"""Read-only instrumentation of matched material-journal / software-recall flows."""
from __future__ import annotations
from pathlib import Path
import sys,os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','MKL_NUM_THREADS'):os.environ[key]='1'
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT.parent/'material-trust-v3'))
import material_trust as model
from material_trust import np,plain,json_bytes,atomic_bytes,Settings,StructuralSolver
from continuum import strain_magnitude
import argparse,csv,json,time,hashlib

CADENCE=.002
HORIZON=1.3

class SoftwareControl(model.speck.SpeckSolver):
    """Same quantized recall information; original fabric, no journal or sample writes."""
    def __init__(self,config,trail,settings):
        super().__init__(config,trail,settings)
        del self.leadup;del self.recall_profiles
        self.samples=[]

    def sample(self,state,frame):
        self.refresh_binding(state)
        af=np.c_[state['context'],np.tanh(self.attach@strain_magnitude(state['F'])/.12)]
        self.samples.append(self.fabric.quant(af,self.c.feature_quantum).astype(float)*self.c.feature_quantum)

    def read_material(self,state):
        result=[]
        for slot,r in StructuralSolver.read_material(self,state):
            count=round(r['end']/CADENCE)+1
            if len(self.samples)<count:raise ValueError('Control lacks a completed sampled prefix.')
            af=np.asarray(self.samples[:count]);i,j=r['recipient'],r['origin']
            profile=dict(times=np.arange(count)*CADENCE,features=.5*(af[:,i]+af[:,j]),duration=r['end']-r['start'])
            result.append((slot,{**r,'leadup':{'profile':profile}}))
        return result

    retrieve=model.MaterialSolver.retrieve
    write_event=StructuralSolver.write_event

def construct(arm):
    settings=Settings(1,0,horizon=HORIZON)
    if arm=='journal':return model.build_solver(settings)
    case=model.base.preflight.approve('threshold_1')
    with (model.base.UPSTREAM/'marker-seeds.csv').open(newline='') as f:trail=model.base.Trail(list(csv.DictReader(f)))
    return SoftwareControl(model.base.Config(**case['config']),trail,settings),case

class Instrument:
    """Observe the unchanged two Heun stages; add no derivatives or corrective heat."""
    def __init__(self,solver):
        self.solver=solver;self.active=None;self.stages=[];self.max_stage_error=0.;self.max_heat_error=0.;self.max_extraction_error=0.
        self.original_rhs=solver.rhs;self.original_material=solver.material
        self.original_constitutive=solver.fabric.constitutive;self.original_grad=solver.grad
        solver.rhs=self.rhs;solver.material=self.material;solver.fabric.constitutive=self.constitutive;solver.grad=self.grad

    def material(self,F,m,L):
        result=self.original_material(F,m,L)
        if self.active is not None:self.last_material=(result,L)
        return result

    def constitutive(self,F,b):
        result=self.original_constitutive(F,b)
        if self.active is not None:self.last_fabric=result
        return result

    def grad(self,a):
        result=self.original_grad(a)
        if self.active is not None and a is self.active['g']:self.last_grad=result
        return result

    def rhs(self,t,state,details=False):
        self.active=state
        try:
            result=self.original_rhs(t,state,details)
            ds=result[0] if details else result
            so=self.solver;c=so.c
            (_,tau,Y,_,_),L=self.last_material
            _,fabric_tau,fabric_heat,_=self.last_fabric
            Lu=self.last_grad[...,:3,:];D=(Lu+Lu.swapaxes(-1,-2))/2
            nu=c.nu*np.exp(-c.thermal_feedback*np.tanh(state['g'][...,4]/.03))
            viscous=float(np.mean(2*nu*np.sum(D*D,axis=(-1,-2))))
            fabric=float(np.dot(so.V,fabric_heat))
            transfer=float(np.sum(so.V[:,None,None]*Y*ds['m']))
            kinetic_rate=float(np.mean(np.sum(state['g'][...,:3]*ds['g'][...,:3],axis=-1)))
            # Add back G0*tr(L): the source subtracts isotropic G0 I from stress.
            elastic_rate=float(np.dot(so.V,np.sum((tau+fabric_tau)*L,axis=(1,2))+
                np.sum(Y*ds['m'],axis=(1,2))-fabric_heat+c.G0*np.trace(L,axis1=1,axis2=2)))
            thermal_rate=float(ds['g'][...,4].mean())
            threshold=float(ds['ledger'][1]);breathing=float(ds['breathing_work'])
            error=kinetic_rate+elastic_rate+thermal_rate-threshold-breathing
            heat_error=thermal_rate-(viscous-transfer+fabric)
            extraction_error=transfer-float(ds['ledger'][2])
            self.max_stage_error=max(self.max_stage_error,abs(error))
            self.max_heat_error=max(self.max_heat_error,abs(heat_error))
            self.max_extraction_error=max(self.max_extraction_error,abs(extraction_error))
            self.stages.append(dict(threshold=threshold,breathing=breathing,viscous=viscous,
                fabric=fabric,to_directional_storage=transfer,net_heat=viscous-transfer+fabric,
                stage_error=error))
            return result
        finally:self.active=None

    def energy(self,state):
        so=self.solver
        W=self.original_material(state['F'],state['m'],np.zeros((so.P,3,3)))[0]
        wf=so.fabric.energy_force(so.fabric.local_strain(state['F']),state['b'])[0]
        fabric_energy=float(np.dot(so.fabric.weight,wf))
        journal_energy=0.
        if hasattr(so.fabric,'event_size'):
            cut=so.fabric.event_size;journal_energy=float(np.dot(so.fabric.weight[cut:],wf[cut:]))
        kinetic=float(.5*np.mean(np.sum(state['g'][...,:3]**2,axis=-1)))
        base=float(np.dot(so.V,W));thermal=float(state['g'][...,4].mean())
        mechanical=kinetic+base+fabric_energy
        return dict(kinetic=kinetic,continuum_elastic=base,event_fabric=fabric_energy-journal_energy,
            journal_fabric=journal_energy,mechanical=mechanical,thermal=thermal,total=mechanical+thermal)

