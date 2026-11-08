#!/usr/bin/env bash
set -euo pipefail
test "$(id -u)" -ne 0
source_dir=$(cd -- "$(dirname -- "$0")" && pwd)
check_dir=${1:-/home/nsverify/verification/hug-v3-o-rumination-check-20261103}
test ! -e "$check_dir"
export PATH=/home/nsverify/verification/bin:/opt/lean-audit/lean-4.34.0-rc2-linux/bin:/usr/local/bin:/usr/bin:/bin
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus
mkdir -p "$check_dir/.lake" "$check_dir/evidence"
cp "$source_dir"/*.lean "$source_dir/lakefile.toml" "$source_dir/lake-manifest.json" \
 "$source_dir/lean-toolchain" "$source_dir/comparator.json" "$source_dir/reference-freeze-current.json" \
 "$source_dir/verification-inputs.json" "$source_dir/run-linux-check.sh" "$check_dir/"
ln -s /home/nsverify/verification/project/.lake/packages "$check_dir/.lake/packages"
cd "$check_dir"
python3 - <<'PY'
from pathlib import Path
import hashlib,json,os,subprocess
p=Path.cwd()
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
inputs=json.loads((p/'verification-inputs.json').read_text())
for n,h in inputs['files'].items():assert sha(p/n)==h,n
frozen=json.loads((p/'reference-freeze-current.json').read_text())
for group in ('files','source_files'):
 for n,h in frozen.get(group,{}).items():assert sha(p/n)==h,n
assert not list(p.glob('.lake/build/**/*'))
deps=[]
for dep in json.loads((p/'lake-manifest.json').read_text())['packages']:
 root=p/'.lake/packages'/dep['name']
 commit=subprocess.check_output(['git','-C',str(root),'rev-parse','HEAD'],text=True).strip()
 status=subprocess.check_output(['git','-C',str(root),'status','--porcelain=v1'],text=True).strip()
 assert commit==dep['rev'] and not status,(dep['name'],commit,status)
 deps.append(dict(name=dep['name'],commit=commit,clean=True))
cfg=json.loads((p/'comparator.json').read_text())
assert cfg['theorem_names']==frozen['theorems']
assert cfg['enable_nanoda'] is True
assert cfg['permitted_axioms']==['propext','Quot.sound','Classical.choice']
binaries=['/opt/lean-audit/lean-4.34.0-rc2-linux/bin/lean','/home/nsverify/verification/bin/lake',
 '/home/nsverify/verification/bin/landrun',
 '/home/nsverify/verification/project/.lake/packages/Comparator/.lake/build/bin/comparator',
 '/home/nsverify/verification/project/.lake/packages/lean4export/.lake/build/bin/lean4export',
 '/home/nsverify/verification/nanoda_lib/target/release/nanoda_bin']
record=dict(uid=os.getuid(),solution_precompiled=False,source_files=inputs['files'],dependencies=deps,
 binaries={b:sha(Path(b)) for b in binaries},config=cfg,
 lean_version=subprocess.check_output(['lean','--version'],text=True).strip())
(p/'evidence/preflight.json').write_text(json.dumps(record,indent=2)+'\n')
print('PREFLIGHT_PASS: frozen reference, fresh solution, pinned clean dependencies',flush=True)
PY
date -u -Iseconds > evidence/comparator.started
set +e
systemd-run --user --wait --pipe --collect --unit=hug-v3-o-rumination-comparator-20261103 \
 --property=RestrictAddressFamilies=~AF_UNIX -E PATH="$PATH" \
 -E COMPARATOR_LANDRUN=/home/nsverify/verification/bin/landrun \
 -E COMPARATOR_LEAN4EXPORT=/home/nsverify/verification/project/.lake/packages/lean4export/.lake/build/bin/lean4export \
 -E COMPARATOR_NANODA=/home/nsverify/verification/nanoda_lib/target/release/nanoda_bin \
 --working-directory="$PWD" -- /home/nsverify/verification/bin/lake env \
 /home/nsverify/verification/project/.lake/packages/Comparator/.lake/build/bin/comparator comparator.json \
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
 printf '%s\n' "$build_exit" > evidence/lake-build.exit
else
 build_exit=99
fi
python3 - <<'PY'
from pathlib import Path
import hashlib,json,subprocess
p=Path.cwd()
inputs=json.loads((p/'verification-inputs.json').read_text())
for n,h in inputs['files'].items():assert hashlib.sha256((p/n).read_bytes()).hexdigest()==h,n
for dep in json.loads((p/'lake-manifest.json').read_text())['packages']:
 root=p/'.lake/packages'/dep['name']
 assert subprocess.check_output(['git','-C',str(root),'rev-parse','HEAD'],text=True).strip()==dep['rev']
 assert not subprocess.check_output(['git','-C',str(root),'status','--porcelain=v1'],text=True).strip()
(p/'evidence/postflight.json').write_text(json.dumps(dict(source_hashes_unchanged=True,dependency_commits_unchanged=True,dependency_sources_clean=True),indent=2)+'\n')
print('POSTFLIGHT_PASS',flush=True)
PY
mkdir -p "$source_dir/evidence-linux"
cp evidence/* "$source_dir/evidence-linux/"
test "$comparator_exit" -eq 0
test "$build_exit" -eq 0
