#!/usr/bin/env bash
#
# /usr/local/bin/backup-server.sh - runs as the root user via the systemd unit and performs a backup of the docker volumes using restic.
#
# Note: environment variables for restic are loaded by the systemd unit restic-backup.service

set -euo pipefail

LOG=$(mktemp)

# Clean up the temporary log file on exit
trap 'rm -f "$LOG"' EXIT

# On any error, send the tail of the log to the healthcheck's /fail endpoint, then exit.
trap 'curl -fsS -m 10 --retry 3 --data-raw "$(tail -c 4000 "$LOG")" "$HC_URL/fail" >/dev/null || true' ERR

# Measures script duration when /start is called
curl -fsS -m 10 --retry 3 "$HC_URL/start" >/dev/null || true

COMPOSE_DIR="/home/apps/atlas"
{
  shopt -s nullglob
  echo "[$(date)] Running backup hooks..."
  for hook in "$COMPOSE_DIR"/backup-hooks/*.sh; do
    [[ -x "$hook" ]] && {
      echo "  → $(basename "$hook")"
      "$hook"
    }
  done

  echo "[$(date)] Backing up the data root..."
  restic backup /srv/atlas/data --tag atlas-data --tag "$(date +%F)"

  echo "[$(date)] Pruning old snapshots..."
  restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 3 --prune

  if [[ $(date +%u) -eq 7 ]]; then
    echo "[$(date)] Running weekly repository integrity check..."
    restic check
  fi

  echo "[$(date)] Backup completed successfully."

} |& tee "$LOG"

# Script completed successfully
curl -fsS -m 10 --retry 3 "$HC_URL" >/dev/null || true
