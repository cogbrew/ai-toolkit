#!/usr/bin/env bash
# =============================================================================
#  install_mac_setting.sh
#  새 Mac에서 터미널 환경을 한 번에 설정
#  (Oh My Zsh + 플러그인 + iTerm2/Ghostty 를 Catppuccin Mocha 로)
#
#  하는 일
#    1. Homebrew       : 없으면 설치 (macOS 패키지 관리자)
#    2. 앱              : iTerm2, Ghostty 가 없으면 brew 로 설치
#    3. CLI 도구        : autojump(`j 이름`으로 폴더 이동)
#                         glow(마크다운을 보기 좋게 렌더링)
#                         bat(cat + 문법 색상 + 줄 번호)
#    4. Oh My Zsh      : 없으면 설치 (zsh 플러그인/테마 관리 프레임워크)
#    5. zsh 플러그인    : zsh-autosuggestions(회색 자동완성 제안)
#                         zsh-syntax-highlighting(명령어 실시간 색상)
#    6. ~/.zshrc       : 새 Mac(Oh My Zsh 기본 파일)이면 정리된 구조로 새로 작성
#                         이미 직접 정리했거나 다른 설정이 있으면 plugins 줄만 맞춤
#    7. Ghostty 설정    : Catppuccin Mocha(VS Code 값) / Menlo 12 / Box 커서
#    8. iTerm2 설정     : 같은 값의 프로필 추가 + 기본 프로필로 지정
#
#  - 이미 설치된 항목은 건너뜁니다. (여러 번 실행해도 안전)
#  - Ghostty / iTerm2 설정 파일은 실행할 때마다 이 스크립트 내용으로 덮어씁니다.
#
#  사용법
#    bash install_mac_setting.sh
# =============================================================================
set -euo pipefail

FONT_NAME="Menlo"             # Ghostty 용 폰트 이름
ITERM_FONT="Menlo-Regular"    # iTerm2 용 (PostScript 이름)
FONT_SIZE=12
PLUGINS="git autojump zsh-autosuggestions zsh-syntax-highlighting"

