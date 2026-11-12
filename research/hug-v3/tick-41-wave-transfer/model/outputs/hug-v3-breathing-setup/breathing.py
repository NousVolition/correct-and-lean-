"""Declared off/on experiment for the structural Hug v3 solver. Importing this file runs no case."""
import csv
import json
from pathlib import Path
import tempfile

import numpy as np

from structural_hug import Config, Solver as StructuralSolver


HERE = Path(__file__).resolve().parent
ORIGINAL_COUNT = 801
SEED_COLUMNS = ("marker_id","s0_basin","s0_cube","x","y","z")
KINEMATICS = ("x","y","z","x_unwrapped","y_unwrapped","z_unwrapped","vx","vy","vz")
KEY = ("arm","frame","model_time","coincidence_prime","side","marker_id","s0_basin","s0_cube")
LOCAL = ("C","source_C","theta","temperature","structural_fabric_stress_frobenius",
         "viscous_stress_frobenius")


def wrap(x):
    """One cube of side 1, represented by [-.5,.5)."""
    return x - np.floor(x+.5)


def unit_breath(xyz):
    """Periodic curl in the x-z plane. Max component is 1 on the native grid."""
    x,y,z = np.moveaxis(xyz,-1,0)
    d = z+.5
    b = np.cos(np.pi*x)**2 * np.cos(np.pi*y)**2
    bx = -np.pi*np.sin(2*np.pi*x)*np.cos(np.pi*y)**2
    g = (1-np.cos(2*np.pi*d))/(2*np.pi) + np.sin(4*np.pi*d)/(8*np.pi)
    gz = np.sin(2*np.pi*d) + .5*np.cos(4*np.pi*d)
    return np.stack((-b*gz,np.zeros_like(x),bx*g),axis=-1)/1.5


def fluid_velocity(solver, grid_velocity, points):
    """Evaluate the retained velocity Fourier modes at passive water labels."""
    freq = solver.freq[np.abs(solver.freq) < solver.n/3].astype(int)
    idx = freq % solver.n
    coefficients = solver.hat(grid_velocity)[np.ix_(idx,idx,idx)] / solver.n**3
    phase = np.exp(2j*np.pi*(wrap(points)+.5)[:,:,None]*freq)
    xsum = np.tensordot(phase[:,0],coefficients,axes=(1,0))
    xysum = np.einsum("pj,pjkc->pkc",phase[:,1],xsum)
    return np.einsum("pk,pkc->pc",phase[:,2],xysum).real


def sample_grid(grid, points):
    """Periodic trilinear readout of a native scalar or tensor grid at one time."""
    n = grid.shape[0]
    v = (wrap(points)+.5)*n
    base = np.floor(v).astype(int)
    frac = v-base
    out = np.zeros((len(points),)+grid.shape[3:])
    for i in (0,1):
        for j in (0,1):
            for k in (0,1):
                corners = np.array([i,j,k])
                index = (base+corners)%n
                weight = np.prod(np.where(corners,frac,1-frac),axis=1)
                out += grid[tuple(index.T)] * weight.reshape((len(points),)+(1,)*(grid.ndim-3))
    return out


class Trail:
    """State arrays are ID-indexed. Only the original 801 IDs join across arms."""
    def __init__(self, rows):
        if [int(r["marker_id"]) for r in rows] != list(range(ORIGINAL_COUNT)):
            raise ValueError("Invalid original marker IDs")
        self.seeds = np.array([[float(r[k]) for k in ("x","y","z")] for r in rows])
        self.info = [(float(r["s0_basin"]),float(r["s0_cube"]),0.,"","") for r in rows]
        self.order = np.arange(len(rows))
        self.birth_gaps = np.linalg.norm(wrap(np.diff(self.seeds,axis=0)),axis=1)

    def refine(self, points, time):
        deltas = wrap(np.diff(points[self.order],axis=0))
        gaps = np.linalg.norm(deltas,axis=1)
        split = np.flatnonzero(gaps > 3*self.birth_gaps)
        if not len(split):
            return points, []
        new_ids = np.arange(len(points),len(points)+len(split))
        mids = points[self.order[split]]+.5*deltas[split]
        flags = np.zeros(len(gaps),dtype=bool); flags[split] = True
        old_slots = np.arange(len(points))+np.r_[0,np.cumsum(flags)]
        slots = old_slots[split]+1
        order = np.empty(len(points)+len(split),dtype=int)
        starts = np.empty(len(order)-1)
        order[old_slots],order[slots] = self.order,new_ids
        starts[old_slots[:-1]] = self.birth_gaps
        lefts,rights = self.order[split],self.order[split+1]
        starts[slots-1] = np.linalg.norm(wrap(mids-points[lefts]),axis=1)
        starts[slots] = np.linalg.norm(wrap(points[rights]-mids),axis=1)
        births = []
        for e,idx,l,r,p in zip(split,new_ids,lefts,rights,mids):
            basin = (self.info[l][0]+self.info[r][0])/2
            cube = (self.info[l][1]+self.info[r][1])/2
            self.info.append((basin,cube,time,int(l),int(r)))
            births.append([time,int(idx),int(l),int(r),self.birth_gaps[e],gaps[e],*wrap(p)])
        self.order,self.birth_gaps = order,starts
        return np.vstack([points,mids]),births


