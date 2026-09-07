# bh-ticket-maker

Jira(Server/DC)에 이슈 티켓을 대화형 또는 CLI 옵션으로 손쉽게 생성하는 도구입니다.

## 📋 개요

- **프로젝트 기본값**: `COMPANY` (필요 시 지정 프로젝트 키 입력)
- **이슈 유형 기본값**: `결함` (프로젝트에 따라 `Defect`, `버그` 등으로 자동 매핑)
- **담당자 기본값**: 기본 담당자 (사번/계정 기준 자동 할당, 미지정 지원)
- **이슈 설명**: 다중 행(multi-line) 입력 및 외부 에디터(`$EDITOR`) 지원
- **날짜 필드**: 시작일 / 종료일 미지원 (전송 제외)

## 🛠 Usage

### 1. 대화형 모드 (엔터로 기본값 선택)
```bash
bh-ticket-maker
```

### 2. 제목과 설명 지정 실행
```bash
bh-ticket-maker -s "주문서 쿠폰 적용 시 할인율 계산 오류" -d "상세 재현 경로:\n1. 장바구니 담기\n2. 쿠폰 선택"
```

### 3. 특정 프로젝트 및 작업(Task) 생성
```bash
bh-ticket-maker -p COMPANY -t "작업" -s "프론트엔드 빌드 최적화"
```

### 4. 파일 내용 전달 및 확인 프롬프트 건너뛰기(-y)
```bash
bh-ticket-maker -s "결제 오류 수정" -f ./issue_details.md -y
```

### 5. 실제 생성 없이 요청 페이로드 확인 (Dry-Run)
```bash
bh-ticket-maker -s "테스트 제목" --dry-run
```

## ⚙️ 옵션 정보

- `-s, --summary <TEXT>`: 이슈 제목 (요약, 필수)
- `-d, --desc <TEXT>`: 이슈 설명 (여러 줄은 `\n` 사용 가능)
- `-f, --file <PATH>`: 설명으로 사용할 파일 경로
- `-p, --project <KEY>`: Jira 프로젝트 키 (기본값: `COMPANY`)
- `-t, --type <NAME>`: 이슈 유형 (기본값: `결함`)
- `-a, --assignee <USER/ID>`: 담당자 이름 또는 사번
- `--no-assignee`: 담당자 미지정(Unassigned)
- `-y, --yes`: 생성 전 확인 프롬프트 건너뛰기
- `-o, --open`: 생성 완료 후 브라우저에서 티켓 열기
- `--dry-run`: 실제 생성 없이 요청 페이로드만 확인
- `-h, --help`: 도움말 출력