log()  { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
info() { printf '    %s\n' "$*"; }
warn() { printf '\033[1;33m    ! %s\033[0m\n' "$*"; }

[ "$(uname -s)" = "Darwin" ] || { echo "macOS 전용 스크립트입니다."; exit 1; }

# -----------------------------------------------------------------------------
# 1. Homebrew
# -----------------------------------------------------------------------------
log "1/8 Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  info "Homebrew 가 없어 설치합니다. (관리자 비밀번호를 물어볼 수 있습니다)"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# Apple Silicon(/opt/homebrew) / Intel(/usr/local) 모두 대응
if   [ -x /opt/homebrew/bin/brew ]; then BREW_BIN=/opt/homebrew/bin/brew
elif [ -x /usr/local/bin/brew ];    then BREW_BIN=/usr/local/bin/brew
else BREW_BIN="$(command -v brew)"
fi
eval "$("$BREW_BIN" shellenv)"
info "brew: $BREW_BIN"

# -----------------------------------------------------------------------------
# 2. iTerm2 / Ghostty
# -----------------------------------------------------------------------------
log "2/8 iTerm2, Ghostty"
[ -d "/Applications/iTerm.app" ]   && info "iTerm2 이미 설치됨"  || brew install --cask iterm2
[ -d "/Applications/Ghostty.app" ] && info "Ghostty 이미 설치됨" || brew install --cask ghostty

# -----------------------------------------------------------------------------
# 3. CLI 도구
# -----------------------------------------------------------------------------
log "3/8 autojump, glow, bat"
for f in autojump glow bat; do
  brew list "$f" >/dev/null 2>&1 && info "$f 이미 설치됨" || brew install "$f"
done

# -----------------------------------------------------------------------------
# 4. Oh My Zsh
# -----------------------------------------------------------------------------
log "4/8 Oh My Zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
  info "이미 설치됨"
else
  # --unattended : 설치 후 zsh 로 바로 전환하지 않고 스크립트를 계속 진행
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# -----------------------------------------------------------------------------
# 5. zsh 플러그인 (Oh My Zsh custom 폴더에 받기)
# -----------------------------------------------------------------------------
log "5/8 zsh 플러그인"
clone_plugin() {  # $1=이름 $2=git 주소
  local dest="$ZSH_CUSTOM/plugins/$1"
  if [ -d "$dest" ]; then info "$1 이미 있음"
  else git clone --depth=1 "$2" "$dest" && info "$1 설치됨"
  fi
}
clone_plugin zsh-autosuggestions     https://github.com/zsh-users/zsh-autosuggestions
clone_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting

# -----------------------------------------------------------------------------
# 6. ~/.zshrc
#   A. 파일이 없거나 Oh My Zsh 기본 파일 그대로(새 Mac)  -> 정리된 구조로 새로 작성
#   B. 그 밖의 경우(직접 정리했거나 다른 설정이 있음)   -> 내용은 그대로 두고
#      plugins=(...) 에 필요한 플러그인만 추가 (syntax-highlighting 은 항상 맨 끝)
# -----------------------------------------------------------------------------
log "6/8 ~/.zshrc"
ZSHRC="$HOME/.zshrc"

if bat --list-themes 2>/dev/null | grep -qx "Catppuccin Mocha"; then
  BAT_LINE='export BAT_THEME="Catppuccin Mocha"'
else
  BAT_LINE='# export BAT_THEME="Catppuccin Mocha"   # 이 bat 버전에는 테마가 없어 비활성'
fi

is_omz_default() {  # 주석·빈 줄을 뺀 내용이 Oh My Zsh 기본 4줄뿐이면 참
  [ ! -s "$ZSHRC" ] && return 0
  ! grep -vE '^[[:space:]]*(#|$)' "$ZSHRC" \
    | grep -vqE '^(export ZSH=|ZSH_THEME=|plugins=\(|source \$ZSH/oh-my-zsh\.sh)'
}

if is_omz_default; then
  cat > "$ZSHRC" <<EOF
# ===== Homebrew =====
# brew 로 설치한 프로그램(brew, bat, glow 등)을 쓸 수 있도록 PATH 등록
eval "\$(${BREW_BIN} shellenv)"

# ===== 환경변수 / PATH =====
# bat 테마
${BAT_LINE}

# ===== Oh My Zsh =====
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# 새 플러그인은 zsh-syntax-highlighting 앞에 추가 (syntax-highlighting 은 항상 맨 끝)
plugins=(${PLUGINS})
source \$ZSH/oh-my-zsh.sh

# ===== 도구 초기화 =====
# eval "\$(도구 init zsh)" 같은 줄은 여기에

# ===== 개인 설정 (alias 등) =====
EOF
  info "정리된 구조로 새로 작성했습니다."
else
  info "기존 설정이 있어 내용은 그대로 두고 plugins 만 맞춥니다."
  if grep -qE '^plugins=\(' "$ZSHRC"; then
    current=$(awk '/^plugins=\(/{f=1} f{print} f&&/\)/{exit}' "$ZSHRC" \
              | tr '\n' ' ' | sed -E 's/.*plugins=\(([^)]*)\).*/\1/')
    list=()
    for p in $current; do
      [ "$p" = "zsh-syntax-highlighting" ] || list+=("$p")
    done
    for p in git autojump zsh-autosuggestions; do
      [[ " ${list[*]-} " == *" $p "* ]] || list+=("$p")
    done
    list+=("zsh-syntax-highlighting")
    newline="plugins=(${list[*]})"

    if [ "$(awk '/^plugins=\(/{f=1} f{print} f&&/\)/{exit}' "$ZSHRC" | tr '\n' ' ' | sed 's/ *$//')" = "$newline" ]; then
      info "plugins 변경 없음: $newline"
    else
      tmp="$(mktemp)"
      awk -v nl="$newline" '
        skip==1 { if ($0 ~ /\)/) skip=0; next }
        /^plugins=\(/ && done!=1 { print nl; done=1; if ($0 !~ /\)/) skip=1; next }
        { print }
      ' "$ZSHRC" > "$tmp"
      cat "$tmp" > "$ZSHRC"
      rm -f "$tmp"
      info "plugins 적용: $newline"
    fi
  else
    warn "~/.zshrc 에 plugins=(...) 줄이 없습니다. 아래 줄을 직접 추가해 주세요."
    warn "plugins=(${PLUGINS})"
  fi

  if ! grep -q 'BAT_THEME=' "$ZSHRC"; then
    warn "BAT_THEME 이 없습니다. '환경변수 / PATH' 구역에 아래 줄을 추가해 주세요."
    warn "$BAT_LINE"
  fi
