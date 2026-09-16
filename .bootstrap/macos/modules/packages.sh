#!/usr/bin/env bash

FORMULA_MANIFEST="packages/formulas.txt"
BREW="/opt/homebrew/bin/brew"
# shellcheck disable=SC2016
BREW_SHELLENV='eval "$(/opt/homebrew/bin/brew shellenv)"'
GH_SSH_KEY_PATH="$USER_HOME/.ssh/id_ed25519_github"

is_formula() { brew list --formula "$1" &>/dev/null; }

install_homebrew() {
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

add_brew_shellenv() {
  echo "$BREW_SHELLENV" >>"$USER_HOME/.zprofile"
}

install_mise() {
  curl -fsSL https://mise.run | sh
}

setup_gh_ssh() {
  mkdir -p "$USER_HOME/.ssh"
  chmod 700 "$USER_HOME/.ssh"
  ssh-keygen -t ed25519 -f "$GH_SSH_KEY_PATH" -N "" -C "github@$(hostname -s)"

  local ssh_config="$USER_HOME/.ssh/config"
  if ! grep -q "Host github.com" "$ssh_config" 2>/dev/null; then
    tee -a "$ssh_config" >/dev/null <<EOT

Host github.com
  IdentityFile $GH_SSH_KEY_PATH
  AddKeysToAgent yes
EOT
    chmod 600 "$ssh_config"
  fi

  gh ssh-key add "$GH_SSH_KEY_PATH.pub" --title "$(hostname -s)"
}

clone_dotfiles() {
  env GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" gh repo clone "$DOTFILES_REPO" "$CODE_DIR/dotfiles"
}

install_wezterm_terminfo() {
  local tmp
  tmp=$(mktempd)
  curl -fsSL https://raw.githubusercontent.com/wezterm/wezterm/main/termwiz/data/wezterm.terminfo -o "$tmp/terminfo"
  tic -x -o "$USER_HOME/.terminfo" "$tmp/terminfo"
}

run_packages() {
  phase "Packages & Tools"
  step "homebrew" test -x "$BREW" -- install_homebrew
  step "homebrew shellenv" grep -qsxF "$BREW_SHELLENV" "$USER_HOME/.zprofile" -- add_brew_shellenv
  eval "$("$BREW" shellenv)"

  while read -r pkg; do
    step "brew: $pkg" is_formula "$pkg" -- brew install "$pkg"
  done < <(grep -vE '^[[:space:]]*(#|$)' "$FORMULA_MANIFEST")

  step "mise" command -v mise -- install_mise
  step "mise tools" [ -z "$(mise ls --missing)" ] -- mise install
  note "check $LOG_FILE for the gh auth one-time code"
  step "gh auth" gh auth status -- gh auth login --skip-ssh-key --git-protocol ssh --web --scopes "admin:public_key"
  step "gh ssh" test -f "$GH_SSH_KEY_PATH" -- setup_gh_ssh
  step "dotfiles" test -d "$CODE_DIR/dotfiles" -- clone_dotfiles
  step "dotfiles sync" false -- make -C "$CODE_DIR/dotfiles" sync_dots
  step "wezterm terminfo" infocmp -x wezterm -- install_wezterm_terminfo
}
