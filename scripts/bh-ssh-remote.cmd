@echo off
setlocal enabledelayedexpansion

rem 1. plink.exe가 환경변수(PATH)에 있는지 확인
where plink >nul 2>nul
if %errorlevel% equ 0 (
    set SSH_CMD=plink
    set USE_GUI=0
    goto :found
)

rem 2. plink.exe가 기본 Program Files 폴더에 있는지 확인
if exist "%ProgramFiles%\PuTTY\plink.exe" (
    set SSH_CMD="%ProgramFiles%\PuTTY\plink.exe"
    set USE_GUI=0
    goto :found
)
if exist "%ProgramFiles(x86)%\PuTTY\plink.exe" (
    set SSH_CMD="%ProgramFiles(x86)%\PuTTY\plink.exe"
    set USE_GUI=0
    goto :found
)

rem 3. putty.exe가 환경변수(PATH)에 있는지 확인
where putty >nul 2>nul
if %errorlevel% equ 0 (
    set SSH_CMD=putty
    set USE_GUI=1
    goto :found
)

rem 4. putty.exe가 기본 Program Files 폴더에 있는지 확인
if exist "%ProgramFiles%\PuTTY\putty.exe" (
    set SSH_CMD="%ProgramFiles%\PuTTY\putty.exe"
    set USE_GUI=1
    goto :found
)
if exist "%ProgramFiles(x86)%\PuTTY\putty.exe" (
    set SSH_CMD="%ProgramFiles(x86)%\PuTTY\putty.exe"
    set USE_GUI=1
    goto :found
)

rem 5. 스크립트와 같은 폴더(C:\bin)에 복사된 putty.exe가 있는지 확인
if exist "%~dp0putty.exe" (
    set SSH_CMD="%~dp0putty.exe"
    set USE_GUI=1
    goto :found
)

echo [ERROR] PuTTY or Plink executable not found.
echo Please make sure PuTTY is installed.
exit /b 1

:found
rem 2. 인자(세션 이름 등)가 넘어온 경우 바로 접속
if not "%~1"=="" (
    echo Connecting to: %~1
    if "!USE_GUI!"=="1" (
        start "" %SSH_CMD% -load "%~1"
    ) else (
        %SSH_CMD% -load "%~1"
    )
    exit /b %ERRORLEVEL%
)

rem 3. 레지스트리에서 PuTTY 세션 조회 및 목록화
echo =======================================
echo         PuTTY Saved Sessions
echo =======================================
set "count=0"
for /f "tokens=6 delims=\" %%i in ('reg query HKCU\Software\SimonTatham\PuTTY\Sessions 2^>nul') do (
    set /a count+=1
    set "session[!count!]=%%i"
    echo [!count!] %%i
)

if %count% equ 0 (
    echo [INFO] No PuTTY sessions found in registry.
    set /p "TARGET=Enter host to connect (e.g. user@host): "
    if not "!TARGET!"=="" (
        if "!USE_GUI!"=="1" (
            start "" %SSH_CMD% !TARGET!
        ) else (
            %SSH_CMD% !TARGET!
        )
    )
    exit /b 0
)
echo =======================================

rem 4. 사용자 선택 받기
set /p "choice=Select a number or enter session/host [Cancel]: "
if "%choice%"=="" exit /b 0

rem 숫자인지 문자(호스트)인지 판별
set "is_num=1"
for /f "delims=0123456789" %%a in ("%choice%") do set "is_num=0"

if "!is_num!"=="1" (
    if defined session[%choice%] (
        set "TARGET=!session[%choice%]!"
    ) else (
        set "TARGET=%choice%"
    )
) else (
    set "TARGET=%choice%"
)

rem 5. 실행
echo Connecting to !TARGET!...
if "!USE_GUI!"=="1" (
    start "" %SSH_CMD% -load "!TARGET!"
) else (
    %SSH_CMD% -load "!TARGET!"
)
exit /b %ERRORLEVEL%
