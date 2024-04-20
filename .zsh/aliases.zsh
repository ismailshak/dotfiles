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

delete_all_dirs() {
	find . -name "$1" -type d -print -prune -exec rm -rf '{}' \;
}

delete_all_files() {
	find . -name "$1" -type f -print -prune -exec rm -f '{}' \;
}

killport() {
	kill -9 "$(lsof -i:"$1" -t)"
}

cdiff() {
	code --diff "$1" "$2"
}

gdiff() {
	# If no args, use default diff command
	if [ $# -eq 0 ]; then
		git diff
	else
		git diff --color --no-index "$1" "$2"
	fi
}

# npm aliases

alias ni="npm install"
alias nci="npm ci"
alias nu="npm uninstall"
alias nrs="npm run start"
alias nrb="npm run build"
alias nrt="npm run test"

nr() {
	npm run "$1"
};

# pnpm aliases

alias pni="pnpm install"
alias pnu="pnpm uninstall"
alias pns="pnpm start"
alias pnb="pnpm build"
alias pnt="pnpm run test"

pnr() {
  pnpm run "$1"
};

# asdf aliases

alias asdfi="asdf install"
alias asdfn="asdf install nodejs"
alias asdfir="asdf install && asdf reshim"

