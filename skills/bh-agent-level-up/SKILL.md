---
name: bh-agent-level-up
description: |
  세션·교정·리뷰에서 나온 인사이트를 분류·스테이징한 뒤, 적절한 SSOT(primer 계약 / 스킬 harness / rule / TIL)로만 승격한다.
  "에이전트 룰로 승격", "이 대화에서 배운 걸 정리", "level-up", "primer에 계약으로" 요청 시 사용.

  트리거 키워드:
  - 명령어: /bh-agent-level-up, /agent-level-up
  - "에이전트 룰로 승격", "스킬로 만들어", "세션 기반으로 룰/스킬 개선"
  - "agents 룰 개선", "이 대화에서 배운 걸 룰로", "primer에 반영"

  Do NOT use for: audit 자동 개선 (self-improve), 스킬/룰 처음부터 제로 작성 (skill-creator, custom-rule-creator),
  agent-scripts 배포 PR (agent-skill-evolve), 앱 코드 작업, primer-update PR 자동 생성 (primer-update)
---

# bh-agent-level-up — 지식 승격 파이프라인 (v2)

**수동 트리거 전용.** audit·workflow가 자동 호출하지 않는다.

## 왜 v1이 실패했는가

| v1 패턴 | 문제 |
|---------|------|
| Harvest → 곧바로 rule/skill/hook 매핑 | 도메인 계약(S1/S2/S3)이 스킬 GOTCHAS로 복제됨 |
| "반복 질문 → alwaysApply rule" | 컨텍스트 비용만 늘리고 검색·적시 로딩 없음 |
| 승격 기준 없음 | 한 번짜리 팁·잘못된 추론이 영구 자산화 |
| primer 미분리 | 엔지니어링 SSOT와 에이전트 절차가 섞임 |

v2는 검증된 **Capture → Review → Promote**(ARIA, CMM), **Hot/Cold 분리**(Codified Context, Lore), **Progressive disclosure**(Anthropic, Claude-Mem)를 따른다.

---

## 지식 5유형 (분류 SSOT)

승격 전 **반드시** 각 항목을 한 유형에만 태깅한다.

| 유형 | 정의 | 승격 대상 | 예 (프로젝트 세션) |
|------|------|-----------|---------------|
| **K1 Domain contract** | Trigger / Observes / Contract / Anti / Placement | `~/primer/contexts/{repo}/context.md` › Engineering Contracts | S1 로딩+빈배열→스켈레톤, S3 완료+0→null |
| **K2 Procedure harness** | plan/review/debug 시 **어떤 primer 섹션을 읽을지** | 스킬 `references/*-harness.md` (도메인 문장 복사 금지) | git-pr-review › App Options 계약 참조 |
| **K3 Workflow rule** | 도구·브랜치·커밋·PR 등 **결정적** 제약 | `~/.agents/rules/{name}.md` (≤50줄, alwaysApply 신중) | PR 체이닝 명명 |
| **K4 Skill-local gotcha** | 해당 스킬만의 함정 (경로·MCP·workspace) | `skills/{name}/GOTCHAS.md` | JSON 파싱 → shell 폴백 |
| **K5 Ephemeral** | 일회성·미검증·개인 메모 | `bh-til` 또는 **승격 안 함** | "이번 PR만 GPG 우회" |

**금지**: K1 내용을 K2/K4에 장문 복사. K2는 primer **경로·섹션명·체크 질문**만.

---

## Phase 0 — Entry

1. 입력 범위 확인: 현재 대화 / transcript / 명시 파일.
2. 작업 레포·primer repo context 식별 (`primer` index, `context.md` frontmatter `domain:`).
3. 이미 K1~K4에 있는 내용과 **중복 여부** 스캔 (grep 키워드, 섹션 제목).
4. **Merge conflict 세션**이면 `git-merge-conflict` rule + `references/merge-conflict-harness.md`를 먼저 Read.
5. **2개 이상 대안** 비교·SSOT 배치 논의가 있으면 `decision-axis-comparison` 룰 + `references/decision-axis-comparison-harness.md` Read.

---

## Phase 1 — Capture (수확)

추출 대상만 수집 (아직 승격 판단 금지):

- 사용자 **교정** ("아니야", "S1이 맞아", "primer에 있어야 해")
- **확정 결정** (defer, SSOT 위치, naming)
- **리뷰/버그에서 드러난 계약** (로딩 vs empty-after-fetch)
- **절차 누락** (preview 없이 코멘트 발송 등)

Transcript: `~/.cursor/projects/{project}/agent-transcripts/{id}.jsonl` — 키워드 grep 후 주변만 read.

---

## Phase 2 — Classify (분류)

각 캡처 항목에 대해:

1. K1~K5 태그 **하나**
2. **Provenance**: 발화 인용 1줄 또는 파일:line
3. **Confidence**: `confirmed` | `inferred` — `inferred`는 Stage만, Promote 불가
4. **Reusability**: `cross-session` | `this-repo` | `this-skill` | `once`

`inferred` 또는 `once` → 기본 K5(TIL), 승격 제안에서 제외.

---

## Phase 3 — Stage (스테이징)

