"""Combine the measured carrying history and inspect the unchanged force field."""
import json,csv,hashlib
from pathlib import Path
from datetime import datetime,timezone
import numpy as np
ROOT=Path(__file__).resolve().parents[2];WORK=ROOT/'work/unwrapped-history'
OUT=ROOT/'outputs/unwrapped-carrying-history'
with (OUT/'stage-work.csv').open() as f:stage=list(csv.DictReader(f))
num=lambda key:np.array([float(r[key]) for r in stage]).reshape(600,2)
dt=.002
work=dt/2*np.sum(num('AS_power'),axis=1)
mean=dt/2*np.sum(num('mean_power'),axis=1)
fluct=dt/2*np.sum(num('fluctuation_power'),axis=1)
bulk=dt/2*np.sum(num('mean_velocity'),axis=1)
result=json.loads((OUT/'path-results-12-16.json').read_text())
for end in result['endpoints']:
    if not end['sample'].startswith('volume_'):
        end['relative_work_error']=None;end['work_minus_ledger']=None
(OUT/'path-results-12-16.json').write_text(json.dumps(result,indent=2)+'\n')
with (OUT/'path-history-12-16.csv').open() as f:reader=csv.DictReader(f);columns=reader.fieldnames;rows=list(reader)
for row in rows:
    if not row['sample'].startswith('volume_'):row['work_minus_ledger']=''
with (OUT/'path-history-12-16.csv').open('w',newline='') as f:
    w=csv.DictWriter(f,fieldnames=columns);w.writeheader();w.writerows(rows)
with np.load(WORK/'force-history.npz',allow_pickle=False) as z:h=z['final'];force_stages=z['stages']
saved=Path(r'$USER_HOME\Documents\Codex\2026-11-10\lo\work\threshold-one\threshold-1')
with np.load(saved/'fields.npz',allow_pickle=False) as z:velocity_stages=z['stages']
spectral_power=np.real(np.sum(np.conj(velocity_stages[...,0])*force_stages,axis=(2,3,4)))
resolved_power_error=float(np.max(abs(spectral_power-num('AS_power'))))
assert resolved_power_error<1e-16
freq=np.arange(-5,6);grid=np.arange(16)/16-.5
phase=np.exp(2j*np.pi*(grid+.5)[:,None]*freq)
line_integrals=np.einsum('yk,kl,zl->yz',phase,h[5],phase).real
iz=int(np.argmax(np.ptp(line_integrals,axis=0)))
iy0=int(np.argmax(line_integrals[:,iz]));iy1=int(np.argmin(line_integrals[:,iz]))
y0,y1,z=float(grid[iy0]),float(grid[iy1]),float(grid[iz])
circulation=float(line_integrals[iy0,iz]-line_integrals[iy1,iz])
# Independent quadrature on each horizontal edge, at two sample densities.
def horizontal_integral(y,z,n):
    x=np.arange(n)/n-.5
    px=np.exp(2j*np.pi*(x+.5)[:,None]*freq)
    py=np.exp(2j*np.pi*(y+.5)*freq);pz=np.exp(2j*np.pi*(z+.5)*freq)
    return float(np.einsum('xk,klm,l,m->x',px,h,py,pz).real.mean())
quadrature={str(n):horizontal_integral(y0,z,n)-horizontal_integral(y1,z,n) for n in (32,64)}
assert max(abs(v-circulation) for v in quadrature.values())<1e-15
curl_rms=float(np.sqrt(np.sum(np.abs(h)**2*((2*np.pi*freq[None,:,None])**2+(2*np.pi*freq[None,None,:])**2))))
finals={r['sample']:r for r in result['endpoints']};fine=finals['volume_16'];coarse=finals['volume_12']
series={name:[r for r in rows if r['sample']==name] for name in ('volume_12','volume_16')}
history_error={name:max(abs(float(r['work_minus_ledger'])) for r in rr) for name,rr in series.items()}
W=result['reference_ledger'];assert abs(sum(work)-W)<1e-18
assert abs(sum(mean)+sum(fluct)-W)<1e-18
assert abs(fine['relative_work_error'])<1e-4
assert abs(fine['relative_work_error'])<abs(coarse['relative_work_error'])
summary=dict(checked_utc=datetime.now(timezone.utc).isoformat(),AS_work=W,
    max_resolved_force_power_error=resolved_power_error,
    path_work=fine['path_work'],path_work_error_ppm=fine['relative_work_error']*1e6,
    coarse_path_work_error_ppm=coarse['relative_work_error']*1e6,
    max_absolute_history_work_error=history_error,
    mean_motion_work=float(sum(mean)),mean_motion_share_percent=float(100*sum(mean)/W),
    local_motion_work=float(sum(fluct)),local_motion_share_percent=float(100*sum(fluct)/W),
    bulk_unwrapped_displacement=float(sum(bulk)),
    endpoint_height_release=-fine['endpoint_height_energy'],endpoint_height_share_percent=-100*fine['endpoint_height_energy']/W,
    activation_history_correction=fine['activation_history_correction'],activation_history_share_percent=100*fine['activation_history_correction']/W,
    endpoint_trapezoid_vs_native_stage_work=fine['endpoint_trapezoid_work']-fine['path_work'],
    discrete_summation_by_parts_residual=fine['summation_by_parts_residual'],
    closed_rectangle_probe=dict(time=1.2,field='Fourier-resolved AS force, frozen at this saved time; diagnostic curve, not an actual parcel trajectory',vertices=[[-.5,y0,z],[.5,y0,z],[.5,y1,z],[-.5,y1,z],[-.5,y0,z]],horizontal_leg_integrals=[float(line_integrals[iy0,iz]),-float(line_integrals[iy1,iz])],vertical_leg_work=0,closed_loop_work=circulation,quadrature_crosschecks=quadrature,curl_rms=curl_rms,interpretation='Nonzero work on a contractible closed rectangle in unwrapped space; periodic winding alone cannot explain it.'),
    scope='Fixed saved spatial grid and native time step. Refinement changes only passive volume quadrature; no proof of continuum convergence or independently specified gravity reservoir.')
earlier=json.loads((ROOT/'outputs/carrying-gravity-energy/saved-frame-check.json').read_text())
saved=Path(r'$USER_HOME\Documents\Codex\2026-11-10\lo\work\threshold-one\threshold-1')
for frame in ('state-0000.npz','state-0600.npz'):
    wanted=next(h for p,h in earlier['inputs_sha256'].items() if p.endswith(frame))
    assert hashlib.sha256((saved/frame).read_bytes()).hexdigest()==wanted
total_residual=earlier['energy_change']-earlier['work']['breathing']-earlier['work']['write']-fine['path_work']
summary['total_energy_balance_with_path_account']=dict(residual=total_residual,residual_ppm_of_energy_change=1e6*total_residual/earlier['energy_change'],energy_source='Previously verified read-only evaluations; current original-frame hashes match exactly',path_reservoir_change=-fine['path_work'])
(OUT/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps(summary,indent=2))
