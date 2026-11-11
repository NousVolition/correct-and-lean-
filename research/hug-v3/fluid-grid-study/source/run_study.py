"""Full-history fluid/time refinements of the sealed threshold-.015 Hug study.

Original solver modules are imported read-only. Each refinement has an explicit
configuration extension, while every original solver equation remains unchanged.
"""
import os
os.environ.setdefault('OPENBLAS_NUM_THREADS','1')
os.environ.setdefault('OMP_NUM_THREADS','1')
import sys
sys.dont_write_bytecode=True
import argparse, csv, hashlib, json, time
from pathlib import Path
from unittest.mock import patch
import numpy as np
from scipy.fft import fftn, ifftn
from scipy import ndimage

HERE=Path(__file__).resolve().parent
ROOT=HERE.parent.parent
OUT=ROOT/'outputs/fluid-convergence'
OUT.mkdir(parents=True,exist_ok=True)
SOURCE=Path('external-archives/hug-v3-breathing-setup')
ARCHIVE=Path('external-archives/vortex-lines')
sys.path[:0]=[str(SOURCE),str(SOURCE/'upstream')]
from study import approved_arm
from breathing import ComparisonSolver,Config,Trail,fluid_velocity
import breathing as breathing_module
import preflight

def dump(path,value):
    path.write_text(json.dumps(value,indent=2,allow_nan=False),encoding='utf-8')

def readcsv(path):
    with path.open(encoding='utf-8',newline='') as f:return list(csv.DictReader(f))

