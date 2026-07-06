# 💻 작업 PC 소프트웨어 구성 요소 및 가이드 (SSOT)

이 문서는 작업 PC 개발 환경 구성에 필요한 필수 소프트웨어(GUI 및 CLI) 목록과 관련 설정에 대한 단일 정본(Single Source of Truth, SSOT)입니다.

---

## 🖥 1. 필수 GUI 애플리케이션 (GUI Applications)

| 애플리케이션 | 용도 및 특징 | 설정 및 가이드 링크 |
|:---|:---|:---|
| **Ghostty** | GPU 가속 기반 초고속 모던 터미널 에뮬레이터. | [Ghostty 설정 파일](file:///Users/a1101969/bh-agent-kit/etc/ghostty/config)<br>[Ghostty 가이드](file:///Users/a1101969/bh-agent-kit/etc/ghostty/README.md) |
| **cmux** | Ghostty 엔진 기반의 AI 에이전트 전용 오케스트레이션 터미널.<br>Claude Code, Aider 등의 병렬 기동 및 모니터링 최적화. | macOS 단독 앱 형태로 설치 후 사용. |
| **Karabiner-Elements** | 강력한 키보드 키 매핑 커스텀 도구. | 키보드 레이아웃 세팅 시 필수 사용. |
| **Hammerspoon** | macOS 데스크톱 창 관리 및 스크립트 기반 자동화 도구. | `~/.hammerspoon/init.lua` 스크립트로 동작 제어. |
| **Cursor / VS Code** | AI 에이전트 기반 코딩 및 일반 텍스트 편집용 메인 IDE. | [개발 환경 설정 가이드](file:///Users/a1101969/setup-guide.md) 참고 |
| **WebStorm** | JetBrains 사의 프론트엔드 전문 IDE. | 복잡한 프론트엔드 리팩토링 및 검증에 활용. |

---

## 🛠 2. 필수 CLI 도구 (CLI Utilities)

| 도구명 | 용도 | 설치 명령어 | 사용 팁 |
|:---|:---|:---|:---|
| **tmux** | 터미널 세션 유지 및 창 분할 멀티플렉서. | `brew install tmux` | `asciinema`를 통한 중간 녹화 결합에 필수적. |
| **asciinema** | 터미널 작업 내역을 텍스트 기반으로 레코딩하는 도구. | `brew install asciinema` | `asciinema rec -c "tmux attach -t <session>"`으로 중간 녹화. |
| **zoxide** | 터미널 이력 기반 스마트 디렉토리 이동 (`cd` 대체). | `brew install zoxide` | `cd pdp` 등으로 약칭 이동. `cdi`로 fzf 모드 진입. |
| **bat** | 구문 강조(Syntax Highlighting) 및 git diff를 지원하는 `cat` 대체. | `brew install bat` | `alias cat="bat --paging=never"` 설정을 권장. |
| **fzf** | 강력한 명령줄 퍼지 검색(Fuzzy Finder) 필터. | `brew install fzf` | `Ctrl+R`로 터미널 명령어 이력 검색 시 활용. |
| **uv / uvx** | Rust 기반의 초고속 Python 패키지 매니저 및 임시 실행기. | `brew install uv` | `uvx <package>`로 임시 환경에서 CLI 도구 기동. |

---

## ⚙️ 3. 커스텀 스크립트 (`~/bin` 유틸 모음)

로컬 `~/bin`에 위치하며, [BH Dev Onboarding](file:///Users/a1101969/.bh-onboarding.md)을 통해 정기 학습 및 단축 기동을 관리합니다.

* `bh-daily-onboarding`: 온보딩 복습 문서 조회 및 편집 (`bh-daily-onboarding edit`)
* `bh-today-tickets`: 오늘 세션에서 언급된 Jira 티켓 조회
* `bh-port-kill`: 포트 점유 프로세스 종료 (`bh-port-kill 3000`)
* `bh-git-cleanup`: 머지된 브랜치 일괄 삭제
* `bh-git-recent`: 최근 브랜치 fzf 선택 후 체크아웃
* `bh-til`: TIL 한 줄 메모 누적 (`~/.til.md`)
