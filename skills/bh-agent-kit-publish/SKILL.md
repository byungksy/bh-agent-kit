---
name: bh-agent-kit-publish
description: |
  bh-agent-kit 저장소의 에이전트 규칙/스킬 변경 사항을 로컬에 동기화하고 커밋 및 원격 GitHub 저장소에 푸시합니다.
  
  트리거 키워드:
  - 명령어: /bh-agent-kit-publish, /bh-publish
  - 자연어: "bh-agent-kit에 반영해줘", "규칙 푸시해줘", "에이전트 킷 배포해줘", "bh-agent-kit 커밋 푸시"
  
  Do NOT use for: 일반 프로젝트 코드 반영 (company-commit/push 사용), 일반 동기화만 필요한 경우 (company-sync 사용)
---

# bh-agent-kit Publish

`bh-agent-kit` 저장소에 있는 에이전트 설정(rules, skills 등)의 변경 사항을 로컬 환경에 동기화하고 GitHub 원격 저장소에 커밋 및 푸시합니다.

## 명령어

| 명령어 | 설명 |
|--------|------|
| `/bh-agent-kit-publish` | 변경 사항 자동 감지, 로컬 동기화 및 커밋/푸시 실행 |
| `/bh-publish` | `/bh-agent-kit-publish`와 동일 |

## 워크플로우

### 1. bh-agent-kit 저장소 경로 탐색 및 이동
다음 경로 중 유효한 `bh-agent-kit` Git 저장소를 탐색하여 이동합니다.
- `/Users/a1101969/WebstormProjects/bh-agent-kit` (기본 권장)
- `/Users/a1101969/bh-agent-kit`

### 2. 변경 사항 감지 (Status & Diff Check)
- `git status`를 실행하여 수정된 파일(rules, etc)을 파악합니다.
- 변경 사항이 없다면 "변경 사항이 없습니다."라고 사용자에게 보고하고 종료합니다.

### 3. 로컬 동기화 스크립트 실행 (선택)
- 동기화 스크립트 `sync-to-agents.sh` 또는 관련 도구가 프로젝트 내에 정의되어 있다면 로컬에 즉시 동기화 반영을 먼저 실행합니다.
  ```bash
  # 예: ~/.agents/scripts/sync-to-agents.sh --full 또는 로컬 스크립트 실행
  ```

### 4. 커밋 메시지 생성 및 사용자 승인 게이트 (High Triage)
- 변경된 파일 목록과 diff를 분석하여 의미 있는 커밋 메시지를 생성합니다.
  - 예: `[NO-TICKET] inquiry-first §2.1 one-line gate 업데이트`
- **inquiry-first §4 (Trust boundary) 규칙에 따라, 원격 푸시(Publish/send) 전에 반드시 사용자에게 변경 내역과 커밋 메시지를 보여주고 명시적인 승인("진행", "yes" 등)을 받습니다.**

### 5. Git Commit & Push 실행
사용자의 승인을 받은 후 아래 명령을 차례대로 수행합니다:
```bash
git add .
git commit -m "<생성된 커밋 메시지>"
git push origin <현재 브랜치명>
```

### 6. 결과 보고
작업 완료 후 커밋 해시와 푸시된 원격 브랜치 정보를 요약하여 출력합니다.
```text
[bh-agent-kit-publish-result]
branch: <브랜치명>
commit: <커밋 메시지>
status: push 완료
[/bh-agent-kit-publish-result]
```
