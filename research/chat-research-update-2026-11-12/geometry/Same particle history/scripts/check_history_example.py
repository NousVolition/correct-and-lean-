"""Numerical illustration of the analytic history-matching construction.

This is not a proof of irrationality or a certified bound for the PDE.
Two spatial/time resolutions check the illustration independently of the
ordinary mathematical existence proof in the accompanying note.
"""
from pathlib import Path
import json, math, time
import numpy as np
from scipy.optimize import brentq

HERE = Path(__file__).resolve()
OUT = HERE.parents[1] if HERE.parent.name == 'scripts' else HERE.parents[1] / 'outputs' / 'Same particle history'
ROOT = OUT.parents[1]
OUT.mkdir(parents=True, exist_ok=True)
NU, T, TAG, K, BETA, EPS = .015, 1.2, 1.178, 2*np.pi, .125, .001
TARGET_W = 4*np.pi*np.exp(-NU*(4*np.pi)**2*T)
TARGET_DRIFT = np.sqrt(2)/100000

def integrate(n, dt):
    mode = np.fft.fftfreq(n, 1/n)
    kx, ky = np.meshgrid(K*mode, K*mode, indexing='ij')
    x, y = np.meshgrid(np.arange(n)/n, np.arange(n)/n, indexing='ij')
    sx, sy, cx, cy = np.sin(K*x), np.sin(K*y), np.cos(K*x), np.cos(K*y)
    psi = sx*sy*(cx-cy)
    # b=(psi_y,-psi_x) times EPS exp(-5 nu k^2 t).
    bx = K*sx*(cx*cy-np.cos(2*K*y))
    by = -K*sy*(np.cos(2*K*x)-cx*cy)
    initial = np.stack([np.exp(NU*K*K*T)*sx,
                        np.exp(NU*K*K*T)*(cx-cy),
                        np.exp(2*NU*K*K*T)*sx*sy])
    v = np.fft.fft2(initial, axes=(-2,-1))
    mask = (abs(kx/K) <= n//3) & (abs(ky/K) <= n//3)
    ell = -NU*(kx*kx+ky*ky)
    E, E2 = np.exp(dt*ell), np.exp(dt*ell/2)
    roots = np.exp(1j*np.pi*(np.arange(32)+.5)/32)
    LR = dt*ell[...,None]+roots
    Q = dt*np.mean((np.exp(LR/2)-1)/LR, axis=-1).real
    f1 = dt*np.mean((-4-LR+np.exp(LR)*(4-3*LR+LR*LR))/LR**3, axis=-1).real
    f2 = dt*np.mean((2+LR+np.exp(LR)*(-2+LR))/LR**3, axis=-1).real
    f3 = dt*np.mean((-4-3*LR-LR*LR+np.exp(LR)*(4-LR))/LR**3, axis=-1).real

    def adv(vh, t):
        dx = np.fft.ifft2(1j*kx*vh, axes=(-2,-1)).real
        dy = np.fft.ifft2(1j*ky*vh, axes=(-2,-1)).real
        a = -EPS*np.exp(-5*NU*K*K*t)*(bx*dx+by*dy)
        return np.fft.fft2(a, axes=(-2,-1))*mask

    history, saved = [], {}
    count = round(T/dt)
    for step in range(count+2):
        t = step*dt
        if TAG-1e-10 <= t <= T+1e-10:
            jets = np.stack([np.sum(v, axis=(-2,-1)).real,
                             np.sum(v*1j*kx, axis=(-2,-1)).real,
                             np.sum(v*1j*ky, axis=(-2,-1)).real],axis=-1)/n**2
            history.append((t, jets))
        if step in [count-1, count, count+1]:
            saved[step-count] = v.copy()
        if step == count+1:
            break
        Nv = adv(v,t)
        a = E2*v+Q*Nv
        Na = adv(a,t+dt/2)
        b = E2*v+Q*Na
        Nb = adv(b,t+dt/2)
        c = E2*a+Q*(2*Nb-Nv)
        Nc = adv(c,t+dt)
        v = (E*v+f1*Nv+2*f2*(Na+Nb)+f3*Nc)*mask

    vh = saved[0]
    m = np.sum(vh[0]*1j*kx).real/n**2
    scale = -TARGET_W/m
    # Independent central time-difference residual for the passive equation.
    residual_hat = (saved[1]-saved[-1])/(2*dt) - (ell*vh+adv(vh,T))
    scalar_residual = float(np.max(abs(np.fft.ifft2(residual_hat,axes=(-2,-1)).real)))
    # Check the two horizontal Navier--Stokes equations with the stated pressure.
    at = EPS*np.exp(-5*NU*K*K*T)
    ux, uy = at*bx, at*by
    pressure = -.5*(ux*ux+uy*uy+5*K*K*(at*psi)**2)
    ph = np.fft.fft2(pressure)
    residual_h = []
    for f, kp in [(ux,kx),(uy,ky)]:
        fh = np.fft.fft2(f)
        dx = np.fft.ifft2(1j*kx*fh).real
        dy = np.fft.ifft2(1j*ky*fh).real
        lap = np.fft.ifft2(-(kx*kx+ky*ky)*fh).real
        dp = np.fft.ifft2(1j*kp*ph).real
        residual_h.append(np.max(abs(-5*NU*K*K*f+ux*dx+uy*dy-NU*lap+dp)))
    return dict(n=n,dt=dt,mode=mode,vh=vh,history=history,scale=scale,
                scalar_residual=scalar_residual,horizontal_residual=float(max(residual_h)))

def geometry(run, eta, samples=2048):
    n, mode, vh, scale = run['n'],run['mode'],run['vh'],run['scale']
    y = np.arange(samples)/samples
    ey = np.exp(1j*K*y[:,None]*mode)
    coeff = np.einsum('qj,aij->aqi',ey,vh)/n**2
    c = coeff[0]+BETA*(coeff[1]+eta*coeff[2])
    x = np.zeros(samples)
    for iteration in range(20):
        ex = np.exp(1j*K*x[:,None]*mode)
        w = np.sum(ex*c,axis=-1).real
        wx = np.sum(ex*c*(1j*K*mode),axis=-1).real
        shift = w/wx
        x -= shift
        if max(abs(shift)) < 2e-15:
            break
    ex = np.exp(1j*K*x[:,None]*mode)
    wx = np.sum(ex*c*(1j*K*mode),axis=-1).real
    cycoeff = np.einsum('qj,aij->aqi',ey*(1j*K*mode),vh)/n**2
    wy = np.sum(ex*(cycoeff[0]+BETA*(cycoeff[1]+eta*cycoeff[2])),axis=-1).real
    psi = np.sin(K*x)*np.sin(K*y)*(np.cos(K*x)-np.cos(K*y))
    omega_z = 5*K*K*EPS*np.exp(-5*NU*K*K*T)*psi
    omega_y = -scale*wx
    dzdy = omega_z/omega_y
    drift = np.mean(dzdy)
    # Periodic trapezoid rule over one y-turn; primitive starts exactly at zero.
    z = np.zeros(samples+1)
    z[1:] = np.cumsum((dzdy+np.roll(dzdy,-1))/(2*samples))
    # Proper rotation (x,y,z)->(-z,y,x) puts B back at (0,0,1/4).
    physical = np.column_stack([-z[:-1],y,x])
    delta = physical-np.array([0,0,.25])
    delta -= np.round(delta)
    distances = np.linalg.norm(delta,axis=-1)
    return dict(eta=eta,drift=float(drift),x=x,y=y,z=z,physical=physical,
                min_x=float(min(x)),max_x=float(max(x)),min_wx=float(min(wx)),
                min_swirl=float(min(np.sqrt((scale*wy)**2+omega_y**2+omega_z**2))),
                closest_distance=float(min(distances)),
                max_level_residual=float(max(abs(np.sum(ex*c,axis=-1).real))))

def run_checks():
    started=time.time()
    runs=[]
    for n,dt in [(32,.002),(48,.001)]:
        r=integrate(n,dt)
        eta=brentq(lambda e:geometry(r,e,1024)['drift']-TARGET_DRIFT,0,.5,xtol=1e-13)
        g=geometry(r,eta)
        times=np.array([h[0] for h in r['history']])
        jets=np.stack([h[1] for h in r['history']])
        perturb=BETA*(jets[:,1]+eta*jets[:,2])
        whist=-r['scale']*jets[:,0,1]
        hist_difference=abs(r['scale'])*np.max(abs(perturb))
        entry={key:r[key] for key in ['n','dt','scale','scalar_residual','horizontal_residual']}
        entry.update({key:g[key] for key in ['eta','drift','min_x','max_x','min_wx','min_swirl','closest_distance','max_level_residual']})
        entry.update(history_samples=len(times),max_perturbation_first_jet=float(np.max(abs(perturb))),
                     max_history_vector_difference=float(hist_difference))
        runs.append((r,g,entry))
        np.savez(OUT/f'illustration-{n}.npz',times=times,swirl_history=whist,
                 particle_y=.1*(times-T),**{k:g[k] for k in ['x','y','z','physical']},
                 eta=eta,drift=g['drift'],scale=r['scale'],vh=r['vh'],mode=r['mode'])
        print(json.dumps(entry),flush=True)
    a,b=runs[0][2],runs[1][2]
    report=dict(status='NUMERICAL ILLUSTRATION ONLY',
                mathematical_claim='The proof uses an exactly selected irrational drift; the decimal root here only approximates that selection.',
                viscosity=NU,tagging_time=TAG,tick41=T,epsilon=EPS,beta=BETA,
                target_swirl=TARGET_W,target_drift_formula='sqrt(2)/100000',target_drift_float=TARGET_DRIFT,
                runs=[a,b],resolution_changes={k:abs(a[k]-b[k]) for k in ['eta','drift','min_swirl','closest_distance']},
                elapsed_seconds=time.time()-started,
                limitations=['No interval enclosure of the PDE or parameter root.',
                  'Irrational nonreturn is proved analytically, never inferred from a floating-point trace.',
                  'The existence proof takes sufficiently small epsilon; epsilon=0.001 is an illustration checked at two resolutions, not a certified admissible parameter bound.',
                  'The saved Hug simulation was not rerun or used as an initial condition.'])
    (OUT/'Numerical checks.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    assert b['min_wx']>0 and b['min_swirl']>0
    assert b['max_history_vector_difference']<1e-11
    assert b['closest_distance']>=.25-1e-12
    assert report['resolution_changes']['eta']<1e-7
    assert b['scalar_residual']<a['scalar_residual']*.4
    return report

if __name__=='__main__':
    run_checks()
