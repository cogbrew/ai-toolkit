# ai-toolkit 작업 지침

이 저장소는 스킬과 AI 도구 설정을 모으는 개인 저장소다. 이 저장소에서 스킬이나 AI 도구를 추가·수정하는 에이전트는 아래를 따른다.

## 1. 구조

```
ai-toolkit/
├── ai-agents/
│   ├── AGENTS.md                    공통 지침 (모든 도구가 읽는 개인 규칙)
│   ├── skills/                      모든 도구에 연결하는 스킬. 폴더 하나가 스킬 하나
│   │   ├── cog-<스킬 이름>/SKILL.md 직접 만든 스킬(앞으로 만들 것)
│   │   └── <가져온 스킬>/           래퍼 폴더
│   │       ├── SKILL.md             진입 파일(project/ 를 가리킴)
│   │       └── project/             가져온 프로젝트 전체, 내부 구조 그대로
│   └── <도구>/skills/<스킬 이름>/   그 도구에만 연결하는 전용 스킬
├── docs/maintenance.md              지침·스킬을 쓰거나 고칠 때 읽는 안내
├── scripts/                         install.sh(전역 연결), targets.conf(도구별 경로 표)
├── AGENTS.md                        이 문서
└── CLAUDE.md                        Claude 가 이 문서를 읽게 하는 한 줄
```

- 스킬은 `ai-agents/skills/` 에 둔다. 폴더 하나를 도구의 전역 스킬 폴더에 그대로 링크하며, 래퍼 폴더의 진입 파일은 `project/` 를 가리키기만 하고 내용을 복제하지 않는다.
- `ai-agents/<도구>/skills/` 에는 그 도구에만 쓰는 스킬을 둔다. 모든 도구가 쓰는 스킬은 `ai-agents/skills/` 에 둔다.
- 이름 규칙: 직접 만든 스킬은 폴더 이름과 `name` 을 `cog-` 로 시작하는 소문자-하이픈으로 정한다. 가져온 스킬은 이름을 바꾸지 않는다. 접두사가 없으면 가져온 스킬이다.
- 최상위 폴더는 `ai-agents/`, `docs/`, `scripts/` 로 유지한다. 도구가 늘어도 `ai-agents/` 안에서만 늘린다.
- 이 문서(루트 `AGENTS.md`)는 이 저장소에서 일하는 방법이고, `ai-agents/AGENTS.md` 는 모든 작업에 적용되는 개인 규칙이다. 두 문서를 섞지 않는다.

## 2. 건드리면 안 되는 것

- 가져온 스킬의 `project/` 안 구조는 바꾸지 않는다. 폴더 안 파일을 위로 꺼내거나 다른 폴더와 섞지 않는다.
  - 까닭: `slop-rewrite` 의 스크립트는 루트를 자기 위치에서 위로 세어 계산한다(`check_all.py` 의 `parents[2]`, `register_guide.py`·`ingest_comments.py` 등의 `parents[4]`). 폴더 안 구조만 유지하면 저장소 위치와 상관없이 작동한다.
- 스킬 폴더를 가져올 때는 내부 구조 그대로 복사한다. 이미 있는 폴더를 통째로 덮어쓰지 않는다.
- `ai-agents/skills/<스킬>/project/.gitignore` 는 그대로 둔다. `slop-rewrite` 는 이 파일로 `taste/`(개인 코멘트)와 `.env` 를 막는다.

## 3. 새 스킬 추가 절차

1. 가져온 프로젝트를 `ai-agents/skills/<스킬 이름>/project/` 에 내부 구조 그대로 복사한다.
2. 스킬 안의 인수 테스트가 있으면 새 위치에서 돌려 통과를 확인한다. `slop-rewrite` 는 `ai-agents/skills/slop-rewrite/project` 에서 `python3 -X utf8 .claude/skills/slop-rewrite/tests/run_acceptance.py` 로 돌린다.
3. `ai-agents/skills/<스킬 이름>/SKILL.md` 진입 파일을 만든다. 형식은 아래 「진입 파일 형식」을 따른다.
4. 전역 연결(심볼릭 링크)은 사용자가 `scripts/install.sh --apply` 로 한다. 에이전트는 `--apply` 를 실행하지 않는다. 옵션 없이 실행하면 계획만 출력하므로 에이전트도 실행할 수 있다.

