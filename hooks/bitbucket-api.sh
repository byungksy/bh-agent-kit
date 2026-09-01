#!/bin/bash
# ==============================================================================
# bitbucket-api.sh — Bitbucket Cloud & Confluence Wiki API CLI Wrapper
# ==============================================================================
#
# [개요]
# Bitbucket Cloud REST API 및 사내 Confluence REST API를 통합하여,
# PR 제어(머지, 승인, 거절, Draft 해제, 코멘트 등록) 및 PR 이미지 업로드 연동을 지원하는 CLI 래퍼입니다.
#
# [인증 정보 로드 순서]
# 1순위: ~/.config/company-ai-credentials.env (company-ai-toolkit 공유)
# 2순위: ~/.agents/secrets.json + profile.json (레거시 fallback)
#
# [사용법 및 주요 명령어]
#
# 1. PR 라이프사이클 Shorthand:
#   bitbucket-api.sh merge         <workspace> <repo> <pr_id>
#   bitbucket-api.sh approve       <workspace> <repo> <pr_id>
#   bitbucket-api.sh decline       <workspace> <repo> <pr_id>
#   bitbucket-api.sh undraft       <workspace> <repo> <pr_id>
#   bitbucket-api.sh comment       <workspace> <repo> <pr_id> <markdown_text>
#
# 2. 이미지 업로드 & PR 이미지 코멘트 연동:
#   # 사내 Confluence 위키 페이지에 이미지를 첨부파일로 업로드하고 URL 및 Markdown 태그 반환
#   bitbucket-api.sh upload-wiki-image <page_id> <local_image_path> [target_filename]
#
#   # 위키에 이미지를 업로드한 후 해당 PR에 이미지 마크다운 코멘트를 즉시 등록
#   bitbucket-api.sh comment-image     <workspace> <repo> <pr_id> <page_id> <local_image_path> [caption]
#
# 3. 범용 Bitbucket REST API 호출 (PATH는 /2.0 이후 상대경로):
#   bitbucket-api.sh GET  /repositories/company/project-repo/pullrequests/144
#   bitbucket-api.sh POST /repositories/company/project-repo/pullrequests/144/comments '{"content":{"raw":"코멘트"}}'
#   bitbucket-api.sh PUT  /repositories/company/project-repo/pullrequests/144 '{"title":"수정된 제목"}'
# ==============================================================================

set -euo pipefail

CREDENTIALS_ENV="${HOME}/.config/company-ai-credentials.env"
SECRETS_FILE="${HOME}/.agents/secrets.json"
PROFILE_FILE="${HOME}/.agents/profile.json"
BASE_URL="https://api.bitbucket.org/2.0"
CONFLUENCE_BASE_URL="https://wiki.company.com"

usage() {
  local code="${1:-1}"
  cat >&2 <<'USAGE'
Usage: bitbucket-api.sh <COMMAND|METHOD> [ARGS...]

[Bitbucket PR Shorthand]
  bitbucket-api.sh merge         <workspace> <repo> <pr_id>
  bitbucket-api.sh approve       <workspace> <repo> <pr_id>
  bitbucket-api.sh decline       <workspace> <repo> <pr_id>
  bitbucket-api.sh undraft       <workspace> <repo> <pr_id>
  bitbucket-api.sh comment       <workspace> <repo> <pr_id> <markdown_text>

[Image Upload & PR Integration]
  bitbucket-api.sh upload-wiki-image <page_id> <local_image_path> [target_filename]
  bitbucket-api.sh comment-image     <workspace> <repo> <pr_id> <page_id> <local_image_path> [caption]

[Raw Bitbucket REST API]
  bitbucket-api.sh GET|POST|PUT|DELETE <PATH> [JSON_BODY]
USAGE
  exit "$code"
}

