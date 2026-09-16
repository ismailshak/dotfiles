#!/usr/bin/env bash
#
# /usr/local/bin/apps-up.sh - runs as the apps user via the systemd unit and decrypts the secrets for docker compose to use.

set -euo pipefail
cd /home/apps/atlas

# The apps user needs read access to its own age key.
export SOPS_AGE_KEY_FILE=/home/apps/.config/sops/age/keys.txt

# Restrict new file permissions to owner-only (0600) so decrypted secret
# files are not readable by group or other users.
umask 077
sops -d secrets.env >.env
sops -d secrets.redlib.env >.env.redlib

docker compose up -d
