"""Attribute the initial broad velocity-rate difference without changing the model.

Padding evaluates the same retained input Fourier polynomials on more points.
It checks the initial products only, not convergence of a newly resolved flow.
"""
from run_transfer import *
from run_study import coeff,on_grid,curl

DEST=HERE/'outputs/initial-route';DEST.mkdir(parents=True,exist_ok=True)
L=np.arange(-2,3)
LK=np.stack(np.meshgrid(L,L,L,indexing='ij'),axis=-1)
LD=np.maximum(np.sum(LK*LK,axis=-1),1)

def low_on(a,n):
    h=np.fft.fftn(a,axes=(0,1,2))/n**3
    v=h[np.ix_(L%n,L%n,L%n)].copy();v[2,2,2]=0
    return v

def project_low(h):
    return h-LK*(np.sum(LK*h,axis=-1)/LD)[...,None]

def measure():
    decl=json.loads((HERE/'EXPERIMENT.json').read_text())
    eps=decl['perturbation_absolute_rms']
    solver,_=new_solver();s=load_state();q=np.load(INPUT/'unit-fine-perturbation.npy')
    f,uh=coeff(s['g'][...,:3],N);_,qh=coeff(q,N);_,th=coeff(s['g'][...,4],N)
    k=np.stack(np.meshgrid(f,f,f,indexing='ij'),axis=-1)
    gh=qh[..., :,None]*(2j*np.pi*k[...,None,:])
    all_parts={};rows=[]
    for work_n in [32,48,64,96]:
        u=on_grid(uh,f,work_n);v=on_grid(qh,f,work_n)
        w=on_grid(curl(uh,f),f,work_n);z=on_grid(curl(qh,f),f,work_n)
        linear=eps*(np.cross(v,w)+np.cross(u,z))
        quadratic=eps**2*np.cross(v,z)
        theta=on_grid(th,f,work_n)
        nu=solver.c.nu*np.exp(-solver.c.thermal_feedback*np.tanh(theta/.03))
        grad=on_grid(gh,f,work_n)
        stress=eps*nu[...,None,None]*(grad+grad.swapaxes(-1,-2))
        visc=project_low(np.sum(low_on(stress,work_n)*(2j*np.pi*LK[...,None,:]),axis=-1))
        parts=dict(advection_linear=project_low(low_on(linear,work_n)),
                   advection_quadratic=project_low(low_on(quadratic,work_n)),
                   viscosity=visc)
        total=sum(parts.values());all_parts[work_n]=dict(parts,total=total)
        row=dict(work_grid=work_n,total_rate_rms=norm(total),viscosity_min=float(nu.min()),viscosity_max=float(nu.max()))
        for name,value in parts.items():
            row[name+'_rate_rms']=norm(value)
            row[name+'_signed_fraction_along_total']=float(np.vdot(total,value).real/np.vdot(total,total).real)
        rows.append(row)
    exact=np.load(INPUT/'initial-broad-rate-difference.npy')
    native=all_parts[32]['total'];padded=all_parts[96]['total']
    checks=dict(native_reconstruction_relative_difference=norm(native-exact)/norm(exact),
                native_vs_96_relative_difference=norm(native-padded)/norm(padded),
                padded64_vs_96_relative_difference=norm(all_parts[64]['total']-padded)/norm(padded),
                padded48_vs_96_relative_difference=norm(all_parts[48]['total']-padded)/norm(padded),
                quadratic_advection_native_vs_96_relative_difference=norm(all_parts[32]['advection_quadratic']-all_parts[96]['advection_quadratic'])/norm(all_parts[96]['advection_quadratic']),
                linear_advection_native_vs_96_relative_difference=norm(all_parts[32]['advection_linear']-all_parts[96]['advection_linear'])/norm(all_parts[96]['advection_linear']))
    assert checks['native_reconstruction_relative_difference']<1e-5
    for row in rows:
        assert abs(sum(row[x+'_signed_fraction_along_total'] for x in ['advection_linear','advection_quadratic','viscosity'])-1)<1e-12
    np.savez_compressed(DEST/'component-vectors.npz',**{str(n)+'_'+k:v for n,p in all_parts.items() for k,v in p.items()})
    with (DEST/'initial-components.csv').open('w',newline='') as out:
        w=csv.DictWriter(out,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
    report=dict(time=START,definition='Projected Fourier coefficients for 1<=max(abs(k))<=2; vector RMS over the unit cube.',
        initial_other_terms='Material and clay stresses, their positions, and the context-dependent activation are identical initially. Their initial velocity-rate differences are zero. Later feedback stays active in the main runs.',
        formula='P_low P_divfree [epsilon(q cross curl(u) + u cross curl(q)) + epsilon^2 q cross curl(q) + div(nu(theta)*epsilon*(grad(q)+grad(q)^T))]',
        fractions='Signed projection onto the total rate difference; these add to one. Component norms need not add.',
        padding_scope='Same saved 32^3 field resampled; checks initial nonlinear evaluation only, not full spatial refinement.',
        checks=checks,rows=rows)
    write_json(DEST/'initial-route.json',report)
    print(json.dumps(report,indent=2))

if __name__=='__main__':measure()
