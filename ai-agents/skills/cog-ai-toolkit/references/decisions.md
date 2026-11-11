# 결정 기록과 아직 정하지 않은 것

## 결정 기록 (2026-11-11)

- 폴더 이름 `ai-agents/`: 도구별 폴더를 한 곳에 묶기 위해 정했다. `agents/` 는 서브에이전트 폴더와 혼동되고, `global/`·`home/`·`shared/`·`rules/` 는 의미가 맞지 않거나 도구가 쓰는 이름과 겹쳐 제외했다.
- 스킬은 `ai-agents/skills/` 한 곳에 둔다: 최상위 `skills/` 를 없애고 `ai-agents/` 가 지침과 스킬을 함께 담는다. 세 도구가 같은 `SKILL.md` 형식을 읽으므로 진입 파일을 도구마다 두지 않고 한 벌만 둔다. 한 도구에만 쓰는 스킬은 `ai-agents/<도구>/skills/` 에 둔다.
- 래퍼 폴더 방식: `slop-rewrite` 스크립트가 자기 위치에서 루트를 계산해 내부 구조를 바꿀 수 없다. 그래서 가져온 프로젝트를 `project/` 에 통째로 담고 진입 파일을 곁에 둔다. 상대경로만 쓰므로 저장소를 옮겨도 동작한다. Claude 에서 인식, 상대경로 따라가기, 스크립트 실행, 목록에 중복 없음을 시험했다.
- 연결 스크립트(`scripts/install.sh`): 기본은 계획만 출력하고 `--apply` 로 실행한다. 스킬 하나마다 링크하며 도구 폴더 전체는 링크하지 않는다. 이미 있는 항목은 덮어쓰지 않고 `--backup` 일 때만 옮겨 둔다. 삭제 명령은 쓰지 않는다. 별칭 `~/.ai-toolkit`(저장소 위치)도 만든다. 도구별 경로와 예약 이름은 `scripts/targets.conf` 에 둔다.
- 이름 규칙: 직접 만든 스킬만 `cog-` 접두사를 붙이고, 가져온 스킬(`slop-rewrite`, `taste-builder`, `styleguide-builder`)은 이름을 유지한다. 기존 `my-*` 스킬 4개는 복사하지 않고, 내용을 참고해 작성 기준과 시험을 거쳐 새로 만든다. `my-code-conventions` 는 `cog-code-writer` 로, `my-django-drf-conventions` 는 `cog-django` 로 다시 만들었다. `my-vue-nuxt-ui-conventions` 는 `cog-vue` 로 다시 만들었다. 나머지 1개(`my-write-report`)는 아직 만들지 않았다.
- 공통 지침은 `ai-agents/AGENTS.md` 한 파일: 도구 전용 줄이 없어 한 파일로 시작했다. `ai-config` 의 공통 지침 49줄을 문체만 명사형으로 바꿔 옮겼다.
- `ai-config` 는 이전이 끝난 뒤 쓰지 않는다.
- 다루는 도구: Claude Code, Codex, Antigravity(앱·CLI). Antigravity IDE 는 쓰지 않는다. Gemini CLI 는 Antigravity CLI 로 대체되어 다루지 않는다.
- 유지보수를 스킬(`cog-ai-toolkit`)로 둔 이유: 어느 도구에서든 어느 프로젝트에서든 갱신이 필요할 수 있어서 직접 호출할 수 있는 스킬이 맞다. 참조문서 방식은 자동 호출의 확실성이 문제였던 스킬 방식(4개 중 2개 호출)보다 읽히는 비율이 높았지만(4/4), 직접 호출에는 그 약점이 없고 세 도구에 링크로 깔려 다른 프로젝트에서도 쓸 수 있다. 이전 문서(`docs/maintenance.md`)와 루트 `AGENTS.md` 의 내용은 이 스킬의 `references/` 로 옮겼다.
- 루트 `AGENTS.md` 의 안내 문구는 세 차례 고쳤다. 처음 문구는 「새 스킬 추가」 요청에서 읽지 않았고, 두 번째 문구는 「스킬 만들어줘」 같은 작업 요청에서 읽지 않았다. 작업 시점(「…하는 요청을 받으면, 파일을 쓰기 전에」)을 명시한 문구에서 작업 요청 3/3 은 읽었고 무관한 요청 3/3 은 읽지 않았다. 지금의 루트 안내는 이 결과를 따른다.
- `cog-code-writer` 의 범위: 코드를 쓸 때 지킬 기본 규칙(주석과 독스트링, 예시 데이터, 함수와 파일 구성, 한 곳에만 두기, 문서 확인, 검증)만 담는다. 옛 스킬에 있던 코드 검수 방식과 설계안 제시 규칙은 쓰기 규칙과 성격이 달라 넣지 않았다. 문서는 명사형 종결로 쓰고 특수기호를 쓰지 않으며 윤문 검사기의 원칙 층을 통과시켰다. 이름은 짧게 `cog-code-writer` 로 정했다.
- `cog-code-writer` 를 코드 작성 때마다 읽히게 하는 방식: Claude 시험에서 스킬만 두면 코드 작성 요청 10개 중 8개, 스킬과 전역 지침 한 줄을 두면 10개 모두 호출됐다. 그래서 스킬과 지침 한 줄(`ai-agents/AGENTS.md` 의 코드 절)을 둔다. 규칙 본문을 지침에 직접 넣는 방식은 같은 규칙이 두 곳에 생겨 어긋나기 쉬워 택하지 않았다. 호출된 경우 규칙이 지켜졌고(독스트링 0개, 가상 이름, 문서 확인 5항목), 아무것도 없는 기준에서는 어긋났다. 과제당 1회 시험이다.
- `cog-django` 의 범위: Django 백엔드의 기본 구성 규칙(디렉토리 구조와 층, apps·modules·utils·extensions 구성, settings 분리, .env 와 필수 변수 검사와 기능 스위치, accounts 와 core 구성, 등록 위치, 범용 함정, 마이그레이션)만 담는다. 옛 `my-django-drf-conventions` 에서는 범용 규칙만 발췌했다. `.env` 구조와 settings 구성은 옛 스킬에 거의 없어서 프로젝트 `infra-iscim-app` 의 코드(변수 이름만 추출하고 값은 읽지 않음)와 그 프로젝트의 `CLAUDE.md` 에서 뽑았다. 그 프로젝트의 `backend` 스킬은 옛 스킬의 복사본이라 근거로 쓰지 않았다.
- `cog-django` 에서 뺀 것: 인증과 권한 체계, 배치와 외부 연동(실행 리포트, 락, 재시도, 자격증명), DRF API 설계, 로깅 설계(로그 테이블, 로그 봉투), 프로젝트 고유 예시. 후속 스킬 후보로 둔다.
- `cog-django` 에 에이전트가 일반 Django 지식으로 추가한 것: N+1, update 와 bulk_update 의 시그널·auto_now 미호출, transaction.on_commit, 적용된 마이그레이션 수정 금지, 마이그레이션 누락 확인, ruff 기본값, 새 환경변수를 더할 때 읽는 코드와 필수 목록과 .env.example 을 함께 고친다는 규칙. 마지막 규칙은 코드 구조에서 추정한 것이다.
- `cog-django` 호출 방식: 직접 호출과 description 자동 호출만 쓰고 전역 지침 한 줄은 두지 않는다. Claude 시험(과제당 1회)에서 Django 요청 12개 중 11개가 호출됐고, 미호출 1개는 디버깅 질문이라 description 에 디버깅 구절을 더했다. 보강 뒤 같은 유형 3개가 모두 호출됐다. Django 가 아닌 요청 8개(다른 언어 코드, 비코드, 다른 언어 디버깅)에서는 호출되지 않았다. 동작 시험에서 스킬 항목 언급은 27/27, 스킬이 없을 때는 10/27 이었다. 이 점수는 스킬의 어휘로 잡은 항목이라 스킬이 쓰이는지만 보여 주고 규칙의 타당성은 보여 주지 않는다.
- `cog-vue` 의 범위: 프론트엔드 기본 규칙(파일 위치와 앱 경계, 이름 짓기, 컴포넌트와 Pinia 스토어 작성, 스타일 토큰과 Nuxt UI 를 Vite 에서 쓸 때의 차이, Vite 설정과 환경변수와 린트)만 담는다. 옛 `my-vue-nuxt-ui-conventions` 의 layout, naming, vue, pinia, design-tokens, nuxt-ui-in-vite 에서 범용 규칙을 발췌했고, 설정 파일 구성은 프로젝트 `infra-iscim-app/frontend` 의 vite.config, tsconfig, oxlint, oxfmt, editorconfig, gitignore 와 코드에서 뽑았다(환경변수 파일은 읽지 않고 VITE_ 변수 이름만 코드에서 추출).
- `cog-vue` 에서 뺀 것: 데이터 테이블, 읽기 전용 상세, 페이지 헤더, 토스트와 모달 흐름, 폼 검증 같은 화면 패턴(옛 data-tables, detail-view, page-header, ux-patterns). 프로젝트 부품(AppDataTable, useListQuery 등)에 묶인 내용이 많아 후속 스킬 후보로 둔다. 옛 스킬의 특수기호, 옛 스킬 이름 참조(`my-code-conventions` 등), 프로젝트 고유 화면 예시는 넣지 않았다.
- `cog-vue` 에 에이전트가 추가한 것(프로젝트에서 확인하지 못한 일반 지식): import.meta.env 타입 선언(env.d.ts)을 함께 고친다는 규칙, 환경변수 읽는 위치를 한곳으로 모은다는 규칙, VITE_ 변수에 비밀 값을 넣지 않는다는 규칙, autoImport 로 생성되는 dts 를 직접 고치지 않는다는 규칙, 개발 중 console 을 커밋하지 않는다는 규칙, 린트로 앱 경계와 상대경로 금지가 강제되는지 확인한다는 규칙, 패키지 설치 시 lock 파일 확인.
- `cog-vue` 호출 방식: 직접 호출과 description 자동 호출만 쓰고 전역 지침 한 줄은 두지 않는다. Claude 시험(질문당 1회)에서 Vue 요청 4개(파일 위치, 색 클래스, 액션 이름, 빈 화면 원인)는 모두 호출됐고, Vue 와 무관한 요청 3개(파이썬 코드, Django 질문, README 문단)는 호출되지 않았다. 동작 시험은 하지 않았다.

