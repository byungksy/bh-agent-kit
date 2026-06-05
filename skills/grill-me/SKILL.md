---
name: grill-me
description: |
  구현·플랜·PR 스택 착수 전에 가정·누락·범위 오류를 역질문과 체크리스트로 검증한다.
  UI 기획 정합성(G1–G6) + 인프라·체이닝·lint gate 플랜(G7–G15).
  "grill-me", "플랜 검증", "구현 전 검증", stacked PR 착수 전 실행.

  Do NOT use for: 코드 구현 후 검증 (code-verify), 머지 후 회귀 (branch-stability)
---

# Grill-Me — 구현 전 설계·플랜·PR 스택 검증

추측으로 구현하면 AS-IS 오류, 기획 누락, **범위 과대/과소**, **로컬≠CI**, **체이닝 merge 순서** 실수가 남는다.
코드 작성·PR 생성 전에 아래 항목을 검증한다. PR 체이닝 표기는 `team-pr-chaining` 룰을 따른다.

## 모드 선택

| 플랜 유형 | 실행 섹션 |
|-----------|-----------|
| UI/화면 기획 반영 | **G1–G6** |
| 인프라·lint·schema·CI·hook·legacy fix | **G7–G15** |
| 둘 다 | 전부 |

불명확하면 AskQuestion 1회: 「기획 화면 변경 / 인프라·contract / 혼합?」

---

## Part A — 기획·UI 플랜 (G1–G6)

### G1. AS-IS 코드 정합성

플랜 AS-IS가 **실제 파일**에 있는지 grep/read로 확인. 없으면 추론 AS-IS → 재작성.

### G2. TO-BE 기획서 정합성

기획서 원문과 TO-BE **문구·줄 수** 일치. 요약·paraphrase 금지.

### G3. 기획서 항목 누락

기획 변경 항목 ↔ 플랜 Task 1:1. chip/badge/CSS/로그 필드 등 소항목 누락 자주 발생.

### G4. 불필요한 수정

기획에 없는 리팩터·구조 변경 → 범위 초과. 전제조건이면 플랜에 이유 명시.

### G5. 컨벤션 정합성

인접 파일 패턴(링크, CTA, 상수 위치, 로그 key)과 플랜 구현 방식 일치.

### G6. 잘못된 추론 패턴

- AS-IS가 기획 TO-BE와 동일하게 적힘
- 「추후 판단」만 있고 구현 방법 없음
- 기획 섹션 통째 누락

---

## Part B — 인프라·contract·PR 스택 (G7–G15)

인프라·PR 스택 작업에서 자주 틀린 항목. **코드/CI/plan/티켓을 read로 확인**한다.

### G7. PR 스택·체이닝 정의

- [ ] PR-A/B/C/D(또는 PR-1…) 표, **source → target**, merge 순서, PR # 기재 (`team-pr-chaining`)
- [ ] 각 PR **한 가지 목적** (infra / legacy / hook / docs — 한 PR에 섞지 않음)
- [ ] stacked PR의 `--changed --base` = **직계 target branch** (main 아님)

**실패 신호**: 「PR-B 시뮬레이션」인데 base가 main으로만 적혀 있음.

### G8. 로컬 검증 = CI SSOT

- [ ] CI step과 **동일 스크립트·동일 플래그** (`verify-context.py --changed` 등)
- [ ] ad-hoc `git diff | xargs` one-off **금지** — 스크립트 옵션으로 승격
- [ ] README는 **main merge 후 사용자** 관점만 (티켓별 stacked 예시·내부 PR 번호 금지)

### G9. 검증 범위 (전체 / 변경분 / staged)

| 명령 | 언제 |
|------|------|
| `--files` | 수정 파일, pre-commit |
| `--changed --base` | PR CI, push 전 |
| 인자 없음 | legacy 일괄 점검 |

includes fragment(`*-detail.md`)는 context.md 검증에서 제외되는지 plan·코드 일치.

### G10. WARN vs ERROR gate

- [ ] merge gate에 **ERROR만** 차단하는지 명시
- [ ] WARN→ERROR 승격(T5 등) **별 PR** + legacy 영향도 스캔 전제
- [ ] 「DoD ERROR」와 「Forbidden bullet ERROR」 혼동 없음

### G11. Scope deferral 기록

범위에서 빼는 Task(T5, T6–T8…)가 있으면:

- [ ] 티켓 **코멘트 + description/DoD** 갱신
- [ ] 대표 PR(**PR-A**) **코멘트**
- [ ] plan scope 조정 섹션

**실패 신호**: 「T5 안 할 거야?」가 채팅에만 있고 티켓/PR 미반영.

### G12. 티켓 AS-IS ≠ TO-BE 제거

티켓 **문제 설명**(수동 트리거, WARN…)을 **제거 목표**로 읽지 않았는지 확인.

예: 「수동 context-update」= AS-IS pain → **유지** + 자동 경로는 **범위外** 가능.

### G13. SSOT drift

- [ ] `templates/` → codegen → `schemas/` — schemas 수동 편집 금지
- [ ] verify 로직 hook/CI/plan **중복 구현** 없음 — 공통 verify 스크립트 호출만

### G14. 의존성·설치 부담

`requirements.txt`, `setup.sh`, hook install — **최초 1회** 경로가 README/plan에 있는지. 실패 시 친절한 exit 메시지.

### G15. 용어·한국어 설명

plan/답변에 **pain point, greenfield, deterministic, SSOT** 등 쓸 때 plan 용어表 또는 한 줄 풀이.

사용자 「무슨 말이야?」 → paraphrase 실패 신호 → grill-me 재실행.

---

## 역질문 (모호할 때 1문항씩)

코드/CI로 답 가능하면 탐색 먼저. 아니면 사용자에게 1개씩:

1. **Merge gate**: WARN도 막을까, ERROR만 막을까?
2. **Legacy**: main FAIL N건 — 이번 PR에서 전부 vs 변경분만 CI?
3. **Stacked base**: `--changed` base는 main vs 부모 feature?
4. **Defer**: T5/T6 — 이번 티켓 vs follow-up? (티켓/PR 기록 동의?)
5. **로컬 gate**: pre-commit만 vs pre-push까지?

각 질문에 **권장안 + 근거** 1줄 첨부.

---

## 출력 형식

```
━━━━ Grill-Me 결과 ━━━━

모드: {UI | Infra | Both}
통과: {N}건 | 문제: {M}건

{문제 목록 — G번호 + 설명 + 증거(파일/줄/명령)}

PR 스택 (해당 시):
| PR-A | … | source → target | merge # |

→ "플랜 수정해줘" — 문제 항목 기준 재작성
→ "무시하고 진행해" — 사용자 책임
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 적용 시점

- 사용자 「grill-me」「플랜 검증」「PR-A부터 진행」요청
- stacked PR 2개 이상 착수 **직전** (에이전트가 자동 권장 가능)
- scope/deferral 결정 직후 — G11 재검증

**자동 실행 금지** — 사용자 요청 또는 stacked PR 착수 제안 시.
