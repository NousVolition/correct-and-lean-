"""Continue both material tracers in the saved thin-band 3D model."""

import argparse
import hashlib
import json
import sys
from pathlib import Path

import numpy as np

from basin_parcel_3d import Cylinder, VelocityWindow


def file_digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def save_checkpoint(path, state, fruits, time, metadata):
    names = ('scalar', 'u', 'v', 'w')
    provisional = path.with_suffix('.writing.npz')
    np.savez_compressed(provisional, **dict(zip(names,state)), fruits=fruits, time=time,
                        metadata=json.dumps(metadata,sort_keys=True))
    provisional.replace(path)


def load_checkpoint(path, metadata):
    with np.load(path,allow_pickle=False) as archive:
        assert json.loads(str(archive['metadata'])) == metadata
        return (tuple(archive[name] for name in ('scalar','u','v','w')),
                archive['fruits'], float(archive['time']))


def advect(mesh, positions, before, after, t, next_t):
    endpoints = []
    velocities = []
    for xyz in positions:
        window = VelocityWindow(mesh,xyz)
        window.add(before)
        window.add(after)
        endpoint = window.trace(xyz,(t,next_t))[-1]
        endpoints.append(endpoint)
        velocities.append(window.velocity(1,endpoint))
    return np.array(endpoints), np.array(velocities)


def step(mesh, state, dt):
    k = mesh.rates(state)
    midpoint = tuple(a+.5*dt*b for a,b in zip(state,k))
    midpoint_rate = mesh.rates(midpoint)
    return tuple(a+dt*b for a,b in zip(state,midpoint_rate))


def kinetic(mesh, state):
    return .5*mesh.h**2*mesh.dz*sum(np.sum(f*f) for f in state[1:])


def reconstruct(mesh, reference, metadata, path):
    # Both fruit start at their previously established material origins. A parcel
    # is never assigned to H when the clock crosses 0.10.
    expected = np.stack([reference['red_dot_seeded_parcel_xyz'],reference['H_arriving_parcel_xyz']],axis=1)
    times = reference['time']
    state = mesh.initial(reference['depth_contrast'])
    positions = expected[0].copy()
    previous_velocity = mesh.centred(*state[1:])
    dt = (times[-1]-times[0])/(len(times)-1)
    worst = 0.
    for i in range(1,len(times)):
        state = step(mesh,state,dt)
        velocity = mesh.centred(*state[1:])
        positions, fruit_velocity = advect(mesh,positions,previous_velocity,velocity,times[i-1],times[i])
        worst = max(worst,float(np.max(np.linalg.norm(positions-expected[i],axis=1))))
        previous_velocity = velocity
    assert worst < 1.e-12, worst
    np.testing.assert_allclose(kinetic(mesh,state),reference['final_kinetic_energy'],rtol=1.e-10,atol=1.e-20)
    np.testing.assert_allclose(fruit_velocity[1],reference['final_local_velocity_H_xyz'],rtol=1.e-8,atol=1.e-14)
    save_checkpoint(path,state,positions,times[-1],metadata)
    saved, fruit_saved, time_saved = load_checkpoint(path,metadata)
    assert all(np.array_equal(a,b) for a,b in zip(state,saved))
    np.testing.assert_array_equal(positions,fruit_saved)
    print(f'{mesh.n}: matched both original tracks through {time_saved:.2f}, largest position difference {worst:.3g}',flush=True)
    return saved,fruit_saved,time_saved,{'original_snapshot_count':len(times),'max_position_difference_radii':worst,
        'matched_earlier_kinetic_energy_and_orange_velocity':True,'checkpoint_arrays_roundtrip_exact':True}


def local_velocity(mesh, velocities, xyz):
    window = VelocityWindow(mesh,xyz)
    window.add(velocities)
    return window.velocity(0,xyz)


