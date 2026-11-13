"""Passive unwrapped paths from saved stages; no solver state is evolved here."""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','MKL_NUM_THREADS'):os.environ[key]='1'
import sys,json,csv,time,hashlib
from pathlib import Path
from datetime import datetime,timezone
sys.dont_write_bytecode=True
import numpy as np
ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'work/unwrapped-history'
OUT=ROOT/'outputs/unwrapped-carrying-history'
SAVED=Path(r'$USER_HOME\Documents\Codex\2026-11-10\lo\work\threshold-one\threshold-1')
FREQ=np.arange(-5,6)
def evaluate(coef,points):
    """The same tensor-product Fourier extension used by native water labels."""
    result=np.empty((len(points),coef.shape[-1]))
    for start in range(0,len(points),1024):
        p=points[start:start+1024]
        phase=np.exp(2j*np.pi*((p+.5)%1.)[:,:,None]*FREQ)
        xsum=np.tensordot(phase[:,0],coef,axes=(1,0))
        xysum=np.einsum('pj,pjkc->pkc',phase[:,1],xsum)
        result[start:start+len(p)]=np.einsum('pk,pkc->pc',phase[:,2],xysum).real
    return result
def main():
    start=time.monotonic();sizes=[int(n) for n in sys.argv[1:]] or [12,16]
    with np.load(SAVED/'fields.npz',allow_pickle=False) as z:stages=z['stages'];finalu=z['velocity'][-1];pairref=z['points']
    with np.load(WORK/'force-history.npz',allow_pickle=False) as z:forces=z['stages'];finalf=z['final']
    with np.load(SAVED/'state-0000.npz',allow_pickle=False) as z:tags=z['observer_X'].copy()
    grids=[];groups=[];offset=0
    for n in sizes:
        a=(np.arange(n)+.5)/n-.5
        grid=np.stack(np.meshgrid(a,a,a,indexing='ij'),-1).reshape(-1,3)
        grids.append(grid);groups.append((f'volume_{n}',slice(offset,offset+len(grid))));offset+=len(grid)
    tag_slice=slice(offset,offset+len(tags));groups.append(('original_801',slice(offset,offset+801)))
    groups.append(('tag_A',slice(offset+801,offset+802)));groups.append(('tag_B',slice(offset+802,offset+803)))
    X=np.vstack(grids+[tags]);X0=X.copy();W=np.zeros(len(X));WT=np.zeros(len(X));J=np.zeros(len(X))
    oldX=oldf=None;rows=[];max_tag_error=0.;checkpoint_errors=[];dt=.002
    checkpoints={int(p.stem.split('-')[1]):p for p in SAVED.glob('state-*.npz')}
    readings=json.loads((SAVED/'particle-readings.json').read_text());ledger=np.array([r['threshold_force_work'] for r in readings])
    for frame in range(601):
        hu=finalu if frame==600 else stages[frame,0]
        hf=finalf if frame==600 else forces[frame,0]
        local=evaluate(np.concatenate([hu,hf[...,None]],axis=-1),X)
        v,f=local[:,:3],local[:,3]
        disp=X[:,0]-X0[:,0]
        if frame:
            WT += .5*(oldf+f)*(X[:,0]-oldX[:,0])
            J -= .5*(oldX[:,0]+X[:,0]-2*X0[:,0])*(f-oldf)
        potential=-f*disp
        assert np.max(abs(WT+potential-J))<1e-13
        max_tag_error=max(max_tag_error,float(np.max(abs(X[-2:]-pairref[frame]))))
        if frame in checkpoints:
            with np.load(checkpoints[frame],allow_pickle=False) as z:ref=z['observer_X']
            err=float(np.max(abs(X[tag_slice]-ref)))
            assert err<2e-13,(frame,err)
            checkpoint_errors.append(dict(frame=frame,max_error=err))
        for name,sl in groups:
            row=dict(sample=name,frame=frame,time=dt*frame,count=sl.stop-sl.start,
                path_work=float(W[sl].mean()),endpoint_trapezoid_work=float(WT[sl].mean()),
                endpoint_height_energy=float(potential[sl].mean()),activation_history_correction=float(J[sl].mean()),
                work_minus_ledger=float(W[sl].mean()-ledger[frame]) if name.startswith('volume_') else None,mean_unwrapped_displacement=float(disp[sl].mean()),
                instantaneous_path_power=float(np.mean(f[sl]*v[sl,0])),
                summation_by_parts_residual=float((WT[sl]+potential[sl]-J[sl]).mean()))
            rows.append(row)
        if frame%100==0:
            print(json.dumps(dict(phase='following',grids=sizes,frame=frame,elapsed_seconds=round(time.monotonic()-start,2),max_original_path_error=max_tag_error)),flush=True)
        if frame==600:break
        pred=X+dt*v
        localp=evaluate(np.concatenate([stages[frame,1],forces[frame,1,...,None]],axis=-1),pred)
        W += .5*dt*(f*v[:,0]+localp[:,3]*localp[:,0])
        oldX=X.copy();oldf=f.copy()
        X += .5*dt*(v+localp[:,:3])
    suffix='-'.join(str(n) for n in sizes)
    with (OUT/f'path-history-{suffix}.csv').open('w',newline='') as f:
        writer=csv.DictWriter(f,fieldnames=list(rows[0]));writer.writeheader();writer.writerows(rows)
    endpoints=[]
    for name,sl in groups:
        row=next(r.copy() for r in reversed(rows) if r['sample']==name)
        row.update(relative_work_error=(row['path_work']-ledger[-1])/ledger[-1] if name.startswith('volume_') else None,
            end_winding_changed_particles=int(np.sum(np.any(np.floor(X[sl]+.5)!=np.floor(X0[sl]+.5),axis=1))),
            max_displacement=float(np.max(np.linalg.norm(X[sl]-X0[sl],axis=1))),
            displacement_min=(X[sl]-X0[sl]).min(axis=0).tolist(),displacement_max=(X[sl]-X0[sl]).max(axis=0).tolist())
        endpoints.append(row)
    np.savez_compressed(WORK/f'path-endpoints-{suffix}.npz',initial=X0,final=X,path_work=W,endpoint_trapezoid_work=WT,history_correction=J,endpoint_height_energy=potential)
    result=dict(checked_utc=datetime.now(timezone.utc).isoformat(),method='Passive native Heun water trajectories; Fourier-resolved unprojected AS force, fixed uniform initial volume labels; same saved velocity stages and reconstructed force stages',grids=sizes,dt=dt,initial_fluid_density=1,domain_volume=1,reference_ledger=float(ledger[-1]),endpoints=endpoints,max_original_pair_error=max_tag_error,max_original_803_path_error=max(x['max_error'] for x in checkpoint_errors),original_path_checkpoint_count=len(checkpoint_errors),elapsed_seconds=time.monotonic()-start)
    (OUT/f'path-results-{suffix}.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2),flush=True)
if __name__=='__main__':main()
