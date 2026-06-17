# bh-agent-kit

개인용 코딩 에이전트 **룰·스킬** 모음. Cursor / Claude / Codex 등에 복사하거나 `~/.agents` sync 파이프라인에 연결해 사용한다.

## 구조

| 경로 | 설명 |
|------|------|
| `rules/` | 에이전트에 주입할 룰 본문 (`.md`) |
| `rules-meta.json` | 룰별 `alwaysApply`·`description` (Cursor frontmatter 생성용) |
| `skills/` | 온디맨드 스킬 (`*/SKILL.md`) |
| `scripts/` | 로컬 `~/bin` 및 `~/.agents/scripts`에서 사용되는 개인용 유틸리티 쉘 스크립트 모음 |
| `etc/sources/` | 각 룰·스킬의 출처·참고 링크·내부 통합 메모 |

## 설치 예시

```bash
# ~/.agents SSOT에 반영
cp rules/*.md ~/.agents/rules/
cp rules-meta.json ~/.agents/rules-meta.json   # 기존 meta와 merge 필요 시 수동 병합
cp -R skills/* ~/.agents/skills/             # 스킬 추가·갱신
cp scripts/* ~/.agents/scripts/               # 스크립트 추가·갱신
bash ~/.agents/scripts/sync-to-agents.sh --full
```

`00-inquiry-first.md`는 파일명 순으로 Codex `AGENTS.md` 맨 위에 오도록 `00-` 접두어를 유지한다.

## 룰 목록

| 파일 | alwaysApply | 요약 |
|------|-------------|------|
| `00-inquiry-first.md` | true | 대전제 — 정렬 후 실행 (risk triage, blocking 질문) |
| `communication-style.md` | true | 답변 톤·간결성 |
| `team-pr-chaining.md` | true | Stacked PR 표기 (team/PR 호스팅 맥락) |
| `output-writing.md` | false (PR 작성 시 Read) | PR 디스크립션 — 기획/작업/리뷰기한(`-`), 목적 우선·짧은 문장 |
| `session-handoff.md` | true | 작업 마무리·다음 액션 8항 (로컬·push·PR·배포·브라우저·스크립트·질문 앵커) |

## 스킬 목록

| 경로 | 요약 |
|------|------|
| `skills/grill-me/` | 구현·플랜·PR 스택 착수 전 G1–G15 검증 (grill-me, 플랜 검증) |
| `skills/bh-agent-level-up/` | 세션 인사이트 분류·스테이징·SSOT 승격 (primer/rule/TIL) |

## 스크립트 목록 (`scripts/`)

로컬 개발 및 AI 에이전트 연동을 위한 개인용 쉘 스크립트 도구들입니다.

### 1. 에이전트 & 세션 도구
* **`bh-cursor-sessions-today.sh`**: fzf 기반의 대화형 Cursor 세션 뷰어. 좌우 방향키로 날짜 이동 및 에이전트 재개(`--resume`) 기능을 제공합니다.
* **`bh-agy-session`**: CLI 에이전트 세션 관련 유틸리티.
* **`bh-agent-sync`**: 로컬 에이전트 룰과 스킬을 각 프로젝트 및 전역 설정과 동기화합니다.
* **`bh-til-idle-check`**: 유휴 시간을 감지하여 그날 배운 지식을 회고(TIL)하도록 유도하고 스크립트를 연결합니다.
* **`bh-token-usage`**: Claude 및 GPT 토큰 사용량을 분석하고 시각화합니다.

### 2. Git & 프로젝트 관리
* **`bh-git-cleanup`**: 사용하지 않거나 병합이 완료된 로컬 브랜치를 일괄 정리합니다.
* **`bh-git-clone`**: 디렉토리 구조 표준에 맞춰 간소화된 git clone을 수행합니다.
* **`bh-git-merge`**: fzf 기반으로 병합 대상 브랜치를 선택하여 머지 작업을 돕습니다.
* **`bh-git-recent`**: 최근 작업했던 브랜치 목록을 조회하고 빠르게 checkout합니다.
* **`bh-proj`**: 자주 방문하는 프로젝트 디렉토리 경로로 편리하게 바로 가기를 제공합니다.
* **`bh-today-tickets`**: Jira API와 연동하여 오늘 할당된 작업 티켓 목록을 조회합니다.

### 3. Sentry & 로그 모니터링
* **`bh-sentry-events-by-feature-id`**: 피처(Feature) ID를 기준으로 Sentry 이벤트를 상세 쿼리합니다.
* **`bh-sentry-events-by-user`**: 사용자 정보를 기준으로 발생한 Sentry 이벤트를 추적합니다.
* **`bh-sentry-events-groupby`**: 특정 기준으로 Sentry 이벤트를 그룹화하여 통계를 냅니다.
* **`bh-sentry-events-lib.sh`**: Sentry API 조회를 담당하는 공통 쉘 라이브러리입니다.

### 4. 배포 & 인프라 도구
* **`bh-deploy-with-bp`**: CLI 상에서 Bitbucket Pipeline 배포를 대화형으로 트리거합니다.
* **`bh-ssh-remote`**: fzf로 등록된 원격 서버를 선택해 SSH 세션을 열어줍니다.
* **`bh-secrets`**: 로컬 및 에이전트 실행에 필요한 API 토큰과 비밀번호 등의 시크릿 키들을 안전하게 로드하고 관리합니다.

### 5. TIL & 문서 헬퍼
* **`bh-til-log`**: 오늘 하루 배운 점이나 작업을 간편하게 CLI에서 로깅합니다.
* **`bh-til-view`**: 로깅된 TIL 히스토리를 요약해 보여주는 뷰어입니다.
* **`bh-view-md`**: 터미널 환경에서 마크다운(`.md`) 파일을 가독성 좋게 출력합니다.

### 6. 시스템 유틸리티
* **`bh-port-kill`**: 특정 포트를 점유 중인 프로세스를 포트 번호 기반으로 편리하게 강제 종료합니다.
* **`bh-json-diff`**: 두 JSON 파일 간의 구조 및 값 차이점을 가독성 높게 비교합니다.
* **`bh-env-diff`**: 로컬 환경 변수 차이를 대조합니다.
* **`bh-morning`**: 아침에 출근하여 오늘의 일정, 브리핑, 작업 목록을 세팅해 줍니다.
* **`bh-daily-onboarding`**: 신규 프로젝트 온보딩 시 템플릿과 체크 사항을 확인해 줍니다.
* **`bh-gui`**: CLI 명령어 실행을 GUI로 래핑하여 실행합니다.

출처는 `etc/sources/` 참고.
