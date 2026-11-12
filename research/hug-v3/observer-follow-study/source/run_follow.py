"""Passive four-region origins along existing observer labels; native flow unchanged."""
import os,sys
os.environ.setdefault('OPENBLAS_NUM_THREADS','1');os.environ.setdefault('OMP_NUM_THREADS','1')
sys.dont_write_bytecode=True
import argparse,csv,hashlib,json,time,traceback
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'outputs/observer540-872'
sys.path.insert(0,str(ROOT/'work/pair25-origins'))
import run_origins as prior
previous=prior.previous
IDS=np.array([540,872]);PAIR=np.array([825,850]);RADIUS=.075
TAGS=prior.TAGS;REGIONS=['near540_only','near872_only','near_both','near_neither','later_source']
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def dump(p,x):previous.dump(p,x)
def csvout(p,records):
    with p.open('w',newline='',encoding='utf-8') as f:
        w=csv.DictWriter(f,list(records[0]));w.writeheader();w.writerows(records)
def stencil(grid,points):
    n=grid.shape[0];v=((points+.5)%1)*n;base=np.floor(v).astype(int);frac=v-base
    offsets=np.array([[i,j,k] for i in [0,1] for j in [0,1] for k in [0,1]])
    nodes=(base[:,None,:]+offsets[None,:,:])%n
    weights=np.prod(np.where(offsets[None,:,:],frac[:,None,:],1-frac[:,None,:]),axis=-1)
    corners=grid[nodes[...,0],nodes[...,1],nodes[...,2]]
    return (corners*weights[...,None]).sum(axis=1),nodes,weights,corners
class Origins:
    def __init__(self,solver,s,dt):
        self.solver=solver;self.native=solver.rhs;self.dt=dt;self.xyz=prior.grid_points(solver.n)
        d=prior.distances(self.xyz.reshape(-1,3),s['observer_X'][IDS])[:,:2].reshape((solver.n,)*3+(2,))
        a=d[...,0]<=RADIUS;b=d[...,1]<=RADIUS
        masks=[a&~b,b&~a,a&b,~a&~b]
        self.q=np.stack([np.where(m,s['g'][...,3],0.) for m in masks]+[np.zeros_like(s['g'][...,3])],axis=-1)
        self.qentry=self.q.copy();self.global_entry=self.q.mean(axis=(0,1,2))
        self.max_defect=0.;self.minimum=0.;self.source_integral=0.;self.k=[];self.sources=[]
        assert np.array_equal(self.q.sum(axis=-1),s['g'][...,3])
    def inspect(self,q,s):
        self.max_defect=max(self.max_defect,float(abs(q.sum(axis=-1)-s['g'][...,3]).max()))
        self.minimum=min(self.minimum,float(q.min()))
    def rhs(self,t,s,details=False):
        rates,stats,extra=self.native(t,s,details=True)
        q=self.q if not self.k else self.q+self.dt*self.k[0];assert len(self.k)<2
        self.inspect(q,s);dq=prior.transport(self.solver,q,s['g'][...,:3])
        source=self.solver.c.kappa*float(s['A'])*extra['kernel'];dq[...,4]+=source
        self.k.append(dq);self.sources.append(float(source.mean()))
        return (rates,stats,extra) if details else rates
    def step(self,t,s):
        self.k=[];self.sources=[];new=self.solver.step(t,s,self.dt);assert len(self.k)==2
        self.q=self.q+self.dt/2*(self.k[0]+self.k[1]);self.source_integral+=self.dt/2*sum(self.sources)
        self.inspect(self.q,new);return new
def pilot():
    OUT.mkdir(parents=True,exist_ok=True);solver,s,info,inputs,count=previous.load(TAGS[0]);dt=info['dt']
    native=solver.step(1.2,s,dt);marked=Origins(solver,s,dt);solver.rhs=marked.rhs;actual=marked.step(1.2,s)
    exact={k:native[k].tobytes()==actual[k].tobytes() for k in s}
    assert all(exact.values()) and marked.max_defect<=1e-12
    initial_partition=marked.qentry.sum(axis=-1);assert np.array_equal(initial_partition,s['g'][...,3])
    output={'passed':True,'all_native_one_step_arrays_equal':exact,'initial_partition_exact':True,'reconstruction_error':marked.max_defect,'minimum_component':marked.minimum,'code_sha256':sha(__file__),'original_solver_inputs_checked':count,'prior_transport_code_sha256':sha(prior.__file__),'scope':'Two pilot solver steps, no production results.'}
    dump(OUT/'pilot.json',output);print(json.dumps(output,indent=2),flush=True)
