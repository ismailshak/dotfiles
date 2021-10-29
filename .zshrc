###########################################################################
##    Append the following after oh-my-zsh/prezto dumps into ~/.zshrc    ##
###########################################################################

export PATH="bin:node_modules/.bin:$PATH" # Add node_modules to PATH export

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[ -f "${GHCUP_INSTALL_BASE_PREFIX:=$HOME}/.ghcup/env" ] && source "${GHCUP_INSTALL_BASE_PREFIX:=$HOME}/.ghcup/env"


# General aliases

alias zrc="nvim ~/.zshrc"
alias zsrc="source ~/.zshrc"
alias vrc="nvim ~/.vimrc"
alias vsrc="source ~/.vimrc"
alias ..="cd ../";

killport() { kill $( lsof -i:$1 -t ) }
diff() { git diff --color --no-index "$1" "$2" }
cdiff() { code --diff "$1" "$2"}

# npm aliases

alias ni="npm install";
alias nrs="npm run start";
alias nrb="npm run build";
alias nrt="npm run test";

nr() { npm run "$1" };