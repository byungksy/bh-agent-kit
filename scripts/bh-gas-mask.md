# bh-gas-mask

macOS 호스트 파일 관리 앱인 **Gas Mask**의 로컬 백업 프로필들을 `fzf` 인터페이스를 통해 터미널에서 대화형으로 간편하게 스위칭하고 적용하는 스크립트입니다.

## 🛠 기술 스택
- **Shell**: Bash
- **Terminal UI**: `fzf` (Fuzzy Finder)
- **macOS Integration**: Custom URL Scheme (`open -g hammerspoon://`), System Network Cache Control (`dscacheutil`, `killall`)

## 📋 Usage
```bash
# 터미널에서 실행 후 대화형 창을 통해 전환할 프로필 선택
./bh-gas-mask
```

## ⚙️ 사전 요구사항
- `fzf`가 시스템에 설치되어 있어야 합니다. (`brew install fzf`)
- Gas Mask 앱이 설치되어 있어야 하며, 로컬 프로필들이 `~/Library/Gas Mask/Local/*.hst`에 백업 저장되어 있는 구조여야 합니다.
- `/etc/hosts` 파일을 덮어쓰기 위해 실행 시 관리자 패스워드(`sudo`) 입력이 필요합니다.
