"""Independent heat-grid recounts, shared observation grids and exact record comparisons."""
import os
for k in ['OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','MKL_NUM_THREADS']:os.environ[k]='1'
import argparse,csv,hashlib,json,struct,zlib
from pathlib import Path
import numpy as np
from scipy.fft import fftn,ifftn
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1];OUT=ROOT/'outputs/heat-grid'
TAGS=['n16_dt0p002','n24_dt0p002','n32_dt0p002','n40_dt0p002','n40_dt0p001'];NAMES=['initial_warmth','net_viscous_heat','structural_release','write_0','write_1','write_2']
TIMES=[.4,.8,1.2];HEADER_BYTES=46
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(p):return json.loads(Path(p).read_text(encoding='utf-8-sig'))
def dump(p,x):Path(p).write_text(json.dumps(x,indent=2,allow_nan=False)+'\n',encoding='utf-8')
def readrows(p):
 with Path(p).open(newline='',encoding='utf-8') as f:return list(csv.DictReader(f))
def key(t,side):return (round(float(t),10),str(side))
def wrap(x):return (x+.5)%1-.5
def xyz(n):
 x=np.arange(n)/n-.5;return np.stack(np.meshgrid(x,x,x,indexing='ij'),-1)
def coefficients(q):
 n=q.shape[0];freq=np.rint(np.fft.fftfreq(n)*n).astype(int);f=freq[np.abs(freq)<n/3];h=fftn(q,axes=(0,1,2))/n**3
 return f,h[np.ix_(f%n,f%n,f%n)]
def sample(h,f,n):
 pad=np.zeros((n,n,n),complex);pad[np.ix_(f%n,f%n,f%n)]=h*n**3;return ifftn(pad,axes=(0,1,2)).real
def metrics(q,center,coordinates=None):
 mean=float(q.mean());negative=float(-q[q<0].sum()/q.size);square=float(np.einsum('ijk,ijk->',q,q)/q.size)
 coordinates=xyz(q.shape[0]) if coordinates is None else coordinates;mask=np.sum(wrap(coordinates-center)**2,axis=-1)>.25**2
 return {'integral':mean,'negative_integral':negative,'negative_to_net_ratio':negative/mean if mean else 0.,'effective_volume':mean*mean/square if square else 0.,'peak':float(q.max()),'outside025_integral':float(q[mask].sum()/q.size),'outside025_share':float(q[mask].sum()/q.size/mean) if mean else 0.}
