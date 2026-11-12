"""A high-band velocity perturbation at tick 41, evolved with full coupling.

This is a numerical sensitivity experiment, not an additional physical force.
The unchanged sealed solver is resumed from the saved post-write state at 1.2.
"""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
os.environ['OMP_NUM_THREADS']='1'
import sys
sys.dont_write_bytecode=True
from pathlib import Path
HERE=Path(__file__).resolve().parent
MODEL=HERE/'model'
if not MODEL.exists():raise FileNotFoundError('Extract the complete published study, including model/')
sys.path.insert(0,str(MODEL/'work/hug-threshold1-refinement'))
from run_study import make_solver,np,digest
import scipy,json,csv,argparse,time,shutil,platform

N=32;START=1.2;END=1.22;RELATIVE_AMPLITUDE=1e-4
INPUT=HERE/'inputs';INPUT.mkdir(parents=True,exist_ok=True)
STATE=INPUT/'tick41-off-n32.npz'
ORIGINAL=STATE

def write_json(p,value):Path(p).write_text(json.dumps(value,indent=2,allow_nan=False),encoding='utf-8')
def spectrum(a):return np.fft.fftn(a,axes=(0,1,2))/N**3
F=np.rint(np.fft.fftfreq(N)*N).astype(int)
K=np.stack(np.meshgrid(F,F,F,indexing='ij'),axis=-1)
KMAX=np.max(abs(K),axis=-1)
BANDS=dict(mean=KMAX==0,broad=(KMAX>=1)&(KMAX<=2),middle=(KMAX>=3)&(KMAX<=7),fine=(KMAX>=8)&(KMAX<=10),outside=KMAX>10)
LOW_INDEX=np.arange(-2,3)%N

def low(h):
    v=h[np.ix_(LOW_INDEX,LOW_INDEX,LOW_INDEX)].copy();v[2,2,2]=0
    return v
def norm(h,mask=None):return float(np.sqrt(np.sum(abs(h if mask is None else h[mask])**2)))
def rms(a):return float(np.sqrt(np.mean(np.sum(a*a,axis=-1))))
def load_state():
    with np.load(STATE) as z:return {k:z[k].copy() for k in z.files}
def new_solver():
    solver,case,extra=make_solver(N)
    solver.peak=0.;solver.initial()  # establishes the native fixed utility baseline
    assert solver.c.threshold==1 and all(e['end']<=START for e in case['events'])
    return solver,case

