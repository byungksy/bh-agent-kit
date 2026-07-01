# bh-get-token-usage

Cursor Analytics API (`/analytics/by-user/models`)를 호출해 사용자별 model messages 합계로 팀 내부 랭킹을 계산·출력하는 스크립트. Cursor 리더보드가 Chats / Tab / Agent LoC만 노출하고 토큰 기준 랭킹 UI를 제공하지 않는 한계를 우회한다.

## 🛠 기술 스택

- **Shell**: Bash (`set -euo pipefail`)
- **Deps**: `curl`, `jq`, `python3`, `security` (macOS Keychain)
- **API**: `https://api.cursor.com/analytics/by-user/models` — Enterprise Analytics API

## 📋 Usage

```bash
bh-get-token-usage
bh-get-token-usage --start-date 2026-06-02 --end-date 2026-07-01 --top 10
bh-get-token-usage --users alice@example.com,bob@example.com
```

옵션:

- `--start-date YYYY-MM-DD` (기본: 30일 전)
- `--end-date YYYY-MM-DD` (기본: 오늘)
- `--top N` (기본: 20)
- `--users email1,email2` (선택 필터)
- `--page-size N` (기본: 200, 최대 500)

## 🔑 인증 토큰 탐색 순서

`bh-token-lookup` 룰을 따른다:

1. `CURSOR_API_KEY` 환경변수
2. `~/.config/11st-ai-credentials.env` 의 `CURSOR_API_KEY`
3. `~/.cursor/api-key` 첫 줄
4. macOS Keychain (일반적인 Cursor API Key service/host)

권장 저장 위치: `~/.config/11st-ai-credentials.env`

```env
CURSOR_API_KEY=your_dashboard_api_key
```

Cursor Dashboard → API Keys 에서 발급하며 **Enterprise Admin 권한**이 필요하다. 권한이 없으면 API가 401/403으로 실패한다.

## ⚠️ 주의

- 이 스크립트가 쓰는 API Key는 **Dashboard 발급 Admin API Key**이며, Cursor 앱 로컬 `state.vscdb`의 accessToken과 다르다. 후자로는 `/analytics/*` 엔드포인트를 호출할 수 없다.
- 지표는 **`model_breakdown.messages` 합계**를 토큰 사용량의 프록시로 사용한다. 실제 토큰 수는 아니지만 사용자별 상대 랭킹 근사치로 유효하다.
- 팀 플랜의 경우 `/analytics/by-user/*` 접근 가능 여부가 다를 수 있다.
