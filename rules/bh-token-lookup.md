# bh-token-lookup

개인 도구가 인증 토큰을 찾을 때, 아래 순서 외의 위치는 새로 만들지 않는다. 헤매지 않기 위한 SSOT 룰.

## When (Read on demand)

- 새 `bh-*` 스크립트에 API 호출을 붙일 때
- 기존 스크립트가 "토큰 없음" / 401·403으로 실패했을 때
- Cursor 사용량·랭킹·analytics 조회 요청

## Cursor 토큰은 두 종류 (호환되지 않음)

| 용도 | 종류 | 위치 |
|------|------|------|
| 개인 사용량 (`api2.cursor.sh/auth/usage`, `cursor.com/api/usage-summary`) | 로컬 Access Token | `~/Library/Application Support/Cursor/User/globalStorage/state.vscdb` — SQLite `SELECT value FROM ItemTable WHERE key = 'cursorAuth/accessToken'` |
| 팀·Enterprise Analytics (`api.cursor.com/analytics/...`) | Dashboard 발급 API Key | env `CURSOR_API_KEY` 또는 `~/.config/11st-ai-credentials.env` |

두 값을 서로 대체해 쓰지 않는다. 요청 API에 맞는 걸 골라야 한다.

## 전역 탐색 순서 (모든 서비스 공통)

1. 환경변수 (`CURSOR_API_KEY`, `BITBUCKET_BEARER_TOKEN`, …)
2. `~/.config/11st-ai-credentials.env` — 개인 credentials SSOT (`source` 로 로드)
3. `~/.cursor/mcp.json` — MCP 토큰 SSOT (`bh-secrets` 관리, loader: `~/.agents/scripts/bh-secrets.sh`)
4. 서비스별 특수 위치 (Cursor local: SQLite `state.vscdb` / git: credential helper 등)
5. macOS Keychain (`security find-generic-password -w -s <service>`)

## 규칙

- **MUST**: 위 순서대로 조회하고 첫 번째로 유효한 값을 사용한다
- **MUST**: 신규 키는 위 SSOT 중 하나에만 추가한다 (새 저장소 임의 생성 금지)
- **MUST**: 로컬 파일에 새로 저장할 때 `chmod 600` 적용
- **MUST NOT**: 토큰을 코드·리포지토리·로그·에러 메시지에 그대로 노출

## 알려진 매핑 (2026-07 기준)

| 키 | SSOT |
|----|------|
| `CURSOR_API_KEY` | `credentials.env` |
| Cursor Access Token | `state.vscdb` (SQLite) |
| `BITBUCKET_BEARER_TOKEN`, `BITBUCKET_EMAIL` | `mcp.json` (bh-secrets) |
| `JIRA_PERSONAL_TOKEN`, `CONFLUENCE_PERSONAL_TOKEN` | `mcp.json` (args) + `credentials.env` 중복 허용 |
| `SLACK_BOT_TOKEN`, `SENTRY_AUTH_TOKEN`, `WHATAP_API_TOKEN`, `BROWSERSTACK_ACCESS_KEY` | `mcp.json` |

## 참고 스크립트

- `bh-secrets list | get <KEY> | set <KEY> <VALUE> | verify`
- `bh-get-token-usage` — Cursor Analytics 사용자별 messages 랭킹
- `~/bh-agent-kit/scripts/cursor-usage` — 로컬 accessToken 활용 예시
