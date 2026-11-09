#!/usr/bin/env bash
# Build the same two independent checker tools used by the saved Linux audits.
set -euo pipefail
out=$(realpath -m "${1:?output directory required}")
mkdir -p "$out"
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT

checkout_pin() {
  local name=$1 url=$2 rev=$3
  git -C "$work" init --quiet "$name"
  git -C "$work/$name" fetch --quiet --depth=1 "$url" "$rev"
  git -C "$work/$name" checkout --quiet --detach FETCH_HEAD
  test "$(git -C "$work/$name" rev-parse HEAD)" = "$rev"
}

checkout_pin landrun https://github.com/Zouuup/landrun.git ec104f6edc1e14d7fec6d31146f1ec6f9c192c5a
(cd "$work/landrun" && go build -mod=readonly -trimpath -o "$out/landrun" ./cmd/landrun)
checkout_pin nanoda https://github.com/ammkrn/nanoda_lib.git d0a02cc5defadd683f62f9d078f41688314fa31f
(cd "$work/nanoda" && cargo build --locked --release --bin nanoda_bin)
install -m 755 "$work/nanoda/target/release/nanoda_bin" "$out/nanoda_bin"
sha256sum "$out/landrun" "$out/nanoda_bin"