def prepare():
    if not STATE.exists():shutil.copyfile(ORIGINAL,STATE)
    solver,case=new_solver();s=load_state();u=s['g'][...,:3]
    rng=np.random.default_rng(20261112)
    raw=rng.standard_normal(u.shape)
    q=solver.project(raw)
    q=solver.real(solver.hat(q)*BANDS['fine'][...,None]);q/=rms(q)
    np.save(INPUT/'unit-fine-perturbation.npy',q)
    epsilon=RELATIVE_AMPLITUDE*rms(u)
    changed={k:v.copy() for k,v in s.items()};changed['g'][...,:3]+=epsilon*q
    difference=changed['g'][...,:3]-u;dh=spectrum(difference)
    unchanged=[k for k in s if k!='g' and np.array_equal(s[k],changed[k])]
    assert len(unchanged)==len(s)-1
    assert np.array_equal(changed['g'][...,3:],s['g'][...,3:])
    assert norm(dh,BANDS['broad'])<1e-16 and norm(dh,BANDS['mean'])<1e-16
    assert abs(rms(q)-1)<1e-14
    assert np.max(abs(np.sum(2j*np.pi*K*spectrum(q),axis=-1)))<1e-12
    base_rates=solver.rhs(START,s)
    pert_rates=solver.rhs(START,changed)
    initial_rate=low(spectrum(pert_rates['g'][...,:3]-base_rates['g'][...,:3]))
    np.save(INPUT/'initial-broad-rate-difference.npy',initial_rate)
    declaration=dict(question='Does a velocity difference confined to fine Fourier modes generate a broad-mode difference under the full coupled evolution?',
        n=N,threshold=1,breathing='off',model_time_start=START,model_time_end=END,start_side='after third write',
        broad_modes='1 <= max(abs(k_x),abs(k_y),abs(k_z)) <= 2',
        fine_modes='8 <= max(abs(k_x),abs(k_y),abs(k_z)) <= 10',
        convention='Integer wave numbers count cycles per unit cube; broad excludes the spatial mean.',
        perturbation_random_seed=20261112,perturbation_relative_rms=RELATIVE_AMPLITUDE,
        baseline_velocity_rms=rms(u),perturbation_absolute_rms=epsilon,
        initial_actual_fine_difference=norm(dh,BANDS['fine']),initial_broad_roundoff=norm(dh,BANDS['broad']),
        initial_mean_roundoff=norm(dh,BANDS['mean']),initial_broad_rate_difference=norm(initial_rate),
        unchanged_state_arrays=unchanged,context_and_heat_initially_identical=True,
        time_steps=[.0005,.00025,.000125],half_amplitude_step=.00025,
        coupling='All original fluid, thermal, fabric, material, actor and record feedback active.',
        scheduled_writes_in_window=[],readable_record_ids=[r['event_id'] for _,r in solver.read_material(s)],
        source_state_sha256=digest(STATE),source_case_manifest=case['manifest_sha256'],
        perturbation_sha256=digest(INPUT/'unit-fine-perturbation.npy'),
        no_new_forcing=True,gate='Native threshold1_n32 configuration accepted by unchanged preflight; experiment changes only initial velocity.',
        interpretation='Supports sensitivity to an imposed fine-band discrepancy. Does not identify the source of pre-existing numerical errors or prove an energy cascade.',
        runtime=dict(python=sys.version,numpy=np.__version__,scipy=scipy.__version__,platform=platform.platform(),threads=1))
    write_json(HERE/'EXPERIMENT.json',declaration)
    print(json.dumps({k:declaration[k] for k in ['baseline_velocity_rms','perturbation_absolute_rms','initial_broad_roundoff','initial_broad_rate_difference','readable_record_ids']},indent=2))

