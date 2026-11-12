"""Continue saved native states and audit finite retention; no new physical law."""
import os, sys
os.environ.setdefault("OPENBLAS_NUM_THREADS","1")
os.environ.setdefault("OMP_NUM_THREADS","1")
sys.dont_write_bytecode=True
import argparse, csv, hashlib, json, time, traceback
from pathlib import Path
from datetime import datetime, timezone
import numpy as np

ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/"work/pair25-retention"
OUT=ROOT/"outputs/pair25-retention"
OLD=ROOT/"outputs/fluid-finer-grid"
sys.path.insert(0,str(ROOT/"work/fluid-convergence"))
from run_study import make_solver

START=1.2
END=1.3
PAIR_INDICES=np.array([825,850])
CATEGORIES={
 "g":"fluid grid: velocity, C and theta",
 "X":"shared material positions", "F":"shared material deformation",
 "m":"shared directional material memory", "b":"shared bistable memory material",
 "A":"system context accumulator", "ledger":"system exchange accounts",
 "expression":"actor state", "context":"actor state", "norm":"actor state",
 "logradius":"actor relation state", "relation":"actor relation state",
 "responses":"actor relation state", "association":"actor relation state",
 "write_work":"system writing-work account",
 "observer_X":"passive observer positions only", "breathing_work":"system added-drive work account",
}

