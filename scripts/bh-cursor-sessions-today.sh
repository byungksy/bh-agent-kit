#!/usr/bin/env bash
# Cursor 채팅 세션 뷰어
# - fzf로 세션 선택 → Cursor에서 열기
# - ←/→ 화살표로 날짜 전환 (최대 14일 전)
# - cursor agents 프로세스 자동 실행
#
# Usage: ~/cursor-sessions-today.sh [--from HH:MM] [--date YYYY-MM-DD] [--list]

set -euo pipefail

CURSOR_PROJECTS="/Users/a1101969/.cursor/projects"
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
DAYS_EN=("Sun" "Mon" "Tue" "Wed" "Thu" "Fri" "Sat")
MAX_OFFSET=13

get_date_with_offset() {
  date -v-${1}d +%Y-%m-%d
}

get_weekday_en() {
  local dow
  dow=$(date -j -f "%Y-%m-%d" "$1" "+%w" 2>/dev/null || date -d "$1" "+%w" 2>/dev/null)
  echo "${DAYS_EN[$dow]}"
}

resolve_workspace_path() {
  local p_dir="$1"
  local candidate=""
  
  if [ -z "$p_dir" ]; then
    echo "/Users/a1101969"
    return
  fi

  if [[ "$p_dir" == Users-a1101969-* ]]; then
    local rest="${p_dir#Users-a1101969-}"
    
    if [[ "$rest" == Projects-* ]]; then
      local proj_name="${rest#Projects-}"
      candidate="/Users/a1101969/Projects/$proj_name"
      if [ -d "$candidate" ]; then echo "$candidate"; return; fi
    elif [[ "$rest" == WebstormProjects-* ]]; then
      local proj_name="${rest#WebstormProjects-}"
      candidate="/Users/a1101969/WebstormProjects/$proj_name"
      if [ -d "$candidate" ]; then echo "$candidate"; return; fi
    fi
    
    candidate="/Users/a1101969/$rest"
    if [ -d "$candidate" ]; then echo "$candidate"; return; fi

    local temp="$rest"
    local prefix="/Users/a1101969"
    while [[ "$temp" == *-* ]]; do
      temp="${temp/-//}"
      candidate="$prefix/$temp"
      if [ -d "$candidate" ]; then echo "$candidate"; return; fi
    done
  fi

  if [[ "$p_dir" == var-folders-* ]]; then
    local rest="${p_dir#var-folders-}"
    local temp="$rest"
    local prefix="/var/folders"
    local i
    for (( i=0; i<5; i++ )); do
      temp="${temp/-//}"
    done
    candidate="$prefix/$temp"
    if [ -d "$candidate" ]; then echo "$candidate"; return; fi
  fi

  echo "/Users/a1101969"
}

