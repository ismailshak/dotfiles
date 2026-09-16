#!/usr/bin/env sh

set -e

if [ "$(id -u)" -eq 0 ]; then
  echo "Do not run as root or with sudo (the Homebrew installer refuses to run as root)"
  exit 1
fi

if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
  echo "Finish the Xcode Command Line Tools install, then run this script again"
  exit 1
fi

REPO_URL="https://github.com/ismailshak/dotfiles.git"
DEST="/tmp/dotfiles"

if [ -d "$DEST/.git" ]; then
  git -C "$DEST" pull --ff-only
else
  git clone "$REPO_URL" "$DEST"
fi

bash "$DEST/.bootstrap/macos/bootstrap.sh"
