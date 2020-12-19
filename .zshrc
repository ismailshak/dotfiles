export PATH="bin:node_modules/.bin:$PATH" # Add node_modules to PATH export
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

#ZSH_THEME="spaceship"
# Customize to your needs...

#   SPACESHIP_PROMPT_ORDER=(
#   time          # Time stamps section
#   user          # Username section
#   dir           # Current directory section
#   host          # Hostname section
#   git           # Git section (git_branch + git_status)
#   hg            # Mercurial section (hg_branch  + hg_status)
#   package       # Package version
#   node          # Node.js section
#   ruby          # Ruby section
#   elixir        # Elixir section
#   xcode         # Xcode section
#   swift         # Swift section
#   golang        # Go section
#   php           # PHP section
#   rust          # Rust section
#   haskell       # Haskell Stack section
#   julia         # Julia section
#   docker        # Docker section
#   aws           # Amazon Web Services section
#   venv          # virtualenv section
#   conda         # conda virtualenv section
#   pyenv         # Pyenv section
#   dotnet        # .NET section
#   ember         # Ember.js section
#   kubecontext   # Kubectl context section
#   terraform     # Terraform workspace section
#   exec_time     # Execution time
#   line_sep      # Line break
#   battery       # Battery level and status
#   vi_mode       # Vi-mode indicator
#   jobs          # Background jobs indicator
#   exit_code     # Exit code section
#   char          # Prompt character
# )

[[ -s "$HOME/.avn/bin/avn.sh" ]] && source "$HOME/.avn/bin/avn.sh" # load avn

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

  # Set Spaceship ZSH as a prompt
  autoload -U promptinit; promptinit
  prompt spaceship
  SPACESHIP_DOCKER_SHOW=false
  SPACESHIP_AWS_SHOW=false

  [ -f "${GHCUP_INSTALL_BASE_PREFIX:=$HOME}/.ghcup/env" ] && source "${GHCUP_INSTALL_BASE_PREFIX:=$HOME}/.ghcup/env"

alias zshrc="nvim ~/.zshrc"
alias srczshrc="source ~/.zshrc"
alias vimrc="nvim ~/.vimrc"
alias srcvim="source ~/.vimrc"
