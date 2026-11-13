"""Bind each fresh verification run to its exact sources and pinned dependencies."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
from datetime import datetime, timezone

root = Path.cwd()
phase = sys.argv[1]
verify_root = Path(sys.argv[2])

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

inputs = json.loads((root / 'verification-inputs.json').read_text())
frozen = json.loads((root / 'suppression-reference-freeze.json').read_text())
for record in (inputs, frozen):
    for name, expected in record['files'].items():
        assert sha(root / name) == expected, name

dependencies = []
for dependency in json.loads((root / 'lake-manifest.json').read_text())['packages']:
    path = root / '.lake/packages' / dependency['name']
    commit = subprocess.check_output(['git', '-C', str(path), 'rev-parse', 'HEAD'], text=True).strip()
    status = subprocess.check_output(['git', '-C', str(path), 'status', '--porcelain=v1'], text=True).strip()
    assert commit == dependency['rev'] and not status, (dependency['name'], commit, status)
    dependencies.append({'name': dependency['name'], 'commit': commit, 'source_clean': True})

config = json.loads((root / 'comparator.json').read_text())
assert config == {
    'challenge_module': 'ASSuppressionChallenge',
    'solution_module': 'ASSuppressionSolution',
    'enable_nanoda': True,
    'theorem_names': ['SocialAS.Verified.full_suppression_comparison'],
    'permitted_axioms': ['propext', 'Quot.sound', 'Classical.choice'],
}
record = {
    'observed_at_utc': datetime.now(timezone.utc).isoformat(),
    'phase': phase,
    'uid': os.getuid(),
    'sources_match_sealed_inputs': True,
    'original_model_and_target_match_frozen_reference': True,
    'dependencies': dependencies,
    'config': config,
}
if phase == 'preflight':
    assert not list((root / '.lake/build').glob('**/*'))
    record['solution_precompiled'] = False
    record['lean_version'] = subprocess.check_output(['lean', '--version'], text=True).strip()
    binary_paths = [
        Path('/opt/lean-audit/lean-4.34.0-rc2-linux/bin/lean'),
        verify_root / 'bin/lake', verify_root / 'bin/landrun',
        verify_root / 'project/.lake/packages/Comparator/.lake/build/bin/comparator',
        verify_root / 'project/.lake/packages/lean4export/.lake/build/bin/lean4export',
        verify_root / 'nanoda_lib/target/release/nanoda_bin',
    ]
    record['binaries_sha256'] = {str(path): sha(path) for path in binary_paths}
elif phase == 'postflight':
    record['comparator_exit'] = int((root / 'evidence/comparator.exit').read_text())
    record['lake_build_exit'] = int((root / 'evidence/lake-build.exit').read_text())
else:
    raise ValueError(phase)
(root / 'evidence' / f'{phase}.json').write_text(json.dumps(record, indent=2) + '\n')
print(f'{phase.upper()}_PASS: original model, target, source hashes, and dependency revisions preserved')
