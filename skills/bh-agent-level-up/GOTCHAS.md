# bh-agent-level-up GOTCHAS

## 파이프라인

- **Stage 전 파일 쓰기 금지** — Layer 1 인덱스 → 사용자 선택 → Layer 2 상세 → 승인 → Promote.
- `inferred` 항목은 TIL만; primer/rule 승격 불가.
- 한 캡처 항목에 K1+K4 **동시 승격** 시 K1에 본문, K4에는 "primer §ATF Options 참조" 한 줄만.

## SSOT

| 콘텐츠 | 쓸 곳 | 쓰지 말 곳 |
|--------|--------|------------|
| S1/S2/S3, API 상태 계약 | primer K1 | skill GOTCHAS, alwaysApply rule |
| PR URL·workspace·MCP 폴백 | K4 skill-local | primer |
| 커밋/브랜치/티켓 형식 | K3 rule (짧게) | primer |
| 다음 액션 8항 체크리스트 | K3 `session-handoff` | skill 본문 장문 |

## agents

- Rule SSOT: `bh-agent-kit/rules/` → `~/.agents/rules/` 복사 후 sync.
- **자동 트리거 없음** — `bh-til-idle-check`는 `/bh-agent-level-up` **제안만**.

## 실패 모드 (v1에서 온 교훈)

- "세션에서 배운 모든 것 → grill-me 15항 추가" → **거부**. K1/K2로 쪼개고 harness는 질문만.
- K1~K5·도구 비교를 bullet만으로 제시 → **거부**. 스펙트럼·표 필수.
- 「다음 액션」에 PR 한 줄만 → **거부**. `session-handoff` 8항(로컬·push·PR·배포·브라우저·스크립트·질문 앵커).
