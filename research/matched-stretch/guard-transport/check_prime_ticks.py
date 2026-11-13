"""Compare a 320-step marker clock with a new 250-step replay at their actual shared times."""
import argparse
import csv
import hashlib
import io
import json
from fractions import Fraction
from pathlib import Path
from zipfile import ZipFile

import numpy as np

from check_basin import release_points, replay, sample


PRIMES = (2,3,5,7,11,13,17,19,23,29,31,37,41)


def shared_times():
    marker = {Fraction(k,320): k for k in range(385)}
    mentor = {Fraction(j,250): j for j in range(301)}
    common = sorted(marker.keys() & mentor.keys())
    assert common == [Fraction(i,10) for i in range(13)]
    return [(t, marker[t], mentor[t], prime) for t,prime in zip(common,PRIMES,strict=True)]


def advance(points, left, right, count):
    dt = .1/count
    for i in range(count):
        alpha = i/count
        a = (1-alpha)*sample(left,points) + alpha*sample(right,points)
        mid = points+.5*dt*a
        alpha = (i+.5)/count
        points = points + dt*((1-alpha)*sample(left,mid) + alpha*sample(right,mid))
    return points


def rms(delta):
    return float(np.sqrt(np.mean(np.sum(delta**2,axis=1))))


def exported_ticks(archive, label):
    """Read original prime annotations and y-up positions from the dense-trail CSV."""
    ticks = {}
    with ZipFile(archive) as bundle:
        name = f"trail-dense-{label}.csv"
        with bundle.open(name) as stream:
            digest = hashlib.file_digest(stream, "sha256").hexdigest()
        with bundle.open(name) as stream:
            for r in csv.DictReader(io.TextIOWrapper(stream,encoding="utf-8")):
                if not r["coincidence_prime"]:
                    continue
                tick = int(r["coincidence_prime"])
                rows = ticks.setdefault(tick, [])
                assert int(r["marker_id"]) == len(rows)
                rows.append((float(r["model_time"]),float(r["x"]),-float(r["y"])))
    assert set(ticks) == set(PRIMES) and all(len(rows)==401 for rows in ticks.values())
    return ticks, digest


def compare(grids, exported=None):
    marker, mentor = release_points(), release_points()
    rows = []
    for i,(time,k,j,prime) in enumerate(shared_times()):
        if i:
            left, right = grids[2*i-2], grids[2*i]
            marker = advance(marker,left,right,32)
            mentor = advance(mentor,left,right,25)
        current = grids[2*i]
        delta = mentor-marker
        row = {"prime":prime, "model_time":float(time), "marker_step":k, "mentor_step":j,
               "position_rms":rms(delta), "position_max":float(np.max(np.linalg.norm(delta,axis=1))),
               "velocity_rms_at_own_positions":rms(sample(current,mentor)-sample(current,marker))}
        if 0 < i < 12:
            # Same marker positions. Hide only the velocity readout at this tick.
            estimate = .5*(sample(grids[2*i-2],marker)+sample(grids[2*i+2],marker))
            row["held_out_readout_rms"] = rms(estimate-sample(current,marker))
        if exported is not None:
            reference = np.array(exported[prime])
            np.testing.assert_array_equal(reference[:,0], float(time))
            np.testing.assert_allclose(marker,reference[:,1:],rtol=5.1e-7,atol=1e-14)
        rows.append(row)
    return rows


def main(archive, readings):
    cases = {}
    checked_csvs = {}
    for label,target in (("7.52",.99),("7.67",1.01)):
        if archive:
            grids = {}
            for tick in range(0,25,2):
                with np.load(archive/f"{label}-n384-primary"/f"field-{tick:04}.npz") as z:
                    grids[tick] = np.stack([z["u"],z["v"]],-1)
        else:
            _,grids = replay(target,24)
        exported = None
        if readings:
            exported, checked_csvs[label] = exported_ticks(readings,label)
        cases[label] = compare(grids,exported)
    return {"marker_count":401,"marker_rate":320,"mentor_rate":250,"cases":cases,
            "original_prime_rows_checked":sum(13*401 for _ in checked_csvs),
            "original_csv_sha256":checked_csvs}


if __name__ == "__main__":
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--archive",type=Path,help="read the 13 original frames instead of regenerating them")
    parser.add_argument("--readings",type=Path,help="cross-check all shared rows in the original dense-trail ZIP")
    args = parser.parse_args()
    print(json.dumps(main(args.archive,args.readings),indent=2,allow_nan=False))
