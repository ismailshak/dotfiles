#!/usr/bin/env bash
#
# .debian/modules/preflight.sh - check for prerequisites before running the bootstrap (and keep sudo alive for background processes)

keep_sudo_warm() {
  (while true; do
    sudo -n true
    sleep 50
  done) &
  SUDO_KEEPALIVE_PID=$! # cleanup() in lib.sh reaps this
}

run_preflight() {
  # wipe LOG_FILE on each run, but keep the file itself so we can tail it later
  : >"$LOG_FILE"

  # # Switch to global sudo timestamp so backgrounded processes (spin) can use cached creds
  # echo 'Defaults timestamp_type=global' | sudo tee /etc/sudoers.d/bootstrap-timestamp >/dev/null

  sudo -v # prompt interactively before any output
  phase "Preflight"
  step "debian" test -f /etc/debian_version -- true
  step "internet" nc -zw1 deb.debian.org 443 -- true
  keep_sudo_warm
}