if [ $# -lt 1 ]; then
  usage
fi

# ── Auth Loader ───────────────────────────────────────────────

_read_env_var() {
  local file="$1" key="$2"
  grep -E "^${key}=" "$file" 2>/dev/null | head -1 | cut -d= -f2- | tr -d '"'"'" || true
}

load_auth() {
  TOKEN="" EMAIL="" CONFLUENCE_TOKEN=""

  # 1순위: ~/.config/company-ai-credentials.env (company-ai-toolkit 공유)
  if [ -f "$CREDENTIALS_ENV" ]; then
    TOKEN=$(_read_env_var "$CREDENTIALS_ENV" "BITBUCKET_BEARER_TOKEN")
    EMAIL=$(_read_env_var "$CREDENTIALS_ENV" "BITBUCKET_EMAIL")
    CONFLUENCE_TOKEN=$(_read_env_var "$CREDENTIALS_ENV" "CONFLUENCE_PERSONAL_TOKEN")
  fi

  # 2순위: ~/.agents/secrets.json + profile.json (레거시 fallback)
  if { [ -z "$TOKEN" ] || [ -z "$EMAIL" ]; } && [ -f "$SECRETS_FILE" ] && [ -f "$PROFILE_FILE" ]; then
    [ -z "$TOKEN" ] && TOKEN=$(jq -r '.["company-bitbucket-mcp.BITBUCKET_BEARER_TOKEN"] // empty' "$SECRETS_FILE")
    [ -z "$EMAIL" ] && EMAIL=$(jq -r '.bitbucket.email // empty' "$PROFILE_FILE")
  fi
  if [ -z "$CONFLUENCE_TOKEN" ] && [ -f "$SECRETS_FILE" ]; then
    CONFLUENCE_TOKEN=$(jq -r '.["confluence.personal_token"] // .["mcp-atlassian.CONFLUENCE_PERSONAL_TOKEN"] // empty' "$SECRETS_FILE")
  fi

  if [ -z "$TOKEN" ]; then
    echo "Error: BITBUCKET_BEARER_TOKEN not found in $CREDENTIALS_ENV or $SECRETS_FILE" >&2; exit 1
  fi
  if [ -z "$EMAIL" ]; then
    echo "Error: BITBUCKET_EMAIL not found in $CREDENTIALS_ENV or $PROFILE_FILE" >&2; exit 1
  fi
}

# ── HTTP Execution ────────────────────────────────────────────

api_call() {
  local method="$1" path="$2" body="${3:-}"
  local url="${BASE_URL}${path}"

  local -a args=(
    -s -w "\n%{http_code}"
    -X "$method"
    "$url"
    -u "${EMAIL}:${TOKEN}"
    -H "Accept: application/json, text/plain, */*"
  )

  if [ -n "$body" ]; then
    args+=(-H "Content-Type: application/json" -d "$body")
  fi

  local response http_code body_text
  response=$(curl "${args[@]}")
  http_code=$(echo "$response" | tail -1)
  body_text=$(echo "$response" | sed '$d')

  echo "$body_text"

  if [ "${http_code:-0}" -ge 400 ] 2>/dev/null; then
    echo "HTTP ${http_code}" >&2
    return 1
  fi
}

# ── Confluence Wiki Image Upload ──────────────────────────────

upload_wiki_image() {
  local page_id="$1" local_path="$2" target_filename="${3:-}"

  if [ ! -f "$local_path" ]; then
    echo "Error: Local image file not found: $local_path" >&2; return 1
  fi

  if [ -z "$CONFLUENCE_TOKEN" ]; then
    echo "Error: CONFLUENCE_PERSONAL_TOKEN not found in $CREDENTIALS_ENV" >&2; return 1
  fi

  if [ -z "$target_filename" ]; then
    target_filename="$(basename "$local_path")"
  fi

  # Confluence REST API multipart attachment upload
  local upload_url="${CONFLUENCE_BASE_URL}/rest/api/content/${page_id}/child/attachment"
  local resp
  resp=$(curl -k -s -X POST \
    -H "Authorization: Bearer ${CONFLUENCE_TOKEN}" \
    -H "X-Atlassian-Token: nocheck" \
    -F "file=@${local_path};type=image/png;filename=${target_filename}" \
    "$upload_url")

  local full_img_url="${CONFLUENCE_BASE_URL}/download/attachments/${page_id}/${target_filename}"
  echo "Image uploaded successfully to Wiki (Page ID: ${page_id})" >&2
  echo "Filename: ${target_filename}" >&2
  echo "Image URL: ${full_img_url}" >&2

  # 반환값으로 Markdown 형식 출력
  echo "![${target_filename}](${full_img_url})"
}

# ── PR Shorthand Functions ────────────────────────────────────

pr_comment() {
  local ws="$1" repo="$2" pr_id="$3" text="$4"
  local base="/repositories/${ws}/${repo}/pullrequests/${pr_id}"
  local payload
  payload=$(jq -n --arg raw "$text" '{"content":{"raw":$raw}}')
  api_call POST "${base}/comments" "$payload"
}

pr_comment_image() {
  local ws="$1" repo="$2" pr_id="$3" page_id="$4" local_path="$5" caption="${6:-}"
  local target_filename
  target_filename="$(basename "$local_path")"

  # 1. 위키에 이미지 업로드
  local md_img
  md_img=$(upload_wiki_image "$page_id" "$local_path" "$target_filename" | tail -1)

  # 2. 코멘트 본문 조합
  local comment_body=""
  if [ -n "$caption" ]; then
    comment_body="${caption}"$'\n\n'"${md_img}"
  else
    comment_body="${md_img}"
  fi

  # 3. PR 코멘트 등록
  pr_comment "$ws" "$repo" "$pr_id" "$comment_body"
}

shorthand() {
  local action="$1" ws="$2" repo="$3" pr_id="$4"
  local base="/repositories/${ws}/${repo}/pullrequests/${pr_id}"

  case "$action" in
    merge)   api_call POST "${base}/merge" ;;
    approve) api_call POST "${base}/approve" ;;
    decline) api_call POST "${base}/decline" ;;
    undraft)
      local current title payload
      current=$(api_call GET "$base")
      title=$(echo "$current" | jq -r '.title // empty')
      if [ -z "$title" ]; then
        echo "Error: failed to read PR title" >&2; return 1
      fi
      payload=$(jq -n --arg t "$title" '{"title":$t,"draft":false}')
      api_call PUT "$base" "$payload"
      ;;
  esac
}

