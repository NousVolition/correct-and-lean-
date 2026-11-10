"""Matched sharp-law startup tests on a closed horizontal disk with an endpoint probe."""
from pathlib import Path
import argparse
import json
import sys

import numpy as np

try:
    from scipy.sparse import coo_matrix
    from scipy.sparse.linalg import splu
except ImportError:
    sys.path.insert(0, str(Path(__file__).resolve().parent / '.runtime'))
    from scipy.sparse import coo_matrix
    from scipy.sparse.linalg import splu


HERE = Path(__file__).resolve().parent
HOLE_PX = np.array([890.,470.])
SOURCE_PX = np.array([696.,523.])
RIM_PX = np.array([650.,270.])
CENTER = (SOURCE_PX-HOLE_PX)/RIM_PX
WIDTH = .135
RING = .10
END = .10
DIFFUSION = .00015
VISCOSITY = .002


def neighbor(a,axis,step):
    """Next or preceding array entry with zero extension at the edge."""
    b=np.roll(a,-step,axis=axis)
    index=[slice(None),slice(None)]
    index[axis]=slice(-step,None) if step>0 else slice(0,-step)
    b[tuple(index)]=0
    return b


def div_no_scale(u,v):
    return u-neighbor(u,1,-1)+v-neighbor(v,0,-1)


def full_laplacian(a):
    return neighbor(a,1,1)+neighbor(a,1,-1)+neighbor(a,0,1)+neighbor(a,0,-1)-4*a


def interpolate(field,x,y,n,offset=0):
    # Cell centres are at -1+(j+.5)*2/n. x and y can be arrays.
    ix=(x+1)*n/2-.5-offset
    iy=(y+1)*n/2-.5-offset
    j=np.floor(ix).astype(int)
    i=np.floor(iy).astype(int)
    a,b=ix-j,iy-i
    return (1-a)*(1-b)*field[i,j]+a*(1-b)*field[i,j+1]+(1-a)*b*field[i+1,j]+a*b*field[i+1,j+1]


