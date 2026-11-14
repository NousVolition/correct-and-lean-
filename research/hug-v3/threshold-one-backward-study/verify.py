"""Recount saved numerical evidence; optionally compare a fresh numerical replay.

All thresholds below are numerical acceptance tests, not certified error bounds.
"""
import argparse
import csv
import json
import platform
from datetime import datetime, timezone
from pathlib import Path

import numpy as np
import scipy

import trace as study

HERE = Path(__file__).resolve().parent
LABELS = [f'event-{i}-{side}' for i in (1, 2, 3) for side in ('left', 'right')]


def load(directory):
    return json.loads((directory/'measurements.json').read_text())


def check_pass(directory, tighter):
    rows = load(directory)
    assert [r['label'] for r in rows] == LABELS
    provenance = json.loads((directory/'provenance.json').read_text())
    assert provenance['tighter'] == tighter
    assert provenance['settings'] == study.settings(tighter)
    assert provenance['code_sha256'] == study.sha(HERE/'trace.py')
    for name, digest in provenance['input_sha256'].items():
        assert study.sha(study.STUDY/name) == digest, name
    for name, digest in provenance['outputs_sha256'].items():
        assert study.sha(directory/name) == digest, name
    meta = {r['label']: r for r in json.loads((study.STUDY/'snapshots.json').read_text())}
    with (directory/'measurements.csv').open(newline='') as f:
        csv_rows = list(csv.DictReader(f))
    assert len(csv_rows) == 54
    csv_map = {(r['label'], r['window']): r for r in csv_rows}
    nested, candidates, max_slope = 0, 0, 0.
    with np.load(directory/'traces.npz', allow_pickle=False) as lines, \
         np.load(study.STUDY/'snapshots.npz', allow_pickle=False) as archive:
        for row in rows:
            label, index = row['label'], row['index']
            assert index == meta[label]['index'] and row['time'] == meta[label]['time']
            assert np.array_equal(archive['pairs'][index], [row['A'], row['B']])
            assert row['settings'] == study.settings(tighter)
            assert row['join_error_at_A'] == 0
            assert all(p['initial_join_error'] == 0 for p in row['pieces'])
            s, p = lines[label+'_s'], lines[label+'_p']
            assert s.shape == (6145,) and p.shape == (6145, 3)
            assert s[0] == -12 and s[-1] == 0 and np.all(np.diff(s) > 0)
            assert np.array_equal(p[-1], row['A']) and np.isfinite(p).all()
            assert np.max(np.linalg.norm(np.diff(p, axis=0), axis=1)-np.diff(s)) < 1e-10
            assert set(row['windows']) == set(study.WINDOWS)
            for name, w in row['windows'].items():
                assert w['bounds'] == list(study.WINDOWS[name])
                lo, hi = w['bounds']
                winner = w['winner']
                assert winner == w['candidates'][0]
                assert winner['d'] == min(c['d'] for c in w['candidates'])
                assert winner['s'] < 0 and winner['kind'] == 'interior'
                assert winner['d'] < row['saved_forward_075']['d']
                c = csv_map[(label, name)]
                assert float(c['time']) == row['time']
                assert float(c['s']) == winner['s'] and float(c['d']) == winner['d']
                assert c['kind'] == winner['kind']
                for candidate in w['candidates']:
                    candidates += 1
                    assert lo <= candidate['s'] <= hi
                    delta = study.periodic(np.array(candidate['p'])-row['B'])
                    assert abs(np.linalg.norm(delta)-candidate['d']) < 1e-12
                vel = study.field_at(archive['omega'][index], winner['p'])
                slope = abs(np.dot(study.periodic(np.array(winner['p'])-row['B']),
                                   vel/np.linalg.norm(vel)))
                max_slope = max(max_slope, float(slope))
                assert slope < 2e-9
                sampled = np.linalg.norm(study.periodic(p[(lo <= s) & (s <= min(hi, 0))]-row['B']), axis=1).min()
                assert winner['d'] <= sampled + 2e-10
                assert sampled-winner['d'] < 1/512 + 2e-10
                for other in row['windows'].values():
                    a, b = other['bounds']
                    if (a, b) != (lo, hi) and a <= lo and hi <= b:
                        nested += 1
                        assert other['winner']['d'] <= winner['d'] + 2e-12
            for old in row['original_window_regression'].values():
                assert old['distance_difference'] < 2e-10
                assert old['arclength_difference'] < 2e-8
    return {'readings': len(csv_rows), 'nested_comparisons': nested,
            'candidate_entries_recounted': candidates,
            'maximum_winner_stationarity_residual': max_slope,
            'observed_min_rhs_omega': min(r['observed_min_rhs_omega'] for r in rows),
            'observed_min_sampled_omega': min(r['observed_min_sampled_omega'] for r in rows),
            'maximum_original_distance_difference': max(v['distance_difference']
                for r in rows for v in r['original_window_regression'].values()),
            'maximum_original_arclength_difference': max(v['arclength_difference']
                for r in rows for v in r['original_window_regression'].values())}