승격 후보를 **인덱스 테이블**로만 제시 (progressive disclosure Layer 1).

동일 인사이트에 K1~K5 **배치가 갈리거나** 승격 대상을 고를 때는 테이블 **앞에** `decision-axis-comparison-harness` 스펙트럼 블록을 **반드시** 포함한다.

```
━━━━ Level-Up 스테이징 (Layer 1) ━━━━

| id | 유형 | 한 줄 요약 | confidence | 대상 SSOT |
|----|------|------------|------------|-----------|
| L1 | K1 | App 옵션 S1/S3 계약 | confirmed | primer/mobile-app-repo |
| L2 | K2 | git-pr-review primer harness | confirmed | git-pr-review/references |
| L3 | K4 | MCP diff JSON 실패 | confirmed | git-pr-review/GOTCHAS |

상세 초안 보려면: "L1 상세" / "전체 상세" / "L1,L2만 승격"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

사용자가 id를 고르기 전까지 **파일 쓰기 금지**.

---

## Phase 4 — Propose (상세 + 게이트)

선택한 id만 Layer 2로 펼친다. 각 항목은 **승격 게이트**를 통과해야 한다.

### K1 (primer Engineering Contract) 게이트

- [ ] Trigger / Observes / Contract / Anti / Placement 5블록 채움
- [ ] 기존 `context.md` 상태머신 절과 **모순 없음**
- [ ] 스킬 본문에 동일 문장 **복사하지 않음** (경로 참조만)

템플릿: `~/primer/templates/repo-context.md` › Engineering Contracts

### K2 (skill harness) 게이트

- [ ] "When to load primer" + 섹션 앵커 + 체크리스트 3~7항
- [ ] 도메인 문장은 primer 링크, harness에는 **질문**만 ("S1 vs S3 구분했는가?")

### K3 (rule) 게이트

- [ ] 50줄 이하, alwaysApply 정당화 (매 세션 필요한가?)
- [ ] glob으로 좁힐 수 있으면 alwaysApply **사용 안 함**
- [ ] `rules-meta.json` 초안 포함

### K4 (GOTCHAS) 게이트

- [ ] 해당 스킬 실행 시에만 유효
- [ ] K1에 넣을 도메인 지식이 **아님**

### 공통

- [ ] `confirmed` + `cross-session` 또는 `this-repo`
- [ ] 중복·상충 기존 자산 없음

---

## Phase 5 — Promote (승인 후만 적용)

승인된 id만 최소 diff로 반영:

| 유형 | 경로 | 후속 |
|------|------|------|
| K1 | `~/primer/contexts/{repo}/context.md` | 사용자가 primer-update PR 원하면 `primer-update` 안내 |
| K2 | `~/.agents/skills/{skill}/references/*-harness.md` | SKILL.md에 "Before implement/review: read harness" 1줄 |
| K3 | `~/.agents/rules/{name}.md` + `rules-meta.json` | `sync-to-agents.sh --full` |
| K4 | `~/.agents/skills/{skill}/GOTCHAS.md` | — |
| K5 | `bh-til "..."` | 파일 승격 없음 |

```bash
bash ~/agent-scripts/rules/sync-to-agents.sh --full  # K3만
```

**금지**: 사용자 승인 없이 agents/primer 커밋·push, K1을 skill GOTCHAS에 장문 복사, 세션 무관 대규모 refactor.

---

## Phase 6 — Verify

- [ ] K1: Contract 블록이 테스트·리뷰 코멘트와 정합 (가능하면 파일:line 1개 인용)
- [ ] K2: harness만 읽어도 "무엇을 primer에서 읽을지" 명확
- [ ] K3: `~/.cursor/rules/{name}.mdc` 생성 (sync 후)
- [ ] 중복 grep으로 동일 계약 2곳 이상 없음

---

## self-improve / agent-skill-evolve 와 역할

| 도구 | 역할 |
|------|------|
| **self-improve** | audit `[CORRECTION_DETECTED]` → 패치 **제안** |
| **bh-agent-level-up** | 사용자 회고 → **분류·스테이징·SSOT 승격** |
| **agent-skill-evolve** | agent-scripts **배포 PR** |
| **primer-update** | 작업 레포 → primer **PR 생성** |

---

## 산출물 형식

```
[bh-agent-level-up-result]
staged: L1,K2 (K1 primer, K2 git-pr-review harness)
promoted:
  - ~/primer/contexts/mobile-app-repo/context.md (Engineering Contracts › App UI Options)
  - ~/.agents/skills/git-pr-review/references/primer-harness.md (new)
skipped: L3 (K5 → bh-til only)
sync: ok | n/a
next: primer-update PR / agent-scripts commit (미요청)
[/bh-agent-level-up-result]
```

---

## 참고 (외부 패턴)

- **ARIA / CMM**: capture → human promote
- **Codified Context / Lore**: hot rule vs cold spec, task-scoped retrieval
- **Anthropic context engineering**: progressive disclosure, smallest high-signal set
- **adr-kit / MADR**: 아키텍처 **결정**은 ADR; **동작 계약**은 primer K1

## GOTCHAS

`references/GOTCHAS.md` 또는 동일 디렉터리 `GOTCHAS.md` 참고.
