# bh-til-idle-check

Cursor AI 에이전트의 유휴(Idle) 상태를 백그라운드에서 감시하여, 작업 완료 시점에 배운 것을 기록하도록 권장하는 TIL 리마인더 알림을 보내는 백그라운드 헬퍼 스크립트입니다.

## 🛠 기술 스택
- **Shell**: Bash
- **Parsing**: Grep, Stat, Find
- **macOS Integration**: AppleScript (`osascript`), Custom URL Scheme (`open -g hammerspoon://`)
- **Scheduler**: macOS launchd 데몬 스케줄링 연동에 용이

## 📋 Usage
```bash
# 일반적으로 macOS launchd 스케줄러(60초 간격)에 등록되어 실행됩니다.
# 수동 테스트 실행:
./bh-til-idle-check
```

## ⚙️ 기능 상세
- **Idle 감지**: 최근 수정된 Cursor 세션 트랜스크립트 파일(`*.jsonl`)의 타임스탬프를 감시하여, 마지막 활동 시점으로부터 3분(180초) 이상 활동이 없으면 리마인더 알림을 트리거합니다.
- **레벨업 제안**: 유휴 진입 직전까지 진행한 세션 내용에 에이전트 룰이나 스킬 수정 패턴이 감지되면, 단순 TIL 알림 대신 `/bh-agent-level-up` 승격 작업을 유도하는 특화 알림을 전송합니다.
- **중복 방지**: 동일한 유휴 구간 내에서 반복해서 알림이 뜨지 않도록 `/tmp/bh-til-idle.lock` 파일을 이용해 1회만 알림이 전송되도록 제어합니다.
