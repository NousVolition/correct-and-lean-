#!/usr/bin/env bash
set -euo pipefail
test "$(id -u)" -ne 0
src=$(cd "$(dirname "$0")" && pwd)
mode=${1:?pass dev or verify}
shift
cache=${HUG_VERIFICATION_ROOT:-$HOME/verification}
up="$cache/project"
export PATH="$cache/bin:/opt/lean-audit/lean-4.34.0-rc2-linux/bin:/usr/local/bin:/usr/bin:/bin"
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus
export LEAN_NUM_THREADS=6
case "$mode" in
 dev) dir="$cache/as-signed-vortex-dev" ;;
 verify) dir=$(mktemp -d "$cache/as-signed-vortex-check.XXXXXXXX") ;;
 *) exit 2 ;;
esac
mkdir -p "$dir/.lake/packages"
cp "$src"/*.lean "$src/lake-manifest.json" "$src/lakefile.toml" "$src/lean-toolchain" "$dir/"
if [ ! -L "$dir/.lake/packages/NavierStokesAndEuler" ]; then
 ln -s "$up" "$dir/.lake/packages/NavierStokesAndEuler"
fi
for dep in "$up"/.lake/packages/*; do
 target="$dir/.lake/packages/$(basename "$dep")"
 if [ ! -e "$target" ]; then ln -s "$dep" "$target"; fi
done
cd "$dir"
if [ "$mode" = dev ]; then
 lake build "$@"
 exit
fi
cp "$src/comparator.json" "$src/reference-freeze.json" .
mkdir evidence
python3 - <<'PY'
from pathlib import Path
import hashlib, json, re, subprocess
p=Path('.')
locked=json.loads(Path('reference-freeze.json').read_text())
cfg=json.loads(Path('comparator.json').read_text())
assert cfg['theorem_names']==locked['theorems'] and len(set(locked['theorems']))==25
assert cfg['enable_nanoda'] and cfg['permitted_axioms']==['propext','Quot.sound','Classical.choice']
for n,h in locked['files'].items():
 assert hashlib.sha256(Path(n).read_bytes()).hexdigest()==h,n
for name in locked['solution_modules']:
 source=Path(name).read_text()
 assert not re.search(r'\b(sorryAx|sorry|admit|axiom|native_decide)\b',source),name
assert not (p/'.lake/build').exists()
s={}
for d in json.loads(Path('lake-manifest.json').read_text())['packages']:
 path=Path('.lake/packages')/d['name']
 rev=subprocess.check_output(['git','-C',path,'rev-parse','HEAD'],text=True).strip()
 assert rev==d['rev'] and not subprocess.check_output(['git','-C',path,'status','--porcelain']).strip(), d['name']
 s[d['name']]=rev
print('Frozen reference; new solution build directory; all dependency revisions and source trees checked.',flush=True)
Path('evidence/preflight.json').write_text(json.dumps({'dependencies':s,'files':locked['files']},indent=2)+'\n')
PY
date -u -Iseconds > evidence/start.txt
set +e
systemd-run --user --wait --pipe --collect --property=RestrictAddressFamilies=~AF_UNIX \
 -E PATH="$PATH" -E COMPARATOR_LANDRUN="$cache/bin/landrun" \
 -E COMPARATOR_LEAN4EXPORT="$up/.lake/packages/lean4export/.lake/build/bin/lean4export" \
 -E COMPARATOR_NANODA="$cache/nanoda_lib/target/release/nanoda_bin" \
 --working-directory="$dir" -- "$cache/bin/lake" env \
 "$up/.lake/packages/Comparator/.lake/build/bin/comparator" comparator.json \
 2>&1 | tee evidence/comparator.log
cmp=${PIPESTATUS[0]}
lake build 2>&1 | tee evidence/lean-build.log
build=${PIPESTATUS[0]}
lake env lean Solution.lean 2>&1 | tee evidence/axioms.log
axioms=${PIPESTATUS[0]}
set -e
printf '%s\n' "$cmp" > evidence/comparator.exit
printf '%s\n' "$build" > evidence/lean-build.exit
printf '%s\n' "$axioms" > evidence/axioms.exit
date -u -Iseconds > evidence/finish.txt
python3 - <<'PY'
import json,hashlib,subprocess
from pathlib import Path
for n,h in json.loads(Path('reference-freeze.json').read_text())['files'].items():
 assert hashlib.sha256(Path(n).read_bytes()).hexdigest()==h,n
for n,r in json.loads(Path('evidence/preflight.json').read_text())['dependencies'].items():
 dep=Path('.lake/packages')/n
 assert subprocess.check_output(['git','-C',dep,'rev-parse','HEAD'],text=True).strip()==r,n
 assert not subprocess.check_output(['git','-C',dep,'status','--porcelain']).strip(),n
Path('evidence/postflight.json').write_text(json.dumps({'source_hashes_unchanged': True,
 'dependency_revisions_unchanged': True,'dependency_sources_clean': True})+'\n')
PY
mkdir -p "$src/evidence"
cp evidence/* "$src/evidence/"
test "$cmp" -eq 0 && test "$build" -eq 0 && test "$axioms" -eq 0