def compare(a, b):
    maximum = {'winner_distance': 0., 'winner_arclength': 0., 'winner_position': 0.,
               'sampled_trace_position': 0.}
    first, second = load(a), load(b)
    assert [r['label'] for r in first] == [r['label'] for r in second] == LABELS
    with np.load(a/'traces.npz') as la, np.load(b/'traces.npz') as lb:
        for ra, rb in zip(first, second):
            assert ra['index'] == rb['index'] and ra['time'] == rb['time']
            assert ra['A'] == rb['A'] and ra['B'] == rb['B']
            for name in study.WINDOWS:
                wa, wb = ra['windows'][name]['winner'], rb['windows'][name]['winner']
                assert wa['kind'] == wb['kind']
                maximum['winner_distance'] = max(maximum['winner_distance'], abs(wa['d']-wb['d']))
                maximum['winner_arclength'] = max(maximum['winner_arclength'], abs(wa['s']-wb['s']))
                maximum['winner_position'] = max(maximum['winner_position'],
                    float(np.linalg.norm(np.array(wa['p'])-wb['p'])))
            label = ra['label']
            assert np.array_equal(la[label+'_s'], lb[label+'_s'])
            maximum['sampled_trace_position'] = max(maximum['sampled_trace_position'],
                float(np.linalg.norm(la[label+'_p']-lb[label+'_p'], axis=1).max()))
    assert maximum['winner_distance'] < 2e-9, maximum
    assert maximum['winner_arclength'] < 2e-8, maximum
    assert maximum['winner_position'] < 2e-8, maximum
    assert maximum['sampled_trace_position'] < 2e-8, maximum
    return maximum


def fixture():
    # Analytic unit-speed line x(s)=(.8s,.6s,0), B=(-.16,-.12,.1).
    # Torus distance is >= .1 and reaches .1 at s=-.2 (and at repeats).
    omega = np.zeros((11, 11, 11, 3), dtype=complex)
    omega[5, 5, 5] = [.8, .6, 0]
    pair = np.array([[0., 0., 0.], [-.16, -.12, .1]])
    saved = study.original.measure(omega, pair)
    result, s, p = study.trace(omega, pair, saved)
    err = float(np.linalg.norm(p-s[:, None]*np.array([.8, .6, 0]), axis=1).max())
    assert err < 1e-10
    assert all(abs(w['winner']['d']-.1) < 1e-12 for w in result['windows'].values())
    assert abs(result['windows']['back_3_only']['winner']['s']+.2) < 1e-12
    return {'status': 'PASS', 'maximum_position_error': err, 'expected_minimum': .1,
            'scope': 'Numerical direction, joins and periodic minima for an analytic constant field'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path)
    parser.add_argument('--replay', type=Path, help='Fresh parent directory containing normal/ and tight/')
    args = parser.parse_args()
    manifest = HERE/'bundle-sha256.json'
    if manifest.exists():
        for name, digest in json.loads(manifest.read_text()).items():
            assert study.sha(HERE/name) == digest, name
    normal, tight = load(HERE/'normal'), load(HERE/'tight')
    events = []
    for i in range(3):
        left, right = normal[2*i:2*i+2]
        event = {'event': i+1, 'bracket': [left['time'], right['time']], 'sides': {}}
        for side, row in [('left', left), ('right', right)]:
            winners = {str(n): row['windows'][f'back_{n}_only']['winner'] for n in (3, 6, 12)}
            event['sides'][side] = {'winners': winners,
                'improvement_from_3_to_12': winners['3']['d']-winners['12']['d'],
                'improvement_from_original_forward': row['saved_forward_075']['d']-winners['12']['d']}
            assert all(row['windows'][f'back_{n}_'+suffix]['winner'] == winners[str(n)]
                       for n in (3, 6, 12) for suffix in ('to075', 'to300'))
        event['winner_position_change_across_bracket'] = float(np.linalg.norm(study.periodic(
            np.array(event['sides']['left']['winners']['12']['p'])-
            event['sides']['right']['winners']['12']['p'])))
        events.append(event)
    result = {'status': 'PASS', 'scope': 'NUMERICAL_ONLY; no Lean result',
              'checked_utc': datetime.now(timezone.utc).isoformat(),
              'runtime': {'python': platform.python_version(), 'numpy': np.__version__,
                          'scipy': scipy.__version__, 'system': platform.system()},
              'normal': check_pass(HERE/'normal', False), 'tight': check_pass(HERE/'tight', True),
              'normal_vs_tight': compare(HERE/'normal', HERE/'tight'),
              'analytic_fixture': fixture(), 'events': events,
              'limitations': ['Tighter agreement is not an error bound against an exact trace.',
                              'Sampled root searches do not prove exhaustive continuous minima.',
                              'Six frozen fields only; no new fluid evolution or convergence test.',
                              'No new Lean proof; full trajectories and minima remain uncertified.']}
    if args.replay:
        result['fresh_replay'] = {}
        for name, tighter in [('normal', False), ('tight', True)]:
            folder = args.replay/name
            result['fresh_replay'][name] = {'checks': check_pass(folder, tighter),
                                          'comparison_to_published': compare(HERE/name, folder)}
    if args.output:
        if args.output.resolve().exists():
            raise FileExistsError('Fresh verification receipts must not overwrite saved evidence')
        args.output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
