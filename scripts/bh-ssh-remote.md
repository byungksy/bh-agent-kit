# bh-ssh-remote

Windows 환경에서 PuTTY 레지스트리 세션 정보를 읽어와 원격 서버 접속을 편리하게 연결하는 CMD 헬퍼 스크립트입니다. 보안 정책이 강력하게 적용된 윈도우 원격지 서버에서도 문제없이 동작할 수 있도록 순수 배치 파일(Batch File)로 작성되었습니다.

## 🛠 기술 스택
- **Shell**: Windows Batch Script (CMD)
- **Integration**: Windows Registry (`HKCU\Software\SimonTatham\PuTTY\Sessions`), PuTTY/Plink
- **Bypass**: PowerShell 스크립트(ExecutionPolicy) 보안 차단 우회

## 📋 Usage
```cmd
# 1. 인터랙티브 세션 선택 (목록 자동 조회 및 입력 대기)
bh-ssh-remote

# 2. 특정 세션 이름으로 다이렉트 접속
bh-ssh-remote <session_name>

# 3. 직접 호스트 주소 입력하여 접속
bh-ssh-remote user@10.x.x.x
```

## ⚙️ 사전 요구사항 & 설치 방법
1. 원격지 Windows 서버에 커스텀 실행 폴더(예: `C:\bin`)를 생성하고 시스템 환경 변수 `PATH`에 등록합니다.
2. `bh-ssh-remote.cmd` 파일을 `C:\bin` 폴더에 복사합니다.
3. 원격지 서버에 설치된 `putty.exe` (또는 `plink.exe`) 실행 파일 본체를 `C:\bin` 폴더로 복사합니다.
   - 만약 바로가기(`.lnk`)만 찾을 수 있는 경우, 동봉된 `putty-copy-helper.ps1` 스크립트를 실행하여 바로가기가 가리키는 실제 파일을 자동으로 추출하여 복사할 수 있습니다.
   ```powershell
   # putty-copy-helper.ps1 실행
   powershell -NoProfile -ExecutionPolicy Bypass -File .\putty-copy-helper.ps1
   ```
