#!/usr/bin/env bash
#
# .bootstrap/debian/modules/users.sh - create and manage users and groups

# in_group <user> <group>: reads the group database. It is true as soon as usermod has run, before the next login.
in_group() { [[ " $(id -nG "$1" 2>/dev/null) " == *" $2 "* ]]; }

# Succeeds when this shell has the user on provided groups. A group added by usermod is activated in the next login.
groups_active() {
  local group active
  active=" $(id -nG) "
  for group in $(id -nG "$1"); do
    [[ $active == *" $group "* ]] || return 1
  done
}

create_apps_user() {
  sudo useradd --system --create-home --home-dir "$APPS_DIR" \
    --shell /usr/sbin/nologin "$APPS_USER"
}

set_login_shell_zsh() {
  local zsh_path
  zsh_path=$(command -v zsh)
  sudo chsh -s "$zsh_path" "$1"
}

login_shell_is_zsh() { [[ $(getent passwd "$1" | cut -d: -f7) == */zsh ]]; }

run_users() {
  phase "Users & Permissions"
  local me
  me=$(whoami)

  step "$me → sudo group" in_group "$me" sudo -- sudo usermod -aG sudo "$me"
  step "$me → docker group" in_group "$me" docker -- sudo usermod -aG docker "$me"
  # adm can read /var/log and the system journal without sudo
  step "$me → adm group" in_group "$me" adm -- sudo usermod -aG adm "$me"
  step "service user: $APPS_USER" id "$APPS_USER" -- create_apps_user
  step "$APPS_USER → docker group" in_group "$APPS_USER" docker -- sudo usermod -aG docker "$APPS_USER"
  step "$me → zsh" login_shell_is_zsh "$me" -- set_login_shell_zsh "$me"

  groups_active "$me" || note "group changes take effect on next login"
}
