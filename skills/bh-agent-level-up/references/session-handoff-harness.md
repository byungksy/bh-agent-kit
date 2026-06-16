# Session Handoff Harness

**When**: 디버깅·배포·PR 세션 종료, 사용자 「다음 액션」 질문, `/bh-agent-level-up` 직전.

**Rule SSOT**: `rules/session-handoff.md` (체크리스트 8항). 본 harness는 **에이전트 절차**만.

## Before answering

1. `git status -sb` · `git branch -vv` · `git log main..HEAD --oneline` (해당 시)
2. 작업 레포에 CI yaml 변경 있으면 → deploy 스텝·custom pipeline 이름 확인
3. 서버 이슈 세션이면 → healthcheck·로그 파일 경로가 열린 상태인지 대화에서 확인

## Capture → Level-up 매핑

| 세션 유형 | K1 후보 | K4/K5 |
|-----------|---------|-------|
| 런타임 오진 (로그 메시지 ≠ 원인) | primer Engineering Contract | K5 til |
| CI/배포 구조 결정 | primer 또는 pipeline 룰 | — |
| 「다음 액션 빈약」 사용자 교정 | K3 `session-handoff` 보강 | K5 til |

## Anti

- 「PR 검토하세요」만 제시
- push 필요 여부 미확인
- 브라우저·서버 검증 생략

## Checklist (3)

- [ ] 8항 중 **해당 없음**도 명시했는가?
- [ ] 다음 질문 **앵커 한 줄**을 줬는가?
- [ ] 인사이트 확정 시 `bh-til`·level-up 스테이징을 안내했는가?
