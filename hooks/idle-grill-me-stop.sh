#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_lib.sh"
lib_init

status=$(lib_get_stop_status)
if [ "$status" != "completed" ]; then
  exit 0
fi

current_conv=$(echo "$_LIB_INPUT" | jq -r '.conversation_id // .session_id // empty')
if [ -z "$current_conv" ]; then
  exit 0
fi

STATE_DIR="${HOME}/.agents/state/idle-grill"
mkdir -p "$STATE_DIR"
now=$(date +%s)
echo "$now" > "${STATE_DIR}/${current_conv}.stop"

(
  sleep 30
  
  last_start=$(cat "${STATE_DIR}/${current_conv}.start" 2>/dev/null || echo 0)
  if [ "$last_start" -gt "$now" ]; then
    exit 0
  fi
  
  last_stop=$(cat "${STATE_DIR}/${current_conv}.stop" 2>/dev/null || echo 0)
  if [ "$last_stop" -gt "$now" ]; then
    exit 0
  fi

  if command -v agy >/dev/null 2>&1; then
    # In agy, trigger the grill-me interactively
    agy --conversation "$current_conv" -p "/grill-me" &
  fi
) &> /dev/null &
