"""Test time-interpolated velocity against withheld fields of the directional Hug–Navier model."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

import numpy as np


SOURCE_COMMIT = "f7b923c40011b2c3a261dc118959f75259cb5ce4"
HASHES = {
    "model.py": "60948e928f31d57e8384f2f7ccd68d4ab9664d6aee3398f82407324bb0f42e30",
    "protocol.json": "ba767c26ec3324f0441e158475910e12b9d225ab1f99859b534f51c280a3ebae",
}
START, END = 0.6, 0.7
STEP = 1 / 320
FIRST, MIDDLE = START + STEP, 0.65
FIELD_TIMES = [START, FIRST, 0.625, MIDDLE, 0.675, END]


def load_source(folder):
    for name, expected in HASHES.items():
        if hashlib.sha256((folder / name).read_bytes()).hexdigest() != expected:
            raise ValueError(f"Expected the pinned upstream version of {name}")
    spec = importlib.util.spec_from_file_location("hug_navier_model", folder / "model.py")
    model = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(model)
    return model, json.loads((folder / "protocol.json").read_text(encoding="utf-8"))


class Snapshot:
    """Periodic Fourier evaluation of velocity and guard gradients on the source's square."""

    def __init__(self, fields):
        n = fields.shape[-1]
        self.modes = np.fft.fftfreq(n) * n
        coeff = np.fft.fft2(fields, axes=(-2, -1), norm="forward")
        self.velocity_coeff = coeff[:2]
        self.gradient_coeff = np.stack(
            [1j * self.modes[:, None] * coeff[4:6], 1j * self.modes * coeff[4:6]],
            axis=1,
        )

    def evaluate(self, coeff, points):
        ex = np.exp(1j * np.outer(points[:, 0], self.modes))
        ey = np.exp(1j * np.outer(points[:, 1], self.modes))
        return np.einsum("pi,...ij,pj->p...", ex, coeff, ey, optimize=True).real

    def velocity(self, points):
        return self.evaluate(self.velocity_coeff, points)

    def gradients(self, points):
        return self.evaluate(self.gradient_coeff, points)


def snapshots(model, protocol, n, dt):
    # The published dynamics and case are reused; this experiment requests extra field outputs.
    config = {**protocol, "time": {**protocol["time"], "end": END, "field_times": FIELD_TIMES}}
    case, = [c for c in model.cases(config) if
             (c["mode"], c["weight"], c["pulse"]) == ("directional", "equal", "B")]
    _, fields, times = model.run(config, [case], n, dt)
    np.testing.assert_allclose(times, FIELD_TIMES, rtol=0, atol=2e-15)
    if not np.isfinite(fields).all():
        raise ValueError("Non-finite field")
    return {t: Snapshot(frame[0]) for t, frame in zip(FIELD_TIMES, fields)}


def blend(fields, left, right, time, points):
    a = (time - left) / (right - left)
    return (1 - a) * fields[left].velocity(points) + a * fields[right].velocity(points)


def marker_positions(fields):
    # Deliberately off-grid at N=32 and N=48. These are new diagnostic labels seeded at 0.6.
    axis = (np.arange(8) + 0.37) * (2 * np.pi / 8)
    p = np.stack(np.meshgrid(axis, axis, indexing="ij"), axis=-1).reshape(-1, 2)
    positions = {START: p.copy()}
    for k in range(16):
        t = START + k * STEP
        k1 = blend(fields, START, END, t, p)
        k2 = blend(fields, START, END, t + STEP/2, p + STEP*k1/2)
        k3 = blend(fields, START, END, t + STEP/2, p + STEP*k2/2)
        k4 = blend(fields, START, END, t + STEP, p + STEP*k3)
        p = p + STEP*(k1 + 2*k2 + 2*k3 + k4)/6
        if k in (0, 15):
            positions[FIRST if k == 0 else MIDDLE] = p.copy()
    return positions


