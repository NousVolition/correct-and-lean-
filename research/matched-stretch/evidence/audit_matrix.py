"""Audit completed records, retained evidence, and report calculations without advancing a solver."""
from pathlib import Path
from datetime import datetime,timezone
import json,hashlib,sys
import numpy as np
S=Path(r'C:/Users/ziman/Documents/Codex/2026-10-05/ca/work/matched-stretch-study')
C=Path(r'C:/Users/ziman/Documents/Codex/2026-10-09/referenced-chatgpt-conversation-this-is-an')
P=Path(__file__).resolve().parent
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def same(a,b,label):assert np.allclose(a,b,rtol=2e-10,atol=1e-9),(label,a,b)
protocol=read(S/'protocol.json');analysis=read(S/'analysis.json')
assert len(protocol['jobs'])==48
for k,v in protocol['source_hashes'].items():assert sha(S/k)==v
candidates=list(S.glob('completed-*/verification.json'))+list(S.parent.glob('*/matched-verification.json'))+list(S.parent.glob('timestep128-*/verification.json'))+list((C/'outputs/matched-stretch-followup').glob('*/verification*.json'))
candidates += [P/'verification-early64.json',P/'verification-baseline-n256-half.json']
evidence={}
for path in candidates:
 d=read(path)
 if not (str(d.get('status','')).startswith('passed') or d.get('status')=='verified_complete'):continue
 items=[]
 if isinstance(d.get('runs'),list):items=[(x['id'],x.get('result_sha256'),x.get('fields',[])) for x in d['runs'] if x.get('id')]
 elif isinstance(d.get('run'),str):items=[(d['run'],d.get('result_sha256'),d.get('fields',[]))]
 elif isinstance(d.get('result_hashes'),dict):
  items=[(rid,h,[x for x in d.get('fields',[]) if x.get('run')==rid]) for rid,h in d['result_hashes'].items()]
 for rid,h,fields in items:
  if h and len(fields)==41:evidence[rid]=dict(path=path,hash=h,fields=fields,evidence_status=d['status'])
coverage=[];results={};checks=0
oldhashes=[x['old'] for x in protocol.get('implementation_revisions',[])]
for job in protocol['jobs']:
 rid=job['id'];folder=S/'runs'/rid;r=read(folder/'result.json');rows=r['series'];a=analysis['runs'][rid]
 assert r['job']==job and r['status']=='complete' and r['end_time']==.4 and r['last_output']==40 and len(rows)==41
 assert r['source_hashes']==protocol['source_hashes'] or r['source_hashes'] in oldhashes
 assert r['source_hashes']['numerics.py']==protocol['source_hashes']['numerics.py']
 assert r['max_speed_cfl']<.5 and r['field']=='field-040.npy'
 e=evidence[rid];assert sha(folder/'result.json')==e['hash'],rid
 for i,row in enumerate(rows):
  same(row['t'],i*.01,'time')
  assert (folder/f'field-{i:03d}.npy').stat().st_size>0
  assert row['energy']>0 and row['enstrophy']>0 and row['Wmax']>0
  assert abs(row['energy_budget_relative_residual'])<.005
  same(row['energy_budget_relative_residual'],(row['energy']-rows[0]['energy']+row['integrated_viscous_energy_loss'])/rows[0]['energy'],'energy budget')
  same(row['enstrophy_budget_relative_residual'],(row['enstrophy']-rows[0]['enstrophy']-row['integrated_enstrophy_production']+row['integrated_viscous_enstrophy_loss'])/max(rows[0]['enstrophy'],row['enstrophy']),'enstrophy budget')
  same(row['mean_velocity'],rows[0]['mean_velocity'],'mean')
  if i:assert row['I']>rows[i-1]['I']
  checks+=1
 t=np.array([x['t'] for x in rows]);w=np.array([x['Wmax'] for x in rows])
 for k,v in dict(through=.4,peak_W=max(w),peak_time_sampled=t[np.argmax(w)],peak_over_initial=max(w)/w[0],I_final=rows[-1]['I'],screen_failures=sum(not x['resolved_screen'] for x in rows),max_abs_energy_budget_residual=max(abs(x['energy_budget_relative_residual']) for x in rows)).items():same(a[k],v,(rid,k))
 assert a['status']=='complete' and a['category']=='resolution screen failed'
 if job['family']=='perturbation':
  dv=np.array([x['D_relative_initial_baseline_l2'] for x in rows]);ly=np.log(dv);tc=t-t.mean()
  slope=np.sum(tc*(ly-ly.mean()))/np.sum(tc*tc)
  for k,v in dict(D_initial=dv[0],D_final=dv[-1],endpoint_log_growth_rate=np.log(dv[-1]/dv[0])/.4,least_squares_log_growth_rate=slope).items():same(a['perturbation'][k],v,(rid,k))
 for key in ['Wmax','enstrophy']:
  v=np.array([x[key] for x in rows]);rec=a['recurrence'][key]
  trend=np.sum((t-t.mean())*(v-v.mean()))/np.sum((t-t.mean())**2)
  de=v-v.mean()-trend*(t-t.mean())
  corr=np.array([np.dot(de[:len(de)-i],de[i:]) for i in range(len(de))]);corr/=corr[0]
  window=.5-.5*np.cos(2*np.pi*np.arange(len(v))/len(v))
  power=np.abs(np.fft.rfft(de*window))**2/window.sum()**2;power[1:]*=2
  same(rec['return_x'],v[:-1],'return x');same(rec['return_y'],v[1:],'return y')
  same(rec['detrended_autocorrelation'],corr,'autocorrelation')
  same(rec['detrended_power'],power,'temporal spectrum')
  same(rec['frequency'],np.fft.rfftfreq(len(v),.01),'frequency')
 coverage.append(dict(run=rid,result_sha256=e['hash'],evidence_file=str(e['path'].relative_to(C)) if e['path'].is_relative_to(C) else str(e['path'].relative_to(S.parent)),evidence_sha256=sha(e['path']),fields=41,verification='new saved-field audit' if e['path'].parent==P else 'retained independent evidence; result hash binding rechecked',historical_metadata_revision=r['source_hashes']!=protocol['source_hashes']))
 results[rid]=r
