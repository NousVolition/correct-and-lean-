"""Threshold-1 full-history refinements; original numerical modules read-only."""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
os.environ['OMP_NUM_THREADS']='1'
import sys
sys.dont_write_bytecode=True
from pathlib import Path
import argparse,csv,hashlib,importlib.util,json,shutil,time
from unittest.mock import patch
import numpy as np
from scipy.fft import fftn,ifftn
from scipy import ndimage

HERE=Path(__file__).resolve().parent
ROOT=HERE.parent.parent
OUT=ROOT/'outputs/hug-threshold1-refinement'
SOURCE=ROOT/'outputs/hug-v3-breathing-setup'
PREVIOUS=ROOT/'external-archives/prior-fluid-convergence'
ARCHIVE=ROOT/'external-archives/prior-threshold-one'
OUT.mkdir(parents=True,exist_ok=True)
sys.path[:0]=[str(SOURCE),str(SOURCE/'upstream')]
from study import approved_arm
from breathing import ComparisonSolver,Config,Trail
import breathing as breathing_module

def digest(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def dump(path,value):Path(path).write_text(json.dumps(value,indent=2,allow_nan=False),encoding='utf-8')
def plain(v):
    if isinstance(v,np.ndarray):return v.tolist()
    if isinstance(v,np.generic):return v.item()
    if isinstance(v,dict):return {k:plain(x) for k,x in v.items()}
    if isinstance(v,(list,tuple)):return [plain(x) for x in v]
    return v
def readcsv(path):
    with Path(path).open(encoding='utf-8',newline='') as f:return list(csv.DictReader(f))

def coeff(g,n):
    f=np.arange(-((n-1)//3),(n-1)//3+1)
    return f,fftn(g,axes=(0,1,2))[np.ix_(f%n,f%n,f%n)]/n**3
def at(h,f,p):
    p=np.asarray(p);phase=np.exp(2j*np.pi*((p.reshape(-1,3)+.5)%1)[:,:,None]*f)
    v=np.tensordot(phase[:,0],h,axes=(1,0));v=np.einsum('pj,pjkc->pkc',phase[:,1],v)
    return np.einsum('pk,pkc->pc',phase[:,2],v).real.reshape(p.shape)
def on_grid(h,f,n):
    pad=np.zeros((n,n,n)+h.shape[3:],complex);pad[np.ix_(f%n,f%n,f%n)]=h*n**3
    return ifftn(pad,axes=(0,1,2)).real
def cubic(h,f,n):
    response=(2+np.cos(2*np.pi*f/n))/3
    weights=response[:,None,None]*response[None,:,None]*response[None,None,:]
    grid=np.ascontiguousarray(np.moveaxis(on_grid(h/weights[...,None],f,n),-1,0))
    def evaluate(points):
        p=np.asarray(points);xyz=((p.reshape(-1,3)+.5)*n).T
        return np.stack([ndimage.map_coordinates(c,xyz,order=3,mode='grid-wrap',prefilter=False) for c in grid],axis=1).reshape(p.shape)
    return evaluate
def curl(h,f):return np.cross(2j*np.pi*np.stack(np.meshgrid(f,f,f,indexing='ij'),-1),h)
def trace(evaluate,seeds,ds,length):
    count=round(length/abs(ds));assert abs(count*abs(ds)-length)<1e-13
    path=np.empty((count+1,len(seeds),3));path[0]=seeds;minimum=np.inf
    def direction(p):
        nonlocal minimum
        v=evaluate(p);norm=np.linalg.norm(v,axis=1);minimum=min(minimum,float(norm.min()))
        if norm.min()<1e-8:raise FloatingPointError('Near-null vortex direction')
        return v/norm[:,None]
    for j in range(count):
        p=path[j];a=direction(p);b=direction(p+ds*a/2);c=direction(p+ds*b/2);d=direction(p+ds*c)
        path[j+1]=p+ds/6*(a+2*b+2*c+d)
    return path,minimum
def nearest(path,target):
    a=path[:-1]-target;a-=np.rint(a);d=np.diff(path,axis=0)
    q=np.clip(-np.sum(a*d,axis=2)/np.sum(d*d,axis=2),0,1)
    mag=np.linalg.norm(a+q[:,:,None]*d,axis=2);idx=mag.argmin(axis=0);seeds=np.arange(len(target))
    return mag[idx,seeds],idx+q[idx,seeds]
def heun(p,h,f,dt):return p+dt/2*(at(h[0],f,p)+at(h[1],f,p+dt*at(h[0],f,p)))

def prepare():
    case,extra=approved_arm('breathing_on');upstream=SOURCE/'upstream'
    seal=json.loads((upstream/'source_seal.json').read_text())
    inputs={str(upstream/p):sha for p,sha in seal.items()}
    for name in ['study.py','breathing.py','comparison-seal.json','marker-seeds.csv','prime-times.csv']:
        inputs[str(SOURCE/name)]=digest(SOURCE/name)
    for path in [PREVIOUS/'outputs/fluid-convergence/observer-labels.npz',PREVIOUS/'outputs/fluid-convergence/observer-labels.json',
                 SOURCE/'results/breathing_on/prime-02-at.npz',ARCHIVE/'fields.npz',ARCHIVE/'checks.json']:
        inputs[str(path)]=digest(path)
    assert all(digest(p)==sha for p,sha in inputs.items())
    for n in [16,24,32]:
        target=HERE/('declared-n'+str(n));target.mkdir(exist_ok=True)
        for name,sha in seal.items():
            dest=target/name;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(upstream/name,dest)
        cfg=dict(case['config'],threshold=1.,n=n)
        protocol=json.loads((target/'protocol.json').read_text())
        ident='threshold1_n'+str(n);protocol['cases'][ident]=dict(config=cfg,events=case['events'])
        dump(target/'protocol.json',protocol)
        manifest=json.loads((target/'declarations/main.json').read_text())
        manifest['run_id']=ident;manifest['parameters'].update(threshold=1.,n=n)
        manifest['fixture_ranges']['n']=dict(min=n,max=n)
        if 'threshold' in manifest['fixture_ranges']:manifest['fixture_ranges']['threshold']=dict(min=1.,max=1.)
        for rule in manifest['added_rules']:
            if rule['name']=='Inherited M16 Force setup':
                rule['statement']=rule['statement'].replace('Gamma=0.015','Gamma=1')
                rule['reason']='User-requested threshold1 refinement from time zero, 2026-11-11.'
        newname='declarations/'+ident+'.json';dump(target/newname,manifest)
        dump(target/'source_seal.json',{p:digest(target/p) for p in list(seal)+[newname]})
        dump(target/'derivation.json',dict(numerical_sources_unchanged=True,guard_unchanged=True,
             original_seal=digest(upstream/'source_seal.json'),changes=[dict(path='protocol.json',old=seal['protocol.json'],new=digest(target/'protocol.json'))],
             added=[dict(path=newname,sha256=digest(target/newname))],physical_changes={'threshold':[.015,1.]},grid=n))
    shutil.copy2(PREVIOUS/'outputs/fluid-convergence/observer-labels.npz',OUT/'observer-labels.npz')
    shutil.copy2(PREVIOUS/'outputs/fluid-convergence/observer-labels.json',OUT/'observer-labels-origin.json')
    dump(OUT/'input-sha256.json',inputs)
    for n in [16,24,32]:
        solver,_,_=make_solver(n);assert solver.c.threshold==1 and solver.n==n
        print('Declaration accepted',n,flush=True)
    import scipy,platform
    dump(OUT/'runtime.json',dict(python=sys.version,executable=sys.executable,numpy=np.__version__,scipy=scipy.__version__,platform=platform.platform(),threads=1))
    shutil.copy2(HERE/'PLAN.md',OUT/'METHODS.md')

_original_velocity=breathing_module.fluid_velocity
def make_solver(n):
    case,extra=approved_arm('breathing_on')
    path=HERE/('declared-n'+str(n))/'preflight.py'
    spec=importlib.util.spec_from_file_location('threshold_refinement_gate_'+str(n),path)
    gate=importlib.util.module_from_spec(spec);spec.loader.exec_module(gate)
    declared=gate.approve('threshold1_n'+str(n))
    def rounded_velocity(solver,grid,points):
        f=np.rint(solver.freq[np.abs(solver.freq)<solver.n/3]).astype(int)
        return at(solver.hat(grid)[np.ix_(f%solver.n,f%solver.n,f%solver.n)]/solver.n**3,f,points)
    breathing_module.fluid_velocity=_original_velocity if n==16 else rounded_velocity
    with patch.dict(sys.modules,{'preflight':gate}):
        solver=ComparisonSolver(Config(**declared['config']),extra['peak'],extra['period'],Trail(readcsv(SOURCE/'marker-seeds.csv')))
    return solver,declared,extra

def run(n,dt):
    tag='n'+str(n)+'_dt'+str(dt).replace('.','p');folder=OUT/tag
    folder.mkdir(exist_ok=False)
    solver,case,extra=make_solver(n);state=solver.initial()
    with np.load(SOURCE/'results/breathing_on/prime-02-at.npz') as z:
        for k in z.files:
            if k=='g' and n!=16:
                f,h=coeff(z[k],16);state[k]=on_grid(h,f,n)
            else:state[k]=z[k].copy()
    initial_g=state['g'].copy()
    with np.load(OUT/'observer-labels.npz') as z:observers=z['initial'].copy()
    f=np.arange(-((n-1)//3),(n-1)//3+1)
    steps=round(1.2/dt);first=round(1.1/dt)
    assert abs(steps*dt-1.2)<1e-13 and abs(first*dt-1.1)<1e-13
    ends={round(e['end']/dt):e for e in case['events']};starts={}
    checks=[];diags=[];event_log=[];window=[];moved=[];prime_fields=[];stages=[]
    native=solver.rhs;energy0=None;t0=time.monotonic();is_baseline=(n==16 and dt==.002)
    archive_stages=None
    if is_baseline:
        with np.load(ARCHIVE/'fields.npz') as saved:archive_stages=saved['stages']
    full=np.lib.format.open_memmap(folder/'window-stages.npy',mode='w+',dtype=np.complex128,shape=(round(.1/dt),2,len(f),len(f),len(f),3))
    stage_error=0.;birth_count=0
    def capture(t,s,details=False):
        if not details:stages.append(coeff(s['g'][...,:3],n)[1])
        return native(t,s,details)
    def diagnostics(t,side):
        nonlocal energy0
        _,stats,_=native(t,state,details=True)
        if energy0 is None:energy0=stats['energy']
        stats.update(side=side,breathing_work=float(state['breathing_work']),write_work=float(state['write_work']),
            energy_balance=float(stats['energy']-energy0-state['ledger'][1]-state['breathing_work']-state['write_work']))
        diags.append(stats)
    with patch.object(solver,'rhs',capture):
        for i in range(steps+1):
            t=i*dt
            if i:
                stages.clear();state=solver.step((i-1)*dt,state,dt);assert len(stages)==2
                observers=heun(observers,stages,f,dt)
                if i>first:full[i-first-1]=stages
                if is_baseline:stage_error=max(stage_error,float(np.max(abs(np.asarray(stages)-archive_stages[i-1]))))
                if not all(np.isfinite(v).all() for v in state.values()):raise FloatingPointError('Nonfinite '+str(t))
                state['observer_X'],births=solver.trail.refine(state['observer_X'],t);birth_count+=len(births)
                if births:raise RuntimeError('Native trail birth requires extended accounting; saved prior observations remain valid')
            prime=abs(t/.1-round(t/.1))<1e-9;common=abs(t/.002-round(t/.002))<1e-9
            if i==first:
                ew=cubic(curl(coeff(state['g'][...,:3],n)[1],f),f,128)
                a,lo=trace(ew,observers[50:75],-1/1024,.09375);b,hi=trace(ew,observers[50:75],1/1024,.09375)
                observers=np.vstack([observers,a[-1],b[-1]])
                dump(folder/'selection.json',dict(recipe='grid128 RK4 ds1/1024 +/-0.09375 through transported centers',min_direction=min(lo,hi)))
            if i>=first and common:
                window.append(coeff(state['g'][...,:3],n)[1]);moved.append(observers.copy())
            if prime:
                side='before_write' if i in ends else 'at';diagnostics(t,side)
                prime_fields.append(state['g'].copy())
                np.savez_compressed(folder/('state-'+str(i).zfill(4)+'-'+side+'.npz'),**state)
            if i in ends:
                event=ends[i];record=solver.make_event(state,starts.pop(event['event_id']),event)
                before={k:state[k].copy() for k in ['g','X','F','observer_X','A']}
                state,account=solver.write_event(state,record)
                for k in ['X','F','observer_X','A']:np.testing.assert_array_equal(before[k],state[k])
                np.testing.assert_array_equal(before['g'][...,:4],state['g'][...,:4])
                event_log.append(dict(time=t,event_id=event['event_id'],positions_velocity_context_unchanged=True,**account))
                diagnostics(t,'after_write');np.savez_compressed(folder/('state-'+str(i).zfill(4)+'-after_write.npz'),**state)
            for e in case['events']:
                if round(e['start']/dt)==i:starts[e['event_id']]=state['F'].copy()
            if is_baseline and (ARCHIVE/('state-'+str(i).zfill(4)+'.npz')).exists():
                with np.load(ARCHIVE/('state-'+str(i).zfill(4)+'.npz')) as z:
                    errors={k:float(np.max(abs(state[k]-z[k]))) for k in z.files if k!='observer_X'}
                    markerr=float(np.max(abs(state['observer_X'][:801]-z['observer_X'][:801])))
                assert max(errors.values())<3e-13 and markerr<3e-13
                checks.append(dict(frame=i,time=t,physical_max_error=max(errors.values()),physical_exact=all(v==0 for v in errors.values()),original_marker_max_error=markerr))
            if prime:
                progress=dict(run=tag,time=t,step=i,steps=steps,elapsed_seconds=time.monotonic()-t0)
                dump(folder/'progress.json',progress);print(json.dumps(progress),flush=True)
    full.flush()
    decoded=solver.read_material(state);assert [r['event_id'] for _,r in decoded]==[0,1,2]
    dump(folder/'decoded-events.json',plain([dict(slot=int(slot),**r) for slot,r in decoded]))
    np.savez_compressed(folder/'window.npz',freq=f,velocity=np.asarray(window),observers=np.asarray(moved),times=np.arange(550,601)*.002)
    np.savez_compressed(folder/'prime-fields.npz',g=np.asarray(prime_fields),initial=initial_g)
    np.savez_compressed(folder/'final-state.npz',**state)
    dump(folder/'diagnostics.json',diags);dump(folder/'events.json',event_log);dump(folder/'baseline-checks.json',checks)
    if is_baseline:assert stage_error<3e-13
    summary=dict(n=n,dt=dt,threshold=1.,full_history=True,steps=steps,elapsed_seconds=time.monotonic()-t0,
      config=vars(solver.c),breathing_peak=extra['peak'],breathing_period=extra['period'],events=event_log,
      source_manifest=case['manifest_sha256'],comparison_manifest=extra['manifest_sha256'],
      initial_condition='exact saved native arrays, same Fourier polynomial at finer grids',
      baseline_checkpoint_count=len(checks),baseline_max_velocity_stage_error=stage_error if is_baseline else None,
      original_markers=len(state['observer_X']),marker_births=birth_count,additional_observers=len(observers),
      passive_frequency_conversion='original' if n==16 else 'round integer-valued modes',
      max_abs_energy_balance=max(abs(v['energy_balance']) for v in diags))
    dump(folder/'summary.json',summary);print('COMPLETE',tag,flush=True)

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('action',choices=['prepare','run']);p.add_argument('--n',type=int,default=16);p.add_argument('--dt',type=float,default=.002)
    a=p.parse_args()
    if a.action=='prepare':prepare()
    else:run(a.n,a.dt)
