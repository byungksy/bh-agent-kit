# bh-cursor-notify-setup

Cursor 프롬프트에 `알려줘`가 있으면 에이전트 완료 시 Hammerspoon 알림(5초, 클릭 → Cursor 포커스)을 띄운다.

## Usage

```bash
bh-cursor-notify-setup
# Hammerspoon → Reload Config
# ~/.cursor/hooks.json 병합 (출력 안내 따름)
```

## 테스트

```bash
open -g "hammerspoon://cursor-done?title=테스트&msg=확인&duration=5"
```

## 관련 파일

- `etc/hammerspoon/cursor-agent-notify.snippet.lua`
- `hooks/flag-notify-on-alleoju.sh`, `hooks/notify-on-alleoju.sh`
- `etc/hammerspoon/README.md`
