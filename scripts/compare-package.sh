#!/usr/bin/env bash
# Run from a package root, before compiling any local solution.
set -euo pipefail
tools=$(realpath "${1:?directory containing landrun and nanoda_bin required}")
evidence=$(realpath -m "${2:?new evidence directory required}")
mkdir -p "$evidence"
test "$(id -u)" -ne 0
test -x "$tools/landrun" && test -x "$tools/nanoda_bin"
if [[ -d .lake/build && -n $(find .lake/build -type f -name '*.olean' -print -quit) ]]; then
  echo 'Comparator requires a fresh local package build directory.' >&2
  exit 1
fi

# Put the toolchain binaries ahead of the elan shims for isolated child builds.
if [[ $(dirname "$(command -v lake)") == "${ELAN_HOME:-$HOME/.elan}/bin" ]]; then
  real_lake=$(elan which lake)
  export PATH="$(dirname "$real_lake"):$PATH"
fi
lake build Comparator/comparator lean4export/lean4export
comparator=$(realpath .lake/packages/Comparator/.lake/build/bin/comparator)
exporter=$(realpath .lake/packages/lean4export/.lake/build/bin/lean4export)

# Hosted runners need no user bus when the transient system service runs with the
# invoking user's uid/gid. Both paths enforce the same socket restriction.
if systemctl --user show-environment >/dev/null 2>&1; then
  service=(systemd-run --user)
else
  service=(sudo -n systemd-run --uid="$(id -u)" --gid="$(id -g)")
fi
set +e
"${service[@]}" --wait --pipe --collect --working-directory="$PWD" \
  --property=RestrictAddressFamilies=~AF_UNIX --property=NoNewPrivileges=yes \
  --setenv="PATH=$PATH" --setenv="HOME=$HOME" \
  --setenv="COMPARATOR_LANDRUN=$tools/landrun" --setenv="COMPARATOR_NANODA=$tools/nanoda_bin" \
  --setenv="COMPARATOR_LEAN4EXPORT=$exporter" \
  -- "$(command -v lake)" env "$comparator" comparator.json 2>&1 | tee "$evidence/comparator.log"
status=${PIPESTATUS[0]}
set -e
printf '%s\n' "$status" > "$evidence/comparator.exit"
exit "$status"