# ═══════════════════════════════════════════════════════════════
# 내부 서브커맨드: --collect DATE FROM_HOUR
#   fzf reload에서 호출. 세션 목록을 stdout으로 출력
# ═══════════════════════════════════════════════════════════════
if [[ "${1:-}" == "--collect" ]]; then
  TARGET_DATE="${2:-$(date +%Y-%m-%d)}"
  FROM_HOUR="${3:-08:00}"
  START_TIME="${TARGET_DATE} ${FROM_HOUR}:00"
  END_TIME="${TARGET_DATE} 23:59:59"

  find "$CURSOR_PROJECTS" -name "*.jsonl" -path "*/agent-transcripts/*" -newermt "$START_TIME" ! -newermt "$END_TIME" -print0 2>/dev/null \
    | while IFS= read -r -d '' f; do
      mod=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$f" 2>/dev/null || stat --format="%y" "$f" 2>/dev/null | cut -c1-16)
      echo "$mod|$f"
    done \
    | sort \
    | while IFS='|' read -r mod filepath; do
      uuid=$(basename "$filepath" .jsonl)
      project_dir=$(echo "$filepath" | sed "s|${CURSOR_PROJECTS}/||" | cut -d'/' -f1)
      project_name=$(echo "$project_dir" | sed 's/Users-a1101969-WebstormProjects-//;s/Users-a1101969-//;s/Users-a1101969/home/')

      query=$(head -1 "$filepath" | python3 -c "
import sys, json, re
try:
    obj = json.loads(sys.stdin.read())
    for c in obj.get('message',{}).get('content',[]):
        if c.get('type') == 'text':
            m = re.search(r'<user_query>\s*(.*?)\s*</user_query>', c['text'], re.DOTALL)
            if m:
                q = m.group(1).strip().replace('\n', ' ')[:80]
                print(q)
                break
except:
    pass
" 2>/dev/null)
      [ -z "$query" ] && query="(내용 없음)"
      printf "%s  %-26s  %s\t%s\n" "$mod" "$project_name" "$query" "$uuid"
    done

  exit 0
fi

# ═══════════════════════════════════════════════════════════════
# 내부 서브커맨드: --nav OFFSET_FILE DIRECTION FROM_HOUR
#   날짜 offset을 prev/next로 이동하고 새 세션 목록 출력
# ═══════════════════════════════════════════════════════════════
if [[ "${1:-}" == "--nav" ]]; then
  OFFSET_FILE="$2"
  DIRECTION="$3"
  FROM_HOUR="$4"

  current=$(cat "$OFFSET_FILE" 2>/dev/null || echo "0")
  [[ -z "$current" || ! "$current" =~ ^[0-9]+$ ]] && current=0

  if [[ "$DIRECTION" == "prev" ]]; then
    new_offset=$((current + 1))
    [ $new_offset -gt $MAX_OFFSET ] && new_offset=$MAX_OFFSET
  else
    new_offset=$((current - 1))
    [ $new_offset -lt 0 ] && new_offset=0
  fi

  echo "$new_offset" > "${OFFSET_FILE}.tmp"
  mv "${OFFSET_FILE}.tmp" "$OFFSET_FILE"
  target=$(get_date_with_offset "$new_offset")
  "$SCRIPT_PATH" --collect "$target" "$FROM_HOUR" | tail -10 | cut -f1
  exit 0
fi

# ═══════════════════════════════════════════════════════════════
# 내부 서브커맨드: --header OFFSET_FILE FROM_HOUR
#   현재 offset 기준 헤더 문자열 반환
# ═══════════════════════════════════════════════════════════════
if [[ "${1:-}" == "--header" ]]; then
  OFFSET_FILE="$2"
  FROM_HOUR="$3"

  off=$(cat "$OFFSET_FILE" 2>/dev/null || echo "0")
  [[ -z "$off" || ! "$off" =~ ^[0-9]+$ ]] && off=0
  d=$(get_date_with_offset "$off")
  weekday=$(get_weekday_en "$d")

  if [ "$off" -eq 0 ]; then
    label="Today"
  elif [ "$off" -eq 1 ]; then
    label="Yesterday"
  else
    label="${off}d ago"
  fi

  echo "📋 ${d} (${weekday}, ${label}) ${FROM_HOUR}~ — [Left/Right] Nav, [Tab] Preview, [Enter] Resume, [Ctrl-R] GUI Open, [Esc] Cancel"
  exit 0
fi

# ═══════════════════════════════════════════════════════════════
# 내부 서브커맨드: --detail UUID
#   fzf execute 바인딩에서 호출. 대화 내용을 stdout으로 출력
# ═══════════════════════════════════════════════════════════════
if [[ "${1:-}" == "--detail" ]]; then
  DISPLAY_LINE="$2"
  OFFSET_FILE="$3"
  FROM_HOUR_ARG="$4"

  off=$(cat "$OFFSET_FILE" 2>/dev/null || echo "0")
  target=$(get_date_with_offset "$off")

  uuid=$("$SCRIPT_PATH" --collect "$target" "$FROM_HOUR_ARG" \
    | grep -F "$DISPLAY_LINE" \
    | head -1 \
    | cut -f2)

  if [ -z "$uuid" ]; then
    echo "⚠️  세션을 찾을 수 없습니다: [$DISPLAY_LINE]"
    exit 0
  fi

  jsonl_path=$(find "$CURSOR_PROJECTS" -name "${uuid}.jsonl" -path "*/agent-transcripts/*" 2>/dev/null | head -1)

  if [ -z "$jsonl_path" ]; then
    echo "⚠️  파일을 찾을 수 없습니다: ${uuid}.jsonl"
    exit 0
  fi

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  💬 대화 상세: ${uuid}"
  echo "  📁 파일: $(basename $(dirname $(dirname $jsonl_path)))"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  python3 - "$jsonl_path" <<'PYEOF'
import sys, json, re, textwrap

path = sys.argv[1]
messages = []

with open(path, "r", encoding="utf-8") as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            obj = json.loads(line)
            # role은 최상위, content는 message 하위
            role = obj.get("role", "")
            if role not in ("user", "assistant"):
                continue

            msg = obj.get("message", {})
            content = msg.get("content", [])
            if isinstance(content, str):
                content = [{"type": "text", "text": content}]

            texts = []
            for c in content:
                if isinstance(c, dict) and c.get("type") == "text":
                    t = c.get("text", "")
                    # <user_query> 태그 안의 실제 쿼리 추출
                    m = re.search(r'<user_query>\s*(.*?)\s*</user_query>', t, re.DOTALL)
                    if m:
                        t = m.group(1)
                    else:
                        # 기타 XML 태그 제거
                        t = re.sub(r'<[^>]+>', '', t)
                    t = t.strip()
                    if t:
                        texts.append(t)
                elif isinstance(c, str):
                    texts.append(c.strip())

            if texts:
                messages.append((role, "\n".join(texts)))
        except Exception:
            continue

if not messages:
    print("(대화 내용 없음)")
    sys.exit(0)

# 연속된 같은 role 메시지를 하나로 합치기
merged = []
for role, text in messages:
    if merged and merged[-1][0] == role:
        merged[-1] = (role, merged[-1][1] + "\n\n" + text)
    else:
        merged.append([role, text])

COLS = 72
SEP = "─" * COLS

for role, text in merged:
    if role == "user":
        header = "\033[1;44;97m  👤 사용자  \033[0m"
        indent = "  "
    else:
        header = "\033[1;43;30m  🤖 AI  \033[0m"
        indent = "  "

    print(header)
    for para in text.split("\n"):
        if para.strip():
            wrapped = textwrap.fill(para, width=COLS - len(indent),
                                    initial_indent=indent,
                                    subsequent_indent=indent)
            print(wrapped)
        else:
            print()
    print(f"\033[2m{SEP}\033[0m")
PYEOF

  exit 0
fi

# ═══════════════════════════════════════════════════════════════
# 메인 진입점
# ═══════════════════════════════════════════════════════════════

FROM_HOUR="08:00"
TARGET_DATE=$(date +%Y-%m-%d)
LIST_ONLY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --from) FROM_HOUR="$2"; shift 2 ;;
    --date) TARGET_DATE="$2"; shift 2 ;;
    --list) LIST_ONLY=true; shift ;;
    -h|--help)
      echo "Usage: $0 [--from HH:MM] [--date YYYY-MM-DD] [--list]"
      echo ""
      echo "Options:"
      echo "  --from HH:MM       시작 시간 (기본: 08:00)"
      echo "  --date YYYY-MM-DD  대상 날짜 (기본: 오늘)"
      echo "  --list             fzf 없이 목록만 출력"
      echo ""
      echo "fzf 모드:"
      echo "  ←/→               이전/다음 날짜 (최대 14일 전)"
      echo "  Enter              선택한 세션 재개 (cursor agent --resume)"
      echo "  Ctrl-R             선택한 세션을 Cursor에서 열기"
      echo "  Esc                종료"
      echo ""
      echo "범위: ~/.cursor/projects/ 하위 모든 워크스페이스"
      exit 0
      ;;
    *) echo "Unknown option: $1. Use -h for help."; exit 1 ;;
  esac
