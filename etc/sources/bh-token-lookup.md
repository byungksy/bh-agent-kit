# bh-token-lookup 출처 및 배경

## 배경
* 개인 도구 및 에이전트마다 서로 다른 위치(`credentials.env`, `mcp.json`, `.env.secret`, `state.vscdb`)에 토큰을 분산 저장하면서 발생하던 탐색 비용 및 인증 실패 문제를 해결하기 위함.
* `~/.secret/tokens.json` 단일 통합 Key-Value JSON 저장소를 최우선 SSOT로 정의하여 일관된 접근 및 보안 권한(`0700`/`0600`)을 보장.

## 핵심 참고 파일
* 규칙 정의: `rules/bh-token-lookup.md`
* 샘플 템플릿: `etc/secret-tokens.example.json`
