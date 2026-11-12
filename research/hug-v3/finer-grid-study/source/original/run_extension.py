"""Finite extension of the original fluid-grid study; no solver law is changed."""
import os
os.environ.setdefault('OPENBLAS_NUM_THREADS', '1')
os.environ.setdefault('OMP_NUM_THREADS', '1')
import sys
sys.dont_write_bytecode = True
import argparse
import hashlib
import json
import shutil
import time
import traceback
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PRIOR = ROOT / 'outputs/fluid-convergence'
OUT = ROOT / 'outputs/fluid-finer-grid'
OUT.mkdir(parents=True, exist_ok=True)
sys.path.insert(0, str(ROOT / 'work/fluid-convergence'))
import run_study as base
import numpy as np

def stamp():
    return datetime.now(timezone.utc).isoformat()

def dump(path, value):
    temporary = path.with_suffix(path.suffix + '.tmp')
    temporary.write_text(json.dumps(value, indent=2, allow_nan=False) + '\n', encoding='utf-8')
    temporary.replace(path)

def verify_originals():
    expected = json.loads((PRIOR / 'input-sha256.json').read_text(encoding='utf-8'))
    for p, digest in expected.items():
        if hashlib.sha256(Path(p).read_bytes()).hexdigest() != digest:
            raise AssertionError('Original input changed: ' + p)
    return len(expected)

def prepare():
    verified = verify_originals()
    for name in ['initial-native.npz', 'observer-labels.npz', 'observer-labels.json']:
        source, target = PRIOR / name, OUT / name
        if target.exists():
            assert target.read_bytes() == source.read_bytes(), name
        else:
            shutil.copyfile(source, target)
    return verified

def pilot(n, dt, count=3):
    solver, _, _ = base.make_solver(n)
    state = solver.initial()
    with np.load(PRIOR / 'initial-native.npz') as z:
        f, h = base.coeff(z['g'], 16)
        state['g'] = base.on_grid(h, f, n)
        for k in z.files:
            if k != 'g':
                np.testing.assert_array_equal(state[k], z[k])
    with np.load(PRIOR / 'observer-labels.npz') as z:
        state['observer_X'] = np.vstack([state['observer_X'], z['initial']])
    samples = []
    for i in range(count):
        start = time.monotonic()
        state = solver.step(i * dt, state, dt)
        samples.append(time.monotonic() - start)
        assert all(np.isfinite(v).all() for v in state.values())
    return dict(n=n, dt=dt, steps=count, seconds_per_step=samples,
                estimated_full_run_seconds=float(np.median(samples) * round(1.2/dt)),
                only_a_runtime_pilot=True)

def run(n, dt):
    assert (n, dt) in [(40, .0005), (48, .0005), (48, .00025)]
    count = prepare()
    base.OUT = OUT
    tag = 'n' + str(n) + '_dt' + str(dt).replace('.', 'p')
    folder = OUT / tag
    folder.mkdir(exist_ok=True)
    if (folder / 'status.json').exists() or (folder / 'summary.json').exists():
        raise FileExistsError('Inspect existing run before restarting: ' + tag)
    started = time.monotonic()
    progress = dict(run=tag, n=n, dt=dt, pid=os.getpid(), started_utc=stamp(),
                    status='running', phase='integration', model_time=0.0,
                    completed_steps=0, total_steps=round(1.2/dt),
                    input_hashes_verified=count, no_lean_run=True)
    dump(folder / 'status.json', progress)
    native_step = base.ComparisonSolver.step
    def step(self, t, state, delta):
        result = native_step(self, t, state, delta)
        index = round((t+delta)/delta)
        if index % 20 == 0 or index == round(1.2/delta):
            progress.update(model_time=round(t+delta, 12), completed_steps=index,
                            elapsed_seconds=time.monotonic()-started, observed_utc=stamp())
            dump(folder / 'status.json', progress)
        return result
    base.ComparisonSolver.step = step
    try:
        base.run(n, dt)
        progress.update(phase='gap_measurement', observed_utc=stamp())
        dump(folder / 'status.json', progress)
        import measure
        measure.measure(tag, ds=1/1024, grid=192)
        progress.update(phase='tracing_control', observed_utc=stamp())
        dump(folder / 'status.json', progress)
        measure.measure(tag, ds=1/2048, grid=256)
        progress.update(status='complete', phase='complete', completed_utc=stamp(),
                        elapsed_seconds=time.monotonic()-started,
                        input_hashes_verified_after=verify_originals())
        dump(folder / 'status.json', progress)
    except BaseException as exc:
        progress.update(status='failed', failed_utc=stamp(), error=repr(exc),
                        traceback=traceback.format_exc())
        dump(folder / 'status.json', progress)
        raise
    finally:
        base.ComparisonSolver.step = native_step

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('action', choices=['pilot', 'run'])
    parser.add_argument('--n', type=int, required=True)
    parser.add_argument('--dt', type=float, default=.0005)
    args = parser.parse_args()
    if args.action == 'pilot':
        count = prepare()
        result = pilot(args.n, args.dt)
        result.update(source_hashes_verified=count, observed_utc=stamp())
        dump(OUT / ('pilot-n'+str(args.n)+'.json'), result)
        print(json.dumps(result), flush=True)
    else:
        run(args.n, args.dt)
