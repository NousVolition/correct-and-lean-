"""Withhold true half-tick fields from both dense-trail basin replays."""
import argparse
import hashlib
import json
from pathlib import Path

import numpy as np

from basin_sources.startup import ClosedDisk, VISCOSITY, interpolate, neighbor


def velocity_grid(disk, u, v):
    axis = -1 + (np.arange(96) + .5) * 2/96
    x, y = np.meshgrid(axis, axis)
    centered = ((u+neighbor(u, 1, -1))/2, (v+neighbor(v, 0, -1))/2)
    return np.stack([interpolate(f, x, y, disk.n) for f in centered], -1).astype("float32")


def release_points():
    segments = np.array([[(599,414),(667,350),(787,337),(873,379)],
                         [(873,379),(927,403),(942,441),(890,470)]])
    t = np.linspace(0, 1, 1201)[:, None]
    curves = [((1-t)**3*a + 3*(1-t)**2*t*b + 3*(1-t)*t*t*c + t**3*d - [890,470])
              / [650,270] for a,b,c,d in segments]
    trail = np.vstack([curves[0], curves[1][1:]])
    distance = np.r_[0., np.cumsum(np.linalg.norm(np.diff(trail, axis=0), axis=1))]
    labels = np.linspace(0, distance[-1], 401)
    return np.column_stack([np.interp(labels, distance, col) for col in trail.T])


def sample(grid, points):
    grid = grid.astype(float, copy=False)
    ix, iy = ((points+1)*48-.5).T
    j, i = np.floor(ix).astype(int), np.floor(iy).astype(int)
    assert np.all((j >= 0) & (j < 95) & (i >= 0) & (i < 95))
    ax, ay = (ix-j)[:,None], (iy-i)[:,None]
    return ((1-ay)*((1-ax)*grid[i,j]+ax*grid[i,j+1]) +
            ay*((1-ax)*grid[i+1,j]+ax*grid[i+1,j+1]))


def positions_at_midpoints(grids):
    # Original explicit midpoint tracer. Only the original 0.1-spaced frames move it.
    p = release_points()
    midpoints = {}
    for frame in range(9):
        left, right = grids[2*frame], grids[2*frame+2]
        def at(points, a):
            return (1-a)*sample(left, points) + a*sample(right, points)
        dt = .1/32
        for step in range(32):
            v = at(p, step/32)
            p = p + dt*at(p + dt*v/2, (step+.5)/32)
            if step == 15:
                midpoints[2*frame+1] = p.copy()
    return midpoints


def case(label, target, archive):
    disk = ClosedDisk(384)
    amplitude = target / float(interpolate(disk.slope(disk.profile), 0., 0., 384))
    s = amplitude * disk.profile.copy()
    u, v = np.zeros_like(s), np.zeros_like(s)
    grids = {0: velocity_grid(disk, u, v)}
    for tick in range(1,20):
        t, stop = (tick-1)*.05, tick*.05
        while stop-t > 1e-12:
            if tick <= 12:
                dt = min(.0015625, stop-t)
            else:
                speed = np.max(abs(u)) + np.max(abs(v))
                dt = min(stop-t, .2*disk.h**2/VISCOSITY, .7*disk.h/max(speed, 1e-10))
            state = (s,u,v)
            first = disk.rate(*state)
            mid = [a+.5*dt*b for a,b in zip(state, first[:3])]
            second = disk.rate(*mid)
            s,u,v = [a+dt*b for a,b in zip(state, second[:3])]
            t += dt
        grids[tick] = velocity_grid(disk, u, v)
    digests = {}
    for tick in range(0,19,2):
        if archive:
            with np.load(archive/f"{label}-n384-primary"/f"field-{tick:04}.npz") as saved:
                np.testing.assert_array_equal(grids[tick], np.stack([saved["u"],saved["v"]],-1))
        digests[str(tick)] = hashlib.sha256(grids[tick].astype("<f4").tobytes()).hexdigest()
    positions = positions_at_midpoints(grids)
    checks = []
    for tick in (7,13,17):
        p = positions[tick]
        truth = sample(grids[tick], p)
        errors = []
        for reach in (2,1):
            predicted = .5*(sample(grids[tick-reach],p) + sample(grids[tick+reach],p))
            per_marker = np.linalg.norm(predicted-truth, axis=1)
            errors.append(dict(spacing=2*reach*.05, rms=float(np.sqrt(np.mean(per_marker**2))),
                               maximum=float(per_marker.max()), max_marker=int(np.argmax(per_marker))))
        checks.append(dict(time=tick*.05, errors=errors, ratio=errors[0]["rms"]/errors[1]["rms"]))
    return dict(case=label, target=target, amplitude=amplitude, markers=401,
                grid=384, sampling_grid=96, original_frame_sha256=digests, checks=checks)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--archive", type=Path, help="original continued/ directory for bytewise comparison")
    args = parser.parse_args()
    print(json.dumps([case("7.52",.99,args.archive), case("7.67",1.01,args.archive)],
                     indent=2, allow_nan=False))
