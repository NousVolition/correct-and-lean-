#!/usr/bin/env bash
set -euo pipefail
src=$(cd -- "$(dirname -- "$0")" && pwd)
dev=/home/nsverify/verification/hug-existence-dev-20261030
export PATH=/home/nsverify/verification/bin:/opt/lean-audit/lean-4.34.0-rc2-linux/bin:/usr/bin:/bin
mkdir -p "$dev/.lake/build/lib/lean"
if [ ! -e "$dev/.lake/packages" ]; then
 ln -s /home/nsverify/verification/project/.lake/packages "$dev/.lake/packages"
 for module in HugModel ActiveHugModel HugBarrier ActiveHugSolution; do
  cp /home/nsverify/verification/hug-squeeze-20261030/.lake/build/lib/lean/$module.olean "$dev/.lake/build/lib/lean/"
 done
fi
cp "$src"/*.lean "$src/lakefile.toml" "$src/lake-manifest.json" "$src/lean-toolchain" "$dev/"
cd "$dev"
for module in "$@"; do
 lake env lean -o ".lake/build/lib/lean/$module.olean" "$module.lean"
done
