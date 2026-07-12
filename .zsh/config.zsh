# ========================
# Custom ZSH configuration
# ========================
#
# Run this to symlink this file to the expected directory:
# ln -s ~/<path-to-this-dir>/.zsh ~/.zsh
#
# Then add the following at the end of your .zshrc:
#
# ```
# # Source custom configuration
# [ -f ~/.zsh/config.zsh ] && source ~/.zsh/config.zsh
# ```
#
# =========================

# Initialize starship prompt
command -v starship &>/dev/null && eval "$(starship init zsh)"

# Initialize zoxide
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# mise-en-place configuration
# mise-en-place configuration
_mise_paths=(
  "$HOME/.local/bin/mise"
  "/usr/local/bin/mise"
  "/opt/homebrew/bin/mise"
)
for _mise_path in "${_mise_paths[@]}"; do
  if [ -x "$_mise_path" ]; then
    eval "$($_mise_path activate zsh)"
    break
  fi
done
unset _mise_path _mise_paths

# Set default editor
export EDITOR="nvim"

# Add local node_modules to PATH
export PATH="node_modules/.bin:$PATH"

# Set TERM so terminfo is correctly loaded
export TERM="wezterm"

# Use neovim as man pager
export MANPAGER="nvim +Man!"

# Add global tools OPAM switch to PATH (OCaml)
[ -d "$HOME/.opam/tools/bin" ] && export PATH="$PATH:$HOME/.opam/tools/bin"

# Add Cargo bin to PATH
# . "$HOME/.cargo/env"
[ -d "$HOME/.cargo/bin" ] && . "$HOME/.cargo/env"

source ~/.zsh/aliases.zsh
source ~/.zsh/completion.zsh
source ~/.zsh/fzf.zsh
source ~/.zsh/history.zsh
source ~/.zsh/keybinding.zsh
