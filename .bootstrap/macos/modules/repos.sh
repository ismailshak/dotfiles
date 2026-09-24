#!/usr/bin/env bash

clone_repo() {
  env GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" gh repo clone "$1" "$CODE_DIR/${1#*/}"
}

link_nvim_config() {
  mkdir -p "$USER_HOME/.config"
  ln -s "$CODE_DIR/nvim" "$USER_HOME/.config/nvim"
}

run_repos() {
  phase "GitHub repos → $CODE_DIR"
  while read -r repo; do
    step "clone: ${repo#*/}" test -d "$CODE_DIR/${repo#*/}" -- clone_repo "$repo"
  done < <(gh repo list --no-archived --json nameWithOwner --jq '.[].nameWithOwner')

  step "neovim config" test -e "$USER_HOME/.config/nvim" -- link_nvim_config
  step "neovim plugins" false -- nvim --headless "+Lazy! restore" "+MasonToolsInstallSync" +qa
}
