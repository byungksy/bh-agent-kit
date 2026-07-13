# Kiro CLI 포팅 가이드

bh-agent-kit의 rules·skills·hooks를 [Kiro CLI](https://kiro.dev) 에이전트에 연동하는 방법.

## 디렉토리 매핑

| 역할 | Cursor/Gemini | Kiro CLI |
|------|--------------|----------|
| 항상 적용 룰 | `.cursor/rules/*.mdc` / `.gemini/config/rules/*.md` | `~/.kiro/steering/*.md` |
| 온디맨드 스킬 | `.gemini/config/skills/*/SKILL.md` | `~/.kiro/skills/*/SKILL.md` |
| 에이전트 훅 | `.cursor/hooks.json` / Claude Code `hooks` 블록 | `~/.kiro/agents/<name>.json` → `hooks` 필드 |
| 에이전트 설정 | `.cursorrules` / `AGENTS.md` | `~/.kiro/agents/<name>.json` |

## 1. Rules → Steering

`~/.kiro/steering/` 에 `.md` 파일을 두면 kiro 기본 에이전트가 자동으로 로드한다.
원본을 복사하지 않고 심볼릭 링크로 연결하면 SSOT가 유지된다.

```bash
mkdir -p ~/.kiro/steering

# bh-agent-kit rules 전체 링크
for f in ~/bh-agent-kit/rules/*.md; do
  ln -sf "$f" ~/.kiro/steering/$(basename "$f")
done
```

### Frontmatter 규칙

| 값 | 동작 |
|----|------|
| frontmatter 없음 | 항상 로드 (always) |
| `inclusion: always` | 항상 로드 |
| `inclusion: manual` | `/context add`로 수동 추가할 때만 로드 |
| `inclusion: fileMatch` | 특정 파일 패턴 매칭 시 로드 |

> `alwaysApply: true/false` (Cursor/Gemini 형식)는 kiro에서 무시된다.
> on-demand 룰은 `inclusion: manual` frontmatter를 달아야 자동 로드를 막을 수 있다.

### 실제 적용 예시

```bash
# gemini config rules 전체
for f in ~/.gemini/config/rules/*.md; do
  ln -sf "$f" ~/.kiro/steering/$(basename "$f")
done

# 11st-ai-toolkit rules
for f in ~/11st-ai-toolkit/rules/*.md; do
  ln -sf "$f" ~/.kiro/steering/$(basename "$f")
done

# on-demand rules (inclusion: manual이 없으면 자동 로드됨 — 원본 확인 필요)
mkdir -p ~/.kiro/steering/on-demand
for f in ~/11st-ai-toolkit/rules/on-demand/*.md; do
  ln -sf "$f" ~/.kiro/steering/on-demand/$(basename "$f")
done
```

## 2. Skills → ~/.kiro/skills/

`~/.kiro/skills/<name>/SKILL.md` 구조를 맞추면 kiro가 on-demand로 로드한다.
폴더 단위로 심볼릭 링크를 걸면 된다.

```bash
mkdir -p ~/.kiro/skills

# bh-agent-kit skills
for d in ~/bh-agent-kit/skills/*/; do
  ln -snf "$d" ~/.kiro/skills/$(basename "$d")
done

# gemini config skills
for d in ~/.gemini/config/skills/*/; do
  ln -snf "$d" ~/.kiro/skills/$(basename "$d")
done

# 11st-ai-toolkit skills
for d in ~/11st-ai-toolkit/skills/*/; do
  ln -snf "$d" ~/.kiro/skills/$(basename "$d")
done
```

agent 설정의 `resources`에 아래를 추가해야 kiro가 스킬을 인식한다.

```json
"resources": [
  "skill://.kiro/skills/**/SKILL.md"
]
```

## 3. Hooks → agent hooks

kiro hooks는 agent JSON의 `hooks` 필드에 정의한다.

### 이벤트 매핑

| Cursor/Claude Code | Kiro CLI | 용도 |
|-------------------|----------|------|
| `beforeSubmitPrompt` / `UserPromptSubmit` | `userPromptSubmit` | 프롬프트 제출 시 — 동적 상태 주입 |
| `preToolUse` | `preToolUse` | 툴 실행 전 — 게이트 검사 |
| `postToolUse` | `postToolUse` | 툴 실행 후 — 출력 압축 등 |
| `afterAgentResponse` | `stop` | 턴 종료 후 — 모델 기록, 후처리 |
| `agentStart` | `agentSpawn` | 에이전트 시작 시 |

### hooks 예시

```json
"hooks": {
  "userPromptSubmit": [
    {
      "command": "~/11st-ai-toolkit/hooks/inject-rules.sh",
      "timeout_ms": 5000
    }
  ],
  "preToolUse": [
    {
      "matcher": "write",
      "command": "~/11st-ai-toolkit/hooks/pretooluse-gate.sh",
      "timeout_ms": 5000
    }
  ],
  "postToolUse": [
    {
      "matcher": "*",
      "command": "~/11st-ai-toolkit/hooks/mcp-output-compress.sh",
      "timeout_ms": 5000
    }
  ],
  "stop": [
    {
      "command": "~/bh-agent-kit/hooks/show-turn-model.sh",
      "timeout_ms": 3000
    }
  ]
}
```

`matcher` 필드: `write`, `shell`, `@git/status`, `*` (전체) 등 툴명 또는 glob.

## 4. Agent 설정 파일

`~/.kiro/agents/<name>.json`으로 에이전트를 정의한다.

```json
{
  "name": "11st-default",
  "description": "에이전트 설명",
  "tools": ["read", "write", "shell", "glob", "grep", "code", "subagent",
            "todo_list", "use_aws", "web_search", "web_fetch", "knowledge", "introspect"],
  "allowedTools": ["read", "write", "shell", "glob", "grep", "code", "subagent",
                   "todo_list", "use_aws", "web_search", "web_fetch", "knowledge", "introspect"],
  "resources": [
    "skill://.kiro/skills/**/SKILL.md"
  ],
  "hooks": { }
}
```

`allowedTools`에 툴을 나열하면 해당 툴은 승인 없이 자동 실행된다 (`--trust-all-tools`와 동일 효과).

### 기본 에이전트 설정

```bash
kiro-cli settings chat.defaultAgent 11st-default
```

### alias (권장)

```bash
# ~/.zshrc
alias kiro='kiro-cli chat --trust-all-tools --agent 11st-default'
```

`--trust-all-tools`는 `allowedTools`에 없는 MCP 툴까지 커버한다.

### 유효성 검증

```bash
kiro-cli agent validate --path ~/.kiro/agents/11st-default.json
kiro-cli agent list
```

## 5. 전체 설치 스크립트 예시

```bash
#!/bin/bash
set -euo pipefail

TOOLKIT=~/11st-ai-toolkit
BH_KIT=~/bh-agent-kit
GEMINI_RULES=~/.gemini/config/rules
GEMINI_SKILLS=~/.gemini/config/skills

mkdir -p ~/.kiro/steering/on-demand
mkdir -p ~/.kiro/skills
mkdir -p ~/.kiro/agents

# --- Steering ---
for f in "$GEMINI_RULES"/*.md; do
  ln -sf "$f" ~/.kiro/steering/$(basename "$f")
done
for f in "$BH_KIT"/rules/*.md; do
  ln -sf "$f" ~/.kiro/steering/$(basename "$f")
done
for f in "$TOOLKIT"/rules/*.md; do
  ln -sf "$f" ~/.kiro/steering/$(basename "$f")
done
for f in "$TOOLKIT"/rules/on-demand/*.md; do
  ln -sf "$f" ~/.kiro/steering/on-demand/$(basename "$f")
done

# --- Skills ---
for d in "$GEMINI_SKILLS"/*/; do
  ln -snf "$d" ~/.kiro/skills/$(basename "$d")
done
for d in "$BH_KIT"/skills/*/; do
  ln -snf "$d" ~/.kiro/skills/$(basename "$d")
done
for d in "$TOOLKIT"/skills/*/; do
  ln -snf "$d" ~/.kiro/skills/$(basename "$d")
done

echo "✓ steering: $(ls ~/.kiro/steering/*.md | wc -l | tr -d ' ')개"
echo "✓ skills:   $(ls ~/.kiro/skills/ | wc -l | tr -d ' ')개"
echo ""
echo "다음 단계: ~/.kiro/agents/11st-default.json 생성 후"
echo "  kiro-cli agent validate --path ~/.kiro/agents/11st-default.json"
echo "  kiro-cli settings chat.defaultAgent 11st-default"
```

## 주의사항

- steering 파일은 **모든 턴에 컨텍스트에 로드**된다. 파일 수·크기가 클수록 컨텍스트를 소모하므로 필수 룰만 `always`로 유지한다.
- `output-writing.md` 같이 특정 상황에만 필요한 룰은 원본에 `inclusion: manual` frontmatter를 추가하거나 on-demand 서브디렉토리로 분리한다.
- 심볼릭 링크이므로 원본 저장소(`bh-agent-kit`, `11st-ai-toolkit`, `.gemini/config`)를 업데이트하면 kiro에도 즉시 반영된다.
- kiro는 `~/.kiro/steering/` 하위를 **재귀 탐색**하므로 on-demand 서브디렉토리의 `inclusion: manual` 파일도 자동 로드 대상이 된다 — frontmatter 확인 필수.
