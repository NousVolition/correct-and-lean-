"""Resolve the activation-history demand along the original passive fluid paths."""
import os,sys,json,csv,time,hashlib,importlib.util
from pathlib import Path
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','MKL_NUM_THREADS'):os.environ[key]='1'
import numpy as np
ROOT=Path(__file__).resolve().parents[2];WORK=Path(__file__).resolve().parent
OUT=ROOT/'outputs/full-carrying-energy'
spec=importlib.util.spec_from_file_location('paths',ROOT/'work/unwrapped-history/follow_paths.py')
paths=importlib.util.module_from_spec(spec);spec.loader.exec_module(paths)

def main():
    started=time.monotonic();sizes=[12,16];grids=[];groups=[];offset=0
    for n in sizes:
        a=(np.arange(n)+.5)/n-.5;points=np.stack(np.meshgrid(a,a,a,indexing='ij'),-1).reshape(-1,3)
        grids.append(points);groups.append((n,slice(offset,offset+len(points))));offset+=len(points)
    X=np.vstack(grids);X0=X.copy();J=np.zeros((len(X),4));W=np.zeros(len(X));Jendpoint=np.zeros(len(X))
    with np.load(paths.SAVED/'fields.npz') as z:vel=z['stages'];uf=z['velocity'][-1]
    with np.load(ROOT/'work/unwrapped-history/force-history.npz') as z:force=z['stages'];ff=z['final']
    with np.load(WORK/'activation-stage-parts.npz') as z:parts=z['parts'];pf=z['final']
    wave=2j*np.pi*np.stack(np.meshgrid(paths.FREQ,paths.FREQ,paths.FREQ,indexing='ij'),-1)
    dt=.002;rows=[];oldB=oldX=None
    def evaluate(hu,hf,hparts,x):
        B=-hf;gradB=B[...,None]*wave
        fields=np.concatenate([hu,B[...,None],gradB,hparts],-1)
        v=paths.evaluate(fields,x);u=v[:,:3];b=v[:,3];transport=(v[:,4:7]*u).sum(-1)
        # sum(columns) = partial_t B + u.grad B, by construction.
        adv,diff,source,deform=v[:,7:].T
        full_parts=np.column_stack([deform,diff,source,adv+transport-deform])
        return u,b,full_parts
    for frame in range(601):
        hu=uf if frame==600 else vel[frame,0];hf=ff if frame==600 else force[frame,0]
        hp=pf if frame==600 else parts[frame,0]
        u,b,d=evaluate(hu,hf,hp,X);xi=X[:,0]-X0[:,0]
        if frame:Jendpoint+=.5*(oldX[:,0]+X[:,0]-2*X0[:,0])*(b-oldB)
        for n,sl in groups:
            row=dict(grid=n,frame=frame,time=dt*frame,work=float(W[sl].mean()),
                endpoint_release=float(-(b[sl]*xi[sl]).mean()),history_endpoint=float(Jendpoint[sl].mean()),
                history_rate_integral=float(J[sl].sum(axis=1).mean()),
                deformation=float(J[sl,0].mean()),diffusion=float(J[sl,1].mean()),
                source=float(J[sl,2].mean()),transport_discretization=float(J[sl,3].mean()))
            row['rate_vs_endpoint_difference']=row['history_rate_integral']-row['history_endpoint']
            row['energy_closure_defect']=row['work']-row['endpoint_release']-row['history_rate_integral']
            rows.append(row)
        if frame%100==0:print(json.dumps(dict(frame=frame,elapsed=time.monotonic()-started)),flush=True)
        if frame==600:break
        pred=X+dt*u;up,bp,dp=evaluate(vel[frame,1],force[frame,1],parts[frame,1],pred)
        J+=.5*dt*(xi[:,None]*d+(pred[:,0]-X0[:,0])[:,None]*dp)
        W-=.5*dt*(b*u[:,0]+bp*up[:,0])
        oldX=X.copy();oldB=b.copy();X+=.5*dt*(u+up)
    prior=json.loads((ROOT/'outputs/unwrapped-carrying-history/path-results-12-16.json').read_text())
    ends=[]
    for n,sl in groups:
        row=next(r.copy() for r in reversed(rows) if r['grid']==n)
        previous=next(r for r in prior['endpoints'] if r['sample']==f'volume_{n}')
        row['previous_work_match']=abs(row['work']-previous['path_work'])
        row['previous_history_match']=abs(row['history_endpoint']-previous['activation_history_correction'])
        assert max(row['previous_work_match'],row['previous_history_match'])<2e-15
        row['closure_defect_fraction_of_work']=row['energy_closure_defect']/row['work']
        ends.append(row)
    result=dict(endpoints=ends,quadrature='Original Heun stages, passive Fourier paths, endpoint-history comparison',
        columns=['deformation','diffusion','source','transport_discretization'],
        last_column_scope='Finite-volume transport/product-rule and Fourier-filter effects, plus differences between raw centered-gradient and resolved spatial activation transport. It is retained, not interpreted as physical storage.',
        elapsed_seconds=time.monotonic()-started,script_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
    (OUT/'activation-results.json').write_text(json.dumps(result,indent=2)+'\n')
    with (OUT/'activation-history.csv').open('w',newline='') as f:
        w=csv.DictWriter(f,list(rows[0]));w.writeheader();w.writerows(rows)
    print(json.dumps(result,indent=2),flush=True)
if __name__=='__main__':main()
