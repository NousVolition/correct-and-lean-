"""Passive old-pair functional on saved v3 states; no time steps or force edits.

Old coefficients and old reference-pair prescription are diagnostic choices,
not reactivated dynamics or a physical calibration. Old grid/material counts
are replaced only by the saved data's resolution for evaluating this functional.
"""
import os,sys,json,csv,hashlib,importlib.util,time
from pathlib import Path
from datetime import datetime,timezone
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','MKL_NUM_THREADS'):os.environ[key]='1'
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'outputs/paired-context-energy'
OLD=Path(r'$USER_HOME\Documents\Codex\2026-10-08\referenced-chatgpt-conversation-this-is-an-2\outputs\hug-field-specification')
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()

def module(name,path):
    spec=importlib.util.spec_from_file_location(name,path)
    result=importlib.util.module_from_spec(spec);sys.modules[name]=result
    spec.loader.exec_module(result);return result

d=module('pair_diag',ROOT/'work/full-carrying/diagnose_stages.py');np=d.np
old=module('historical_pair',OLD/'coupled_hug.py')

def logcosh(z):
    az=abs(z);v=np.empty_like(z);small=az<20
    v[small]=np.log1p(2*np.sinh(z[small]/2)**2)
    v[~small]=az[~small]+np.log1p(np.exp(-2*az[~small]))-np.log(2.)
    return v

def positive_kernel_and_rate(solver,X,Xdot):
    """Differentiate the old periodic Gaussian image sums and normalization."""
    rs=[];rds=[];ell=solver.c.thermal_width
    for j in range(3):
        delta=(X[:,j,None]-solver.x[None,:]+.5)%1-.5
        vals=[np.exp(-.5*((delta+shift)/ell)**2) for shift in (-1,0,1)]
        raw=sum(vals)
        rawdot=sum(-v*(delta+shift)/ell**2 for v,shift in zip(vals,(-1,0,1)))*Xdot[:,j,None]
        den=raw.sum(axis=1,keepdims=True);r=raw/den
        rd=(rawdot-r*rawdot.sum(axis=1,keepdims=True))/den
        rs.append(r);rds.append(rd)
    product=lambda rr:(rr[0][:,:,None,None]*rr[1][:,None,:,None]*rr[2][:,None,None,:]).reshape(solver.P,-1)
    R=product(rs);Rdot=np.zeros_like(R)
    for j in range(3):
        terms=rs.copy();terms[j]=rds[j];Rdot+=product(terms)
    return R,Rdot

def gate_and_rate(h,hdot,length):
    w=np.zeros_like(h);wdot=np.zeros_like(h);on=h>0
    w[on]=h[on]**2/(h[on]**2+length**2)
    wdot[on]=2*h[on]*length**2/(h[on]**2+length**2)**2*hdot[on]
    return w,wdot

def evaluate(sol,X,C,Xdot=None,Cdot=None):
    if Xdot is None:Xdot=np.zeros_like(X)
    if Cdot is None:Cdot=np.zeros_like(C)
    c=sol.c;V=sol.V;pi=sol.partner
    R,Rdot=positive_kernel_and_rate(sol,X,Xdot)
    center=float(np.average(X[:,2],weights=V));center_dot=float(np.average(Xdot[:,2],weights=V))
    h=X[:,2]-center;hd=Xdot[:,2]-center_dot
    gh=sol.xyz[...,2].ravel()-center;ghd=np.full_like(gh,-center_dot)
    w,wd=gate_and_rate(h,hd,c.upper_length)
    gw,gwd=gate_and_rate(gh,ghd,c.upper_length)
    raw=R*gw;rawdot=Rdot*gw+R*gwd
    den=raw.sum(axis=1,keepdims=True)
    assert den.min()>1e-300
    RU=raw/den;RUdot=(rawdot-RU*rawdot.sum(axis=1,keepdims=True))/den
    cp=RU@C.ravel();c_field=RU@Cdot.ravel();c_geometry=RUdot@C.ravel()
    a=w*w[pi];ad=wd*w[pi]+w*wd[pi]
    z=(cp[pi]-cp)/c.pair_scale;lc=logcosh(z)
    pair=c.pair_rate*a*c.pair_scale*np.tanh(z)
    pairgrid=RU.T@(V*pair)/sol.dv
    E=.5*c.pair_rate*c.pair_scale**2*np.sum(V*a*lc)
    field=-sol.dv*np.dot(pairgrid,Cdot.ravel())
    sampling=-np.dot(V*pair,c_geometry)
    gates=.5*c.pair_rate*c.pair_scale**2*np.dot(V*ad,lc)
    cd=c_field+c_geometry
    directed=.5*c.pair_rate*c.pair_scale**2*np.sum(V*(ad*lc+a*np.tanh(z)*(cd[pi]-cd)/c.pair_scale))
    return dict(E=float(E),field=float(field),sampling=float(sampling),gates=float(gates),
        total=float(field+sampling+gates),directed=float(directed),D=pairgrid,R=R,
        min_gate=float(a.min()),min_row_den=float(den.min()),
        row_sum_error=float(abs(RU.sum(axis=1)-1).max()),
        row_rate_sum_error=float(abs(RUdot.sum(axis=1)).max()),
        conservative_pair_sum=float(np.dot(V,pair)))

