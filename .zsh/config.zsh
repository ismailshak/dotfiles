# oh-my-zsh configuration
#------------------------

export ZSH="$HOME/.oh-my-zsh"

# make omz history wrapper output timestamps
HIST_STAMPS="yyyy.mm.dd"

plugins=(git)

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

#------------------------

# Initialize starship prompt
eval "$(starship init zsh)"

# Initialize zoxide
eval "$(zoxide init zsh)"

# Add local node_modules to PATH
export PATH="node_modules/.bin:$PATH"

# Add global tools OPAM switch to PATH (OCaml)
[ -d "$HOME/.opam/tools/bin" ] && export PATH="$PATH:$HOME/.opam/tools/bin"

# main aliases
source ~/.zsh/aliases.zsh

# fzf aliases
source ~/.zsh/fzf_aliases.zsh

