#!/usr/bin/env bash
set -euo pipefail
mode=${1:?dev or verify}; shift
src=$(cd "$(dirname "$0")" && pwd)
cache=${HUG_VERIFICATION_ROOT:-$HOME/verification}
up="$cache/project"
export PATH="$cache/bin:/opt/lean-audit/lean-4.34.0-rc2-linux/bin:/usr/local/bin:/usr/bin:/bin"
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus
export LEAN_NUM_THREADS=8
test "$(id -u)" -ne 0
case "$mode" in
 dev) stage="$cache/rescaled-vortex-development" ;;
 verify) stage=$(mktemp -d "$cache/rescaled-vortex-replay.XXXXXXXX") ;;
 *) exit 2 ;;
esac
dir="$stage/as-vortex-rescaling-lean"
mkdir -p "$dir/.lake/packages"
for b in as-signed-vortex-lean as-vortex-hline-lean; do
 base="$stage/$b"
 if [ "$mode" = dev ] && [ ! -e "$base" ]; then
  if [ "$b" = as-signed-vortex-lean ]; then prior="$cache/as-signed-vortex-dev"; else prior="$cache/hline-development/as-vortex-hline-lean"; fi
  if [ -d "$prior" ]; then ln -s "$prior" "$base"; fi
 fi
 if [ ! -L "$base" ]; then
  mkdir -p "$base" "$dir/.lake/$b-cache"
  if [ ! -e "$base/.lake" ]; then ln -s "$dir/.lake/$b-cache" "$base/.lake"; fi
  if [ ! -e "$base/.lake/packages" ]; then ln -s "$dir/.lake/packages" "$base/.lake/packages"; fi
  cp "$src/../$b/"*.lean "$src/../$b/lakefile.toml" "$src/../$b/lake-manifest.json" "$src/../$b/lean-toolchain" "$base/"
 fi
done
for dep in "$up"/.lake/packages/*; do
 if [ ! -e "$dir/.lake/packages/$(basename "$dep")" ]; then ln -s "$dep" "$dir/.lake/packages/$(basename "$dep")"; fi
done
if [ ! -e "$dir/.lake/packages/NavierStokesAndEuler" ]; then ln -s "$up" "$dir/.lake/packages/NavierStokesAndEuler"; fi
cp "$src/"*.lean "$src/lakefile.toml" "$src/lake-manifest.json" "$src/lean-toolchain" "$dir/"
cd "$dir"
if [ "$mode" = dev ]; then lake build "$@"; exit; fi
cp "$src/comparator.json" "$src/reference-freeze.json" "$src/run-check.sh" "$dir/"
mkdir evidence
python3 - "$src" <<'PY'
from pathlib import Path
import hashlib,json,re,subprocess,sys
p=Path.cwd()
src=Path(sys.argv[1]); new=json.loads(Path('reference-freeze.json').read_text())
def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
for n,h in new['files'].items(): assert sha(p/n)==h,n
cfg=json.loads(Path('comparator.json').read_text())
assert cfg['theorem_names']==new['theorems'] and len(set(new['theorems']))==len(new['theorems'])
assert cfg['enable_nanoda'] and cfg['permitted_axioms']==['propext','Quot.sound','Classical.choice']
assert not (p/'.lake/build').exists()
for n in new['solution_modules']:
 assert not re.search(r'\b(sorryAx|sorry|admit|axiom|native_decide)\b',(p/n).read_text()),n
prior={}
for b,h in new['prior_freezes'].items():
 f=src.parent/b/'reference-freeze.json'
 assert sha(f)==h,b
 old=json.loads(f.read_text()); base=p.parent/b
 assert not (base/'.lake/build').exists()
 assert all((base/n).exists() for n in old['solution_modules'])
 prior[b]={n:h for n,h in old['files'].items() if (base/n).is_file()}
 for n,h in prior[b].items(): assert sha(base/n)==h,n
deps={}
for d in json.loads(Path('lake-manifest.json').read_text())['packages']:
 if d['type']=='path': continue
 root=Path('.lake/packages')/d['name']
 assert subprocess.check_output(['git','-C',root,'rev-parse','HEAD'],text=True).strip()==d['rev']
 assert not subprocess.check_output(['git','-C',root,'status','--porcelain']).strip()
 deps[d['name']]=d['rev']
Path('evidence/preflight.json').write_text(json.dumps({'files':new['files'],'dependencies':deps,
 'inherited':prior,'new_and_inherited_builds_started_empty':True},indent=2)+'\n')
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
lake env lean RescaleSolution.lean 2>&1 | tee evidence/axioms.log
axioms=${PIPESTATUS[0]}
set -e
printf '%s\n' "$cmp" > evidence/comparator.exit
printf '%s\n' "$build" > evidence/lean-build.exit
printf '%s\n' "$axioms" > evidence/axioms.exit
date -u -Iseconds > evidence/finish.txt
python3 - <<'PY'
from pathlib import Path
import json,hashlib,subprocess
m=json.loads(Path('evidence/preflight.json').read_text())
for root,items in [(Path('.'),m['files'])]+[(Path('..')/b,v) for b,v in m['inherited'].items()]:
 for n,h in items.items(): assert hashlib.sha256((root/n).read_bytes()).hexdigest()==h,n
for n,r in m['dependencies'].items():
 dep=Path('.lake/packages')/n
 assert subprocess.check_output(['git','-C',dep,'rev-parse','HEAD'],text=True).strip()==r
 assert not subprocess.check_output(['git','-C',dep,'status','--porcelain']).strip()
Path('evidence/postflight.json').write_text('{"sources_unchanged":true,"dependencies_clean":true}\n')
PY
mkdir -p "$src/evidence"
cp evidence/* "$src/evidence/"
test "$cmp" -eq 0 && test "$build" -eq 0 && test "$axioms" -eq 0
