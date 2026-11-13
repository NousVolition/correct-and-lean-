"""Measure the registered basin trail in the original 3D cylinder with an optional oscillatory body force."""
import argparse
import csv
import hashlib
import json
import os
from pathlib import Path
import sys

import numpy as np


SAMPLE = .002
PERIOD = .6
RADIUS = .8
SCALE = 1.  # peak of the largest acceleration component on a face
CONTRAST = .02
COORDS = ("x","y","z","vx","vy","vz")
HEADER = ("time","s",*COORDS,"marker_id","inserted","birth_time","parent_left","parent_right")


def digest(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream,"sha256").hexdigest()


def write_json(path, data):
    part = path.with_suffix(".json.partial")
    part.write_text(json.dumps(data,indent=2,allow_nan=False),encoding="utf-8")
    os.replace(part,path)


def read_seeds(path):
    rows = []
    with path.open(encoding="utf-8",newline="") as stream:
        for row in csv.DictReader(stream):
            if float(row["time"]) != 0:
                break
            assert int(row["marker_id"]) == len(rows)
            rows.append([float(row[k]) for k in ("s","x","y")])
    assert len(rows) == 801
    data = np.asarray(rows)
    return data[:,0], np.column_stack((data[:,1:],np.full(len(data),.5)))


def sample(mesh, centres, points):
    """The cylinder's original cell-centred trilinear sampler, vectorized across markers."""
    coord = points.copy()
    coord[:,:2] = (coord[:,:2]+1)/mesh.h - .5
    coord[:,2] = coord[:,2]/mesh.dz - .5
    ix,iy,iz = np.floor(coord).astype(int).T
    if not ((ix>=0)&(ix+1<mesh.n)&(iy>=0)&(iy+1<mesh.n)&(iz>=0)&(iz+1<mesh.layers)).all():
        raise ValueError("A parcel left the interior velocity sampling stencil")
    if not (mesh.disk.inside[iy,ix]&mesh.disk.inside[iy+1,ix]&
            mesh.disk.inside[iy,ix+1]&mesh.disk.inside[iy+1,ix+1]).all():
        raise ValueError("A parcel encountered the cylindrical rim")
    a,b,c = coord.T - np.stack((ix,iy,iz))
    result = []
    for f in centres:
        def level(k):
            return (1-b)*((1-a)*f[k,iy,ix]+a*f[k,iy,ix+1]) + b*((1-a)*f[k,iy+1,ix]+a*f[k,iy+1,ix+1])
        result.append((1-c)*level(iz) + c*level(iz+1))
    return np.column_stack(result)


def follow(mesh, positions, before, after, dt):
    def halfway(p):
        return .5*(sample(mesh,before,p)+sample(mesh,after,p))
    k1 = sample(mesh,before,positions)
    k2 = halfway(positions+.5*dt*k1)
    k3 = halfway(positions+.5*dt*k2)
    k4 = sample(mesh,after,positions+dt*k3)
    return positions+dt*(k1+2*k2+2*k3+k4)/6


class Trail:
    def __init__(self, labels, points):
        self.order = list(range(len(labels)))
        self.info = [(s,0.,"","") for s in labels]
        self.start_gaps = np.linalg.norm(np.diff(points,axis=0),axis=1)
        self.events = []

    def refine(self, points, time):
        lengths = np.linalg.norm(np.diff(points,axis=0),axis=1)
        edges = np.flatnonzero(lengths > 3*self.start_gaps)
        if not len(edges):
            return points
        ids = np.arange(len(self.info),len(self.info)+len(edges))
        mid = (points[edges]+points[edges+1])/2
        for edge,idx,position in zip(edges,ids,mid):
            left,right = self.order[edge:edge+2]
            label = (self.info[left][0]+self.info[right][0])/2
            self.info.append((label,time,left,right))
            self.events.append(dict(marker_id=int(idx),s=label,time=time,xyz=position.tolist(),
                                    left=left,right=right,parent_gap=lengths[edge],
                                    parent_start_gap=self.start_gaps[edge]))
        # Insert from the end. The source edge indices continue to refer to the old order.
        for edge,idx,position in reversed(list(zip(edges,ids,mid))):
            self.order.insert(edge+1,int(idx))
            self.start_gaps[edge] = np.linalg.norm(position-points[edge])
            self.start_gaps = np.insert(self.start_gaps,edge+1,np.linalg.norm(points[edge+1]-position))
        return np.insert(points,edges+1,mid,axis=0)

    def record(self, writer, tick, points, velocities):
        if not np.isfinite(points).all() or not np.isfinite(velocities).all():
            raise ValueError("Nonfinite marker reading")
        stamp = f"{tick/500:.3f}"
        for idx, point, velocity in zip(self.order,points,velocities,strict=True):
            s,birth,left,right = self.info[idx]
            writer.writerow((stamp,s,*map(float,point),*map(float,velocity),idx,int(left!=""),birth,left,right))


