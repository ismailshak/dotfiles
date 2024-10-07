# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Customize menu appearance
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:-1,bg:-1,fg+:-1,bg+:-1,gutter:-1
  --color=spinner:yellow,info:yellow,pointer:cyan,prompt:cyan
  --prompt="󰍉 " --pointer="" --marker=""
  --border-label="" --preview-window="border-rounded"
  --info="right"
  --padding=1,0,0,1
  --no-scrollbar
  --cycle
  --layout=reverse'

# history
fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')
}

# kill processes - list only the ones you can kill
fkill() {
    local pid
    if [ "$UID" != "0" ]; then
        pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
    else
        pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    fi

    if [ "x$pid" != "x" ]
    then
        echo $pid | xargs kill -${1:-9}
    fi
}

# checkout git branch/tag, with a preview showing the commits between the tag/branch and HEAD
fco() {
  local tags branches target
  branches=$(
    git --no-pager branch --all \
      --format="%(if)%(HEAD)%(then)%(else)%(if:equals=HEAD)%(refname:strip=3)%(then)%(else)%1B[0;34;1mbranch%09%1B[m%(refname:short)%(end)%(end)" \
    | sed '/^$/d') || return
  tags=$(
    git --no-pager tag | awk '{print "\x1b[35;1mtag\x1b[m\t" $1}') || return
  target=$(
    (echo "$branches"; echo "$tags") |
    fzf --no-hscroll --no-multi -n 2 \
        --ansi --preview="git --no-pager log -150 --pretty=format:%s '..{2}'") || return
  git checkout $(awk '{print $2}' <<<"$target" )
}

# run npm script (requires jq)
fnr() {
  local script
  script=$(cat package.json | jq -r '.scripts | keys[] ' | sort | fzf) && npm run $(echo "$script")
}

# run a pnpm script (requires jq)
fpnr() {
  local script
  script=$(cat package.json | jq -r '.scripts | keys[] ' | sort | fzf) && pnpm run $(echo "$script")
}

# find password and copy to clipboard (requires lpass)
flp() {
  lpass show -c --password $(lpass ls --format="%/as%/ag%an" | fzf | awk '{print $(NF)}' | sed 's/\]//g')
}

# grep files with ripgrep and open it in neovim
ffg() {
  RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case --no-ignore --hidden --follow --glob '!.git' --glob '!node_modules'"
  fzf --ansi --disabled --query "" \
    --bind "start:reload:$RG_PREFIX {q}" \
    --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
    --delimiter : \
    --preview 'bat --color=always {1} --highlight-line {2}' \
    --preview-window 'bottom,60%,border-top,+{2}+3/3,~3' \
    --bind 'enter:become(nvim {1} +{2})'
}

# find directories with fd and cd into them
# (eza is used to add colors and icons to the output)
ffd() {
  target=$(fd --type d --hidden --follow --no-ignore \
    --exclude .git \
    --exclude node_modules \
    --exclude .cache \
    --exclude .next \
    --exclude .DS_Store \
    --exclude dist \
    --exclude public \
    --exclude coverage \
    --exclude target \
    --exec eza --icons=always --color=always --list-dirs --no-quotes \
    | fzf --ansi \
    --delimiter : \
    --preview 'eza --color=always --icons=always --git --git-repos --long --no-filesize --no-time --no-user --no-permissions --group-directories-first --tree --level=2 --all --git-ignore "$(echo "{1}" | awk "{print \$2}" | rev | cut -c 2- | rev )"' \
    --preview-window 'right,50%,border-left' \
    | awk '{print $2}')

  cd "$target"
}

# find files with fd and open them in neovim
# (eza is used to add colors and icons to the output)
fff() {
  RG_FLAGS="--hidden --follow --no-ignore --glob !.git --glob !node_modules --glob !.cache --glob !.next --glob !.DS_Store --glob !dist --glob !public --glob !coverage --glob !target"
  fzf --ansi --disabled --query "" \
    --bind "start:reload:(rg --files $RG_FLAGS | rg --smart-case {q} | xargs eza --icons=always --color=always)" \
    --bind "change:reload:sleep 0.1; (rg --files $RG_FLAGS | rg --smart-case {q} | xargs eza --icons=always --color=always) || true" \
    --delimiter : \
    --preview 'bat --color=always "$(echo {1} | awk "{print \$2}")"' \
    --preview-window 'right,50%,border-left' \
    --bind 'enter:become(nvim "$(echo {1} | awk "{print \$2}")")'
}
