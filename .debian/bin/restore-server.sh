#!/usr/bin/env bash
#
# /usr/local/bin/restore-server.sh - runs manually as the root user to restore the docker volumes using restic
#
# Note: environment variables for restic are assumed to be loaded into the environment before this script is called

set -euo pipefail

COMPOSE_DIR="/home/apps/atlas"

DRY_RUN=""
if [[ ${1:-} == --dry-run ]]; then
  DRY_RUN="--dry-run"
fi

echo "[$(date)] Restoring the data root..."
restic restore $DRY_RUN latest --target / --include /srv/atlas/data

shopt -s nullglob
echo "[$(date)] Running restore hooks..."
for hook in "$COMPOSE_DIR"/restore-hooks/*.sh; do
  [[ -x "$hook" ]] && {
    echo "  → $(basename "$hook")"

    if [[ -n $DRY_RUN ]]; then
      echo "    (dry run) $hook"
    else
      "$hook"
    fi
  }
done

echo "[$(date)] Restore completed successfully."
