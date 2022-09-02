#!/usr/bin/env bash

set -e

# Inspired by: https://github.com/kentcdodds/dotfiles/blob/master/.macos
#
# Run without downloading:
# curl https://raw.githubusercontent.com/ismailshak/dotfiles/main/.macos/init_mac.sh | bash

#
# TODO:
#     - add prompts for user interactions (--interactive mode basically)
#     - look into exposing the spinner's task's exit code (so we can prompt_success or prompt_failure)


# Settings
LOG_FILE_PATH="$HOME/Desktop/log.txt"
CODE_DIR="code"
CODE_DIR_PATH="${HOME}/${CODE_DIR}"
GITHUB_USER="ismailshak"
GITHUB_EMAIL="ismailshak94@yahoo.com"

# UI
TAB="  "
PROMPT_ICON="?"
SUCCESS_ICON="✓"
FAILURE_ICON="✗"
SPINNER_BLOCKS="▁ ▂ ▃ ▄ ▅ ▆ ▇ █ ▇ ▆ ▅ ▄ ▃ ▁"
SPINNER_BRAILLE="⣾⣽⣻⢿⡿⣟⣯⣷"
SPINNER_CIRCLES="◐ ◓ ◑ ◒"
SPINNER_TRIANGLES="◢ ◣ ◤ ◥"
SPINNER=$SPINNER_BRAILLE

# UTILITY
# -------

function write_to_log() {
  echo -e "$@" >> "$LOG_FILE_PATH"
}

# Trap Ctrl+C. Print a message before exiting
function exit_handler() {
  echo
  echo
  echo "Cancelling... (script can be reran safely)"
  write_to_log "\n\n****** Script was cancelled $(date) ******"

  exit
}

# Register handler to trap
trap 'exit_handler' SIGINT

# COMMAND HELPERS
# ---------------

# Run command and redirect all output to a log file
function execute() {
  write_to_log "\n-----------------------\nOutput from: '$*'\n-----------------------\n"
  $@ >> "$LOG_FILE_PATH" 2>&1
}

# Redirect all output to the void
function swallow() {
  $@ &> /dev/null
}

