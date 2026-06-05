# PR 체이닝 표기 (Stacked PR)

한 티켓을 여러 PR로 나눠 순차 merge할 때, **에이전트·사용자·Jira·PR 코멘트**에서 같은 이름으로 부른다.

## 표기 통일

| 허용 | 금지 (혼용) |
|------|-------------|
| **PR-A**, **PR-B**, **PR-C**, **PR-D** | A PR, 1번 PR, 첫 PR, stacked #2 (맥락 없이) |
| **PR-1**, **PR-2**, **PR-3**, **PR-4** | PR-A와 PR-1을 같은 체인에서 섞기 |

**한 티켓·한 대화에서 한 계열만 선택**한다. 기본은 **PR-A/B/C/D**(알파벳).

숫자 계열(PR-1…)을 쓸 때도 동일 규칙: PR-1=첫 merge, 순서 증가.

## 체인 소개 시 필수 (표 1회)

| 라벨 | PR # | source → target | 목적 | merge 순서 |
|------|------|-----------------|------|------------|
| PR-A | #135 | `feature/…-schema` → `main` | contract infra | 1 |
| PR-B | #136 | `feature/…-legacy-fix` → PR-A | legacy fix | 2 |
| PR-C | #138 | `feature/…-local-hook` → PR-B | pre-commit gate | 3 |

- **target**이 `main`이 아니면 stacked PR임을 명시한다.
- PR 번호를 모르면 `TBD` — 라벨·브랜치·순서는 비운 채 두지 않는다.

## 에이전트 응답 규칙

- 사용자가 「PR-B」「PR-C」를 쓰면 **같은 라벨**로 답한다. 임의로 「두 번째 PR」만 쓰지 않는다.
- merge 순서 안내: `PR-A → PR-B → PR-C → main` 형식.
- scope/deferral(T5 follow-up 등) 기록 시 **Jira + PR 코멘트 + plan** 셋 중 빠진 곳을 사용자에게 알린다.

## PR 제목 패턴 (team·인프라 계열)

```
{TICKET} | {에픽 한 줄} | {순번}) {이 PR 역할}
```

예: `TEAM-146 | context.md 정적 검사 보완 | 3) pre-commit hook — verify-context 로컬 gate`

순번은 PR-A=1), PR-B=2) … 와 맞춘다.
