---
name: bh-gif
description: |
  동영상을 고품질 GIF로 변환해주는 터미널 명령어(bh-gif) 사용 및 관리.
  
  트리거 키워드:
  - 명령어: /bh-gif
  - 자연어: "동영상 gif 변환", "gif로 만들어줘", "bh-gif"
---

# bh-gif

`bh-gif`는 `ffmpeg`와 `gifski`를 사용하여 동영상을 고품질 GIF로 변환해주는 커스텀 터미널 도구입니다.

## 1. 사전 요구사항 (의존성)
- `ffmpeg`: 프레임 추출
- `gifski`: 고품질 GIF 병합
(명령어: `brew install ffmpeg gifski`)

## 2. 사용법
```bash
bh-gif <video_file>
```
예시:
```bash
bh-gif input.mp4
# 결과: input.gif 파일이 생성되고 경로가 출력됨
```

## 3. 스크립트 위치
- 파일 경로: `scripts/bh-gif`
- 사용자의 PATH에 해당 경로가 추가되어 있어야 어디서든 사용 가능합니다.
