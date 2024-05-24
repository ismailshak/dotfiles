# Put the terminal in emacs keybind mode (the default mode)
bindkey -e

# Start typing + [Up-Arrow] - fuzzy find history forward
autoload -U up-line-or-beginning-search
zle -N up-line-or-beginning-search
bindkey -M emacs "^[[A" up-line-or-beginning-search
bindkey -M viins "^[[A" up-line-or-beginning-search
bindkey -M vicmd "^[[A" up-line-or-beginning-search
if [[ -n "${terminfo[kcuu1]}" ]]; then
  bindkey -M emacs "${terminfo[kcuu1]}" up-line-or-beginning-search
  bindkey -M viins "${terminfo[kcuu1]}" up-line-or-beginning-search
  bindkey -M vicmd "${terminfo[kcuu1]}" up-line-or-beginning-search
fi

# Start typing + [Down-Arrow] - fuzzy find history backward
autoload -U down-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey -M emacs "^[[B" down-line-or-beginning-search
bindkey -M viins "^[[B" down-line-or-beginning-search
bindkey -M vicmd "^[[B" down-line-or-beginning-search
if [[ -n "${terminfo[kcud1]}" ]]; then
  bindkey -M emacs "${terminfo[kcud1]}" down-line-or-beginning-search
  bindkey -M viins "${terminfo[kcud1]}" down-line-or-beginning-search
  bindkey -M vicmd "${terminfo[kcud1]}" down-line-or-beginning-search
fi

# [Alt-RightArrow] - move forward one word
bindkey -M emacs '^[[1;3C' forward-word
bindkey -M viins '^[[1;3C' forward-word
bindkey -M vicmd '^[[1;3C' forward-word

# [Alt-LeftArrow] - move backward one word
bindkey -M emacs '^[[1;3D' backward-word
bindkey -M viins '^[[1;3D' backward-word
bindkey -M vicmd '^[[1;3D' backward-word

# [Space] - trigger history expansion (e.g. !ls<Space> or !!<Space>)
bindkey ' ' magic-space
