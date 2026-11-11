# ai-toolkit

여러 AI 에이전트(Claude Code, Codex, Antigravity)에서 함께 쓰는 스킬과 공통 지침을 한 곳에서 관리하는 개인 저장소다. 원본은 여기서만 고치고, 각 도구에는 링크로 연결한다.

## 구조

```
ai-toolkit/
├── ai-agents/
│   ├── AGENTS.md                공통 지침(모든 도구가 읽는 개인 규칙)
│   ├── skills/                  모든 도구에 연결하는 스킬. 폴더 하나가 스킬 하나
│   │   ├── cog-ai-toolkit/      이 저장소를 고칠 때 쓰는 유지보수 스킬
│   │   ├── cog-code-writer/     코드를 쓸 때 지킬 기본 규칙
│   │   ├── cog-django/          Django 백엔드 기본 구성 규칙
│   │   ├── cog-vue/             Vue + Vite + Pinia + @nuxt/ui 프론트엔드 기본 규칙
│   │   ├── cog-report-writer/   보고서를 쓸 때 지킬 구성, 내용, 디자인 규칙
│   │   └── slop-rewrite/        가져온 스킬(래퍼 폴더)
│   └── <도구>/skills/           한 도구에만 쓰는 스킬
└── scripts/                     install.sh(전역 연결), targets.conf(도구별 경로 표)
```

- 직접 만든 스킬의 이름은 `cog-` 로 시작한다. 접두사가 없는 스킬은 가져온 스킬이다.
- 자세한 구조와 규칙은 `ai-agents/skills/cog-ai-toolkit/references/` 에 있다.

## 설치

```bash
scripts/install.sh               # 계획만 출력한다(아무것도 만들지 않는다)
scripts/install.sh --apply       # 계획대로 링크를 만든다
scripts/install.sh --apply --backup   # 충돌한 기존 항목을 ~/.ai-toolkit-backup/ 으로 옮기고 연결한다
```

- 도구별 스킬 폴더에 스킬을 하나씩 링크하고, 공통 지침과 별칭 `~/.ai-toolkit`(이 저장소 위치)도 연결한다.
- 이미 있는 항목은 덮어쓰지 않는다. 삭제하는 동작은 없다.
- 도구별 경로는 `scripts/targets.conf` 에 있다.

## 갱신 방법

어느 도구에서든 어느 프로젝트에서든 `cog-ai-toolkit` 스킬을 직접 호출한다.

| 도구 | 호출 |
|---|---|
| Claude Code | `/cog-ai-toolkit` |
| Codex | `$cog-ai-toolkit` |
| Antigravity | `/cog-ai-toolkit` |

호출하면 에이전트가 이 저장소의 규칙과 절차(사본에서 먼저 고치기, 승인, 시험)를 따른다. 커밋과 push 는 사용자가 말할 때만 한다.

## 직접 만든 스킬

| 이름 | 용도 |
|---|---|
| `cog-ai-toolkit` | 이 저장소의 스킬과 지침을 만들거나 고칠 때의 규칙과 절차 |
| `cog-code-writer` | 코드를 쓸 때 지킬 기본 규칙(주석, 예시 데이터, 함수와 파일, 한 곳에만 두기, 문서 확인, 검증). 공통 지침이 코드 작성 전에 호출하도록 지정함 |
| `cog-django` | Django 백엔드의 기본 구성 규칙(디렉토리 구조, apps·modules 구성, settings 와 .env, accounts 와 core, 등록 위치, 조용히 깨지는 코드). 직접 호출(`/cog-django`)과 description 자동 호출을 씀 |
| `cog-vue` | Vue 3 + Vite + Pinia + @nuxt/ui 프론트엔드의 기본 규칙(파일 위치와 앱 경계, 이름 짓기, 컴포넌트와 스토어 작성, 색과 타이포와 아이콘, Vite 설정과 VITE_ 환경변수와 린트). 화면 패턴(표, 상세, 헤더, 폼, 토스트)은 담지 않음. 직접 호출(`/cog-vue`)과 description 자동 호출을 씀 |
| `cog-report-writer` | 보고서를 쓸 때 지킬 구성과 내용 규칙(목적, 흐름, 리스크와 이슈 기준, 일관성)과 디자인(색, 배지, HTML 기본 CSS). 문체와 윤문은 `slop-rewrite` 가 맡음. 직접 호출(`/cog-report-writer`)과 description 자동 호출을 씀 |

## 가져온 스킬

| 이름 | 비고 |
|---|---|
| `slop-rewrite` | 한국어 문서 윤문·검토. README 가 공개 사이트를 가리키고 MIT 라이선스 파일이 있다. 내부 구조는 바꾸지 않는다. |

## 주의

- 개인 자산이므로 비공개 저장소에서 관리한다. 비밀 정보(키, 토큰, 비밀번호)와 실명·이메일은 넣지 않는다.
- `slop-rewrite` 의 개인 코멘트 폴더(`taste/`)는 그 스킬의 `.gitignore` 가 막는다.
