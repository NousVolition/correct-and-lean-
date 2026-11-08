#!/usr/bin/env bash
export VERIFY_ROOT="${VERIFY_ROOT:-$HOME/verification}"
set -euo pipefail
src=$(cd -- "$(dirname -- "$0")" && pwd)
dev="$VERIFY_ROOT"/hug-existence-dev-20261030
export PATH="$VERIFY_ROOT"/bin:/opt/lean-audit/lean-4.34.0-rc2-linux/bin:/usr/bin:/bin
mkdir -p "$dev/.lake/build/lib/lean"
if [ ! -e "$dev/.lake/packages" ]; then
 ln -s "$VERIFY_ROOT"/project/.lake/packages "$dev/.lake/packages"
 for module in HugModel ActiveHugModel HugBarrier ActiveHugSolution; do
  cp "$VERIFY_ROOT"/hug-squeeze-20261030/.lake/build/lib/lean/$module.olean "$dev/.lake/build/lib/lean/"
 done
fi
cp "$src"/*.lean "$src/lakefile.toml" "$src/lake-manifest.json" "$src/lean-toolchain" "$dev/"
cd "$dev"
for module in "$@"; do
 lake env lean -o ".lake/build/lib/lean/$module.olean" "$module.lean"
done