fi

# -----------------------------------------------------------------------------
# 7. Ghostty 설정
#    색상은 VS Code "Catppuccin Mocha" 의 terminal.* 값에서 추출
# -----------------------------------------------------------------------------
log "7/8 Ghostty 설정"
GHOSTTY_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
GHOSTTY_CFG="$GHOSTTY_DIR/config.ghostty"
mkdir -p "$GHOSTTY_DIR"
cat > "$GHOSTTY_CFG" <<EOF
# Ghostty config  (install_mac_setting.sh 로 생성)
# Colors: VS Code "Catppuccin Mocha" 터미널 값에서 추출

theme = Catppuccin Mocha

# --- Font ---
font-family = ${FONT_NAME}
font-size = ${FONT_SIZE}
# Menlo 를 VS Code / iTerm2 와 비슷한 굵기로 (0~255, 기본 255)
font-thicken = true
font-thicken-strength = 64

# --- VS Code 터미널 동작 맞추기 ---
minimum-contrast = 4.5
bold-is-bright = true

# --- Cursor: iTerm2 Box 와 동일 (깜빡임은 Ghostty 기본값 = 켜짐) ---
cursor-style = block

# --- Colors (VS Code terminal.* 값) ---
background = #1e1e2e
foreground = #cdd6f4
cursor-color = #f5e0dc
cursor-text = #1e1e2e
selection-background = #585b70
selection-foreground = #cdd6f4

palette = 0=#45475a
palette = 1=#f38ba8
palette = 2=#a6e3a1
palette = 3=#f9e2af
palette = 4=#89b4fa
palette = 5=#f5c2e7
palette = 6=#94e2d5
palette = 7=#a6adc8
palette = 8=#585b70
palette = 9=#f37799
palette = 10=#89d88b
palette = 11=#ebd391
palette = 12=#74a8fc
palette = 13=#f2aede
palette = 14=#6bd7ca
palette = 15=#bac2de

# no-cursor: 프롬프트에서 커서를 세로 막대로 바꾸지 않음
shell-integration-features = no-cursor,ssh-env,ssh-terminfo
EOF
info "작성: $GHOSTTY_CFG"

# -----------------------------------------------------------------------------
# 8. iTerm2 설정 (Dynamic Profile)
#    Dynamic Profiles 폴더에 JSON 을 두면 iTerm2 가 자동으로 프로필을 읽어 옵니다.
#    - Font Menlo 12 / Use bold font / Brighten bold text
#    - Thin strokes: Never / Cursor: Box / Minimum contrast: 0
# -----------------------------------------------------------------------------
log "8/8 iTerm2 프로필"
ITERM_BASE="$HOME/Library/Application Support/iTerm2"
ITERM_DIR="$ITERM_BASE/DynamicProfiles"
ITERM_JSON="$ITERM_DIR/catppuccin-mocha-vscode.json"
PROFILE_GUID="catppuccin-mocha-vscode"
mkdir -p "$ITERM_DIR"

