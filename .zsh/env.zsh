# Sourced from ~/.zshenv, so it runs for EVERY zsh (including non-interactive
# `zsh -c` from skhd/launchd). Keep it to cheap env/PATH setup only: no output,
# no `eval "$(tool init)"`, nothing terminal-specific (e.g. TERM).

# mise shims, so tools like jq resolve in yabai/skhd scripts
export PATH="$HOME/.local/share/mise/shims:$PATH"

# Set default editor
export EDITOR="nvim"

# Use neovim as man pager
export MANPAGER="nvim +Man!"

# Add global tools OPAM switch to PATH (OCaml)
[ -d "$HOME/.opam/tools/bin" ] && export PATH="$PATH:$HOME/.opam/tools/bin"

# Add Cargo bin to PATH
[ -d "$HOME/.cargo/bin" ] && . "$HOME/.cargo/env"