def summarize(tag):
 folder=OUT/tag;r=load(folder/'receipt.json');assert r['status']=='completed' and r['threshold']==1 and r['source_unchanged']
 for rel,h in r['files_sha256'].items():assert sha(folder/rel)==h,rel
 rows=readrows(folder/'history.csv');index={key(x['time'],x['side']):x for x in rows};assert len(index)==len(rows)==round(1.6/r['actual_step'])+4
 z=np.load(folder/'fields.npz',allow_pickle=False);q=z['components'];g=z['native_g'];assert q.shape==g.shape[:-1]+(6,) and z['component_names'].tolist()==NAMES
 maxreconstruction=float(abs(q.sum(axis=-1)-g[...,4]).max());assert maxreconstruction<1e-12
 nativecoords=xyz(r['grid']);commoncoords={n:xyz(n) for n in [96,128]};readouts=[];maxmean=0.;maxomitted=0.;maxnormal=0.;maxquadshare=0.
 for j,(t,side) in enumerate(zip(z['time'],z['side'])):
  row=index[key(t,side)];maxmean=max(maxmean,abs(float(g[j,...,4].mean())-float(row['thermal_mean'])))
  for c,name in enumerate(NAMES):maxmean=max(maxmean,abs(float(q[j,...,c].mean())-float(row[name+'_mean'])))
  for i,write in enumerate(r['writes']):
   if t<TIMES[i] or (t==TIMES[i] and side=='before_write'):continue
   own=q[j,...,3+i];h=write['account']['heat'];center=z['birth_centers'][i];nat=metrics(own,center,nativecoords);f,hats=coefficients(own/h)
   omitted=float(abs(sample(hats,f,r['grid'])*h-own).max());maxomitted=max(maxomitted,omitted);assert omitted<1e-15
   common={}
   for n in [96,128]:
    normalized=sample(hats,f,n);m=metrics(normalized,center,commoncoords[n]);common[str(n)]=m;maxnormal=max(maxnormal,abs(m['integral']-1))
   maxquadshare=max(maxquadshare,abs(common['96']['outside025_share']-common['128']['outside025_share']))
   readouts.append({'snapshot':j,'time':float(t),'side':str(side),'event_id':i,'native':nat,'common':common})
 assert maxmean<1e-14 and maxnormal<1e-10
 budgets=[];sums=[];tags=[];initial=float(rows[0]['thermal_mean'])
 for row in rows:
  thermal=float(row['thermal_mean']);budgets.append(abs(thermal-initial-float(row['continuous_ledger'])-float(row['write_total'])));sums.append(abs(thermal-sum(float(row[n+'_mean']) for n in NAMES)))
  tags.extend(abs(float(row[n+'_mean'])-float(row[n+'_expected_mean'])) for n in NAMES)
 assert max(budgets)<1e-12 and max(sums)<1e-12 and max(tags)<1e-14
 writes=[]
 for i,t in enumerate(TIMES):
  active=[x for x in readouts if x['event_id']==i];birth=next(x for x in active if x['time']==t and x['side']=='after_write');end=next(x for x in active if x['time']==1.6);h=r['writes'][i]['account']['heat']
  before=index[(t,'before_write')];assert float(before[f'write_{i}_mean'])==0
  data={'event_id':i,'write_time':t,'deposited_heat':h,'earlier_write_heat_at_this_write':sum(float(before[f'write_{k}_mean']) for k in range(i)),'final_integral':float(rows[-1][f'write_{i}_mean']),'maximum_integral_drift':max(abs(float(row[f'write_{i}_mean'])-h) for row in rows if float(row[f'write_{i}_expected_mean'])>0),'maximum_negative_to_net_ratio':max(x['native']['negative_to_net_ratio'] for x in active),'birth_centroid':z['birth_centers'][i].tolist(),'birth_common':birth['common'],'final_common':end['common'],'recorded_crc':r['writes'][i]['account']['crc']}
  for label,readout in [('birth',birth),('final',end)]:
   for field in ['effective_volume','peak','outside025_share','negative_to_net_ratio']:data[label+'_'+field]=readout['native'][field]
  writes.append(data)
 final=rows[-1];parts={name:float(final[name+'_mean']) for name in NAMES};total=float(final['thermal_mean']);write_total=sum(parts[n] for n in NAMES[3:])
 summary={'run':tag,'grid':r['grid'],'dt':r['actual_step'],'rows':len(rows),'snapshots':len(q),'writes':writes,'final_temperature_mean_excess':total,'initial_temperature_mean_excess':initial,'final_components':parts,'final_write_total':write_total,'final_write_share_of_excess':write_total/total,'total_increase_from_initial':total-initial,'write_share_of_thermal_increase':write_total/(total-initial),'minimum_absolute_temperature':min(float(row['temperature_min']) for row in rows),'minimum_unfiltered_net_viscous':r['minimum_unfiltered_net_viscous'],'maximum_extraction_fraction_of_viscous_heating':r['maximum_extraction_fraction_of_viscous_heating'],'baseline_checkpoints':len(r['baseline_checks']),'baseline_max_array_error':max((x['maximum_array_error'] for x in r['baseline_checks']),default=None)}
 verify={'saved_grid_values_recounted':int(q.size+g.size),'snapshot_means_max_error':maxmean,'reconstruction_max':maxreconstruction,'budget_max':max(budgets),'component_sum_max':max(sums),'tag_integral_max':max(tags),'discarded_unresolved_roundoff_max':maxomitted,'normalized_integral_error':maxnormal,'quadrature_96_vs_128_outside_share_max':maxquadshare,'source_receipt_sha256':sha(folder/'receipt.json')}
 z.close();result={'summary':summary,'recount':verify,'readouts':readouts};dump(folder/'analysis.json',result);print(json.dumps({'analyzed':tag,'recount':verify}),flush=True);return result
