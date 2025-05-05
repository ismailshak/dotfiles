#!/usr/bin/env bash

set -e

# Inspired by: https://github.com/kentcdodds/dotfiles/blob/master/.macos
#
# Run without downloading:
# bash <(curl -s https://raw.githubusercontent.com/ismailshak/dotfiles/main/.macos/init_mac.sh)

#
# TODO:
#   - expose the spinner's task's exit code (so we can prompt_success or prompt_failure)

# Settings
LOG_FILE_PATH="/tmp/init_mac_logs.txt"
CODE_DIR="code"
CODE_DIR_PATH="${HOME}/${CODE_DIR}"

# UI
TAB="  "
PROMPT_ICON="?"
SUCCESS_ICON="✓"
FAILURE_ICON="✗"
# SPINNER_BLOCKS="▁ ▂ ▃ ▄ ▅ ▆ ▇ █ ▇ ▆ ▅ ▄ ▃ ▁"
SPINNER_BRAILLE="⣷⣯⣟⡿⢿⣻⣽⣾"
# SPINNER_CIRCLES="◐ ◓ ◑ ◒"
# SPINNER_TRIANGLES="◢ ◣ ◤ ◥"
SPINNER=$SPINNER_BRAILLE

# Values to set
GITHUB_USER_EMAIL=""
GITHUB_SCRIPT_TOKEN=""
GITHUB_SSH_KEY_TITLE=""

# UTILITY
# -------

