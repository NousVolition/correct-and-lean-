"""Evolve the original thin-band field in a closed cylinder and trace parcels."""

import argparse
import json
import sys
from pathlib import Path

import numpy as np

from basin_smoothing import exact_off


def neighbor(field, axis, step):
    """Adjacent horizontal cell with zero padding at the grid edges."""
    target = [slice(None)] * field.ndim
    source = target.copy()
    if step > 0:
        target[axis], source[axis] = slice(None, -step), slice(step, None)
    else:
        target[axis], source[axis] = slice(-step, None), slice(None, step)
    result = np.zeros_like(field)
    result[tuple(target)] = field[tuple(source)]
    return result


class Cylinder:
    def __init__(self, original, n, layers):
        from scipy.fft import dct, idct
        from scipy.sparse import coo_matrix, eye
        from scipy.sparse.linalg import splu

        self.original = original
        self.disk = d = original.ClosedDisk(n)
        self.n, self.layers = n, layers
        self.h, self.dz = d.h, 1/layers
        self.z = (np.arange(layers) + .5) / layers
        self.mid = layers // 2
        assert self.z[self.mid] == .5
        self.dct, self.idct, self.splu = dct, idct, splu
        k = np.arange(layers)
        cosine = np.cos(np.pi * self.z[:, None] * k) * np.sqrt(2/layers)
        cosine[:, 0] = 1/np.sqrt(layers)
        derivative = -np.sin(np.pi * self.z[:, None] * k) * (k*np.pi*np.sqrt(2/layers))
        self.scalar_z_derivative = derivative @ cosine.T

        ids = np.full((n,n), -1, dtype=int)
        count = int(d.inside.sum())
        ids[d.inside] = np.arange(count)
        a = np.r_[ids[d.ex], ids[d.ey]]
        b = np.r_[original.neighbor(ids,1,1)[d.ex], original.neighbor(ids,0,1)[d.ey]]
        self.graph = coo_matrix((np.repeat([1.,1.,-1.,-1.], len(a)),
                                 (np.r_[a,b,a,b], np.r_[a,b,b,a])), shape=(count,count)).tocsc()
        self.identity = eye(count, format='csc')
        self.shifts = 4*(self.h/self.dz)**2 * np.sin(np.pi*k/(2*layers))**2
        self.factors = {}

    def initial(self, alpha):
        scalar = 1.01 * self.disk.profile * (1 + alpha*np.cos(np.pi*self.z[:,None,None])**2)
        return (scalar, np.zeros_like(scalar), np.zeros_like(scalar),
                np.zeros((self.layers+1, self.n, self.n)))

    def divergence(self, u, v, w):
        return (u-neighbor(u,2,-1)+v-neighbor(v,1,-1))/self.h + np.diff(w, axis=0)/self.dz

    def project(self, u, v, w):
        d = self.disk
        rhs = -self.h * self.divergence(u,v,w)[:, d.inside]
        modes = self.dct(rhs, type=2, axis=0, norm='ortho')
        solution = np.zeros_like(modes)
        solution[0,1:] = d.poisson.solve(modes[0,1:])
        scale = max(float(np.max(np.abs(modes))), np.finfo(float).tiny)
        for k in range(1, self.layers):
            if np.max(np.abs(modes[k])) < 2.e-13 * scale:
                continue
            if k not in self.factors:
                self.factors[k] = self.splu(self.graph+self.shifts[k]*self.identity, permc_spec='MMD_AT_PLUS_A')
            solution[k] = self.factors[k].solve(modes[k])
        phi = np.zeros_like(u)
        phi[:,d.inside] = self.idct(solution, type=2, axis=0, norm='ortho')
        u -= (neighbor(phi,2,1)-phi)*d.ex
        v -= (neighbor(phi,1,1)-phi)*d.ey
        w[1:-1] -= self.h/self.dz*np.diff(phi, axis=0)*d.inside
        return u, v, w

    @staticmethod
    def centred(u, v, w):
        return .5*(u+neighbor(u,2,-1)), .5*(v+neighbor(v,1,-1)), .5*(w[:-1]+w[1:])

    def rates(self, state):
        scalar, u, v, w = state
        h, dz, d = self.h, self.dz, self.disk
        nu, diffusivity = self.original.VISCOSITY, self.original.DIFFUSION
        # Retain the saved disk's conservative scalar fluxes and its 4th-order
        # horizontal slope. The vertical cosine derivative enforces insulated lids
        # and exactly represents the prescribed initial cos² depth dependence.
        scalar_rate = np.stack([d.scalar_rate(s, ui, vi) for s,ui,vi in zip(scalar,u,v)])
        flux_z = np.zeros_like(w)
        flux_z[1:-1] = .5*w[1:-1]*(scalar[1:]+scalar[:-1]) - diffusivity*np.diff(scalar,axis=0)/dz
        scalar_rate -= np.diff(flux_z,axis=0)/dz
        slope_xy = np.stack([d.slope(s) for s in scalar])
        slope_z = (self.scalar_z_derivative @ scalar.reshape(self.layers,-1)).reshape(scalar.shape)
        activation = exact_off(np.hypot(slope_xy,slope_z)-1., .01)
        force_x = -.5*(activation+neighbor(activation,2,1))
        uc, vc, wc = self.centred(u,v,w)

        def horizontal_rate(field, axis, cross, mask, force=0.):
            east, west = neighbor(field,2,1), neighbor(field,2,-1)
            south, north = neighbor(field,1,1), neighbor(field,1,-1)
            deeper = np.concatenate((field[1:],field[-1:]),axis=0)
            shallower = np.concatenate((field[:1],field[:-1]),axis=0)
            lateral = .5*(cross+neighbor(cross,axis,1))
            vertical = .5*(wc+neighbor(wc,axis,1))
            vx, vy = (field,lateral) if axis == 2 else (lateral,field)
            transport = (vx*(east-west)+vy*(south-north))/(2*h) + vertical*(deeper-shallower)/(2*dz)
            diffusion = (east+west+south+north-4*field)/h**2 + (deeper+shallower-2*field)/dz**2
            return (nu*diffusion - transport + force)*mask

        ru = horizontal_rate(u,2,vc,d.ex,force_x)
        rv = horizontal_rate(v,1,uc,d.ey)
        wi = w[1:-1]
        east, west = neighbor(wi,2,1), neighbor(wi,2,-1)
        south, north = neighbor(wi,1,1), neighbor(wi,1,-1)
        transport_w = ((uc[1:]+uc[:-1])*(east-west) + (vc[1:]+vc[:-1])*(south-north))/(4*h)
        transport_w += wi*(w[2:]-w[:-2])/(2*dz)
        diffusion_w = (east+west+south+north-4*wi)/h**2 + (w[2:]+w[:-2]-2*wi)/dz**2
        rw = np.zeros_like(w)
        rw[1:-1] = (nu*diffusion_w-transport_w)*d.inside
        return (scalar_rate, *self.project(ru,rv,rw))


