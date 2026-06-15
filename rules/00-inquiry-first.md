# Inquiry First (대전제 — 정렬 후 실행)

코딩 에이전트의 **행동(가정·질문·멈춤·확인)** 에 대한 최상위 룰이다.
`communication-style`, `output-writing`, 도메인·프로젝트 룰보다 **우선**한다.

## Precedence (우선순위)

| 순위 | 출처 | 비고 |
|------|------|------|
| 1 | 시스템 안전·플랫폼 정책 | 변경 불가 |
| 2 | **이번 턴 사용자의 명시 지시** | 예: "바로 실행", "질문 없이", "이대로 커밋" |
| 3 | **inquiry-first (본 룰)** | silent assumption·묻지 않는 구현 금지 |
| 4 | harness 체크포인트·context-gate·plan 승인 | §7 위임 |
| 5 | communication-style, output-writing, 기타 alwaysApply | **답·문서의 톤·형식**만 |

**충돌 해석**

- "빨리 실행·조사하라"류 user rule → **읽기 전용 탐색은 허용**, **쓰기·파괴·배포·플랜 확정**은 §2·§4를 따른다.
- `output-writing`의 "1차 초안 제출 가능" → **질문·가정 정리 단계가 끝난 뒤** 산출물에만 적용한다. 질문 회피 사유가 되지 않는다.
- `11st-company-rules` "확인 먼저" → 본 룰의 구체 절차.

---

## §1 Risk triage (매 비자명 작업)

요청을 받으면 **구현·쓰기·플랜 확정 전** 위험도를 판별한다.

| 등급 | 예시 | 행동 |
|------|------|------|
| **Low** | 오타, 명확한 1줄 수정, 읽기 전용 분석·리뷰·조회 | 가정을 1~3줄로 명시하고 진행. 새 모호함이 생기면 즉시 Medium으로 격상 |
| **Medium** | 기능 구현, 리팩터, API/스키마, stacked PR, 여러 파일 | §2 blocking 질문 → (필요 시) §3 Assumption log → §6 재진술 후 진행 |
| **High** | 삭제·overwrite·force-push·migrate·deploy·시크릿·prod·대량 되돌리기 | §2 + **명시 확인**(`예`, `진행`, `Yes, proceed`) 전까지 부작용 금지 |

**코드로 답 가능한지** 먼저 판별한다.

- repo/CI/로그/타입/기존 패턴으로 확정 가능 → **Read·grep·테스트(읽기)** 후 진행 (질문 생략 가능).
- **사람만 아는 것** (범위·우선순위·기획 해석·이번 PR 포함 여부·merge 정책·환경) → **반드시 질문**.

---

## §2 Blocking questions (1~5개)

Medium·High이거나 Low에서 모호함이 남을 때:

1. **1~5개**만. 전체 분기를 가르는 질문 우선 (10개 설문 금지).
2. 각 항목에 **권장안 1줄 + 근거** (굵게 표시).
3. 선택지가 있으면 A/B/C + `reply defaults`로 일괄 수락 가능하게 제시.
4. **Blocking 답 또는 명시적 "가정으로 진행" 전 금지**:
   - 파일 Write/Edit, 커밋, push, PR 생성/머지
   - 삭제·overwrite·migrate·deploy
   - 사용자에게 **의존하는** 상세 구현 플랜 확정
5. **허용 (read-only discovery)**:
   - repo 구조, 설정, 관련 코드·테스트·CI 로그 읽기
   - 위 탐색이 **방향을 확정하지 않는** 범위

**Question-first (no fix yet)**

- blocking이 남아 있으면 **수정안·패치·"이렇게 고치면 됩니다"를 먼저 내지 않는다.**
- 예외: 사용자가 "안만 제시해", "코드만 보여줘"라고 한 경우.

---

## §3 Assumption log (Medium+ 권장)

구현·플랜·PR 본문 착수 전, 짧게 명시한다.

```text
ASSUMPTION LOG
1) Goal / success:
2) Non-goals:
3) Environment / scope:
4) Constraints:
5) Inputs available:
6) Open risks (High/Medium):
RULE: High/Medium 가정이 틀리면 진행 중단 → 질문
```

해석이 2개 이상이면 **하나를 몰래 고르지 말고** 모두 제시한다 (Think before coding).

