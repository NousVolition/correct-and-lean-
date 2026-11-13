"""Export saved observations and preserve the exact existing proof sources."""
from pathlib import Path
import datetime, hashlib, json, re, shutil, sys, zipfile
import numpy as np

ROOT = Path('$USER_HOME/Documents/Codex')
HERE = ROOT / '2026-11-10/lo'
OUT = HERE / 'outputs/Ambiguity theorem checks'
LEAN = OUT / 'lean'
EVIDENCE = OUT / 'evidence'
for folder in (LEAN, EVIDENCE): folder.mkdir(parents=True, exist_ok=True)
GO = ROOT / '2026-11-10/go'
sys.path.insert(0, str(GO / 'work'))
from threshold_one_pair import make_solver

sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
sources = {}
def record(path):
    sources[str(path)] = sha(path)
    return path

oldbuild = ROOT / '2026-11-10/for-the-after-breathing-stopped-figure/work/original-yang-build'
for name in ['Volterra.lean', 'TwoMemory.lean']:
    shutil.copyfile(record(oldbuild / name), LEAN / name)
suite = HERE / 'outputs/SIMS rational readout check/corrected/SIMSLatentReadout.lean'
shutil.copyfile(record(suite), LEAN / suite.name)
archive = record(GO / 'outputs/Yang-Mills - readings and proof sources.zip')
with zipfile.ZipFile(archive) as z:
    for name in ['TwoMemoryTransport.lean', 'YangMillsCueTest.lean']:
        (LEAN / name).write_bytes(z.read('proofs/' + name))
assert (LEAN/'TwoMemoryTransport.lean').read_bytes() == record(oldbuild/'TwoMemoryTransport.lean').read_bytes()

solver, case, breathing = make_solver('on')
snapshots = {}
records = {}
paths = {}
for side in ['before', 'after']:
    path = record(GO / f'work/threshold-one-pair/on/prime-41-{side}_write.npz')
    paths[side] = str(path)
    shutil.copyfile(path, EVIDENCE / path.name)
    with np.load(path, allow_pickle=False) as z: snapshots[side] = dict(z)
    records[side] = [dict(r) for _, r in solver.read_material(snapshots[side])]
ids = {side: [int(r['event_id']) for r in rows] for side, rows in records.items()}
assert ids == {'before': [0, 1], 'after': [0, 1, 2]}
before, after = snapshots['before'], snapshots['after']

def encoded(a):
    assert np.isfinite(a).all()
    return np.ascontiguousarray(a, dtype='<f8').tobytes()

encoded_observation = {}
for side, state in snapshots.items():
    encoded_observation[side] = {
        'velocity': encoded(state['g'][..., :3]),
        'markers': encoded(state['observer_X']),
    }
    for name, data in encoded_observation[side].items():
        (EVIDENCE / f'{side}-{name}.bin').write_bytes(data)
assert encoded_observation['before'] == encoded_observation['after']
assert not np.array_equal(before['b'], after['b'])
assert not np.array_equal(before['g'][...,4], after['g'][...,4])
old = record(HERE / 'work/threshold-one/threshold-1/state-0600.npz')
comparison_to_prior_run = {}
with np.load(old, allow_pickle=False) as z:
    for name in z.files:
        compare = after[name][:803] if name == 'observer_X' else after[name]
        comparison_to_prior_run[name] = {
            'bytes_equal': encoded(z[name]) == encoded(compare),
            'max_absolute_difference': float(np.max(np.abs(z[name]-compare))),
        }

data = ['import Mathlib', '', '/- Exact little-endian binary64 byte strings exported from saved NPZ arrays.',
        '   Array decoding and event decoding are independently checked outside Lean. -/',
        'namespace Tick41SavedWrite', '',
        'structure Snapshot where', '  velocityBytes : String', '  markerBytes : String',
        '  eventIds : List Nat', '',
        'inductive Side | before | after deriving DecidableEq, Repr', '']
