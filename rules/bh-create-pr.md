# bh-create-pr

Git 변경 사항(git diff)과 Jira 티켓 정보를 기반으로 Pull Request(PR) 설명을 작성하고 Bitbucket PR 생성을 요청받았을 때, 수동으로 작성하거나 임의의 PR 커맨드를 호출하는 대신 로컬 CLI 도구 `bh-create-pr`을 사용한다.

## When (Read on demand)

- 작업 브랜치에서 PR 생성을 준비하거나 PR 설명을 작성할 때
- Bitbucket에 Pull Request 생성을 요청받았을 때
- 버그 수정(Bugfix/Hotfix) 후 이슈 원인 및 해결 방법을 구조화된 PR 설명으로 작성해야 할 때
- 세션에서 진행한 작업 컨텍스트를 반영하여 고품질의 PR을 발행하고자 할 때

## 기본 정책 및 제약 (불변식)

| 항목 | 정책 | 비고 |
|------|------|------|
| **하이브리드 모드** | 에이전트 사전 컨텍스트 조회 및 주입 권장 | `--context`로 조회 후 `-s`, `-d`, `-c`로 실행 |
| **타겟 베이스 브랜치** | `origin/HEAD` 또는 `main` 최우선 감지 | 필요 시 `-b <BRANCH>`로 지정 |
| **Bugfix 필수 섹션** | `이슈현상*`, `발생 원인*`, `해결방법*` | 버그 수정 시 3개 항목 누락 불가 (자동 검증) |
| **Feature 필수 섹션** | `기획내용*`, `작업내용*`, `서비스 영향범위*` | 표준 기능 개발 템플릿 준수 |
| **Bitbucket Markdown** | 블록 요소 간 `\n\n` 빈 줄 준수 | CLI에서 자동 정규화 처리 |
| **클립보드 연동** | macOS `pbcopy` 자동 저장 | 터미널 프리뷰와 함께 복사 완료 |

## CLI 명령어 규격

도구 경로: `~/bin/bh-create-pr` (PATH 등록)

```bash
bh-create-pr [옵션]
  -s, --title <TEXT>          PR 제목 직접 지정
  -d, --desc <TEXT>           PR 본문 직접 지정
  -f, --file <PATH>           PR 본문 파일 경로
      --context               Git 및 Jira 컨텍스트를 JSON으로 출력하고 종료
  -b, --base <BRANCH>         타겟 베이스 브랜치 (기본값: main)
  -t, --ticket <KEY>          연결할 Jira 티켓 키 (브랜치/커밋에서 자동 감지)
      --bugfix, --hotfix      Bugfix 모드 강제 적용 (이슈현상/원인/해결방법 필수)
      --feat, --feature       Feature 모드 강제 적용
  -c, --create                Bitbucket PR 즉시 생성 (API)
      --draft                 PR 제목에 [DRAFT] 접두어 추가
      --dry-run               실제 PR 생성 없이 프리뷰만 수행
      --strict                Bugfix 필수 섹션 누락 시 에러 중단
  -y, --yes                   대화형 프롬프트 건너뛰기
```

## 에이전트 실행 지침 (하이브리드 워크플로우)

에이전트가 사용자의 PR 생성을 대행할 때는 **하이브리드 패턴**을 적용하여 세션의 깊이 있는 컨텍스트를 반영한다.

### 1단계: 컨텍스트 조회
```bash
bh-create-pr --context
```
- 반환된 JSON에서 `current_branch`, `base_branch`, `ticket_key`, `ticket_summary`, `is_bugfix`, `commits`, `diff_stat` 확인.

### 2단계: PR 설명 작성 및 검증
- 작업 성격에 맞추어 필수 섹션을 빠짐없이 작성한다:
  - **Bugfix / Hotfix인 경우**:
    ```markdown
    ## 이슈현상*
    - 재현 조건 및 발생한 이상 증상 구체적 서술

    ## 발생 원인*
    - 코드 diff와 티켓 내용을 바탕으로 기술적 근본 원인(Root Cause) 명시

    ## 해결방법*
    - 무엇을 어떻게 수정했고 왜 그렇게 조치했는지 의도 명시

    ## 변경 요약
    - 핵심 변경 파일/컴포넌트 불릿 리스트

    ## 서비스 영향범위*
    - 영향받는 화면 및 사용자 시나리오

    ## 리뷰기한
    - 영업일 기준 리뷰 마감 기한
    ```

### 3단계: PR 생성 실행
비대화형 플래그(`-c`, `-y` 등)와 함께 작성된 제목과 설명을 전달한다:
```bash
bh-create-pr -s "[COMPANY-12345] 버그 수정 요약" -d "$(cat << 'EOF'
## 이슈현상*
...
## 발생 원인*
...
## 해결방법*
...
EOF
)" -c -y
```

생성 완료 시 발급된 PR URL(`https://bitbucket.org/.../pull-requests/XXX`)을 사용자에게 보고한다.
