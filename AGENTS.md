# ai-toolkit 작업 지침

이 저장소는 스킬과 AI 도구 설정을 모으는 개인 저장소다. 이 저장소에서 스킬이나 AI 도구를 추가·수정하는 에이전트는 아래를 따른다.

## 1. 구조

```
ai-toolkit/
├── skills/<스킬 이름>/              스킬 본체. 스킬마다 폴더 하나
├── ai-agents/
│   ├── AGENTS.md                    공통 지침 본체 (모든 도구가 읽는 개인 규칙)
│   └── <도구>/                      도구별 전역 진입 파일 원본
│       └── skills/<스킬 이름>/SKILL.md
├── docs/maintenance.md              지침·스킬을 쓰거나 고칠 때 읽는 안내
├── AGENTS.md                        이 문서
└── CLAUDE.md                        Claude 가 이 문서를 읽게 하는 한 줄
```

- 본체는 `skills/` 에만 둔다. 전역 진입 파일은 본체를 가리키기만 하고 내용을 복제하지 않는다.
- `ai-agents/<도구>/` 아래는 그 도구의 전역 폴더 구조를 따른다. 예: `ai-agents/claude/skills/` 는 `~/.claude/skills/` 에 대응한다.
- 최상위 폴더는 `skills/`, `ai-agents/`, `docs/` 로 유지한다. 도구가 늘어도 `ai-agents/` 안에서만 늘린다.
- 이 문서(루트 `AGENTS.md`)는 이 저장소에서 일하는 방법이고, `ai-agents/AGENTS.md` 는 모든 작업에 적용되는 개인 규칙이다. 두 문서를 섞지 않는다.

## 2. 건드리면 안 되는 것

- `skills/<스킬>/` 안의 구조는 바꾸지 않는다. 폴더 안 파일을 위로 꺼내거나 다른 폴더와 섞지 않는다.
  - 까닭: `skills/slop-rewrite/` 의 스크립트는 루트를 자기 위치에서 위로 세어 계산한다(`check_all.py` 의 `parents[2]`, `register_guide.py`·`ingest_comments.py` 등의 `parents[4]`). 폴더 안 구조만 유지하면 저장소 위치와 상관없이 작동한다.
- 스킬 폴더를 가져올 때는 내부 구조 그대로 복사한다. 이미 있는 폴더를 통째로 덮어쓰지 않는다.
- `skills/<스킬>/.gitignore` 는 그대로 둔다. `slop-rewrite` 는 이 파일로 `taste/`(개인 코멘트)와 `.env` 를 막는다.

## 3. 새 스킬 추가 절차

1. 본체를 `skills/<스킬 이름>/` 에 내부 구조 그대로 복사한다.
2. 스킬 안의 인수 테스트가 있으면 새 위치에서 돌려 통과를 확인한다. `slop-rewrite` 는 `skills/slop-rewrite` 에서 `python3 -X utf8 .claude/skills/slop-rewrite/tests/run_acceptance.py` 로 돌린다.
3. 도구마다 `ai-agents/<도구>/skills/<스킬 이름>/SKILL.md` 진입 파일 원본을 만든다. 형식은 아래 4번을 따른다.
4. 전역 연결(심볼릭 링크)은 사용자가 한다. 에이전트는 링크를 만들지 않는다.

### 진입 파일 형식

```
---
name: <스킬 이름>
description: <언제 이 스킬을 쓰는지와 트리거 문구>
---
본체는 `<ai-toolkit 절대경로>/skills/<스킬>/<본체 SKILL.md 상대 경로>` 다. 그 파일을 읽고 따르며, 상대 경로 명령은 `<ai-toolkit 절대경로>/skills/<스킬>` 에서 돌린다.
```

- `<ai-toolkit 절대경로>` 는 이 저장소를 가져온 실제 경로로 채운다. 문서에는 자리표시자로 둔다.
- `SKILL.md` 형식은 Claude·Codex·Antigravity 가 같아서 도구별 진입 파일 내용도 같다. 한 파일을 고치면 나머지 도구의 파일도 같이 고친다.

## 4. 새 AI 도구 추가 절차

1. 그 도구의 공식 문서에서 전역 스킬 경로와 `SKILL.md` 형식을 확인한다. 2차 자료만으로 확정하지 않는다.
2. `ai-agents/<도구>/` 를 만들고, 전역 폴더 구조를 그대로 따라 진입 파일 원본을 둔다.
3. 아래 5번 표에 도구를 추가하고, 확인한 것과 못 한 것을 구분해 적는다.
4. 전역 링크는 사용자가 건다.

## 5. 도구별 전역 경로

| 도구 | 링크가 걸리는 곳 | 저장소 안 원본 | 상태 |
|---|---|---|---|
| Claude | `~/.claude/skills/<스킬>` | `ai-agents/claude/skills/<스킬>/` | 확인됨 |
| Codex | `~/.agents/skills/<스킬>` | `ai-agents/codex/skills/<스킬>/` | 공식 문서 요약으로만 확인. 링크 인식은 시험 전 |
| Antigravity (앱·CLI) | `~/.gemini/config/skills/<스킬>` | `ai-agents/antigravity/skills/<스킬>/` | 공식 문서로 확인. 링크 인식은 시험 전 |

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
- 전역 링크는 사용자가 만들고 바꾼다. 에이전트는 링크를 만들거나 바꾸지 않는다.