def run(tag):
    folder=OUT/tag;folder.mkdir(parents=True,exist_ok=True)
    if (folder/'status.json').exists():raise FileExistsError('Existing run; inspect before restart')
    pilot_record=json.loads((OUT/'pilot.json').read_text());assert pilot_record['passed'] and pilot_record['code_sha256']==sha(__file__)
    solver,s,info,inputs,count=previous.load(tag);n=info['n'];dt=info['dt'];steps=round(.1/dt);every=round(.002/dt)
    old=ROOT/'outputs/pair25-origins'/tag
    with np.load(old/'tracked-states.npz') as z:expected_positions=z['observer_positions']
    inputs.update({str(p.relative_to(ROOT)):sha(p) for p in [old/'tracked-states.npz',old/'exit-state.npz',ROOT/'outputs/pair25-origins/crossings.csv',Path(prior.__file__)]})
    save_steps=set(range(0,steps+1,every))
    with (ROOT/'outputs/pair25-origins/crossings.csv').open(newline='',encoding='utf-8') as f:
        for row in csv.DictReader(f):
            if row['run']==tag and row['view']=='union':
                save_steps.update(round((float(row[k])-1.2)/dt) for k in ['last_time_before','first_time_after'])
    origins=Origins(solver,s,dt);solver.rhs=origins.rhs;entry={k:v.copy() for k,v in s.items()}
    ep,ei=previous.payload_array(solver,s)
    positions=[];native_values=[];component_values=[];nodes_saved=[];weights_saved=[];g_corners=[];q_corners=[];memory=[];memory_ids=[]
    fields=[];field_steps=[];rows=[];windows=[];positions_exact=True;max_drift=0.;max_source=0.;start=time.monotonic()
    status={'run':tag,'status':'running','started_utc':previous.stamp(),'completed_steps':0,'total_steps':steps};dump(folder/'status.json',status)
    try:
        for j in range(steps+1):
            t=round(1.2+j*dt,12)
            if j:s=origins.step(round(1.2+(j-1)*dt,12),s)
            assert np.array_equal(s['observer_X'],expected_positions[j]),'Native observer path changed'
            p=s['observer_X'][IDS];position=s['observer_X'][[540,872,825,850]];positions.append(position.copy())
            native,nodes,weights,gc=stencil(s['g'],p);components,qn,qw,qc=stencil(origins.q,p)
            assert np.array_equal(nodes,qn) and np.array_equal(weights,qw)
            native_values.append(native);component_values.append(components);nodes_saved.append(nodes);weights_saved.append(weights);g_corners.append(gc);q_corners.append(qc)
            pa,keys=previous.payload_array(solver,s);assert np.array_equal(pa,ep) and np.array_equal(keys,ei)
            memory.append(pa);memory_ids.append(keys)
            totals=origins.q.mean(axis=(0,1,2));max_drift=max(max_drift,float(abs(totals[:4]-origins.global_entry[:4]).max()))
            max_source=max(max_source,abs(float(totals[4])-origins.source_integral),abs(float(totals[4])-float(s['ledger'][0]-entry['ledger'][0])))
            distances=prior.distances(p,s['observer_X'][PAIR])
            for k,identity in enumerate(IDS):
                row={'run':tag,'step':j,'time':t,'observer':int(identity),'distance_A':float(distances[k,0]),'distance_B':float(distances[k,1]),'distance_pair_union':float(distances[k,2]),'inside_pair_wide':bool(distances[k,2]<=.1)}
                row.update({name:float(native[k,i]) for i,name in enumerate(['u_x','u_y','u_z','C','theta'])})
                row.update({name:float(components[k,i]) for i,name in enumerate(REGIONS)})
                rows.append(row)
            if j in save_steps:
                fields.append(origins.q.copy());field_steps.append(j)
                d=prior.distances(origins.xyz.reshape(-1,3),p)[:,:2].reshape((n,)*3+(2,))
                for k,identity in enumerate(IDS):
                    mask=d[...,k]<=RADIUS;amount=np.where(mask[...,None],origins.q,0.).mean(axis=(0,1,2));old_components=[k,2]
                    original=origins.q[...,old_components].sum(axis=-1)
                    row={'run':tag,'step':j,'time':t,'observer':int(identity),'radius':RADIUS,'entry_original':float(origins.global_entry[old_components].sum()),'original_inside':float(amount[old_components].sum()),'original_elsewhere':float(np.where(~mask,original,0.).mean()),'other_origin_inside':float(amount[1-k]+amount[3]),'later_source_inside':float(amount[4]),'native_total_inside':float(np.where(mask,s['g'][...,3],0.).mean()),'window_cells':int(mask.sum()),'global_later_source':float(totals[4]),'source_integral':origins.source_integral}
                    row.update({name:float(amount[i]) for i,name in enumerate(REGIONS)})
                    windows.append(row)
            if j%10==0 or j==steps:
                status.update(completed_steps=j,model_time=t,elapsed_seconds=time.monotonic()-start,observed_utc=previous.stamp());dump(folder/'status.json',status)
                print(tag,j,'/',steps,flush=True)
        with np.load(old/'exit-state.npz') as z:exact={k:s[k].tobytes()==z[k].tobytes() for k in s}
        assert len(exact)==17
        np.savez_compressed(folder/'exit-state.npz',**s)
        np.savez_compressed(folder/'point-stencils.npz',positions=np.asarray(positions),native_values=np.asarray(native_values),origin_values=np.asarray(component_values),nodes=np.asarray(nodes_saved),weights=np.asarray(weights_saved),native_corners=np.asarray(g_corners),origin_corners=np.asarray(q_corners),observer_ids=IDS,dt=dt)
        np.savez_compressed(folder/'origin-fields.npz',steps=np.array(field_steps),fields=np.asarray(fields),initial=origins.qentry,region_names=np.array(REGIONS))
        np.savez_compressed(folder/'memory-payloads.npz',entry_payloads=ep,entry_ids=ei,payloads=np.asarray(memory),ids=np.asarray(memory_ids))
        csvout(folder/'point-history.csv',rows);csvout(folder/'window-history.csv',windows)
        criteria={'all_native_exit_arrays_equal':all(exact.values()),'all_native_observer_positions_equal':positions_exact,'context_reconstruction':origins.max_defect<=1e-12,'original_component_global_conservation':max_drift<=1e-12,'later_source_account':max_source<=1e-10,'nonnegative_components_within_roundoff':origins.minimum>=-1e-12,'full_shared_payloads_unchanged':True}
        result={'run':tag,'n':n,'dt':dt,'steps':steps,'start':1.2,'end':1.3,'observer_ids':IDS.tolist(),'radius':RADIUS,'regions':REGIONS,'saved_field_steps':field_steps,'criteria':criteria,'native_exit_array_equality':exact,'max_reconstruction_defect':origins.max_defect,'max_original_global_drift':max_drift,'max_source_account_error':max_source,'minimum_component':origins.minimum,'input_hashes':inputs,'code_sha256':sha(__file__),'shared_payload_comparisons':3*(steps+1),'elapsed_seconds':time.monotonic()-start}
        for path,digest in inputs.items():assert sha(ROOT/path)==digest
        dump(folder/'result.json',result);status.update(status='complete',completed_utc=previous.stamp(),criteria=criteria,elapsed_seconds=time.monotonic()-start);dump(folder/'status.json',status)
    except BaseException as error:
        status.update(status='failed',error=repr(error),traceback=traceback.format_exc());dump(folder/'status.json',status);raise
if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('action',choices=['pilot','run']);parser.add_argument('--tag',choices=TAGS);args=parser.parse_args()
    pilot() if args.action=='pilot' else run(args.tag)
