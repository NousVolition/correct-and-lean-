"""Read-only membership/geometry and energy recount from the saved Pair 25 states."""
import os,sys,json,csv,hashlib,importlib.util
from pathlib import Path
from datetime import datetime,timezone
for k in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','MKL_NUM_THREADS'):os.environ[k]='1'
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'outputs/full-carrying-energy'
LOCAL=Path(r'$USER_HOME\Documents\Codex\2026-11-09\please-go-through-correct-and-lean')
REPO=Path(r'$USER_HOME\Documents\Codex\2026-11-11\ang-mills-as-an-instance-the\work\github-publication')
DATA=REPO/'research/hug-v3/pair-origin-lean/source-data'
sys.path[:0]=[r'$USER_HOME\Documents\Codex\2026-10-28\new-chat-4\hug-v3-coexistence-lean\.runtime',str(LOCAL/'work/fluid-convergence')]
import numpy as np
from run_study import make_solver
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def load(p):
    with np.load(p) as z:return {k:z[k].copy() for k in z.files}

def main():
    inputs={};runs=[]
    for tag in ['n40_dt0p0005','n48_dt0p0005','n48_dt0p00025']:
        folder=LOCAL/'outputs/pair25-origins'/tag
        entrypath=LOCAL/'outputs/pair25-retention'/tag/'entry-state.npz'
        paths=[folder/'tracked-states.npz',folder/'exit-state.npz',entrypath,DATA/(tag+'-membership.npz'),DATA/(tag+'-result.json')]
        inputs.update({str(p):sha(p) for p in paths})
        tracked=load(paths[0]);entry=load(entrypath);exitstate=load(paths[1]);membership=load(paths[3])
        assert len(entry)==len(exitstate)==17
        assert np.array_equal(tracked['times'],membership['times'])
        centers=tracked['observer_positions'][:,[825,850]]
        bit_count=0;nearest=float('inf');summaries=[]
        for pop,key in [('observer','observer_positions'),('material','material_positions')]:
            ids=membership[pop+'_ids'];xyz=tracked[key][:,ids]
            delta=xyz[:,:,None,:]-centers[:,None,:,:];delta-=np.rint(delta)
            dist=np.sqrt((delta*delta).sum(-1));dist=np.concatenate([dist,dist.min(axis=-1,keepdims=True)],-1)
            computed=dist[:,:,None,:]<=membership['radii'][None,None,:,None]
            assert np.array_equal(computed,membership[pop]);bit_count+=computed.size
            nearest=min(nearest,float(abs(dist[:,:,None,:]-membership['radii'][None,None,:,None]).min()))
            primary=computed[:,:,1,2];wide=computed[:,:,2,2]
            summaries.append(dict(population=pop,primary_entry=int(primary[0].sum()),primary_continuous_sampled=int(primary.all(axis=0).sum()),
                wide_departing=ids[wide[0]&~wide[-1]].tolist(),wide_arriving=ids[~wide[0]&wide[-1]].tolist()))
        assert np.array_equal(tracked['material_F'][0],entry['F']) and np.array_equal(tracked['material_F'][-1],exitstate['F'])
        assert np.array_equal(tracked['material_m'][0],entry['m']) and np.array_equal(tracked['material_m'][-1],exitstate['m'])
        info=json.loads(paths[4].read_text());solver,case,extra=make_solver(info['n'])
        # No RHS or time step is called. All energies are independently
        # evaluated from the existing constitutive law and saved arrays.
        energies=[]
        for state in [entry,exitstate]:
            base=solver.material(state['F'],state['m'],np.zeros_like(state['F']))[0]
            fabric=solver.fabric.constitutive(state['F'],state['b'])[0]
            W=base+fabric
            pop=membership['material'][0,:,1,2]
            energies.append(dict(kinetic=float(.5*np.mean((state['g'][...,:3]**2).sum(-1))),
                stored=float(solver.V@W),heat=float(state['g'][...,4].mean()),
                initial_member_stored=float(solver.V[pop]@W[pop]),
                AS=float(state['ledger'][1]),breathing=float(state['breathing_work']),write=float(state['write_work'])))
        change={k:energies[1][k]-energies[0][k] for k in energies[0]}
        change['physical_total']=change['kinetic']+change['stored']+change['heat']
        change['balance_residual']=change['physical_total']-change['AS']-change['breathing']-change['write']
        assert abs(change['balance_residual'])<1e-8
        runs.append(dict(run=tag,start=1.2,end=1.3,threshold=solver.c.threshold,membership_bits_recomputed=bit_count,
            populations=summaries,nearest_boundary=nearest,
            all_material_F_changed=bool(np.all(np.max(abs(tracked['material_F'][-1]-tracked['material_F'][0]),axis=(1,2))>0)),
            all_material_m_changed=bool(np.all(np.max(abs(tracked['material_m'][-1]-tracked['material_m'][0]),axis=(1,2))>0)),
            min_m_step_change=float(np.diff(tracked['material_m'],axis=0).min()),energy_endpoints=energies,energy_changes=change))
    spec=importlib.util.spec_from_file_location('certificate',DATA.parent/'check_certificate.py')
    cert=importlib.util.module_from_spec(spec);spec.loader.exec_module(cert)
    certificate=cert.check()
    assert all(sha(Path(p))==h for p,h in inputs.items())
    modules={m.__file__ for m in list(sys.modules.values()) if getattr(m,'__file__',None) and Path(m.__file__).suffix=='.py' and ('hug-v3' in m.__file__ or 'fluid-convergence' in m.__file__)}
    result=dict(checked_utc=datetime.now(timezone.utc).isoformat(),status='PASS',read_only=True,new_solver_steps=0,
        geometry_source='Original local tracked arrays; exact comparison to the newly published full membership files',
        source_certificate=certificate,runs=runs,read_inputs_unchanged=True,input_sha256=inputs,
        energy_formula_sources={p:sha(Path(p)) for p in sorted(modules)},
        limitations=['No between-step crossing proof','Window members are not a complete physical inventory','This is threshold .015, t=1.2..1.3, separate from the threshold-1 activation gap','Energy endpoint arithmetic is floating point, not a new Lean trajectory proof'])
    (OUT/'pair25-saved-check.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k not in ('input_sha256','energy_formula_sources')},indent=2))
if __name__=='__main__':main()