# Wrap command with a spinner. Leaves cursor on the same line as spinner label
function spinner() {
  # Run given command in the background
  execute ${@:2} &

  # Process id of the supplied command
  pid=$!

  # Iterate until the process exits
  i=0
  length=${#SPINNER}
  symbol="{s}"
  while kill -0 $pid 2>/dev/null
  do
    i=$(( (i+1) % $length ))
    # We take the first argument and substitute the symbol with the spinner
    echo -ne "\r${1/$symbol/${SPINNER:$i:1}}"
    sleep .15
  done
  # TODO: Figure out background command exit code and handle it
  # echo "$?"
}

# LOG FUNCTIONS
# -------------

# Output cursor will remain on the same line
function log() {
  echo -e -n "$*"
}

# Console cursor will jump to the next line
function log_ln() {
  echo -e "$@"
}

# CURSOR FUNCTIONS
# ----------------

# Move cursor back to the beginning of the current line
function erase_line() {
  echo -n -e "\r\033[0K"
}

# Move cursor back to the beginning of the previous line
function erase_previous_line() {
  echo -e "\r\033[1A\033[0K$@"
}

# COLOR FUNCTIONS
# ---------------

function bold() {
  log_ln "\x1B[1m$*\x1B[0m"
}
function underline() {
  log_ln "\x1B[4m$*\x1B[0m"
}
function white(){
  log_ln "\x1B[37m$*\x1B[0m"
}
function grey() {
  log_ln "\x1B[90m$*\x1B[0m"
}
function black(){
  log_ln "\x1B[30m$*\x1B[0m"
}
function red(){
  log_ln "\x1B[31m$*\x1B[0m"
}
function green(){
  log_ln "\x1B[32m$*\x1B[0m"
}
function yellow(){
  log_ln "\x1B[33m$*\x1B[0m"
}
function blue(){
  log_ln "\x1B[34m$*\x1B[0m"
}
function purple(){
  log_ln "\x1B[35m$*\x1B[0m"
}
function cyan(){
  log_ln "\x1B[36m$*\x1B[0m"
}

# UI
# --

function job_prefix() {
  log "$(purple $1)"
}

function task_header() {
  log_ln "- $(bold $1)"
}

function log_todo() {
  log_ln "$TAB$1 $2"
}

# PROMPT HELPERS
# --------------

function prompt() {
  log "$TAB$(cyan $PROMPT_ICON) $1"
}

function prompt_success() {
  erase_line && echo "$TAB$(green $SUCCESS_ICON) $1"
}

function prompt_failure() {
  erase_line && echo "$TAB$(red $FAILURE_ICON) $1"
}

# VALIDATION HELPERS
# ------------------

# Specifically, Xcode's command line tools
function check_xcode() {
  local prefix=$(job_prefix "Xcode")
  prompt "$prefix: ..."
  if swallow xcode-select -p; then
    prompt_success "$prefix: Installed"
  else
    prompt_failure "$prefix: Not found. Install it from the App Store"
    # TODO: instead of exiting maybe we can wait for a confirmation and loop check until it is
    exit 1
  fi
}

# Do we have internet access
function check_internet() {
  local prefix=$(job_prefix "Internet")
  prompt "$prefix..."
  if swallow nc -zw1 google.com 443; then
    prompt_success "$prefix: Connected"
  else
    prompt_failure "$prefix: Check your internet connection"
    exit 1
  fi
}

# Ask user to authorize upfront, and keep it alive until the script completes
function check_privileges() {
  local prefix=$(job_prefix "Admin privileges")
  prompt "$prefix: "
  if swallow sudo -v --non-interactive; then
    prompt_success "$prefix: Already authorized"
  else
    sudo -v -p "Laptop password: "
    erase_previous_line "$TAB$(green "$SUCCESS_ICON") $prefix: Authenticated"
  fi

  # Keep-alive: update existing `sudo` time stamp until `.macos` has finished
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

# Create the directory where all user code repos will live
function check_code_dir() {
  local prefix=$(job_prefix "Code directory")
  prompt "$prefix..."
  if [[ -d "$CODE_DIR_PATH" ]]; then
    prompt_success "$prefix: Already exists"
  else
    mkdir -p "${CODE_DIR_PATH}"
    prompt_success "$prefix: Created '$CODE_DIR_PATH'"
  fi
}

# MAC SETTINGS
# ------------

# https://macos-defaults.com/
# https://www.real-world-systems.com/docs/defaults.1.html

function configure_general_settings() {
  local prefix=$(job_prefix "General settings")
  prompt "$prefix: ..."
  # Disable automatic capitalization
  execute defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -int 0
  # Disable auto-correct
  execute defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -int 0
  # Enable tap to click
  execute defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  # Disable “natural” (Lion-style) scrolling
  execute defaults write NSGlobalDomain com.apple.swipescrolldirection -int 0
  # Set a fast key repeat rate
  execute defaults write NSGlobalDomain KeyRepeat -int 2
  execute defaults write NSGlobalDomain InitialKeyRepeat -int 15

  prompt_success "$prefix: Updated"
}

function configure_finder() {
  local prefix=$(job_prefix "Finder settings")
  prompt "$prefix: ..."
  # Remove items from trash after 30 days
  execute defaults write com.apple.finder "FXRemoveOldTrashItems" -bool "true"
  # Disable warning when changing file extension
  execute defaults write com.apple.finder "FXEnableExtensionChangeWarning" -bool "false"

  # Restart Finder
  execute killall Finder

  prompt_success "$prefix: Updated"
}

function configure_dock() {
  local prefix=$(job_prefix "Dock settings")
  prompt "$prefix: ..."
  # Enable autohide
  execute defaults write com.apple.dock "autohide" -int 1
  # Set dock size
  execute defaults write com.apple.dock tilesize -int 46

  # Restart Dock so settings take effect
  execute killall Dock

  prompt_success "$prefix: Updated"
}

# TOOLS
# -----

function install_oh_my_zsh() {
  local prefix=$(job_prefix "oh-my-zsh")
  # TODO: replace ZSH_THEME var with 'spaceship'
  # echo "Setting oh-my-zsh to 'spaceship' theme"
  if [ ! -d ~/.oh-my-zsh ]; then
    spinner "$TAB{s} $prefix: Installing..." sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    erase_line && prompt_success "${prefix}: Installed"
  else
    prompt_success "${prefix}: Already installed"
  fi
}

function install_homebrew() {
  local prefix=$(job_prefix "homebrew")
  if [ ! -x /usr/local/bin/brew ] && [ ! -x /opt/homebrew/bin/brew ]; then
      spinner "$TAB{s} $prefix: Installing..." /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      erase_line && prompt_success "${prefix}: Installed $(grey $(brew --version | head -n 1))"
  else
      prompt_success "${prefix}: Already installed $(grey $(brew --version | head -n 1))"
  fi
}

function install_asdf() {
  local prefix=$(job_prefix "asdf")
  if ! execute which asdf; then
    spinner "$TAB{s} $prefix: Installing..." brew install asdf
    execute echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> ${ZDOTDIR:-~}/.zshrc
    erase_line && prompt_success "${prefix}: Installed $(grey $(asdf --version))"
  else
    prompt_success "${prefix}: Already installed $(grey $(asdf --version))"
  fi
}

function install_nodejs() {
  local prefix=$(job_prefix "nodejs")
  if ! execute which node; then
    spinner "$TAB{s} $prefix: Installing nodejs dependencies..." brew gpg gawk
    spinner "$TAB{s} $prefix: Installing latest nodejs..." asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    execute asdf install nodejs latest
    execute asdf global nodejs latest
    erase_line && prompt_success "${prefix}: Installed $(grey $(node --version))"
  else
    prompt_success "${prefix}: Already installed $(grey "$(node --version)")"
  fi
}

function _golang_vars() {
  echo "export GOPATH=$HOME/go" >> ${ZDOTDIR:-~}/.zshrc
  echo "export GOROOT=/usr/local/opt/go/libexec" >> ${ZDOTDIR:-~}/.zshrc
  echo "export PATH=$PATH:$GOPATH/bin" >> ${ZDOTDIR:-~}/.zshrc
  echo "export PATH=$PATH:$GOROOT/bin" >> ${ZDOTDIR:-~}/.zshrc
}

function install_go() {
  local prefix=$(job_prefix "golang")
  if ! execute which go; then
    echo -e "\n--- GOLANG ---\n"
    spinner "$TAB{s} $prefix: Preparing..." _golang_vars
    spinner "$TAB{s} $prefix: Installing..." brew install go
    erase_line && prompt_success "${prefix}: Installed $(grey $(go version))"
  else
    prompt_success "${prefix}: Already installed $(grey "$(go version)")"
  fi
}

# HOMEBREW PACKAGES / CASKS
# -------------------------

function is_pkg_installed() {
  swallow brew list $@
}

function install_brew_pkg() {
  local prefix=$(job_prefix "$1")
  if ! is_pkg_installed $1; then
    spinner "$TAB{s} $prefix: Installing..." brew install $1
    erase_line && prompt_success "${prefix}: Installed"
  else
    prompt_success "${prefix}: Already installed"
  fi
}

function install_brew_casks() {
  curl -sL https://raw.githubusercontent.com/ismailshak/dotfiles/main/.macos/casks.txt |
  while read CASK
  do
    local prefix=$(job_prefix "$CASK")
    if ! is_pkg_installed $CASK; then
      spinner "$TAB{s} $prefix: Installing..." brew install --cask $CASK
      erase_line && prompt_success "${prefix}: Installed"
    else
      prompt_success "${prefix}: Already installed"
    fi
  done
}

function _configure_neovim() {
  git clone https://github.com/ismailshak/nvim ~/.config/nvim

  # Install plugins
  nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
}

function configure_neovim() {
  local prefix=$(job_prefix "neovim")
  if [ ! -d ~/.config/nvim ]; then
    spinner "$TAB{s} $prefix: Cloning config..." git clone https://github.com/ismailshak/nvim ~/.config/nvim
    erase_line && spinner "$TAB{s} $prefix: Configuring..." _configure_neovim
    erase_line && prompt_success "${prefix}: Configured"
  else
    prompt_success "${prefix}: Already configured"
  fi
}

# GIT / GITHUB
# ------------

function _setup_ssh() {
  touch ~/.ssh/config
  ssh-keygen -q -t rsa -b 4096 -C "$GITHUB_EMAIL" -N '' -f ~/.ssh/id_rsa_fake <<<y
  echo "Host *\n AddKeysToAgent yes\n UseKeychain yes\n IdentityFile ~/.ssh/id_rsa" | tee ~/.ssh/config
  eval "$(ssh-agent -s)"
}

function setup_git_ssh() {
  local prefix=$(job_prefix "git SSH credentials")
  if [ ! -s ~/.ssh/id_rsa ]; then
    spinner "$TAB{s} $prefix: Configuring..." _setup_ssh
    erase_line && prompt_success "${prefix}: Created"
  else
    prompt_success "${prefix}: Already installed"
  fi
}

function setup_gh_cli() {
  local prefix=$(job_prefix "gh auth")
  if ! execute gh auth status; then
    spinner "$TAB{s} $prefix: Configuring..." gh auth login --web --git-protocol ssh
    erase_line && prompt_success "${prefix}: Authenticated"
  else
    prompt_success "${prefix}: Already authenticated"
  fi
}

# Clone all repos for user that just auth'd above
function clone_user_repos() {
  execute cd $CODE_DIR_PATH

  j=0
  cloneLogLimit=5
  gh repo list --json name --jq '.[].name' |
  while read REPO
  do
    local prefix=$(job_prefix $REPO)
    if [ -d $REPO ]; then
      prompt_success "$prefix: Already cloned"
      continue
    fi

    if (( $j > $cloneLogLimit )); then
      execute gh repo clone $REPO
      erase_line && log $(grey "$TAB ... and $j more repos ...")
    else
      spinner "$TAB{s} ${prefix}: Cloning..." gh repo clone $REPO
      erase_line && prompt_success "${prefix}: Cloned"
    fi
    # TODO: fix this not incrementing
    # and log "... and X more repos ..." when limit is reached
    j=$((j++ ))
  done

  execute cd -
}

# DOTFILES
# --------

function sync_file() {
  local file_path=$1
  local prefix=$(job_prefix $3)
  if [ -f "$file_path" ]; then
     cat "$file_path" >> "$2"
    prompt_success "${prefix}: Copied"
  else
    prompt_failure "${prefix}: '$file_path' not found"
  fi
}

function sync_gitconfig() {
  local target_path=~/.gitconfig
  if [ ! -f "$target_path" ]; then
    touch "$target_path"
  fi

  sync_file "$CODE_DIR_PATH/dotfiles/.gitconfig" "$target_path" "gitconfig"
}

function sync_zshrc() {
  local target_path=~/.zshrc
  if [ ! -f "$target_path" ]; then
    touch "$target_path"
  fi
  sync_file "$CODE_DIR_PATH/dotfiles/.zshrc" "$target_path" "zshrc"
}

function sync_tmuxconf() {
  local target_path=~/.tmux.conf
  if [ ! -f "$target_path" ]; then
    touch "$target_path"
  fi
  sync_file "$CODE_DIR_PATH/dotfiles/.tmux.conf" "$target_path" "tmux config"
}

# INPUT FONT
# ----------

# Contains the customization options
DOWNLOAD_URL=https://input.djr.com/build/\?customize\&fontSelection\=fourStyleFamily\&regular\=InputMono-Regular\&italic\=InputMono-Italic\&bold\=InputMono-Bold\&boldItalic\=InputMono-BoldItalic\&a\=0\&g\=ss\&i\=serif\&l\=serif\&zero\=slash\&asterisk\=0\&braces\=straight\&preset\=default\&line-height\=1.2\&accept\=I+do\&email\=

ZIP_NAME="input-font.zip"
TEMP_DIR="$HOME/tmp-font"
FONT_ASSET_PATH="$TEMP_DIR/Input_Fonts/Input"
FINAL_DIR="$HOME/Documents/input-font"

function setup_input_font() {
  local prefix=$(job_prefix "Install")

  # Operate out of a temp dir
  rm -rf "$TEMP_DIR"
  mkdir "$TEMP_DIR"
  cd "$TEMP_DIR"

  # Create the final destination dir
  rm -rf "$FINAL_DIR"
  mkdir -p "$FINAL_DIR/source"

  # Download from URL
  spinner "$TAB{s} $prefix: Downloading..." curl -o $ZIP_NAME -L $DOWNLOAD_URL

  # Unzip
  spinner "$TAB{s} $prefix: Unzipping..." unzip $ZIP_NAME

  # Copy font assets to a 'source' dir inside the dedicated dir
  execute find "$TEMP_DIR" -name '*.ttf' -exec cp -prv '{}' "$FINAL_DIR/source" ';'
  # cp "$FONT_ASSET_PATH/*.ttf" "$FINAL_DIR/source" # <--- this would work in zsh

  # Delete temp dir
  execute rm -rf "$TEMP_DIR"

  # Navigate back to wherever we were
  execute cd -

  erase_line && prompt_success "$prefix: Done"
}

function _run_patch_script() {
  docker run -v $FINAL_DIR/source:/in -v $FINAL_DIR/patched:/out nerdfonts/patcher --careful --complete --adjust-line-height
}

function patch_input_font() {
  local prefix=$(job_prefix "Patch nerd font")

  spinner "$TAB{s} $prefix: Patching... $(grey "This may take a while")" _run_patch_script

  erase_line && prompt_success "$prefix: Done $(grey "step logs can be found in the docker container used to patch")"
}

# SCRIPT EXECUTION
# ----------------

write_to_log
write_to_log "================================================"
write_to_log "            START - $(date)"
write_to_log "================================================"

log_ln
task_header "👋 Hello $(whoami)! Let's get you set up."

log_ln
task_header "Checking if requirements are met"
check_xcode
check_internet
check_privileges
check_code_dir

log_ln
task_header "Configuring laptop settings"
configure_general_settings
configure_finder
configure_dock

log_ln
task_header "Installing tools"
install_oh_my_zsh # Install oh-my-zsh early, since it dominates the ~/.zshrc
install_homebrew
install_asdf
install_nodejs
install_go

log_ln
task_header "Installing homebrew packages"
install_brew_pkg "gh"
install_brew_pkg "neovim"
install_brew_pkg "tmux"
install_brew_pkg "docker"
install_brew_pkg "ripgrep"
install_brew_pkg "circleci"
install_brew_pkg "jq"
install_brew_pkg "spaceship"
install_brew_pkg "stylua"

log_ln
task_header "Installing homebrew casks"
install_brew_casks

log_ln
task_header "Git & Github authentication"
setup_git_ssh
setup_gh_cli

log_ln
task_header "Cloning all user repos to '${CODE_DIR_PATH}'"
clone_user_repos

log_ln
task_header "Configuring neovim"
configure_neovim

log_ln
task_header "Syncing dotfiles"
sync_gitconfig
sync_zshrc
sync_tmuxconf

log_ln
task_header "Installing Input font"
setup_input_font
patch_input_font

log_ln
task_header "List of things that need manual setup"
log_todo "🔒" "Log into all the things"
log_todo "📌" "Packer install remaining neovim plugins"
log_todo "🔋" "Restore Alfred pack"
log_todo "🪐" "Set oh-my-zsh theme to 'spaceship'"
log_todo "☁️ " "Visit https://github.com/settings/keys and paste the key was copied to your clipboard" && pbcopy < ~/.ssh/id_rsa.pub
log_todo "🔣" "Set VSCode & iTerm's font to Input"

log_ln
log_ln "All done 🚀"

log_ln
log_ln $(grey "Script logs can be found here: $(underline "$LOG_FILE_PATH")")
log_ln
log_ln $(grey "The log file will be automatically destroyed on the next restart")
log_ln $(grey "To keep the log file, move it out of '/tmp/':")
log_ln $(grey "cp $LOG_FILE_PATH ~/Desktop")

write_to_log
write_to_log "================================================"
write_to_log "            END - $(date)"
write_to_log "================================================"

