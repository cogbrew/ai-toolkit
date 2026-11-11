# 구조와 이름 규칙

## 용어
이 스킬의 문서는 아래 뜻으로만 용어를 쓴다.
- 본체: 가져온 프로젝트 전체. 래퍼 폴더의 `project/` 에 둔다.
- 래퍼 폴더(wrapper): 폴더 바로 아래에 `SKILL.md` 가 없는 가져온 스킬을 `project/` 로 담고 진입 파일을 곁에 둔 스킬 폴더. 위치는 `ai-agents/skills/<스킬>/` 다.
- 진입 파일: 래퍼 폴더 안에서 `project/` 의 본체를 가리키는 짧은 `SKILL.md`.
- 사본: 고치기 전에 스크래치패드에 만든 복사본.
- 확인: 공식 문서나 파일을 읽어 사실을 알아내는 일.
- 시험: 실제로 실행해 동작을 관찰하는 일.

## 구조

```
ai-toolkit/
├── README.md                        사람용 소개
├── AGENTS.md, CLAUDE.md             이 저장소를 고칠 때 cog-ai-toolkit 을 쓰라는 안내
├── ai-agents/
│   ├── AGENTS.md                    공통 지침 (모든 도구가 읽는 개인 규칙)
│   ├── skills/                      모든 도구에 연결하는 스킬. 폴더 하나가 스킬 하나
│   │   ├── cog-ai-toolkit/          이 저장소의 유지보수 스킬
│   │   ├── cog-<스킬 이름>/SKILL.md 직접 만든 스킬
│   │   └── <가져온 스킬>/           래퍼 폴더
│   │       ├── SKILL.md             진입 파일(project/ 를 가리킴)
│   │       └── project/             가져온 프로젝트 전체, 내부 구조 그대로
│   └── <도구>/skills/<스킬 이름>/   그 도구에만 연결하는 전용 스킬
└── scripts/                         install.sh(전역 연결), targets.conf(도구별 경로 표)
```

- 스킬은 `ai-agents/skills/` 에 둔다. 폴더 하나를 도구의 전역 스킬 폴더에 그대로 링크하며, 래퍼 폴더의 진입 파일은 `project/` 를 가리키기만 하고 내용을 복제하지 않는다.
- `ai-agents/<도구>/skills/` 에는 그 도구에만 쓰는 스킬을 둔다. 모든 도구가 쓰는 스킬은 `ai-agents/skills/` 에 둔다.
- 이름 규칙: 직접 만든 스킬은 폴더 이름과 `name` 을 `cog-` 로 시작하는 소문자-하이픈으로 정한다. 가져온 스킬은 이름을 바꾸지 않는다. 접두사가 없으면 가져온 스킬이다.
- 최상위 폴더는 `ai-agents/`, `scripts/` 로 유지한다. 도구가 늘어도 `ai-agents/` 안에서만 늘린다.
- 루트 `AGENTS.md` 는 이 저장소를 고칠 때 `cog-ai-toolkit` 을 쓰라는 안내이고, `ai-agents/AGENTS.md` 는 모든 작업에 적용되는 개인 규칙이다. 두 문서를 섞지 않는다.

## 건드리면 안 되는 것

- 가져온 스킬의 `project/` 안 구조는 바꾸지 않는다. 폴더 안 파일을 위로 꺼내거나 다른 폴더와 섞지 않는다.
  - 까닭: `slop-rewrite` 의 스크립트는 루트를 자기 위치에서 위로 세어 계산한다(`check_all.py` 의 `parents[2]`, `register_guide.py`·`ingest_comments.py` 등의 `parents[4]`). 폴더 안 구조만 유지하면 저장소 위치와 상관없이 작동한다.
- 스킬 폴더를 가져올 때는 내부 구조 그대로 복사한다. 이미 있는 폴더를 통째로 덮어쓰지 않는다.
- `ai-agents/skills/<스킬>/project/.gitignore` 는 그대로 둔다. `slop-rewrite` 는 이 파일로 `taste/`(개인 코멘트)와 `.env` 를 막는다.
