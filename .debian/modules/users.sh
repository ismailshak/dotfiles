#!/usr/bin/env bash
#
# .debian/modules/users.sh - create and manage users and groups

in_group() { id -nG "$1" 2>/dev/null | grep -qw "$2"; }

create_apps_user() {
  sudo useradd --system --create-home --home-dir "$APPS_DIR" \
    --shell /usr/sbin/nologin "$APPS_USER"
}

run_users() {
  phase "Users & Permissions"
  local me
  me=$(whoami)

  step "$me → sudo group" in_group "$me" sudo -- sudo usermod -aG sudo "$me"
  step "$me → docker group" in_group "$me" docker -- sudo usermod -aG docker "$me"
  step "service user: $APPS_USER" id "$APPS_USER" -- create_apps_user
  step "$APPS_USER → docker group" in_group "$APPS_USER" docker -- sudo usermod -aG docker "$APPS_USER"
  step "$me → zsh" [ "$(getent passwd "$me" | cut -d: -f7)" = "$(command -v zsh)" ] -- sudo chsh -s "$(command -v zsh)" "$me"

  note "group changes take effect on next login"
}
