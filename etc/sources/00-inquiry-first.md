# 출처: 00-inquiry-first

`rules/00-inquiry-first.md` 작성·통합 시 참고한 자료. (2026-06-05)

## 외부 참고 (웹·오픈소스)

| 패턴 | 출처 | URL |
|------|------|-----|
| Think before coding (가정 명시, 해석 병렬 제시, 멈추고 질문) | Andrej Karpathy → andrej-karpathy-skills | https://github.com/multica-ai/andrej-karpathy-skills |
| 동일 요약 | Cosmoscalibur | https://www.cosmoscalibur.com/en/blog/2026/guia-de-comportamiento-para-agentes-de-codigo/ |
| Risk triage (Low / Medium / High) | clarify-first | https://github.com/DmiyDing/clarify-first |
| Blocking 1~5 questions, pause before act, `defaults` | Ask Questions skill (Cursor) | https://www.ai-insight-solutions.com/blog/ask-questions-skill-for-cursor/ |
| Response Protocol (항상 + ask-first 강모드) | GitHub Copilot clarifying questions | https://levelup.gitconnected.com/how-to-make-github-copilot-ask-clarifying-questions-before-it-acts-18a50e1d2937 |
| Assumption Log | Nova Elvaris, DEV | https://dev.to/novaelvaris/assumption-logs-the-simplest-way-to-get-more-reliable-ai-help-4g7g |
| Assumption Inventory (리스크 라벨) | Nova Elvaris, DEV | https://dev.to/novaelvaris/the-assumption-inventory-prompt-catch-hidden-requirements-before-you-code-1j6n |
| Question-first (no fix yet) | Nova Elvaris, DEV | https://dev.to/novaelvaris/question-first-prompting-make-your-assistant-ask-before-it-answers-4dn2 |
| clarify-then-code (자기 신뢰도 % 지시 역효과) | John Higgins, LinkedIn | https://www.linkedin.com/posts/johnbhiggins_evidenced-based-prompting-tips-stop-telling-activity-7369393647668113408-BByX |
| Trust boundary (decision points) | Nova Elvaris, DEV | https://dev.to/novaelvaris/the-trust-boundary-prompt-safer-ai-workflows-with-explicit-permissions-1emc |
| 가정 도구화·질문 강제 (텍스트만으로 부족) | Uhyeon Park | https://uhyeon.dev/blog/ai-agent-assumption-prevention |
| 룰 작성 (500줄 이하, 검증 가능) | Cursor Docs — Rules | https://cursor.com/help/customization/rules |
| 충돌 시 clarification | AgentSpec Cursor v5 예시 | https://agentspec.sh/rules/9d7641af-8654-4734-9a41-4ee68db80f2f |

## 내부 통합 (개인 ~/.agents·company toolkit)

| 구성요소 | 역할 |
|----------|------|
| `company-rules` | "확인 먼저", 추측 금지 → inquiry-first §Precedence에서 구체화 |
| `grill-me` 스킬 | 구현·플랜·stack 착수 전 심화 역질문 (opt-in) → §7 위임 |
| `context-gate` / `work-context` | plan_gate, 브랜치·범위 확인 → §7 위임 |
| `company-harness-process` C항 | 플랜 승인 후 Task 연속 실행 → §7 예외 |
| `communication-style` | 산출 톤 → §6, Precedence 5순위 |
| `output-writing` (프로젝트 `.agents`) | PR·요약 형식 → §6, Precedence 충돌 해석 |
| User rule "MUST run commands" | §Precedence — read-only 탐색 허용, blocking 시 쓰기 금지 |

## SSOT

- 최초 작성: 로컬 `~/.agents/rules/00-inquiry-first.md` (2026-06-05)
- 배포 본 저장소: `bh-agent-kit/rules/00-inquiry-first.md`