def record_comparison(left,right,i):
 folders=[OUT/tag for tag in [left,right]];raw=[(d/'records'/f'write-{i}.bin').read_bytes() for d in folders];assert len(raw[0])==len(raw[1])
 z=[np.load(d/'records'/f'write-{i}.npz',allow_pickle=False) for d in folders];assert np.array_equal(z[0]['weights'],z[1]['weights'])
 for b in raw:assert struct.unpack('<I',b[-4:])[0]==zlib.crc32(b[:-4])
 bits=[np.unpackbits(np.frombuffer(b,dtype=np.uint8),bitorder='little') for b in raw];parts={'header':slice(0,HEADER_BYTES),'strain':slice(HEADER_BYTES,-4),'checksum':slice(-4,None)};regions={}
 for name,sl in parts.items():
  aa=np.frombuffer(raw[0][sl],dtype=np.uint8);bb=np.frombuffer(raw[1][sl],dtype=np.uint8);aw=np.frombuffer(raw[0][sl],dtype='<u2');bw=np.frombuffer(raw[1][sl],dtype='<u2')
  regions[name]={'bytes':len(aa),'changed_bytes':int(np.count_nonzero(aa!=bb)),'words':len(aw),'changed_words':int(np.count_nonzero(aw!=bw)),'changed_bits':sum(int(v).bit_count() for v in np.bitwise_xor(aa,bb)),'left_ones':sum(int(v).bit_count() for v in aa),'right_ones':sum(int(v).bit_count() for v in bb)}
 # Same material quadrature and cell weights; only the recorded target and prior b enter this cost.
 w=z[0]['weights'];target_left=.02*(2*bits[0].astype(float)-1);target_right=.02*(2*bits[1].astype(float)-1);b0=z[0]['before_b'];b1=z[1]['before_b']
 cost=lambda target,b:w*.05*(target-b)**2/.02
 c0=cost(target_left,b0);fixed=cost(target_left,b1);c1=cost(target_right,b1)
 for j,c in enumerate([c0,c1]):np.testing.assert_array_equal(c,z[j]['cell_heat'])
 for j,target in enumerate([target_left,target_right]):np.testing.assert_array_equal(target,z[j]['target'])
 total=float(c1.sum()-c0.sum());encoding=float((c1-fixed).sum());state=float((fixed-c0).sum());residual=total-encoding-state;assert abs(residual)<1e-18
 costparts={}
 for name,sl in {'header':slice(0,8*HEADER_BYTES),'strain':slice(8*HEADER_BYTES,-32),'checksum':slice(-32,None)}.items():costparts[name]={'actual_heat_difference':float(c1[sl].sum()-c0[sl].sum()),'changed_targets_at_right_prestate':float((c1[sl]-fixed[sl]).sum()),'prior_state_at_fixed_left_targets':float((fixed[sl]-c0[sl]).sum())}
 result={'left':left,'right':right,'event_id':i,'left_payload_sha256':hashlib.sha256(raw[0]).hexdigest(),'right_payload_sha256':hashlib.sha256(raw[1]).hexdigest(),'payload_equal':raw[0]==raw[1],'payload_bytes':len(raw[0]),'regions':regions,'total_changed_bits':sum(v['changed_bits'] for v in regions.values()),'total_changed_words':sum(v['changed_words'] for v in regions.values()),'both_crc':[struct.unpack('<I',b[-4:])[0] for b in raw],'heat_difference':total,'changed_targets_at_right_prestate':encoding,'prior_state_at_fixed_left_targets':state,'partition_residual':residual,'region_cost_partition':costparts,'scope':'A fixed-target write-cost diagnostic on saved pre-write cell states. This does not replace any write or evolve a counterfactual fluid trajectory.'}
 strain0,strain1=[zz['raw_strain'] for zz in z];decoded0,decoded1=[zz['quantized_strain'] for zz in z]
 result['strain_change']={'raw_max_absolute':float(abs(strain1-strain0).max()),'raw_rms_difference':float(np.sqrt(np.mean((strain1-strain0)**2))),'left_raw_rms':float(np.sqrt(np.mean(strain0**2))),'decoded_max_absolute':float(abs(decoded1-decoded0).max()),'changed_quantized_components':int(np.count_nonzero(decoded0!=decoded1)),'components':int(strain0.size)}
 headers=[struct.unpack('<23h',b[:HEADER_BYTES]) for b in raw]
 result['header_word_changes']=[{'index':j,'left':x,'right':y,'region':'actions' if j>=16 else 'other_header'} for j,(x,y) in enumerate(zip(*headers)) if x!=y]
 assert result['strain_change']['changed_quantized_components']==regions['strain']['changed_words']
 for zz in z:zz.close()
 return result
