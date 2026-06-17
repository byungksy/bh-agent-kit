# Hammerspoon — Cursor agent 완료 알림

프롬프트에 `알려줘`가 포함되면, 에이전트 `stop` 시 macOS 알림(5초)을 띄우고 클릭 시 Cursor로 포커스한다.

## 구성

| 파일 | 역할 |
|------|------|
| `cursor-agent-notify.snippet.lua` | `hammerspoon://cursor-done` URL 핸들러 |
| `../hooks/flag-notify-on-alleoju.sh` | `beforeSubmitPrompt` — `알려줘` 감지 |
| `../hooks/notify-on-alleoju.sh` | `stop` — Hammerspoon URL 호출 |

## 설치

```bash
bh-cursor-notify-setup
# Hammerspoon 메뉴 → Reload Config
```

수동 설치:

1. `hooks/*.sh` → `~/.agents/hooks/` (실행 권한)
2. `cursor-agent-notify.snippet.lua` 내용을 `~/.hammerspoon/init.lua` 끝에 추가
3. `~/.cursor/hooks.json`에 훅 등록 (`etc/hooks/cursor-notify.snippet.json` 참고)

## 사전 요구

- Hammerspoon 설치·실행
- **시스템 설정 → 알림 → Hammerspoon** — 알림 허용, 스타일 알림/배너
- `~/.agents/hooks/_lib.sh` (11st-ai-toolkit / agents sync)

## 테스트

```bash
open -g "hammerspoon://cursor-done?title=테스트&msg=알림%20확인&duration=5"
```

Console: `cursor-done notify sent` — 에러 없으면 정상.

## 주의

- `hs.ipc.setup`은 Hammerspoon 1.1.1에서 없음 — 사용하지 않음
- `notify:register` / `hs.notify.register` 객체 메서드 패턴 사용 금지 → `hs.notify.new(callback, attrs)` 사용
