import argparse
import csv
import json

import numpy as np
from scipy.integrate import solve_ivp
from scipy.interpolate import CubicSpline
from scipy.optimize import brentq

from zoom_curves import (ARCHIVED, DT, FIRST_FRAME, LENGTH, T0, T1, WORK, dense_fields,
                         field_at, periodic, tangent, xyz)


def native_sampler(n):
    with np.load(WORK / f"zoom-native-{n}.npz") as z:
        grid = T0 + DT*np.arange(n+1)/n
        w = CubicSpline(grid, z["omega"],axis=0)
        p = CubicSpline(grid, z["points"],axis=0)
    return lambda t: (w(t), p(t))


def profile(omega, points, tight=False):
    A, B, C = points
    def rhs(s, p):
        w = field_at(omega,p)
        norm = np.linalg.norm(w)
        if norm < 1e-10:
            raise RuntimeError("Unresolved near-zero vorticity direction")
        return w/norm

    result = solve_ivp(rhs, (0,LENGTH), A, method="DOP853",
                       rtol=2e-12 if tight else 2e-10, atol=3e-14 if tight else 2e-12,
                       dense_output=True, max_step=.004 if tight else .009)
    assert result.success
    curve = result.sol
    # Resolve the entire forward trace, including its ends. Bracket by sign of
    # the distance derivative, then evaluate each local minimum in 3D.
    s = np.unique(np.r_[np.arange(0,LENGTH+1e-14,1/(4096 if tight else 2048)),result.t])
    line = curve(s).T
    omega_values = np.concatenate([field_at(omega,a) for a in np.array_split(line,16)])
    norms = np.linalg.norm(omega_values,axis=1)
    projection = np.einsum("ij,ij->i",periodic(line-B),omega_values)/norms
    def slope(x):
        p = curve(x)
        return float(np.dot(periodic(p-B),rhs(x,p)))
    def location(x):
        p = curve(x)
        return dict(s=float(x),d=float(np.linalg.norm(periodic(p-B))),p=p.tolist())
    minima = []
    if projection[0] >= 0:
        minima.append(location(0))
    for i in np.flatnonzero((projection[:-1] < 0) & (projection[1:] >= 0)):
        x = brentq(slope, s[i], s[i+1], xtol=1e-14)
        if abs(slope(x)) < 2e-9:
            minima.append(location(x))
    if projection[-1] <= 0:
        minima.append(location(LENGTH))
    # Fixed arclength is a geometric reference, while C is the old closest
    # water particle transported by the native velocity.
    old_s = float(ARCHIVED[FIRST_FRAME]["closest_arclength_cube_lengths"])
    end_s = float(ARCHIVED[FIRST_FRAME+1]["closest_arclength_cube_lengths"])
    closest = min(minima,key=lambda m:m["d"])
    # Plot the first .75, with a more detailed view possible in the display.
    display_s = np.linspace(0,LENGTH,193)
    return dict(minima=minima, winner=closest, min_omega=float(norms.min()),
                closest_omega=float(np.linalg.norm(field_at(omega,curve(closest["s"])))),
                old_s=location(old_s), end_s=location(end_s),
                A=A.tolist(), B=B.tolist(), C=C.tolist(),
                carried_miss=float(np.linalg.norm(periodic(C-B))),
                line=curve(display_s).T.round(8).tolist())


def run(args):
    if args.source == "dense":
        sample = lambda t: dense_fields((t-T0)/DT)
    else:
        sample = native_sampler(int(args.source))
    times = np.linspace(args.start,args.stop,args.count)
    frames = []
    for time in times:
        r = profile(*sample(time),tight=args.tight)
        r["t"]=float(time)
        frames.append(r)
    out = WORK/f"zoom-{args.name}.json"
    out.write_text(json.dumps(frames,separators=(",",":")))
    for r in frames:
        candidates = [(round(p["s"],6), round(p["d"],6)) for p in r["minima"] if p["d"] < r["winner"]["d"]+.01]
        print(f'{r["t"]:.9f} s={r["winner"]["s"]:.6f} d={r["winner"]["d"]:.7f} low={r["min_omega"]:.6g} {candidates}',flush=True)


if __name__ == "__main__":
    parser=argparse.ArgumentParser()
    parser.add_argument("name")
    parser.add_argument("source")
    parser.add_argument("start",type=float)
    parser.add_argument("stop", type=float)
    parser.add_argument("count",type=int)
    parser.add_argument("--tight",action="store_true")
    run(parser.parse_args())
