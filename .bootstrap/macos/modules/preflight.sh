#!/usr/bin/env bash

run_preflight() {
  : >"$LOG_FILE"

  sudo -v
  phase "Preflight"
  step "macos" test "$(uname -s)" = Darwin -- false
  step "xcode command line tools" xcode-select -p -- false
  step "internet" nc -zw1 github.com 443 -- false
  keep_sudo_warm
}