def stamp(): return datetime.now(timezone.utc).isoformat()
def digest(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def dump(p,obj):
    temp=p.with_suffix(p.suffix+".tmp")
    temp.write_text(json.dumps(obj,indent=2,allow_nan=False)+"\n",encoding="utf-8")
    temp.replace(p)
def sample(grid,points):
    """Periodic trilinear value and its exact piecewise spatial gradient."""
    n=grid.shape[0]; p=np.asarray(points); v=((p+.5)%1)*n
    base=np.floor(v).astype(int); frac=v-base
    tail=grid.shape[3:]
    value=np.zeros((len(p),)+tail)
    grad=np.zeros(value.shape+(3,))
    for i in (0,1):
      for j in (0,1):
       for k in (0,1):
        corners=np.array([i,j,k]); index=(base+corners)%n
        weights=np.where(corners,frac,1-frac)
        data=grid[tuple(index.T)]
        value+=data*np.prod(weights,axis=1).reshape((len(p),)+(1,)*len(tail))
        for axis in range(3):
            w=n*(1 if corners[axis] else -1)*np.prod(np.delete(weights,axis,1),axis=1)
            grad[...,axis]+=data*w.reshape((len(p),)+(1,)*len(tail))
    return value,grad

def verify_inputs(tag):
    inventory=json.loads((OLD/"OUTPUT-SHA256.json").read_text())
    inputs={}
    for name in ["final-state.npz","summary.json","events.json"]:
        rel=tag+"/"+name; p=OLD/rel
        inputs[str(p.relative_to(ROOT))]=digest(p)
        assert inputs[str(p.relative_to(ROOT))]==inventory[rel],rel
    original=json.loads((ROOT/"outputs/fluid-convergence/input-sha256.json").read_text())
    for path,h in original.items(): assert digest(path)==h,path
    return inputs,len(original)

def load(tag):
    inputs,count=verify_inputs(tag)
    info=json.loads((OLD/tag/"summary.json").read_text())
    solver,case,extra=make_solver(info["n"])
    solver.initial()  # Re-establish immutable actor baselines, not the evolving state.
    with np.load(OLD/tag/"final-state.npz") as z: s={k:z[k] for k in z.files}
    assert set(s)==set(CATEGORIES)
    assert s["observer_X"].shape==(926,3)
    assert s["X"].shape==(384,3)
    assert np.isfinite(s["g"]).all()
    assert not [e for e in case["events"] if START<e["end"]<=END]
    return solver,s,info,inputs,count

class Audit:
    def __init__(self,solver,entry):
        self.solver=solver;self.native=solver.rhs
        self.entry=entry
        self.stage_terms=[]
        self.minimum_memory_rate=float("inf")
        self.minimum_memory_increase=0.
        self.minimum_read_margin=float("inf")
        self.sign_flips=0
        self.stages=0
        self.component_error=0.
        self.entry_sign=entry["b"]>0
    def inspect(self,s):
        if not all(np.isfinite(v).all() for v in s.values()):raise FloatingPointError("Nonfinite state")
        assert s["observer_X"].shape==(926,3)
        self.minimum_memory_increase=min(self.minimum_memory_increase,float((s["m"]-self.entry["m"]).min()))
        self.minimum_read_margin=min(self.minimum_read_margin,float(abs(s["b"]).min()))
        self.sign_flips=max(self.sign_flips,int(np.count_nonzero((s["b"]>0)!=self.entry_sign)))
    def rhs(self,t,s,details=False):
        rates,stats,extra=self.native(t,s,details=True)
        self.inspect(s)
        self.minimum_memory_rate=min(self.minimum_memory_rate,float(rates["m"].min()))
        c=self.solver.c; n=self.solver.n
        p=s["observer_X"][PAIR_INDICES]
        vals,grad=sample(s["g"],p)
        velocity=rates["observer_X"][PAIR_INDICES]
        C=s["g"][...,3]
        diff=c.diffusion*n*n*sum(np.roll(C,1,axis=a)+np.roll(C,-1,axis=a)-2*C for a in range(3))
        source=c.kappa*float(s["A"])*extra["kernel"]
        advC=self.solver.context_transport(C,s["g"][...,:3])-diff
        cond=self.solver.filter(-self.solver.divergence(extra["heatflux"]))
        production=self.solver.filter(extra["heat_rate"])
        advT=self.solver.filter(-self.solver.divergence(s["g"][...,:3]*s["g"][...,4,None]))
        split=np.stack([diff,source,advC,cond,production,advT],axis=-1)
        local,_=sample(split,p)
        local[:,2]+=np.sum(grad[:,3]*velocity,axis=1)
        local[:,5]+=np.sum(grad[:,4]*velocity,axis=1)
        actual,_=sample(rates["g"][...,3:5],p)
        actual+=np.einsum("pcj,pj->pc",grad[:,3:5],velocity)
        error=max(float(abs(actual[:,0]-local[:,:3].sum(axis=1)).max()),
                  float(abs(actual[:,1]-local[:,3:].sum(axis=1)).max()))
        self.component_error=max(self.component_error,error)
        if error>1e-12:raise AssertionError("Rate decomposition mismatch")
        self.stage_terms.append(local)
        self.stages+=1
        return (rates,stats,extra) if details else rates

def payload_array(solver,s):
    array=np.zeros((solver.c.capacity,solver.fabric.byte_count),dtype=np.uint8)
    ids=np.full(solver.c.capacity,-1,dtype=np.int64)
    for slot,record in solver.read_material(s):
        array[slot]=np.frombuffer(solver.fabric.payload(record),dtype=np.uint8)
        ids[slot]=record["event_id"]
    return array,ids

def pilot():
    OUT.mkdir(parents=True,exist_ok=True)
    n=10;x=np.arange(n)/n-.5
    xyz=np.stack(np.meshgrid(x,x,x,indexing="ij"),-1)
    g=2+3*xyz[...,0]-2*xyz[...,1]+.7*xyz[...,2]+xyz[...,0]*xyz[...,1]
    p=np.array([[.015,-.135,.045],[-.225,.155,-.255]])
    value,grad=sample(g,p)
    expected=2+3*p[:,0]-2*p[:,1]+.7*p[:,2]+p[:,0]*p[:,1]
    expected_grad=np.stack([3+p[:,1],-2+p[:,0],np.full(2,.7)],axis=-1)
    np.testing.assert_allclose(value,expected,atol=2e-14,rtol=0)
    np.testing.assert_allclose(grad,expected_grad,atol=2e-13,rtol=0)
    fd=[]
    for a in range(3):
        d=np.zeros_like(p);d[:,a]=1e-6
        fd.append((sample(g,p+d)[0]-sample(g,p-d)[0])/2e-6)
    fd=np.stack(fd,axis=-1)
    np.testing.assert_allclose(fd,grad,atol=1e-8,rtol=0)
    solver,s,info,inputs,count=load("n40_dt0p0005")
    original=solver.step(START,s,.0005)
    audit=Audit(solver,s);solver.rhs=audit.rhs
    instrumented=solver.step(START,s,.0005)
    assert all(np.array_equal(original[k],instrumented[k]) for k in s)
    result=dict(passed=True,instrumentation_leaves_all_state_arrays_exactly_equal=True,
                arrays=len(s),analytic_gradient_max_error=float(abs(grad-expected_grad).max()),
                finite_difference_gradient_error=float(abs(fd-grad).max()),
                rate_component_error=audit.component_error,original_inputs_checked=count,
                input_hashes=inputs,solver_steps_for_validation=2,no_production_run=True)
    dump(OUT/"setup-checks.json",result)
    print(json.dumps(result,indent=2),flush=True)

def run(tag):
    OUT.mkdir(exist_ok=True,parents=True)
    folder=OUT/tag
    folder.mkdir(exist_ok=True)
    if (folder/"status.json").exists():raise FileExistsError("Existing run; inspect before restart")
    assert json.loads((OUT/"setup-checks.json").read_text())["passed"]
    solver,s,info,inputs,count=load(tag)
    dt=info["dt"];steps=round((END-START)/dt);every=round(.002/dt)
    assert abs(START+steps*dt-END)<1e-12
    entry={k:v.copy() for k,v in s.items()}
    np.savez_compressed(folder/"entry-state.npz",**s)
    entry_values=sample(s["g"],s["observer_X"][PAIR_INDICES])[0]
    entry_payloads,entry_ids=payload_array(solver,s)
    assert list(entry_ids)==[0,1,2,-1]
    audit=Audit(solver,entry);solver.rhs=audit.rhs
    _,initial_stats,_=audit.native(START,s,details=True)
    budgets=np.zeros((2,6));samples=[];global_rows=[];payloads=[];ids=[];moved=[]
    entry_m=s["m"].copy();previous_m=s["m"].copy()
    min_step_increment=0.
    start=time.monotonic()
    status=dict(run=tag,status="running",start_time=START,end_time=END,completed_steps=0,
                total_steps=steps,started_utc=stamp(),pair_display=25,data_pair_id=24)
    dump(folder/"status.json",status)
    try:
        for i in range(steps+1):
            t=round(START+i*dt,12)
            if i:
                audit.stage_terms.clear()
                s=solver.step(round(START+(i-1)*dt,12),s,dt)
                assert len(audit.stage_terms)==2
                budgets+=dt/2*(audit.stage_terms[0]+audit.stage_terms[1])
                audit.inspect(s)
                min_step_increment=min(min_step_increment,float((s["m"]-previous_m).min()))
                previous_m=s["m"].copy()
            if i%every==0:
                v,_=sample(s["g"],s["observer_X"][PAIR_INDICES])
                _,stats,_=audit.native(t,s,details=True)
                pa,ri=payload_array(solver,s)
                payloads.append(pa);ids.append(ri)
                retained=all(any(ri[j]==entry_ids[k] and np.array_equal(pa[j],entry_payloads[k])
                                 for j in range(4)) for k in range(3))
                moved.append(s["observer_X"][PAIR_INDICES].copy())
                for p,label in enumerate(["A","B"]):
                    for c,name,offset in [(3,"C",0),(4,"theta",3)]:
                        changes=budgets[p,offset:offset+3]
                        observed=float(v[p,c]-entry_values[p,c])
                        samples.append(dict(run=tag,time=t,point=label,field=name,
                            entry=float(entry_values[p,c]),current=float(v[p,c]),change=observed,
                            diffusion_or_conduction=float(changes[0]),
                            source_or_heat_exchange=float(changes[1]),
                            advection_interpolation=float(changes[2]),
                            accounted_change=float(changes.sum()),residual=float(observed-changes.sum())))
                global_rows.append(dict(run=tag,time=t,records=len(ri[ri>=0]),entry_records_retained=retained,
                    context_increment=float(stats["C_total"]-initial_stats["C_total"]),
                    context_source_increment=float(s["ledger"][0]-entry["ledger"][0]),
                    context_residual=float(stats["C_total"]-initial_stats["C_total"]-s["ledger"][0]+entry["ledger"][0]),
                    energy_increment=float(stats["energy"]-initial_stats["energy"]),
                    external_work_increment=float(s["ledger"][1]-entry["ledger"][1]+s["breathing_work"]-entry["breathing_work"]+s["write_work"]-entry["write_work"]),
                    energy_residual=float(stats["energy"]-initial_stats["energy"]-s["ledger"][1]+entry["ledger"][1]-s["breathing_work"]+entry["breathing_work"]-s["write_work"]+entry["write_work"]),
                    minimum_m_increase=float((s["m"]-entry_m).min()),
                    minimum_b_margin=float(abs(s["b"]).min()),
                    max_divergence=float(stats["div_error"]),
                    min_temperature=float(stats["min_temperature"])))
            if i%10==0 or i==steps:
                status.update(completed_steps=i,model_time=t,elapsed_seconds=time.monotonic()-start,observed_utc=stamp())
                dump(folder/"status.json",status)
                print(tag,i,"/",steps,"time",t,"seconds",round(time.monotonic()-start,1),flush=True)
        np.savez_compressed(folder/"exit-state.npz",**s)
        np.savez_compressed(folder/"record-payloads.npz",payloads=np.asarray(payloads),ids=np.asarray(ids),
                            entry_payloads=entry_payloads,entry_ids=entry_ids,times=START+.002*np.arange(51))
        np.savez(folder/"pair-positions.npz",positions=np.asarray(moved),times=START+.002*np.arange(51))
        for name,rows in [("local-budgets.csv",samples),("global-accounts.csv",global_rows)]:
            with (folder/name).open("w",newline="",encoding="utf-8") as f:
                w=csv.DictWriter(f,list(rows[0]));w.writeheader();w.writerows(rows)
        inventory=[dict(name=k,classification=CATEGORIES[k],shape=list(s[k].shape),
                        changed=not np.array_equal(entry[k],s[k]),
                        max_absolute_change=float(abs(s[k]-entry[k]).max()),
                        entry_array_sha256=hashlib.sha256(entry[k].tobytes()).hexdigest(),
                        exit_array_sha256=hashlib.sha256(s[k].tobytes()).hexdigest())
                   for k in s]
        metrics=dict(max_local_budget_residual=max(abs(r["residual"]) for r in samples),
                     max_context_ledger_residual=max(abs(r["context_residual"]) for r in global_rows),
                     max_energy_ledger_residual=max(abs(r["energy_residual"]) for r in global_rows),
                     all_entry_records_retained=all(r["entry_records_retained"] for r in global_rows),
                     minimum_m_rate=audit.minimum_memory_rate,
                     minimum_m_increase=audit.minimum_memory_increase,
                     minimum_m_step_increment=min_step_increment,
                     minimum_b_read_margin=audit.minimum_read_margin,
                     maximum_b_sign_flips=audit.sign_flips,
                     rate_component_max_error=audit.component_error)
        verdict=dict(record_payloads_retained=metrics["all_entry_records_retained"],
                     memory_values_not_decreased=metrics["minimum_m_increase"]>=-1e-14 and min_step_increment>=-1e-14,
                     bit_read_margins_met=metrics["minimum_b_read_margin"]>=.005 and audit.sign_flips==0,
                     context_ledger_met=metrics["max_context_ledger_residual"]<=1e-10,
                     energy_ledger_met=metrics["max_energy_ledger_residual"]<=1e-6,
                     local_budget_target_met=metrics["max_local_budget_residual"]<=1e-6)
        # Do not promote numerical record retention to complete private inventory.
        result=dict(run=tag,n=info["n"],dt=dt,start=START,end=END,steps=steps,samples=51,
                    rhs_stages=audit.stages,metrics=metrics,criteria=verdict,
                    full_private_inventory_established=False,
                    no_new_write=True,no_lean_check_in_this_run=True,
                    inventory=inventory,input_hashes=inputs,original_source_hashes_checked=count,
                    code_sha256=digest(__file__),elapsed_seconds=time.monotonic()-start)
        for p,h in inputs.items():assert digest(ROOT/p)==h
        dump(folder/"result.json",result)
        status.update(status="complete",completed_utc=stamp(),criteria=verdict,elapsed_seconds=time.monotonic()-start)
        dump(folder/"status.json",status)
    except BaseException as exc:
        status.update(status="failed",error=repr(exc),traceback=traceback.format_exc(),failed_utc=stamp())
        dump(folder/"status.json",status)
        raise

if __name__=="__main__":
    parser=argparse.ArgumentParser()
    parser.add_argument("action",choices=["pilot","run"])
    parser.add_argument("--tag")
    args=parser.parse_args()
    pilot() if args.action=="pilot" else run(args.tag)
