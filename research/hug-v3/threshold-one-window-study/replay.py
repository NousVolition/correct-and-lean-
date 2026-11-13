"""Recreate local event-side states using the preserved solver and declarations.

No original archive is written. This is local refinement of a saved 0.002
history, not full-history refinement. Run with Python, NumPy and SciPy.
"""
import csv, hashlib, json, sys
from pathlib import Path
import numpy as np
from scipy.fft import fftn

HERE=Path(__file__).resolve().parent
sys.dont_write_bytecode=True
sys.path[:0]=[str(HERE/'sources/declared'),str(HERE/'sources')]
import preflight
from breathing import ComparisonSolver, Config, Trail

FREQ=np.arange(-5,6)
WN=2j*np.pi*np.stack(np.meshgrid(FREQ,FREQ,FREQ,indexing='ij'),-1)
def coefficients(u):
    return fftn(u,axes=(0,1,2))[np.ix_(FREQ%16,FREQ%16,FREQ%16)]/16**3
def read_state(frame):
    with np.load(HERE/f'saved/state-{frame:04d}.npz') as z: return dict(z)
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def verify_inputs():
    manifest=json.loads((HERE/'source-manifest.json').read_text())
    for name,row in manifest.items(): assert sha(HERE/name)==row['sha256'],name
    return len(manifest)
def main():
    count=verify_inputs()
    case=preflight.approve('threshold_1')
    config=json.loads((HERE/'saved/Configuration.json').read_text())
    assert case['config']==config['effective_config']
    assert case['events']==config['base_case']['events']
    assert config['actual_step']==.002 and config['comparison']['peak']==.5
    with (HERE/'sources/marker-seeds.csv').open(newline='') as f:
        trail=Trail(list(csv.DictReader(f)))
    solver=ComparisonSolver(Config(**case['config']),.5,.6,trail)
    solver.initial()
    old=json.loads((HERE/'saved/refinement-64.json').read_text())
    samples=[]; omegas=[]; pairs=[]; comparisons=[]
    def capture(label,stamp,state,reference=None):
        pair=state['observer_X'][-2:]
        row={'label':label,'time':stamp,'index':len(samples)}
        if reference:
            error=float(np.max(abs(pair-np.array([reference['A'],reference['B']]))))
            assert error<2e-14,(label,error)
            row['saved_pair_max_abs_error']=error
            row['saved_winner']=reference['winner']
            row['saved_minima']=reference['minima']
        samples.append(row)
        omegas.append(np.cross(WN,coefficients(state['g'][...,:3])))
        pairs.append(pair.copy())
    event_id=0
    for interval,first,last in zip(old['intervals'],(589,599),(592,600),strict=True):
        start=first*.002
        state=read_state(first)
        snapshots={start:state}
        capture(f'native-{first}',start,state)
        for k in range(1,(last-first)*64+1):
            t=start+k*(.002/64)
            state=solver.step(start+(k-1)*(.002/64),state,.002/64)
            snapshots[t]=state
            if k%8==0: capture(f'interval-{first}-{k:03d}',t,state)
        endpoint=read_state(last)
        errors={k:float(np.max(abs(state[k]-endpoint[k]))) for k in ('observer_X','X','F')}
        errors['velocity']=float(np.max(abs(state['g'][...,:3]-endpoint['g'][...,:3])))
        comparisons.append({'interval':[start,last*.002],'endpoint_difference_from_native':errors,
                            'saved_endpoint_difference':interval['endpoint_difference_from_native']})
        for event in interval['switches']:
            event_id+=1
            lo,hi=event['initial_bracket']
            left_state=snapshots[lo]
            right_state=snapshots[hi]
            target=event['bracket'][0]
            while hi-lo>2e-9:
                mid=(lo+hi)/2
                mid_state=solver.step(lo,left_state,mid-lo)
                # Follow the archived bisection choices; remeasurement separately
                # checks that these still straddle the same forward exchange.
                if mid<=target: lo,left_state=mid,mid_state
                else: hi,right_state=mid,mid_state
            assert [lo,hi]==event['bracket']
            capture(f'event-{event_id}-left',lo,left_state,event['left'])
            capture(f'event-{event_id}-right',hi,right_state,event['right'])
            print(json.dumps({'event':event_id,'bracket':[lo,hi]}),flush=True)
    np.savez_compressed(HERE/'snapshots.npz',omega=np.array(omegas),pairs=np.array(pairs))
    (HERE/'snapshots.json').write_text(json.dumps(samples,indent=2)+'\n')
    result={'input_files_verified':count,'source_inputs_unchanged':verify_inputs()==count,
            'level':64,'samples':len(samples),'events':event_id,'endpoints':comparisons,
            'max_saved_pair_error':max(r.get('saved_pair_max_abs_error',0) for r in samples),
            'scope':'New local replay from archived states; original full history and physical parameters retained.'}
    (HERE/'replay-checks.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result),flush=True)
if __name__=='__main__':main()
