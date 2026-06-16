# Session Handoff — 다음 액션 체크리스트

구현·디버깅·배포 세션을 **마무리하는 응답** 또는 사용자가 **「다음에 뭐 해?」** 를 물을 때, 아래를 **사실 조회 후** 빠짐없이 적는다. 「PR 검토하세요」 한 줄로 끝내지 않는다.

## 필수 점검 (git status·branch -vv로 확인)

| # | 항목 | 적을 내용 |
|---|------|-----------|
| 1 | **로컬 잔여** | uncommitted / untracked(커밋 대상 vs 무시) |
| 2 | **커밋·미 push** | 브랜치명, `ahead N`, upstream 유무 |
| 3 | **원격 PR** | PR 없음 / 초안 URL / 리뷰·머지 대기 |
| 4 | **배포·CI** | pipeline 실행 필요·관찰 스텝·custom pipeline 이름 |
| 5 | **서버·런타임** | SSH healthcheck·로그 grep·재기동 여부 |
| 6 | **브라우저** | Bitbucket/GitHub pipeline·PR diff·Sentry·Slack 등 **열 URL** |
| 7 | **로컬 스크립트** | `./scripts/healthcheck.sh`, build, test 등 **실행 명령** |
| 8 | **다음 질문 템플릿** | 이어갈 때 사용자가 붙여넣을 **한 줄 앵커** (`@파일`, 브랜치, 로그 한 줄) |

## 응답 형식

```markdown
## 다음 액션

### 지금 (순서)
1. …

### 로컬
- …

### 원격 / PR
- …

### 배포·검증
- …

### 브라우저
- …

### 다음에 나에게 이렇게 물어봐
> …
```

## 규칙

- **추측 금지** — push 여부·PR 유무는 `git`·원격 호스팅 API로 확인한 뒤만 쓴다.
- **한 가지만** 강조할 때도 나머지 항목이 **해당 없음**이면 `없음`으로 명시한다.
- level-up·TIL 승격 요청 시 → `bh-agent-level-up` + `bh-til` 안내를 #8에 포함한다.

## Related

- `bh-agent-level-up` › `references/session-handoff-harness.md`
