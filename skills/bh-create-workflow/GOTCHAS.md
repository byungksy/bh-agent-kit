# 11st Workflow Gotchas

- **Don't use syntax error prone Mermaid code**: Mermaid 문법 에러가 발생하면 브라우저 렌더링에 실패하여 화면이 빈 채로 남는다. 텍스트 내에 괄호`()`, 대괄호`[]`, 중괄호`{}`, 특수문자, 쉼표 등이 들어가면 반드시 쌍따옴표 `""`로 감싸서 선언해야 한다.
- **Don't save in project root**: HTML/MD 결과물을 프로젝트 루트나 엉뚱한 임시 디렉터리에 마구 생성하지 않는다. **MUST** 홈 디렉터리 하위의 `~/ai-workflow/diagrams/` 디렉터리 하위에 저장하여 여러 프로젝트에서 생성된 모든 다이어그램 파일들을 한 곳에서 깔끔하게 통합 관리한다.
- **Don't hardcode heavy CSS/JS in individual files**: 개별 HTML 파일 안에 CSS 스타일이나 Mermaid JS 라이브러리를 하드코딩으로 전부 주입하지 마라. `~/ai-workflow/diagrams/assets/style.css`와 `~/ai-workflow/diagrams/assets/mermaid-init.js`를 상대경로(`./assets/...`)로 로드하도록 래퍼 링크 구조를 유지하여 HTML 파일의 용량과 복잡성을 최소화하라.
- **Don't use relative paths in links**: 사용자에게 HTML 파일의 경로를 제공할 때 `file:///`을 사용할 수 있는 absolute path를 제공한다. 상대 경로는 링크 클릭 시 정상 작동하지 않는다.
- **Don't overcomplicate diagrams**: 다이어그램이 너무 비대해지면 브라우저 상에서 한 눈에 보기 어렵고 UI가 깨질 수   있다. 다이어그램의 노드 개수가 20개를 초과하는 복잡한 경우, 의미론적으로 여러 개의 하위 시퀀스/프로세스 HTML 파일로 분할하여 작성하라.
- **Don't hardcode Title and Descriptions in template**: HTML 파일 생성 시 `{Workflow 타이틀}`, `{프로세스에 대한 상세한 요약 설명 또는 안내}`, `{Mermaid 다이어그램 본문}` 부분을 해당 다이어그램의 실제 컨텍스트와 매칭되는 내용으로 명확하게 채워야 한다. placeholder 그대로 남겨두지 마라.
- **Don't skip Markdown file**: Markdown 파일(`*.md`)도 항상 쌍으로 생성하여, 사용자가 IDE 에디터 프리뷰 기능으로도 동시에 편하게 조회할 수 있게 배려하라.
