# Load completions from ~/.zsh/completion
fpath=($HOME/.zsh/completion $fpath)

# Register completion functions
zstyle ':completion:*' completer _extensions _complete _approximate

# Enable case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Group completions by category with formatting
zstyle ':completion:*' group-name ''

# Category description formatting
# (%F/f for foreground color, %B/b for bold, %U/u for underline)
zstyle ':completion:*:descriptions' format '%F{magenta}%B-%d-%b%f'

# Category description formatting for corrected completions
# (%e for number of errors)
zstyle ':completion:*:corrections' format '%F{orange}%B-%d (errors: %e)-%b%f'

# Hide empty groups in completion menu
zstyle ':completion:*:descriptions' hide yes

# Set completion style to menu with entry selection
zstyle ':completion:*' menu yes select search

# Load completion list extensions
zmodload zsh/complist

# Allow dotfiles in completions
_comp_options+=(globdots)

# Autoload and initialize completion system
autoload -Uz compinit && compinit
