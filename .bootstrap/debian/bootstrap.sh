#!/usr/bin/env bash
# .bootstrap/debian/bootstrap.sh - bootstrap a new Debian server
#
# (initiated by install.sh)

# shellcheck disable=SC2034
set -euo pipefail

cd "$(dirname "$0")"

APPS_USER="apps"
APPS_DIR="/home/${APPS_USER}"
USERNAME="$(whoami)"
USER_HOME="$(getent passwd "$USERNAME" | cut -d: -f6)"
CODE_DIR="${CODE_DIR:-$USER_HOME/code}"
DOTFILES_REPO="ismailshak/dotfiles"

# mise reads the tool list from the /tmp checkout because ~/.config/mise is not linked until "dotfiles sync" and gh (a mise tool) is needed before that
REPO_DIR="$(cd ../.. && pwd)"
MISE_GLOBAL_CONFIG_FILE="$REPO_DIR/.config/mise/config.toml"
export MISE_GLOBAL_CONFIG_FILE
export PATH="$USER_HOME/.local/share/mise/shims:$PATH"

# shellcheck source=./.bootstrap/lib.sh
source ../lib.sh

# Modules run in this order
MODULES=(packages users access secrets apps health backups)

run_modules "$@"
