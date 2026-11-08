#!/usr/bin/env bash
# The release ID and SHA-256 come from the official Lean release metadata.
set -euo pipefail
mode=${1:?fetch or install required}
tools=${2:?tools directory required}
tag=v4.34.0-rc2
archive="$tools/lean-$tag-linux.tar.zst"
digest=3d011041203acacf300d343a39673f7d233743397993797c941346ae9e5df1a8
asset=https://api.github.com/repos/leanprover/lean4/releases/assets/523667199
release="https://github.com/leanprover/lean4/releases/download/$tag/lean-${tag#v}-linux.tar.zst"

verify() {
  printf '%s  %s\n' "$digest" "$archive" | sha256sum --check
}

case "$mode" in
  fetch)
    mkdir -p "$tools"
    for url in "$asset" "$release"; do
      if curl --fail --location --silent --show-error --retry 2 --retry-delay 2 \
          --connect-timeout 20 --max-time 480 -H 'Accept: application/octet-stream' \
          --output "$archive" "$url" && verify; then
        exit 0
      fi
    done
    echo 'Neither official release endpoint supplied the pinned archive.' >&2
    exit 1
    ;;
  install)
    prefix=${3:?installation directory required}
    test "$(tr -d '\r\n' <lean-toolchain)" = "leanprover/lean4:$tag"
    verify
    mkdir -p "$prefix"
    tar --zstd -xf "$archive" --strip-components=1 -C "$prefix"
    "$prefix/bin/lean" --version
    echo "$prefix/bin" >> "${GITHUB_PATH:?GitHub Actions path file required}"
    ;;
  *) exit 2 ;;
esac
