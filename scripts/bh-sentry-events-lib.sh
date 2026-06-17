#!/usr/bin/env bash
# ── bh-sentry-events-lib.sh ───────────────────────────────────────────────────
# Sentry Events API group-by 공통 라이브러리.
# 직접 실행하지 말고 bh-sentry-events-groupby 등에서 source 한다.
#
# 인증 SSOT: ~/.cursor/mcp.json → mcpServers.sentry-selfhosted-mcp.env
#   SENTRY_AUTH_TOKEN, SENTRY_URL, SENTRY_ORG_SLUG
#
# 함수:
#   bh_sentry_load_mcp          — mcp.json에서 Sentry env 로드
#   bh_sentry_events_groupby    — Events API 호출 + TSV 출력
# ──────────────────────────────────────────────────────────────────────────────

bh_sentry_load_mcp() {
  MCP_CONFIG="${MCP_CONFIG:-$HOME/.cursor/mcp.json}"

  if [[ ! -f "$MCP_CONFIG" ]]; then
    echo "Error: mcp.json not found ($MCP_CONFIG)" >&2
    return 1
  fi

  # shellcheck disable=SC2016
  eval "$(
    python3 - "$MCP_CONFIG" <<'PYEOF'
import json, sys

path = sys.argv[1]
servers = json.load(open(path)).get("mcpServers", {})
env = servers.get("sentry-selfhosted-mcp", {}).get("env", {})

def emit(key, val):
    safe = (val or "").replace("'", "'\\''")
    print(f"export {key}='{safe}'")

emit("SENTRY_AUTH_TOKEN", env.get("SENTRY_AUTH_TOKEN", ""))
emit("SENTRY_API_URL", env.get("SENTRY_URL", ""))
emit("SENTRY_ORG", env.get("SENTRY_ORG_SLUG", ""))
PYEOF
  )"

  if [[ -z "${SENTRY_AUTH_TOKEN:-}" ]]; then
    echo "Error: SENTRY_AUTH_TOKEN missing in mcp.json (sentry-selfhosted-mcp)" >&2
    return 1
  fi

  SENTRY_API_URL="${SENTRY_API_URL:-https://search-sentry-admin.11stcorp.com}"
  SENTRY_ORG="${SENTRY_ORG:-sentry}"
}

# bh_sentry_events_groupby GROUP_FIELD QUERY PROJECT STATS_PERIOD SORT_FIELD RAW
bh_sentry_events_groupby() {
  local group_field="$1"
  local query="$2"
  local project="$3"
  local stats_period="$4"
  local sort_field="$5"
  local raw="$6"

  local endpoint="${SENTRY_API_URL%/}/api/0/organizations/${SENTRY_ORG}/events/"

  local response
  response="$(
    curl -sS -G \
      -H "Authorization: Bearer ${SENTRY_AUTH_TOKEN}" \
      -H "Accept: application/json" \
      --data-urlencode "field=${group_field}" \
      --data-urlencode "field=count()" \
      --data-urlencode "query=${query}" \
      --data-urlencode "groupBy=${group_field}" \
      --data-urlencode "sort=${sort_field}" \
      --data-urlencode "statsPeriod=${stats_period}" \
      --data-urlencode "project=${project}" \
      "$endpoint"
  )"

  if [[ "$raw" == "1" ]]; then
    printf '%s\n' "$response"
    return 0
  fi

  if ! command -v jq >/dev/null 2>&1; then
    printf '%s\n' "$response"
    return 0
  fi

  if ! printf '%s' "$response" | jq -e '.data' >/dev/null 2>&1; then
    printf '%s\n' "$response" | jq . >&2 || printf '%s\n' "$response" >&2
    return 1
  fi

  echo "# groupBy=${group_field} query=${query} project=${project} period=${stats_period}"
  printf '%s\n' "$response" | jq -r --arg gf "$group_field" '
    .data
    | sort_by(-."count()")
    | .[]
    | [(.[$gf] // "(empty)"), ."count()"]
    | @tsv
  ' | awk -v gf="$group_field" 'BEGIN { print gf "\tcount" } { print }'
}
