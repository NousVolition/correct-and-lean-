"""One declared change from the original breathing-on study: Gamma .015 -> 1."""
import argparse
import csv
from dataclasses import asdict
import hashlib
import importlib.util
import json
from pathlib import Path
import shutil
import sys
from unittest.mock import patch

import numpy as np

from follow_water_pairs import (STUDY, NATIVE, WORK, OUT, DT, WN, ComparisonSolver,
                                Config, Trail, approved_arm, coefficients, field_at,
                                original_pairs, read_npz)
from track_slope_at_a import inverse_particle_step, reading
from vortex_line_fields import forward

DEST = WORK / 'threshold-one'
DEST.mkdir(exist_ok=True)
PUBLIC = OUT / 'Threshold 1 rerun'
PUBLIC.mkdir(exist_ok=True)
PRIMES = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def plain(value):
    if isinstance(value, np.ndarray): return value.tolist()
    if isinstance(value, np.generic): return value.item()
    if isinstance(value, dict): return {k: plain(v) for k, v in value.items()}
    if isinstance(value, (tuple, list)): return [plain(v) for v in value]
    return value


def write_json(path, data):
    path.write_text(json.dumps(plain(data), indent=2, allow_nan=False), encoding='utf-8')


def setup(threshold):
    case, extra = approved_arm('breathing_on')
    assert extra['step'] == DT and extra['end'] == 1.2
    with (STUDY / 'marker-seeds.csv').open(newline='') as f:
        trail = Trail(list(csv.DictReader(f)))
    cfg = dict(case['config'], threshold=threshold)
    changed = {k: [case['config'][k], v] for k, v in cfg.items() if v != case['config'][k]}
    assert changed == ({'threshold': [.015, 1.]} if threshold == 1 else {})
    if threshold == 1:
        # The original gate correctly rejects undeclared parameter changes.
        # Give this user-requested case its own declaration and source seal;
        # retain and execute the unchanged gate, rather than disabling it.
        upstream = STUDY / 'upstream'
        isolated = DEST / 'declared-source'
        old_seal = json.loads((upstream/'source_seal.json').read_text())
        for relative, expected in old_seal.items():
            assert digest(upstream/relative) == expected
            target = isolated/relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(upstream/relative, target)
        protocol = json.loads((isolated/'protocol.json').read_text())
        protocol['cases']['threshold_1'] = dict(config=cfg, events=case['events'])
        write_json(isolated/'protocol.json', protocol)
        manifest = json.loads((isolated/'declarations/main.json').read_text())
        manifest['run_id'] = 'threshold_1'
        manifest['parameters']['threshold'] = 1.
        manifest['fixture_ranges']['threshold'] = dict(min=1., max=1.)
        for rule in manifest['added_rules']:
            if rule['name'] == 'Inherited M16 Force setup':
                rule['statement'] = rule['statement'].replace('Gamma=0.015', 'Gamma=1')
                rule['reason'] = 'User explicitly requested slope threshold 1 from the beginning, with every other setting unchanged, on 2026-11-10. Other M16 choices remain inherited.'
        write_json(isolated/'declarations/threshold_1.json', manifest)
        sealed_paths = list(old_seal) + ['declarations/threshold_1.json']
        write_json(isolated/'source_seal.json', {p:digest(isolated/p) for p in sealed_paths})
        spec = importlib.util.spec_from_file_location('threshold_one_preflight', isolated/'preflight.py')
        gate = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(gate)
        declared_case = gate.approve('threshold_1')
        assert declared_case['config'] == cfg and declared_case['events'] == case['events']
        # StructuralSolver imports its guard by canonical name during construction.
        with patch.dict(sys.modules, {'preflight': gate}):
            solver = ComparisonSolver(Config(**cfg), extra['peak'], extra['period'], trail)
        assert all(digest(upstream/p) == sha for p,sha in old_seal.items())
        write_json(isolated/'derivation.json', dict(parent_source_seal_sha256=digest(upstream/'source_seal.json'),
            changed_existing_files=['protocol.json'], added_files=['declarations/threshold_1.json'],
            numerical_source_files_unchanged=True, guard_unchanged=True, numerical_parameter_changes=changed,
            declaration_accepted=True))
    else:
        solver = ComparisonSolver(Config(**cfg), extra['peak'], extra['period'], trail)
    return solver, case, extra, changed


