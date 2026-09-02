# bh-token-lookup

개인 도구 및 AI 에이전트가 인증 토큰/시크릿을 찾을 때, 아래 순서 외의 위치는 새로 만들지 않는다. 헤매지 않기 위한 통합 SSOT 룰.

## When (Read on demand)

- 새 `bh-*` 스크립트 또는 봇/도구에 API 호출을 붙일 때
- 기존 스크립트/봇이 "토큰 없음" / 401·403으로 실패했을 때
- Cursor 사용량·랭킹·analytics 조회 요청
- Harbor, Bitbucket, Jira, Slack, Sentry 등 사내/외부 서비스 토큰 참조 시

---

## 🔒 개인 시크릿 통합 관리 (`~/.secret/tokens.json`)

개인의 모든 API 키와 인증 토큰은 **`~/.secret/tokens.json` (단일 통합 Key-Value JSON)**을 최우선 SSOT로 관리한다.

### 파일 및 디렉터리 권한 (MUST)
```bash
mkdir -p ~/.secret && chmod 700 ~/.secret
chmod 600 ~/.secret/tokens.json
```

### 토큰 조회 방법 (에이전트 / 스크립트)

* **Bash / Shell (`jq` 사용)**:
  ```bash
  TOKEN=$(jq -r '.KEY_NAME // empty' ~/.secret/tokens.json 2>/dev/null)
  ```
* **Python**:
  ```python
  import json
  from pathlib import Path

  def get_secret(key: str, default: str = "") -> str:
      secret_file = Path.home() / ".secret" / "tokens.json"
      if not secret_file.exists():
          return default
      try:
          data = json.loads(secret_file.read_text(encoding="utf-8"))
          return data.get(key, default)
      except Exception:
          return default
  ```

---

## 🔑 Cursor 토큰 구분 (호환되지 않음)

| 용도 | 종류 | 위치 |
|------|------|------|
| 개인 사용량 (`api2.cursor.sh/auth/usage`, `cursor.com/api/usage-summary`) | 로컬 Access Token | `~/Library/Application Support/Cursor/User/globalStorage/state.vscdb` — SQLite `SELECT value FROM ItemTable WHERE key = 'cursorAuth/accessToken'` |
| 팀·Enterprise Analytics (`api.cursor.com/analytics/...`) | Dashboard 발급 API Key | `~/.secret/tokens.json` (`CURSOR_API_KEY`) 또는 env `CURSOR_API_KEY` |

두 값을 서로 대체해 쓰지 않는다. 요청 API에 맞는 걸 골라야 한다.

---

## 전역 탐색 순서 (모든 서비스 공통)

1. **환경변수** (`CURSOR_API_KEY`, `BITBUCKET_BEARER_TOKEN`, `HARBOR_DEV_ROBOT_NAME`, …)
2. **`~/.secret/tokens.json`** — 개인 시크릿 통합 SSOT (JSON Key-Value)
3. **`~/.cursor/mcp.json`** — MCP 토큰 SSOT (`bh-secrets` 관리)
4. **서비스별 특수 위치** (Cursor local: SQLite `state.vscdb` / git: credential helper 등)
5. **macOS Keychain** (`security find-generic-password -w -s <service>`)

---

## 🛡️ 보안 규칙 (MUST & MUST NOT)

- **MUST**: 위 탐색 순서대로 조회하고 첫 번째로 유효한 값을 사용한다.
- **MUST**: 신규 키는 `~/.secret/tokens.json`에 추가하여 단일 관리한다 (임의의 새 파일/경로 생성 금지).
- **MUST**: 로컬 파일 생성 시 `chmod 700 ~/.secret`, `chmod 600 ~/.secret/tokens.json` 적용.
- **MUST NOT (절대 금지)**: **실제 토큰/비밀번호/시크릿 값을 코드, 리포지토리(git commit/push), PR, 로그, 에러 메시지에 노출하지 않는다.**
- **MUST NOT**: 리포지토리에는 오직 더미/플레이스홀더가 포함된 템플릿 샘플 파일(`etc/secret-tokens.example.json`)만 커밋/푸시를 허용한다.

---

## 알려진 매핑 테이블

| 키 이름 | 주요 용도 | 권장 SSOT 위치 |
|---|---|---|
| `HARBOR_DEV_ROBOT_NAME` | 사내 개발 Harbor 레지스트리 로봇 계정 ID | `~/.secret/tokens.json` |
| `HARBOR_DEV_ROBOT_SECRET` | 사내 개발 Harbor 레지스트리 로봇 계정 Secret | `~/.secret/tokens.json` |
| `BITBUCKET_EMAIL`, `BITBUCKET_APP_PASSWORD` | Bitbucket Cloud API Basic Auth | `~/.secret/tokens.json` / `mcp.json` |
| `JIRA_API_TOKEN`, `CONFLUENCE_PERSONAL_TOKEN` | Atlassian Jira / Confluence API | `~/.secret/tokens.json` / `mcp.json` |
| `SLACK_BOT_TOKEN`, `SLACK_APP_TOKEN` | Slack Bot & Socket Mode 연결 | `~/.secret/tokens.json` / `mcp.json` |
| `SENTRY_AUTH_TOKEN` | Sentry 이슈 조회 / API | `~/.secret/tokens.json` / `mcp.json` |
| `NEXUS_PASSWORD` | 사내 Nexus 레포지토리 패스워드 | `~/.secret/tokens.json` |
| `CURSOR_API_KEY` | Cursor Enterprise / Dashboard Analytics API | `~/.secret/tokens.json` |
| Cursor Access Token | Cursor 로컬 개인 사용량 조회 | `state.vscdb` (SQLite) |

---

## 템플릿 샘플 파일

* 샘플 템플릿 경로: [`etc/secret-tokens.example.json`](../etc/secret-tokens.example.json)
