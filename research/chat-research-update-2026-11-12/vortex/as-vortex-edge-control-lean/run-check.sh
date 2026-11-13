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
  dev) stage="$cache/edge-control-development" ;;
  verify) stage=$(mktemp -d "$cache/edge-control-replay.XXXXXXXX") ;;
  *) exit 2 ;;
esac
dir="$stage/as-vortex-edge-control-lean"
mkdir -p "$dir/.lake/packages"
for name in as-signed-vortex-lean as-vortex-hline-lean as-vortex-rescaling-lean; do
  base="$stage/$name"
  if [ "$mode" = dev ] && [ ! -e "$base" ]; then
    ln -s "$cache/rescaled-vortex-development/$name" "$base"
  elif [ "$mode" = verify ]; then
    mkdir -p "$base" "$dir/.lake/$name-cache"
    ln -s "$dir/.lake/$name-cache" "$base/.lake"
    ln -s "$dir/.lake/packages" "$base/.lake/packages"
    cp "$src/../$name/"*.lean "$src/../$name/lakefile.toml" "$src/../$name/lake-manifest.json" "$src/../$name/lean-toolchain" "$base/"
  fi
done
for dep in "$up"/.lake/packages/*; do
  link="$dir/.lake/packages/$(basename "$dep")"
  if [ ! -e "$link" ]; then ln -s "$dep" "$link"; fi
done
if [ ! -e "$dir/.lake/packages/NavierStokesAndEuler" ]; then ln -s "$up" "$dir/.lake/packages/NavierStokesAndEuler"; fi
cp "$src/"*.lean "$src/lakefile.toml" "$src/lake-manifest.json" "$src/lean-toolchain" "$dir/"
cd "$dir"
if [ "$mode" = dev ]; then lake build "$@"; exit; fi
cp "$src/comparator.json" "$src/reference-freeze.json" "$src/run-check.sh" "$dir/"
mkdir evidence
python3 - "$src" <<'PY'
import hashlib,json,re,subprocess,sys
from pathlib import Path
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def repo(root,*args): return subprocess.check_output(['git','-C',root,*args],text=True).strip()
src=Path(sys.argv[1]); pkg=Path.cwd()
frozen=json.loads(Path('reference-freeze.json').read_text())
cfg=json.loads(Path('comparator.json').read_text())
assert cfg['theorem_names']==frozen['theorems'] and len(set(cfg['theorem_names']))==len(cfg['theorem_names'])
assert cfg['enable_nanoda'] and set(cfg['permitted_axioms'])=={'propext','Quot.sound','Classical.choice'}
assert not (pkg/'.lake/build').exists()
for n,h in frozen['files'].items(): assert sha(pkg/n)==h,n
for n in frozen['solution_modules']:
    assert not re.search(r'\b(sorry|sorryAx|admit|axiom|native_decide)\b',(pkg/n).read_text()),n
prior={}
for name,digest in frozen['prior_freezes'].items():
    base=pkg.parent/name
    ref=src.parent/name/'reference-freeze.json'
    assert sha(ref)==digest and not (base/'.lake/build').exists(),name
    old=json.loads(ref.read_text())
    verified={n:h for n,h in old['files'].items() if (base/n).is_file()}
    assert set(old['solution_modules'])<=set(verified),name
    for n,h in verified.items(): assert sha(base/n)==h,n
    prior[name]=verified
deps={}
for dep in json.loads(Path('lake-manifest.json').read_text())['packages']:
    if dep['type']=='path': continue
    path=pkg/'.lake/packages'/dep['name']
    assert repo(path,'rev-parse','HEAD')==dep['rev'] and not repo(path,'status','--porcelain'),dep['name']
    deps[dep['name']]=dep['rev']
Path('evidence/preflight.json').write_text(json.dumps({'files':frozen['files'],'inherited':prior,
    'dependencies':deps,'new_and_three_audit_builds_started_empty':True},indent=2)+'\n')
PY
date -u -Iseconds > evidence/start.txt
set +e
systemd-run --user --wait --pipe --collect --property=RestrictAddressFamilies=~AF_UNIX \
  -E PATH="$PATH" -E COMPARATOR_LANDRUN="$cache/bin/landrun" \
  -E COMPARATOR_LEAN4EXPORT="$up/.lake/packages/lean4export/.lake/build/bin/lean4export" \
  -E COMPARATOR_NANODA="$cache/nanoda_lib/target/release/nanoda_bin" \
  --working-directory="$dir" -- "$cache/bin/lake" env \
  "$up/.lake/packages/Comparator/.lake/build/bin/comparator" comparator.json 2>&1 | tee evidence/comparator.log
cmp=${PIPESTATUS[0]}
lake build 2>&1 | tee evidence/lean-build.log
built=${PIPESTATUS[0]}
lake env lean EdgeControlSolution.lean 2>&1 | tee evidence/axioms.log
ax=${PIPESTATUS[0]}
set -e
printf '%s\n' "$cmp" > evidence/comparator.exit
printf '%s\n' "$built" > evidence/lean-build.exit
printf '%s\n' "$ax" > evidence/axioms.exit
date -u -Iseconds > evidence/finish.txt
python3 - <<'PY'
from pathlib import Path
import hashlib,json,subprocess
m=json.loads(Path('evidence/preflight.json').read_text())
for root,items in [(Path('.'),m['files'])]+[(Path('..')/k,v) for k,v in m['inherited'].items()]:
    for n,h in items.items(): assert hashlib.sha256((root/n).read_bytes()).hexdigest()==h,n
for n,rev in m['dependencies'].items():
    p=Path('.lake/packages')/n
    assert subprocess.check_output(['git','-C',p,'rev-parse','HEAD'],text=True).strip()==rev
    assert not subprocess.check_output(['git','-C',p,'status','--porcelain']).strip()
Path('evidence/postflight.json').write_text('{"sources_unchanged":true,"dependencies_clean":true}\n')
PY
mkdir -p "$src/evidence"
cp evidence/* "$src/evidence/"
test "$cmp" -eq 0 && test "$built" -eq 0 && test "$ax" -eq 0

