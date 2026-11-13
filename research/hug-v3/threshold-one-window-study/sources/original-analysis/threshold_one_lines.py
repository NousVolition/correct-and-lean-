"""Read the same forward .75-length vortex trace against the same partner B."""
import argparse
import json
import time
import numpy as np

from threshold_one_run import DEST, DT, WN, write_json
from inspect_turn import profile


def measure(velocity, pair, stamp, tight=False):
    omega = np.cross(WN, velocity)
    if np.max(abs(omega)) < 1e-12:
        return dict(time=float(stamp), A=pair[0].tolist(), B=pair[1].tolist(), defined=False,
                    reason='Zero vorticity; no vortex-line direction.')
    # profile's third slot is an old carried-point diagnostic, unused by its
    # closest-point calculation. Do not report that unrelated diagnostic here.
    p = profile(omega, np.vstack([pair, pair[0]]), tight=tight)
    rank = min(range(len(p['minima'])), key=lambda i:p['minima'][i]['d'])
    ordered = sorted(p['minima'], key=lambda m:m['d'])
    return dict(time=float(stamp), A=pair[0].tolist(), B=pair[1].tolist(), defined=True,
                winner=p['winner'], minima=p['minima'], winner_rank=rank,
                distance_margin=ordered[1]['d']-ordered[0]['d'] if len(ordered)>1 else None,
                min_omega=p['min_omega'], closest_omega=p['closest_omega'], line=p['line'])


def main(focus_only=False):
    folder = DEST/'threshold-1'
    with np.load(folder/'fields.npz') as data:
        velocity, pairs = data['velocity'], data['points']
    order = list(range(550,601))
    if not focus_only: order += list(range(550))
    rows = {}
    start = time.perf_counter()
    for frame in order:
        row = measure(velocity[frame], pairs[frame], frame*DT)
        rows[frame] = row
        if frame % 10 == 0 or frame in (589,590):
            print(json.dumps(dict(frame=frame, time=frame*DT, elapsed=time.perf_counter()-start,
                winner=row.get('winner'), minima=len(row.get('minima',[])))), flush=True)
            write_json(folder/'line-progress.json', dict(frame=frame, completed=len(rows), elapsed=time.perf_counter()-start))
        if len(rows)%50 == 0 or frame==600:
            write_json(folder/'closest-point-readings.json', [rows[k] for k in sorted(rows)])
    ordered = [rows[k] for k in sorted(rows)]
    candidates = []
    for a,b in zip(ordered,ordered[1:]):
        if not (a['defined'] and b['defined']):continue
        changed_rank = len(a['minima'])==len(b['minima']) and a['winner_rank']!=b['winner_rank']
        large_arc_change = abs(a['winner']['s']-b['winner']['s']) > .025
        if changed_rank or large_arc_change:
            candidates.append(dict(left=a['time'],right=b['time'], left_s=a['winner']['s'],right_s=b['winner']['s'],
                left_d=a['winner']['d'],right_d=b['winner']['d'],rank_change=changed_rank,
                status='Candidate only; distinguish branch exchange from continuous movement by refinement.'))
    write_json(folder/'closest-point-readings.json', ordered)
    write_json(folder/'switch-candidates.json', candidates)
    print(json.dumps(dict(rows=len(rows), candidates=candidates, elapsed=time.perf_counter()-start)),flush=True)


if __name__=='__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('--focus-only',action='store_true')
    args=parser.parse_args()
    main(args.focus_only)