def run(args):
    sys.path.insert(0,str(args.source.resolve()))
    import startup

    reference = json.loads(args.reference.read_bytes())
    mesh = Cylinder(startup,reference['grid_width'],reference['layers'])
    metadata = {'grid':mesh.n,'layers':mesh.layers,'alpha':reference['depth_contrast'],
                'original_sha256':file_digest(args.source/'startup.py'),
                'solver_sha256':file_digest(Path(__file__).with_name('basin_parcel_3d.py')),
                'previous_trace_sha256':file_digest(args.reference),
                'fruit_order':['apple','orange'],'coordinate_order':['x_right','y_down','depth_from_top']}
    if args.resume:
        state, positions, start = load_checkpoint(args.resume,metadata)
        continuity = {'resumed_from':str(args.resume),'checkpoint_sha256':file_digest(args.resume)}
    else:
        state, positions, start, continuity = reconstruct(mesh,reference,metadata,args.checkpoint_start)
        continuity['checkpoint_sha256'] = file_digest(args.checkpoint_start)
    assert args.until > start and args.steps >= 1
    dt = (args.until-start)/args.steps
    assert dt*startup.VISCOSITY*(2/mesh.h**2 + 1/mesh.dz**2) < .48
    times = np.linspace(start,args.until,args.steps+1)
    previous_velocity = mesh.centred(*state[1:])
    tracers = [positions.copy()]
    tracer_velocities = [[local_velocity(mesh,previous_velocity,p).tolist() for p in positions]]
    reference_mass = float(np.sum(state[0])*mesh.h**2*mesh.dz)
    mass_error = 0.; divergence = 0.; mid_vertical = 0.
    speeds = [float(np.sqrt(np.max(sum(v*v for v in previous_velocity))))]
    for i in range(1,len(times)):
        state = step(mesh,state,dt)
        velocity = mesh.centred(*state[1:])
        positions, fruit_velocity = advect(mesh,positions,previous_velocity,velocity,times[i-1],times[i])
        tracers.append(positions.copy()); tracer_velocities.append(fruit_velocity.tolist())
        mass_error = max(mass_error,abs(float(np.sum(state[0])*mesh.h**2*mesh.dz)-reference_mass))
        divergence = max(divergence,float(np.max(np.abs(mesh.divergence(*state[1:])))))
        mid_vertical = max(mid_vertical,float(np.max(np.abs(velocity[2][mesh.mid]))))
        speeds.append(float(np.sqrt(np.max(sum(v*v for v in velocity)))))
        assert np.isfinite(speeds[-1]) and mass_error < 1.e-10 and divergence < 1.e-8
        previous_velocity = velocity
        if i%max(1,args.steps//6)==0 or i==args.steps:
            print(f'{mesh.n}: time {times[i]:.4f}, apple {positions[0,:2].tolist()}, orange {positions[1,:2].tolist()}',flush=True)
    save_checkpoint(args.checkpoint_end,state,positions,times[-1],metadata)
    restored, restored_positions, t_end = load_checkpoint(args.checkpoint_end,metadata)
    assert all(np.array_equal(a,b) for a,b in zip(state,restored)) and t_end == args.until
    np.testing.assert_array_equal(positions,restored_positions)
    report = {'metadata':metadata,'continuity':continuity,'time':times.tolist(),'steps':args.steps,'timestep':dt,
              'tracers':np.asarray(tracers).tolist(),'tracer_velocities':tracer_velocities,
              'max_scalar_total_drift':mass_error,'max_velocity_divergence':divergence,
              'max_abs_vertical_speed_on_midplane':mid_vertical,
              'any_interpolated_parcel_length_bound_radii':float(np.dot(np.diff(times),np.maximum(speeds[:-1],speeds[1:]))),
              'ending_checkpoint':str(args.checkpoint_end.resolve()),'ending_checkpoint_sha256':file_digest(args.checkpoint_end),
              'ending_checkpoint_roundtrip_exact':True}
    args.output.write_text(json.dumps(report,separators=(',',':'),allow_nan=False)+'\n',encoding='utf-8')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source',type=Path); parser.add_argument('reference',type=Path); parser.add_argument('output',type=Path)
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument('--checkpoint-start',type=Path); source.add_argument('--resume',type=Path)
    parser.add_argument('--checkpoint-end',type=Path,required=True)
    parser.add_argument('--until',type=float,required=True); parser.add_argument('--steps',type=int,required=True)
    run(parser.parse_args())
