#!/usr/bin/env bash
# Reuses the pinned checking tools installed for the earlier audit.
# Always use a fresh destination; never copy Windows build products.
set -euo pipefail
test "$(id -u)" -ne 0
source_dir=$(cd -- "$(dirname -- "$0")" && pwd)
check_dir=${1:-/home/nsverify/verification/hug-existence-20261030}
test ! -e "$check_dir"
export PATH=/home/nsverify/verification/bin:/opt/lean-audit/lean-4.34.0-rc2-linux/bin:/usr/local/bin:/usr/bin:/bin
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus
mkdir -p "$check_dir/.lake" "$check_dir/evidence"
cp "$source_dir"/*.lean "$source_dir/lakefile.toml" "$source_dir/lake-manifest.json" \
  "$source_dir/lean-toolchain" "$source_dir/comparator.json" \
  "$source_dir/existence-reference-freeze.json" "$source_dir/source-provenance.json" \
  "$source_dir/verification-inputs.json" "$check_dir/"
cp -r "$source_dir/sources" "$check_dir/sources"
ln -s /home/nsverify/verification/project/.lake/packages "$check_dir/.lake/packages"
cd "$check_dir"
python3 - <<'PY'
from pathlib import Path
import hashlib, json, os, subprocess
p=Path.cwd()
def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
inputs=json.loads((p/'verification-inputs.json').read_text())
for name, expected in inputs['files'].items():
    assert sha(p/name)==expected, name
for freeze in ['existence-reference-freeze.json']:
    record=json.loads((p/freeze).read_text())
    for group in ['files','source_files']:
        for name,expected in record.get(group,{}).items():
            assert sha(p/name)==expected, name
assert not (p/'.lake/build/lib/lean/HugExistenceSolution.olean').exists()
assert not list(p.glob('.lake/build/**/*'))
deps=[]
for dep in json.loads((p/'lake-manifest.json').read_text())['packages']:
    root=p/'.lake/packages'/dep['name']
    commit=subprocess.check_output(['git','-C',str(root),'rev-parse','HEAD'],text=True).strip()
    status=subprocess.check_output(['git','-C',str(root),'status','--porcelain=v1'],text=True).strip()
    assert commit==dep['rev'] and not status, (dep['name'],commit,status)
    deps.append(dict(name=dep['name'],commit=commit,clean=True))
cfg=json.loads((p/'comparator.json').read_text())
assert cfg['enable_nanoda'] is True
assert cfg['permitted_axioms']==['propext','Quot.sound','Classical.choice']
assert cfg['theorem_names']==['ActiveHug.Verified.full_coupled_existence_uniqueness']
binary_paths=[
 '/opt/lean-audit/lean-4.34.0-rc2-linux/bin/lean',
 '/home/nsverify/verification/bin/lake',
 '/home/nsverify/verification/bin/landrun',
 '/home/nsverify/verification/project/.lake/packages/Comparator/.lake/build/bin/comparator',
 '/home/nsverify/verification/project/.lake/packages/lean4export/.lake/build/bin/lean4export',
 '/home/nsverify/verification/nanoda_lib/target/release/nanoda_bin']
record=dict(uid=os.getuid(),solution_precompiled=False,dependencies=deps,
 source_files=inputs['files'],binaries={b:sha(Path(b)) for b in binary_paths},
 lean_version=subprocess.check_output(['lean','--version'],text=True).strip(),
 config=cfg)
(p/'evidence/preflight.json').write_text(json.dumps(record,indent=2)+'\n')
print('PREFLIGHT_PASS: fresh solution, frozen references, all dependency commits clean')
PY
date -u -Iseconds > evidence/comparator.started
set +e
systemd-run --user --wait --pipe --collect --unit=hug-existence-comparator-20261030 \
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
import hashlib, json, subprocess
p=Path.cwd()
inputs=json.loads((p/'verification-inputs.json').read_text())
for name, expected in inputs['files'].items():
    assert hashlib.sha256((p/name).read_bytes()).hexdigest()==expected, name
for dep in json.loads((p/'lake-manifest.json').read_text())['packages']:
    root=p/'.lake/packages'/dep['name']
    assert subprocess.check_output(['git','-C',str(root),'rev-parse','HEAD'],text=True).strip()==dep['rev']
    assert not subprocess.check_output(['git','-C',str(root),'status','--porcelain=v1'],text=True).strip()
(p/'evidence/postflight.json').write_text(json.dumps(dict(source_hashes_unchanged=True,dependency_commits_unchanged=True,dependency_sources_clean=True),indent=2)+'\n')
print('POSTFLIGHT_PASS: sources and dependency revisions preserved')
PY
mkdir -p "$source_dir/evidence-linux"
cp evidence/* "$source_dir/evidence-linux/"
test "$comparator_exit" -eq 0
test "$build_exit" -eq 0
