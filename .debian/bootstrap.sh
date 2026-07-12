#!/usr/bin/env bash
# .debian/bootstrap.sh - bootstrap a new Debian server
#
# (initiated by install.sh)

set -euo pipefail

cd "$(dirname "$0")"

# shellcheck source=./.debian/lib.sh
source ./lib.sh

# Ordered list of modules to run
MODULES=(preflight packages users access secrets apps health)

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
