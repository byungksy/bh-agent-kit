# Ghostty Configuration

맥 기반의 고성능 GPU 가속 터미널 에뮬레이터인 **Ghostty**의 개인 테마, 폰트 및 탭 디자인 커스텀 설정입니다.

## 🛠 기술 스택
- **규격**: Ghostty Configuration Syntax (v1)

## 📋 세부 설정 정보
- **Theme**: `Rose Pine Dawn` (차분하고 가독성이 뛰어난 파스텔 톤의 라이트 테마)
- **Font**: 
  - 영문: `JetBrains Mono` (가독성이 뛰어난 개발용 폰트)
  - 한글 보완: `D2Coding` (D2Coding 폰트가 백업 폰트로 자동 바인딩되어 한글 깨짐 방지)
- **UI/Window Style**: `macos-titlebar-style = tabs` (상단 타이틀바를 탭 형태로 일체화하여 넓은 터미널 작업 영역 확보)

## ⚙️ 적용 방법
이 설정 파일을 복사하여 본인의 macOS Ghostty 설정 경로에 덮어씌웁니다.

```bash
# 1. 디렉토리 생성
mkdir -p ~/Library/Application\ Support/com.mitchellh.ghostty

# 2. 설정 파일 복사
cp etc/ghostty/config ~/Library/Application\ Support/com.mitchellh.ghostty/config
```
또는 `~/.config/ghostty/config` 경로에 복사하여 사용하실 수도 있습니다.
