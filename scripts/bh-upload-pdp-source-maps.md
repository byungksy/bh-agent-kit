# bh-upload-pdp-source-maps

모노레포 구조의 PDP 프론트엔드 빌드 산출물 소스맵을 Sentry에 업로드하는 헬퍼 스크립트.

## 특징
- **상용 버전 전용 (RC 자동 필터링)**: 기본적으로 `-rc-` 형태의 dev/alp 빌드 파일 및 릴리즈는 모두 제외하고, 오직 상용(Release) 빌드 파일만 업로드합니다.
- **보안 철저**: 사내 URL, 토큰, 프로젝트명 등 민감 정보가 하드코딩되지 않으며, 환경변수 또는 `~/.sentry-pdp.env`, `bh-secrets`를 통해 안전하게 주입됩니다.
- **모노레포 지원**: `pdp`, `retail`, `luxury`, `amazon`, `pages` 각 앱의 `latest.txt` 버전을 자동 파싱하여 `${app}@${version}` 릴리즈 태그로 개별 업로드합니다.
- **Debug ID 매핑**: Sentry 최신 규격인 `sentry-cli sourcemaps inject` 기반 Debug ID 매핑을 지원합니다.
- **CI 아티팩트 지원**: CI에서 보존된 `sourcemaps.tar.gz` 파일을 인자로 넘기면 임시 디렉토리에 자동 압축 해제 후 업로드합니다.
- **Dry-run 지원**: `--dry-run` 플래그로 실제 업로드 없이 대상 파일 및 릴리즈 태그를 시뮬레이션할 수 있습니다.

## 사용법

### 1. 상용 전체 앱 일괄 업로드 (기본값: RC 파일 자동 제외)
```bash
bh-upload-pdp-source-maps
```

### 2. 특정 앱만 업로드
```bash
bh-upload-pdp-source-maps pdp
```

### 3. CI 상용 아티팩트(`sourcemaps.tar.gz`) 업로드
```bash
bh-upload-pdp-source-maps sourcemaps.tar.gz
```

### 4. 시뮬레이션 (Dry-run)
```bash
bh-upload-pdp-source-maps --dry-run
```

### 5. RC 파일도 포함하여 업로드하고 싶을 때
```bash
bh-upload-pdp-source-maps --include-rc
```
