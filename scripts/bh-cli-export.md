# bh-cli-export

CLI 명령어의 출력 결과(ANSI escape sequence로 컬러나 서식이 들어간 텍스트)를 받아서 스타일이 보존된 HTML 파일 또는 이스케이프 시퀀스가 제거된 깨끗한 ASCII(Plain Text) 파일로 내보내는 스크립트입니다.

## 🛠 기술 스택
- **Shell**: Bash
- **HTML Converter**: `aha` (Ansi HTML Adapter)
- **Text Processing**: Perl (ANSI 이스케이프 시퀀스 스트리핑 용)

## 📋 Usage

### 1. HTML로 내보내기 (기본값)
터미널 컬러 스타일이 보존된 HTML 파일로 저장합니다. (시스템에 `aha` 유틸리티가 없다면 Homebrew를 통해 자동 설치를 안내 및 수행합니다.)
```bash
# git diff 결과를 컬러가 유지된 HTML 파일로 저장
git diff --color=always | ./bh-cli-export diff.html

# command 옵션 사용
./bh-cli-export --command "git diff --color=always" --format html --out diff.html
```

### 2. 깨끗한 Plain Text(ASCII)로 내보내기
ANSI 이스케이프 코드(색상 코드 등)를 모두 제거하고 텍스트만 깔끔하게 저장합니다.
```bash
# git diff 결과를 색상 코드 없이 깨끗한 텍스트로 저장
git diff --color=always | ./bh-cli-export diff.txt

# 확장자가 .txt 이면 자동으로 ascii 포맷으로 동작합니다.
```

### 3. ANSI 원본 텍스트로 내보내기
색상 코드 시퀀스를 지우지 않고 그대로 텍스트 파일에 담습니다.
```bash
git diff --color=always | ./bh-cli-export --format ansi diff.ansi
```

## ⚙️ 옵션 정보
- `-c, --command <cmd>`: 파이프라인 대신 실행할 명령어를 직접 기재하여 캡처합니다.
- `-f, --format <format>`: 변환 포맷을 강제 지정합니다. (`html`, `ascii`, `ansi` 지원)
- `-o, --out <file>`: 출력 파일 경로를 지정합니다. (포지셔널 인자로 그냥 파일명을 넘겨도 무방합니다.)
