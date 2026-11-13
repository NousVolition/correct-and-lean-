"""Continuum foundation for the new coupled social/history candidate.

Source C/A/threshold equations + declared immersed material/thermal additions.
All fields and the moving material evolve in one joint integration. Dimensionless
synthetic parameters; see MODEL.md and CORRECTIONS.md. No prescribed body trajectory.
"""
from dataclasses import dataclass, asdict, replace
import numpy as np
from scipy.fft import fftn, ifftn
import json, hashlib, time
from pathlib import Path

ROOT=Path(__file__).resolve().parent

def strain_tensor(F):
    """Added v2 sensor definition: Green-Lagrange strain, objective under Q F."""
    return .5*(F.swapaxes(-1,-2)@F-np.eye(3))

def strain_magnitude(F):
    return np.linalg.norm(strain_tensor(F),axis=(-2,-1))


@dataclass
class Config:
    n:int=24
    dt:float=.005
    end:float=2.
    radial:int=3
    polar:int=4
    azimuth:int=8
    nu:float=.015
    diffusion:float=.008
    G0:float=.08
    Gm:float=.18
    mscale:float=.2
    write_rate:float=1.
    rate_scale:float=.04
    eta:float=.7
    power_floor:float=.00001
    k0:float=.006
    km:float=.009
    mechanical_width:float=.035
    thermal_width:float=.045
    source_width:float=.08
    sigma:float=.16
    threshold:float=.015
    epsilon:float=.012
    delta:float=.003
    gamma:float=.08
    kappa:float=1.
    initial_heat:float=.03
    input_kind:str='balanced'
    branch:str='smooth'
    initial_record:float=0.
    thermal_feedback:float=.35
    direction_polar:int=3
    direction_azimuth:int=8


def body_quadrature(c):
    r,wr=np.polynomial.legendre.leggauss(c.radial); r=(r+1)/2; wr=wr/2
    z,wz=np.polynomial.legendre.leggauss(c.polar)
    ph=(np.arange(c.azimuth)+.5)*2*np.pi/c.azimuth
    rr,zz,pp=np.meshgrid(r,z,ph,indexing='ij')
    axes=np.array([.22,.17,.19])
    X=np.stack([rr*np.sqrt(1-zz**2)*np.cos(pp),rr*np.sqrt(1-zz**2)*np.sin(pp),rr*zz],axis=-1).reshape(-1,3)*axes
    V=(wr[:,None,None]*wz[None,:,None]*np.ones((1,1,c.azimuth))*rr**2*2*np.pi/c.azimuth*np.prod(axes)).ravel()
    return X,V