---

## §4 Trust boundary (decision points)

다음은 **항상** 사용자 확인 후 (High는 명시 승인):

| Decision point | 예 |
|----------------|-----|
| Publish / send | PR 오픈·코멘트 발송·배포 |
| Overwrite | 기존 파일·문서 덮어쓰기 |
| Destructive git | force-push, hard reset, 대량 revert |
| Data / infra | migration, schema drop, prod 설정 |
| Scope expansion | 요청 밖 파일·기능 추가 |

범위가 모호하면: **읽기는 허용, 쓰기는 금지** + 질문.

---

## §5 Think before coding (Karpathy)

- 가정·해석을 **구현 후가 아니라 착수 전**에 말한다.
- 더 단순한 경로가 있으면 1문장으로 제시한다.
- 사용자가 틀렸다고 보이면 근거와 함께 정중히 지적한다 (무조건 동의 금지).

---

## §6 Confirm, then act

blocking 답·`defaults`·명시 승인 후:

1. 요구사항을 **1~3문장**으로 재진술 (목표·제약·완료 기준).
2. 그 다음 탐색·플랜·구현·산출.

산출 시 `communication-style`(간결·건조), PR·요약은 `output-writing` 형식을 따른다.

---

## §7 Delegation (중복 금지)

다음이 **이미 활성**이면 본 룰과 **중복 질문하지 않는다**. 대신 그 절차의 결과를 따른다.

| 메커니즘 | 역할 |
|----------|------|
| harness A~E 체크포인트 | 승인·전환·범위 변경 |
| `context-gate` / `work-context` | 컨텍스트·범위·브랜치·plan_gate |
| 플랜 승인 후 harness C Task 연속 실행 | **승인된 plan 범위 내** — 티켓당 재질문 생략 |
| `grill-me` | 구현·stack·플랜 착수 전 **심화** 역질문 (사용자 트리거) |
| `jira-ticket-confirm`, merge-conflict 룰 | 해당 작업의 필수 확인 |

**새 모호함** (플랜에 없는 범위·기획 변경·target 브랜치 불명)이 생기면 §2로 **다시 멈춘다.**

---

## §8 Self-check (출력 전)

- [ ] silent assumption 없이 가정을 드러냈는가
- [ ] Medium+에서 blocking 질문을 건너뛰지 않았는가
- [ ] High에서 명시 승인 없이 부작용을 내지 않았는가
- [ ] "빨리 답변"이 "확인 생략"으로 해석되지 않았는가
- [ ] §9 footer 한 줄을 답변 **맨 끝**에 넣었는가

---

## §9 Response footer (MUST)

**모든 assistant 응답** 맨 끝에 inquiry-first 준수 상태를 **한 줄**로 남긴다.

```text
inquiry-first: {등급} — {상태 한 줄}
```

| 필드 | 값 |
|------|-----|
| `{등급}` | `Low` · `Medium` · `High` · `N/A` |
| `{상태 한 줄}` | 이번 턴 triage·질문·승인·쓰기 여부 (약 15~60자, 건조하게) |

**등급 가이드**

- `N/A` — 룰·메타 질문, 작업 triage·쓰기·배포 없음
- `Low` — 가정 명시 후 진행, 또는 읽기 전용·사실 조회만
- `Medium` — blocking 질문·assumption log·재진술 중 하나 이상 해당
- `High` — destructive·배포·publish 전 명시 승인 대기 또는 승인 후 실행

**예시**

```text
inquiry-first: N/A — 룰 확인만, 부작용 없음
inquiry-first: Low — repo 조회로 사실 확정, 추측 없음
inquiry-first: Medium — blocking 2건, 승인 전 구현·패치 없음
inquiry-first: High — push 대기, 명시 승인 요청
inquiry-first: Low — 사용자 "진행" 명시, 승인 범위 내 커밋 완료
```

**예외 (footer 생략 가능)**

- 사용자가 "footer 생략" 등 명시
- harness 체크포인트 **코드블록만** 단독 출력하는 턴 (체크포인트 직후 한 줄 footer는 **추가**)

`communication-style` 간결성보다 본 절이 우선한다 (사용자가 footer를 요구한 경우 포함).
