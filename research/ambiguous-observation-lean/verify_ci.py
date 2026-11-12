"""Check published evidence, build the pinned package, and audit its named proofs."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import tomllib
from datetime import datetime, timezone

ROOT = Path(__file__).resolve().parent
ALLOWED = {'propext', 'Quot.sound', 'Classical.choice'}
AXIOMS = re.compile(r"'([^']+)' (?:depends on axioms:\s*\[([^\]]*)\]|does not depend on any axioms)\.?\Z", re.S)

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def read_json(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))

def check_saved():
    manifest = read_json(ROOT / 'publication-manifest.json')['files']
    for rel, expected in manifest.items():
        path = (ROOT / rel).resolve()
        if not path.is_relative_to(ROOT) or not path.is_file() or digest(path) != expected:
            raise ValueError('Missing or changed published input: ' + rel)
    declared_sources = {name for name in manifest if name.endswith('.lean')}
    if declared_sources != {p.name for p in ROOT.glob('*.lean')}:
        raise ValueError('Unexpected or omitted Lean source')
    discovered = []
    for name in sorted(declared_sources):
        code = (ROOT / name).read_text()
        if re.search(r'\b(?:sorryAx|sorry|admit|axiom|native_decide|implemented_by|unsafe)\b', code):
            raise ValueError('Forbidden proof construct in ' + name)
        discovered.extend(Path(name).stem + '.' + item for item in re.findall(
            r'^(?:@\[[^\]]+\]\s*)?(?:theorem|lemma)\s+(\w+)', code, re.M))
    targets = read_json(ROOT / 'targets.json')
    if len(targets) != len(set(targets)) or targets != discovered:
        raise ValueError('Named proof targets differ from published sources')
    printed = re.findall(r'^#print axioms (\S+)', (ROOT / 'CheckAllAxioms.lean').read_text(), re.M)
    if printed != targets:
        raise ValueError('Axiom audit does not cover the exact target list')
    receipt = read_json(ROOT / 'verification.json')
    if receipt['status'] != 'PASS':
        raise ValueError('Local receipt does not pass')
    for row in receipt['modules']:
        if row['status'] != 'PASS' or digest(ROOT / (row['module'] + '.lean')) != row['source_sha256']:
            raise ValueError('Stale local source receipt: ' + row['module'])
        if digest(ROOT / row['log']) != row['log_sha256'] or not set(row['axioms']) <= ALLOWED:
            raise ValueError('Stale or invalid local axiom log: ' + row['module'])
    print(f'PASS: published fingerprints and {len(targets)} named proof targets', flush=True)
    return manifest, targets

def parse_axioms(transcript, targets):
    seen = {}
    for line in transcript.splitlines():
        message = json.loads(line)
        if message.get('severity') == 'error':
            raise ValueError('Lean reported an error: ' + str(message.get('data')))
        match = AXIOMS.fullmatch(str(message.get('data', '')).strip())
        if not match:
            continue
        name, used = match.groups()
        values = [a.strip() for a in used.split(',') if a.strip()] if used else []
        if name not in targets or name in seen or not set(values) <= ALLOWED:
            raise ValueError('Unexpected, duplicate or forbidden axiom report: ' + name)
        seen[name] = values
    if set(seen) != set(targets):
        raise ValueError('Missing axiom reports: ' + repr(sorted(set(targets) - set(seen))))
    return seen

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check-only', action='store_true')
    args = parser.parse_args()
    inputs, targets = check_saved()
    if args.check_only:
        return
    output = ROOT / 'github-evidence'
    output.mkdir(exist_ok=True)
    version = subprocess.check_output(['lake', 'env', 'lean', '--version'], cwd=ROOT, text=True).strip()
    expected = (ROOT / 'lean-toolchain').read_text().strip().split(':v')[-1]
    if 'version ' + expected not in version:
        raise ValueError('Incorrect Lean version: ' + version)
    config = tomllib.loads((ROOT / 'lakefile.toml').read_text())
    pinned = next(p['rev'] for p in config['require'] if p['name'] == 'mathlib')
    actual = subprocess.check_output(['git', '-C', str(ROOT / '.lake/packages/mathlib'), 'rev-parse', 'HEAD'], text=True).strip()
    if actual != pinned:
        raise ValueError('Mathlib revision differs from the pin')
    with (output / 'lake-build.log').open('w') as log:
        build = subprocess.run(['lake', 'build'], cwd=ROOT, text=True, stdout=log, stderr=subprocess.STDOUT, timeout=900)
    (output / 'lake-build.exit').write_text(str(build.returncode) + '\n')
    if build.returncode:
        raise ValueError('Lake build failed; see github-evidence/lake-build.log')
    audit = subprocess.run(['lake', 'env', 'lean', '--json', 'CheckAllAxioms.lean'], cwd=ROOT,
                           text=True, capture_output=True, timeout=240)
    (output / 'axioms.jsonl').write_text(audit.stdout)
    (output / 'axioms.stderr.log').write_text(audit.stderr)
    if audit.returncode:
        raise ValueError('Lean axiom audit failed')
    axioms = parse_axioms(audit.stdout, targets)
    readable = '\n'.join(f'{name}: ' + (', '.join(used) if used else 'no axioms') for name, used in axioms.items()) + '\n'
    (output / 'axioms.log').write_text(readable)
    check_saved()
    receipt = {
        'status': 'PASS', 'checked_at_utc': datetime.now(timezone.utc).isoformat(),
        'lean_version': version, 'mathlib_commit': actual, 'lake_build': 'PASS',
        'targets': targets, 'target_count': len(targets), 'axiom_dependencies': axioms,
        'published_inputs': inputs,
        'logs': {p.name: digest(p) for p in sorted(output.iterdir()) if p.is_file() and p.name != 'github-receipt.json'},
        'scope': 'Summary instances, real readJet projection, and separate explicit abelian field-equation comparison.',
        'limits': ['No simulator or transcription verification', 'No admissible Yang-Mills family result',
                   'Comparator and nanoda not run'],
        'execution_context': {k: os.environ.get(k) for k in [
            'GITHUB_REPOSITORY', 'GITHUB_SHA', 'PR_HEAD', 'GITHUB_EVENT_NAME', 'GITHUB_RUN_ID', 'GITHUB_RUN_ATTEMPT']},
    }
    (output / 'github-receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps({'status': 'PASS', 'lake_build': 'PASS', 'named_proofs': len(axioms),
                      'axiom_union': sorted({a for used in axioms.values() for a in used})}), flush=True)

if __name__ == '__main__':
    main()
