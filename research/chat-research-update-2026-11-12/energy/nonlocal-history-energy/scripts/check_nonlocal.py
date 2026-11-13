"""Read-only nonlocal energy-transfer diagnostics at saved states. No stepping."""
import os,sys,json,csv,hashlib,importlib.util,time
from pathlib import Path
from datetime import datetime,timezone
for k in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','MKL_NUM_THREADS'):os.environ[k]='1'
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'outputs/nonlocal-history-energy'
spec=importlib.util.spec_from_file_location('diag',ROOT/'work/full-carrying/diagnose_stages.py')
d=importlib.util.module_from_spec(spec);spec.loader.exec_module(d);np=d.np
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()

def main():
    case=d.old.preflight.approve('threshold_1')
    with (d.old.INPUT/'study/marker-seeds.csv').open() as f:trail=d.Trail(list(csv.DictReader(f)))
    solver=d.ComparisonSolver(d.Config(**case['config']),.5,.6,trail);solver.initial()
    paths=sorted(d.old.SAVED.glob('state-*.npz'))
    sources=[d.old.INPUT/'declared-source'/name for name in ['continuum.py','structural_hug.py','social_base.py']]
    hashes={str(p):sha(p) for p in paths+sources};rows=[];started=time.monotonic()
    for p in paths:
        s=d.old.load(p);frame=int(p.stem.split('-')[1]);t=frame*.002
        rates,st,ex=solver.rhs(t,s,details=True)
        M,R=ex['M'],ex['R'];V=solver.V;u=s['g'][...,:3];W=ex['W']
        pu=M@u.reshape(-1,3)
        stored_grid=(M.T@(V*W)/solver.dv).reshape(s['g'].shape[:3])
        _,_,Y,_,_=solver.material(s['F'],s['m'],ex['L'])
        _,_,release,_=solver.extra_constitutive(s,ex['L'])
        Wdot=np.sum(ex['tau']*ex['L'],axis=(1,2))+np.sum(Y*rates['m'],axis=(1,2))-release
        stored_dot=(M.T@(V*Wdot)/solver.dv).reshape(stored_grid.shape)-solver.divergence(
            (M.T@(V[:,None]*W[:,None]*pu)/solver.dv).reshape(u.shape))
        Edot=np.sum(u*rates['g'][...,:3],-1)+rates['g'][...,4]+stored_dot
        breath=np.sum(u*solver.breath_at(t),-1)
        # Deliberately omit AS from this diagnostic residual, but keep its
        # original force in rates. Reconstruct only a passive periodic flux.
        residual=solver.filter(Edot)+solver.divergence(ex['SE_local'])-solver.filter(breath)
        rh=solver.hat(residual);den=np.where(solver.k2==0,1,solver.k2)
        correction=solver.real(1j*solver.k*(rh/den)[...,None])
        divcorrection=solver.divergence(correction)
        after=residual+divcorrection;power=float(rates['ledger'][1])
        row=dict(frame=frame,time=t,AS_power=power,
            source_kernel_mean=float(ex['kernel'].mean()),source_weights_sum=float(ex['social']['source_weights'].sum()),
            interpolation_row_sum_error=float(abs(M.sum(axis=1)-1).max()),thermal_row_sum_error=float(abs(R.sum(axis=1)-1).max()),
            spread_energy=float(stored_grid.mean()),parcel_energy=float(V@W),
            spread_energy_defect=float(stored_grid.mean()-V@W),
            stress_adjoint_power_defect=st['elastic_power_residual'],write_adjoint_power_defect=st['write_power_residual'],
            explicit_pairgrid_max=float(abs(ex['pairgrid']).max()),
            native_nonlocal_flux_divergence_mean=float(solver.divergence(ex['interaction_flux']).mean()),
            diagnostic_residual_mean_before=float(residual.mean()),diagnostic_residual_mean_after=float(after.mean()),
            diagnostic_flux_divergence_mean=float(divcorrection.mean()),
            residual_after_minus_its_mean_max=float(abs(after-residual.mean()).max()),
            residual_mean_minus_AS=float(residual.mean()-power))
        rows.append(row)
        if len(rows)%15==0:print(json.dumps(dict(states=len(rows),elapsed=time.monotonic()-started)),flush=True)
    maxima={k:max(abs(r[k]) for r in rows) for k in ['interpolation_row_sum_error','thermal_row_sum_error',
        'spread_energy_defect','stress_adjoint_power_defect','write_adjoint_power_defect','explicit_pairgrid_max',
        'native_nonlocal_flux_divergence_mean','diagnostic_flux_divergence_mean','residual_after_minus_its_mean_max','residual_mean_minus_AS']}
    assert all(maxima[k]<1e-11 for k in maxima)
    assert max(abs(r['source_kernel_mean']-1) for r in rows)<1e-12
    assert max(abs(r['source_weights_sum']-1) for r in rows)<1e-12
    assert abs(rows[-1]['diagnostic_residual_mean_after'])>1e-6
    assert all(sha(p)==h for p,h in hashes.items())
    with (OUT/'nonlocal-checkpoints.csv').open('w',newline='') as f:
        w=csv.DictWriter(f,list(rows[0]));w.writeheader();w.writerows(rows)
    result=dict(checked_utc=datetime.now(timezone.utc).isoformat(),read_only=True,new_solver_steps=0,saved_states=len(rows),
        maxima=maxima,final=rows[-1],
        diagnostic='Rebuild a periodic nonlocal redistribution flux after omitting AS only from the diagnostic energy residual; the physical AS force and all equations stay unchanged.',
        conclusion='The corrected local residual is spatially constant at its original nonzero mean. The nonlocal flux cannot pay a global energy deficit.',
        sources_and_states_unchanged=True,input_sha256=hashes,script_sha256=sha(Path(__file__)),elapsed_seconds=time.monotonic()-started,
        limitations=['Rules out redistribution flux as the missing global supply, not all nonlocal stored-energy functionals',
            'Original closed/periodic domain is essential to the zero-net-flux conclusion',
            'The old upper-half paired context law is absent in this run; social/history coupling remains active',
            'These numerical checks are not a continuum theorem'])
    (OUT/'nonlocal-check.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k!='input_sha256'},indent=2))
if __name__=='__main__':main()