for side in ['before', 'after']:
    data.extend([f'def {side}Snapshot : Snapshot :=',
        '  ⟨"' + encoded_observation[side]['velocity'].hex() + '",',
        '   "' + encoded_observation[side]['markers'].hex() + '",',
        '   [' + ', '.join(str(n) for n in ids[side]) + ']⟩', ''])
data.extend(['def snapshot : Side → Snapshot',
             '  | .before => beforeSnapshot', '  | .after => afterSnapshot', '',
             'def observe (s : Side) : String × String :=',
             '  ((snapshot s).velocityBytes, (snapshot s).markerBytes)', '',
             'def eventTwoPresent (s : Side) : Bool := (snapshot s).eventIds.contains 2', '',
             'end Tick41SavedWrite', ''])
(LEAN / 'Tick41SavedWrite.lean').write_text('\n'.join(data), encoding='utf-8')

geom = ROOT / '2026-11-07/mathlib4-the-main-library-good-first/outputs/hug-threshold1-refinement/tick41-lean'
gpath = record(geom / 'exact-data.json')
geo = json.loads(gpath.read_text())
manifest = json.loads(record(geom / 'manifest.json').read_text())
assert all(sha(geom/n) == h for n,h in manifest.items())
returns = []
for row in geo['records']:
    for label in ['A','B']:
        s = row['scalars']
        item = dict(name=row['key']+'_'+label, start=s[label+'_start_x'], end=s[label+'_return_x'], scale=row['scale'])
        assert item['scale'] > 0
        assert (item['end']-item['start']) % item['scale'] != 0
        returns.append(item)
ints = lambda n: f'({n})' if n < 0 else str(n)
lines = ['import Mathlib', '', 'namespace Tick41SavedReturns', '',
         'structure Return where', '  name : String', '  startX : Int', '  endX : Int', '  scale : Int',
         '  deriving DecidableEq, Repr', '', 'def saved : List Return := [']
lines.append(',\n'.join('  ⟨"'+r['name']+'", '+', '.join(ints(r[k]) for k in ['start','end','scale'])+'⟩' for r in returns))
lines.extend([']', '', 'def xCloses (r : Return) : Bool := (r.endX - r.startX) % r.scale == 0', '',
              'abbrev SavedReturn := {r : Return // r ∈ saved}', '', 'end Tick41SavedReturns', ''])
(LEAN / 'Tick41SavedReturns.lean').write_text('\n'.join(lines), encoding='utf-8')
(EVIDENCE / 'saved-returns.json').write_text(json.dumps(returns,indent=2)+'\n')
configuration = record(GO / 'work/threshold-one-pair/on/configuration.json')
report = {
    'checked_at_utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
    'source_hashes': sources, 'snapshot_paths': paths, 'decoded_event_ids': ids,
    'velocity_shape': list(before['g'][...,:3].shape), 'marker_shape': list(before['observer_X'].shape),
    'velocity_bytes_equal': True, 'marker_bytes_equal': True,
    'velocity_bytes': len(encoded_observation['before']['velocity']),
    'marker_bytes': len(encoded_observation['before']['markers']),
    'fabric_changed': True, 'temperature_changed': True,
    'mean_temperature_change': float(np.mean(after['g'][...,4]-before['g'][...,4])),
    'changed_fabric_values': int(np.count_nonzero(before['b']!=after['b'])),
    'comparison_to_prior_A_run': comparison_to_prior_run,
    'witnesses_are_before_after_from_one_archived_run_not_mixed_replays': True,
    'threshold': case['config']['threshold'], 'breathing': breathing,
    'new_fluid_steps': 0, 'new_model_calls': 0,
    'saved_return_count': len(returns), 'saved_periodically_closed_x_count': 0,
    'saved_geometry_manifest_files_verified': len(manifest),
    'trust_boundary': 'The source files and exact byte export/event decoding were checked in Python, not proved by Lean.',
}
assert all(sha(Path(p)) == h for p,h in sources.items())
report['reviewed_sources_preserved'] = True
(OUT / 'Export checks.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({k:v for k,v in report.items() if k not in ['source_hashes','snapshot_paths']},indent=2))