class VelocityWindow:
    """Full depth of a small horizontal window around a traced point."""
    def __init__(self, mesh, centre):
        self.mesh = mesh
        self.x0, self.y0 = (np.floor((np.asarray(centre[:2])+1)/mesh.h-.5).astype(int) - 6)
        self.frames = []

    def add(self, velocities):
        self.frames.append(np.stack([v[:,self.y0:self.y0+14,self.x0:self.x0+14] for v in velocities],axis=-1))

    def velocity(self, frame, point):
        x, y, z = point
        px = (x+1)/self.mesh.h - .5 - self.x0
        py = (y+1)/self.mesh.h - .5 - self.y0
        pz = z/self.mesh.dz - .5
        ix, iy, iz = np.floor([px,py,pz]).astype(int)
        assert 0 <= ix < 13 and 0 <= iy < 13 and 0 <= iz < self.mesh.layers-1, point
        a, b, c = px-ix, py-iy, pz-iz
        block = self.frames[frame][iz:iz+2, iy:iy+2, ix:ix+2]
        horizontal = (1-b)*((1-a)*block[:,0,0]+a*block[:,0,1]) + b*((1-a)*block[:,1,0]+a*block[:,1,1])
        return (1-c)*horizontal[0] + c*horizontal[1]

    def trace(self, initial, times, backward=False):
        x = np.asarray(initial, dtype=float).copy()
        path = [x.copy()]
        step = -1 if backward else 1
        sequence = range(len(times)-1,0,-1) if backward else range(len(times)-1)
        for i in sequence:
            j = i+step
            dt = times[j]-times[i]
            def half_velocity(point):
                return .5*(self.velocity(i,point)+self.velocity(j,point))
            k1 = self.velocity(i,x)
            k2 = half_velocity(x+.5*dt*k1)
            k3 = half_velocity(x+.5*dt*k2)
            k4 = self.velocity(j,x+dt*k3)
            x = x+dt*(k1+2*k2+2*k3+k4)/6
            path.append(x.copy())
        return np.array(path[::-1] if backward else path)


