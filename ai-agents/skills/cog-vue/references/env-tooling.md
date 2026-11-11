# 설정과 환경변수와 도구

예시 프로젝트(infra-iscim-app 의 frontend)의 설정 파일에서 뽑은 구성임. 환경변수 파일의 값은 읽지 않았고 변수 이름만 코드에서 뽑음. 표시한 에이전트 추가 항목은 일반 Vite 지식이며 프로젝트에서 확인한 것이 아님.

## 환경변수
- 프론트엔드에 노출되는 환경변수는 VITE_ 로 시작하는 것뿐이고 `import.meta.env.VITE_*` 로 읽음. 막는 실수: 비밀 값을 VITE_ 변수에 넣으면 빌드 결과물에 그대로 들어가 누구나 읽는 일. 키, 토큰, 비밀번호는 프론트엔드 환경변수에 넣지 않음.
- 예시 프로젝트의 변수는 VITE_BASE_URL(API 기준 주소), VITE_AUTH_MODE(인증 방식 스위치), VITE_API_TIMEOUT(요청 제한 시간)임.
- .env 파일은 커밋하지 않고 값 없는 틀(.env.example)만 커밋함. 에이전트는 .env 파일의 값을 읽거나 출력하지 않고, 검색할 때는 `rg --glob '!**/.env*'` 처럼 환경변수 파일을 제외함. 필요한 값은 사용자에게 요청함.
- 에이전트 추가: 새 변수를 쓰면 `import.meta.env` 의 타입 선언(env.d.ts 의 ImportMetaEnv)과 .env.example 을 함께 고침. 막는 실수: 변수 이름 오타가 타입 검사를 통과해 undefined 로 동작하는 일. 예시 프로젝트에 이 선언이 있는지는 확인하지 못함.
- 읽는 위치는 한곳(axios 플러그인, 환경 설정 모듈 등)으로 모으고 화면 코드에서 import.meta.env 를 직접 부르지 않음. 에이전트 추가이며 예시 프로젝트에서의 준수 여부는 확인하지 못함.

## Vite 설정
- 플러그인은 vue, vueJsx, vueDevTools, @nuxt/ui/vite 임. @nuxt/ui 의 autoImport 와 components 선언 파일(dts)은 `src/types` 에 생성하게 하고, 이 생성 파일은 직접 고치지 않음(에이전트 추가).
- 별칭은 `@` 가 `src` 를 가리킴. tsconfig 의 paths(`@/*`)와 짝이므로 둘을 함께 고침. Nuxt UI 테마 타입을 위해 `#build/ui/*` 경로도 tsconfig 에 있음.
- 개발 서버는 3000 포트이고 https 인증서는 serve 일 때만 상위의 pem 폴더에서 읽음. 인증서와 키 파일은 읽거나 출력하지 않음.
- 빌드는 assetsDir 을 static 으로 하고 console 을 제거(dropConsole)함. 막는 실수: 디버그 로그가 운영에 남는 일. 개발 중 확인용 로그를 console 로 남기고 커밋하지 않음(에이전트 추가).

## TypeScript
- tsconfig.app.json 에서 noUncheckedIndexedAccess 를 켬. 인덱스 접근 결과가 undefined 를 포함하므로 배열과 사전 접근 뒤에 확인함.
- 타입 검사는 vue-tsc 가 함. 검사 명령 이름은 package.json 의 scripts 에서 확인하고 추측하지 않음.

## 린트와 포맷
- 린트는 oxlint(.oxlintrc.json)이고 포맷은 oxfmt(.oxfmtrc.json)임. 들여쓰기 4칸, 작은따옴표, 세미콜론 사용, 끝 쉼표 all, 화살표 함수 인자 괄호 생략(arrowParens avoid), 줄 너비 120, Tailwind 클래스 정렬(sortTailwindcss)임. .editorconfig 도 같은 값을 따름.
- 에디터 설정과 포맷터 설정이 어긋나면 포맷터 설정 파일이 기준임. 새 코드를 쓰면 포맷 검사 명령을 돌려 확인함(명령 이름은 package.json 에서 확인).
- 앱 사이 임포트 금지(structure 문서)와 상대경로 임포트 금지(component-store 문서)는 린트 규칙으로 걸어야 강제됨. 걸려 있는지 먼저 확인하고, 없으면 사용자에게 알림(에이전트 추가).

## 패키지
- 패키지를 설치하면 같은 작업에서 package.json 과 잠금 파일(lock)이 함께 바뀌었는지 확인함. 사용하는 패키지 매니저는 잠금 파일 이름으로 확인함. 라이브러리 버전은 이 문서에 적지 않고 package.json 이 정함.
