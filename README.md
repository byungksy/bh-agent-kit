# bh-agent-kit

개인용 코딩 에이전트 **룰·스킬** 모음. Cursor / Claude / Codex 등에 복사하거나 `~/.agents` sync 파이프라인에 연결해 사용한다.

## 구조

| 경로 | 설명 |
|------|------|
| `rules/` | 에이전트에 주입할 룰 본문 (`.md`) |
| `rules-meta.json` | 룰별 `alwaysApply`·`description` (Cursor frontmatter 생성용) |
| `skills/` | 온디맨드 스킬 (`*/SKILL.md`) |
| `hooks/` | Cursor 훅 스크립트 (`*.sh`). `~/.cursor/hooks/`로 복사 후 `~/.cursor/hooks.json`에 등록 |
| `etc/sources/` | 각 룰·스킬의 출처·참고 링크·내부 통합 메모 |

## 설치 예시

```bash
# ~/.agents SSOT에 반영
cp rules/*.md ~/.agents/rules/
cp rules-meta.json ~/.agents/rules-meta.json   # 기존 meta와 merge 필요 시 수동 병합
cp -R skills/* ~/.agents/skills/             # 스킬 추가·갱신
bash ~/.agents/scripts/sync-to-agents.sh --full
```

`00-inquiry-first.md`는 파일명 순으로 Codex `AGENTS.md` 맨 위에 오도록 `00-` 접두어를 유지한다.

## 룰 목록

| 파일 | alwaysApply | 요약 |
|------|-------------|------|
| `00-inquiry-first.md` | true | 대전제 — 정렬 후 실행 (risk triage, blocking 질문, 응답 footer) |
| `communication-style.md` | true | 답변 톤·간결성 |
| `team-pr-chaining.md` | true | Stacked PR 표기 (team/PR 호스팅 맥락) |
| `output-writing.md` | false (PR 작성 시 Read) | PR 디스크립션 — 기획/작업/리뷰기한(`-`), 목적 우선·짧은 문장 |
| `bh-token-lookup.md` | false (토큰 필요 시 Read) | 인증 토큰 탐색 순서 SSOT — Cursor accessToken vs Analytics API Key, credentials.env / mcp.json / Keychain 순회 |

## 스킬 목록

| 경로 | 요약 |
|------|------|
| `skills/grill-me/` | 구현·플랜·PR 스택 착수 전 G1–G15 검증 (grill-me, 플랜 검증) |

## 훅 목록

| 파일 | 이벤트 | 요약 |
|------|--------|------|
| `hooks/show-turn-model.sh` | `afterAgentResponse` | auto 모드 turn별 사용 모델을 stderr(Cursor Hooks 채널) + `~/.cursor/turn-models.jsonl`에 기록 |

### 훅 설치

```bash
cp hooks/*.sh ~/.cursor/hooks/
chmod +x ~/.cursor/hooks/*.sh
```

이후 `~/.cursor/hooks.json`의 해당 이벤트 배열에 항목 추가:

```json
"afterAgentResponse": [
  { "command": "~/.cursor/hooks/show-turn-model.sh", "timeout": 3 }
]
```

출처는 `etc/sources/` 참고.
