# 도구별 경로와 호출 문법

## 새 AI 도구를 추가하는 절차

1. 그 도구의 공식 문서에서 전역 스킬 경로와 `SKILL.md` 형식을 확인한다. 2차 자료만으로 확정하지 않는다.
2. 그 도구에만 쓰는 스킬이 있으면 `ai-agents/<도구>/skills/` 에 둔다. 공통 스킬(`ai-agents/skills/`)은 그대로 쓴다.
3. 아래 표와 `scripts/targets.conf` 에 도구를 추가하고, 확인한 것과 못 한 것을 구분해 적는다.
4. 전역 링크는 사용자가 건다.

## 도구별 전역 경로

| 도구 | 링크가 걸리는 곳 | 저장소 안 원본 | 상태 |
|---|---|---|---|
| Claude | `~/.claude/skills/<스킬>` | `ai-agents/skills/<스킬>/` (전용은 `ai-agents/claude/skills/<스킬>/`) | 확인됨. 래퍼 폴더도 시험으로 인식 확인 |
| Codex | `~/.agents/skills/<스킬>` | `ai-agents/skills/<스킬>/` (전용은 `ai-agents/codex/skills/<스킬>/`) | 공식 문서 원문으로 확인(링크 폴더 지원 명시). 링크로 건 `~/.codex/AGENTS.md` 의 전역 지침 적용을 확인함(커밋 규칙을 묻자 지침대로 답함, 2026-11-11, 1회). `/skills` 에 스킬 7개가 표시됨(6개는 캡처로, `slop-rewrite` 는 사용자가 확인했다고 알려 옴, 2026-11-11, 1회). 2026-11-13 에 `/skills` → `1. List skills` 목록에서 `cog-llm-wiki` 를 포함한 직접 만든 스킬 7개와 `slop-rewrite` 가 표시됨을 확인함(1회). `cog-llm-wiki` 로 직접 호출(`$cog-llm-wiki`), 한국어 자동 호출, 빈 폴더에서의 위치 확인이 동작함(기본 모델 GPT-6-Luna, `codex exec`, 각 1회) |
| Antigravity (앱·CLI) | `~/.gemini/config/skills/<스킬>` | `ai-agents/skills/<스킬>/` (전용은 `ai-agents/antigravity/skills/<스킬>/`) | 공식 문서로 확인. 링크로 건 스킬 7개가 `agy` 의 `/skills` 에 표시됨(2026-11-11, 사용자 화면으로 1회 확인). 2026-11-13 에 `cog-llm-wiki` 가 `/skills` 에 표시되고, 직접 호출(`/cog-llm-wiki`), 한국어 자동 호출, 빈 폴더에서의 위치 확인이 동작함(Gemini 4 Argon medium, 대화형, 각 1회). 워크스페이스 밖의 스킬 파일을 읽을 때 파일 접근 승인 창이 뜸 |

- 이 표의 경로는 `scripts/targets.conf` 와 같아야 한다. 경로가 바뀌면 둘을 같이 고친다.
- Antigravity CLI 는 `~/.gemini/antigravity-cli/skills/` 와 `~/.gemini/skills/` 도 읽지만 앱은 읽지 않고 CLI 에서 우선순위가 가장 높다. 앱과 CLI 가 같이 쓰도록 `~/.gemini/config/skills/` 에 둔다.
- Antigravity 문서에 심볼릭 링크 지원 여부가 없지만 `~/.gemini/config/skills` 의 링크 스킬은 `agy` 의 `/skills` 에 표시됐다. 직접 호출과 자동 호출은 `cog-llm-wiki` 로 시험했다(위 표). `agy` 가 새 스킬을 만들 때의 위치는 `~/.gemini/antigravity-cli/skills/` 이며 `config/skills` 가 아니다.
- Antigravity IDE 는 쓰지 않는다.
- Antigravity 전역 지침 파일은 `~/.gemini/AGENTS.md` 로 연결한다(2026-11 공식 문서 `antigravity.google/docs/rules` 확인). 앱, CLI, IDE 가 모두 읽는 경로이고 규칙은 합산된다. 파일당 24,000바이트와 전체 20,000토큰 예산이 있다. 심볼릭 링크 지원 여부는 문서에 없지만 링크로 연결한 파일을 `agy` 가 전역 지침(`user_global`)으로 읽는 것을 확인했다(2026-11-11, 1회).
- Gemini CLI 는 Antigravity CLI(`agy`)로 대체되어 다루지 않는다.
- `Gemini.app` 은 이 경로를 읽는지 확인하지 못했다.

## 스킬 직접 호출 문법

| 도구 | 문법 | 근거 |
|---|---|---|
| Claude Code | `/cog-ai-toolkit` (메시지 맨 앞에 이름) | 공식 문서 |
| Codex | `$cog-ai-toolkit` 또는 `/skills` 에서 선택 | 공식 문서 |
| Antigravity | `/cog-ai-toolkit` | 공식 문서 |

- `@cog-ai-toolkit` 은 세 도구의 스킬 문서에 나오지 않는다. Claude 에서 `@` 는 파일 지정에 쓰인다.
- 세 도구에서의 직접 호출은 `cog-llm-wiki` 로 시험했다(Claude, Codex `$cog-llm-wiki`, Antigravity `/cog-llm-wiki`). 다른 스킬로는 시험하지 않았다.
- Codex 에서 `/skills` 목록 창을 연 뒤 입력란에 `$` 가 남아 있으면 `$$이름` 으로 입력된다. 입력란을 비우고 호출한다.
