---
name: eli5
description: |
  어떤 주제든 아무것도 모르는 사람도 이해할 수 있게, 그림 위주 적은 글자의 HTML로 설명한다.

  트리거 키워드:
  - 명령어: /eli5 <주제>
  - "5살한테 설명하듯", "ELI5", "쉽게 설명해줘 (그림으로)", "초등학생도 알아듣게"

  Do NOT use for: 코드 리뷰, 기술 문서 작성, 정확도가 중요한 전문 설명 (단순화 과정에서 세부사항이 손실됨)
---

# eli5

주제를 하나도 모르는 사람에게 설명하듯, 큰 그림(비주얼)과 적은 글자만 있는 HTML 아티팩트로 만든다.

원본: [anthropics/claude-plugins-community/eli5](https://github.com/anthropics/claude-plugins-community/tree/main/eli5) (MIT License, Thariq Shihipar)

**MUST** 작업 시작 전 [GOTCHAS.md](./GOTCHAS.md)를 먼저 Read한다. 이 스킬은 원본이 매우 단순한 한 줄 지시라, 실제 함정은 GOTCHAS에 축적된다.

## 사용법

```
/eli5 how does DNS work
/eli5 블록체인이 뭐야
```

## 출력 규칙

- 결과물은 **HTML 파일 하나**로 만든다 (인라인 CSS, 외부 의존성 없음)
- 텍스트는 최소화하고 시각적 비유·다이어그램 중심으로 구성한다
- 전문 용어는 쓰지 않거나, 쓰더라도 그림으로 먼저 개념을 보여준 뒤에만 등장시킨다
- 주제 하나당 화면(또는 섹션) 3~6개 이내로 압축한다 — 길어지면 ELI5의 목적을 벗어난다

## 명령어

| 명령어 | 설명 |
|--------|------|
| `/eli5 <주제>` | 해당 주제를 그림 위주 HTML로 설명 |
