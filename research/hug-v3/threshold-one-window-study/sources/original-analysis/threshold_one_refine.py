"""Resolve closest-point branch changes without changing the archived native run."""
import argparse
import json
import numpy as np

from threshold_one_run import DEST, DT, setup, write_json, read_npz, coefficients, WN
from threshold_one_lines import measure


def copy_state(state): return {k:v.copy() for k,v in state.items()}


def line_row(state, stamp, tight=False):
    return measure(coefficients(state['g'][..., :3]), state['observer_X'][-2:], stamp, tight)


def refine(level):
    solver, _, _, _ = setup(1.)
    solver.initial()
    folder = DEST/'threshold-1'
    payload = dict(level=level, substeps_per_native_step=level, intervals=[])
    for first, last in ((589,592),(599,600)):
        start, end = first*DT, last*DT
        state = read_npz(folder/f'state-{first:04d}.npz')
        stamp = start
        rows = [line_row(state, stamp, tight=True)]
        snapshots = {stamp:copy_state(state)}
        h = DT/level
        switches=[]
        for k in range(1,(last-first)*level+1):
            t = start + k*h
            state = solver.step(start+(k-1)*h,state,h)
            row = line_row(state,t)
            previous = rows[-1]
            # Near and far local minima are well separated in arclength in these
            # intervals. Crossing .2 alone is only a candidate until a tie is verified.
            if (previous['winner']['s']<.2)!=(row['winner']['s']<.2):
                switches.append((previous,row,copy_state(snapshots[previous['time']])))
            rows.append(row)
            snapshots={t:copy_state(state)}
        refined=[]
        for left, right, left_state in switches:
            initial_near=left['winner']['s']<.2
            initial_bracket=[left['time'],right['time']]
            while right['time']-left['time']>2e-9:
                middle=(left['time']+right['time'])/2
                middle_state=solver.step(left['time'],copy_state(left_state),middle-left['time'])
                row=line_row(middle_state,middle,tight=True)
                if (row['winner']['s']<.2)==initial_near:
                    left,left_state=row,middle_state
                else:right=row
            # Tight evaluation on both sides also verifies the line-integration result.
            left=line_row(left_state,left['time'],tight=True)
            closest_pair = sorted(left['minima'],key=lambda m:m['d'])[:2]
            assert len(closest_pair)==2
            arc_separation=abs(closest_pair[0]['s']-closest_pair[1]['s'])
            assert arc_separation>.1
            refined.append(dict(bracket=[left['time'],right['time']],left=left,right=right,
                initial_bracket=initial_bracket, competing_arc_separation=arc_separation,
                competition_distance_gap=abs(closest_pair[0]['d']-closest_pair[1]['d'])))
            print(json.dumps(dict(level=level, bracket=refined[-1]['bracket'],
                arcs=[left['winner']['s'],right['winner']['s']], distance=left['winner']['d'])),flush=True)
        original=read_npz(folder/f'state-{last:04d}.npz')
        # At t=1.2 the archived endpoint is after a write. Its velocity/positions
        # are unchanged by that write; compare these fields only.
        endpoint_difference={k:float(np.max(abs(state[k]-original[k]))) for k in ('observer_X','X','F')}
        endpoint_difference['velocity']=float(np.max(abs(state['g'][..., :3]-original['g'][..., :3])))
        payload['intervals'].append(dict(start=start,end=end,rows=rows,switches=refined,
                                         endpoint_difference_from_native=endpoint_difference))
    # Evaluate the old switch instant directly from the threshold-1 t=1.178 state.
    state=read_npz(folder/'state-0589.npz')
    old=1.1782848043
    n=int(np.ceil((old-1.178)/(DT/level)))
    for a,b in zip(np.linspace(1.178,old,n+1)[:-1],np.linspace(1.178,old,n+1)[1:]):
        state=solver.step(float(a),state,float(b-a))
    payload['old_switch_in_new_run']=line_row(state,old,tight=True)
    write_json(folder/f'refinement-{level}.json',payload)
    print('REFINEMENT COMPLETE '+str(level),flush=True)


if __name__=='__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('substeps',type=int,choices=[32,64,128])
    refine(parser.parse_args().substeps)
