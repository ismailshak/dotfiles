#!/usr/bin/env bash
#
# .debian/modules/apps.sh - installs the apps systemd service and runs the compose stack.
#
# (depends on Docker [packages.sh] and the age key [secrets.sh])

APPS_SERVICE_FILE="/etc/systemd/system/apps.service"
COMPOSE_REPO="ismailshak/atlas"

setup_apps_ssh() {
  local ssh_dir="${APPS_DIR}/.ssh"
  local key_file="${ssh_dir}/id_ed25519"

  sudo mkdir -p "$ssh_dir"
  sudo ssh-keygen -t ed25519 -C "${APPS_USER}@$(hostname)" -f "$key_file" -N "" -q
  sudo ssh-keyscan github.com 2>/dev/null | sudo tee "${ssh_dir}/known_hosts" >/dev/null
  sudo chown -R "${APPS_USER}:${APPS_USER}" "$ssh_dir"
  sudo chmod 700 "$ssh_dir"
  sudo chmod 600 "$key_file" "${ssh_dir}/known_hosts"
  sudo chmod 644 "${key_file}.pub"

  note "Add the deploy key to the atlas https://github.com/${COMPOSE_REPO}/settings/keys (check $LOG_FILE)"
  echo "------ atlas deploy key start -----"
  sudo cat "${key_file}.pub"
  echo "------ atlas deploy key end -----"
}

clone_compose_repo() {
  local tmp
  tmp=$(mktempd)
  GIT_SSH_COMMAND="ssh -i ${APPS_DIR}/.ssh/id_ed25519 -o StrictHostKeyChecking=no" gh repo clone "$COMPOSE_REPO" "$tmp/atlas"
  sudo mv "$tmp/atlas" "${APPS_DIR}/atlas" # into apps' home, as root
  sudo chown -R "${APPS_USER}:${APPS_USER}" "${APPS_DIR}/atlas"
}

install_apps_unit() {
  install_system_file config/systemd/apps.service "$APPS_SERVICE_FILE"
  sudo systemctl daemon-reload
  sudo systemctl enable apps.service
}

run_apps() {
  phase "Hosted apps (the compose stack)"
  confirm "Clone the compose repo and run the stack?" N || {
    note "skipping the app stack"
    return 0
  }

  step "apps SSH key" sudo test -f "${APPS_DIR}/.ssh/id_ed25519" -- setup_apps_ssh
  step "compose repo" test -d "${APPS_DIR}/atlas" -- clone_compose_repo
  step "docker.service" systemctl is-active docker.service -- sudo systemctl enable --now docker.service
  step "apps.service" test -f "$APPS_SERVICE_FILE" -- install_apps_unit
  step "stack up" systemctl is-active apps.service -- sudo systemctl restart apps.service
  note "status: systemctl status apps.service   |   logs: journalctl -u apps.service -f"
}
