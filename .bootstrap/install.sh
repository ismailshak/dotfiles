#!/usr/bin/env sh
#
# Clones this repo to /tmp/dotfiles and runs the bootstrap for the current OS.
# Arguments are passed to bootstrap.sh: append `-s -- --only <module>` to the `sh` below to run one module.
#
# macOS:  curl -fsSL https://raw.githubusercontent.com/ismailshak/dotfiles/main/.bootstrap/install.sh | sh
# Debian: wget -qO- https://raw.githubusercontent.com/ismailshak/dotfiles/main/.bootstrap/install.sh | sh

set -e

REPO_URL="https://github.com/ismailshak/dotfiles.git"
DEST="/tmp/dotfiles"

# The Homebrew installer doesn't allow running as root and the debian bootstrap sets up the current user
if [ "$(id -u)" -eq 0 ]; then
  echo "Do not run as root or with sudo"
  exit 1
fi

case "$(uname -s)" in
Darwin)
  platform=macos
  # Needed primarily for git
  if ! xcode-select -p >/dev/null 2>&1; then
    xcode-select --install
    echo "Finish the Xcode Command Line Tools install, then run this script again"
    exit 1
  fi
  ;;
Linux)
  if [ ! -f /etc/debian_version ]; then
    echo "Unsupported Linux distribution: only Debian has a bootstrap"
    exit 1
  fi
  platform=debian
  if ! command -v git >/dev/null 2>&1; then
    sudo apt-get update -qq && sudo apt-get install -y git
  fi
  ;;
*)
  echo "Unsupported OS: $(uname -s)"
  exit 1
  ;;
esac

if [ -d "$DEST/.git" ]; then
  git -C "$DEST" pull --ff-only
else
  git clone "$REPO_URL" "$DEST"
fi

bash "$DEST/.bootstrap/$platform/bootstrap.sh" "$@"
