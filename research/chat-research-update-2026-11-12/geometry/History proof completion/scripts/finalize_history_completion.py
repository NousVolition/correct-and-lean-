"""Preserve checked partial work without reporting the full fluid claim as proved."""
from pathlib import Path
import datetime
import hashlib
import json
import re
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'outputs' / 'History proof completion'
OLD = ROOT / 'outputs' / 'Same particle history'
SOURCE = OUT / 'lean'
NAMES = ['HistoryParameterSelection', 'HistoryPlanarBase',
         'HistoryScalarLift', 'HistoryCompletionTarget']
EXPECTED = [5, 9, 6, 3]
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()

def original_log_path(record):
    raw = record['log']
    if raw.startswith('/mnt/c/') and not Path('/mnt/c').is_dir():
        return Path('C:/' + raw[len('/mnt/c/'):])
    return Path(raw)

historical_record = OLD / 'Formal core verification.json'
previous = json.loads(historical_record.read_text(encoding='utf-8'))
assert previous['status'] == 'PASS'
for name, prefix in [('SIMSLatentReadout', 'base_theorem_'), ('HistoryMatchCore', '')]:
    for suffix, key in [('.lean', prefix+'source_sha256'), ('.olean', prefix+'object_sha256')]:
        assert sha(SOURCE/(name+suffix)) == previous[key]
        assert sha(OLD/'lean'/(name+suffix)) == previous[key]

modules = []
for name, count in zip(NAMES, EXPECTED):
    record_path = OUT / (name+' verification.json')
    record = json.loads(record_path.read_text(encoding='utf-8'))
    assert record['status'] == 'PASS' and record['exit_code'] == 0
    assert record['mathlib_commit'] == previous['mathlib_commit']
    assert record['lean_binary_sha256'] == previous['lean_binary_sha256']
    assert record['base_dependency_verification_sha256'] == sha(historical_record)
    code = (SOURCE/(name+'.lean')).read_text(encoding='utf-8')
    assert not re.search(r'\b(sorry|admit|axiom|native_decide|implemented_by)\b', code)
    assert len(record['axiom_reports']) == count == len(re.findall(r'^#print axioms ', code, re.M))
    assert set(record['axioms']) <= {'propext', 'Classical.choice', 'Quot.sound'}
    assert sha(SOURCE/(name+'.lean')) == record['source_sha256']
    assert sha(SOURCE/(name+'.olean')) == record['object_sha256']
    log = original_log_path(record)
    assert sha(log) == record['log_sha256']
    for dep, cert in record.get('dependencies', {}).items():
        assert sha(SOURCE/(dep+'.lean')) == cert['source_sha256']
        assert sha(SOURCE/(dep+'.olean')) == cert['object_sha256']
        assert sha(OUT/(dep+' verification.json')) == cert['verification_sha256']
    modules.append({
        'name': name, 'status': 'PASS', 'principal_reports': count,
        'checked_at_utc': record['checked_at_utc'],
        'source_sha256': record['source_sha256'],
        'object_sha256': record['object_sha256'],
        'verification_file': record_path.name,
        'verification_sha256': sha(record_path),
        'latest_log': log.relative_to(OUT).as_posix(),
        'log_sha256': record['log_sha256'],
        'checker_hash_recorded_in_original_run': 'checker_sha256' in record,
    })

target = (SOURCE/'HistoryCompletionTarget.lean').read_text(encoding='utf-8')
assert 'def FullPairExists : Prop' in target
assert 'theorem full_pair_rules_out_exact_reader (h : FullPairExists)' in target
assert 'ContDiffOn ℝ ⊤' not in target
assert 'ContDiffOn ℝ ⊤' not in (SOURCE/'HistoryScalarLift.lean').read_text(encoding='utf-8')

(OUT/'scripts').mkdir(exist_ok=True)
(OUT/'historical').mkdir(exist_ok=True)
shutil.copy2(ROOT/'work'/'check_history_completion.py', OUT/'scripts'/'check_history_completion.py')
shutil.copy2(Path(__file__), OUT/'scripts'/'finalize_history_completion.py')
shutil.copy2(historical_record, OUT/'historical'/'Formal core verification.json')
old_log = original_log_path(previous)
assert sha(old_log) == previous['log_sha256']
shutil.copy2(old_log, OUT/'historical'/old_log.name)

report = {
    'status': 'PARTIAL',
    'requested_full_pair': 'UNPROVED',
    'end_to_end_fluid_pair_checked': False,
    'fluid_specific_parameter_selection_checked': False,
    'abstract_parameter_selection_checked': True,
    'common_planar_fluid_checked': True,
    'scalar_to_fluid_construction': 'CHECKED CONDITIONAL ON ACTUAL SCALAR SOLUTION',
    'three_scalar_existence': 'UNPROVED',
    'actual_winding_and_history_properties': 'UNPROVED',
    'complete_target': 'HistoryCompletionTarget.FullPairExists',
    'new_modules_checked': 4,
    'new_principal_reports': sum(EXPECTED),
    'allowed_axioms': ['Classical.choice', 'Quot.sound', 'propext'],
    'lean_version': '4.34.0-rc2',
    'lean_binary_sha256': previous['lean_binary_sha256'],
    'mathlib_commit': previous['mathlib_commit'],
    'smoothness_correction': {
        'intended': 'C-infinity on forward time t >= 0',
        'corrected_draft_interfaces': ['HistoryScalarLift.ScalarEvolution.smooth', 'HistoryCompletionTarget.Allowed'],
        'base_retains_proved_stronger_analytic_regularity': True,
        'affected_modules_rechecked': ['HistoryScalarLift', 'HistoryCompletionTarget'],
    },
    'modules': modules,
    'historical_dependencies': {
        'reused_after_source_and_object_hash_checks': ['HistoryMatchCore', 'SIMSLatentReadout'],
        'recompiled_in_this_check': False,
        'original_record_sha256': sha(historical_record),
    },
    'fresh_environment_build_tested': False,
    'new_numerical_simulation_run': False,
    'original_history_package_preserved': True,
    'scope_note': 'A passing conditional theorem or target definition is not a proof of the complete pair.',
    'metadata_verified_at_utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
}
(OUT/'Verification.json').write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')

files = sorted(p for p in OUT.rglob('*') if p.is_file() and p.suffix != '.olean'
               and p.name != 'Manifest.json')
manifest = {
    'status': 'PARTIAL; complete pair unproved',
    'compiled_objects_omitted_from_archive': True,
    'files': [{'path': p.relative_to(OUT).as_posix(), 'bytes': p.stat().st_size,
               'sha256': sha(p)} for p in files],
}
(OUT/'Manifest.json').write_text(json.dumps(manifest, indent=2)+'\n', encoding='utf-8')
archive = OUT.parent/'History-proof-completion-progress.zip'
with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED) as z:
    for p in files+[OUT/'Manifest.json']:
        z.write(p, p.relative_to(OUT).as_posix())
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
    for entry in manifest['files']:
        assert hashlib.sha256(z.read(entry['path'])).hexdigest() == entry['sha256']
print(json.dumps({'status': 'PARTIAL', 'full_pair': 'UNPROVED',
                  'new_reports': sum(EXPECTED), 'archive': str(archive),
                  'archive_files': len(files)+1, 'archive_sha256': sha(archive)}, indent=2))
