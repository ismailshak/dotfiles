#!/usr/bin/env bash

# shellcheck disable=SC2034
set -euo pipefail

cd "$(dirname "$0")"

USER_HOME="$HOME"
CODE_DIR="${CODE_DIR:-$USER_HOME/code}"
DOTFILES_REPO="ismailshak/dotfiles"

# mise reads the tool list from the /tmp checkout because ~/.config/mise is not linked until "dotfiles sync" and gh (a mise tool) is needed before that
REPO_DIR="$(cd ../.. && pwd)"
MISE_GLOBAL_CONFIG_FILE="$REPO_DIR/.config/mise/config.toml"
export MISE_GLOBAL_CONFIG_FILE
export PATH="$USER_HOME/.local/share/mise/shims:$USER_HOME/.local/bin:$PATH"

# shellcheck source=./.bootstrap/lib.sh
source ../lib.sh

# Modules run in this order
MODULES=(packages settings apps repos manual)

run_modules "$@"
