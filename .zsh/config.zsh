# Add local node_modules to PATH
export PATH="node_modules/.bin:$PATH"

# main aliases
source ~/.zsh/aliases.zsh

# fzf aliases
source ~/.zsh/fzf_aliases.zsh

# Initialize starship prompt
eval "$(starship init zsh)"

# Initialize zoxide
eval "$(zoxide init zsh)"

