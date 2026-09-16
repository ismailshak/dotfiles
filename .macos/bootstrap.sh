#!/usr/bin/env bash

# shellcheck disable=SC2034
set -euo pipefail

cd "$(dirname "$0")"

USER_HOME="$HOME"
CODE_DIR="${CODE_DIR:-$USER_HOME/code}"
DOTFILES_REPO="ismailshak/dotfiles"

# mise reads the tool list from the /tmp checkout because ~/.config/mise is not linked until "dotfiles sync" and gh (a mise tool) is needed before that
MISE_GLOBAL_CONFIG_FILE="$(dirname "$PWD")/.config/mise/config.toml"
export MISE_GLOBAL_CONFIG_FILE
export PATH="$USER_HOME/.local/share/mise/shims:$USER_HOME/.local/bin:$PATH"

# shellcheck source=./.bootstrap/lib.sh
source ../.bootstrap/lib.sh

# shellcheck source=./.macos/modules/preflight.sh
source "modules/preflight.sh"
run_preflight

MODULES=(packages settings apps repos)

only=""
[[ ${1:-} == --only ]] && only=${2:-}

for m in "${MODULES[@]}"; do
  [[ -n $only && $m != "$only" ]] && continue
  # shellcheck source=/dev/null
  source "modules/${m}.sh"
  "run_${m}"
done

if [[ -z $only ]]; then
  phase "Manual steps"
  note "🔒 log into apps"
  note "🔋 restore the Alfred pack"
  note "🐘 restore the TablePlus license"
  note "🐳 install Docker Desktop"
fi

tty_ln ""
tty_ln "${c_green}All done 🚀${c_reset}  ${c_grey}log: $LOG_FILE${c_reset}"
