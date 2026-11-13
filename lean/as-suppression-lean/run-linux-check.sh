#!/usr/bin/env bash
# Fresh protected-reference comparison, Lean kernel replay, nanoda, then Lake.
set -euo pipefail
test "$(id -u)" -ne 0
source_dir=$(cd -- "$(dirname -- "$0")" && pwd)
verify_root=${VERIFY_ROOT:-$HOME/verification}
check_dir=${1:?Supply a new verification directory}
test ! -e "$check_dir"
export PATH="$verify_root/bin:/opt/lean-audit/lean-4.34.0-rc2-linux/bin:/usr/local/bin:/usr/bin:/bin"
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus
export LEAN_NUM_THREADS=4
mkdir -p "$check_dir/.lake" "$check_dir/evidence"
cp "$source_dir"/*.lean "$source_dir/lakefile.toml" "$source_dir/lake-manifest.json" \
  "$source_dir/lean-toolchain" "$source_dir/comparator.json" \
  "$source_dir/suppression-reference-freeze.json" "$source_dir/verification-inputs.json" \
  "$source_dir/source-equations.json" "$source_dir/source-protocol.json" \
  "$source_dir/verify-evidence.py" "$source_dir/run-linux-check.sh" "$check_dir/"
ln -s "$verify_root/project/.lake/packages" "$check_dir/.lake/packages"
cd "$check_dir"
python3 verify-evidence.py preflight "$verify_root"
date -u -Iseconds > evidence/comparator.started
set +e
systemd-run --user --wait --pipe --collect \
  --property=RestrictAddressFamilies=~AF_UNIX -E PATH="$PATH" -E LEAN_NUM_THREADS=4 \
  -E COMPARATOR_LANDRUN="$verify_root/bin/landrun" \
  -E COMPARATOR_LEAN4EXPORT="$verify_root/project/.lake/packages/lean4export/.lake/build/bin/lean4export" \
  -E COMPARATOR_NANODA="$verify_root/nanoda_lib/target/release/nanoda_bin" \
  --working-directory="$PWD" -- "$verify_root/bin/lake" env \
  "$verify_root/project/.lake/packages/Comparator/.lake/build/bin/comparator" comparator.json \
  2>&1 | tee evidence/comparator.log
comparator_exit=${PIPESTATUS[0]}
set -e
printf '%s\n' "$comparator_exit" > evidence/comparator.exit
date -u -Iseconds > evidence/comparator.finished
if [ "$comparator_exit" -eq 0 ]; then
  set +e
  lake build 2>&1 | tee evidence/lake-build.log
  build_exit=${PIPESTATUS[0]}
  set -e
else
  build_exit=99
fi
printf '%s\n' "$build_exit" > evidence/lake-build.exit
python3 verify-evidence.py postflight "$verify_root"
mkdir -p "$source_dir/evidence-linux"
cp evidence/* "$source_dir/evidence-linux/"
test "$comparator_exit" -eq 0
test "$build_exit" -eq 0
