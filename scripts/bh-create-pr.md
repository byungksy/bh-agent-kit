# bh-create-pr

코드 변경 사항(git diff)과 Jira 티켓 정보를 기반으로 AI 에이전트를 구동하거나, 대화 중인 에이전트(하이브리드 모드)가 작성한 내용을 주입받아 Bitbucket PR을 생성하는 CLI 도구입니다.

## 📋 개요

- **하이브리드 모드 지원**:
  - `--context`: Git diff/커밋/Jira 정보를 JSON으로 추출하여 호출 에이전트에게 제공
  - `-s`, `-d`, `-f`, stdin 파이프: 에이전트가 세션 맥락을 담아 작성한 PR 제목과 설명을 직접 전달받아 생성
  - 미입력 시 내장 AI 에이전트(`agy`)가 자율 분석하여 자동 작성
- **Bugfix / Hotfix 필수 섹션 검증**:
  - 버그 수정(`bugfix`, `hotfix`, `결함`, `Defect`) 작업 시 `이슈현상*`, `발생 원인*`, `해결방법*` 필수 작성 강제
  - 누락 시 경고 및 `--strict` 옵션으로 안전 차단 지원
- **Bitbucket Markdown 빈 줄 규칙 자동 정규화**:
  - 블록 요소(헤더, 리스트, 본문 단락) 사이에 `\n\n` 빈 줄을 자동 정규화하여 렌더링 깨짐 방지
- **원클릭 클립보드 복사 및 PR 생성**:
  - macOS 클립보드(`pbcopy`) 자동 복사
  - Bitbucket REST API를 통한 즉시 PR 생성 (`-c`)
  - 미푸시 브랜치 자동 감지 및 원격 푸시 연동

## 🛠 Usage

### 1. 기본 자동 생성 (내장 AI 구동)
```bash
bh-create-pr
```

### 2. 하이브리드 모드: 에이전트가 컨텍스트 조회 후 직접 주입
```bash
# 1) 컨텍스트 조회 (JSON)
bh-create-pr --context

# 2) 에이전트가 작성한 제목/설명으로 PR 생성
bh-create-pr -s "[COMPANY-12345] 주문서 할인율 계산 오류 수정" \
  -d "## 이슈현상*\n- 특정 조건에서 할인율이 0%로 적용됨\n\n## 발생 원인*\n- 분기 조건 누락\n\n## 해결방법*\n- 방어 로직 추가" -c
```

### 3. 마크다운 파일 또는 파이프 입력
```bash
# 파일 지정
bh-create-pr -s "[COMPANY-12345] 결함 수정" -f ./pr_description.md -c

# 파이프 전달
cat pr_body.md | bh-create-pr -s "[COMPANY-12345] 결함 수정" -c
```

### 4. 베이스 브랜치 및 티켓 지정
```bash
bh-create-pr -b main -t COMPANY-12345
```

### 5. 실제 PR 생성 없이 프리뷰만 확인 (Dry-Run)
```bash
bh-create-pr --dry-run
```

## ⚙️ 옵션 정보

- `-s, --title, --summary <TEXT>`: PR 제목 직접 지정
- `-d, --desc, --description <TEXT>`: PR 본문 직접 지정
- `-f, --file <PATH>`: PR 본문으로 사용할 파일 경로
- `--context`: Git/Jira 컨텍스트를 JSON으로 출력하고 종료 (에이전트 연동용)
- `-b, --base <BRANCH>`: 타겟 베이스 브랜치 (기본값: 원격 `origin/HEAD` 또는 `main` 자동 감지)
- `-t, --ticket <KEY>`: 연결할 Jira 티켓 키 (브랜치명/커밋에서 자동 감지)
- `--bugfix, --hotfix`: Bugfix 모드 강제 적용 (이슈현상/원인/해결방법 필수)
- `--feat, --feature`: Feature 모드 강제 적용 (기획내용/작업내용)
- `-c, --create`: Bitbucket API로 PR 즉시 생성
- `--draft`: PR 제목에 `[DRAFT]` 접두어 추가
- `-o, --open`: 생성 완료 후 브라우저에서 PR 열기
- `--dry-run`: 실제 생성 없이 에이전트 설명 생성 및 프리뷰만 수행
- `--strict`: Bugfix 모드 필수 섹션 누락 시 에러로 중단
- `--force`: 검증 경고를 무시하고 진행
- `-q, --quiet`: 진행 로그 출력 억제
- `-y, --yes`: 대화형 확인 프롬프트 건너뛰기
- `-h, --help`: 도움말 출력
