"""Passive origin bookkeeping on unchanged native states; no new physical law."""
import os,sys
os.environ.setdefault('OPENBLAS_NUM_THREADS','1');os.environ.setdefault('OMP_NUM_THREADS','1')
sys.dont_write_bytecode=True
import argparse,csv,hashlib,json,time,traceback
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'work/pair25-retention'))
import run_retention as previous
OUT=ROOT/'outputs/pair25-origins'
RADII=(.05,.075,.1)
PAIR=np.array([825,850]);OBSERVER_IDS=np.array([i for i in range(926) if i not in PAIR])
TAGS=['n40_dt0p0005','n48_dt0p0005','n48_dt0p00025']
def digest(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def dump(p,x):previous.dump(p,x)
def writecsv(p,rows):
    with p.open('w',newline='',encoding='utf-8') as f:
        w=csv.DictWriter(f,list(rows[0]));w.writeheader();w.writerows(rows)
def distances(points,centers):
    delta=points[:,None,:]-centers[None,:,:];delta-=np.rint(delta)
    d=np.sqrt(np.sum(delta*delta,axis=-1))
    return np.column_stack([d,d.min(axis=1)])
def grid_points(n):
    x=np.arange(n)/n-.5
    return np.stack(np.meshgrid(x,x,x,indexing='ij'),-1)
def transport(solver,q,u):
    """Native centered face flux, batched only over diagnostic labels."""
    uh=solver.hat(u);rhs=np.zeros_like(q)
    for j in range(3):
        multiplier=np.exp(.5j*solver.k[...,j]*solver.dx)
        for k in range(3):
            if k!=j:multiplier=multiplier*np.sinc(solver.k[...,k]*solver.dx/(2*np.pi))
        uf=solver.real(uh[...,j]*multiplier)
        plus=np.roll(q,-1,axis=j)
        flux=uf[...,None]*.5*(q+plus)-solver.c.diffusion*(plus-q)/solver.dx
        rhs-=(flux-np.roll(flux,1,axis=j))/solver.dx
    return rhs
class Origins:
    def __init__(self,solver,s,dt):
        self.solver=solver;self.native=solver.rhs;self.dt=dt
        self.xyz=grid_points(solver.n);d=distances(self.xyz.reshape(-1,3),s['observer_X'][PAIR])[:,2].reshape(solver.n,solver.n,solver.n)
        self.q=np.empty(s['g'].shape[:3]+(7,))
        C=s['g'][...,3]
        for i,r in enumerate(RADII):
            self.q[...,i]=np.where(d<=r,C,0.)
            self.q[...,i+3]=np.where(d>r,C,0.)
        self.q[...,6]=0.
        self.qentry=self.q.copy();self.global_entry=self.q.mean(axis=(0,1,2))
        self.k=[];self.stage_max_defect=0.;self.min_component=0.;self.source_integrals=[]
        self.source_integral=0.;self.state_min_C=float(C.min())
    def check_reconstruction(self,q,s):
        self.stage_max_defect=max(self.stage_max_defect,max(float(abs(q[...,i]+q[...,i+3]+q[...,6]-s['g'][...,3]).max()) for i in range(3)))
        self.min_component=min(self.min_component,float(q.min()))
        self.state_min_C=min(self.state_min_C,float(s['g'][...,3].min()))
    def rhs(self,t,s,details=False):
        rates,stats,extra=self.native(t,s,details=True)
        q=self.q if not self.k else self.q+self.dt*self.k[0]
        assert len(self.k)<2
        self.check_reconstruction(q,s)
        dq=transport(self.solver,q,s['g'][...,:3])
        source=self.solver.c.kappa*float(s['A'])*extra['kernel']
        dq[...,6]+=source
        self.source_integrals.append(float(source.mean()))
        self.k.append(dq)
        return (rates,stats,extra) if details else rates
    def step(self,t,s):
        self.k=[];self.source_integrals=[]
        result=self.solver.step(t,s,self.dt)
        assert len(self.k)==2
        self.q=self.q+self.dt/2*(self.k[0]+self.k[1])
        self.source_integral+=self.dt/2*sum(self.source_integrals)
        self.check_reconstruction(self.q,result)
        return result
def pilot():
    OUT.mkdir(parents=True,exist_ok=True)
    solver,s,info,inputs,count=previous.load(TAGS[0]);dt=info['dt']
    rng=np.random.default_rng(2525)
    q=rng.normal(size=s['g'].shape[:3]+(3,))
    batched=transport(solver,q,s['g'][...,:3])
    errors=[float(abs(batched[...,i]-solver.context_transport(q[...,i],s['g'][...,:3])).max()) for i in range(3)]
    assert max(errors)<1e-11
    conservation=float(abs(batched.mean(axis=(0,1,2))).max());assert conservation<1e-12
    original=solver.step(1.2,s,dt)
    audit=Origins(solver,s,dt);solver.rhs=audit.rhs
    marked=audit.step(1.2,s)
    exact={k:np.array_equal(original[k],marked[k]) for k in s}
    assert all(exact.values()) and audit.stage_max_defect<1e-12
    result={'passed':True,'all_native_one_step_arrays_identical':exact,'native_transport_max_difference':max(errors),'synthetic_conservative_transport_error':conservation,'origin_reconstruction_error':audit.stage_max_defect,'minimum_component':audit.min_component,'source_inputs_checked':count,'code_sha256':digest(__file__),'scope':'Two validation solver steps; no production results.'}
    dump(OUT/'setup-checks.json',result);print(json.dumps(result,indent=2),flush=True)
def run(tag):
    folder=OUT/tag;folder.mkdir(parents=True,exist_ok=True)
    if (folder/'status.json').exists():raise FileExistsError('Existing run; inspect before restart')
    pilot_record=json.loads((OUT/'setup-checks.json').read_text())
    assert pilot_record['passed'] and pilot_record['code_sha256']==digest(__file__)
    solver,s,info,inputs,count=previous.load(tag)
    n=info['n'];dt=info['dt'];steps=round(.1/dt);every=round(.002/dt)
    origins=Origins(solver,s,dt);solver.rhs=origins.rhs
    entry={k:v.copy() for k,v in s.items()}
    ep,ei=previous.payload_array(solver,s)
    positions=[];material_positions=[];material_m=[];material_F=[];payloads=[];record_ids=[];times=[]
    origin_rows=[];point_rows=[];census=[];field_samples=[];common_times=[]
    max_drift=0.;max_source_defect=0.;start=time.monotonic()
    status={'run':tag,'status':'running','completed_steps':0,'total_steps':steps,'started_utc':previous.stamp(),'start':1.2,'end':1.3}
    dump(folder/'status.json',status)
    try:
        for j in range(steps+1):
            t=round(1.2+j*dt,12)
            if j:s=origins.step(round(1.2+(j-1)*dt,12),s)
            centers=s['observer_X'][PAIR]
            positions.append(s['observer_X'].copy());material_positions.append(s['X'].copy());times.append(t)
            material_m.append(s['m'].copy());material_F.append(s['F'].copy())
            pa,ri=previous.payload_array(solver,s);payloads.append(pa);record_ids.append(ri)
            assert list(ri)==list(ei) and np.array_equal(pa,ep),'Memory record contents changed'
            for population,pts,ids in [('material',s['X'],np.arange(384)),('observer',s['observer_X'][OBSERVER_IDS],OBSERVER_IDS)]:
                d=distances(pts,centers)
                for radius in RADII:
                    for v,view in enumerate(['A','B','union']):
                        inside=d[:,v]<=radius
                        census.append({'run':tag,'step':j,'time':t,'population':population,'radius':radius,'view':view,'inside':int(inside.sum()),'outside':int((~inside).sum()),'near_boundary':int((abs(d[:,v]-radius)<=1e-8).sum()),'minimum_boundary_distance':float(abs(d[:,v]-radius).min())})
            q=origins.q;totals=q.mean(axis=(0,1,2))
            max_drift=max(max_drift,float(abs(totals[:6]-origins.global_entry[:6]).max()))
            max_source_defect=max(max_source_defect,abs(float(totals[6])-origins.source_integral),abs(float(totals[6])-(float(s['ledger'][0])-float(entry['ledger'][0]))))
            if j%every==0:
                d=distances(origins.xyz.reshape(-1,3),centers)[:,2].reshape(n,n,n)
                point_values=previous.sample(q,centers)[0]
                actual_points=previous.sample(s['g'][...,3],centers)[0]
                for i,radius in enumerate(RADII):
                    w=d<=radius
                    row={'run':tag,'step':j,'time':t,'radius':radius,
                         'entry_inside_context':float(origins.global_entry[i]),
                         'original_inside_now':float(np.where(w,q[...,i],0.).mean()),
                         'original_elsewhere_now':float(np.where(~w,q[...,i],0.).mean()),
                         'outside_origin_inside_now':float(np.where(w,q[...,i+3],0.).mean()),
                         'later_source_inside_now':float(np.where(w,q[...,6],0.).mean()),
                         'total_inside_now':float(np.where(w,s['g'][...,3],0.).mean()),
                         'original_global_now':float(totals[i]),'later_source_global_now':float(totals[6]),
                         'source_integral':origins.source_integral,'window_grid_cells':int(w.sum())}
                    origin_rows.append(row)
                    for p,name in enumerate(['A','B']):
                        point_rows.append({'run':tag,'time':t,'radius':radius,'point':name,
                            'original_inside':float(point_values[p,i]),'outside_origin':float(point_values[p,i+3]),
                            'later_source':float(point_values[p,6]),'native_context':float(actual_points[p])})
                field_samples.append(q.copy());common_times.append(t)
            if j%10==0 or j==steps:
                status.update(completed_steps=j,model_time=t,elapsed_seconds=time.monotonic()-start,observed_utc=previous.stamp())
                dump(folder/'status.json',status);print(tag,j,'/',steps,'seconds',round(time.monotonic()-start,1),flush=True)
        prior=ROOT/'outputs/pair25-retention'/tag
        with np.load(prior/'exit-state.npz') as z:exact={k:s[k].tobytes()==z[k].tobytes() for k in s}
        with np.load(prior/'pair-positions.npz') as z:pair_exact=np.array_equal(np.asarray(positions)[::every][:,PAIR],z['positions'])
        np.savez_compressed(folder/'exit-state.npz',**s)
        np.savez_compressed(folder/'tracked-states.npz',times=np.asarray(times),observer_positions=np.asarray(positions),material_positions=np.asarray(material_positions),material_F=np.asarray(material_F),material_m=np.asarray(material_m),observer_ids=np.arange(926),material_ids=np.arange(384))
        np.savez_compressed(folder/'record-payloads.npz',times=np.asarray(times),payloads=np.asarray(payloads),ids=np.asarray(record_ids),entry_payloads=ep,entry_ids=ei)
        np.savez_compressed(folder/'context-origins.npz',times=np.asarray(common_times),fields=np.asarray(field_samples),initial=origins.qentry,radii=np.asarray(RADII))
        writecsv(folder/'window-census.csv',census);writecsv(folder/'context-window-origins.csv',origin_rows);writecsv(folder/'context-point-origins.csv',point_rows)
        verdict={'all_native_exit_arrays_unchanged':all(exact.values()),'all_saved_pair_positions_unchanged':bool(pair_exact),'context_reconstruction_met':origins.stage_max_defect<=1e-12,'original_component_total_met':max_drift<=1e-12,'later_source_account_met':max_source_defect<=1e-10,'components_nonnegative_within_roundoff':origins.min_component>=-1e-12,'all_memory_payloads_unchanged':True}
        result={'run':tag,'n':n,'dt':dt,'start':1.2,'end':1.3,'steps':steps,'radii':RADII,'primary_radius':.075,'native_array_equality':exact,'criteria':verdict,'max_context_reconstruction_defect':origins.stage_max_defect,'max_global_original_component_drift':max_drift,'max_later_source_account_defect':max_source_defect,'minimum_origin_component':origins.min_component,'minimum_native_context':origins.state_min_C,'shared_payload_comparisons':3*(steps+1),'input_hashes':inputs,'prior_exit_sha256':digest(prior/'exit-state.npz'),'code_sha256':digest(__file__),'elapsed_seconds':time.monotonic()-start,'scope':'Passive finite identity and signed-context provenance in declared moving views; no private complete physical inventory.'}
        dump(folder/'result.json',result)
        for p,h in inputs.items():assert digest(ROOT/p)==h
        status.update(status='complete',completed_utc=previous.stamp(),criteria=verdict,elapsed_seconds=time.monotonic()-start);dump(folder/'status.json',status)
    except BaseException as exc:
        status.update(status='failed',error=repr(exc),traceback=traceback.format_exc(),failed_utc=previous.stamp());dump(folder/'status.json',status);raise
if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('action',choices=['pilot','run']);parser.add_argument('--tag',choices=TAGS);args=parser.parse_args()
    pilot() if args.action=='pilot' else run(args.tag)