c() {  # hex -> iTerm2 색상 JSON
  local h="${1#\#}"
  LC_ALL=C awk -v r=$((16#${h:0:2})) -v g=$((16#${h:2:2})) -v b=$((16#${h:4:2})) 'BEGIN{
    printf "{\"Red Component\":%.6f,\"Green Component\":%.6f,\"Blue Component\":%.6f,\"Alpha Component\":1,\"Color Space\":\"sRGB\"}", r/255, g/255, b/255 }'
}
PALETTE=(45475a f38ba8 a6e3a1 f9e2af 89b4fa f5c2e7 94e2d5 a6adc8
         585b70 f37799 89d88b ebd391 74a8fc f2aede 6bd7ca bac2de)

# iTerm2 는 DynamicProfiles 폴더를 실시간으로 감시합니다.
# 폴더 안에 직접 쓰면 '쓰는 도중'의 미완성 파일을 읽고 JSON 오류를 띄우므로,
# 감시하지 않는 상위 폴더에서 다 쓴 뒤 한 번에 옮깁니다. (mv 는 원자적)
ITERM_TMP="$(mktemp "$ITERM_BASE/catppuccin.XXXXXX")"
{
  echo '{ "Profiles": [ {'
  echo "  \"Name\": \"Catppuccin Mocha (VSCode)\","
  echo "  \"Guid\": \"$PROFILE_GUID\","
  echo "  \"Normal Font\": \"${ITERM_FONT} ${FONT_SIZE}\","
  echo '  "Use Bold Font": true,'
  echo '  "Use Bright Bold": true,'
  echo '  "Thin Strokes": 0,'
  echo '  "Cursor Type": 2,'
  echo '  "Minimum Contrast": 0,'
  for i in "${!PALETTE[@]}"; do
    echo "  \"Ansi $i Color\": $(c "${PALETTE[$i]}"),"
  done
  echo "  \"Background Color\": $(c 1e1e2e),"
  echo "  \"Foreground Color\": $(c cdd6f4),"
  echo "  \"Bold Color\": $(c cdd6f4),"
  echo "  \"Cursor Color\": $(c f5e0dc),"
  echo "  \"Cursor Text Color\": $(c 1e1e2e),"
  echo "  \"Selection Color\": $(c 585b70),"
  echo "  \"Selected Text Color\": $(c cdd6f4),"
  echo "  \"Link Color\": $(c 89b4fa)"
  echo '} ] }'
} > "$ITERM_TMP"

# JSON 검사: macOS 기본 내장 JavaScript(osascript)의 JSON.parse 사용
# (plutil -lint 는 plist 검사기라 JSON 을 검사하지 못함)
json_ok() {
  osascript -l JavaScript - "$1" >/dev/null 2>&1 <<'JS'
ObjC.import('Foundation');
function run(argv) {
  JSON.parse($.NSString.stringWithContentsOfFileEncodingError(argv[0], $.NSUTF8StringEncoding, null).js);
}
JS
}

if json_ok "$ITERM_TMP"; then
  mv -f "$ITERM_TMP" "$ITERM_JSON"
  info "작성: $ITERM_JSON"
else
  warn "iTerm2 프로필 JSON 이 올바르지 않아 적용하지 않았습니다: $ITERM_TMP"
  exit 1
fi

# 기본 프로필 지정: iTerm2 가 실행 중이면 종료 시 설정을 덮어쓰므로 건너뜀
if pgrep -x iTerm2 >/dev/null 2>&1; then
  warn "iTerm2 가 실행 중이라 기본 프로필 지정은 건너뜁니다."
  warn "iTerm2 > Settings > Profiles 에서 'Catppuccin Mocha (VSCode)' 선택 후"
  warn "Other Actions... > Set as Default 를 눌러 주세요."
else
  defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "$PROFILE_GUID"
  info "기본 프로필로 지정했습니다."
fi

# -----------------------------------------------------------------------------
log "완료"
info "터미널을 새로 열거나 'exec zsh' 를 실행하면 적용됩니다."
info "마크다운 읽기: glow README.md   /   코드 읽기: bat 파일명"
