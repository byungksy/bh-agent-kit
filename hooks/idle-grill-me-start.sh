#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_lib.sh"
lib_init

current_conv=$(echo "$_LIB_INPUT" | jq -r '.conversation_id // .session_id // empty')
if [ -z "$current_conv" ]; then
  exit 0
fi

STATE_DIR="${HOME}/.agents/state/idle-grill"
mkdir -p "$STATE_DIR"
now=$(date +%s)
echo "$now" > "${STATE_DIR}/${current_conv}.start"
