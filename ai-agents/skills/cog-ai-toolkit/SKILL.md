---
name: cog-ai-toolkit
description: >-
  ai-toolkit 저장소에 스킬·지침(AGENTS.md)·작업 규칙을 새로 만들거나 고치거나 정리할 때 쓴다. 대화 중에 정리한 절차나 워크플로우를 스킬로 남기자는 요청, 기존 스킬·지침을 갱신하자는 요청, 새 AI 도구의 스킬 경로를 추가하는 요청에 쓴다. 예: "/cog-ai-toolkit", "이걸 스킬로 남겨 줘", "ai-toolkit 에 추가해 줘", "스킬 고쳐 줘". 스킬을 사용하는 일, 일반 코드 작성, 이 저장소와 무관한 문서 수정에는 쓰지 않는다.
---
# cog-ai-toolkit

이 스킬은 ai-toolkit 저장소를 고칠 때의 규칙과 절차를 담는다. 저장소 위치는 `~/.ai-toolkit` 이다. 이 경로가 없으면 사용자에게 `scripts/install_ai_toolkit.sh --apply` 실행을 요청한다.

## 지킬 것
- 커밋·push·삭제는 사용자가 말했을 때만 한다. 이전 승인은 다음 승인이 아니다.
- 비밀 정보(`.env`, 키, 토큰)와 실명·이메일·사번을 저장소에 넣지 않는다.
- 전역 링크는 사용자가 `scripts/install_ai_toolkit.sh --apply` 로 만든다. 에이전트는 링크를 만들거나 바꾸지 않고 `--apply` 를 실행하지 않는다. 옵션 없이 실행하면 계획만 출력하므로 에이전트도 실행할 수 있다.
- 가져온 스킬의 `project/` 안 구조는 바꾸지 않는다.

## 절차
1. 고칠 문서의 사본을 스크래치패드에 만들고 사본에서 먼저 고친다.
2. 도구별 공식 문서를 확인한다(`references/tools.md`).
3. 사본을 시험한다(`references/testing.md`).
4. 바뀐 줄을 사용자에게 보여 주고 승인받은 뒤 저장소 파일에 반영한다.
5. 반영 뒤 `references/tools.md` 의 확인 상태와 `references/decisions.md` 를 갱신한다.

## 다른 프로젝트에서 호출된 경우
1. 대화에서 스킬 이름(`cog-` 로 시작하는 소문자-하이픈), `description`, 단계를 뽑아 사본 초안을 만들어 보여 준다. 현재 작업 폴더에는 만들지 않는다.
2. 비밀 정보·개인정보·사내 정보가 없는지 확인해 알린다.
3. 사용자가 승인하면 `~/.ai-toolkit/ai-agents/skills/<이름>/` 에 쓴다. 저장소 밖 쓰기라 권한 승인이 필요하다.
4. 연결은 사용자가 `install_ai_toolkit.sh --apply` 로 한다. 호출 시험 뒤 커밋은 저장소에서 사용자가 말할 때만 한다.

## 무엇을 읽을지
| 상황 | 읽을 파일 |
|---|---|
| 구조, 이름 규칙, 건드리면 안 되는 것 | `references/structure.md` |
| 스킬을 만들거나 고칠 때 | `references/skills.md` |
| 지침 파일(AGENTS.md 등)을 고칠 때 | `references/instructions.md` |
| 시험하는 방법 | `references/testing.md` |
| 도구별 경로·호출 문법·새 도구 추가 | `references/tools.md` |
| 결정 이유와 아직 정하지 않은 것 | `references/decisions.md` |
