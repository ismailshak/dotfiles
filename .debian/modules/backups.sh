#!/usr/bin/env bash
#
# .debian/modules/backups.sh - set up snapshots and remote back ups
#
# (depends on Docker [packages.sh] and the age key [secrets.sh])

RESTIC_ENV_FILE="/etc/restic/env"

configure_restic_env() {
  sudo mkdir -p /etc/restic
  sudo chmod 700 /etc/restic

  RESTIC_REPOSITORY="$1"
  RESTIC_PASSWORD="$2"
  BACKBLAZE_KEY_ID="$3"
  BACKBLAZE_APP_KEY="$4"
  HC_URL="$5"

  # Owned by root
  sudo tee "$RESTIC_ENV_FILE" >/dev/null <<EOF
export RESTIC_REPOSITORY="$RESTIC_REPOSITORY"
export RESTIC_PASSWORD="$RESTIC_PASSWORD"
export AWS_ACCESS_KEY_ID="$BACKBLAZE_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$BACKBLAZE_APP_KEY"
export HC_URL="$HC_URL"
EOF

  sudo chmod 600 "$RESTIC_ENV_FILE"
}

install_backup_unit() {
  install_system_file config/systemd/restic-backup.service /etc/systemd/system/restic-backup.service
  install_system_file config/systemd/restic-backup.timer /etc/systemd/system/restic-backup.timer
  sudo systemctl daemon-reload
  sudo systemctl enable --now restic-backup.timer
}

run_backups() {
  phase "Snapshots & Backups"

  local RESTIC_REPOSITORY RESTIC_PASSWORD BACKBLAZE_KEY_ID BACKBLAZE_APP_KEY HC_URL

  ask "Restic repository:" RESTIC_REPOSITORY
  ask -s "Restic password:" RESTIC_PASSWORD
  ask -s "Backblaze key ID:" BACKBLAZE_KEY_ID
  ask -s "Backblaze app key:" BACKBLAZE_APP_KEY
  ask -s "Healthcheck URL:" HC_URL

  step "restic env file" false -- configure_restic_env "$RESTIC_REPOSITORY" "$RESTIC_PASSWORD" "$BACKBLAZE_KEY_ID" "$BACKBLAZE_APP_KEY" "$HC_URL"
  step "install backup-server.sh" test -f /usr/local/bin/backup-server.sh -- install_system_file bin/backup-server.sh /usr/local/bin/backup-server.sh 755
  step "restic-backup.service" systemctl is-enabled restic-backup.timer -- install_backup_unit
  step "install restore-server.sh" test -f /usr/local/bin/restore-server.sh -- install_system_file bin/restore-server.sh /usr/local/bin/restore-server.sh 755
}
