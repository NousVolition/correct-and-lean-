#!/usr/bin/env bash
set -euo pipefail
mode=${1:?dev or verify}; shift
src=$(cd "$(dirname "$0")" && pwd)
base="$src/../as-signed-vortex-lean"
cache=${HUG_VERIFICATION_ROOT:-$HOME/verification}
up="$cache/project"
export PATH="$cache/bin:/opt/lean-audit/lean-4.34.0-rc2-linux/bin:/usr/local/bin:/usr/bin:/bin"
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus
export LEAN_NUM_THREADS=8
test "$(id -u)" -ne 0
case "$mode" in
 dev) stage="$cache/hline-development" ;;
 verify) stage=$(mktemp -d "$cache/hline-replay.XXXXXXXX") ;;
 *) exit 2 ;;
esac
dir="$stage/as-vortex-hline-lean"
baseline="$stage/as-signed-vortex-lean"
mkdir -p "$dir/.lake/packages"
if [ "$mode" = dev ] && [ -d "$cache/as-signed-vortex-dev" ] && [ ! -e "$baseline" ]; then
 ln -s "$cache/as-signed-vortex-dev" "$baseline"
fi
if [ ! -L "$baseline" ]; then
 mkdir -p "$baseline" "$dir/.lake/pinned-baseline"
 if [ ! -e "$baseline/.lake" ]; then ln -s "$dir/.lake/pinned-baseline" "$baseline/.lake"; fi
 cp "$base"/*.lean "$base"/lakefile.toml "$base"/lake-manifest.json "$base"/lean-toolchain "$baseline/"
 if [ ! -e "$baseline/.lake/packages" ]; then ln -s "$dir/.lake/packages" "$baseline/.lake/packages"; fi
fi
cp "$src"/*.lean "$src"/lakefile.toml "$src"/lake-manifest.json "$src"/lean-toolchain "$dir/"
for dep in "$up"/.lake/packages/*; do
 if [ ! -e "$dir/.lake/packages/$(basename "$dep")" ]; then ln -s "$dep" "$dir/.lake/packages/$(basename "$dep")"; fi
done
if [ ! -e "$dir/.lake/packages/NavierStokesAndEuler" ]; then
 ln -s "$up" "$dir/.lake/packages/NavierStokesAndEuler"
fi
cd "$dir"
if [ "$mode" = dev ]; then lake build "$@"; exit; fi
cp "$src/comparator.json" "$src/reference-freeze.json" "$src/run-check.sh" "$dir/"
mkdir evidence
python3 - "$base/reference-freeze.json" <<'PY'
from pathlib import Path
import json, hashlib, subprocess, re, sys
p=Path.cwd()
def digest(f): return hashlib.sha256(f.read_bytes()).hexdigest()
old=json.loads(Path(sys.argv[1]).read_text()); new=json.loads(Path('reference-freeze.json').read_text())
assert digest(Path(sys.argv[1]))==new['baseline_freeze_sha256']
base=p.parent/'as-signed-vortex-lean'
assert all((base/n).is_file() for n in old['solution_modules'])
for n,h in old['files'].items():
 if (base/n).is_file(): assert digest(base/n)==h,n
for n,h in new['files'].items(): assert digest(p/n)==h,n
assert not (p/'.lake/build').exists() and not (base/'.lake/build').exists()
for n in new['solution_modules']:
 assert not re.search(r'\b(sorryAx|sorry|admit|axiom|native_decide)\b',(p/n).read_text()),n
cfg=json.loads(Path('comparator.json').read_text())
assert cfg['theorem_names']==new['theorems'] and len(set(new['theorems']))==len(new['theorems'])
assert cfg['enable_nanoda'] and cfg['permitted_axioms']==['propext','Quot.sound','Classical.choice']
deps={}
for d in json.loads(Path('lake-manifest.json').read_text())['packages']:
 if d['type']=='path': continue
 root=Path('.lake/packages')/d['name']
 assert subprocess.check_output(['git','-C',root,'rev-parse','HEAD'],text=True).strip()==d['rev']
 assert not subprocess.check_output(['git','-C',root,'status','--porcelain']).strip()
 deps[d['name']]=d['rev']
Path('evidence/preflight.json').write_text(json.dumps({'dependencies':deps,'files':new['files'],
 'baseline_files':{n:h for n,h in old['files'].items() if (base/n).is_file()}},indent=2)+'\n')
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
lake env lean HLineSolution.lean 2>&1 | tee evidence/axioms.log
axioms=${PIPESTATUS[0]}
set -e
printf '%s\n' "$cmp" > evidence/comparator.exit
printf '%s\n' "$build" > evidence/lean-build.exit
printf '%s\n' "$axioms" > evidence/axioms.exit
date -u -Iseconds > evidence/finish.txt
python3 - <<'PY'
import json,hashlib,subprocess
from pathlib import Path
m=json.loads(Path('evidence/preflight.json').read_text())
for root,key in [(Path('.'),'files'),(Path('../as-signed-vortex-lean'),'baseline_files')]:
 for n,h in m[key].items(): assert hashlib.sha256((root/n).read_bytes()).hexdigest()==h,n
for n,r in m['dependencies'].items():
 dep=Path('.lake/packages')/n
 assert subprocess.check_output(['git','-C',dep,'rev-parse','HEAD'],text=True).strip()==r
 assert not subprocess.check_output(['git','-C',dep,'status','--porcelain']).strip()
Path('evidence/postflight.json').write_text('{"sources_unchanged":true,"dependencies_clean":true}\n')
PY
mkdir -p "$src/evidence"
cp evidence/* "$src/evidence/"
test "$cmp" -eq 0 && test "$build" -eq 0 && test "$axioms" -eq 0