class BreathingForce:
    """Discrete curl of a compactly supported edge potential in the x-depth plane."""
    def __init__(self, mesh, neighbor):
        x,y = mesh.disk.x + mesh.h/2, mesh.disk.y
        shape = np.maximum(1-(x*x+y*y)/RADIUS**2,0.)**3
        z = np.arange(mesh.layers+1)*mesh.dz
        depth_shape = (np.sin(np.pi*z)-.25*np.sin(2*np.pi*z))/np.pi
        depth_shape[[0,-1]] = 0.
        psi = depth_shape[:,None,None]*shape
        fx = -np.diff(psi,axis=0)/mesh.dz
        fz = (psi-neighbor(psi,2,-1))/mesh.h
        scale = SCALE/max(np.abs(fx).max(),np.abs(fz).max())
        self.x,self.z = fx*scale,fz*scale
        self.y = np.zeros_like(self.x)
        assert not np.any(self.x[:,~mesh.disk.ex]) and not np.any(self.z[:,~mesh.disk.inside])
        assert not np.any(self.z[[0,-1]])
        self.max_divergence = float(abs(mesh.divergence(self.x,self.y,self.z)).max())
        projected = mesh.project(self.x.copy(),self.y.copy(),self.z.copy())
        self.projection_residual = max(float(np.max(abs(a-b))) for a,b in zip(projected,(self.x,self.y,self.z)))
        assert self.max_divergence < 1e-11 and self.projection_residual < 1e-11

    def add(self, rates, time):
        factor = np.cos(2*np.pi*time/PERIOD)
        rates[1][:] += factor*self.x
        rates[3][:] += factor*self.z


def step(mesh, state, time, dt, drive):
    first = mesh.rates(state)
    if drive is not None:
        drive.add(first,time)
    mid = tuple(f+.5*dt*k for f,k in zip(state,first))
    second = mesh.rates(mid)
    if drive is not None:
        drive.add(second,time+.5*dt)
    return tuple(f+dt*k for f,k in zip(state,second))