class ComparisonSolver(StructuralSolver):
    """Native physical and social dynamics, with a tagged external force and read-only observers."""
    def __init__(self,cfg,peak,period,trail):
        super().__init__(cfg)
        self.trail = trail
        self.peak = peak
        self.period = period
        self.pattern = unit_breath(self.xyz)
        if not np.allclose(self.project(self.pattern),self.pattern,atol=2e-13,rtol=0):
            raise ValueError("External force is outside the native solenoidal Fourier subspace")

    def breath_at(self,time):
        return self.pattern*(self.peak*np.cos(2*np.pi*time/self.period))

    def initial(self):
        state = super().initial()
        state["observer_X"] = self.trail.seeds.copy()
        state["breathing_work"] = np.array(0.)
        return state

    def rhs(self,time,state,details=False):
        result = super().rhs(time,state,details)
        rates = result[0] if details else result
        u = state["g"][...,:3]
        rates["observer_X"] = fluid_velocity(self,u,state["observer_X"])
        power = 0.
        if self.peak:
            # The retained curl has P_h b = b. Add it to the projected velocity
            # rate at each native Heun stage; the native pressure increment is zero.
            force = self.breath_at(time)
            rates["g"][...,:3] += force
            power = np.mean(np.sum(u*force,axis=-1))
        rates["breathing_work"] = np.array(power)
        return result


def marker_data(arm,frame,time,prime,side,trail,points,velocity,ids):
    wrapped = wrap(points)
    for i in ids:
        basin,cube,*_ = trail.info[i]
        yield (arm,frame,f"{time:.3f}",prime,side,int(i),basin,cube,
               *wrapped[i],*points[i],*velocity[i])


def prime_reading(folder, writer, log, arm,frame,time,prime,side,solver,state,work):
    ds,stats,extra = solver.rhs(time,state,details=True)
    p = state["observer_X"][:ORIGINAL_COUNT]
    # Isolate structural fabric stress from the other elastic contributions in extra["stress"].
    fabric_tau = solver.fabric.constitutive(state["F"],state["b"])[1]
    spread = (extra["M"].T@(solver.V[:,None]*fabric_tau.reshape(solver.P,9))/solver.dv)
    fabric = spread.reshape(solver.n,solver.n,solver.n,3,3)
    grad = solver.grad(state["g"][...,:3])
    viscous = extra["viscosity"][...,None,None]*(grad+grad.swapaxes(-1,-2))
    C,theta = sample_grid(state["g"][...,3:5],p).T
    source = sample_grid(solver.c.kappa*state["A"]*extra["kernel"],p)
    fabric_norm = np.linalg.norm(sample_grid(fabric,p),axis=(-1,-2))
    viscous_norm = np.linalg.norm(sample_grid(viscous,p),axis=(-1,-2))
    common = marker_data(arm,frame,time,prime,side,solver.trail,p,ds["observer_X"],range(len(p)))
    for i,row in enumerate(common):
        writer.writerow((*row,C[i],source[i],theta[i],1+theta[i],fabric_norm[i],viscous_norm[i]))
    snapshot = f"prime-{prime:02d}-{side}.npz"
    # Exact native material and actor arrays for this instant. Passive IDs have their own table.
    np.savez_compressed(folder/snapshot,**{k:v for k,v in state.items() if k!="observer_X"})
    threshold = float(state["ledger"][1]); breathing = float(state["breathing_work"])
    decoded = [int(r["event_id"]) for _,r in solver.read_material(state)]
    observation = dict(arm=arm,frame=frame,time=time,prime=prime,side=side,snapshot=snapshot,
        decoded_event_ids=decoded,event_write=work,context_accumulator=float(state["A"]),
        total_external_work=threshold+breathing,context_force_work=threshold,breathing_work=breathing,
        write_work=float(state["write_work"]),total_energy=float(stats["energy"]),
        context_balance=float(stats["C_balance"]),divergence=float(stats["div_error"]),
        deformation_det_error=float(stats["det_error"]),minimum_temperature=float(stats["min_temperature"]))
    fixed = np.tile(solver.trail.seeds[0],(3,1))
    fixed[:,2] = [-.25,0.,.25]
    observation["fixed_probes_xyz"] = fixed.tolist()
    observation["fixed_probe_velocity"] = fluid_velocity(solver,state["g"][...,:3],fixed).tolist()
    log.write(json.dumps(observation,allow_nan=False)+"\n")
    return stats["energy"]


