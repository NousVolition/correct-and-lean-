"""Recover missing force samples by replaying the unchanged saved experiment.
Validate every saved velocity stage and full checkpoint; write only this task's work.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','MKL_NUM_THREADS'): os.environ[key]='1'
import sys, json, csv, hashlib, time
from pathlib import Path
from datetime import datetime, timezone
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'work/unwrapped-history'
OUT=ROOT/'outputs/unwrapped-carrying-history'
OUT.mkdir(parents=True,exist_ok=True)
INPUT=Path(r'$USER_HOME\Documents\Codex\2026-11-11\new-chat-13\tick41-readonly-check\inputs')
SAVED=Path(r'$USER_HOME\Documents\Codex\2026-11-10\lo\work\threshold-one\threshold-1')
RUNTIME=Path(r'$USER_HOME\Documents\Codex\2026-10-28\new-chat-4\hug-v3-coexistence-lean\.runtime')
sys.path[:0]=[str(RUNTIME),str(INPUT/'declared-source'),str(INPUT/'study')]
import numpy as np
import scipy
import preflight
from breathing import ComparisonSolver, Trail
from structural_hug import Config
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def load(p):
    with np.load(p,allow_pickle=False) as z:return {k:z[k].copy() for k in z.files}
def force_x(s,c):
    C=s['g'][...,3]
    grad=np.stack([(np.roll(C,-1,axis=j)-np.roll(C,1,axis=j))*(c.n/2) for j in range(3)],-1)
    q=np.sqrt(np.sum(grad*grad,-1)+c.delta*c.delta)-np.sqrt(c.threshold*c.threshold+c.delta*c.delta)
    assert c.branch=='smooth'
    a=np.zeros_like(q);on=q>0;a[on]=q[on]*np.exp(-(c.epsilon/q[on])**2)
    return -c.sigma*a
def main():
    start=time.monotonic()
    case=preflight.approve('threshold_1')
    with (INPUT/'study/marker-seeds.csv').open() as f:trail=Trail(list(csv.DictReader(f)))
    solver=ComparisonSolver(Config(**case['config']),.5,.6,trail)
    solver.initial()
    config=json.loads((SAVED/'configuration.json').read_text())
    assert config['effective_config']==case['config'] and config['actual_step']==.002
    paths=list((INPUT/'declared-source').rglob('*.py'))+[INPUT/'study/breathing.py',INPUT/'study/marker-seeds.csv',INPUT/'declared-source/source_seal.json',INPUT/'declared-source/protocol.json',INPUT/'declared-source/declarations/threshold_1.json',SAVED/'configuration.json',SAVED/'fields.npz',SAVED/'particle-readings.json']+sorted(SAVED.glob('state-*.npz'))
    hashes={str(p):sha(p) for p in paths}
    checkpoint_ids={int(p.stem.split('-')[1]):p for p in SAVED.glob('state-*.npz')}
    with np.load(SAVED/'fields.npz',allow_pickle=False) as z:
        velocity=z['velocity'];stages=z['stages'];tagpoints=z['points'];times=z['times']
    assert velocity.shape==(601,11,11,11,3) and stages.shape==(600,2,11,11,11,3)
    readings=json.loads((SAVED/'particle-readings.json').read_text())
    assert len(readings)==601
    s=load(checkpoint_ids[0]);dt=.002
    freq=np.arange(-5,6);idx=freq%16
    coef=lambda a:solver.hat(a)[np.ix_(idx,idx,idx)]/16**3
    force_stages=np.empty((600,2,11,11,11),complex)
    rate_rows=[];checkpoints=[];max_stage_error=0.;max_ledger_error=0.;max_tag_error=0.
    native=solver.rhs
    call_id=0
    def capture(t,state,details=False):
        nonlocal call_id,max_stage_error
        assert not details
        step,stage=divmod(call_id,2)
        err=float(np.max(abs(coef(state['g'][...,:3])-stages[step,stage])))
        max_stage_error=max(max_stage_error,err)
        assert err<2e-12,(step,stage,err)
        fx=force_x(state,solver.c)
        force_stages[step,stage]=coef(fx)
        rates=native(t,state)
        u=state['g'][...,:3];ub=u.mean(axis=(0,1,2));fb=float(fx.mean())
        power=float(np.mean(fx*u[...,0]));meanpower=float(fb*ub[0])
        assert abs(power-float(rates['ledger'][1]))<1e-16
        acceleration=rates['g'][...,:3].mean(axis=(0,1,2))
        meanforce_error=float(np.max(abs(acceleration-np.array([fb,0,0]))))
        assert meanforce_error<1e-13
        rate_rows.append(dict(step=step,stage=stage,time=t,AS_power=power,mean_power=meanpower,fluctuation_power=power-meanpower,mean_force=fb,mean_velocity=ub[0],mean_force_identity_error=meanforce_error))
        call_id+=1
        return rates
    solver.rhs=capture
    events={round(e['end']/dt):e for e in case['events']}
    starts={e['event_id']:s['F'].copy() for e in case['events'] if e['start']==0}
    writes=[]
    for frame in range(1,601):
        s=solver.step((frame-1)*dt,s,dt)
        pair=s['observer_X'][-2:].copy()
        points,births=trail.refine(s['observer_X'][:-2],frame*dt)
        assert not births, 'Unexpected marker insertion relative to saved run'
        s['observer_X']=np.vstack([points,pair])
        if frame in events:
            event=events[frame]
            record=solver.make_event(s,starts.pop(event['event_id']),event)
            s,account=solver.write_event(s,record)
            writes.append(dict(frame=frame,event=event['event_id'],work=float(account['work'])))
        for event in case['events']:
            if round(event['start']/dt)==frame:starts[event['event_id']]=s['F'].copy()
        max_ledger_error=max(max_ledger_error,abs(float(s['ledger'][1])-readings[frame]['threshold_force_work']))
        max_tag_error=max(max_tag_error,float(np.max(abs(s['observer_X'][-2:]-tagpoints[frame]))))
        assert max_ledger_error<2e-12 and max_tag_error<2e-12
        if frame in checkpoint_ids:
            ref=load(checkpoint_ids[frame]);assert set(ref)==set(s)
            errors={k:float(np.max(abs(s[k]-v))) for k,v in ref.items()}
            assert max(errors.values())<2e-11,(frame,errors)
            checkpoints.append(dict(frame=frame,max_error=max(errors.values()),blocks=len(errors)))
        if frame%50==0:
            status=dict(frame=frame,total=600,elapsed_seconds=round(time.monotonic()-start,2),max_stage_error=max_stage_error,max_checkpoint_error=max(x['max_error'] for x in checkpoints))
            (WORK/'replay-progress.json').write_text(json.dumps(status)+'\n')
            print(json.dumps(status),flush=True)
    np.savez_compressed(WORK/'force-history.npz',stages=force_stages,final=coef(force_x(s,solver.c)))
    with (OUT/'stage-work.csv').open('w',newline='') as f:
        writer=csv.DictWriter(f,fieldnames=list(rate_rows[0]));writer.writeheader();writer.writerows(rate_rows)
    assert all(sha(Path(p))==h for p,h in hashes.items())
    report=dict(checked_utc=datetime.now(timezone.utc).isoformat(),steps=600,stage_samples=call_id,full_checkpoints_compared=len(checkpoints),checkpoint_comparisons=checkpoints,initial_checkpoint_loaded=0,max_velocity_stage_error=max_stage_error,max_ledger_error=max_ledger_error,max_tagged_pair_error=max_tag_error,writes=writes,all_sources_and_saved_inputs_unchanged=True,input_sha256=hashes,numpy=np.__version__,scipy=scipy.__version__,elapsed_seconds=time.monotonic()-start)
    (OUT/'replay-verification.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({k:v for k,v in report.items() if k not in ('input_sha256','checkpoint_comparisons')},indent=2),flush=True)
if __name__=='__main__':main()