def run(args):
    sys.path[:0] = [str(args.model),str(args.startup)]
    import startup
    from basin_parcel_3d import Cylinder, neighbor
    from continue_basin_fruit import advect

    prefix = f"trail-{args.case}-{args.mode}"
    path = args.output/(prefix+".csv")
    part = path.with_suffix(".csv.partial")
    args.output.mkdir(exist_ok=True,parents=True)
    reference_file = args.source/f"trail-{args.case}.csv"
    reference = json.loads((args.source/f"trail-{args.case}-receipt.json").read_text())
    assert digest(reference_file) == reference["csv_sha256"]
    model_receipt = json.loads((args.model.parent.parent/"outputs/Thin-band-parcel-run.json").read_text())
    assert digest(args.model/"basin_parcel_3d.py")==model_receipt["3d_solver_sha256"]
    assert digest(args.startup/"startup.py")==model_receipt["original_solver_sha256"]
    labels,points = read_seeds(reference_file)
    curve = Trail(labels,points)
    mesh = Cylinder(startup,args.grid,args.layers)
    initial = mesh.initial(CONTRAST)
    # Preserve the archived prepared amplitude and the cylinder's depth profile.
    state = (initial[0]*(reference["amplitude"]/1.01), *initial[1:])
    drive = BreathingForce(mesh,neighbor) if args.mode=="breathing" else None
    initial_peak = float(mesh.disk.slope(state[0][mesh.mid]).max())
    initial_h = float(startup.interpolate(mesh.disk.slope(state[0][mesh.mid]),0.,0.,mesh.n))
    volume = mesh.h**2*mesh.dz
    mass = float(np.sum(state[0])*volume)
    start_v = mesh.centred(*state[1:])
    fixed = np.tile(points[0],(3,1))
    fixed[:,2] = [.25,.5,.75]
    probes = fixed.copy()
    ref_particle = points[:1].copy()
    tracked = []
    max_div = max_mass = release_err = max_cfl = max_w = midplane_excursion = 0.
    rows = native_steps = 0
    min_dt = float("inf")
    with part.open("w",newline="",encoding="utf-8",buffering=1024*1024) as stream:
        writer = csv.writer(stream,lineterminator="\n")
        writer.writerow(HEADER)
        for tick in range(601):
            stop = tick/500
            if tick:
                t = (tick-1)/500
                while stop-t > 1e-13:
                    s,u,v,w = state
                    speed = (np.max(abs(u))+np.max(abs(v)))/mesh.h + np.max(abs(w))/mesh.dz
                    diffusion = max(startup.VISCOSITY,startup.DIFFUSION)*(2/mesh.h**2+1/mesh.dz**2)
                    remaining = stop-t
                    subdivisions = max(1,int(np.ceil(max(remaining*speed/.5,remaining*diffusion/.42))))
                    next_t = stop if subdivisions==1 else t+remaining/subdivisions
                    dt = next_t-t
                    state = step(mesh,state,t,dt,drive)
                    end_v = mesh.centred(*state[1:])
                    group = follow(mesh,np.vstack((points,probes)),start_v,end_v,dt)
                    points,probes = group[:-3],group[-3:]
                    # Independent original, scalar VelocityWindow/RK4, carried from its own previous state.
                    ref_particle,_ = advect(mesh,ref_particle,start_v,end_v,t,next_t)
                    release_err = max(release_err,float(np.linalg.norm(ref_particle[0]-points[0])))
                    points = curve.refine(points,next_t)
                    start_v = end_v
                    t = next_t
                    native_steps += 1
                    min_dt = min(min_dt,dt)
                    max_cfl = max(max_cfl,dt*speed)
                    max_w = max(max_w,float(np.max(abs(state[3]))))
                    max_mass = max(max_mass,abs(float(state[0].sum()*volume)-mass))
                    max_div = max(max_div,float(np.max(abs(mesh.divergence(*state[1:])))))
                assert max_div < 1e-8 and max_mass < 1e-10 and release_err < 1e-11
                assert not np.any(state[3][[0,-1]]) and not np.any(state[1][:,~mesh.disk.ex]) and not np.any(state[2][:,~mesh.disk.ey])
            velocities = sample(mesh,start_v,points)
            curve.record(writer,tick,points,velocities)
            rows += len(points)
            midplane_excursion = max(midplane_excursion,float(np.max(abs(points[:,2]-.5))))
            np.testing.assert_allclose(probes[1],points[0],rtol=0,atol=2e-13)
            tracked.append(dict(time=stop,points=probes.tolist(),water=sample(mesh,start_v,probes).tolist(),
                                fixed_water=sample(mesh,start_v,fixed).tolist()))
            if tick and tick%100==0:
                print(f"{prefix} at {stop:.3f}, {rows:,} rows, {len(curve.events)} additions",flush=True)
    assert len(tracked)==601 and max_w>1e-6
    with part.open("rb") as f:
        csv_hash = hashlib.file_digest(f,"sha256").hexdigest()
    record = dict(case=args.case,mode=args.mode,grid=[mesh.n,mesh.n,mesh.layers],depth_contrast=CONTRAST,
        prepared_amplitude=reference["amplitude"],initial_measured_midplane_peak=initial_peak,
        initial_measured_midplane_slope_at_H=initial_h,period=PERIOD if drive else None,
        driving_force=("Oscillatory body acceleration from the discrete curl of the y-edge potential; "
           "shape (1-r^2/0.8^2)^3 for r<0.8, zero outside, times "
           "(sin(pi*z)-0.25*sin(2*pi*z))/pi times cos(2*pi*t/0.6). "
           "fx=-Dz(psi), fy=0, fz=Dx(psi); peak face component 1." if drive else "Original cylinder forcing only"),
        drive_max_divergence=drive.max_divergence if drive else 0.,
        drive_pressure_projection_residual=drive.projection_residual if drive else 0.,
        drive_at_release_probes=(sample(mesh,mesh.centred(drive.x,drive.y,drive.z),fixed).tolist() if drive else None),
        conditions=model_receipt["conditions"],initial_state_note="Use the 2D case amplitude in place of 1.01 in the cylinder scalar. Water starts at rest. H=(0,0,0.5).",
        units="Basin radii; x right, y down the picture, depth z increases from lid to floor. Velocities in radii/model time.",
        observables="601 native step endpoints from 0 to 1.2. Original trilinear point velocity; original RK4 tracer stages use before/after fields. Raw floating-point samples. Probes start at the release x,y and z=.25,.5,.75. fixed_water samples the same three stationary locations.",
        insertion_rule="Test each integration endpoint. Insert a spatial midpoint when the 3D chord exceeds three times its starting chord. Rebase each of the two new neighbour pairs at birth. s is the mean of the two original-material labels.",
        source_2d=str(reference_file),parent_csv_sha256=reference["csv_sha256"],csv_sha256=csv_hash,
        source_hashes={str(p):digest(p) for p in (args.model/"basin_parcel_3d.py",args.model/"continue_basin_fruit.py",
            args.model/"basin_smoothing.py",args.startup/"startup.py",Path(__file__))},
        rows=rows,samples=601,initial_markers=801,final_markers=len(curve.order),events=curve.events,
        native_steps=native_steps,smallest_step=min_dt,max_courant=max_cfl,
        max_mass_drift=max_mass,max_divergence=max_div,max_vertical_face_speed=max_w,
        max_marked_trail_depth_change=midplane_excursion,max_independent_release_error=release_err,
        probe_start=fixed.tolist(),probes=tracked)
    record["conditions"] = dict(record["conditions"],initial_scalar=record["initial_state_note"])
    os.replace(part,path)
    write_json(args.output/(prefix+"-receipt.json"),record)
    print(f"{prefix} complete: {rows:,} rows, release {points[0].tolist()}, largest depth change {midplane_excursion:g}",flush=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("case",choices=["7.52","7.67"])
    parser.add_argument("mode",choices=["baseline","breathing"])
    parser.add_argument("--model",type=Path,required=True)
    parser.add_argument("--startup",type=Path,required=True)
    parser.add_argument("--source",type=Path,required=True,help="Folder of the two original dense trail CSVs")
    parser.add_argument("--output",type=Path,required=True)
    parser.add_argument("--grid",type=int,default=160)
    parser.add_argument("--layers",type=int,default=9)
    run(parser.parse_args())
