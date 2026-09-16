#!/usr/bin/env bash

set -euo pipefail

LOG_FILE="${LOG_FILE:-/tmp/bootstrap-log.log}"
SPINNER="⣷⣯⣟⡿⢿⣻⣽⣾"

# -- Output --

# stdout and stderr go to the log with a timestamp per line; fd 3 is the terminal
exec 3>&1
exec > >(while IFS= read -r line; do printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$line"; done >>"$LOG_FILE") 2>&1

tty() { printf '%s' "$*" >&3; }
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

spin() {
  local label=$1
  echo "--- step: $label ($(date '+%H:%M:%S')) ---"

  shift
  "$@" &
  local pid=$! i=0 n=${#SPINNER}
  while kill -0 "$pid" 2>/dev/null; do
    i=$(((i + 1) % n))
    tty $'\r'"  ${SPINNER:i:1} ${label}…"
    sleep 0.1
  done
  wait "$pid"
}

phase() {
  tty_ln ""
  tty_ln "${c_bold}- $*${c_reset}"
}

# step <label> [guard...] -- <action...>: skipped when the guard succeeds, aborts with the log tail when the action fails
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
  tty $'\r\033[0K'
  if ((rc == 0)); then
    ok "$label"
  else
    fail "$label (exit $rc)"
    tail -n 8 "$LOG_FILE" >&3 2>/dev/null || true
    return "$rc"
  fi
}

# -- User input --

# confirm <question> [Y|N]: returns 0 on yes; without a tty the default answer is taken
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

# ask [-s] <prompt> <var>: stores the answer in the named variable; -s masks the input
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

# ask_multiline <prompt> <var>: stores the answer in the named variable; an empty line ends the input
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
trap 'exit 130' INT TERM # Ctrl-C exits 130, which then fires EXIT

keep_sudo_warm() {
  (while true; do
    sudo -n true
    sleep 50
  done) &
  SUDO_KEEPALIVE_PID=$! # cleanup() reaps this
}

mktempd() {
  local d
  d=$(mktemp -d)
  _CLEANUP_DIRS+=("$d")
  printf '%s' "$d"
}

install_system_file() {
  sudo install -D -m "${3:-0644}" "$1" "$2"
}