comparisons={}
pairs=[('grid-64-128','baseline-n64-base','baseline-n128-base'),('grid-128-256','baseline-n128-base','baseline-n256-base')]+[(f'timestep-{n}',f'baseline-n{n}-base',f'baseline-n{n}-half') for n in (64,128,256)]
for name,ka,kb in pairs:
 out={}
 for key in ('Wmax','I','energy','enstrophy','max_to_mean_spin'):
  av=np.array([r[key] for r in results[ka]['series']]);bv=np.array([r[key] for r in results[kb]['series']])
  out[key]=dict(relative_curve_l2=float(np.sqrt(np.sum((av-bv)**2)/np.sum(bv*bv))),relative_max_error=float(max(abs(av-bv))/max(abs(bv))),relative_endpoint_difference=float(abs(av[-1]-bv[-1])/abs(bv[-1])))
  for k,v in out[key].items():same(analysis['comparisons'][name]['fields'][key][k],v,(name,key,k))
 comparisons[name]=out
# Verify retained spectrum shell sums against their saved diagnostics.
for rid in ['baseline-n256-base','baseline-n256-half']:
 d=read(evidence[rid]['path'])
 for sp in d['spectra']:
  row=results[rid]['series'][int(round(sp['t']*100))]
  same(sum(sp['energy']),row['energy'],'energy shells')
  same(sum(sp['enstrophy']),row['enstrophy'],'enstrophy shells')
final=read(P/'verification-baseline-n256-half.json');assert final['status']=='passed' and len(final['paired_field_comparisons'])==41
out=dict(status='passed',checked_utc=datetime.now(timezone.utc).isoformat(),jobs=48,saved_observation_records_checked=checks,new_saved_fields_remeasured=574,retained_verified_jobs=34,new_simulations=0,coverage=coverage,comparisons=comparisons,source_hashes=protocol['source_hashes'],protocol_sha256=sha(S/'protocol.json'),analysis_sha256=sha(S/'analysis.json'),scope='All 48 complete result records, report summaries, finite-time rates, recurrence transforms, five refinement comparisons, budget algebra, spectrum shell totals and saved-field coverage audited. 574 fields newly remeasured: final 41 at grid256 and 533 early grid64. Retained independent evidence covers the other 34 jobs with unchanged result hashes. Only 41 historical grid256 baseline fields were freshly rehashed; earlier fields were not all reread. Saved stage integrals retained; no trajectories repeated.',limitations=['Raw-strain periodic joins nonsmooth','Initial global maxima outside central tube','All runs have spatial screen failures','128 and 256 timestep screens fail','Finite-time perturbation rates are not asymptotic Lyapunov exponents','No physical stability threshold inferred'])
assert not (P/'matrix-verification.json').exists()
(P/'matrix-verification.json').write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps({k:v for k,v in out.items() if k in ('status','jobs','saved_observation_records_checked','new_saved_fields_remeasured','retained_verified_jobs')}))
