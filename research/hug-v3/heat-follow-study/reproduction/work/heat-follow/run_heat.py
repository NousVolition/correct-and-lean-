"""Read-only source tags for the original coupled threshold-1 heat equation."""
import os,sys
for name in ['OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','MKL_NUM_THREADS']:os.environ[name]='1'
sys.dont_write_bytecode=True
import argparse,csv,hashlib,json,time,traceback
from datetime import datetime,timezone
from pathlib import Path
import numpy as np
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1];INPUT=HERE/'inputs';OUT=ROOT/'outputs/heat-follow'
sys.path[:0]=[str(INPUT/'declared-source'),str(INPUT/'study')]
from breathing import ComparisonSolver,Trail
from structural_hug import Config
import preflight
NAMES=['initial_warmth','net_viscous_heat','structural_release','write_0','write_1','write_2']
def stamp():return datetime.now(timezone.utc).isoformat()
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2,allow_nan=False)+'\n',encoding='utf-8')
def load_state(p):
    with np.load(p,allow_pickle=False) as z:return {k:z[k].copy() for k in z.files}
def frozen():
    entries=json.loads((INPUT/'manifest.json').read_text())
    for x in entries:assert sha(INPUT/x['path'])==x['sha256'],x['path']
    return {x['path']:x['sha256'] for x in entries}
def setup():
    sources=frozen();case=preflight.approve('threshold_1');assert case['config']['threshold']==1 and case['config']['n']==16
    with (INPUT/'study/marker-seeds.csv').open(newline='') as f:trail=Trail(list(csv.DictReader(f)))
    solver=ComparisonSolver(Config(**case['config']),.5,.6,trail)
    generated=solver.initial();s=load_state(INPUT/'baseline/state-0000.npz')
    for k,v in generated.items():
        compare=s[k][:len(v)] if k=='observer_X' else s[k]
        np.testing.assert_allclose(v,compare,atol=3e-16,rtol=0,err_msg=k)
    return solver,s,case,sources
def wrap(x):return (x+.5)%1-.5
def center(q,solver):
    total=float(q.mean())
    if abs(total)<1e-30:return np.zeros(3),0.
    moments=np.array([np.mean(q*np.exp(2j*np.pi*solver.xyz[...,j])) for j in range(3)])
    return np.angle(moments)/(2*np.pi),float(np.min(abs(moments))/abs(total))
