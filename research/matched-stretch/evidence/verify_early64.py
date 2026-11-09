"""Close early 64-grid verification coverage gaps using saved arrays only."""
from pathlib import Path
import os
import sys,json,hashlib,time
import numpy as np
S=Path(os.environ['MATCHED_STRETCH_STUDY'])
P=Path(__file__).resolve().parent
sys.path.insert(0,str(S))
from numerics import Flow
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
dest=P/'verification-early64.json'
assert not dest.exists()
protocol=read(S/'protocol.json')
assert all(sha(S/k)==v for k,v in protocol['source_hashes'].items())
ids=['baseline-n64-base','baseline-n64-half','viscosity-n64-nu0.01','viscosity-n64-nu0.002']
ids += [f'perturb-n64-a{a}-s{s}' for a in ('0.001','0.005','0.01') for s in (101,202,303)]
runs=[];start=time.time()
baseline0=np.fft.irfftn(np.load(S/'runs/baseline-n64-base/field-000.npy'),s=(64,)*3,axes=(-3,-2,-1))
norm0=np.sum(baseline0**2)
for rid in ids:
 folder=S/'runs'/rid;r=read(folder/'result.json');f=Flow(64,r['job']['nu'],workers=1)
 assert r['status']=='complete' and len(r['series'])==41
 init=f.initial()
 if r['job']['family']=='perturbation':init=f.perturb(init,r['job']['amplitude'],r['job']['seed'])
 assert np.array_equal(init,np.load(folder/'field-000.npy'))
 mean=init[:,0,0,0].real/64**3
 maxima={};fields=[]
 for i,row in enumerate(r['series']):
  path=folder/f'field-{i:03d}.npy';h=np.load(path,allow_pickle=False)
  assert h.shape==(3,64,64,33) and h.dtype==np.complex128 and np.isfinite(h).all()
  u=np.fft.irfftn(h,s=(64,)*3,axes=(-3,-2,-1))
  x,y,z=f.k
  curl=1j*np.stack([y*h[2]-z*h[1],z*h[0]-x*h[2],x*h[1]-y*h[0]])
  w=np.fft.irfftn(curl,s=(64,)*3,axes=(-3,-2,-1))
  measured={'Wmax':float(np.sqrt(np.sum(w*w,axis=0)).max()),'energy':float(.5*np.sum(u*u)*f.dx**3),'enstrophy':float(.5*np.sum(w*w)*f.dx**3)}
  if r['job']['family']=='perturbation':
   hb=np.load(S/'runs/baseline-n64-base'/path.name,allow_pickle=False)
   delta=np.fft.irfftn(h-hb,s=(64,)*3,axes=(-3,-2,-1))
   measured['D_relative_initial_baseline_l2']=float(np.sqrt(np.sum(delta*delta)/norm0))
  for k,v in measured.items():
   err=abs(v-row[k])/max(abs(row[k]),1e-15);assert err<1e-10,(rid,i,k,err)
   maxima[k]=max(maxima.get(k,0),err)
  assert np.max(abs(u.mean(axis=(1,2,3))-mean))<1e-10
  fields.append(dict(file=path.name,sha256=sha(path),physical_measurements=measured))
 re=f.observe(h,.4,r['accum'],r['series'][0])
 endpoint={}
 for k in ('enstrophy_production','high_band_energy_fraction','high_band_enstrophy_fraction','energy_budget_relative_residual','enstrophy_budget_relative_residual','divergence_max'):
  err=abs(re[k]-r['series'][-1][k])/max(abs(r['series'][-1][k]),1);assert err<1e-10
  endpoint[k]=err
 runs.append(dict(id=rid,result_sha256=sha(folder/'result.json'),fields=fields,max_relative_errors=maxima,endpoint_errors=endpoint,initial_prescribed=True))
 (P/'early64-progress.json').write_text(json.dumps(dict(status='running',runs_checked=len(runs),total_runs=len(ids),elapsed_seconds=time.time()-start)))
 print(rid,'verified',flush=True)
out=dict(status='passed',new_simulations=0,fields_checked=sum(len(r['fields']) for r in runs),runs=runs,source_hashes=protocol['source_hashes'],protocol_sha256=sha(S/'protocol.json'),elapsed_seconds=time.time()-start,scope='New independent physical-space W, energy, enstrophy and perturbation D measurements for all saved fields of 13 early 64-grid runs. Prescribed initial arrays and frozen endpoint diagnostics checked. Historical evidence preserved; no trajectories repeated.')
dest.write_text(json.dumps(out,indent=2)+'\n')
(P/'early64-progress.json').write_text(json.dumps(dict(status='passed',runs_checked=len(runs),total_runs=len(ids),elapsed_seconds=time.time()-start)))
print('PASSED',out['fields_checked'],flush=True)
