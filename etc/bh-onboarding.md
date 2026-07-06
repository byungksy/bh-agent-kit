# 🛠 BH Dev Onboarding

> 매일 `bh-daily-onboarding` 으로 복습. 편집은 `bh-daily-onboarding edit`

---

## ~/bin 유틸 모음

| 명령어 | 설명 | 사용 예 |
|--------|------|---------|
| `bh-today-tickets` | 오늘 Cursor 세션에서 언급된 Jira 티켓 조회 | `bh-today-tickets` / `bh-today-tickets 2026-05-21` |
| `bh-port-kill` | 특정 포트 점유 프로세스 kill | `bh-port-kill 3000` |
| `bh-git-cleanup` | merged 브랜치 일괄 삭제 | `bh-git-cleanup` |
| `bh-git-recent` | 최근 브랜치 fzf 선택 → 체크아웃 | `bh-git-recent` |
| `bh-git-clone` | git clone 자동화 | `bh-git-clone <url>` |
| `bh-git-merge` | merge 자동화 | `bh-git-merge` |
| `bh-env-diff` | .env vs .env.example 누락 키 비교 | `bh-env-diff` |
| `bh-proj` | fzf로 프로젝트 디렉토리 이동 | `bh-proj` |
| `bh-til` | TIL 한 줄 메모 누적 (`~/.til.md`) | `bh-til "배운 것"` |
| `bh-json-diff` | 두 JSON 파일 의미 기반 diff | `bh-json-diff a.json b.json` |
| `bh-deploy-with-bp` | 배포 파이프라인 | `bh-deploy-with-bp` |
| `bh-cursor-sessions-today.sh` | 오늘 Cursor 세션 조회 | `bh-cursor-sessions-today.sh` |
| `bh-daily-onboarding` | 이 문서 열기 | `bh-daily-onboarding` / `bh-daily-onboarding edit` |
---

## 🖥 개발 환경 및 필수 도구 (SSOT)

> 💡 전체 GUI 애플리케이션 및 CLI 도구 가이드라인 단일 정본은 [mac-setup.md](file:///Users/a1101969/bh-agent-kit/etc/mac-setup.md)를 참조하십시오.

### 필수 GUI 도구
* **Ghostty** & **cmux**: GPU 가속 터미널 및 AI 에이전트 병렬 모니터링 터미널.
* **Karabiner-Elements** & **Hammerspoon**: 키 매핑 및 macOS 창 관리 자동화.

### CLI 도구

### bat — cat 업그레이드
```bash
cat package.json        # 문법 강조 + 라인 넘버 + git diff 표시
# alias cat="bat --paging=never" 로 투명하게 대체됨
```

### zoxide — cd 업그레이드
```bash
cd pdp                  # 이력 기반으로 pdp-front-mobile-base로 점프
cd slack                # slack-cursor-bot으로 점프
cdi                     # fzf 인터랙티브 모드 — 이력 전체 검색
cd ..                   # 기존 cd 그대로 동작
# 처음엔 방문 이력이 없어서 조금 써야 학습됨
```

### zsh-autosuggestions
```bash
# 이전에 쳤던 명령어를 흐릿하게 미리보기
# → 키로 수락
```

### fzf — 퍼지 파인더
```bash
# bh-git-recent, bh-proj, cdi 등 내부적으로 사용
# Ctrl+R: 히스토리 퍼지 검색
```


---

## dotfiles 개념

- `~/.zshrc`, `~/.gitconfig` 등 `.`으로 시작하는 설정 파일들 = **dotfiles**
- `~/dotfiles/` git repo로 관리 → GitHub에 올려두면 새 맥에서 1분 복원
- **GNU Stow** 로 심링크 관리

```bash
# dotfiles 레포 세팅
mkdir ~/dotfiles && cd ~/dotfiles
git init
cp ~/.zshrc .
brew install stow
stow --target=$HOME .          # 심링크 생성
gh repo create dotfiles --public && git push -u origin main

# 새 맥에서 복원
git clone https://github.com/{username}/dotfiles ~/dotfiles
cd ~/dotfiles && stow --target=$HOME .
```

---

## TIL 활용

```bash
bh-til "오늘 배운 것"      # 인자로 바로 입력
bh-til                     # 대화형 입력
cat ~/.til.md              # 전체 보기
```

---

## 참고 링크

- [the-book-of-secret-knowledge](https://github.com/trimstray/the-book-of-secret-knowledge) — CLI 꿀팁 대백과 ★222k
- [obra/superpowers](https://github.com/obra/superpowers) — AI에게 줄 shell 슈퍼파워 ★201k
- [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles) — dotfiles 교과서 ★31k
- [explainshell.com](https://explainshell.com) — 복잡한 shell 명령어 해설
