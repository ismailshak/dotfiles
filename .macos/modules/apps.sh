#!/usr/bin/env bash

CASK_MANIFEST="packages/casks.txt"
WEZTERM_ICON="/Applications/WezTerm.app/Contents/Resources/terminal.icns"

is_cask() { brew list --cask "$1" &>/dev/null; }

run_apps() {
  phase "Apps"
  while read -r cask; do
    step "cask: $cask" is_cask "$cask" -- brew install --cask "$cask"
  done < <(grep -vE '^[[:space:]]*(#|$)' "$CASK_MANIFEST")

  step "fonts" false -- make -C "$CODE_DIR/dotfiles" sync_fonts
  step "app icons" cmp -s "$CODE_DIR/dotfiles/icons/wezterm.icns" "$WEZTERM_ICON" -- make -C "$CODE_DIR/dotfiles" sync_icons
}
