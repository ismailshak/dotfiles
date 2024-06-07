# General aliases

alias ..="cd ../"
alias -- -="cd -"
alias zrc="nvim ~/.zshrc"
alias zsrc="source ~/.zshrc"
alias ip="ifconfig | grep broadcast"
alias openport="npx localtunnel --port"
alias catt="bat"
alias lg="lazygit"
alias ld="lazydocker"
alias sp="spotify_player"
alias n="nvim"
alias e="exit"
alias c="clear"

delete_all_dirs() { find . -name "$1" -type d -print -prune -exec rm -rf '{}' \; }
delete_all_files() { find . -name "$1" -type f -print -prune -exec rm -f '{}' \; }
killport() { kill -9 "$(lsof -i:"$1" -t)" }
togif() { ffmpeg -i $1 -filter_complex "[0:v] fps=12,split [a][b];[a] palettegen [p];[b][p] paletteuse" $2 }

cdiff() { code --diff "$1" "$2" }
ndiff() { nvim -d "$1" "$2" }
gdiff() { git diff --color --no-index "$1" "$2" }

# git aliases (most aliases are in ~/.gitconfig)

alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"'
alias gunwip='git rev-list --max-count=1 --format="%s" HEAD | grep -q "\--wip--" && git reset HEAD~1'
alias gco="git checkout"

# npm aliases

alias ni="npm install"
alias nci="npm ci"
alias nu="npm uninstall"
alias nrs="npm run start"
alias nrb="npm run build"
alias nrt="npm run test"
alias nr="npm run"

# pnpm aliases

alias pni="pnpm install"
alias pnu="pnpm uninstall"
alias pns="pnpm start"
alias pnb="pnpm build"
alias pnt="pnpm run test"
alias pnr="pnpm run"

# asdf aliases

alias asdfi="asdf install"
alias asdfn="asdf install nodejs"
alias asdfir="asdf install && asdf reshim"