done

# cursor agent 프로세스 체크 및 자동 실행
if ! pgrep -f "\.local/bin/agent" > /dev/null 2>&1; then
  echo "⚡ cursor agent 프로세스가 없어 실행합니다..."
  cursor agent > /dev/null 2>&1 &
  sleep 1
fi

# --list 모드
if [ "$LIST_ONLY" = true ]; then
  weekday=$(get_weekday_en "$TARGET_DATE")
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  📋 Cursor Chat Sessions — ${TARGET_DATE} (${weekday}) ${FROM_HOUR}~"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  output=$("$SCRIPT_PATH" --collect "$TARGET_DATE" "$FROM_HOUR")
  if [ -z "$output" ]; then
    echo "  (세션이 없습니다)"
  else
    total=$(echo "$output" | wc -l | tr -d ' ')
    displayed=$(echo "$output" | tail -10)
    n=$(( total > 10 ? total - 10 : 0 ))
    while IFS=$'\t' read -r display uuid; do
      n=$((n + 1))
      printf "\033[1;36m%2d.\033[0m %s\n" "$n" "$display"
    done <<< "$displayed"
    echo ""
    if [ "$total" -gt 10 ]; then
      echo "  최근 10개 표시 (전체 ${total}개)"
    else
      echo "  총 ${total}개 세션"
    fi
  fi
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 0
fi