def simulate(original, n, layers, steps, alpha, red_xy):
    mesh = Cylinder(original,n,layers)
    state = mesh.initial(alpha)
    times = np.linspace(0.,original.END,steps+1)
    dt = original.END/steps
    assert dt*original.VISCOSITY*(2/mesh.h**2 + 1/mesh.dz**2) < .48
    hmark = np.array([0.,0.,.5]); red = np.r_[red_xy,.5]
    near_h, near_red = VelocityWindow(mesh,hmark), VelocityWindow(mesh,red)
    speed = []; scalar_totals = []; divergence = []; mid_vertical = []; kinetic = []; max_vertical = []
    print(f'Starting {n} by {n} by {layers} with {steps} steps, depth contrast {alpha}',flush=True)
    for i,t in enumerate(times):
        s, u, v, w = state
        velocities = mesh.centred(u,v,w)
        near_h.add(velocities); near_red.add(velocities)
        speed.append(float(np.sqrt(max(0.,np.max(velocities[0]**2+velocities[1]**2+velocities[2]**2)))))
        scalar_totals.append(float(s.sum()*mesh.h**2*mesh.dz))
        divergence.append(float(np.abs(mesh.divergence(u,v,w)).max()))
        mid_vertical.append(float(np.max(np.abs(velocities[2][mesh.mid]))))
        max_vertical.append(float(np.max(np.abs(w))))
        kinetic.append(float(.5*mesh.h**2*mesh.dz*(np.sum(u*u)+np.sum(v*v)+np.sum(w*w))))
        assert np.isfinite(speed[-1]) and np.isfinite(kinetic[-1])
        if i == steps:
            break
        k1 = mesh.rates(state)
        if i == 0:
            initial_accel = [float(original.interpolate(a[mesh.mid],0.,0.,n)) for a in mesh.centred(*k1[1:])]
        trial = tuple(field+.5*dt*rate for field,rate in zip(state,k1))
        km = mesh.rates(trial)
        state = tuple(field+dt*rate for field,rate in zip(state,km))
        if (i+1) % max(1,steps//4) == 0:
            print(f'{n} cells, step {i+1}/{steps}',flush=True)
    path = near_h.trace(hmark,times,backward=True)
    forward = near_h.trace(path[0],times)
    red_path = near_red.trace(red,times)
    assert np.array_equal(path[-1], hmark)
    forward_error = float(np.linalg.norm(forward[-1]-hmark))
    conservation_error = float(max(abs(np.array(scalar_totals)-scalar_totals[0])))
    assert max(divergence) < 1.e-8 and conservation_error < 1.e-10 and forward_error < 1.e-10
    # The saved cell-centred velocity is interpolated convexly in space and time.
    # This bounds the length of any track of that interpolant during the run.
    anywhere_bound = float(np.dot(np.diff(times),np.maximum(speed[:-1],speed[1:])))
    path_length = float(np.linalg.norm(np.diff(path,axis=0),axis=1).sum())
    assert path_length <= anywhere_bound
    output = {
        'grid_width': n, 'layers': layers, 'steps': steps, 'depth_contrast': alpha,
        'time': times.tolist(), 'initial_acceleration_H_xyz': initial_accel,
        'actual_initial_midplane_peak_slope': float(mesh.disk.slope(mesh.initial(alpha)[0][mesh.mid]).max()),
        'origin_xyz_radii': path[0].tolist(), 'destination_xyz_radii': path[-1].tolist(),
        'origin_to_H_radii': float(np.linalg.norm(path[0]-hmark)), 'path_length_radii': path_length,
        'final_local_velocity_H_xyz': near_h.velocity(steps,hmark).tolist(),
        'max_depth_excursion_H_track': float(np.max(abs(path[:,2]-.5))),
        'whole_volume_max_vertical_face_speed': max(max_vertical), 'midplane_max_abs_vertical_speed': max(mid_vertical),
        'max_cell_center_speed': max(speed),'upper_bound_any_saved_velocity_track_length_radii': anywhere_bound,
        'max_velocity_divergence': max(divergence), 'max_scalar_total_drift': conservation_error,
        'midplane_red_dot_forward_endpoint_xyz': red_path[-1].tolist(),
        'midplane_red_dot_final_distance_to_H_radii': float(np.linalg.norm(red_path[-1]-hmark)),
        'H_roundtrip_error_radii': forward_error, 'final_kinetic_energy': kinetic[-1],
        'H_arriving_parcel_xyz': path.tolist(), 'red_dot_seeded_parcel_xyz': red_path.tolist(),
    }
    print('Recovered origin',path[0].tolist(),'travel',path_length,'volume displacement bound',anywhere_bound,flush=True)
    return output


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source',type=Path)
    parser.add_argument('geometry',type=Path)
    parser.add_argument('output',type=Path)
    parser.add_argument('--grid',type=int,required=True)
    parser.add_argument('--layers',type=int,required=True)
    parser.add_argument('--steps',type=int,required=True)
    parser.add_argument('--alpha',type=float,default=.02)
    parser.add_argument('--planar-control',action='store_true')
    args = parser.parse_args()
    sys.path.insert(0,str(args.source.resolve()))
    import startup
    geo = json.loads(args.geometry.read_bytes())
    data = simulate(startup,args.grid,args.layers,args.steps,args.alpha,geo['red_start_xy_radii_relative_to_H'])
    if args.planar_control:
        from basin_smoothing import run_pair
        assert args.alpha == 0
        comparison = next(r for r in run_pair(args.source.resolve(),args.grid,args.steps,.01)
                          if r['law'] == 'smooth exact-off' and r['controlled_at'] == 'peak')
        np.testing.assert_allclose(data['final_local_velocity_H_xyz'][:2],comparison['final_velocity_H_image_xy'],rtol=1.e-7,atol=1.e-13)
        np.testing.assert_allclose(data['origin_xyz_radii'][:2],comparison['parcel_origin_relative_to_H_xy_in_radii'],rtol=2.e-4,atol=1.e-13)
        data['independent_planar_control'] = comparison
    args.output.write_text(json.dumps(data,indent=2,allow_nan=False)+'\n',encoding='utf-8')
