---
name: bh-archetype
description: |
  Cursor agent-transcripts 세션 기록을 훑어서 사용자를 Boris(Claude Code) 5 아키타입(Prototyper / Builder / Sweeper / Grower / Maintainer)에 매핑한다.
  진지한 커리어 진단이 아니라 **가십성 자가진단**용. 점심시간에 돌려보고 동료랑 노는 용도.

  트리거 키워드:
  - 명령어: /bh-archetype
  - 한국어: "5 아키타입", "5가지 아키타입", "나는 어떤 아키타입", "Prototyper Builder Sweeper Grower Maintainer", "5 archetypes", "Boris 아키타입", "클로드코드 아키타입"
  - 영어: "which archetype am i", "five archetypes", "boris archetype"

  Do NOT use for: 진지한 커리어 진단, 인사 평가, 채용 가이드, 팀 빌딩 공식 진단. 출력은 어디까지나 가십 수준이다.
---

# bh-archetype — 5 아키타입 가십성 자가진단

미래의 직무 시장을 훔쳐보는 것 같다, Claude Code 창시자 Boris가 제시한 5개 아키타입(Prototyper / Builder / Sweeper / Grower / Maintainer)에 **나는 어디에 속하나**를 agent-transcripts 기반으로 가볍게 매핑한다.

**MUST**: 결과는 가십 톤으로 낸다. 단정·평가·"~해야 한다"식 처방 금지. "근거 인용 + 시기별 무게중심 + 한 줄 결론"만.

출처: <https://www.linkedin.com/posts/jaeyunhenrylee_미래의-직업-시장을-훔쳐보는-것-같다-클로드코드-창시자-boris가-activity-7477159999040028672-mYj1>

---

## 5 아키타입 (원문 그대로)

| # | Archetype | 정의 |
|---|-----------|------|
| 1 | **Prototyper** | comes up with brand new ideas; churns out many ideas, most of which don't ship |
| 2 | **Builder** | quickly turns a prototype/idea into production-grade product/infra |
| 3 | **Sweeper** | cleans up the UI, simplifies the code and system, unships, optimizes performance |
| 4 | **Grower** | takes a product that has been built and iterates on it to improve Product-Market Fit |
| 5 | **Maintainer** | owns a mature system to make it secure, reliable, fast, and efficient as it scales |

Boris 부연: 한 사람이 2~3 아키타입에 걸쳐 있는 게 흔하다. 직무 함수(엔지니어/PM/디자이너/DS)와 무관하다.

---

## 워크플로우

### Step 1: 분석 범위 확정

**MUST** AskQuestion으로 1회 묻는다 (옵션 — `defaults` 응답이면 권장값으로 진행):

```
분석 범위?
- [기본] 최근 2주치 세션 (Recommended)
- 최근 1달치 세션
- 최근 3개월 세션 (시기별 변화까지)
```

권장 분모: **최소 2주, 가능하면 한 달.** 일주일 이하는 표본이 부족해 가십 정확도도 떨어진다.

### Step 2: agent-transcripts 수집

```bash
TRANSCRIPTS_DIR=$(find ~/.cursor/projects -name "agent-transcripts" -type d 2>/dev/null | head -1)
ls -lt "$TRANSCRIPTS_DIR" | head -50
```

각 세션 디렉토리의 `*.jsonl`에서 user 메시지만 추출:

```bash
jq -r 'select(.role=="user") | .message | if type == "string" then . else (.content[]?|select(.type=="text")|.text) end' "$JSONL" 2>/dev/null \
  | grep -v "^<system" | grep -v "manually attached"
```

**MUST** 세션당 첫 3~5줄만 보지 말 것. 표면 진단이 된다. 세션이 큰 경우(>200줄) 전체 발화 흐름을 훑어야 한다.

### Step 3: 아키타입 시그널 매핑

| 시그널 | 매핑 |
|---|---|
| 새 아이디어·실험·POC 발화, "이거 한번 만들어볼까", 여러 방향성 동시 탐색 | **1 Prototyper** |
| `bh-*` 스크립트화, 셸 유틸, 인프라 세팅, 컨텍스트 시스템, "production으로 굳히자" | **2 Builder** |
| minify·최적화, 미사용 룰/스킬/플러그인 식별, 표준화·SSOT, "이거 정리하자", unship | **3 Sweeper** |
| 도입 현황 정리·확대, 채택 가이드, 라이브 메트릭 분석, 이해관계자 설득, A/B 효과 검증 | **4 Grower** |
| 모니터링 쿼리, conflict resolve, 버저닝, 운영 안정성, 릴리즈 흐름 | **5 Maintainer** |

**MUST** 시기별로 무게중심이 바뀔 수 있다. 시기별 표를 함께 낼 것.

### Step 4: 출력 포맷

```markdown
## 결론

**시기별 무게중심: {1차} + {2차} + {깔림}.** {1 Prototyper 또는 명백히 약한 것}은 거의 0.

## 한눈에 비교

```
새 아이디어 ◄────────────────────────────────────► 운영 안정

   1 Prototyper    2 Builder    3 Sweeper    4 Grower    5 Maintainer

   {기간A 중심}:        ▲▲▲          ▲             ▲
   {기간B 중심}:         ▲           ▲            ▲▲▲
```

## 시기별 패턴

| 시기 | 1차 아키타입 | 대표 작업 |
|---|---|---|
| {YYYY-MM-DD ~ YYYY-MM-DD} | **{N Archetype}** | {실제 세션에서 본 작업 3~5개} |
| ... | ... | ... |

## 핵심 시그널 (실제 발화 인용)

**{N Archetype}**
- "{인용 1}" — {짧은 해설}
- "{인용 2}" — {짧은 해설}
```

**MUST** 실제 발화를 큰따옴표로 인용한다. 일반론·추측만으로 결론 내지 말 것.

### Step 5: 톤 가드

- "당신은 X다"식 단정 금지. "{1차} + {2차}로 보인다" 정도.
- 처방 금지. "그러므로 ~하세요" 금지.
- 결과 끝에 "가십 수준 진단입니다 — 진지하게 받지 마세요" 한 줄 첨부.

---

## 안티 패턴

| 안티 | 왜 안 되는지 |
|---|---|
| 각 세션 첫 3~5줄만 보고 결정 | 표면 진단 → 사용자가 "2주치는 봐야지" 류 반박을 부른다 |
| 1개 아키타입으로 단정 | Boris 원문이 "2~3 spans"라고 명시 |
| 시기별 변화 무시 | 5월 Builder가 6월 Grower로 옮겨가는 흐름을 놓친다 |
| 진지한 평가·처방 | 가십 톤 위반 |
| 분기·역할 미상 발화도 강제 매핑 | "이전 대화 잔향", "지금 모델 뭐야?" 같은 메타·잡담은 매핑에서 제외 |