def compare(left,right,kind,analyses):
 aa,bb=[analyses[t] for t in [left,right]];zs=[np.load(OUT/t/'fields.npz',allow_pickle=False) for t in [left,right]];assert np.array_equal(zs[0]['time'],zs[1]['time']) and np.array_equal(zs[0]['side'],zs[1]['side'])
 fields=[z['components'] for z in zs];results=[];quadrature_error=0.
 for i in range(3):
  h0,h1=[a['summary']['writes'][i]['deposited_heat'] for a in [aa,bb]];indexed=[{(r['snapshot'],r['event_id']):r for r in a['readouts']} for a in [aa,bb]];history=[]
  for j,(t,side) in enumerate(zip(zs[0]['time'],zs[0]['side'])):
   if (j,i) not in indexed[0]:continue
   coeffs=[coefficients(q[j,...,3+i]/h) for q,h in zip(fields,[h0,h1])];l1={}
   for n in [96,128]:
    q0,q1=[sample(hats,f,n) for f,hats in coeffs];l1[str(n)]=float(np.mean(abs(q1-q0)))
   quadrature_error=max(quadrature_error,abs(l1['96']-l1['128']));m0,m1=[idx[(j,i)]['common']['96'] for idx in indexed]
   controls=[idx[(j,i)]['common']['128'] for idx in indexed]
   history.append({'snapshot':j,'time':float(t),'side':str(side),'normalized_field_L1':l1['96'],'L1_observation128':l1['128'],'outside_share_difference':abs(m1['outside025_share']-m0['outside025_share']),'effective_volume_relative_difference':abs(m1['effective_volume']-m0['effective_volume'])/m0['effective_volume'],'peak_relative_difference':abs(h1*m1['peak']-h0*m0['peak'])/abs(h0*m0['peak']),'normalized_peak_relative_difference':abs(m1['peak']-m0['peak'])/abs(m0['peak']),'observation128_outside_share_difference':abs(controls[1]['outside025_share']-controls[0]['outside025_share'])})
  worst={name:max(row[name] for row in history) for name in ['normalized_field_L1','outside_share_difference','effective_volume_relative_difference','peak_relative_difference','normalized_peak_relative_difference']}
  amount=abs(h1-h0)/abs(h0);conditions={'deposited_heat':amount<=.01,'normalized_shape':worst['normalized_field_L1']<=.01,'outside_share':worst['outside_share_difference']<=.005,'effective_volume':worst['effective_volume_relative_difference']<=.01,'peak':worst['peak_relative_difference']<=.01}
  results.append({'event_id':i,'relative_deposited_heat_change':amount,**worst,'criteria':conditions,'all_criteria_pass':all(conditions.values()),'history':history,'record_bits':record_comparison(left,right,i)})
 totals0=np.cumsum([w['deposited_heat'] for w in aa['summary']['writes']]);totals1=np.cumsum([w['deposited_heat'] for w in bb['summary']['writes']]);cumulative=float(np.max(abs(totals1-totals0)/abs(totals0)))
 quadrature=max(aa['recount']['quadrature_96_vs_128_outside_share_max'],bb['recount']['quadrature_96_vs_128_outside_share_max'])
 result={'left':left,'right':right,'kind':kind,'writes':results,'maximum_relative_cumulative_write_heat':cumulative,'cumulative_heat_pass':cumulative<=.01,'observation_quadrature_L1_difference_max':quadrature_error,'observation_quadrature_share_difference_max':quadrature,'quadrature_control_pass':quadrature_error<=.001 and quadrature<=.0005,'all_heat_criteria_pass':all(x['all_criteria_pass'] for x in results) and cumulative<=.01,'thermal_increase_endpoint_relative_difference':abs(bb['summary']['total_increase_from_initial']-aa['summary']['total_increase_from_initial'])/abs(aa['summary']['total_increase_from_initial'])}
 for z in zs:z.close()
 print(json.dumps({'compared':left+' -> '+right,'heat_criteria_pass':result['all_heat_criteria_pass'],'quadrature_control_pass':result['quadrature_control_pass']}),flush=True);return result
