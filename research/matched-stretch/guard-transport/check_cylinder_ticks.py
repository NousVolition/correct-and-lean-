"""Join the four historical cylinder trajectories at exact clock coincidences."""
import argparse
import csv
import hashlib
import json
from pathlib import Path

import numpy as np

from check_prime_ticks import shared_times


def read_originals(path, expected, selected):
    with path.open("rb") as stream:
        if hashlib.file_digest(stream, "sha256").hexdigest() != expected:
            raise ValueError(f"Source hash differs for {path.name}")
    frames = {time: {} for time in selected}
    population = dict.fromkeys(selected, 0)
    with path.open(newline="", encoding="utf-8") as stream:
        for row in csv.DictReader(stream):
            t = row["time"]
            if t not in selected:
                continue
            population[t] += 1
            if int(row["inserted"]):
                continue
            idx = int(row["marker_id"])
            if idx in frames[t]:
                raise ValueError(f"Repeated original ID {idx} at {t}")
            frames[t][idx] = float(row["z"])
    ids = list(range(801))
    for t, frame in frames.items():
        if sorted(frame) != ids:
            raise ValueError(f"Incomplete original marker population at {t}")
    return {t:np.array([frame[i] for i in ids]) for t,frame in frames.items()}, population


def main(folder, provenance):
    hashes = json.loads(provenance.read_bytes())["csv_outputs"]
    ticks = shared_times()
    selected = {format(float(t),".3f") for t,_,_,_ in ticks}
    cases = {}
    for label in ("7.52","7.67"):
        frames, counts = {}, {}
        for mode in ("baseline","breathing"):
            name = f"trail-{label}-{mode}.csv"
            frames[mode],counts[mode] = read_originals(folder/name,hashes[name]["csv_sha256"],selected)
        rows = []
        for t,k,j,prime in ticks:
            key = format(float(t),".3f")
            frame = t*500
            assert frame.denominator == 1
            diff = frames["breathing"][key]-frames["baseline"][key]
            rows.append({"prime":prime,"time":float(t),"marker_step":k,"mentor_step":j,
                         "cylinder_frame":int(frame),"baseline_population":counts["baseline"][key],
                         "breathing_population":counts["breathing"][key],"paired_original_ids":len(diff),
                         "depth_difference_rms":float(np.sqrt(np.mean(diff**2))),
                         "release_depth_difference":float(diff[0])})
        cases[label] = rows
    return cases


if __name__ == "__main__":
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("csv_folder",type=Path)
    parser.add_argument("--provenance",type=Path,
                        default=Path(__file__).parent/"basin_sources/basin-solver-provenance.original.json")
    args=parser.parse_args()
    print(json.dumps(main(args.csv_folder,args.provenance),indent=2,allow_nan=False))
