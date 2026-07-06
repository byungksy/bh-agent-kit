# GOTCHAS for bh-agent-kit-publish

- **두 개의 로컬 리포지토리 충돌 방지**: `/Users/a1101969/WebstormProjects/bh-agent-kit`와 `/Users/a1101969/bh-agent-kit` 두 디렉토리가 모두 존재하므로, 현재 수정 작업이 진행되고 변경 사항(dirty state)이 있는 디렉토리를 올바르게 선택해야 한다. 기본적으로 변경 사항이 있는 곳을 자동 추적하도록 작성한다.
- **inquiry-first 승인 없이 Push 금지**: Git push는 High 등급의 작업이므로, 사용자에게 명시적으로 승인(예: "진행")을 얻은 다음에만 push 명령을 날려야 한다.