# ═══════════════════════════════════════════════════════════════
# fzf 인터랙티브 모드 (좌우 날짜 전환)
# ═══════════════════════════════════════════════════════════════

offset_file=$(mktemp)
echo "0" > "$offset_file"
ACTION_FILE=$(mktemp)
echo "resume" > "$ACTION_FILE"
trap "rm -f $offset_file $ACTION_FILE" EXIT

weekday=$(get_weekday_en "$TARGET_DATE")
init_header="📋 ${TARGET_DATE} (${weekday}, Today) ${FROM_HOUR}~ — [Left/Right] Nav, [Tab] Preview, [Enter] Resume, [Ctrl-R] GUI Open, [Esc] Cancel"

nav_left="${SCRIPT_PATH} --nav ${offset_file} prev ${FROM_HOUR}"
nav_right="${SCRIPT_PATH} --nav ${offset_file} next ${FROM_HOUR}"
hdr_cmd="${SCRIPT_PATH} --header ${offset_file} ${FROM_HOUR}"
detail_cmd="${SCRIPT_PATH} --detail {} ${offset_file} ${FROM_HOUR}"

selected=$("$SCRIPT_PATH" --collect "$TARGET_DATE" "$FROM_HOUR" \
  | tail -10 \
  | cut -f1 \
  | fzf --ansi \
        --header="$init_header" \
        --header-first \
        --reverse \
        --no-multi \
        --height=40 \
        --border=rounded \
        --prompt="세션 선택 > " \
        --preview="$detail_cmd" \
        --preview-window="right:50%:wrap:hidden" \
        --bind "left:reload($nav_left)+transform-header($hdr_cmd)" \
        --bind "right:reload($nav_right)+transform-header($hdr_cmd)" \
        --bind "tab:toggle-preview" \
        --bind "ctrl-r:execute(echo open > $ACTION_FILE)+accept" \
        --expect="ctrl-r" \
  2>/tmp/fzf-sessions-err)

# --expect 사용 시 첫 줄에 눌린 키가 출력됨
pressed_key=$(echo "$selected" | head -1)
selected=$(echo "$selected" | tail -n +2)

# fzf 에러 확인
if [ -s /tmp/fzf-sessions-err ]; then
  # 실제 구동 실패 관련 에러(unknown option, tty 관련 등)가 있는지 체크하여 출력하고 에러 종료
  if grep -q -E -i "invalid|error|failed|unknown|tty" /tmp/fzf-sessions-err; then
    echo "⚠️  fzf 실행 오류가 발생했습니다:"
    cat /tmp/fzf-sessions-err
    exit 1
  fi
fi

if [ -z "$selected" ]; then
  exit 0
fi

# 선택 항목에서 UUID 추출
current_offset=$(cat "$offset_file")
current_date=$(get_date_with_offset "$current_offset")

uuid=$("$SCRIPT_PATH" --collect "$current_date" "$FROM_HOUR" \
  | tail -10 \
  | grep -F "$selected" \
  | head -1 \
  | cut -f2)

