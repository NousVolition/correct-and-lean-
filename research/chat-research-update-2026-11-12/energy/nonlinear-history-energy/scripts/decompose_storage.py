"""Read-only separation of the nonlinear stored energies already in the solver."""
import os,sys,json,csv,hashlib,importlib.util
from pathlib import Path
from datetime import datetime,timezone
for k in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','MKL_NUM_THREADS'):os.environ[k]='1'
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'outputs/nonlinear-history-energy'
spec=importlib.util.spec_from_file_location('diag',ROOT/'work/full-carrying/diagnose_stages.py')
d=importlib.util.module_from_spec(spec);spec.loader.exec_module(d);np=d.np
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()

def main():
    case=d.old.preflight.approve('threshold_1')
    with (d.old.INPUT/'study/marker-seeds.csv').open() as f:trail=d.Trail(list(csv.DictReader(f)))
    solver=d.ComparisonSolver(d.Config(**case['config']),.5,.6,trail);c=solver.c
    # Evaluating material formulas needs no step or grid RHS.
    paths=sorted(d.old.SAVED.glob('state-*.npz'))
    history=ROOT/'outputs/full-carrying-energy/activation-history.csv'
    with history.open(newline='') as f:target={int(r['frame']):r for r in csv.DictReader(f) if r['grid']=='16'}
    sources=[d.old.INPUT/'declared-source/continuum.py',d.old.INPUT/'declared-source/structural_hug.py',d.old.INPUT/'declared-source/equation_register.csv']
    hashes={str(p):sha(p) for p in paths+sources+[history]};rows=[]
    max_match=max_power_error=max_stress_error=max_brate_error=0.
    for p in paths:
        frame=int(p.stem.split('-')[1]);s=d.old.load(p);F=s['F'];m=s['m'];b=s['b']
        B=F@F.transpose(0,2,1)
        base=c.G0/2*(np.trace(B,axis1=1,axis2=2)-3)
        directions=np.einsum('pij,kj->pki',F,solver.directions)
        strain=((directions*directions).sum(-1)-1)/2
        expression=-np.expm1(-m/c.mscale)
        directional=.5*np.sum(c.Gm*expression*solver.direction_weights[None,:,None]*strain[:,:,None]**2,axis=(1,2))
        e=solver.fabric.local_strain(F);weights=solver.fabric.weight
        micro=.5*c.micro_k*(e-b)**2
        wells=c.well_height/4*((b/c.rest_amplitude)**2-1)**2
        nativeW,nativeTau,heat,bd=solver.fabric.constitutive(F,b)
        nativebase=solver.material(F,m,np.zeros_like(F))[0]
        total=float(solver.V@(base+directional)+weights@(micro+wells))
        native=float(solver.V@(nativebase+nativeW))
        max_match=max(max_match,abs(total-native))
        # Nonlinear energy gradients and their full relaxation heat, retaining
        # the cross term in (micro_gradient + well_gradient)^2.
        Ymicro=c.micro_k*(b-e)
        Ywell=c.well_height*b/c.rest_amplitude**2*((b/c.rest_amplitude)**2-1)
        Y=Ymicro+Ywell
        candidate_bd=-c.fabric_mobility*Y
        relaxation=float(weights@(c.fabric_mobility*Y*Y))
        max_brate_error=max(max_brate_error,float(abs(candidate_bd-bd).max()))
        max_power_error=max(max_power_error,abs(float(weights@(Y*bd))+float(solver.V@heat)))
        # A deterministic traceless virtual strain rate tests the contraction
        # of the actual F-based stress, independently of grid interpolation.
        L=np.array([[.2,.1,0],[-.07,-.05,.03],[.02,0,-.15]])
        Fdot=np.einsum('ij,pjk->pik',L,F)
        edot=np.sum(F*Fdot,axis=1)[solver.fabric.point,solver.fabric.axis]
        stress_power=float(weights@(c.micro_k*(e-b)*edot))
        native_power=float(np.sum(solver.V[:,None,None]*nativeTau*L))
        max_stress_error=max(max_stress_error,abs(stress_power-native_power))
        r=target[frame]
        rows.append(dict(frame=frame,time=.002*frame,neo_hookean=float(solver.V@base),
            exponential_directional=float(solver.V@directional),fabric_microstrain=float(weights@micro),
            fabric_quartic_wells=float(weights@wells),total_stored=total,native_stored=native,
            fabric_relaxation_power=relaxation,
            microstrain_relaxation_rate=float(weights@(Ymicro*bd)),well_relaxation_rate=float(weights@(Ywell*bd)),
            required_history=float(r['history_endpoint'])))
    assert max_match<1e-18 and max_power_error<1e-18 and max_stress_error<1e-16 and max_brate_error==0
    first,last=rows[0],rows[-1]
    energies=['neo_hookean','exponential_directional','fabric_microstrain','fabric_quartic_wells','total_stored']
    comparison={k:dict(initial=first[k],final=last[k],change=last[k]-first[k]) for k in energies}
    previous=json.loads((ROOT/'outputs/full-carrying-energy/stage-verification.json').read_text())
    # Reuse the 1200-stage integrated heat already verified, not a new simulation.
    inherited_relaxation=previous['integrated_rates']['release_to_heat']
    assert all(sha(p)==h for p,h in hashes.items())
    with (OUT/'nonlinear-storage-history.csv').open('w',newline='') as f:
        w=csv.DictWriter(f,list(rows[0]));w.writeheader();w.writerows(rows)
    result=dict(checked_utc=datetime.now(timezone.utc).isoformat(),read_only=True,new_solver_steps=0,saved_states=62,
        decomposed_energies=comparison,required_net_extra_store_change=-last['required_history'],
        max_decomposition_vs_native_error=max_match,max_nonlinear_relaxation_heat_defect=max_power_error,
        max_virtual_stress_contraction_defect=max_stress_error,max_fabric_rate_difference=max_brate_error,
        inherited_1200_stage_fabric_heat_release=inherited_relaxation,
        inherited_evidence=dict(source=str(ROOT/'outputs/full-carrying-energy/stage-verification.json'),sha256=sha(ROOT/'outputs/full-carrying-energy/stage-verification.json'),
            scope='Previous verified full replay, not rerun in this task'),
        source_files_and_saved_states_unchanged=True,input_sha256=hashes,script_sha256=sha(Path(__file__)),
        limitations=['Known nonlinear constitutive energies only; no universal exclusion of other full-history functionals',
            'Separate component relaxation rates can have either sign; only their total loss is the nonnegative heat production',
            'Event writes were already included in saved endpoint states and their own recorded work',
            'The material law is a declared later implementation, not an original corpus energy law'])
    (OUT/'nonlinear-storage-check.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k!='input_sha256'},indent=2))
if __name__=='__main__':main()
