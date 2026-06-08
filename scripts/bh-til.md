# bh-til

오늘 배운 중요한 내용을 날짜별 마크다운 목록 파일(`~/.til.md`)에 실시간으로 기록하고 보관하는 쉘 스크립트입니다.

## 🛠 기술 스택
- **Shell**: Bash
- **Parsing**: Awk, Grep
- **macOS Integration**: AppleScript (`osascript`), Custom URL Scheme (`open -g hammerspoon://`)

## 📋 Usage
```bash
# 1. 인자가 없을 때: 오늘 작성한 TIL 목록 조회 후 대화형 입력 프롬프트 제공
./bh-til

# 2. 인자가 있을 때: 한 줄 텍스트를 인자로 받아 바로 저장
./bh-til "Hammerspoon URL Scheme 연동 방법 학습 및 쉘 연동 성공"
```

## ⚙️ 사전 요구사항
- 저장되는 대상 마크다운 파일 경로는 기본값으로 `~/.til.md`에 위치하지만, 환경 변수 `TIL_FILE`을 재지정하여 다른 경로에 저장할 수 있습니다.