def coeff(g,n):
    f=np.arange(-((n-1)//3),(n-1)//3+1)
    return f,fftn(g,axes=(0,1,2))[np.ix_(f%n,f%n,f%n)]/n**3

def at(h,f,p):
    p=np.asarray(p)
    phase=np.exp(2j*np.pi*((p.reshape(-1,3)+.5)%1)[:,:,None]*f)
    v=np.tensordot(phase[:,0],h,axes=(1,0))
    v=np.einsum('pj,pjkc->pkc',phase[:,1],v)
    return np.einsum('pk,pkc->pc',phase[:,2],v).real.reshape(p.shape)

def on_grid(h,f,n):
    shape=(n,n,n)+h.shape[3:]
    pad=np.zeros(shape,complex)
    pad[np.ix_(f%n,f%n,f%n)]=h*n**3
    return ifftn(pad,axes=(0,1,2)).real

def cubic(h,f,n):
    response=(2+np.cos(2*np.pi*f/n))/3
    weights=response[:,None,None]*response[None,:,None]*response[None,None,:]
    grid=np.ascontiguousarray(np.moveaxis(on_grid(h/weights[...,None],f,n),-1,0))
    def evaluate(points):
        p=np.asarray(points)
        xyz=((p.reshape(-1,3)+.5)*n).T
        return np.stack([ndimage.map_coordinates(c,xyz,order=3,mode='grid-wrap',prefilter=False) for c in grid],axis=1).reshape(p.shape)
    return evaluate

def curl(h,f):
    k=2j*np.pi*np.stack(np.meshgrid(f,f,f,indexing='ij'),-1)
    return np.cross(k,h)

def trace(evaluate,seeds,ds,length):
    count=round(length/abs(ds));assert abs(count*abs(ds)-length)<1e-13
    path=np.empty((count+1,len(seeds),3));path[0]=seeds
    minimum=np.inf
    def direction(p):
        nonlocal minimum
        v=evaluate(p);norm=np.linalg.norm(v,axis=1)
        minimum=min(minimum,float(norm.min()))
        if norm.min()<1e-8:raise FloatingPointError('Near-null vortex direction')
        return v/norm[:,None]
    for j in range(count):
        p=path[j];a=direction(p);b=direction(p+ds*a/2)
        c=direction(p+ds*b/2);d=direction(p+ds*c)
        path[j+1]=p+ds/6*(a+2*b+2*c+d)
    return path,minimum

def nearest(path,target):
    a=path[:-1]-target;a-=np.rint(a)
    d=np.diff(path,axis=0);q=np.clip(-np.sum(a*d,axis=2)/np.sum(d*d,axis=2),0,1)
    delta=a+q[:,:,None]*d;mag=np.linalg.norm(delta,axis=2);idx=mag.argmin(axis=0)
    seeds=np.arange(len(target))
    return mag[idx,seeds],idx+q[idx,seeds]

def heun(p,h,f,dt):
    a=at(h[0],f,p);b=at(h[1],f,p+dt*a)
    return p+dt/2*(a+b)

def original_observers():
    rows=[r for r in readcsv(ARCHIVE/'10-direct-partners.csv') if r['prime_tick']=='37']
    points=[np.array([[float(r[tag+'_'+axis]) for axis in 'xyz'] for r in rows]) for tag in ['A','B']]
    with np.load(ARCHIVE/'10-fine/lines.npz') as z:points.append(z['central_seeds'][0])
    return np.vstack(points)

def make_solver(n):
    case,extra=approved_arm('breathing_on')
    cfg=dict(case['config']);cfg['n']=n
    # The original approved baseline remains intact. This explicit numerical
    # extension is the sole runtime parameter permission; no guard is disabled.
    if n!=16:
        extension=dict(case,config=cfg)
        preflight.ACTIVE=('fluid_convergence_n'+str(n),extension,
                          dict(claims_corpus_validation=False,extension='Eulerian n only'))
        # A floating FFT frequency can be 6.999999999999999 on n=24.
        # The original astype(int) would duplicate mode 6 and omit mode 7.
        # Round integer-valued mode labels; do not change the fluid equations.
        def rounded_velocity(solver,grid_velocity,points):
            freq=np.rint(solver.freq[np.abs(solver.freq)<solver.n/3]).astype(int)
            idx=freq%solver.n
            h=solver.hat(grid_velocity)[np.ix_(idx,idx,idx)]/solver.n**3
            return at(h,freq,points)
        breathing_module.fluid_velocity=rounded_velocity
    trail=Trail(readcsv(SOURCE/'marker-seeds.csv'))
    solver=ComparisonSolver(Config(**cfg),extra['peak'],extra['period'],trail)
    return solver,case,extra

def prepare_labels():
    folder=OUT/'n16_dt0p002'
    h=np.load(folder/'full-stages.npy',mmap_mode='r')
    f=np.arange(-5,6);target=original_observers();p=target.copy()
    worst=0.;start=time.monotonic()
    for j in range(549,-1,-1):
        guess=p.copy()
        for attempt in range(12):
            residual=p-heun(guess,h[j],f,.002);guess+=residual
            if np.max(abs(residual))<5e-15:break
        error=float(np.max(abs(p-heun(guess,h[j],f,.002))))
        if error>1e-13:raise RuntimeError('Inverse-map residual exceeded bound')
        worst=max(worst,error);p=guess
        if j%100==0:print('inverse',j,'elapsed',round(time.monotonic()-start,1),flush=True)
    initial=p.copy()
    for j in range(550):p=heun(p,h[j],f,.002)
    error=float(np.max(abs(p-target)))
    assert error<2e-12
    np.savez(OUT/'observer-labels.npz',initial=initial,prime37=target)
    dump(OUT/'observer-labels.json',dict(convention='same baseline material labels at t=0',
        ordering='A[0:25], B[25:50], centers[50:75]',max_inverse_step_residual=worst,
        max_full_forward_roundtrip_error=error,elapsed_seconds=time.monotonic()-start))
    print('labels complete',error,flush=True)

def run(n,dt,baseline=False,max_steps=None):
    tag='n'+str(n)+'_dt'+str(dt).replace('.','p')
    folder=OUT/tag;folder.mkdir(exist_ok=True)
    if (folder/'summary.json').exists():raise FileExistsError('Completed run exists: '+tag)
    solver,case,extra=make_solver(n)
    state=solver.initial()
    if n==16:
        initial_g=state['g'].copy()
        if baseline:np.savez(OUT/'initial-native.npz',g=initial_g,**{k:v for k,v in state.items() if k!='g'})
    else:
        with np.load(OUT/'initial-native.npz') as z:
            f,h=coeff(z['g'],16);state['g']=on_grid(h,f,n)
            for k in z.files:
                if k!='g':np.testing.assert_array_equal(state[k],z[k])
        initial_g=state['g'].copy()
    fixed=None
    if not baseline:
        with np.load(OUT/'observer-labels.npz') as z:fixed=z['initial'].copy()
        state['observer_X']=np.vstack([state['observer_X'],fixed])
    refs={}
    if baseline:
        old=SOURCE/'results/breathing_on'
        refs={(int(r['frame']),r['side']):r for r in map(json.loads,(old/'prime-states.jsonl').read_text(encoding='utf-8').splitlines())}
        marker_refs={}
        for r in readcsv(old/'prime-markers.csv'):
            marker_refs.setdefault((int(r['frame']),r['side']),[]).append([float(r[k]) for k in ['x_unwrapped','y_unwrapped','z_unwrapped']])
    checks=[];diagnostics=[];event_log=[];starts={};stage_capture=[];window=[];moved=[];prime_fields=[]
    f=np.arange(-((n-1)//3),(n-1)//3+1)
    steps=round(1.2/dt);first=round(1.1/dt)
    assert abs(steps*dt-1.2)<1e-13 and abs(first*dt-1.1)<1e-13
    ends={round(e['end']/dt):e for e in case['events']}
    for e in case['events']:
        assert abs(round(e['start']/dt)*dt-e['start'])<1e-13
        assert abs(round(e['end']/dt)*dt-e['end'])<1e-13
    native=solver.rhs
    full=np.lib.format.open_memmap(folder/'full-stages.npy',mode='w+',dtype=np.complex128,
                shape=(steps,2,len(f),len(f),len(f),3)) if baseline else None
    def capture(t,s,details=False):
        if baseline and not details:stage_capture.append(coeff(s['g'][...,:3],n)[1])
        return native(t,s,details)
    def verify(i,side):
        if baseline and (i,side) in refs:
            r=refs[i,side]
            with np.load(old/r['snapshot']) as z:
                for k in z.files:np.testing.assert_array_equal(state[k],z[k])
            np.testing.assert_array_equal(state['observer_X'][:801],np.asarray(marker_refs[i,side]))
            checks.append(dict(frame=i,side=side,exact=True,state_arrays=len(z.files),marker_count=801))
    energy0=None;time0=time.monotonic();external_baseline=None
    with patch.object(solver,'rhs',capture):
        for i in range(steps+1):
            t=i*dt
            if i:
                stage_capture.clear()
                state=solver.step((i-1)*dt,state,dt)
                if baseline:
                    assert len(stage_capture)==2;full[i-1]=stage_capture
                    if external_baseline is not None:
                        external_baseline=heun(external_baseline,stage_capture,f,dt)
                if not all(np.isfinite(v).all() for v in state.values()):raise FloatingPointError('nonfinite at '+str(t))
                # Original observers did not refine in the archive. Check their
                # declared birth rule independently of the additional labels.
                original,births=solver.trail.refine(state['observer_X'][:801],t)
                if births:raise RuntimeError('New native trail births require separate accounting')
            common=abs(t/.002-round(t/.002))<1e-9
            prime=abs(t/.1-round(t/.1))<1e-9
            if i==first:
                if baseline:
                    selected=original_observers()
                    # Keep the original 801-observer arithmetic shape untouched
                    # for exact replay; added labels are strictly passive.
                    external_baseline=np.vstack([selected,selected[:50]])
                else:
                    wf=curl(coeff(state['g'][...,:3],n)[1],f)
                    evalw=cubic(wf,f,128)
                    centers=state['observer_X'][851:876]
                    a,_=trace(evalw,centers,-1/1024,.09375)
                    b,_=trace(evalw,centers,1/1024,.09375)
                    state['observer_X']=np.vstack([state['observer_X'],a[-1],b[-1]])
            if i>=first and common:
                window.append(coeff(state['g'][...,:3],n)[1])
                moved.append((external_baseline if baseline else state['observer_X'][801:]).copy())
            if prime:
                side='before_write' if i in ends else 'at'
                verify(i,side)
                _,stats,_=native(t,state,details=True)
                if energy0 is None:energy0=stats['energy']
                stats.update(side=side,breathing_work=float(state['breathing_work']),write_work=float(state['write_work']),
                     energy_balance=float(stats['energy']-energy0-state['ledger'][1]-state['breathing_work']-state['write_work']))
                diagnostics.append(stats)
                prime_fields.append(state['g'].copy())
                print(tag,'time',round(t,3),'elapsed',round(time.monotonic()-time0,1),'energy defect',stats['energy_balance'],flush=True)
            if i in ends:
                event=ends[i];record=solver.make_event(state,starts.pop(event['event_id']),event)
                before=state['g'][...,:3].copy();state,account=solver.write_event(state,record)
                np.testing.assert_array_equal(before,state['g'][...,:3])
                event_log.append(dict(time=t,event_id=event['event_id'],**account))
                verify(i,'after_write')
                _,stats,_=native(t,state,details=True)
                stats.update(side='after_write',breathing_work=float(state['breathing_work']),write_work=float(state['write_work']),
                    energy_balance=float(stats['energy']-energy0-state['ledger'][1]-state['breathing_work']-state['write_work']))
                diagnostics.append(stats)
            for e in case['events']:
                if round(e['start']/dt)==i:starts[e['event_id']]=state['F'].copy()
            if max_steps is not None and i>=max_steps:break
    elapsed=time.monotonic()-time0
    if full is not None:full.flush()
    np.savez_compressed(folder/'window.npz',freq=f,velocity=np.asarray(window),observers=np.asarray(moved),times=np.arange(550,601)*.002)
    np.savez_compressed(folder/'prime-fields.npz',g=np.asarray(prime_fields),initial=initial_g)
    np.savez_compressed(folder/'final-state.npz',**state)
    dump(folder/'diagnostics.json',diagnostics);dump(folder/'events.json',event_log)
    dump(folder/'baseline-checks.json',checks)
    summary=dict(n=n,dt=dt,full_history=i==steps,steps=i,elapsed_seconds=elapsed,config=vars(solver.c),
        initial_condition='same archived 16-grid Fourier polynomial for heat; all other initial arrays identical',
        source_manifest=case['manifest_sha256'],comparison_manifest=extra['manifest_sha256'],events=event_log,
        passive_frequency_conversion='original' if n==16 else 'round to integer before indexing; fixes n24 float truncation',
        baseline_exact_check_count=len(checks),max_abs_energy_balance=max(abs(v['energy_balance']) for v in diagnostics))
    dump(folder/('summary.json' if max_steps is None else 'benchmark.json'),summary)
    print('COMPLETE',tag,round(elapsed,1),flush=True)

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('action',choices=['run','labels'])
    p.add_argument('--n',type=int,default=16);p.add_argument('--dt',type=float,default=.002)
    p.add_argument('--baseline',action='store_true');p.add_argument('--max-steps',type=int)
    a=p.parse_args()
    if a.action=='labels':prepare_labels()
    else:run(a.n,a.dt,a.baseline,a.max_steps)

