"""Check copied publication bytes; this does not run Lean or a simulation."""
from pathlib import Path
import hashlib
import json

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
manifest = json.loads((HERE / 'publication-manifest.json').read_text(encoding='utf-8'))
failures = []
for row in manifest['files']:
    file = ROOT / row['path']
    if not file.is_file():
        failures.append({'path': row['path'], 'error': 'missing'})
        continue
    data = file.read_bytes()
    digest = hashlib.sha256(data).hexdigest()
    blob = hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()
    if digest != row['published_sha256'] or blob != row['git_blob_sha'] or len(data) != row['bytes']:
        failures.append({'path': row['path'], 'error': 'identity mismatch'})
result = {'status': 'PASS' if not failures else 'FAIL', 'copied_files_checked': len(manifest['files']),
          'lean_sources': sum(r['path'].endswith('.lean') for r in manifest['files']),
          'lean_sources_unchanged': all(r['source_sha256'] == r['published_sha256'] for r in manifest['files'] if r['path'].endswith('.lean')),
          'source_manifest_entries_checked_at_collection': len(manifest['source_binding_checks']),
          'source_manifest_matches_at_collection': all(r['match'] is True for r in manifest['source_binding_checks']),
          'new_Lean_or_simulation_runs': False, 'failures': failures}
print(json.dumps(result, indent=2))
raise SystemExit(bool(failures))
