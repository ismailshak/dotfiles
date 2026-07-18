#!/usr/bin/env bash
# .debian/bootstrap.sh - bootstrap a new Debian server
#
# (initiated by install.sh)

set -euo pipefail

cd "$(dirname "$0")"

# shellcheck source=./.debian/lib.sh
source ./lib.sh

# shellcheck source=./.debian/modules/preflight.sh
source "modules/preflight.sh"
run_preflight

# Ordered list of modules to run
MODULES=(packages users access secrets apps health backups)

only=""
[[ ${1:-} == --only ]] && only=${2:-}
for m in "${MODULES[@]}"; do
  [[ -n $only && $m != "$only" ]] && continue
  # shellcheck source=/dev/null
  source "modules/${m}.sh"
  "run_${m}"
done

tty_ln ""
tty_ln "${c_green}All done 🚀${c_reset}  ${c_grey}log: $LOG_FILE${c_reset}"