def main():
 parser=argparse.ArgumentParser();parser.add_argument('--run');parser.add_argument('--pair',nargs=2);args=parser.parse_args()
 if args.run:summarize(args.run);return
 def cached(left,right,kind,analyses):
  path=OUT/f'comparison-{left}--{right}.json'
  binding={'analyzer_sha256':sha(__file__),'receipts':[sha(OUT/t/'receipt.json') for t in [left,right]],'analyses':[sha(OUT/t/'analysis.json') for t in [left,right]]}
  if path.exists():
   previous=load(path)
   if previous.get('binding')==binding:return previous['comparison']
  result=compare(left,right,kind,analyses);dump(path,{'binding':binding,'comparison':result});return result
 if args.pair:
  analyses={t:load(OUT/t/'analysis.json') if (OUT/t/'analysis.json').exists() else summarize(t) for t in args.pair}
  cached(*args.pair,'time_step' if args.pair==TAGS[3:] else 'grid',analyses);return
 analyses={t:load(OUT/t/'analysis.json') if (OUT/t/'analysis.json').exists() else summarize(t) for t in TAGS}
 comparisons=[cached(TAGS[i],TAGS[i+1],'grid',analyses) for i in range(3)]+[cached(TAGS[3],TAGS[4],'time_step',analyses)]
 last0,last1= comparisons[1:3];trend={}
 for key_ in ['relative_deposited_heat_change','normalized_field_L1','outside_share_difference','effective_volume_relative_difference','peak_relative_difference']:
  trend[key_]=all(right[key_]<=left[key_] for left,right in zip(last0['writes'],last1['writes']))
 trend['cumulative_heat']=last1['maximum_relative_cumulative_write_heat']<=last0['maximum_relative_cumulative_write_heat']
 settled=all(c['all_heat_criteria_pass'] and c['quadrature_control_pass'] for c in comparisons[1:]) and all(trend.values())
 result={'status':'completed','observation_grid_for_declared_criteria':96,'observation_quadrature_control':128,'trend_rule':'Every write separately, plus cumulative heat; a maximum over writes cannot hide a growing discrepancy in another write.','runs':[analyses[t]['summary'] for t in TAGS],'independent_recounts':{t:analyses[t]['recount'] for t in TAGS},'comparisons':comparisons,'finest_grid_trend_decreases':trend,'time_step_all_criteria_pass':comparisons[-1]['all_heat_criteria_pass'],'settled_across_tested_grids_by_predeclared_criteria':settled,'reference16_cost_comparisons':[record_comparison(TAGS[0],t,i) for t in TAGS[1:] for i in range(3)],'scope':'Finite grid/time comparisons for the historical threshold-1 breathing-on coupled simulation. Signed source labels and exact record identities are separate measurements. No continuum or physical-retention proof.','attribution':'AI-generated; dictated and directed by NousVolition.'}
 dump(OUT/'analysis.json',result);print(json.dumps({'complete':True,'settled':settled,'time_step_pass':result['time_step_all_criteria_pass'],'trend':trend}),flush=True)
if __name__=='__main__':main()