class AuditRun:
    def __init__(self,arm,substeps):
        self.arm=arm;self.substeps=substeps;self.solver,self.case=construct(arm)
        self.state=self.solver.initial();self.state['relation'][0,1,2]=1.;self.state['relation'][1,0,2]=0.
        self.meter=Instrument(self.solver);self.initial=self.meter.energy(self.state)
        self.initial_ledgers=dict(threshold=float(self.state['ledger'][1]),breathing=float(self.state['breathing_work']),write=float(self.state['write_work']))
        self.integrals={k:0. for k in ('threshold','breathing','viscous','fabric','to_directional_storage','net_heat','stage_error')}
        self.stroke_heat=0.;self.journal_work=0.;self.event_work=0.;self.writes=[];self.rows=[];self.starts={};self.frame=0
        self.max_write_error=0.;self.max_thermal_jump_error=0.
        self.record('before_initial_write')
        self.sample()
        self.solver.utility_baseline=self.solver.utility(self.state,np.zeros((6,3)))
        self.capture_starts();self.record('after_all')

    @property
    def t(self):return self.frame*CADENCE

    def capture_starts(self):
        for e in self.case['events']:
            if round(e['start']/CADENCE)==self.frame:self.starts[e['event_id']]=self.state['F'].copy()

    def commit(self,after,account,kind,before):
        self.state=after;energy=self.meter.energy(after)
        error=energy['total']-before['total']-account['work']
        thermal_error=energy['thermal']-before['thermal']-account['heat']
        self.max_write_error=max(self.max_write_error,abs(error));self.max_thermal_jump_error=max(self.max_thermal_jump_error,abs(thermal_error))
        self.stroke_heat+=account['heat']
        if kind=='journal':self.journal_work+=account['work']
        else:self.event_work+=account['work']
        self.writes.append({**plain(account),'time':self.t,'kind':kind,'energy_error':error,'thermal_error':thermal_error})

    def sample(self):
        if self.arm=='journal':
            before=self.meter.energy(self.state)
            self.commit(*self.solver.write_sample(self.state,self.frame),kind='journal',before=before)
        else:self.solver.sample(self.state,self.frame)

    def record(self,phase):
        e=self.meter.energy(self.state);initial=self.initial
        work=float(self.state['ledger'][1]+self.state['breathing_work']+self.state['write_work'])-sum(self.initial_ledgers.values())
        D=self.integrals['net_heat']+self.stroke_heat
        total_change=e['total']-initial['total'];mechanical_change=e['mechanical']-initial['mechanical'];thermal_change=e['thermal']-initial['thermal']
        self.rows.append(dict(time=self.t,phase=phase,**e,total_change=total_change,mechanical_change=mechanical_change,
            thermal_change=thermal_change,work=work,drive_work=self.integrals['threshold']+self.integrals['breathing'],
            journal_write_work=self.journal_work,event_write_work=self.event_work,
            threshold_work=self.integrals['threshold'],breathing_work=self.integrals['breathing'],
            viscous_heat=self.integrals['viscous'],fabric_heat=self.integrals['fabric'],
            diverted_to_directional_storage=self.integrals['to_directional_storage'],stroke_heat=self.stroke_heat,
            net_heat=D,total_residual=work-total_change,mechanical_residual=work-mechanical_change-D,
            thermal_residual=thermal_change-D,trust_ab=float(self.state['relation'][0,1,2]),trust_ba=float(self.state['relation'][1,0,2])))

    def step(self):
        dt=CADENCE/self.substeps
        for sub in range(self.substeps):
            self.meter.stages=[]
            self.state=self.solver.step(self.t+sub*dt,self.state,dt)
            if len(self.meter.stages)!=2:raise AssertionError('Expected both native Heun stages.')
            for k in self.integrals:self.integrals[k]+=dt/2*sum(p[k] for p in self.meter.stages)
        self.frame+=1
        if not all(np.isfinite(v).all() for v in self.state.values()):raise FloatingPointError('Nonfinite flow.')
        self.record('flow_end')
        self.sample()
        for event in self.case['events']:
            if round(event['end']/CADENCE)==self.frame:
                raw=self.solver.make_event(self.state,self.starts.pop(event['event_id']),event)
                before=self.meter.energy(self.state)
                self.commit(*self.solver.write_event(self.state,raw),kind='event',before=before)
        self.capture_starts();self.record('after_all')

    def finish(self,folder):
        folder=Path(folder);folder.mkdir(parents=True,exist_ok=True)
        with (folder/'energy.csv').open('w',newline='',encoding='utf-8') as f:
            writer=csv.DictWriter(f,fieldnames=list(self.rows[0]));writer.writeheader();writer.writerows(self.rows)
        atomic_bytes(folder/'energy.json',json_bytes(self.rows));atomic_bytes(folder/'writes.json',json_bytes(self.writes))
        np.savez_compressed(folder/'state.npz',**self.state)
        protocol=json.loads((model.base.UPSTREAM/'protocol.json').read_text())
        tolerance=protocol['criteria']['energy_absolute']
        max_error=max(abs(r['total_residual']) for r in self.rows)
        same=None
        if self.arm=='journal' and self.substeps==1:
            with np.load(model.ROOT/'runs/a-trusting/body.npz',allow_pickle=False) as z:
                same=all(np.array_equal(v,z[k]) for k,v in self.state.items())
            if not same:raise AssertionError('Instrumentation altered the published journal trajectory.')
        report=dict(arm=self.arm,integration_dt=CADENCE/self.substeps,journal_cadence=CADENCE,horizon=HORIZON,
            initial_before_any_write=self.initial,initial_ledgers=self.initial_ledgers,final=self.rows[-1],
            max_total_residual=max_error,max_thermal_residual=max(abs(r['thermal_residual']) for r in self.rows),
            max_mechanical_residual=max(abs(r['mechanical_residual']) for r in self.rows),
            max_stage_energy_error=self.meter.max_stage_error,max_stage_heat_error=self.meter.max_heat_error,
            max_stage_extraction_error=self.meter.max_extraction_error,max_write_energy_error=self.max_write_error,
            max_write_thermal_error=self.max_thermal_jump_error,source_energy_tolerance=tolerance,
            status='PASS' if max_error<=tolerance else 'FAIL',write_count=len(self.writes),
            published_journal_state_exact=same,source_fingerprint=model.source_fingerprint(),
            audit_code_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
            declaration_sha256=hashlib.sha256((ROOT/'DECLARATION.json').read_bytes()).hexdigest())
        atomic_bytes(folder/'summary.json',json_bytes(report));return report

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--arm',choices=['journal','control'],required=True)
    p.add_argument('--substeps',type=int,choices=[1,2],default=1);p.add_argument('--out',type=Path,required=True);args=p.parse_args()
    if args.out.exists() and any(args.out.iterdir()):p.error('Use an empty output folder.')
    run=AuditRun(args.arm,args.substeps);start=time.perf_counter()
    while run.frame<round(HORIZON/CADENCE):
        run.step()
        if run.frame%100==0:print(json.dumps(dict(arm=args.arm,substeps=args.substeps,frame=run.frame,seconds=round(time.perf_counter()-start,2))),flush=True)
    report=run.finish(args.out)
    print(json.dumps({k:report[k] for k in ('arm','integration_dt','status','max_total_residual','max_stage_energy_error','published_journal_state_exact')}),flush=True)

if __name__=='__main__':main()