class HeatAccount:
    def __init__(self,solver,s,dt):
        self.solver=solver;self.native=solver.rhs;self.dt=dt
        self.q=np.zeros(s['g'].shape[:3]+(6,));self.q[...,0]=s['g'][...,4]
        self.initial_mean=float(s['g'][...,4].mean());self.initial_ledger=float(s['ledger'][3])
        self.source_totals=np.zeros(6);self.write_total=0.;self.birth_centers={};self.birth_fields={}
        self.max_reconstruction=0.;self.max_budget=0.;self.max_tag_mean_error=0.;self.max_rhs_reconstruction=0.
        self.minimum_net_viscous=0.;self.minimum_structural=0.;self.minimum_K=1.;self.maximum_extraction_ratio=0.
        self.k=[];self.raw_sources=[]
    def inspect(self,q,s):
        err=float(abs(q.sum(axis=-1)-s['g'][...,4]).max());self.max_reconstruction=max(self.max_reconstruction,err)
        assert err<1e-12,('field reconstruction',err)
    def rhs(self,t,s,details=False):
        rates,stats,extra=self.native(t,s,details=True)
        q=self.q if not self.k else self.q+self.dt*self.k[0];assert len(self.k)<2
        self.inspect(q,s);u=s['g'][...,:3];K=extra['K'];gradient=self.solver.grad(q)
        flux=u[...,None,:]*q[...,None]-np.einsum('...ij,...cj->...ci',K,gradient)
        L=self.solver.grad(u);D=(L+L.swapaxes(-1,-2))/2
        Qv=2*extra['viscosity']*np.sum(D*D,axis=(-1,-2))
        net=Qv-extra['extraction'];release=extra['heat_rate']-net
        source=np.zeros_like(q);source[...,1]=net;source[...,2]=release
        dq=self.solver.filter(-self.solver.divergence(flux)+source)
        rhs_err=float(abs(dq.sum(axis=-1)-rates['g'][...,4]).max())
        self.max_rhs_reconstruction=max(self.max_rhs_reconstruction,rhs_err);assert rhs_err<1e-11
        self.minimum_net_viscous=min(self.minimum_net_viscous,float(net.min()))
        self.minimum_structural=min(self.minimum_structural,float(release.min()))
        valid=Qv>1e-30
        if valid.any():self.maximum_extraction_ratio=max(self.maximum_extraction_ratio,float((extra['extraction'][valid]/Qv[valid]).max()))
        self.k.append(dq);self.raw_sources.append(source.mean(axis=(0,1,2)))
        return (rates,stats,extra) if details else rates
    def step(self,t,s):
        self.k=[];self.raw_sources=[];new=self.solver.step(t,s,self.dt);assert len(self.k)==2
        self.q+=self.dt/2*(self.k[0]+self.k[1]);self.source_totals+=self.dt/2*(self.raw_sources[0]+self.raw_sources[1]);self.inspect(self.q,new)
        return new
    def write(self,before,after,event,account):
        idx=3+event['event_id'];pulse=after['g'][...,4]-before['g'][...,4]
        assert not np.any(self.q[...,idx]);self.q[...,idx]=pulse
        self.birth_centers[idx]=center(pulse,self.solver)[0];self.birth_fields[idx]=pulse.copy()
        self.source_totals[idx]=float(account['heat']);self.write_total+=float(account['heat']);self.inspect(self.q,after)
        assert abs(float(pulse.mean())-account['heat'])<1e-18
    def row(self,t,side,s):
        means=self.q.mean(axis=(0,1,2));expected=self.source_totals.copy();expected[0]+=self.initial_mean
        self.max_tag_mean_error=max(self.max_tag_mean_error,float(abs(means-expected).max()))
        budget=self.initial_mean+float(s['ledger'][3])-self.initial_ledger+self.write_total
        error=float(s['g'][...,4].mean())-budget;self.max_budget=max(self.max_budget,abs(error))
        assert self.max_budget<1e-12 and self.max_tag_mean_error<1e-14
        row={'time':t,'side':side,'thermal_mean':float(s['g'][...,4].mean()),'continuous_ledger':float(s['ledger'][3])-self.initial_ledger,'write_total':self.write_total,'budget_residual':error,'reconstruction_max':float(abs(self.q.sum(axis=-1)-s['g'][...,4]).max()),'temperature_min':float((1+s['g'][...,4]).min())}
        for i,name in enumerate(NAMES):
            q=self.q[...,i];total=float(means[i]);square=float(np.mean(q*q));c,concentration=center(q,self.solver)
            row.update({name+'_mean':total,name+'_expected_mean':float(expected[i]),name+'_min':float(q.min()),name+'_peak':float(q.max()),name+'_negative_integral':float(np.maximum(-q,0).mean()),name+'_effective_volume':total*total/square if square else 0.,name+'_centroid_x':float(c[0]),name+'_centroid_y':float(c[1]),name+'_centroid_z':float(c[2]),name+'_centroid_strength':concentration})
            if i>=3:
                mask=np.linalg.norm(wrap(self.solver.xyz-self.birth_centers[i]),axis=-1)>.25 if i in self.birth_centers else np.zeros(q.shape,dtype=bool)
                row[name+'_outside025_integral']=float(np.where(mask,q,0).mean())
                row[name+'_outside025_share']=row[name+'_outside025_integral']/total if total else 0.
        return row
def pilot():
    solver,s,case,sources=setup();s=load_state(INPUT/'baseline/state-0600.npz');dt=.002
    start=time.monotonic();expected=solver.step(1.2,s,dt)
    tags=HeatAccount(solver,s,dt);tags.q=s['g'][...,4,None]*np.array([.1,.2,.15,.05,.25,.25])
    solver.rhs=tags.rhs;actual=tags.step(1.2,s)
    same={k:actual[k].tobytes()==expected[k].tobytes() for k in expected};assert all(same.values()),same
    result={'passed':True,'all_native_arrays_bitwise_equal':same,'max_field_reconstruction':tags.max_reconstruction,'max_rhs_reconstruction':tags.max_rhs_reconstruction,'seconds_for_two_steps':time.monotonic()-start,'runner_sha256':sha(__file__),'input_files':len(sources),'solver_source_unchanged':True}
    dump(OUT/'pilot.json',result);print(json.dumps(result,indent=2),flush=True)
