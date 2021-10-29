###########################################################################
##    Append the following after oh-my-zsh/prezto dumps into ~/.zshrc    ##
###########################################################################

export PATH="bin:node_modules/.bin:$PATH" # Add node_modules to PATH export

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[ -f "${GHCUP_INSTALL_BASE_PREFIX:=$HOME}/.ghcup/env" ] && source "${GHCUP_INSTALL_BASE_PREFIX:=$HOME}/.ghcup/env"


# General aliases

alias ..="cd ../";
alias zrc="nvim ~/.zshrc"
alias zsrc="source ~/.zshrc"
alias vrc="nvim ~/.vimrc"
alias vsrc="source ~/.vimrc"
alias ip="ifconfig | grep broadcast"
alias openport="npx localtunnel --port"

killport() { kill -9 $(lsof -i:$1 -t) }
diff() { git diff --color --no-index "$1" "$2" }
cdiff() { code --diff "$1" "$2"}

# npm aliases

alias ni="npm install";
alias nrs="npm run start";
alias nrb="npm run build";
alias nrt="npm run test";
alias nci="npm ci"

nr() { npm run "$1" };

#pnpm aliases

alias pni="pnpm install"
alias pns="pnpm start"
alias pnb="pnpm build"
alias pnt="pnpm test"
alias pnci="rm -rf node_modules && pnpm install --frozen-lock-file"

# asdf aliases

alias asdfn="asdf install nodejs"
alias asdfri="asdf reshim && asdf install"
alias asdfi="asdf install"