"""Floating-point conditioning diagnostic. No validated error bounds are claimed."""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
os.environ['OMP_NUM_THREADS']='1'
import argparse,hashlib,json,platform,time
from datetime import datetime,timezone
from pathlib import Path
import numpy as np
import scipy
from scipy.integrate import solve_ivp

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--study-dir',type=Path,
        default=Path(__file__).resolve().parents[2]/'threshold-one-window-study')
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();study=args.study_dir
    meta=json.loads((study/'snapshots.json').read_text())
    with np.load(study/'snapshots.npz',allow_pickle=False) as z:fields,pairs=z['omega'],z['pairs']
    freq=np.arange(-5,6)
    k=np.stack(np.meshgrid(freq,freq,freq,indexing='ij'),axis=-1).reshape(-1,3)
    report={'kind':'Numerical conditioning diagnostic, not validated bounds',
        'generated_at_utc':datetime.now(timezone.utc).isoformat(),
        'versions':{'numpy':np.__version__,'scipy':scipy.__version__,'python':platform.python_version()},
        'source_hashes':{name:hashlib.sha256((study/name).read_bytes()).hexdigest()
            for name in ('snapshots.npz','snapshots.json')},
        'solver':{'method':'DOP853','rtol':2e-12,'atol':2e-14,'max_step':.01},'results':[]}
    started=time.perf_counter()
    for row in meta:
        if not row['label'].startswith('event-'):continue
        index=row['index'];coef=fields[index].reshape(-1,3)
        deriv=coef[:,:,None]*(2j*np.pi*k[:,None,:])
        allcoef=np.concatenate([coef,deriv.reshape(-1,9)],axis=1)
        for direction in (1,-1):
            min_omega=float('inf')
            def rhs(t,y):
                nonlocal min_omega
                phase=np.exp(2j*np.pi*(k@(y[:3]+.5)))
                a=(phase@allcoef).real
                w=a[:3];jac=a[3:].reshape(3,3);norm=np.linalg.norm(w)
                min_omega=min(min_omega,norm)
                n=w/norm;J=direction*((np.eye(3)-np.outer(n,n))@jac)/norm
                return np.r_[direction*n,(J@y[3:12].reshape(3,3)).ravel(),
                    np.linalg.norm(J,2),np.linalg.eigvalsh((J+J.T)/2)[-1]]
            y0=np.r_[pairs[index,0],np.eye(3).ravel(),0.,0.]
            sol=solve_ivp(rhs,(0,3),y0,method='DOP853',rtol=2e-12,atol=2e-14,
                max_step=.01,dense_output=True)
            if not sol.success:raise RuntimeError(sol.message)
            for length in (.75,1.5,3.):
                y=sol.sol(length);singular=np.linalg.svd(y[3:12].reshape(3,3),compute_uv=False)
                report['results'].append({'label':row['label'],'direction':direction,'length':length,
                    'minimum_over_rhs_calls_for_full_length3':min_omega,
                    'integrated_jacobian_norm':float(y[12]),
                    'integrated_logarithmic_norm':float(y[13]),
                    'fundamental_singular_values':singular.tolist(),'sampled_end':y[:3].tolist()})
            print(json.dumps({'label':row['label'],'direction':direction,'status':'numerical_solve_finished'}),flush=True)
    report['elapsed_seconds']=time.perf_counter()-started
    args.output.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')

if __name__=='__main__':main()
