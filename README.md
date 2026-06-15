# bh-agent-kit

개인용 코딩 에이전트 **룰·스킬** 모음. Cursor / Claude / Codex 등에 복사하거나 `~/.agents` sync 파이프라인에 연결해 사용한다.

## 구조

| 경로 | 설명 |
|------|------|
| `rules/` | 에이전트에 주입할 룰 본문 (`.md`) |
| `rules-meta.json` | 룰별 `alwaysApply`·`description` (Cursor frontmatter 생성용) |
| `skills/` | 온디맨드 스킬 (`*/SKILL.md`) |
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

## 스킬 목록

| 경로 | 요약 |
|------|------|
| `skills/grill-me/` | 구현·플랜·PR 스택 착수 전 G1–G15 검증 (grill-me, 플랜 검증) |

출처는 `etc/sources/` 참고.