def sampling_control():
    # Divergence-free shear, linear in time. Use independent analytic values, including a seam crossing.
    n = 16
    x, y = np.meshgrid(np.arange(n)*2*np.pi/n, np.arange(n)*2*np.pi/n, indexing="ij")
    def frame(a):
        return Snapshot(np.stack([(1+a)*np.sin(y), np.ones_like(y), 0*x, 0*x,
                                  np.sin(x)*np.cos(y), np.cos(x)*np.sin(y)]))
    fields = {0.: frame(0), 1.: frame(1)}
    old = np.array([[0.4, 2*np.pi-0.01], [1.2, 0.7]])
    new = old + [0.02, 1/32]
    for a in (0., 1/32, 0.5, 1.):
        exact = np.column_stack([(1+a)*np.sin(new[:, 1]), np.ones(len(new))])
        np.testing.assert_allclose(blend(fields, 0., 1., a, new), exact, atol=1e-12, rtol=0)
    cx, cy = np.cos(new).T
    sx, sy = np.sin(new).T
    exact_gradients = np.stack([np.column_stack([cx*cy, -sx*sy]),
                                np.column_stack([-sx*sy, cx*cy])], axis=1)
    np.testing.assert_allclose(fields[0.].gradients(new), exact_gradients, atol=1e-12, rtol=0)
    stale = (31*fields[0.].velocity(old) + fields[1.].velocity(new))/32
    if np.max(abs(blend(fields, 0., 1., 1/32, new) - stale)) < 0.01:
        raise AssertionError("Manufactured control failed to detect the stale-position substitution")


def rms(values):
    return float(np.sqrt(np.mean(np.square(values))))


def measure(fields, positions, left, right, t):
    p = positions[t]
    a = (t - left) / (right - left)
    reference = fields[t].velocity(p)
    gradients = fields[t].gradients(p)
    u0, u1 = fields[left].velocity(p), fields[right].velocity(p)
    reconstructed = blend(fields, left, right, t, p)
    if not np.all(np.isfinite([u0, u1, reference, reconstructed])):
        raise ValueError("Non-finite velocity readout")
    delta = reconstructed - reference
    guard_error = np.einsum("pi,pgi->pg", delta, gradients)
    def dot(v):
        return np.einsum("pi,pgi->pg", v, gradients)
    np.testing.assert_allclose(dot(reconstructed) - dot(reference), guard_error,
                               atol=2e-15, rtol=1e-12)
    measurement = {
        "t": t, "left": left, "right": right,
        "velocity_rms_vector_error": rms(np.linalg.norm(delta, axis=1)),
        "velocity_max_vector_error": float(np.linalg.norm(delta, axis=1).max()),
        "guard_advection_rms_error_AB_BA": [rms(column) for column in guard_error.T],
    }
    if left == START:
        stale = (1-a)*fields[left].velocity(positions[START]) + a*u1
        measurement["stale_left_velocity_rms_vector_error"] = rms(np.linalg.norm(stale-reference, axis=1))
    if t == FIRST:
        measurement["marker_index_17"] = {
            "initial_position": positions[START][17].tolist(), "new_position": p[17].tolist(),
            "left_at_initial_position": fields[left].velocity(positions[START][17:18])[0].tolist(),
            "left_at_new_position": u0[17].tolist(), "right_at_new_position": u1[17].tolist(),
            "blend": reconstructed[17].tolist(), "withheld_velocity": reference[17].tolist(),
        }
    return measurement


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source_folder", type=Path, help="pinned reports/sims-navier-stokes-guard directory")
    args = parser.parse_args()
    sampling_control()
    model, protocol = load_source(args.source_folder)
    result = {"source_commit": SOURCE_COMMIT, "source_sha256": HASHES,
              "condition": "directional / equal weights / pulse B", "marker_count": 64,
              "sampling_control": "passed", "runs": []}
    positions = None
    for n, dt in [(32, STEP), (32, STEP/2), (48, STEP/2)]:
        fields = snapshots(model, protocol, n, dt)
        if positions is None:
            positions = marker_positions(fields)
        checks = [measure(fields, positions, START, END, FIRST),
                  measure(fields, positions, START, END, MIDDLE),
                  measure(fields, positions, 0.625, 0.675, MIDDLE)]
        result["runs"].append({"grid": n, "solver_dt": dt, "checks": checks})
    print(json.dumps(result, indent=2, allow_nan=False))


if __name__ == "__main__":
    main()
