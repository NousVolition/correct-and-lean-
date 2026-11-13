"""Additional passive diagnostics on the unchanged, checkpoint-matched replay."""
import os,sys,json,csv,hashlib,time,importlib.util
from pathlib import Path
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','MKL_NUM_THREADS'):os.environ[key]='1'
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[2];WORK=Path(__file__).resolve().parent
OUT=ROOT/'outputs/full-carrying-energy';OUT.mkdir(parents=True,exist_ok=True)
spec=importlib.util.spec_from_file_location('replay',ROOT/'work/unwrapped-history/replay.py')
old=importlib.util.module_from_spec(spec);spec.loader.exec_module(old)
np=old.np
from breathing import ComparisonSolver,Trail
from structural_hug import Config

def grad_fd(C,dx):return np.stack([(np.roll(C,-1,axis=j)-np.roll(C,1,axis=j))/(2*dx) for j in range(3)],-1)
def diagnostic(solver,t,s,rates,stats,extra):
    c=solver.c;C=s['g'][...,3];u=s['g'][...,:3];g=grad_fd(C,solver.dx)
    mag=np.sqrt((g*g).sum(-1)+c.delta**2)
    q=mag-np.sqrt(c.threshold**2+c.delta**2);slope=np.zeros_like(q);on=q>0
    slope[on]=np.exp(-(c.epsilon/q[on])**2)*(1+2*(c.epsilon/q[on])**2)
    diffusion=c.diffusion*sum((np.roll(C,-1,axis=j)-2*C+np.roll(C,1,axis=j))/solver.dx**2 for j in range(3))
    source=c.kappa*float(s['A'])*extra['kernel']+extra['pairgrid']
    adv=solver.context_transport(C,u)-diffusion
    assert abs(rates['g'][...,3]-adv-diffusion-source).max()<1e-12
    # B = sigma * resolved activation = -resolved force_x.
    h=c.sigma*slope/mag
    partial_parts=np.stack([h*np.sum(g*grad_fd(v,solver.dx),-1) for v in (adv,diffusion,source)],-1)
    Lu=solver.grad(u)
    strain=-h*np.einsum('...i,...ji,...j->...',g,Lu,g)
    # This strain term is the continuum-inspired part. The remainder below
    # explicitly retains filtering, discrete product rules and transport.
    fields=np.concatenate([partial_parts,strain[...,None]],-1)
    idx=np.arange(-5,6)%c.n
    coef=solver.hat(fields)[np.ix_(idx,idx,idx)]/c.n**3
    tau_work=float(np.sum(solver.V[:,None,None]*extra['tau']*extra['L']))
    _,_,Y,_,_=solver.material(s['F'],s['m'],extra['L'])
    write=float(np.sum(solver.V[:,None,None]*Y*rates['m']))
    release=stats['release_power']
    stored_rate=tau_work+write-release
    kinetic_rate=float(np.mean(np.sum(u*rates['g'][...,:3],-1)))
    heat_rate=float(rates['g'][...,4].mean())
    AS=float(rates['ledger'][1]);breath=float(rates['breathing_work'])
    row=dict(time=t,AS=AS,breathing=breath,stress_to_store=tau_work,write_from_heat=write,
        release_to_heat=release,stored_rate=stored_rate,kinetic_rate=kinetic_rate,heat_rate=heat_rate,
        full_budget_residual=kinetic_rate+stored_rate+heat_rate-AS-breath,
        stress_adjoint_residual=stats['elastic_power_residual'],write_residual=stats['write_power_residual'])
    return coef,row

