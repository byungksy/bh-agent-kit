#!/bin/bash
# Flag the current session when the user asks to be notified ("알려줘").
# Event: beforeSubmitPrompt
# Requires: ~/.agents/hooks/_lib.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_lib.sh"
lib_init

prompt=$(lib_get_user_message)
if ! printf '%s' "$prompt" | grep -qE '알려줘\.?'; then
  exit 0
fi

conversation_id=$(echo "$_LIB_INPUT" | jq -r '.conversation_id // .session_id // empty')
[ -z "$conversation_id" ] && exit 0

STATE_DIR="${HOME}/.agents/state/notify-on-stop"
mkdir -p "$STATE_DIR"
printf '%s' "$conversation_id" > "${STATE_DIR}/pending"
date -u +%Y-%m-%dT%H:%M:%SZ > "${STATE_DIR}/pending.time"

exit 0