if [ -z "$uuid" ]; then
  echo "⚠️  세션 UUID를 찾지 못했습니다."
  echo "   selected: [$selected]"
  exit 1
fi

action=$(cat "$ACTION_FILE" 2>/dev/null || echo "resume")

# Enter (기본): cursor agent --resume 실행
if [[ "$pressed_key" != "ctrl-r" && "$action" == "resume" ]]; then
  echo ""
  echo "▶  세션 재개 준비: ${uuid}"
  echo ""

  # workspace 경로 복원
  jsonl_path=$(find "$CURSOR_PROJECTS" -name "${uuid}.jsonl" -path "*/agent-transcripts/*" 2>/dev/null | awk '{ print length, $0 }' | sort -nr | cut -d" " -f2- | head -1)
  if [ -n "$jsonl_path" ]; then
    project_dir=$(echo "$jsonl_path" | sed "s|${CURSOR_PROJECTS}/||" | cut -d'/' -f1)
  else
    project_dir=""
  fi
  workspace_path=$(resolve_workspace_path "$project_dir")

  echo "📂 Workspace: ${workspace_path}"
  echo "⚡ 에이전트 연결 상태 점검 중..."

  status_ok=false
  # status 명령이 3초 이내에 성공하고 정상 반환값을 갖는지 확인하기 위해 
  # 백그라운드로 돌린 뒤 wait 하는 간단한 타임아웃 메커니즘 적용
  (cursor agent status >/dev/null 2>&1) &
  status_pid=$!
  count=0
  while kill -0 $status_pid 2>/dev/null; do
    sleep 0.5
    count=$((count + 1))
    if [ $count -ge 6 ]; then
      # 3초 초과 시 kill
      kill -9 $status_pid 2>/dev/null || true
      break
    fi
  done
  
  if wait $status_pid 2>/dev/null; then
    status_ok=true
  fi

  if [ "$status_ok" = false ]; then
    echo "⚠️  백그라운드 에이전트 데몬이 응답하지 않거나 프로세스가 꼬였습니다."
    echo "⚡ 기존 에이전트 프로세스 정리 중..."
    pkill -f "\.local/bin/agent" || true
    pkill -f "cursor-agent" || true
    sleep 1
    echo "⚡ 에이전트 데몬 새로 시작 중..."
    cursor agent > /dev/null 2>&1 &
    sleep 1.5
  fi

  echo "▶  에이전트 진입을 시도합니다..."
  echo ""
  cursor agent --workspace="$workspace_path" --resume="$uuid" || {
    exit_code=$?
    echo ""
    echo "❌ 에이전트 진입 실패 (Exit Code: $exit_code)"
    echo "💡 문제 해결 가이드:"
    echo "  1. 로그인 세션이 만료되었을 수 있습니다. 'cursor agent status' 명령으로 로그인 상태를 확인해보세요."
    echo "  2. 문제가 지속되면 'pkill -f \"\\.local/bin/agent\"' 로 프로세스를 수동 정리해보세요."
    echo ""
    read -p "엔터키를 누르면 종료합니다..."
  }
fi

# Enter: 기존 동작 (UUID 클립보드 복사 + Cursor에서 Cmd+K)
echo -n "$uuid" | pbcopy

echo ""
echo "🚀 세션 열기: ${uuid}"
echo "   📋 UUID 클립보드 복사 완료"
echo "   ⌨️  Cursor에서 Cmd+K → 붙여넣기로 검색 중..."

osascript <<'APPLESCRIPT' 2>/tmp/applescript-err
tell application "Cursor" to activate
delay 1.5

tell application "System Events"
    key code 40 using command down
    delay 0.8
    key code 9 using command down
end tell
APPLESCRIPT

if [ $? -ne 0 ]; then
  echo "   ⚠️  AppleScript 오류: $(cat /tmp/applescript-err)"
  echo "   💡 시스템 설정 → 개인정보 보호 → 손쉬운 사용에서 터미널 앱 권한을 확인하세요"
else
  echo "   ✅ 완료 — Cursor에서 해당 세션을 선택하세요"
fi