def csv_file(stream,columns):
    writer = csv.writer(stream,lineterminator="\n")
    writer.writerow(columns)
    return writer


def run_arm(name):
    """The new runner validates both the unchanged upstream fixture and the added arm."""
    from study import approved_arm
    case,experiment = approved_arm(name)
    arm = experiment["arm"]
    if name != "breathing_"+arm:
        raise ValueError("Case identity mismatch")
    with (HERE/"marker-seeds.csv").open(newline="") as f:
        trail = Trail(list(csv.DictReader(f)))
    with (HERE/"prime-times.csv").open(newline="") as f:
        schedule = {int(row["comparison_step"]):int(row["prime"]) for row in csv.DictReader(f)}
    cfg = Config(**case["config"])
    solver = ComparisonSolver(cfg,experiment["peak"],experiment["period"],trail)
    state = solver.initial()
    dt = experiment["step"]
    steps = round(experiment["end"]/dt)
    event_at = {round(e["end"]/dt):e for e in case["events"]}
    starts = {}
    def capture(frame):
        for event in case["events"]:
            if round(event["start"]/dt)==frame:
                starts[event["event_id"]] = state["F"].copy()
    parent = HERE/"results"
    parent.mkdir(exist_ok=True)
    destination = parent/name
    if destination.exists(): raise FileExistsError(destination)
    with tempfile.TemporaryDirectory(prefix=name+"-",dir=parent) as scratch:
        folder = Path(scratch)/name; folder.mkdir()
        with (folder/"markers.csv").open("w",newline="") as dense, (folder/"prime-markers.csv").open("w",newline="") as primes, (folder/"insertions.csv").open("w",newline="") as inserted, (folder/"prime-states.jsonl").open("w",encoding="utf-8") as checkpoint_log:
            all_rows = csv_file(dense,KEY+KINEMATICS+("birth_time","parent_left","parent_right"))
            prime_rows = csv_file(primes,KEY+KINEMATICS+LOCAL)
            birth_rows = csv_file(inserted,("time","marker_id","left","right","starting_gap","current_gap","x","y","z"))
            for frame in range(steps+1):
                time = frame*dt
                if frame:
                    state = solver.step((frame-1)*dt,state,dt)
                    if not all(np.isfinite(v).all() for v in state.values()):
                        raise FloatingPointError(f"Nonfinite joint state at {time}")
                    state["observer_X"],births = trail.refine(state["observer_X"],time)
                    birth_rows.writerows(births)
                prime = schedule.get(frame,"")
                event = event_at.get(frame)
                side = "at"
                account = None
                if event is not None:
                    prime_reading(folder,prime_rows,checkpoint_log,arm,frame,time,prime,"before_write",solver,state,None)
                    event_id = event["event_id"]
                    record = solver.make_event(state,starts.pop(event_id),event)
                    state,work = solver.write_event(state,record)
                    decoded = next(r for _,r in solver.read_material(state) if r["event_id"]==event_id)
                    error=float(np.max(np.abs(decoded["delta_E"]-record["delta_E"])))
                    account = dict(event_id=event_id,observed=event["observed"],slot=int(work["slot"]),
                                   crc=int(work["crc"]),decoded_strain_error=error,work=float(work["work"]),
                                   heat=float(work["heat"]),stored=float(work["stored"]))
                    side = "after_write"
                capture(frame)  # At .800 the earlier event closes before the next one takes its reference F.
                if prime!="":
                    energy = prime_reading(folder,prime_rows,checkpoint_log,arm,frame,time,prime,side,solver,state,account)
                    if frame==0: initial_energy = energy
                points = state["observer_X"]
                velocity = fluid_velocity(solver,state["g"][...,:3],points)
                common = marker_data(arm,frame,time,prime,side,trail,points,velocity,trail.order)
                all_rows.writerows((*row,*trail.info[i][2:]) for i,row in zip(trail.order,common))
        meta = dict(case=name,arm=arm,steps=steps,prime_times=len(schedule),fixed_marker_ids=ORIGINAL_COUNT,
                    additional_marker_ids=len(trail.info)-ORIGINAL_COUNT,
                    event_ids_read=[int(r["event_id"]) for _,r in solver.read_material(state)],
                    base_manifest_sha256=case["manifest_sha256"],comparison_manifest_sha256=experiment["manifest_sha256"],
                    energy_balance_at_end=float(energy-initial_energy-state["ledger"][1]-
                                                state["breathing_work"]-state["write_work"]))
        (folder/"run-summary.json").write_text(json.dumps(meta,indent=2,allow_nan=False),encoding="utf-8")
        folder.rename(destination)
    return meta
