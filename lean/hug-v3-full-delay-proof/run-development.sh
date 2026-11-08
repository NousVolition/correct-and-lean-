#!/usr/bin/env bash
export VERIFY_ROOT="${VERIFY_ROOT:-$HOME/verification}"
set -euo pipefail
source_dir=$(cd -- "$(dirname -- "$0")" && pwd)
dev="$VERIFY_ROOT"/hug-v3-full-delay-dev-20261102
export PATH="$VERIFY_ROOT"/bin:/opt/lean-audit/lean-4.34.0-rc2-linux/bin:/usr/local/bin:/usr/bin:/bin
if [ ! -d "$dev" ]; then
 mkdir -p "$dev/.lake"
 ln -s "$VERIFY_ROOT"/project/.lake/packages "$dev/.lake/packages"
fi
cp "$source_dir"/*.lean "$source_dir/lakefile.toml" "$source_dir/lake-manifest.json" "$source_dir/lean-toolchain" "$dev/"
cd "$dev"
label=$1
shift
test ! -e "$source_dir/dev-$label.log"
set +e
lake build "$@" 2>&1 | tee "$source_dir/dev-$label.log"
code=${PIPESTATUS[0]}
set -e
printf '%s\n' "$code" > "$source_dir/dev-$label.exit"
exit "$code"