def run(dt,half):
    decl=json.loads((HERE/'EXPERIMENT.json').read_text())
    epsilon=decl['perturbation_absolute_rms'];q=np.load(INPUT/'unit-fine-perturbation.npy')
    dest=HERE/'outputs'/('dt'+str(dt).replace('.','p'));dest.mkdir(parents=True,exist_ok=True)
    amplitudes={'baseline':0.,'fine_error':1.}
    if half:amplitudes['half_error']=.5
    solvers={};states={};initial_energy={};initial_ledgers={}
    for name,multiple in amplitudes.items():
        solvers[name],case=new_solver();s=load_state();s['g'][...,:3]+=multiple*epsilon*q;states[name]=s
        stats=solvers[name].rhs(START,s,True)[1]
        initial_energy[name]=stats['energy']
        initial_ledgers[name]=float(s['ledger'][1]+s['write_work']+s['breathing_work'])
    steps=round((END-START)/dt);sample_every=round(.0005/dt)
    assert abs(steps*dt-(END-START))<1e-12 and sample_every*dt==.0005
    rows=[];vectors=[];times=[];progress0=time.monotonic();repeat_exact=None
    for i in range(steps+1):
        t=START+i*dt
        if i:
            for name in states:
                before=states[name]
                states[name]=solvers[name].step(t-dt,before,dt)
                if i==1 and name=='baseline':
                    repeat=solvers[name].step(t-dt,{k:v.copy() for k,v in before.items()},dt)
                    repeat_exact=all(np.array_equal(repeat[k],states[name][k]) for k in repeat)
                    assert repeat_exact
            assert all(np.isfinite(v).all() for s in states.values() for v in s.values())
        base=states['baseline'];baseh=spectrum(base['g'][...,:3])
        row=dict(time=t,elapsed_time=i*dt,dt=dt,baseline_broad_rms=norm(baseh,BANDS['broad']),baseline_fine_rms=norm(baseh,BANDS['fine']))
        snapshot=[]
        for name,multiple in amplitudes.items():
            if name=='baseline':continue
            s=states[name];d=s['g'][...,:3]-base['g'][...,:3];h=spectrum(d)
            for band,mask in BANDS.items():row[f'{name}_{band}_rms']=norm(h,mask)
            row[f'{name}_total_rms']=norm(h)
            row[f'{name}_broad_per_initial_error']=row[f'{name}_broad_rms']/(epsilon*multiple)
            row[f'{name}_fine_per_initial_error']=row[f'{name}_fine_rms']/(epsilon*multiple)
            row[f'{name}_A_difference']=float(s['A']-base['A'])
            row[f'{name}_X_rms']=rms(s['X']-base['X'])
            row[f'{name}_F_rms']=float(np.sqrt(np.mean((s['F']-base['F'])**2)))
            row[f'{name}_clay_rms']=float(np.sqrt(np.mean((s['b']-base['b'])**2)))
            row[f'{name}_heat_rms']=float(np.sqrt(np.mean((s['g'][...,4]-base['g'][...,4])**2)))
            row[f'{name}_context_field_rms']=float(np.sqrt(np.mean((s['g'][...,3]-base['g'][...,3])**2)))
            row[f'{name}_actor_ties_rms']=float(np.sqrt(np.mean((s['relation']-base['relation'])**2)))
            snapshot.append(low(h))
        rows.append(row)
        if i%sample_every==0:times.append(t);vectors.append(snapshot)
        if i%max(1,steps//10)==0 or i==steps:
            progress=dict(dt=dt,time=t,completed=i,total=steps,arms=len(states),elapsed_seconds=time.monotonic()-progress0,
                broad_difference=row['fine_error_broad_rms'],fine_difference=row['fine_error_fine_rms'])
            write_json(dest/'progress.json',progress);print(json.dumps(progress),flush=True)
    with (dest/'history.csv').open('w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
    np.savez_compressed(dest/'broad-difference-modes.npz',times=np.asarray(times),values=np.asarray(vectors),arms=np.array([n for n in states if n!='baseline']))
    balances={};decoded={}
    for name,s in states.items():
        np.savez_compressed(dest/f'{name}-final.npz',**s)
        stats=solvers[name].rhs(END,s,True)[1]
        balances[name]=float(stats['energy']-initial_energy[name]-(s['ledger'][1]+s['write_work']+s['breathing_work']-initial_ledgers[name]))
        decoded[name]=[r['event_id'] for _,r in solvers[name].read_material(s)]
        assert decoded[name]==[0,1,2] and float(s['breathing_work'])==0
    summary=dict(dt=dt,steps=steps,arms=amplitudes,initial_epsilon=epsilon,repeat_first_step_bit_identical=repeat_exact,
        energy_balance_residuals=balances,readable_record_ids=decoded,initial=rows[0],final=rows[-1],elapsed_seconds=time.monotonic()-progress0,
        source_state_unchanged=digest(STATE)==decl['source_state_sha256'])
    write_json(dest/'summary.json',summary)
    print('COMPLETE '+json.dumps(dict(dt=dt,final_broad=rows[-1]['fine_error_broad_rms'],final_fine=rows[-1]['fine_error_fine_rms'],balances=balances)),flush=True)

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('action',choices=['prepare','run']);p.add_argument('--dt',type=float,default=.0005);p.add_argument('--half-amplitude',action='store_true')
    a=p.parse_args()
    if a.action=='prepare':prepare()
    else:run(a.dt,a.half_amplitude)