## 아직 정하지 않은 것

- 안내 문구와 호출 시험은 질문당 1회, Claude 한 모델이다. 읽는 비율이 이 결과보다 낮을 수 있고, Codex·Antigravity 는 시험하지 않았다.
- 공통 지침 7행 「미정으로 보고 제외」의 의미, 용어 변주(안·계획·설계, 승인·확인), 따옴표·가운뎃점·마침표 통일: 따름 시험에서 실패가 나오지 않아 보류했다.
- 「스스로 커밋 금지」「비밀 정보 금지」를 hook·권한 설정으로도 강제할지.
- 공통 지침을 각 도구의 전역 위치에 연결하는 방식은 `install.sh` 의 직접 링크로 구현했다. Codex·Antigravity 에서의 동작은 시험 전이다.
- Antigravity 의 전역 규칙 파일 이름.
- `cog-ai-toolkit` 의 자동 호출을 돕는 전역 지침 안내는 두지 않았다. 직접 호출을 자주 잊으면 다시 검토한다. `cog-code-writer` 는 지침 한 줄을 두었다.
- 옛 `my-*` 전역 링크 8개(Claude 4, Codex 4)는 끊었고 `ai-config` 원본은 그대로다. `cog-code-writer` 와 `cog-django` 는 사용자가 `install.sh --apply` 로 연결해야 쓸 수 있다. 나머지 `my-*` 2개를 같은 방식으로 다시 만들지 정한다.
- `cog-django` 의 앱 구성(apps/분류/화면, app_v1·api_v1)과 core 의 권한 모델(Role, Menu, Feature)이 사용자의 모든 프로젝트에 공통인 규칙인지 확인하지 못했다. 프로젝트 하나(`infra-iscim-app`)를 근거로 일반 규칙이라 가정했다.
- `.env.example` 의 틀 규칙(구획, 변수 설명 쓰는 법)은 파일을 읽지 않아 담지 못했다. 규칙을 받으면 `cog-django` 의 `settings-env` 에 추가한다.
- `cog-django` 로 코드를 실제로 만드는 과제(파일 생성, 구조 준수)는 시험하지 못했다. 시험한 것은 구성과 위치를 묻는 질문이다.
- 후속 스킬 후보는 Django 인증과 권한, 배치와 외부 연동, DRF API 설계이고 순서는 정하지 않았다. 프로젝트 `infra-iscim-app` 의 `backend` 스킬과 `CLAUDE.md` 는 사용자 프로젝트라 바꾸지 않았고, 새 스킬로 바꿀지는 사용자가 정한다.
- `cog-code-writer` 의 함수 분리, 이름 일관성 같은 규칙은 아직 시험하지 못했다.
- 비대화형 시험에서 작업 폴더 밖 읽기와 `python` 실행은 승인이 필요했다. `ai-toolkit` 폴더를 읽기 허용 폴더로 등록할지는 사용자가 정한다(설정 변경).
- Codex·Antigravity 에서의 스킬 인식, 직접 호출, `description` 호출 시험.
- `cog-vue` 의 apps/분류/화면 구성과 App*, use* 부품 이름이 사용자의 모든 프론트엔드 프로젝트에 공통인 규칙인지 확인하지 못했다. 프로젝트 하나를 근거로 일반 규칙이라 가정했다. 외부 `nuxt-ui` 스킬은 프로젝트에만 있고 전역에 없어 설치되어 있으면 읽는다는 조건부 문구로 두었다.
- `cog-vue` 의 화면 패턴 스킬(표, 상세, 헤더, 폼, 토스트와 모달)을 만들지, 어떤 이름으로 만들지 정하지 않았다. 옛 스킬의 data-tables, detail-view, page-header, ux-patterns 는 읽지 않았다(제목 수준 확인 없음).
- `cog-vue` 로 코드를 실제로 만드는 과제와 규칙 지킴 여부는 시험하지 못했다. 시험한 것은 호출 여부뿐이다. 환경변수 파일의 틀(.env.example) 규칙은 파일을 읽지 않아 담지 못했다.
