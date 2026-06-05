# bh-agent-kit

개인용 코딩 에이전트 룰 모음. Cursor / Claude / Codex 등에 `rules/` 내용을 복사하거나 `~/.agents` sync 파이프라인에 연결해 사용한다.

## 구조

| 경로 | 설명 |
|------|------|
| `rules/` | 에이전트에 주입할 룰 본문 (`.md`) |
| `rules-meta.json` | 룰별 `alwaysApply`·`description` (Cursor frontmatter 생성용) |
| `etc/sources/` | 각 룰의 출처·참고 링크·내부 통합 메모 |

## 설치 예시

```bash
# ~/.agents SSOT에 반영
cp rules/*.md ~/.agents/rules/
cp rules-meta.json ~/.agents/rules-meta.json   # 기존 meta와 merge 필요 시 수동 병합
bash ~/.agents/scripts/sync-to-agents.sh --full
```

`00-inquiry-first.md`는 파일명 순으로 Codex `AGENTS.md` 맨 위에 오도록 `00-` 접두어를 유지한다.

## 룰 목록

| 파일 | alwaysApply | 요약 |
|------|-------------|------|
| `00-inquiry-first.md` | true | 대전제 — 정렬 후 실행 (risk triage, blocking 질문) |
| `communication-style.md` | true | 답변 톤·간결성 |
| `team-pr-chaining.md` | true | Stacked PR 표기 (team/PR 호스팅 맥락) |
| `output-writing.md` | false (PR 작성 시 Read) | PR 디스크립션 — 기획/작업/리뷰기한(`-`), 목적 우선·짧은 문장 |

출처는 `etc/sources/` 참고.
