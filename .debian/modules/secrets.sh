#!/usr/bin/env bash
#
# .debian/modules/secrets.sh - install age keys for sops

install_age_key() {
  local target_user="$1"
  local target_home
  target_home=$(getent passwd "$target_user" | cut -d: -f6)
  local dir="${target_home}/.config/sops/age"

  sudo mkdir -p "$dir"
  printf '%s\n' "$AGE_KEY" | sudo tee "${dir}/keys.txt" >/dev/null
  sudo chown -R "${target_user}:${target_user}" "${target_home}/.config/sops"
  sudo chmod 600 "${dir}/keys.txt"
}

run_secrets() {
  phase "Secrets"
  local AGE_KEY

  ask_multiline "Paste the age private key (from 1Password)" AGE_KEY

  step "age key for $APPS_USER" test -f "${APPS_DIR}/.config/sops/age/keys.txt" -- install_age_key "$APPS_USER"
  step "age key for $USERNAME" test -f "${USER_HOME}/.config/sops/age/keys.txt" -- install_age_key "$USERNAME"
  step "install apps-up.sh" test -f /usr/local/bin/apps-up.sh -- install_system_file bin/apps-up.sh /usr/local/bin/apps-up.sh 0755
}