def run(tag,dt):
    folder=OUT/tag;folder.mkdir(parents=True,exist_ok=True)
    if (folder/'status.json').exists():raise FileExistsError('Existing run; inspect before restarting')
    p=json.loads((OUT/'pilot.json').read_text());assert p['passed'] and p['runner_sha256']==sha(__file__)
    solver,s,case,sources=setup();tags=HeatAccount(solver,s,dt);solver.rhs=tags.rhs
    events={round(e['end']/dt):e for e in case['events']};starts={};steps=round(1.6/dt)
    rows=[];writes=[];checks=[];frames=[];fields=[];snap_times=[];sides=[];native=[];snap_mean=[];births=0
    source_hash=sha(__file__);begin=time.monotonic();status={'status':'running','run':tag,'started_utc':stamp(),'completed_steps':0,'total_steps':steps};dump(folder/'status.json',status)
    def save(t,side):
        frames.append(round(t/dt));snap_times.append(t);sides.append(side);fields.append(tags.q.copy());native.append(s['g'].copy());snap_mean.append(tags.source_totals.copy())
    try:
        for frame in range(steps+1):
            t=round(frame*dt,12)
            if frame:
                s=tags.step(round((frame-1)*dt,12),s)
                tail=s['observer_X'][-2:].copy();points,added=solver.trail.refine(s['observer_X'][:-2],t);s['observer_X']=np.vstack([points,tail]);births+=len(added)
            assert all(np.isfinite(v).all() for v in s.values()) and np.isfinite(tags.q).all()
            event=events.get(frame)
            if event:
                rows.append(tags.row(t,'before_write',s));save(t,'before_write')
                before=s;record=solver.make_event(before,starts.pop(event['event_id']),event);s,account=solver.write_event(before,record)
                for k in before:
                    if k not in ['b','g','write_work']:np.testing.assert_array_equal(s[k],before[k])
                np.testing.assert_array_equal(s['g'][...,:4],before['g'][...,:4])
                tags.write(before,s,event,account);decoded=next(r for _,r in solver.read_material(s) if r['event_id']==event['event_id'])
                writes.append({'event_id':event['event_id'],'time':t,'account':account,'deposited_mean':float((s['g'][...,4]-before['g'][...,4]).mean()),'birth_centroid':tags.birth_centers[3+event['event_id']].tolist(),'decoded_strain_error':float(abs(decoded['delta_E']-record['delta_E']).max()),'position_velocity_context_unchanged':True})
            for e in case['events']:
                if round(e['start']/dt)==frame:starts[e['event_id']]=s['F'].copy()
            side='after_write' if event else 'at';rows.append(tags.row(t,side,s))
            if frame%round(.1/dt)==0:save(t,side)
            if dt==.002 and frame<=600 and frame%50==0:
                baseline=load_state(INPUT/f'baseline/state-{frame:04d}.npz');errors={k:float(abs(s[k]-v).max()) for k,v in baseline.items()};assert max(errors.values())<3e-13,(t,errors)
                checks.append({'time':t,'maximum_array_error':max(errors.values()),'per_array_error':errors})
            if frame%round(.1/dt)==0:
                status.update(completed_steps=frame,elapsed_seconds=time.monotonic()-begin,model_time=t);dump(folder/'status.json',status);print(json.dumps({'run':tag,'time':t,'seconds':round(status['elapsed_seconds'],2)}),flush=True)
        assert not starts and len(writes)==3 and sha(__file__)==source_hash and frozen()==sources
        with (folder/'history.csv').open('w',newline='',encoding='utf-8') as f:w=csv.DictWriter(f,list(rows[0]));w.writeheader();w.writerows(rows)
        np.savez_compressed(folder/'fields.npz',frame=frames,time=snap_times,side=np.array(sides),components=np.array(fields),native_g=np.array(native),source_totals=np.array(snap_mean),birth_centers=np.array([tags.birth_centers[i] for i in [3,4,5]]),birth_fields=np.stack([tags.birth_fields[i] for i in [3,4,5]],axis=-1),component_names=np.array(NAMES))
        np.savez_compressed(folder/'exit-state.npz',**s)
        result={'run':tag,'status':'completed','grid':16,'actual_step':dt,'end':1.6,'writes':writes,'baseline_checks':checks,'additional_observer_births':births,'recorded_rows':len(rows),'field_snapshots':len(fields),'max_field_reconstruction':tags.max_reconstruction,'max_rhs_reconstruction':tags.max_rhs_reconstruction,'max_budget_residual':tags.max_budget,'max_tag_mean_error':tags.max_tag_mean_error,'minimum_unfiltered_net_viscous':tags.minimum_net_viscous,'minimum_unfiltered_structural_release':tags.minimum_structural,'maximum_extraction_fraction_of_viscous_heating':tags.maximum_extraction_ratio,'runner_sha256':source_hash,'input_manifest_sha256':sha(INPUT/'manifest.json'),'input_files_sha256':sources,'runtime':{'python':sys.version,'numpy':np.__version__},'source_unchanged':True,'completed_utc':stamp(),'elapsed_seconds':time.monotonic()-begin,'files_sha256':{p.name:sha(p) for p in folder.iterdir() if p.name in ['history.csv','fields.npz','exit-state.npz']}}
        dump(folder/'receipt.json',result);status.update(status='completed',completed_steps=steps,elapsed_seconds=result['elapsed_seconds']);dump(folder/'status.json',status);print(json.dumps({'completed':tag,'seconds':result['elapsed_seconds'],'reconstruction':tags.max_reconstruction}),flush=True)
    except BaseException as exc:
        status.update(status='failed',error=repr(exc),traceback=traceback.format_exc());dump(folder/'status.json',status);raise
if __name__=='__main__':
    a=argparse.ArgumentParser();a.add_argument('mode',choices=['pilot','run']);a.add_argument('--dt',type=float,default=.002);args=a.parse_args()
    if args.mode=='pilot':pilot()
    else:
        assert args.dt in [.002,.001];run('n16_dt'+str(args.dt).replace('.','p'),args.dt)
