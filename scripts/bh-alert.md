# bh-alert

macOS 시스템 배너 알림 및 Hammerspoon 토스트 팝업, 그리고 Slack DM을 동시에 전송할 수 있는 자동화용 범용 알림 헬퍼 스크립트입니다.

## 🛠 기술 스택
- **Shell**: Bash
- **macOS Integration**: AppleScript (`osascript`), Custom URL Scheme (`open -g hammerspoon://`)
- **API & Network**: Python3 (Slack payload JSON 인코딩용), cURL (Slack Web API)

## 📋 Usage
```bash
# 1. 로컬 알림 팝업만 전송 (시스템 배너 + 해머스푼 토스트)
./bh-alert "작업 성공"

# 2. 로컬 알림 + Slack DM 전송
./bh-alert "배포 완료" --slack

# 3. 파이프(stdin) 연결 및 슬랙 전송 (배너에는 첫 줄만 노출, 슬랙 DM으로는 전체 내용 전송)
echo -e "빌드 로그 요약\n- 에러: 없음\n- 시간: 12초" | ./bh-alert --slack

# 4. 부제목을 포함한 로컬 팝업 발송
./bh-alert "메시지 내용" "부제목(세부 정보)"
```

## ⚙️ 사전 요구사항
- Slack DM 전송 기능을 사용하려면 `~/slack-cursor-bot/.env` 파일 내에 `MY_SLACK_BOT_TOKEN` 및 `SLACK_DM_USER_ID` 환경 변수가 등록되어 있어야 합니다.