가져온 스킬이 표준 형식(폴더 바로 아래에 `SKILL.md` 가 있는 것)이면 래퍼 폴더 없이 `ai-agents/skills/<스킬 이름>/` 에 그대로 두고 3번은 건너뛴다.

### 진입 파일 형식

```
---
name: <스킬 이름>
description: <언제 이 스킬을 쓰는지와 트리거 문구>
---
본체는 이 폴더의 `project/<본체 SKILL.md 상대 경로>` 다. 그 파일을 읽고 따르며, 본체가 말하는 「프로젝트 루트」는 이 폴더의 `project/` 이고 상대 경로 명령은 거기서 돌린다. 원칙·스타일가이드·취향은 `project/` 안의 것을 쓴다.
```

- 경로는 모두 이 폴더 기준 상대경로로 쓴다. 사용자 이름이 든 절대경로는 쓰지 않는다.
- Claude·Codex·Antigravity 가 같은 `SKILL.md` 형식을 읽으므로 진입 파일은 도구마다 두지 않고 한 벌만 둔다.

## 4. 새 AI 도구 추가 절차

1. 그 도구의 공식 문서에서 전역 스킬 경로와 `SKILL.md` 형식을 확인한다. 2차 자료만으로 확정하지 않는다.
2. 그 도구에만 쓰는 스킬이 있으면 `ai-agents/<도구>/skills/` 에 둔다. 공통 스킬(`ai-agents/skills/`)은 그대로 쓴다.
3. 아래 5번 표에 도구를 추가하고, 확인한 것과 못 한 것을 구분해 적는다.
4. 전역 링크는 사용자가 건다.

## 5. 도구별 전역 경로

| 도구 | 링크가 걸리는 곳 | 저장소 안 원본 | 상태 |
|---|---|---|---|
| Claude | `~/.claude/skills/<스킬>` | `ai-agents/skills/<스킬>/` (전용은 `ai-agents/claude/skills/<스킬>/`) | 확인됨. 래퍼 폴더도 시험으로 인식 확인 |
| Codex | `~/.agents/skills/<스킬>` | `ai-agents/skills/<스킬>/` (전용은 `ai-agents/codex/skills/<스킬>/`) | 공식 문서 원문으로 확인(링크 폴더 지원 명시). 링크 인식은 시험 전 |
| Antigravity (앱·CLI) | `~/.gemini/config/skills/<스킬>` | `ai-agents/skills/<스킬>/` (전용은 `ai-agents/antigravity/skills/<스킬>/`) | 공식 문서로 확인. 링크 인식은 시험 전 |

- 이 표의 경로는 `scripts/targets.conf` 와 같아야 한다. 경로가 바뀌면 둘을 같이 고친다.
- Antigravity CLI 는 `~/.gemini/antigravity-cli/skills/` 와 `~/.gemini/skills/` 도 읽지만 앱은 읽지 않고 CLI 에서 우선순위가 가장 높다. 앱과 CLI 가 같이 쓰도록 `~/.gemini/config/skills/` 에 둔다.
- Antigravity 문서에 심볼릭 링크 지원 여부가 없다. 링크를 건 뒤 `agy` 의 `/skills` 로 로드를 확인한다.
- Antigravity IDE 는 쓰지 않는다.
- Gemini CLI 는 Antigravity CLI(`agy`)로 대체되어 다루지 않는다.
- `Gemini.app` 은 이 경로를 읽는지 확인하지 못했다.

## 6. 작업 규칙

- 커밋·push·삭제는 사용자가 말했을 때만 한다. 이전 승인은 다음 승인이 아니다.
- 비밀 정보(`.env`, 키, 토큰)는 읽거나 저장소에 올리지 않는다.
- 진입 파일이나 문서에 실명·이메일·사번을 넣지 않는다.

## 7. 지침과 스킬을 쓰거나 고칠 때

- 스킬(`SKILL.md`)이나 지침 파일(`AGENTS.md`, `CLAUDE.md`)을 새로 만들거나 고치거나 정리하는 요청을 받으면, 파일을 쓰기 전에 `docs/maintenance.md` 를 먼저 읽는다. README 수정과 코드 작성에는 읽지 않는다.
- 고칠 문서는 사본에서 먼저 고치고, 바뀐 줄을 보여 준 뒤 사용자 승인을 받아 반영한다.
- 전역 링크는 사용자가 `scripts/install.sh --apply` 로 만들고 바꾼다. 에이전트는 링크를 만들거나 바꾸지 않고 `--apply` 를 실행하지 않는다.