function write_to_log() {
  echo -e "$@" >>"$LOG_FILE_PATH"
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

source_zshrc() {
  source ~/.zshrc
}

# COMMAND HELPERS
# ---------------

# Run command and redirect all output to a log file
function execute() {
  write_to_log "\n-----------------------\nOutput from: '$*'\n-----------------------\n"
  "$@" >>"$LOG_FILE_PATH" 2>&1
}

# Redirect all output to the void
function swallow() {
  "$@" &>/dev/null
}

# Wrap command with a spinner. Leaves cursor on the same line as spinner label
function spinner() {
  # Run given command in the background
  execute "${@:2}" &

  # Process id of the supplied command
  pid=$!

  # Iterate until the process exits
  i=0
  length=${#SPINNER}
  symbol="{s}"
  while kill -0 $pid 2>/dev/null; do
    i=$(((i + 1) % $length))
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
  echo -e "\r\033[1A\033[0K$*"
}

# COLOR FUNCTIONS
# ---------------

function bold() {
  log_ln "\x1B[1m$*\x1B[0m"
}
function underline() {
  log_ln "\x1B[4m$*\x1B[0m"
}
function white() {
  log_ln "\x1B[37m$*\x1B[0m"
}
function grey() {
  log_ln "\x1B[90m$*\x1B[0m"
}
function black() {
  log_ln "\x1B[30m$*\x1B[0m"
}
function red() {
  log_ln "\x1B[31m$*\x1B[0m"
}
function green() {
  log_ln "\x1B[32m$*\x1B[0m"
}
function yellow() {
  log_ln "\x1B[33m$*\x1B[0m"
}
function blue() {
  log_ln "\x1B[34m$*\x1B[0m"
}
function purple() {
  log_ln "\x1B[35m$*\x1B[0m"
}
function cyan() {
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
    prompt_failure "$prefix: Not found. Run 'xcode-select install'"
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
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
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

# USER INPUT
# ----------

function prompt_github_email() {
  local prefix=$(job_prefix "GitHub email")
  prompt "$prefix: "
  read -rp "" GITHUB_USER_EMAIL
  erase_previous_line "$TAB$(green "$SUCCESS_ICON") $prefix: Stored"
}

function prompt_github_token() {
  local prefix=$(job_prefix "GitHub token")
  prompt "$prefix: "
  read -srp "" GITHUB_SCRIPT_TOKEN
  erase_line && echo "$TAB$(green "$SUCCESS_ICON") $prefix: Stored"
}

function prompt_github_ssh_key_title() {
  local prefix=$(job_prefix "GitHub SSH key title")
  prompt "$prefix: "
  read -rp "" GITHUB_SSH_KEY_TITLE
  erase_previous_line "$TAB$(green "$SUCCESS_ICON") $prefix: Stored"
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
  #execute defaults write NSGlobalDomain com.apple.swipescrolldirection -int 0
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

function _install_homebrew() {
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

function _handle_homebrew_path() {
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>"$HOME/.zprofile"
}

function install_homebrew() {
  local prefix=$(job_prefix "homebrew")
  if [ ! -x /usr/local/bin/brew ] && [ ! -x /opt/homebrew/bin/brew ]; then
    spinner "$TAB{s} $prefix: Installing..." _install_homebrew
    execute _handle_homebrew_path
    eval "$(/opt/homebrew/bin/brew shellenv)"
    erase_line && prompt_success "${prefix}: Installed $(grey "$(brew --version | head -n 1)")"
  else
    eval "$(/opt/homebrew/bin/brew shellenv)"
    prompt_success "${prefix}: Already installed $(grey "$(brew --version | head -n 1)")"
  fi
}

# Temporarily source asdf script since it will be added to zshrc later
function _handle_asdf_path() {
  . $(brew --prefix asdf)/libexec/asdf.sh
}

function install_asdf() {
  local prefix=$(job_prefix "asdf")
  if ! execute which asdf; then
    spinner "$TAB{s} $prefix: Installing..." brew install asdf
    execute _handle_asdf_path
    erase_line && prompt_success "${prefix}: Installed $(grey "$(asdf --version)")"
  else
    execute _handle_asdf_path
    prompt_success "${prefix}: Already installed $(grey "$(asdf --version)")"
  fi
}

function install_nodejs() {
  local prefix=$(job_prefix "nodejs")
  if ! execute which node; then
    spinner "$TAB{s} $prefix: Installing..." asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    execute asdf install nodejs latest
    execute asdf global nodejs latest
    erase_line && prompt_success "${prefix}: Installed $(grey "$(node --version)")"
  else
    prompt_success "${prefix}: Already installed $(grey "$(node --version)")"
  fi
}

function install_pnpm() {
  local prefix=$(job_prefix "pnpm")
  if ! execute which pnpm; then
    spinner "$TAB{s} $prefix: Installing..." asdf plugin add pnpm https://github.com/jonathanmorley/asdf-pnpm
    execute asdf install pnpm latest
    execute asdf global pnpm latest
    erase_line && prompt_success "${prefix}: Installed $(grey "$(pnpm --version)")"
  else
    prompt_success "${prefix}: Already installed $(grey "$(pnpm --version)")"
  fi

}

function install_go() {
  local prefix=$(job_prefix "golang")
  if ! execute which go; then
    spinner "$TAB{s} $prefix: Installing..." asdf plugin add golang https://github.com/asdf-community/asdf-golang.git
    execute asdf install golang latest
    execute asdf global golang latest
    erase_line && prompt_success "${prefix}: Installed $(grey "$(go version)")"
  else
    prompt_success "${prefix}: Already installed $(grey "$(go version)")"
  fi
}

function install_neovim() {
  local prefix=$(job_prefix "neovim")
  if [ ! -d ~/.config/nvim ]; then
    spinner "$TAB{s} $prefix: Installing..." asdf plugin add neovim https://github.com/richin13/asdf-neovim.git
    erase_line && prompt_success "${prefix}: Installed"
  else
    prompt_success "${prefix}: Already configured"
  fi
}

function _configure_neovim() {
  symlink_dir "$CODE_DIR_PATH/nvim" "$HOME/.config/nvim"

  # Subshell to install neovim plugins so that changing directories doesn't affect the script
  (
    cd "$CODE_DIR_PATH/nvim"
    asdf install
    asdf global neovim $(cat .tool-versions | awk '/neovim/ {print $2}')
  )

  nvim --headless "+Lazy! sync" "+MasonToolsInstallSync" +qa
}

function configure_neovim() {
  local prefix=$(job_prefix "neovim")
  if [ ! -d ~/.config/nvim ]; then
    spinner "$TAB{s} $prefix: Configuring..." _configure_neovim
    erase_line && prompt_success "${prefix}: Configured"
  else
    prompt_success "${prefix}: Already configured"
  fi
}

# Downloads and installs wezterm's terminfo file
# so that things like underlines and strikethroughs work
function _configure_wezterm() {
  tempfile=$(mktemp)
  curl -o "$tempfile" https://raw.githubusercontent.com/wezterm/wezterm/master/termwiz/data/wezterm.terminfo
  tic -x -o ~/.terminfo "$tempfile"
  rm "$tempfile"
}

function configure_wezterm() {
  local prefix=$(job_prefix "wezterm")
  if ! infocmp wezterm &>/dev/null; then
    spinner "$TAB{s} $prefix: Compiling terminfo..." _configure_wezterm
    erase_line && prompt_success "${prefix}: Configured"
  else
    prompt_success "${prefix}: Already configured"
  fi
}

# HOMEBREW FORMULAS / CASKS
# -------------------------

function is_pkg_installed() {
  swallow brew list "$@"
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
    while read CASK; do
      local prefix=$(job_prefix "$CASK")
      if ! is_pkg_installed $CASK; then
        spinner "$TAB{s} $prefix: Installing..." brew install --cask $CASK
        erase_line && prompt_success "${prefix}: Installed"
      else
        prompt_success "${prefix}: Already installed"
      fi
    done
}

function install_brew_formulas() {
  curl -sL https://raw.githubusercontent.com/ismailshak/dotfiles/main/.macos/formulas.txt |
    while read FORMULA; do
      local prefix=$(job_prefix "$FORMULA")
      if ! is_pkg_installed "$FORMULA"; then
        spinner "$TAB{s} $prefix: Installing..." brew install $FORMULA
        erase_line && prompt_success "${prefix}: Installed"
      else
        prompt_success "${prefix}: Already installed"
      fi
    done

}

# GIT / GITHUB
# ------------

function _setup_ssh() {
  # Generate a new SSH key
  ssh-keygen -q -t ed25519 -C "$GITHUB_USER_EMAIL" -N '' -f ~/.ssh/id_ed25519 <<<y

  # Create a config file to store the ssh-agent settings
  touch ~/.ssh/config
  echo "Host *\n AddKeysToAgent yes\n UseKeychain yes\n IdentityFile ~/.ssh/id_rsa" | tee ~/.ssh/config

  # Start the ssh-agent in the background
  eval "$(ssh-agent -s)"

  # Add private key to the ssh-agent and store passphrase in the keychain
  ssh-add --apple-use-keychain ~/.ssh/id_ed25519
}

function setup_git_ssh() {
  local prefix=$(job_prefix "git SSH keys")
  if [ ! -s ~/.ssh/id_ed25519 ]; then
    spinner "$TAB{s} $prefix: Configuring..." _setup_ssh
    erase_line && prompt_success "${prefix}: Created"
  else
    prompt_success "${prefix}: Already configured"
  fi
}

function _gh_key_exists() {
  gh ssh-key list | grep "$GITHUB_SSH_KEY_TITLE"
}

# Upload the SSH key to Github
function upload_ssh_key() {
  local prefix=$(job_prefix "github SSH key")
  # Check if the key is already uploaded
  if ! execute _gh_key_exists; then
    # Upload the key
    spinner "$TAB{s} $prefix: Uploading..." gh ssh-key add ~/.ssh/id_ed25519.pub --title "$GITHUB_SSH_KEY_TITLE"
    erase_line && prompt_success "${prefix}: Uploaded"
  else
    prompt_success "${prefix}: Already uploaded"
  fi
}

function _gh_auth() {
  echo "$GITHUB_SCRIPT_TOKEN" | gh auth login --with-token

  gh config set -h "github.com" host "github.com"
  gh config set -h "github.com" git_protocol "ssh"
}

function setup_gh_cli() {
  local prefix=$(job_prefix "gh auth")
  if ! execute gh auth status; then
    spinner "$TAB{s} $prefix: Configuring..." _gh_auth
    erase_line && prompt_success "${prefix}: Authenticated"
  else
    prompt_success "${prefix}: Already authenticated"
  fi
}

function _clone() {
  GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" gh repo clone "$1"
}

# Clone all repos for user that just auth'd above
# (wrapped in parens so it executes in a subshell)
function clone_user_repos() (
  execute cd "$CODE_DIR_PATH"

  j=0
  cloneLogLimit=5
  gh repo list --no-archived --json name --jq '.[].name' |
    while read REPO; do
      local prefix=$(job_prefix "$REPO")
      if [ -d "$REPO" ]; then
        prompt_success "$prefix: Already cloned"
        continue
      fi

      if ((j > cloneLogLimit)); then
        execute _clone "$REPO"
        erase_line && log $(grey "$TAB ... and $j more repos ...")
      else
        spinner "$TAB{s} ${prefix}: Cloning..." _clone $REPO
        erase_line && prompt_success "${prefix}: Cloned"
      fi
      j=$((j + 1))
    done

  execute cd -
)

# DOTFILES
# --------

function symlink_file() {
  local file_path=$1
  local target_path=$2
  local prefix=$(job_prefix $3)
  if [ -f "$file_path" ]; then
    ln -s "$file_path" "$target_path"
    prompt_success "${prefix}: Linked"
  else
    prompt_failure "${prefix}: '$file_path' not found"
  fi
}

function symlink_dir() {
  dir_path=$1
  target_path=$2
  prefix=$(job_prefix $3)
  if [ -d "$dir_path" ]; then
    ln -s "$dir_path" "$target_path"
    prompt_success "${prefix}: Linked"
  else
    prompt_failure "${prefix}: '$dir_path' not found"
  fi
}

function sync_dotfiles() {
  local prefix=$(job_prefix "dotfiles")
  spinner "$TAB{s} ${prefix}: Syncing..." make -C "$CODE_DIR_PATH/dotfiles" sync_dots
  erase_line && prompt_success "${prefix}: Synced"
}

function sync_app_icons() {
  local prefix=$(job_prefix "app icons")
  spinner "$TAB{s} ${prefix}: Syncing..." make -C "$CODE_DIR_PATH/dotfiles" sync_icons
  erase_line && prompt_success "${prefix}: Synced"
}

# COMMIT MONO FONT
# ----------

# Contains the customization options for Input Mono
# INPUT_DOWNLOAD_URL=https://input.djr.com/build/\?customize\&fontSelection\=fourStyleFamily\&regular\=InputMono-Regular\&italic\=InputMono-Italic\&bold\=InputMono-Bold\&boldItalic\=InputMono-BoldItalic\&a\=0\&g\=ss\&i\=serif\&l\=serif\&zero\=slash\&asterisk\=0\&braces\=straight\&preset\=default\&line-height\=1.2\&accept\=I+do\&email\=

function install_fonts() {
  local prefix=$(job_prefix "Fonts")
  spinner "$TAB{s} ${prefix}: Installing..." make -C "$CODE_DIR_PATH/dotfiles" sync_fonts
  prompt_success "${prefix}: Installed"
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
task_header "Gathering some information"
prompt_github_email
prompt_github_token
prompt_github_ssh_key_title

log_ln
task_header "Configuring laptop settings"
configure_general_settings
configure_finder
configure_dock

log_ln
task_header "Installing tools"
install_homebrew
install_asdf
install_neovim
install_nodejs
install_pnpm
install_go

log_ln
task_header "Installing homebrew packages"
install_brew_formulas

log_ln
task_header "Git & Github authentication"
setup_git_ssh
setup_gh_cli
upload_ssh_key

log_ln
task_header "Cloning all user repos to '${CODE_DIR_PATH}'"
clone_user_repos

log_ln
task_header "Syncing dotfiles"
sync_dotfiles

log_ln
task_header "Configuring neovim"
configure_neovim
configure_wezterm

log_ln
task_header "Configuring fonts"
install_fonts

log_ln
task_header "Installing homebrew casks"
install_brew_casks

log_ln
task_header "Syncing app icons"
sync_app_icons

log_ln
task_header "List of things that need manual setup"
log_todo "🔒" "Log into all the things"
log_todo "🔋" "Restore Alfred pack"
log_todo "🐘" "Restore TablePlus license"
log_todo "🐳" "Install docker"

log_ln
log_ln "All done 🚀"

log_ln
log_ln "$(grey "Script logs can be found here: $(underline "$LOG_FILE_PATH")")"
log_ln
log_ln "$(grey "The log file will be automatically deleted in 30 days")"
log_ln "$(grey "To keep the log file, move it out of '/tmp/':")"
log_ln "$(grey "cp $LOG_FILE_PATH ~/Desktop")"

write_to_log
write_to_log "================================================"
write_to_log "            END - $(date)"
write_to_log "================================================"