def main():
    started=time.monotonic();case=old.preflight.approve('threshold_1')
    with (old.INPUT/'study/marker-seeds.csv').open() as f:trail=Trail(list(csv.DictReader(f)))
    solver=ComparisonSolver(Config(**case['config']),.5,.6,trail);solver.initial()
    prior=json.loads((ROOT/'outputs/unwrapped-carrying-history/replay-verification.json').read_text())
    assert all(old.sha(Path(p))==h for p,h in prior['input_sha256'].items())
    with np.load(old.SAVED/'fields.npz') as z:velocity_stages=z['stages']
    with np.load(ROOT/'work/unwrapped-history/force-history.npz') as z:force_stages=z['stages']
    s=old.load(old.SAVED/'state-0000.npz');dt=.002
    idx=np.arange(-5,6)%solver.n
    coef=lambda a:solver.hat(a)[np.ix_(idx,idx,idx)]/solver.n**3
    stages=np.empty((600,2,11,11,11,4),complex);rows=[];call=0
    max_u=max_force=max_checkpoint=0.;checks=[]
    native=solver.rhs
    def capture(t,state,details=False):
        nonlocal call,max_u,max_force
        assert not details
        step,stage=divmod(call,2)
        max_u=max(max_u,float(abs(coef(state['g'][...,:3])-velocity_stages[step,stage]).max()))
        max_force=max(max_force,float(abs(coef(old.force_x(state,solver.c))-force_stages[step,stage]).max()))
        rates,stats,extra=native(t,state,details=True)
        stages[step,stage],row=diagnostic(solver,t,state,rates,stats,extra)
        row.update(step=step,stage=stage);rows.append(row);call+=1
        return rates
    solver.rhs=capture
    events={round(e['end']/dt):e for e in case['events']}
    starts={e['event_id']:s['F'].copy() for e in case['events'] if e['start']==0}
    checkpoints={int(p.stem.split('-')[1]):p for p in old.SAVED.glob('state-*.npz')}
    for frame in range(1,601):
        s=solver.step((frame-1)*dt,s,dt)
        pair=s['observer_X'][-2:].copy();points,births=trail.refine(s['observer_X'][:-2],frame*dt)
        assert not births;s['observer_X']=np.vstack([points,pair])
        if frame in events:
            event=events[frame];record=solver.make_event(s,starts.pop(event['event_id']),event)
            s,account=solver.write_event(s,record)
        for event in case['events']:
            if round(event['start']/dt)==frame:starts[event['event_id']]=s['F'].copy()
        if frame in checkpoints:
            ref=old.load(checkpoints[frame]);assert set(s)==set(ref)
            err=max(float(abs(s[k]-v).max()) for k,v in ref.items());max_checkpoint=max(max_checkpoint,err)
            assert err<2e-11;checks.append(dict(frame=frame,max_error=err))
        if frame%100==0:print(json.dumps(dict(frame=frame,elapsed=time.monotonic()-started,max_checkpoint=max_checkpoint)),flush=True)
    # Independent directional finite difference of the native force map at
    # the final state, to verify the analytic activation derivative.
    rates,stats,extra=native(1.2,s,details=True)
    final_parts,_=diagnostic(solver,1.2,s,rates,stats,extra)
    exact=final_parts[...,:3].sum(-1);fd_checks=[]
    for eps in (1e-4,1e-5,1e-6):
        plus={**s,'g':s['g'].copy()};minus={**s,'g':s['g'].copy()}
        plus['g'][...,3]+=eps*rates['g'][...,3];minus['g'][...,3]-=eps*rates['g'][...,3]
        fd=-coef(old.force_x(plus,solver.c)-old.force_x(minus,solver.c))/(2*eps)
        fd_checks.append(dict(epsilon=eps,max_error=float(abs(fd-exact).max()),relative_max_error=float(abs(fd-exact).max()/abs(exact).max())))
    assert max_u<2e-12 and max_force<2e-12 and fd_checks[1]['relative_max_error']<1e-7
    assert max(abs(r['full_budget_residual']) for r in rows)<1e-12
    np.savez_compressed(WORK/'activation-stage-parts.npz',parts=stages,final=final_parts)
    with (OUT/'native-transfer-rates.csv').open('w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
    result=dict(checked_utc=old.datetime.now(old.timezone.utc).isoformat(),stage_count=call,
        checkpoint_count=len(checks),max_velocity_stage_error=max_u,max_force_stage_error=max_force,
        max_full_checkpoint_error=max_checkpoint,checkpoints=checks,activation_derivative_checks=fd_checks,
        max_native_energy_rate_defect=max(abs(r['full_budget_residual']) for r in rows),
        integrated_rates={k:.5*dt*sum(r[k] for r in rows) for k in rows[0] if k not in ('time','step','stage')},
        sources_and_saved_data_unchanged=all(old.sha(Path(p))==h for p,h in prior['input_sha256'].items()),
        input_sha256=prior['input_sha256'],script_sha256=old.sha(Path(__file__)),elapsed_seconds=time.monotonic()-started)
    assert result['sources_and_saved_data_unchanged']
    (OUT/'stage-verification.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k not in ('input_sha256','checkpoints')},indent=2),flush=True)
if __name__=='__main__':main()
