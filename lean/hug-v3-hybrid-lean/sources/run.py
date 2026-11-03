"""Only this gated entry point runs declared coupled fixtures."""
from pathlib import Path
import json,sys,time,hashlib
ROOT=Path(__file__).resolve().parent

def run_case(name):
    from preflight import approve
    declaration=approve(name)
    import numpy as np
    from structural_hug import Solver,Config,strain_magnitude
    c=Config(**declaration['config']);so=Solver(c);s=so.initial()
    events=declaration['events'];starts={};audit=[];history=[];snapshots=[];t=0.
    checkpoints=sorted(set([0.,c.end]+[e[k] for e in events for k in ['start','end']]))
    def save(t):
        _,st,details=so.rhs(t,s,True)
        records=so.read_material(s)
        st.update(write_work=float(s['write_work']),record_count=len(records),
                  response_means=s['responses'].sum((0,1)).tolist(),
                  min_well_margin=float(np.abs(s['b']).min()/c.rest_amplitude),
                  material_decoded_event_ids=[r['event_id'] for _,r in records],
                  source_balance=float(s['g'][...,3].mean()-s['ledger'][0]))
        history.append(st)
        snapshots.append(dict(t=t,X=s['X'].copy(),F=s['F'].copy(),C=s['g'][...,3].copy(),
                              relation=s['relation'].copy(),responses=s['responses'].copy(),
                              b_mean=np.bincount(so.fabric.point,weights=s['b']*so.fabric.local_weight,minlength=so.P),
                              decoded_ids=st['material_decoded_event_ids'],memory=so.retrieve(t,s)[0].copy()))
    start=time.time();save(0);E0=history[0]['energy'];steps=0
    for left,right in zip(checkpoints[:-1],checkpoints[1:]):
        for event in events:
            if abs(event['start']-left)<1e-12:starts[event['event_id']]=s['F'].copy()
        count=int(np.ceil((right-left)/c.dt));dt=(right-left)/count
        for j in range(count):
            t=left+j*dt;s=so.step(t,s,dt);steps+=1
            if not all(np.isfinite(v).all() for v in s.values()):raise FloatingPointError('nonfinite joint state')
            if j%max(1,count//10)==0:save(t+dt)
        t=right
        for event in events:
            if abs(event['end']-right)<1e-12:
                record=so.make_event(s,starts.pop(event['event_id']),event)
                before=s;s,work=so.write_event(s,record)
                decoded=next(r for _,r in so.read_material(s) if r['event_id']==event['event_id'])
                err=float(np.max(np.abs(decoded['delta_E']-record['delta_E'])))
                audit.append(dict(event_id=event['event_id'],origin=event['origin'],recipient=event['recipient'],
                                  start=event['start'],end=event['end'],predecessors=decoded['predecessors'],
                                  observed=event['observed'],recipient_report=event['recipient_report'],
                                  material_error=err,work=work))
        save(t)
    for row in history:row['energy_balance']=row['energy']-E0-row['source_work']-row['write_work']
    result=dict(case=name,config=declaration['config'],steps=steps,seconds=time.time()-start,
                history=history,event_audit=audit,gate_manifest_sha256=declaration['manifest_sha256'],
                final=dict(energy_error=max(abs(r['energy_balance']) for r in history),
                           source_error=max(abs(r['source_balance']) for r in history),
                           det_error=max(r['det_error'] for r in history),
                           deformation=history[-1]['deformation'],speed=history[-1]['speed_rms'],
                           min_well_margin=min(r['min_well_margin'] for r in history),
                           decoded_events=history[-1]['material_decoded_event_ids'],
                           decoded_strain_error=max(r['material_error'] for r in audit),
                           structural_change=float(np.linalg.norm(s['b']-so.fabric.initial()))))
    out=ROOT/'results';out.mkdir(exist_ok=True)
    (out/(name+'.json')).write_text(json.dumps(result,indent=2,allow_nan=False)+'\n')
    # Material-only checkpoint: no episodes, no event IDs, no outcome arrays.
    np.savez_compressed(out/(name+'_body.npz'),F=s['F'],b=s['b'],X=s['X'],reference_X=so.X0,V=so.V)
    np.savez_compressed(out/(name+'_state.npz'),**s)
    # Visualization arrays never become solver inputs.
    np.savez_compressed(out/(name+'_display.npz'),**{k:np.asarray([r[k] for r in snapshots]) for k in snapshots[0] if k!='decoded_ids'},
                        counts=[len(r['decoded_ids']) for r in snapshots])
    print(json.dumps(dict(case=name,seconds=result['seconds'],final=result['final'])),flush=True)
    return result

if __name__=='__main__':run_case(sys.argv[1] if len(sys.argv)>1 else 'main')
