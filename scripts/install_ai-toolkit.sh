#!/usr/bin/env bash
# ai-toolkit 연결 스크립트
#   - 도구별 전역 스킬 폴더에 스킬을 하나씩 링크한다(폴더 전체는 링크하지 않는다).
#   - 공통 지침(ai-agents/AGENTS.md)을 도구별 전역 지침 파일에 링크한다.
#   - 별칭 ~/.ai-toolkit 을 이 저장소로 링크한다.
# 기본은 계획만 출력한다(dry-run). --apply 를 줘야 실제로 만든다.
# 삭제 명령은 쓰지 않는다. 이미 있는 항목은 덮어쓰지 않고, --backup 을 주면 옮겨 두고 연결한다.

set -u

usage() {
  cat <<'EOF'
사용법: scripts/install_ai-toolkit.sh [--apply] [--backup]
  (옵션 없음)  계획만 출력한다(dry-run).
  --apply      계획대로 링크를 만든다.
  --backup     충돌한 기존 항목을 ~/.ai-toolkit-backup/<시각>/ 로 옮긴 뒤 연결한다.
  -h, --help   이 도움말을 보여 준다.
같은 명령을 다시 실행해도 결과가 같다. 이미 있는 항목은 덮어쓰지 않는다.
EOF
}

MODE="dry-run"
BACKUP=0
for arg in "$@"; do
  case "$arg" in
    --apply) MODE="apply" ;;
    --dry-run) MODE="dry-run" ;;
    --backup) BACKUP=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "알 수 없는 옵션: $arg" >&2; usage >&2; exit 1 ;;
  esac
done

if [ -z "${HOME:-}" ]; then
  echo "HOME 이 비어 있어 중단한다." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT="$(dirname "$SCRIPT_DIR")"
CONF="$SCRIPT_DIR/targets.conf"

if [ ! -d "$ROOT/ai-agents/skills" ]; then
  echo "저장소 구조가 맞지 않는다: $ROOT/ai-agents/skills 가 없다." >&2
  exit 1
fi
if [ ! -f "$CONF" ]; then
  echo "설정 파일이 없다: $CONF" >&2
  exit 1
fi

say() { printf '%s\n' "$*"; }

trim() { printf '%s' "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'; }

expand_path() {
  case "$1" in
    "~") printf '%s' "$HOME" ;;
    "~/"*) printf '%s' "$HOME/${1#"~/"}" ;;
    *) printf '%s' "$1" ;;
  esac
}

# ---- 설정 읽기 -------------------------------------------------------------
T_NAME=(); T_EN=(); T_SKILLS=(); T_INSTR=(); T_DIR=(); T_RES=()
N=0
while IFS= read -r raw || [ -n "$raw" ]; do
  line="${raw%%#*}"
  line="$(trim "$line")"
  [ -z "$line" ] && continue
  case "$line" in
    "["*"]")
      name="${line#\[}"; name="${name%\]}"
      T_NAME[$N]="$name"; T_EN[$N]="true"; T_SKILLS[$N]=""; T_INSTR[$N]=""; T_DIR[$N]=""; T_RES[$N]=""
      N=$((N + 1))
      ;;
    *=*)
      [ "$N" -eq 0 ] && continue
      key="$(trim "${line%%=*}")"
      val="$(trim "${line#*=}")"
      i=$((N - 1))
      case "$key" in
        enabled) T_EN[$i]="$val" ;;
        skills) T_SKILLS[$i]="$val" ;;
        instruction) T_INSTR[$i]="$val" ;;
        dir) T_DIR[$i]="$val" ;;
        reserved) T_RES[$i]="$val" ;;
      esac
      ;;
  esac
done < "$CONF"

# ---- 링크 만들기 -----------------------------------------------------------
N_NEW=0; N_OK=0; N_CONFLICT=0; N_BACKUP=0; N_SKIP=0
PLANNED_DIRS="|"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$HOME/.ai-toolkit-backup/$STAMP"

describe_existing() {
  if [ -L "$1" ]; then
    printf '링크 → %s' "$(readlink "$1")"
  elif [ -d "$1" ]; then
    printf '폴더'
  else
    printf '파일'
  fi
}

