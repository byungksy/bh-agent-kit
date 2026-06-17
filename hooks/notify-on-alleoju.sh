#!/bin/bash
# Hammerspoon toast when user asked "알려줘" in prompt. Event: stop
# Requires: ~/.agents/hooks/_lib.sh, Hammerspoon cursor-done URL handler

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_lib.sh"
lib_init

status=$(lib_get_stop_status)
[ "$status" = "completed" ] || exit 0

STATE_DIR="${HOME}/.agents/state/notify-on-stop"
[ -f "${STATE_DIR}/pending" ] || exit 0

pending_conv=$(cat "${STATE_DIR}/pending" 2>/dev/null || true)
current_conv=$(echo "$_LIB_INPUT" | jq -r '.conversation_id // .session_id // empty')

if [ -z "$pending_conv" ]; then
  exit 0
fi

if [ -n "$current_conv" ] && [ "$current_conv" != "$pending_conv" ]; then
  exit 0
fi

title_enc=$(python3 -c 'import urllib.parse; print(urllib.parse.quote("작업 완료"))')
msg_enc=$(python3 -c 'import urllib.parse; print(urllib.parse.quote("에이전트 처리가 완료되었습니다. 클릭하면 Cursor로 이동합니다."))')
open -g "hammerspoon://cursor-done?title=${title_enc}&msg=${msg_enc}&duration=5"

TN="$(command -v terminal-notifier 2>/dev/null || true)"
if [ -n "$TN" ] && [ -x "$TN" ]; then
  "$TN" -title "작업 완료" -message "에이전트 처리가 완료되었습니다." -sound Glass -activate "com.todesktop.230313mzl4w4u92" 2>/dev/null || true
fi

rm -f "${STATE_DIR}/pending" "${STATE_DIR}/pending.time"
exit 0
