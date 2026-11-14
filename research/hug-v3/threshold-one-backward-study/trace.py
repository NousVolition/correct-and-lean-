"""Extend the six saved threshold-1 frozen lines only in negative signed arclength.

This is floating-point numerical evidence, not a certified ODE enclosure.
The sealed earlier study supplies fields, seeds, and forward candidate lists.
"""
import argparse
import csv
import hashlib
import importlib.util
import json
import platform
import time
from datetime import datetime, timezone
from pathlib import Path

import numpy as np
import scipy
from scipy.integrate import solve_ivp
from scipy.optimize import brentq

HERE = Path(__file__).resolve().parent
STUDY = HERE.parent / 'threshold-one-window-study'
spec = importlib.util.spec_from_file_location('original_window_measure', STUDY / 'measure.py')
original = importlib.util.module_from_spec(spec)
spec.loader.exec_module(original)
field_at, periodic = original.field_at, original.periodic
LENGTHS = (.75, 1.5, 3., 6., 12.)
WINDOWS = {f'back_{n}_{tag}': (-float(n), hi)
           for n in (3, 6, 12)
           for tag, hi in [('only', 0.), ('to075', .75), ('to300', 3.)]}
INPUTS = ('snapshots.npz', 'snapshots.json', 'measure.py', 'measurements.json',
          'measurements-tight.json', 'saved/run-configuration.json',
          'saved/Configuration.json', 'saved/Resolved switches.json')


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def settings(tighter):
    return dict(zip(('rtol', 'atol', 'max_step', 'search_spacing'),
                    (2e-13, 3e-15, .002, 1/8192) if tighter
                    else (2e-12, 3e-14, .004, 1/4096)))