class Solver:
    def __init__(self,c):
        self.c=c; self.n=c.n; self.dx=1/c.n; self.dv=self.dx**3
        if c.n%2 or c.azimuth%4 or c.dt<=0 or c.end<=0:
            raise ValueError('even grid, azimuth multiple of four and positive time settings required')
        x=np.arange(c.n)/c.n-.5
        self.x=x; self.xyz=np.stack(np.meshgrid(x,x,x,indexing='ij'),-1)
        freq=np.fft.fftfreq(c.n)*c.n
        self.freq=freq
        self.k=2*np.pi*np.stack(np.meshgrid(freq,freq,freq,indexing='ij'),-1)
        self.k2=np.sum(self.k*self.k,-1)
        self.mask=np.all(np.abs(self.k/(2*np.pi))<c.n/3,axis=-1)
        self.X0,self.V=body_quadrature(c)
        self.P=len(self.V)
        z,w=np.polynomial.legendre.leggauss(c.direction_polar)
        ph=(np.arange(c.direction_azimuth)+.5)*2*np.pi/c.direction_azimuth
        z,ph=np.meshgrid(z,ph,indexing='ij')
        self.directions=np.stack([np.sqrt(1-z*z)*np.cos(ph),np.sqrt(1-z*z)*np.sin(ph),z],-1).reshape(-1,3)
        self.direction_weights=np.repeat(6*w/(2*c.direction_azimuth),c.direction_azimuth)
        sw=np.exp(-np.sum((self.X0-np.array([-.065,.045,.025]))**2,axis=1)/(2*c.source_width**2))
        self.source_weights=sw*self.V; self.source_weights/=self.source_weights.sum()

    def hat(self,a):return fftn(a,axes=(0,1,2),workers=1)
    def real(self,a):return ifftn(a,axes=(0,1,2),workers=1).real
    def filter(self,a):
        return self.real(self.hat(a)*self.mask[(...,)+(None,)*(a.ndim-3)])
    def grad(self,a):
        h=self.hat(a)
        return np.stack([self.real(1j*self.k[...,j][(...,)+(None,)*(a.ndim-3)]*h) for j in range(3)],axis=-1)
    def divergence(self,a):
        # Last axis is spatial flux direction, preceding optional axes are components.
        h=self.hat(a)
        return self.real(np.sum(1j*self.k[(...,)+(None,)*(a.ndim-4)+(slice(None),)]*h,axis=-1))
    def project(self,a,pressure=False):
        h=self.hat(a)*self.mask[...,None]
        kd=np.sum(self.k*h,axis=-1)
        den=np.where(self.k2==0,1,self.k2)
        ph=-1j*kd/den; ph[0,0,0]=0
        h-=self.k* (kd/den)[...,None]
        return (self.real(h),self.real(ph)) if pressure else self.real(h)

    def context_transport(self,C,u):
        """Conservative finite-volume scalar transport.

        Fourier face-averaged normal velocities have zero discrete divergence;
        the normalized material source preserves its discrete total.
        """
        uh=self.hat(u); rhs=np.zeros_like(C)
        for j in range(3):
            face_multiplier=np.exp(.5j*self.k[...,j]*self.dx)
            for k in range(3):
                if k!=j:face_multiplier=face_multiplier*np.sinc(self.k[...,k]*self.dx/(2*np.pi))
            uf=self.real(uh[...,j]*face_multiplier)
            face_C=.5*(C+np.roll(C,-1,axis=j))
            flux=uf*face_C-self.c.diffusion*(np.roll(C,-1,axis=j)-C)/self.dx
            rhs-=(flux-np.roll(flux,1,axis=j))/self.dx
        return rhs

    def matrices(self,X):
        """Spectral velocity interpolation and a separate positive thermal kernel.

        Mechanical spreading is its EXACT discrete adjoint. Gaussian spectral
        smoothing preserves div-free interpolation. Positive thermal weights
        have a separate allocation identity; they do not move the body.
        """
        W=[]; R=[]
        active=np.abs(self.freq)<self.n/3
        f=self.freq[active]; filt=np.exp(-.5*(2*np.pi*f*self.c.mechanical_width)**2)
        for j in range(3):
            delta=X[:,j,None]-self.x[None,:]
            w=np.sum(np.cos(2*np.pi*delta[:,:,None]*f[None,None,:])*filt,axis=-1)/self.n
            W.append(w)
            delta=(delta+.5)%1-.5
            # Periodic Gaussian image sum; +/-1 images cover negligible tails.
            rr=sum(np.exp(-.5*((delta+shift)/self.c.thermal_width)**2) for shift in (-1,0,1))
            rr/=rr.sum(axis=1,keepdims=True)
            R.append(rr)
        M=(W[0][:,:,None,None]*W[1][:,None,:,None]*W[2][:,None,None,:]).reshape(self.P,-1)
        R=(R[0][:,:,None,None]*R[1][:,None,:,None]*R[2][:,None,None,:]).reshape(self.P,-1)
        return M,R

    def initial(self):
        g=np.zeros((self.n,self.n,self.n,5))
        g[...,4]=self.filter(self.c.initial_heat*np.exp(-np.sum((self.xyz/np.array([.19,.14,.16]))**2,axis=-1)/2))
        return dict(g=g,X=self.X0.copy(),F=np.broadcast_to(np.eye(3),(self.P,3,3)).copy(),
                    m=np.full((self.P,len(self.directions),2),self.c.initial_record),A=np.array(0.),ledger=np.zeros(4))

    def material(self,F,m,L):
        c=self.c
        d=np.einsum('pij,kj->pki',F,self.directions)
        strain=(np.sum(d*d,-1)-1)/2
        D=(L+L.transpose(0,2,1))/2
        rate=np.einsum('pki,pij,pkj->pk',d,D,d)
        # No imposed fading or 35% expression floor in this new candidate.
        # F moves the retained directional structure; the full episode archive
        # is a separate social history, not these material constitutive variables.
        effective=m
        f=-np.expm1(-effective/c.mscale)
        weights=c.Gm*f.sum(-1)*self.direction_weights
        B=F@F.transpose(0,2,1)
        W=c.G0/2*(np.trace(B,axis1=1,axis2=2)-3)+.5*np.sum(weights*strain**2,axis=1)
        tau=c.G0*(B-np.eye(3))+np.einsum('pk,pki,pkj->pij',weights*strain,d,d)
        Y=.5*c.Gm*np.exp(-effective/c.mscale)/c.mscale*strain[:,:,None]**2*self.direction_weights[None,:,None]
        rate_pm=np.stack([np.maximum(rate,0),np.maximum(-rate,0)],axis=-1)
        raw=c.write_rate*(rate_pm/np.hypot(rate_pm,c.rate_scale))**2
        n=d/np.linalg.norm(d,axis=-1)[:,:,None]
        Kextra=np.einsum('pk,pki,pkj->pij',c.km*f.sum(-1)*self.direction_weights,n,n)
        return W,tau,Y,raw,Kextra

    def input(self,t):
        if self.c.input_kind=='zero':return 0.
        if 0<t<.5:return np.sin(2*np.pi*t)**2
        if self.c.input_kind=='balanced' and .5<=t<1:return -np.sin(2*np.pi*(t-.5))**2
        return 0.

    def rhs(self,t,s,details=False):
        c=self.c; g=s['g']; u=g[...,:3]; C=g[...,3]; theta=g[...,4]
        grad=self.grad(g); Lu=grad[...,:3,:]; D=(Lu+Lu.swapaxes(-1,-2))/2
        nu=c.nu*np.exp(-c.thermal_feedback*np.tanh(theta/.03))
        Qv=2*nu*np.sum(D*D,axis=(-1,-2))
        M,R=self.matrices(s['X'])
        pu=(M@u.reshape(-1,3)); L=(M@Lu.reshape(-1,9)).reshape(self.P,3,3)
        W,tau,Y,raw,Kextra=self.material(s['F'],s['m'],L)
        Ws,taus,structure_heat,structure_rates=self.extra_constitutive(s,L)
        W=W+Ws; tau=tau+taus
        stress=(M.T@(self.V[:,None]*tau.reshape(self.P,9))/self.dv).reshape(self.n,self.n,self.n,3,3)
        elastic_force=self.divergence(stress)
        occupancy=(R.T@self.V/self.dv).reshape(self.n,self.n,self.n)
        available=R@(Qv/(1+occupancy)).ravel()
        rawpower=np.sum(Y*raw,axis=(1,2))
        denominator=c.power_floor+c.eta*available+rawpower
        limiter=c.eta*available/denominator
        mdot=limiter[:,None,None]*raw
        release=structure_heat
        release_grid=(R.T@(self.V*release)/self.dv).reshape(Qv.shape)
        extraction=c.eta*Qv/(1+occupancy)*(R.T@(self.V*rawpower/denominator)/self.dv).reshape(Qv.shape)
        K=(R.T@(self.V[:,None]*Kextra.reshape(self.P,9))/self.dv).reshape(self.n,self.n,self.n,3,3)+c.k0*np.eye(3)
        heatflux=-np.einsum('...ij,...j->...i',K,grad[...,4,:])

        social, extra_derivatives = self.coupling(t,s,M,R,L)
        kernel=(R.T@social['source_weights']/self.dv).reshape(C.shape)
        source=c.kappa*float(s['A'])*kernel
        # Superseded spatial gate and mirrored-pair exchange removed entirely.
        RU=R; pair=np.zeros(self.P); pairgrid=np.zeros_like(C)
        gradC=np.stack([(np.roll(C,-1,axis=j)-np.roll(C,1,axis=j))/(2*self.dx) for j in range(3)],-1)
        q=np.sqrt(np.sum(gradC**2,-1)+c.delta**2)-np.sqrt(c.threshold**2+c.delta**2)
        if c.branch=='sharp': activation=np.maximum(q,0)
        elif c.branch=='tanh':activation=q*(1+np.tanh(q/c.epsilon))/2
        else:
            activation=np.zeros_like(q); on=q>0
            activation[on]=q[on]*np.exp(-(c.epsilon/q[on])**2)
        force=np.zeros_like(u); force[...,0]=-c.sigma*activation
        curl=np.stack([Lu[...,2,1]-Lu[...,1,2],Lu[...,0,2]-Lu[...,2,0],Lu[...,1,0]-Lu[...,0,1]],-1)
        viscous_force=self.divergence(2*nu[...,None,None]*D)
        du,pi=self.project(np.cross(u,curl)+viscous_force+elastic_force+force,True)
        dC=self.context_transport(C,u)+source+pairgrid
        dtheta=-self.divergence(u*theta[...,None]+heatflux)+Qv-extraction+release_grid
        dg=self.filter(np.concatenate([du,dC[...,None],dtheta[...,None]],-1))
        dg[...,3]=dC
        source_work=np.mean(np.sum(u*force,-1))
        # Ledgers are integrated independently of state energies.
        ledger=np.array([c.kappa*float(s['A']),source_work,np.mean(extraction),np.mean(Qv-extraction+release_grid)])
        ds=dict(g=dg,X=pu,F=L@s['F'],m=mdot,A=np.array(c.gamma*social['utility']),ledger=ledger)
        ds.update(extra_derivatives)
        ds.update(structure_rates)
        if not details:return ds
        kinetic=.5*np.mean(np.sum(u*u,-1)); elastic=np.dot(self.V,W); thermal=np.mean(theta)
        physical_pressure=pi-.5*np.sum(u*u,-1)
        totalstress=stress+2*nu[...,None,None]*D-physical_pressure[...,None,None]*np.eye(3)
        # Thermal baseline 1 is included in total energy flux, but excess heat
        # is used in the integrated diagnostics to avoid subtractive cancellation.
        stored_grid=(M.T@(self.V*W)/self.dv).reshape(C.shape)
        E=.5*np.sum(u*u,-1)+stored_grid+1+theta
        SE=E[...,None]*u-np.einsum('...ij,...j->...i',totalstress,u)+heatflux
        # Account for nonlocal interaction power and Galerkin truncation locally.
        # There is no expression-decay release in this version; m is retained.
        Wdot=np.sum(tau*L,axis=(1,2))+np.sum(Y*mdot,axis=(1,2))-release
        stored_dot=(M.T@(self.V*Wdot)/self.dv).reshape(C.shape)-self.divergence(
            (M.T@(self.V[:,None]*W[:,None]*pu)/self.dv).reshape(u.shape))
        Edot=np.sum(u*dg[...,:3],-1)+dg[...,4]+stored_dot
        # Resolve local products in the same Galerkin space as the fields.
        Edot_resolved=self.filter(Edot)
        SE=self.filter(SE)
        source_power_resolved=self.filter(np.sum(u*force,-1))
        residual=Edot_resolved+self.divergence(SE)-source_power_resolved
        # A declared minimum-L2 periodic interaction-flux convention. Keep and
        # report the zero-mode defect; never remove a mean energy error as heat.
        rh=self.hat(residual); den=np.where(self.k2==0,1,self.k2)
        correction=self.real(1j*self.k*(rh/den)[...,None])
        SE_coupled=SE+correction
        stats=dict(time=t,A=float(s['A']),C_total=float(C.mean()),kinetic=float(kinetic),elastic=float(elastic),
                   thermal=float(thermal),energy=float(kinetic+elastic+thermal),source_work=float(s['ledger'][1]),
                   C_balance=float(C.mean()-s['ledger'][0]),memory=float(np.dot(self.V,np.sum(s['m']*self.direction_weights[None,:,None],axis=(1,2)))/self.V.sum()),
                   speed_rms=float(np.sqrt(2*kinetic)),max_speed=float(np.linalg.norm(u,axis=-1).max()),
                   det_error=float(np.max(np.abs(np.linalg.det(s['F'])-1))),min_memory=float(s['m'].min()),
                   div_error=float(np.max(np.abs(np.trace(Lu,axis1=-2,axis2=-1)))),
                   pair_total=float(np.dot(self.V,pair)),min_heat_rate=float((Qv-extraction).min()),
                   min_temperature=float((1+theta).min()),centroid=np.average(s['X'],axis=0,weights=self.V).tolist(),
                   deformation=float(np.sqrt(np.dot(self.V,strain_magnitude(s['F'])**2)/self.V.sum())),
                   elastic_power_residual=float(np.mean(np.sum(u*elastic_force,-1))+np.sum(self.V[:,None,None]*tau*L)),
                   write_power_residual=float(np.mean(extraction)-np.sum(self.V[:,None,None]*Y*mdot)),
                   mean_context_exterior=float(C[occupancy<.02].mean()),
                   mean_heat_exterior=float(theta[occupancy<.02].mean()),
                   heat_flux_exterior_rms=float(np.sqrt(np.mean(heatflux[occupancy<.02]**2))))
        stats.update(release_power=float(np.dot(self.V,release)),
                     local_energy_mean_defect=float(residual.mean()),
                     local_energy_max_defect=float(np.max(np.abs(Edot_resolved+self.divergence(SE_coupled)-source_power_resolved))),
                     interaction_flux_rms=float(np.sqrt(np.mean(correction**2))))
        return ds,stats,dict(heatflux=heatflux,SE=SE_coupled,SE_local=SE,interaction_flux=correction,pressure=physical_pressure,occupancy=occupancy,
                             pair=pair,pairgrid=pairgrid,pair_kernel=RU,kernel=kernel,stress=stress,heat_rate=Qv-extraction+release_grid,extraction=extraction,
                             L=L,W=W,tau=tau,M=M,R=R,K=K,social=social,viscosity=nu)

    def extra_constitutive(self,s,L):
        return np.zeros(self.P),np.zeros((self.P,3,3)),np.zeros(self.P),{}

    def coupling(self,t,s,M,R,L):
        return dict(source_weights=self.source_weights,utility=self.input(t)),{}

    def step(self,t,s,dt):
        def add(s,k,fac):return {name:s[name]+fac*k[name] for name in s}
        k1=self.rhs(t,s); k2=self.rhs(t+dt/2,add(s,k1,dt/2))
        k3=self.rhs(t+dt/2,add(s,k2,dt/2)); k4=self.rhs(t+dt,add(s,k3,dt))
        return {name:s[name]+dt/6*(k1[name]+2*k2[name]+2*k3[name]+k4[name]) for name in s}

