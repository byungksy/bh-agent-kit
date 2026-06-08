# bh-agent-level-up

AI 에이전트와의 세션, 사용자 교정, 코드 리뷰 중 수확한 지식(인사이트)을 5가지 유형(K1~K5)의 지식 체계로 분류하고, 검증 게이트를 거쳐 에이전트의 영구적인 자산(룰, 스킬, TIL 등)으로 승격시키는 **지식 승격 파이프라인(v2) 스킬**입니다.

## 🛠 기술 스택
- **규격**: Cursor Skill Specification (마크다운 기반의 절차 지시 문서)
- **지식 관리 아키텍처**: 
  - ARIA (Artifact-based Review and Integration Architecture)
  - Codified Context & Lore (Hot/Cold 컨텍스트 분리 기법)
  - Anthropic context engineering (최소 고신호 컨텍스트 주입 원칙)

## 📋 Usage
에이전트와의 페어 프로그래밍 대화 도중, 혹은 작업이 완료된 후 아래의 트리거 명령어를 통해 실행합니다.
```text
/bh-agent-level-up
/agent-level-up
"방금 배운 내용을 에이전트 룰로 승격해줘"
"세션을 기반으로 룰/스킬 개선하자"
```

## ⚙️ 주요 파이프라인 단계
1. **Capture (수확)**: 대화 트랜스크립트에서 사용자 교정이나 중요한 결정 사항을 수집합니다.
2. **Classify (분류)**: 수집된 지식을 K1(도메인 계약), K2(스킬 하네스), K3(워크플로우 룰), K4(스킬 갓챠), K5(일회성 TIL)로 분류합니다.
3. **Stage (스테이징)**: 사용자에게 후보 지식 인덱스 테이블을 보여주어 progressive disclosure를 달성합니다.
4. **Propose (상세 제안)**: 사용자가 선택한 지식에 대해 템플릿 검증과 게이트 조건을 테스트합니다.
5. **Promote (승격)**: 사용자의 승인을 거쳐 룰 파일 동기화 또는 TIL 기록 등을 실행합니다.
