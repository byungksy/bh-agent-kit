#!/bin/bash
# Cursor Hook: auto 모드 turn별 사용 모델 표시
# 이벤트: afterAgentResponse
# - stderr 한 줄 (Cursor "Hooks" 출력 채널에서 확인)
# - ~/.cursor/turn-models.jsonl 에 JSONL append (tail/grep/통계용)
#
# 비고: 기존 ~/.cursor/hooks/track-tokens.sh 와 동일 이벤트로 병존한다.
# 표시 채널을 macOS 알림으로 바꾸려면 stderr 라인 대신 osascript 한 줄을 쓰면 된다.

set -e

LOG_FILE="$HOME/.cursor/turn-models.jsonl"
mkdir -p "$(dirname "$LOG_FILE")"

input=$(cat)

# 필드 추출 (snake_case 우선, camelCase 폴백)
model=$(echo "$input" | jq -r '.model // .modelId // "unknown"')
session_id=$(echo "$input" | jq -r '.session_id // .sessionId // .conversation_id // "unknown"')
generation_id=$(echo "$input" | jq -r '.generation_id // "unknown"')
workspace=$(echo "$input" | jq -r '.workspace_roots[0] // "unknown"')

timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# stderr: Cursor "Hooks" 출력 채널에 노출
# ponytail: 한 줄로만. 더 화려하게 가지 않는다.
echo "[turn-model] ${model}  (gen=${generation_id})" >&2

# JSONL 기록 (별도 분석/통계용)
printf '{"timestamp":"%s","model":"%s","session":"%s","generation":"%s","workspace":"%s"}\n' \
  "$timestamp" "$model" "$session_id" "$generation_id" "$workspace" >> "$LOG_FILE"

exit 0
