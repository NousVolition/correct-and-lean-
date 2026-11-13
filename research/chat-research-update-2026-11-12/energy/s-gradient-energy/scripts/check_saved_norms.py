"""Read-only quadratic scalar/gradient budget checks on saved native states."""
from pathlib import Path
import json,csv,hashlib
from datetime import datetime,timezone
import numpy as np
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'outputs/s-gradient-energy'
SAVED=Path(r'$USER_HOME\Documents\Codex\2026-11-10\lo\work\threshold-one\threshold-1')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
history_path=ROOT/'outputs/full-carrying-energy/activation-history.csv'
with history_path.open(newline='') as f:history={int(r['frame']):r for r in csv.DictReader(f) if r['grid']=='16'}
paths=sorted(SAVED.glob('state-*.npz'));hashes={str(p):sha(p) for p in paths+[history_path]}
rows=[]
for path in paths:
    frame=int(path.stem.split('-')[1])
    with np.load(path) as z:
        C=z['g'][...,3];n=C.shape[0]
        centered=np.stack([(np.roll(C,-1,j)-np.roll(C,1,j))*n/2 for j in range(3)],-1)
        forward=np.stack([(np.roll(C,-1,j)-C)*n for j in range(3)],-1)
        # Continuum Laplacian integration by parts has the nearest-neighbor
        # gradient counterpart for this native finite-volume diffusion stencil.
        lap=n*n*sum(np.roll(C,-1,j)-2*C+np.roll(C,1,j) for j in range(3))
        byparts=float(np.mean(C*lap)+np.mean((forward*forward).sum(-1)))
        assert abs(byparts)<1e-12
        r=history[frame]
        rows.append(dict(frame=frame,time=.002*frame,
            half_S2=float(.5*np.mean(C*C)),half_centered_gradient2=float(.5*np.mean((centered*centered).sum(-1))),
            half_forward_gradient2=float(.5*np.mean((forward*forward).sum(-1))),
            half_A2=float(.5*float(z['A'])**2),
            unresolved_history_endpoint=float(r['history_endpoint']),unresolved_history_rate=float(r['history_rate_integral']),
            discrete_diffusion_integration_by_parts_defect=byparts))
first,last=rows[0],rows[-1]
assert first['frame']==0 and last['frame']==600
assert all(first[k]==0 for k in ['half_S2','half_centered_gradient2','half_forward_gradient2','half_A2'])
assert last['unresolved_history_endpoint']>0
candidates=[]
for key in ['half_S2','half_centered_gradient2','half_forward_gradient2','half_A2']:
    delta=last[key]-first[key];assert delta>0
    # An endpoint fit is only a diagnostic; this value is not selected as a law.
    fitted=-last['unresolved_history_endpoint']/delta
    residuals=[float(r['unresolved_history_endpoint'])+fitted*(r[key]-first[key]) for r in rows]
    i=int(np.argmax(abs(np.asarray(residuals))))
    candidates.append(dict(quantity=key,initial=first[key],final=last[key],change=delta,
        nonnegative_constant_coefficient_can_fill=False,
        endpoint_fitted_coefficient=fitted,
        endpoint_fit_scope='Unrestricted diagnostic fit, not a physical coefficient supplied by notes; its negative sign violates the tested nonnegative quadratic storage class.',
        maximum_saved_time_fit_defect=abs(residuals[i]),defect_time=rows[i]['time'],signed_defect=residuals[i]))
assert hashes=={str(p):sha(p) for p in paths+[history_path]}
result=dict(checked_utc=datetime.now(timezone.utc).isoformat(),read_only=True,solver_steps=0,
    saved_states_checked=len(rows),unresolved_endpoint=last['unresolved_history_endpoint'],unresolved_rate_integral=last['unresolved_history_rate'],
    candidates=candidates,max_diffusion_integration_by_parts_defect=max(abs(r['discrete_diffusion_integration_by_parts_defect']) for r in rows),
    sources_and_states_unchanged=True,input_sha256=hashes,script_sha256=sha(Path(__file__)),
    limitations=['Finite saved experiment, not a continuum trajectory proof',
        'Excludes nonnegative constant multiples and nonnegative combinations of these zero-initial quadratic quantities as payment of the positive net residual',
        'Does not exclude general nonlinear, nonlocal, cross-coupled or history-dependent storage',
        'Endpoint coefficient fits are diagnostic and not source-derived energy laws'])
with (OUT/'saved-norm-history.csv').open('w',newline='') as f:
    w=csv.DictWriter(f,list(rows[0]));w.writeheader();w.writerows(rows)
(OUT/'saved-norm-check.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k!='input_sha256'},indent=2))
