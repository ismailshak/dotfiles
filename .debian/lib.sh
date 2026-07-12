#!/usr/bin/env bash
#
# .debian/lib.sh - common functions for the bootstrap scripts

set -euo pipefail

LOG_FILE="${LOG_FILE:-/tmp/bootstrap-log.log}"
SPINNER="⣷⣯⣟⡿⢿⣻⣽⣾"

APPS_USER="apps"
APPS_DIR="/home/${APPS_USER}"
USERNAME="$(whoami)"
USER_HOME="$(getent passwd "$USERNAME" | cut -d: -f6)"
CODE_DIR="${CODE_DIR:-$USER_HOME/code}"
DOTFILES_REPO="ismailshak/dotfiles"

# -- Output --

# Redirect stdout and stderr to the log file directly
# (every new log line is prefixed with a timestamp).
exec 3>&1
exec > >(while IFS= read -r line; do printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$line"; done >>"$LOG_FILE") 2>&1

# Send output to the original stdout (the terminal), bypassing the log file.
tty() { printf '%s' "$*" >&3; }

# Send output to the original stdout (the terminal) with a newline, bypassing the log file.
tty_ln() { printf '%s\n' "$*" >&3; }

# -- Rendering --

c_green=$'\033[32m'
c_red=$'\033[31m'
c_grey=$'\033[90m'
c_yellow=$'\033[33m'
c_bold=$'\033[1m'
c_reset=$'\033[0m'

ok() { tty_ln "  ${c_green}✓${c_reset} $*"; }
skip() { tty_ln "  ${c_grey}•${c_reset} $* ${c_grey}(already done)${c_reset}"; }
fail() { tty_ln "  ${c_red}✗${c_reset} $*"; }
note() { tty_ln "    ${c_grey}$*${c_reset}"; }
warn() { tty_ln "  ${c_yellow}⚠${c_reset}  $*"; }

# Run a command in the background and show a spinner while it runs.
# $1: label to show next to the spinner
# $@: command to run in the background
spin() {
  local label=$1
  echo "--- step: $label ($(date '+%H:%M:%S')) ---" # goes to log via exec redirect

  shift
  "$@" & # output already goes to the log (see exec above)
  local pid=$! i=0 n=${#SPINNER}
  while kill -0 "$pid" 2>/dev/null; do
    i=$(((i + 1) % n))
    tty $'\r'"  ${SPINNER:i:1} ${label}…"
    sleep 0.1
  done
  wait "$pid"
}

# Print a phase header to the terminal.
phase() {
  tty_ln ""
  tty_ln "${c_bold}- $*${c_reset}"
}

# Run a step with optional guard commands.
# If any guard command succeeds, the step is skipped.
# $1: label to show next to the spinner
# $@: guard commands (optional), followed by `--`, followed by the action command
#
# Example:
#   step "Install foo" command -v foo -- sudo apt install -y foo
step() {
  local label=$1
  shift
  local -a guard=() action=()
  local into=guard
  while (($#)); do
    if [[ $1 == -- ]]; then
      into=action
      shift
      continue
    fi
    [[ $into == guard ]] && guard+=("$1") || action+=("$1")
    shift
  done

  if ((${#guard[@]})) && "${guard[@]}" &>/dev/null; then
    skip "$label"
    return 0
  fi

  local rc=0
  spin "$label" "${action[@]}" || rc=$?
  if ((rc == 0)); then
    tty $'\r\033[0K' # clear the spinner line
    ok "$label"
  else
    tty $'\r\033[0K' # clear the spinner line
    fail "$label (exit $rc)"
    tail -n 8 "$LOG_FILE" >&3 2>/dev/null || true # show what happened inline (no hunting in /tmp)
    return "$rc"
  fi
}

# -- User input --

# Ask for confirmation (yes/no) from the user.
# $1: prompt to show
# $2: default answer (Y/N), optional, defaults to N
# Returns 0 if the user confirmed, 1 otherwise.
#
# Example:
#  if confirm "Do you want to continue?" Y; then
confirm() {
  local q=$1 default=${2:-N} reply
  [[ -t 0 ]] || {
    [[ $default == [Yy] ]]
    return
  }
  tty "$q [$([[ $default == [Yy] ]] && echo Y/n || echo y/N)] "
  read -r reply </dev/tty
  reply=${reply:-$default}
  [[ $reply == [Yy] ]]
}

# Ask for input from the user and store it in a variable.
# $1: prompt to show
# $2: name of the variable to store the answer in
#
# Example:
#   ask "Enter your name" name
ask() {
  local secret=0
  [[ $1 == -s ]] && {
    secret=1
    shift
  }
  local prompt=$1 __var=$2 __val char
  tty "$prompt "
  if ((secret)); then
    __val=''
    while IFS= read -r -s -n1 char </dev/tty; do
      [[ -z $char ]] && break
      if [[ $char == $'\177' || $char == $'\b' ]]; then
        if ((${#__val} > 0)); then
          __val=${__val%?}
          tty $'\b \b'
        fi
      else
        __val+=$char
        tty '*'
      fi
    done
    tty_ln ""
  else read -r __val </dev/tty; fi
  printf -v "$__var" '%s' "$__val"
}

# Ask for multiline input from the user and store it in a variable.
# $1: prompt to show
# $2: name of the variable to store the answer in
#
# Example:
#  ask_multiline "Enter your SSH public key" ssh_key
ask_multiline() {
  local __var=$2 __val='' line
  tty "$1 (press Enter twice to submit): "
  tty_ln ""
  while IFS= read -r line </dev/tty; do
    [[ -z $line ]] && break
    __val+="$line"$'\n'
  done
  printf -v "$__var" '%s' "${__val%$'\n'}"
}

# -- Cleanup --

declare -a _CLEANUP_DIRS=()
SUDO_KEEPALIVE_PID=""

cleanup() {
  local code=$?
  [[ -n $SUDO_KEEPALIVE_PID ]] && kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
  ((${#_CLEANUP_DIRS[@]})) && rm -rf "${_CLEANUP_DIRS[@]}"
  tput cnorm 2>/dev/null || true
  exit "$code"
}

trap cleanup EXIT
trap 'exit 130' INT TERM # Ctrl-C → 130, which then fires EXIT

# Create a temporary directory and register it for cleanup.
# Returns the path of the temporary directory.
mktempd() {
  local d
  d=$(mktemp -d)
  _CLEANUP_DIRS+=("$d")
  printf '%s' "$d"
}

# Install a file to the system with the given permissions.
# $1: source file
# $2: destination file
# $3: permissions (optional, defaults to 0644)
install_system_file() {
  sudo install -D -m "${3:-0644}" "$1" "$2"
}
