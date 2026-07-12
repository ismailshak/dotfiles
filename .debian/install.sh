#!/usr/bin/env sh
#
# This script is intended to be run on a fresh Debian system to bootstrap the setup.
#
# Run it with:
# wget -qO- https://raw.githubusercontent.com/ismailshak/dotfiles/main/.debian/install.sh | sh

set -e

if [ "$(id -u)" -eq 0 ]; then
  echo "Do not run as root or with sudo"
  exit 1
fi

REPO_URL="https://github.com/ismailshak/dotfiles.git"
DEST="/tmp/dotfiles"

if ! command -v git >/dev/null 2>&1; then
  sudo apt-get update -qq && sudo apt-get install -y git
fi

git clone "$REPO_URL" "$DEST"
bash "$DEST/.debian/bootstrap.sh"
