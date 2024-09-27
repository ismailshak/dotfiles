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
eval "$(starship init zsh)"

# Initialize zoxide
eval "$(zoxide init zsh)"

# Add local node_modules to PATH
export PATH="node_modules/.bin:$PATH"

# Add global tools OPAM switch to PATH (OCaml)
[ -d "$HOME/.opam/tools/bin" ] && export PATH="$PATH:$HOME/.opam/tools/bin"

# asdf configuration
. /opt/homebrew/opt/asdf/libexec/asdf.sh

# Add Golang bin to PATH
. ~/.asdf/plugins/golang/set-env.zsh

source ~/.zsh/aliases.zsh
source ~/.zsh/completion.zsh
source ~/.zsh/fzf.zsh
source ~/.zsh/history.zsh
source ~/.zsh/keybinding.zsh