# $1=링크가 가리킬 곳(저장소 안) $2=링크를 만들 위치 $3=출력용 이름
link_item() {
  local target="$1" dest="$2" label="$3" cur parent bname
  if [ -L "$dest" ]; then
    cur="$(readlink "$dest")"
    if [ "$cur" = "$target" ]; then
      say "  이미 연결됨        $label"
      N_OK=$((N_OK + 1))
      return 0
    fi
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ "$BACKUP" -eq 1 ]; then
      if [ "$MODE" = "apply" ]; then
        case "$dest" in
          "$HOME"/*) bname="home__$(printf '%s' "${dest#"$HOME"/}" | sed -e 's#/#__#g')" ;;
          *) bname="abs__$(printf '%s' "$dest" | sed -e 's#^/##' -e 's#/#__#g')" ;;
        esac
        if mkdir -p "$BACKUP_DIR" && mv "$dest" "$BACKUP_DIR/$bname"; then
          say "  백업               $dest → $BACKUP_DIR/$bname"
          N_BACKUP=$((N_BACKUP + 1))
        else
          say "  실패(백업)         $label"
          N_CONFLICT=$((N_CONFLICT + 1))
          return 1
        fi
      else
        say "  백업 후 연결 예정  $label  (기존: $(describe_existing "$dest"))"
        N_NEW=$((N_NEW + 1))
        return 0
      fi
    else
      say "  충돌(덮어쓰지 않음) $label  (기존: $(describe_existing "$dest"))"
      N_CONFLICT=$((N_CONFLICT + 1))
      return 0
    fi
  fi
  parent="$(dirname "$dest")"
  if [ "$MODE" = "apply" ]; then
    if mkdir -p "$parent" && ln -s "$target" "$dest"; then
      say "  연결               $label"
      N_NEW=$((N_NEW + 1))
    else
      say "  실패               $label"
      N_CONFLICT=$((N_CONFLICT + 1))
      return 1
    fi
  else
    if [ ! -d "$parent" ]; then
      case "$PLANNED_DIRS" in
        *"|$parent|"*) ;;
        *) say "  폴더 생성 예정     $parent"; PLANNED_DIRS="$PLANNED_DIRS$parent|" ;;
      esac
    fi
    say "  연결 예정          $label"
    N_NEW=$((N_NEW + 1))
  fi
}

is_reserved() { # $1=이름 $2=쉼표로 구분한 예약 이름
  local n="$1" list="$2" r old_ifs="$IFS"
  IFS=','
  for r in $list; do
    r="$(trim "$r")"
    if [ -n "$r" ] && [ "$r" = "$n" ]; then IFS="$old_ifs"; return 0; fi
  done
  IFS="$old_ifs"
  return 1
}

# $1=저장소 안 스킬 폴더 $2=도구의 전역 스킬 폴더 $3=예약 이름
link_skills_from() {
  local src="$1" dst="$2" reserved="$3" d name
  [ -d "$src" ] || return 0
  for d in "$src"/*/; do
    [ -d "$d" ] || continue
    d="${d%/}"
    name="$(basename "$d")"
    if [ ! -f "$d/SKILL.md" ]; then
      say "  건너뜀             $name (폴더 바로 아래에 SKILL.md 가 없음)"
      N_SKIP=$((N_SKIP + 1))
      continue
    fi
    if is_reserved "$name" "$reserved"; then
      say "  건너뜀             $name (이 도구의 예약 이름)"
      N_SKIP=$((N_SKIP + 1))
      continue
    fi
    link_item "$d" "$dst/$name" "$dst/$name → $d"
  done
}

# ---- 실행 ------------------------------------------------------------------
say "저장소: $ROOT"
say "모드:   $MODE$([ "$BACKUP" -eq 1 ] && printf ' + backup')"
say ""

say "[이름 규칙 점검]"
for d in "$ROOT/ai-agents/skills"/*/; do
  [ -d "$d" ] || continue
  d="${d%/}"; name="$(basename "$d")"
  case "$name" in
    cog-*) ;;
    *) say "  참고               $name (cog- 접두사 없음: 가져온 스킬로 본다)" ;;
  esac
done
say ""

say "[별칭]"
link_item "$ROOT" "$HOME/.ai-toolkit" "$HOME/.ai-toolkit → $ROOT"
say ""

i=0
while [ "$i" -lt "$N" ]; do
  tool="${T_NAME[$i]}"
  if [ "${T_EN[$i]}" != "true" ]; then
    say "[$tool] 사용 안 함(enabled = ${T_EN[$i]})"
    say ""
    i=$((i + 1))
    continue
  fi
  say "[$tool]"
  skills_dst="$(expand_path "${T_SKILLS[$i]}")"
  if [ -n "$skills_dst" ]; then
    link_skills_from "$ROOT/ai-agents/skills" "$skills_dst" "${T_RES[$i]}"
    if [ -n "${T_DIR[$i]}" ]; then
      link_skills_from "$ROOT/ai-agents/${T_DIR[$i]}/skills" "$skills_dst" "${T_RES[$i]}"
    fi
  else
    say "  건너뜀             스킬 폴더가 설정되지 않음"
  fi
  if [ -n "${T_INSTR[$i]}" ]; then
    instr_dst="$(expand_path "${T_INSTR[$i]}")"
    link_item "$ROOT/ai-agents/AGENTS.md" "$instr_dst" "$instr_dst → $ROOT/ai-agents/AGENTS.md"
  else
    say "  건너뜀             지침 파일이 설정되지 않음"
  fi
  say ""
  i=$((i + 1))
done

LBL_NEW="연결(예정)"
[ "$MODE" = "apply" ] && LBL_NEW="연결"
say "요약: $LBL_NEW $N_NEW · 이미 연결됨 $N_OK · 충돌 $N_CONFLICT · 백업 $N_BACKUP · 건너뜀 $N_SKIP"
if [ "$MODE" != "apply" ]; then
  say "계획만 출력했다. 실제로 만들려면 --apply 를 붙인다."
fi
if [ "$N_CONFLICT" -gt 0 ]; then
  say "충돌한 항목은 건드리지 않았다. 옮겨 두고 연결하려면 --apply --backup 을 쓴다."
  exit 2
fi
exit 0