# ── Main ──────────────────────────────────────────────────────

load_auth

case "$1" in
  merge|approve|decline|undraft)
    if [ $# -lt 4 ]; then
      echo "Usage: bitbucket-api.sh $1 <workspace> <repo> <pr_id>" >&2; exit 1
    fi
    shorthand "$1" "$2" "$3" "$4"
    ;;
  comment)
    if [ $# -lt 5 ]; then
      echo "Usage: bitbucket-api.sh comment <workspace> <repo> <pr_id> <markdown_text>" >&2; exit 1
    fi
    pr_comment "$2" "$3" "$4" "$5"
    ;;
  upload-wiki-image)
    if [ $# -lt 3 ]; then
      echo "Usage: bitbucket-api.sh upload-wiki-image <page_id> <local_image_path> [target_filename]" >&2; exit 1
    fi
    upload_wiki_image "$2" "$3" "${4:-}"
    ;;
  comment-image)
    if [ $# -lt 6 ]; then
      echo "Usage: bitbucket-api.sh comment-image <workspace> <repo> <pr_id> <page_id> <local_image_path> [caption]" >&2; exit 1
    fi
    pr_comment_image "$2" "$3" "$4" "$5" "$6" "${7:-}"
    ;;
  GET|POST|PUT|DELETE)
    if [ $# -lt 2 ]; then
      usage
    fi
    api_call "$1" "$2" "${3:-}"
    ;;
  help|--help|-h|"")
    usage 0
    ;;
  *)
    echo "Error: unknown method or command '$1'" >&2
    usage 1
    ;;
esac