class ClosedDisk:
    def __init__(self,n):
        self.n=n
        self.h=2/n
        grid=-1+(np.arange(n)+.5)*self.h
        x,y=np.meshgrid(grid,grid)
        self.x,self.y=x,y
        self.inside=x*x+y*y<1
        self.area=self.h**2*self.inside.sum()
        self.ex=self.inside & neighbor(self.inside,1,1)
        self.ey=self.inside & neighbor(self.inside,0,1)
        self.inner_masks=[]
        for axis in (1,0):
            interior=self.inside.copy()
            for step in (-2,-1,1,2):
                interior &= neighbor(self.inside,axis,step)
            self.inner_masks.append(interior)
        # The previously prepared scalar is exactly Gaussian throughout the source ring.
        # A C² quintic taper outside 3 widths makes its boundary flux zero.
        radius=np.hypot(x-CENTER[0],y-CENTER[1])/WIDTH
        transition=np.clip(radius-3,0,1)
        cutoff=1-transition**3*(10+transition*(-15+6*transition))
        self.profile=WIDTH*np.exp((1-radius**2)/2)*cutoff*self.inside
        cell_id=np.full((n,n),-1,dtype=int)
        count=self.inside.sum()
        cell_id[self.inside]=np.arange(count)
        left=np.r_[cell_id[self.ex],cell_id[self.ey]]
        right=np.r_[neighbor(cell_id,1,1)[self.ex],neighbor(cell_id,0,1)[self.ey]]
        rows=np.r_[left,right,left,right]
        cols=np.r_[left,right,right,left]
        weights=np.repeat([1.,1.,-1.,-1.],len(left))
        normal_laplacian=coo_matrix((weights,(rows,cols)),shape=(count,count)).tocsc()
        # Fix one pressure gauge, retaining every physical velocity degree of freedom.
        self.poisson=splu(normal_laplacian[1:,1:],permc_spec='MMD_AT_PLUS_A')
        core=(x*x+y*y<RING**2).astype(np.int8)
        self.cutx=(core-neighbor(core,1,1))*self.ex
        self.cuty=(core-neighbor(core,0,1))*self.ey

    def project(self,u,v):
        # Internal MAC faces only. Solid boundary faces carry exactly zero normal flux.
        div=div_no_scale(u,v)[self.inside]
        gauge=np.zeros(div.shape)
        gauge[1:]=self.poisson.solve(-div[1:])
        phi=np.zeros_like(u)
        phi[self.inside]=gauge
        return u-(neighbor(phi,1,1)-phi)*self.ex,v-(neighbor(phi,0,1)-phi)*self.ey

    def slope(self,s):
        deriv=[]
        for axis,inner in zip((1,0),self.inner_masks):
            plus,minus=neighbor(s,axis,1),neighbor(s,axis,-1)
            wall_plus=np.where(neighbor(self.inside,axis,1),plus,s)
            wall_minus=np.where(neighbor(self.inside,axis,-1),minus,s)
            second=(wall_plus-wall_minus)/(2*self.h)
            fourth=(8*(plus-minus)+neighbor(s,axis,-2)-neighbor(s,axis,2))/(12*self.h)
            deriv.append(np.where(inner,fourth,second)*self.inside)
        return np.hypot(*deriv)

    def scalar_rate(self,s,u,v):
        h=self.h
        se,ss=neighbor(s,1,1),neighbor(s,0,1)
        scalar_diff=div_no_scale((se-s)*self.ex,(ss-s)*self.ey)*DIFFUSION/h**2
        scalar_adv=div_no_scale(u*(s+se)/2,v*(s+ss)/2)/h
        return (scalar_diff-scalar_adv)*self.inside

    def rate(self,s,u,v):
        h=self.h
        slope=self.slope(s)
        activation=np.maximum(slope-1.,0)
        uc=(u+neighbor(u,1,-1))/2
        vc=(v+neighbor(v,0,-1))/2
        ux=(neighbor(u,1,1)-neighbor(u,1,-1))/(2*h)
        uy=(neighbor(u,0,1)-neighbor(u,0,-1))/(2*h)
        vx=(neighbor(v,1,1)-neighbor(v,1,-1))/(2*h)
        vy=(neighbor(v,0,1)-neighbor(v,0,-1))/(2*h)
        advu=u*ux+(vc+neighbor(vc,1,1))/2*uy
        advv=(uc+neighbor(uc,0,1))/2*vx+v*vy
        fu=-(activation+neighbor(activation,1,1))/2
        ru=(VISCOSITY*full_laplacian(u)/h**2-advu+fu)*self.ex
        rv=(VISCOSITY*full_laplacian(v)/h**2-advv)*self.ey
        ru,rv=self.project(ru,rv)
        return self.scalar_rate(s,u,v),ru,rv,float(slope.max())

    def sample(self,t,s,u,v):
        n,h=self.n,self.h
        uc=(u+neighbor(u,1,-1))/2
        vc=(v+neighbor(v,0,-1))/2
        slope=self.slope(s)
        # Gross transfers across the two sides of exactly the same finite-volume contour.
        signed=h*np.r_[u[self.cutx!=0]*self.cutx[self.cutx!=0],v[self.cuty!=0]*self.cuty[self.cuty!=0]]
        incoming=-np.minimum(signed,0).sum()
        outgoing=np.maximum(signed,0).sum()
        hvel=np.array([interpolate(a,0.,0.,n) for a in (uc,vc)])
        slope_h=float(interpolate(slope,0.,0.,n))
        angles=np.linspace(0,2*np.pi,64,endpoint=False)
        nx,ny=np.cos(angles),np.sin(angles)
        normal=interpolate(uc,RING*nx,RING*ny,n)*nx+interpolate(vc,RING*nx,RING*ny,n)*ny
        low=n//2-8
        patch=(uc[low:low+16,low:low+16].copy(),vc[low:low+16,low:low+16].copy())
        data={'time':t,'K':.5*h*h*(np.sum(u*u)+np.sum(v*v)),'speed_H':np.linalg.norm(hvel),
              'velocity_H':hvel.tolist(),'slope_H':slope_h,'force_H':max(0.,slope_h-1),
              'max_slope':float(slope.max()),'inward':float(incoming),'outward':float(outgoing),
              'scalar_total':float(s.sum()*h*h),
              'max_divergence':float(np.max(np.abs(div_no_scale(u,v)))/h),
              'ring_normal':normal.tolist()}
        return data,patch

    def run(self,peak,steps,capture=None,initial_state=None,snapshot=None,capture_span=.20):
        n=self.n
        dt=END/steps
        assert VISCOSITY*dt/self.h**2<.24
        state=[a.copy() for a in initial_state] if initial_state is not None else [
            peak*self.profile.copy(),np.zeros((n,n)),np.zeros((n,n))]
        records=[]
        patches=[]
        largest=0.
        if capture is not None:
            # Store the measured activation on a common source-aligned display mesh.
            axis=np.linspace(-capture_span,capture_span,129 if capture_span<=.2 else 257)
            plot_x,plot_y=np.meshgrid(CENTER[0]+axis,CENTER[1]+axis)
            fields=[]
        for i in range(steps+1):
            t=END*i/steps
            row,patch=self.sample(t,*state)
            records.append(row)
            patches.append(patch)
            if capture is not None:
                local=np.maximum(self.slope(state[0])-1.,0)
                fields.append(interpolate(local,plot_x,plot_y,n).astype('float32'))
            if i==steps:
                break
            k1=self.rate(*state)
            trial=[z+dt*k/2 for z,k in zip(state,k1[:3])]
            km=self.rate(*trial)
            if i==0:
                au=(k1[1]+neighbor(k1[1],1,-1))/2
                av=(k1[2]+neighbor(k1[2],0,-1))/2
                acceleration=[float(interpolate(a,0.,0.,n)) for a in (au,av)]
                onset_coefficient=.5*self.h**2*(np.sum(k1[1]**2)+np.sum(k1[2]**2))
            largest=max(largest,k1[3],km[3])
            state=[z+dt*k for z,k in zip(state,km[:3])]
        # Backtrack the fluid element ending at the marked H, from t=END to 0.
        loc=np.zeros(2)
        back=[loc.copy()]
        def local_velocity(fields,point):
            assert max(abs(point))<6*self.h
            return np.array([interpolate(a,point[0],point[1],n,offset=n//2-8) for a in fields])
        for i in range(steps,0,-1):
            first=local_velocity(patches[i],loc)
            guess=loc-dt*first/2
            mid=(local_velocity(patches[i],guess)+local_velocity(patches[i-1],guess))/2
            loc=loc-dt*mid
            back.append(loc.copy())
        for row,point in zip(records,reversed(back)):
            row['parcel_ending_at_H']=point.tolist()
        if capture is not None:
            np.savez_compressed(capture,local_activation=np.asarray(fields),axis=axis)
        if snapshot is not None:
            np.savez_compressed(snapshot,S=state[0],u=state[1],v=state[2])
        max_slope=max(largest,records[-1]['max_slope'])
        return {'grid':n,'steps':steps,'area':float(self.area),'peak':peak,
                'observed_max_slope':max_slope,'initial_acceleration_H':acceleration,
                'initial_acceleration_norm2_half':float(onset_coefficient),
                'finite_time_bound':.5*(np.sqrt(2*records[0]['K'])+np.sqrt(self.area)*END*max(0,max_slope-1))**2,
                'start_to_H':float(np.linalg.norm(loc)),'records':records}


def amplitude_for_measured_peak(disk, target):
    """Scale the entire profile until the solver measures the requested peak exactly."""
    estimate = float(target / disk.slope(disk.profile).max())
    if disk.slope(estimate * disk.profile).max() == target:
        return estimate
    # Rounding in the derivative stencil can move the peak a few floats either way.
    lower = upper = estimate
    for _ in range(64):
        lower = np.nextafter(lower, -np.inf)
        upper = np.nextafter(upper, np.inf)
        for candidate in (lower, upper):
            if disk.slope(candidate * disk.profile).max() == target:
                return float(candidate)
    raise ValueError(f"No uniform scaling near {estimate!r} gave an exact measured peak of {target!r}.")


def slope_token(target):
    short = f'{target:g}'
    return short if float(short) == target else repr(float(target))


def one_step_above_one(disk):
    """Apply a uniform relative increment to the previously calibrated unit-peak field."""
    base_amplitude = amplitude_for_measured_peak(disk, 1.0)
    base = base_amplitude * disk.profile
    target = float(np.nextafter(1.0, np.inf))
    for i in range(1, 257):
        increment = float(i * np.spacing(1.0) / 256)
        # Keep the small increment separate: forming 1 + increment first can lose it.
        scalar = base + increment * base
        if disk.slope(scalar).max() == target:
            return base_amplitude, increment, scalar
    raise ValueError("No tested uniform relative increment produced the successor of 1 on this grid.")


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--grid',type=int,required=True)
    parser.add_argument('--steps',type=int,required=True)
    parser.add_argument('--peaks',type=float,nargs='+',required=True)
    parser.add_argument('--capture',action='store_true')
    parser.add_argument('--snapshot',action='store_true')
    setting = parser.add_mutually_exclusive_group()
    setting.add_argument('--at-hole',action='store_true')
    setting.add_argument('--measured-peak',action='store_true',
                         help='Set the measured starting maximum on the grid by uniform profile scaling.')
    args=parser.parse_args()
    disk=ClosedDisk(args.grid)
    for a in args.peaks:
        tag, amplitude = 'peak', a
        initial_state = None
        relative_increment = None
        if args.measured_peak:
            tag = 'measured-peak'
            if a == np.nextafter(1.0, np.inf):
                amplitude, relative_increment, scalar = one_step_above_one(disk)
                initial_state = (scalar, np.zeros_like(scalar), np.zeros_like(scalar))
            else:
                amplitude = amplitude_for_measured_peak(disk, a)
        elif args.at_hole:
            tag, amplitude = 'hole', a / float(interpolate(disk.slope(disk.profile), 0., 0., args.grid))
        prefix = '' if tag == 'peak' else tag + '-'
        token = slope_token(a)
        capture=HERE/f'{prefix}activation-{args.grid}-{args.steps}-{token}.npz' if args.capture else None
        snapshot=HERE/f'{prefix}return-{args.grid}-{args.steps}-{token}.npz' if (args.capture or args.snapshot) and not args.at_hole else None
        result=disk.run(amplitude,args.steps,capture,initial_state=initial_state,snapshot=snapshot,capture_span=.55 if args.at_hole else .20)
        result['controlled_slope']=tag
        result['target_slope']=a
        if args.measured_peak:
            if result['records'][0]['max_slope'] != a:
                raise ValueError("The saved startup measurement differs from the requested peak.")
            if relative_increment is None:
                result['profile_amplitude'] = amplitude
            else:
                result['calibration'] = {'base_profile_amplitude': amplitude, 'relative_increment': relative_increment,
                                         'expression': 'base + relative_increment * base', 'target_hex': a.hex()}
        destination=HERE/f'grid-{args.grid}-steps-{args.steps}-{tag}-{token}.json'
        destination.write_text(json.dumps(result,separators=(',',':'),allow_nan=False),encoding='utf-8')
        end=result['records'][-1]
        print(f"grid={args.grid} steps={args.steps} peak={token} K={end['K']:.6g} speed_H={end['speed_H']:.6g} direct_H={end['force_H']:.4g} in={end['inward']:.6g} out={end['outward']:.6g} initial_pos_offset={result['start_to_H']:.5g}",flush=True)


if __name__=='__main__':
    main()
