"""Repeat the two pictured disk runs with the corpus's smooth exact-off law."""

import argparse
import hashlib
import json
import sys
from pathlib import Path

import numpy as np


def exact_off(q, epsilon):
    q = np.asarray(q, dtype=float)
    activation = np.zeros_like(q)
    active = q > 0
    with np.errstate(over="ignore", under="ignore"):
        activation[active] = q[active] * np.exp(-np.square(epsilon / q[active]))
    return activation


def run_pair(source, grid, steps, epsilon):
    sys.path.insert(0, str(source))
    import startup

    class ComparisonDisk(startup.ClosedDisk):
        smooth = False

        def rate(self, scalar, u, v):
            scalar_rate, du, dv, maximum = super().rate(scalar, u, v)
            if self.smooth:
                q = self.slope(scalar) - 1
                delta = exact_off(q, epsilon) - np.maximum(q, 0)
                # Pressure projection is linear. Correct the already projected
                # sharp force on the same faces, using the same wall and gauge.
                force_x = -0.5 * (delta + startup.neighbor(delta, 1, 1)) * self.ex
                dx, dy = self.project(force_x, np.zeros_like(force_x))
                du, dv = du + dx, dv + dy
            return scalar_rate, du, dv, maximum

        def sample(self, time, scalar, u, v):
            record, patch = super().sample(time, scalar, u, v)
            if self.smooth:
                record['force_H'] = float(exact_off(record['slope_H'] - 1, epsilon))
            return record, patch

    disk = ComparisonDisk(grid)
    unit_slope_h = float(startup.interpolate(disk.slope(disk.profile), 0., 0., grid))
    cases = []
    for controlled_at, amplitude in [('peak', 1.01), ('hole', 1.01 / unit_slope_h)]:
        reference_file = source / f'grid-{grid}-steps-{steps}-{controlled_at}-1.01.json'
        reference = json.loads(reference_file.read_bytes()) if reference_file.exists() else None
        for smooth in (False, True):
            disk.smooth = smooth
            run = disk.run(amplitude, steps)
            history = run['records']
            first, last = history[0], history[-1]
            path = np.asarray([r['parcel_ending_at_H'] for r in history])
            assert np.all(path[-1] == 0)
            assert all(r['max_divergence'] < 1e-8 for r in history)
            assert max(abs(r['scalar_total'] - first['scalar_total']) for r in history) < 1e-10
            assert all(np.isfinite(path.ravel()))
            if reference is not None and not smooth:
                np.testing.assert_allclose(last['velocity_H'], reference['records'][-1]['velocity_H'], rtol=1e-8, atol=1e-13)
                np.testing.assert_allclose(path[0], reference['records'][0]['parcel_ending_at_H'], rtol=1e-8, atol=1e-13)
            result = {
                'controlled_at': controlled_at, 'law': 'smooth exact-off' if smooth else 'sharp',
                'grid': grid, 'steps': steps, 'end_time': last['time'],
                'initial_peak_slope': first['max_slope'], 'initial_slope_H': first['slope_H'],
                'initial_direct_force_H_magnitude': first['force_H'],
                'initial_acceleration_H_image_xy': run['initial_acceleration_H'],
                'final_direct_force_H_magnitude': last['force_H'],
                'final_velocity_H_image_xy': last['velocity_H'], 'final_speed_H': last['speed_H'],
                'parcel_origin_relative_to_H_xy_in_radii': path[0].tolist(),
                'parcel_origin_distance_in_radii': run['start_to_H'],
                'parcel_path_length_in_radii': float(np.linalg.norm(np.diff(path, axis=0), axis=1).sum()),
                'max_recorded_divergence': max(r['max_divergence'] for r in history),
                'historical_sharp_readings_reproduced': reference is not None and not smooth,
            }
            cases.append(result)
            print(grid, controlled_at, result['law'], 'speed', last['speed_H'], 'origin distance', run['start_to_H'], flush=True)
    return cases


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source', type=Path, help='Directory containing the original basin startup.py and reference readings')
    parser.add_argument('output', type=Path)
    parser.add_argument('--epsilon', type=float, default=0.01)
    args = parser.parse_args()
    if args.epsilon <= 0:
        parser.error('epsilon must be positive')
    source = args.source.resolve()
    report = {
        'geometry': 'Original horizontal unit disk, unit depth, impermeable rim. No depth-dependent flow was sampled.',
        'epsilon_in_slope_units': args.epsilon, 'threshold': 1,
        'exact_off': '0 for q<=0, q*exp(-(epsilon/q)^2) for q>0; q=|grad S|-1',
        'original_solver': str(source / 'startup.py'),
        'original_solver_sha256': hashlib.sha256((source / 'startup.py').read_bytes()).hexdigest(),
        'cases': [],
    }
    for grid, steps in [(320, 40), (384, 64)]:
        report['cases'].extend(run_pair(source, grid, steps, args.epsilon))
    args.output.write_text(json.dumps(report, indent=2, allow_nan=False) + '\n', encoding='utf-8')


if __name__ == '__main__':
    main()