def trace(omega, pair, saved, tighter=False):
    A, B = pair
    cfg = settings(tighter)
    rhs_low = np.inf

    def rhs(s, p):
        nonlocal rhs_low
        w = field_at(omega, p)
        norm = float(np.linalg.norm(w))
        rhs_low = min(rhs_low, norm)
        if norm < 1e-10:
            raise RuntimeError('Unresolved near-zero vorticity direction')
        return w / norm

    pieces, diagnostics, samples_s, samples_p = [], [], [], []
    start, p = 0., A.copy()
    for length in LENGTHS:
        end = -length
        sol = solve_ivp(rhs, (start, end), p, method='DOP853', dense_output=True,
                        rtol=cfg['rtol'], atol=cfg['atol'], max_step=cfg['max_step'])
        if not sol.success:
            raise RuntimeError(sol.message)
        pieces.append((end, start, sol))
        diagnostics.append({'bounds': [end, start], 'nfev': sol.nfev,
                            'accepted_steps': len(sol.t)-1,
                            'initial_join_error': float(np.linalg.norm(sol.sol(start)-p))})
        p, start = sol.y[:, -1], end

    def curve(s):
        for lo, hi, sol in pieces:
            if lo-1e-15 <= s <= hi+1e-15:
                return sol.sol(s)
        raise ValueError(s)

    def slope(s):
        p = curve(s)
        return float(np.dot(periodic(p-B), rhs(s, p)))

    def at(s, kind):
        p = curve(s)
        return {'s': float(s), 'd': float(np.linalg.norm(periodic(p-B))),
                'p': p.tolist(), 'kind': kind}

    roots, sampled_minima = [], []
    sampled_low, rejected_seams = np.inf, 0
    for lo, hi, sol in pieces:
        grid = np.unique(np.r_[np.arange(lo, hi, cfg['search_spacing']), lo, hi, sol.t])
        xyz = sol.sol(grid).T
        w = np.concatenate([field_at(omega, part) for part in np.array_split(xyz, 64)])
        norms = np.linalg.norm(w, axis=1)
        sampled_low = min(sampled_low, float(norms.min()))
        if norms.min() < 1e-10:
            raise RuntimeError('Unresolved sampled near-zero vorticity direction')
        delta = periodic(xyz-B)
        proj = np.einsum('ij,ij->i', delta, w) / norms
        for i in np.flatnonzero((proj[:-1] < 0) & (proj[1:] >= 0)):
            s = brentq(slope, grid[i], grid[i+1], xtol=1e-14)
            if abs(slope(s)) < 2e-9:
                roots.append(at(s, 'interior'))
            else:
                rejected_seams += 1
        sampled_minima.append({'bounds': [lo, hi], 'count': len(grid),
                               'minimum': float(np.linalg.norm(delta, axis=1).min())})
        display = np.linspace(lo, hi, round((hi-lo)*512)+1)
        samples_s.extend(display)
        samples_p.extend(sol.sol(display).T)
    roots.sort(key=lambda r: r['s'])
    unique = []
    for r in roots:
        if not unique or abs(r['s']-unique[-1]['s']) > 1e-9:
            unique.append(r)
    roots = unique

    def window(lo, hi, forward_name=None):
        candidates = [r for r in roots if lo < r['s'] < hi] + [at(lo, 'left endpoint')]
        sampled = min(x['minimum'] for x in sampled_minima
                      if lo <= x['bounds'][0] and x['bounds'][1] <= 0)
        if hi == 0:
            candidates.append(at(0., 'right endpoint'))
        else:
            forward = saved['windows'][forward_name]
            assert forward['bounds'] == [0, hi]
            candidates += [r for r in forward['candidates'] if 0 < r['s'] <= hi]
            # A is an interior point of the combined window, not a new endpoint.
            if abs(slope(0.)) < 2e-9:
                candidates.append(at(0., 'stationary join'))
            sampled = min(sampled, forward['sampled_minimum'])
        candidates.sort(key=lambda r: r['d'])
        winner = candidates[0]
        assert winner['d'] <= sampled + 2e-10
        assert sampled-winner['d'] <= cfg['search_spacing'] + 2e-10
        return {'bounds': [lo, hi], 'winner': winner, 'candidates': candidates,
                'sampled_minimum': sampled}

    windows = {name: window(lo, hi, {0.: None, .75: 'forward_075', 3.: 'forward_300'}[hi])
               for name, (lo, hi) in WINDOWS.items()}
    regression = {}
    for length, suffix in ((.75, '075'), (1.5, '150'), (3., '300')):
        new = window(-length, length, 'forward_'+suffix)['winner']
        old = saved['windows']['both_'+suffix]['winner']
        regression['both_'+suffix] = {'distance_difference': abs(new['d']-old['d']),
                                      'arclength_difference': abs(new['s']-old['s'])}
        assert abs(new['d']-old['d']) < 2e-10
        assert abs(new['s']-old['s']) < 2e-8
    order = np.argsort(samples_s)
    line_s = np.array(samples_s)[order]
    line_p = np.array(samples_p)[order]
    keep = np.r_[True, np.diff(line_s) > 0]
    summary = {'windows': windows, 'settings': cfg,
               'observed_min_rhs_omega': float(rhs_low),
               'observed_min_sampled_omega': sampled_low,
               'join_error_at_A': float(np.linalg.norm(curve(0)-A)),
               'pieces': diagnostics, 'sampled_minima': sampled_minima,
               'rejected_periodic_seam_roots': rejected_seams,
               'original_window_regression': regression,
               'saved_forward_075': saved['windows']['forward_075']['winner']}
    return summary, line_s[keep], line_p[keep]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True,
                        help='New output directory; existing results are never overwritten')
    parser.add_argument('--tighter', action='store_true')
    args = parser.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    inputs = {name: sha(STUDY/name) for name in INPUTS}
    meta = [r for r in json.loads((STUDY/'snapshots.json').read_text())
            if r['label'].startswith('event-')]
    baseline_name = 'measurements-tight.json' if args.tighter else 'measurements.json'
    baseline = {r['label']: r for r in json.loads((STUDY/baseline_name).read_text())}
    rows, lines, flat = [], {}, []
    begin = time.perf_counter()
    with np.load(STUDY/'snapshots.npz', allow_pickle=False) as z:
        for sample in meta:
            label, i = sample['label'], sample['index']
            saved = baseline[label]
            assert saved['time'] == sample['time']
            assert np.array_equal(z['pairs'][i], [saved['A'], saved['B']])
            measured, s, p = trace(z['omega'][i], z['pairs'][i], saved, args.tighter)
            rows.append(dict(sample, A=z['pairs'][i, 0].tolist(),
                             B=z['pairs'][i, 1].tolist(), **measured))
            lines[label+'_s'], lines[label+'_p'] = s, p
            for name, result in measured['windows'].items():
                flat.append(dict(label=label, time=sample['time'], window=name,
                                 **{k: result['winner'][k] for k in ('s', 'd', 'kind')}))
            print(json.dumps({'label': label, 'elapsed_seconds': time.perf_counter()-begin,
                              'backward_winners': {str(n): measured['windows'][f'back_{n}_only']['winner']
                                                   for n in (3, 6, 12)}}), flush=True)
    assert inputs == {name: sha(STUDY/name) for name in INPUTS}
    (out/'measurements.json').write_text(json.dumps(rows, separators=(',', ':'))+'\n')
    np.savez_compressed(out/'traces.npz', **lines)
    with (out/'measurements.csv').open('w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=list(flat[0]))
        writer.writeheader()
        writer.writerows(flat)
    provenance = {'scope': 'NUMERICAL_ONLY; no Lean result or rigorous continuous error bound',
                  'completed_utc': datetime.now(timezone.utc).isoformat(),
                  'direction': 'Negative signed arclength from A; frozen snapshot time',
                  'lengths': LENGTHS, 'tighter': args.tighter, 'settings': settings(args.tighter),
                  'input_sha256': inputs, 'code_sha256': sha(__file__),
                  'runtime': {'python': platform.python_version(), 'numpy': np.__version__,
                              'scipy': scipy.__version__, 'system': platform.system()},
                  'elapsed_seconds': time.perf_counter()-begin,
                  'outputs_sha256': {name: sha(out/name) for name in
                                     ('measurements.json', 'measurements.csv', 'traces.npz')}}
    (out/'provenance.json').write_text(json.dumps(provenance, indent=2)+'\n')


if __name__ == '__main__':
    main()