def main():
    started=time.monotonic();case=d.old.preflight.approve('threshold_1')
    with (d.old.INPUT/'study/marker-seeds.csv').open() as f:trail=d.Trail(list(csv.DictReader(f)))
    solver=d.ComparisonSolver(d.Config(**case['config']),.5,.6,trail);solver.initial()
    old_config=old.Config(n=solver.c.n,radial=solver.c.radial,polar=solver.c.polar,azimuth=solver.c.azimuth)
    historic=old.Solver(old_config)
    assert np.array_equal(historic.X0,solver.X0) and np.array_equal(historic.V,solver.V)
    assert np.array_equal(historic.partner[historic.partner],np.arange(historic.P))
    assert np.array_equal(historic.V[historic.partner],historic.V)
    assert old_config.thermal_width==solver.c.thermal_width
    paths=sorted(d.old.SAVED.glob('state-*.npz'))
    sources=list((d.old.INPUT/'declared-source').rglob('*.py'))+[d.old.INPUT/'study/breathing.py',
        d.old.INPUT/'study/marker-seeds.csv',d.old.SAVED/'configuration.json',OLD/'coupled_hug.py',
        ROOT/'work/full-carrying/diagnose_stages.py',ROOT/'work/unwrapped-history/replay.py']
    hashes={str(p):sha(p) for p in paths+sources};rows=[];fd_checks=[]
    c_initial_max=None
    for p in paths:
        s=d.old.load(p);frame=int(p.stem.split('-')[1]);t=frame*.002;C=s['g'][...,3]
        before_state={key:val.copy() for key,val in s.items()}
        rates,stats,ex=solver.rhs(t,s,details=True)
        e=evaluate(historic,s['X'],C,rates['X'],rates['g'][...,3])
        if frame==0:c_initial_max=float(abs(C).max())
        diffusion=solver.c.diffusion*sum((np.roll(C,-1,axis=j)-2*C+np.roll(C,1,axis=j))/solver.dx**2 for j in range(3))
        adv=solver.context_transport(C,s['g'][...,:3])-diffusion
        source=solver.c.kappa*float(s['A'])*ex['kernel']
        c_defect=float(abs(rates['g'][...,3]-adv-diffusion-source).max())
        _,R_native_old=historic.matrices(s['X'])
        r_defect=float(abs(e['R']-R_native_old).max())
        row=dict(frame=frame,time=t,potential=e['E'],context_rate=e['field'],
            advection_rate=float(-solver.dv*np.dot(e['D'],adv.ravel())),
            diffusion_rate=float(-solver.dv*np.dot(e['D'],diffusion.ravel())),
            source_rate=float(-solver.dv*np.dot(e['D'],source.ravel())),
            moving_sampling_rate=e['sampling'],moving_gate_rate=e['gates'],full_rate=e['total'],
            directed_chain_rate=e['directed'],chain_rule_defect=e['total']-e['directed'],
            context_equation_defect=c_defect,old_kernel_defect=r_defect,
            pair_only_hypothetical_rate=float(-solver.dv*np.dot(e['D'],e['D'])),
            actual_pairgrid_max=float(abs(ex['pairgrid']).max()),
            hypothetical_pairgrid_max=float(abs(e['D']).max()),
            pair_conservation_defect=e['conservative_pair_sum'],
            row_sum_error=e['row_sum_error'],row_rate_sum_error=e['row_rate_sum_error'],
            min_pair_weight=e['min_gate'],min_receiver_normalization=e['min_row_den'])
        rows.append(row)
        if frame in (0,400,550,599,600):
            for epsilon in (1e-3,3e-4,1e-4):
                plus=evaluate(historic,s['X']+epsilon*rates['X'],C+epsilon*rates['g'][...,3])['E']
                minus=evaluate(historic,s['X']-epsilon*rates['X'],C-epsilon*rates['g'][...,3])['E']
                fd=(plus-minus)/(2*epsilon)
                fd_checks.append(dict(frame=frame,epsilon=epsilon,analytic=e['total'],finite_difference=fd,error=fd-e['total']))
        assert all(np.array_equal(s[key],before_state[key]) for key in s)
        assert e['E']>=0 and e['min_gate']>=0
        if len(rows)%15==0:print(json.dumps(dict(states=len(rows),elapsed=time.monotonic()-started)),flush=True)
    maxima={key:max(abs(row[key]) for row in rows) for key in ['chain_rule_defect','context_equation_defect',
        'old_kernel_defect','actual_pairgrid_max','pair_conservation_defect','row_sum_error','row_rate_sum_error']}
    assert c_initial_max==0 and rows[0]['potential']==0 and rows[-1]['potential']>0
    assert all(v<1e-11 for v in maxima.values())
    assert maxima['actual_pairgrid_max']==0
    fd_error=max(abs(r['error']) for r in fd_checks if r['epsilon']==1e-4)
    assert fd_error<1e-12
    assert all(sha(p)==h for p,h in hashes.items())
    with (OUT/'checkpoints.csv').open('w',newline='') as f:
        w=csv.DictWriter(f,list(rows[0]));w.writeheader();w.writerows(rows)
    result=dict(checked_utc=datetime.now(timezone.utc).isoformat(),status='PASS',read_only=True,
        new_solver_steps=0,saved_states=len(rows),initial_context_max=c_initial_max,
        initial=rows[0],final=rows[-1],minimum_potential=min(r['potential'] for r in rows),
        maximum_potential=max(r['potential'] for r in rows),maxima=maxima,
        directional_checks=fd_checks,finest_directional_check_max_error=fd_error,
        diagnostic_parameters=dict(pair_rate=old_config.pair_rate,pair_scale=old_config.pair_scale,
            upper_length=old_config.upper_length,thermal_width=old_config.thermal_width,
            grid_n=old_config.n,radial=old_config.radial,polar=old_config.polar,azimuth=old_config.azimuth,
            parcels=historic.P,reference_pair='x-reflection; transported labels, not current spatial reflection'),
        raw_units='context squared * volume / time, not calibrated physical energy; any positive energy conversion preserves the sign obstruction',
        diagnostic_scope='Old prescribed functional evaluated passively on actual saved v3 geometry and context; original physical dynamics unchanged. The old pair force is absent. Resolution comes from saved data, coefficients from the old code.',
        history_scope='Current geometry and persistent reference pairing enter this functional. It contains no independent all-history-only energy term.',
        original_sources_states_and_loaded_arrays_unchanged=True,input_sha256=hashes,
        script_sha256=sha(Path(__file__)),elapsed_seconds=time.monotonic()-started)
    (OUT/'potential-check.json').write_text(json.dumps(result,indent=2,allow_nan=False)+'\n')
    print(json.dumps({k:result[k] for k in ['status','saved_states','initial_context_max','final','maxima','finest_directional_check_max_error','elapsed_seconds']},indent=2))

if __name__=='__main__':main()
