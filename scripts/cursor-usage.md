# cursor-usage

로컬의 Cursor 앱 데이터베이스에서 인증 세션 토큰을 추출한 뒤, Cursor 공식 API를 호출하여 현재 본인의 AI(Premium 및 On-Demand) 사용량 통계와 남은 크레딧 상태를 가져오고, 터미널 리포트 출력 및 알림을 전송하는 스크립트입니다.

## 🛠 기술 스택
- **Shell**: Bash
- **Database**: SQLite3
- **Language**: Python3 (API 응답 파싱 및 시각화 바 차트 생성용)
- **API & Network**: cURL (Cursor API 연동)
- **macOS Integration**: AppleScript (`osascript`), Custom URL Scheme (`open -g hammerspoon://`)

## 📋 Usage
```bash
# 터미널에서 실행 후 사용량 통계 및 배너/토스트 알림 수신
./cursor-usage
```

## ⚙️ 기능 상세
- **자동 인증**: `~/Library/Application Support/Cursor`의 로컬 DB (`state.vscdb`)에서 로그인된 Access Token을 자동으로 찾아내어 복잡한 로그인 과정 없이 사용량을 즉시 조회합니다.
- **실시간 통계**: Premium AI 모델 호출 횟수와 전체 리셋 예정일, On-Demand 결제액(개인/팀)의 한도 및 사용 잔액을 백분율 막대 그래프와 함께 가시성 높게 표시합니다.