def integrate(threshold):
    solver, case, extra, changed = setup(threshold)
    control = threshold == .015
    label = 'control' if control else 'threshold-1'
    folder = DEST / label
    folder.mkdir(exist_ok=True)
    state = solver.initial()
    original = read_npz(NATIVE / 'prime-02-at.npz')
    generated_initial_error = 0.
    for k, v in original.items():
        generated_initial_error = max(generated_initial_error, float(np.max(abs(state[k]-v))))
        np.testing.assert_allclose(state[k], v, rtol=0, atol=3e-16, err_msg='Initial state mismatch: '+k)
        # Freeze the saved t=0 arrays exactly, including last-bit FFT rounding.
        state[k] = v.copy()
        np.testing.assert_array_equal(state[k], v)
    if not control:
        labels = np.array(json.loads((DEST / 'particle-identities.json').read_text())['initial_AB'])
        state['observer_X'] = np.vstack([state['observer_X'], labels])
    fingerprints = {str(p): digest(p) for p in [STUDY/'comparison-seal.json', STUDY/'upstream/source_seal.json', WORK/'zoom-at-1178.npz']}
    write_json(folder/'configuration.json', dict(base_case=case, comparison=extra,
                effective_config=asdict(solver.c), parameter_changes=changed,
                actual_step=DT, end=1.2, passive_pair_count=0 if control else 2,
                sources=fingerprints, finite_trace_length=.75))
    events = {round(e['end']/DT): e for e in case['events']}
    starts = {}
    accepted, stages, points, rows, write_checks, native_checks = [], [], [], [], [], []
    captured = []
    native_rhs = solver.rhs
    def capture(t, s, details=False):
        if not details:
            captured.append(coefficients(s['g'][..., :3]))
        return native_rhs(t, s, details)
    with patch.object(solver, 'rhs', capture):
        for frame in range(601):
            time = frame*DT
            if frame:
                captured.clear()
                state = solver.step((frame-1)*DT, state, DT)
                assert len(captured) == 2
                stages.append(np.array(captured))
                assert all(np.isfinite(v).all() for v in state.values())
                if control:
                    state['observer_X'], births = solver.trail.refine(state['observer_X'], time)
                else:
                    pair = state['observer_X'][-2:].copy()
                    trail_points, births = solver.trail.refine(state['observer_X'][:-2], time)
                    state['observer_X'] = np.vstack([trail_points, pair])
            event = events.get(frame)
            if control and frame % 50 == 0:
                side = 'before_write' if event else 'at'
                archived = read_npz(NATIVE / f'prime-{PRIMES[frame//50]:02d}-{side}.npz')
                err = max(float(np.max(abs(state[k]-v))) for k, v in archived.items())
                assert err < 3e-13, (frame, err)
                native_checks.append(dict(frame=frame, side=side, max_error=err))
            if event:
                before = {k: state[k].copy() for k in ('g', 'observer_X', 'X', 'F')}
                record = solver.make_event(state, starts.pop(event['event_id']), event)
                state, work = solver.write_event(state, record)
                decoded = next(r for _, r in solver.read_material(state) if r['event_id']==event['event_id'])
                for k in ('observer_X', 'X', 'F'):
                    np.testing.assert_array_equal(before[k], state[k])
                np.testing.assert_array_equal(before['g'][..., :4], state['g'][..., :4])
                write_checks.append(dict(frame=frame, event_id=event['event_id'], account=work,
                    decoded_delta_E_error=float(np.max(abs(decoded['delta_E']-record['delta_E']))),
                    positions_velocity_context_unchanged=True))
                if control:
                    archived = read_npz(NATIVE / f'prime-{PRIMES[frame//50]:02d}-after_write.npz')
                    err = max(float(np.max(abs(state[k]-v))) for k, v in archived.items())
                    assert err < 3e-13
                    native_checks.append(dict(frame=frame, side='after_write', max_error=err))
            for e in case['events']:
                if round(e['start']/DT) == frame:
                    starts[e['event_id']] = state['F'].copy()
            accepted.append(coefficients(state['g'][..., :3]))
            if not control:
                pair = state['observer_X'][-2:].copy()
                points.append(pair)
                row = reading(state, pair[0], time, solver)
                row['B'] = pair[1].tolist()
                row['threshold_force_work'] = float(state['ledger'][1])
                rows.append(row)
            # Fine investigation can restart locally without altering the native run.
            if frame % 50 == 0 or frame >= 550:
                np.savez_compressed(folder / f'state-{frame:04d}.npz', **state)
            if frame % 50 == 0:
                _, stats, _ = native_rhs(time, state, details=True)
                print(json.dumps(dict(run=label, time=time, div_error=stats['div_error'],
                    det_error=stats['det_error'], context_force_work=float(state['ledger'][1]))), flush=True)
    accepted = np.array(accepted)
    stages = np.array(stages)
    np.testing.assert_array_equal(stages[:, 0], accepted[:-1])
    np.savez(folder / 'fields.npz', velocity=accepted, stages=stages,
             points=np.array(points), times=np.arange(601)*DT)
    if not control:
        write_json(folder/'particle-readings.json', rows)
    write_json(folder/'checks.json', dict(label=label, threshold=solver.c.threshold,
        physical_changes=changed, source_hashes_unchanged=all(digest(Path(p))==h for p,h in fingerprints.items()),
        initial_physical_state_equal=True, initial_state_source='Saved original prime-02 t=0 arrays',
        regenerated_initial_max_error=generated_initial_error,
        original_marker_count=801, final_trail_count=len(solver.trail.info),
        decoded_event_ids=[r['event_id'] for _,r in solver.read_material(state)], writes=write_checks,
        control_checkpoint_checks=native_checks, end=1.2, step=DT))
    if control:
        # The pair was selected at prime 37. Recover those same material labels at t=0.
        pair37 = original_pairs()[0][2:4].copy()
        pair = pair37.copy()
        worst = 0.
        for step in range(549, -1, -1):
            for j in range(2):
                pair[j], error = inverse_particle_step(pair[j], stages[step])
                worst = max(worst, error)
        initial_pair = pair.copy()
        history = [pair.copy()]
        for stage_pair in stages:
            pair = forward(pair, stage_pair)
            history.append(pair.copy())
        history = np.array(history)
        np.testing.assert_allclose(history[550], pair37, atol=3e-13, rtol=0)
        np.testing.assert_allclose(history[589], read_npz(WORK/'zoom-at-1178.npz')['observer_X'][:2], atol=3e-13, rtol=0)
        saved_a0 = json.loads((WORK/'slope-at-A/history.json').read_text())['rows'][0]['A']
        np.testing.assert_allclose(initial_pair[0], saved_a0, atol=3e-13, rtol=0)
        np.savez(folder/'pair-history.npz', points=history, times=np.arange(601)*DT)
        write_json(DEST/'particle-identities.json', dict(initial_AB=initial_pair, prime37_AB=pair37,
            prime37_roundtrip_error=float(np.max(abs(history[550]-pair37))),
            tag_roundtrip_error=float(np.max(abs(history[589]-read_npz(WORK/'zoom-at-1178.npz')['observer_X'][:2]))),
            maximum_inverse_residual=worst, previous_A_origin_error=float(np.max(abs(initial_pair[0]-saved_a0))),
            definition='Original 10% neck central pair, seed 12. Same starting material labels in both runs.'))
    print(label+' COMPLETE', flush=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=['control', 'threshold-1'])
    args = parser.parse_args()
    integrate(.015 if args.mode=='control' else 1.)
