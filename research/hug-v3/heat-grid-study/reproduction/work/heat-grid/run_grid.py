"""Threshold-1 grid refinements with signed heat tags and exact write payloads."""
import os,sys
for key in ['OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','MKL_NUM_THREADS']:os.environ[key]='1'
sys.dont_write_bytecode=True
import argparse,csv,hashlib,importlib.util,json,time,traceback
from datetime import datetime,timezone
from pathlib import Path
import numpy as np
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1];OUT=ROOT/'outputs/heat-grid'
p=argparse.ArgumentParser();p.add_argument('mode',choices=['pilot','run']);p.add_argument('--n',type=int,required=True);p.add_argument('--dt',type=float,default=.002);a=p.parse_args()
assert a.n in [16,24,32,40] and a.dt in [.002,.001] and (a.dt==.002 or a.n==40)
sys.path[:0]=[str(HERE/('declared-n'+str(a.n))),str(HERE/'reference/study')]
import preflight,breathing
from structural_hug import Config,HEADER
spec=importlib.util.spec_from_file_location('frozen_heat_account',HERE/'reference/run_heat.py');heat=importlib.util.module_from_spec(spec);spec.loader.exec_module(heat)
NAMES=heat.NAMES
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(p):return json.loads(Path(p).read_text(encoding='utf-8-sig'))
def dump(p,x):Path(p).parent.mkdir(parents=True,exist_ok=True);Path(p).write_text(json.dumps(x,indent=2,allow_nan=False)+'\n',encoding='utf-8')
def stamp():return datetime.now(timezone.utc).isoformat()
def frozen():
 x=load(HERE/'inputs.json')
 for rel,h in x.items():assert sha(HERE/rel)==h,rel
 return x
def rounded_velocity(solver,grid_velocity,points):
 freq=np.rint(solver.freq[np.abs(solver.freq)<solver.n/3]).astype(int);idx=freq%solver.n
 coeff=solver.hat(grid_velocity)[np.ix_(idx,idx,idx)]/solver.n**3
 phase=np.exp(2j*np.pi*(breathing.wrap(points)+.5)[:,:,None]*freq)
 xsum=np.tensordot(phase[:,0],coeff,axes=(1,0));xysum=np.einsum('pj,pjkc->pkc',phase[:,1],xsum)
 return np.einsum('pk,pkc->pc',phase[:,2],xysum).real
original_velocity=breathing.fluid_velocity;breathing.fluid_velocity=rounded_velocity
def setup():
 inputs=frozen();case=preflight.approve('heat_grid_n'+str(a.n));assert case['config']['n']==a.n and case['config']['threshold']==1
 with (HERE/'reference/study/marker-seeds.csv').open(newline='') as f:trail=breathing.Trail(list(csv.DictReader(f)))
 solver=breathing.ComparisonSolver(Config(**case['config']),.5,.6,trail);s=solver.initial();old=heat.load_state(HERE/'reference/state-0000.npz');s['observer_X']=old['observer_X'].copy()
 if a.n==16:
  for k,v in old.items():np.testing.assert_allclose(s[k],v,rtol=0,atol=3e-16,err_msg=k)
  s=old
 return solver,s,case,inputs
def pilot():
 solver,s,case,inputs=setup();t=time.monotonic();native=solver.step(0.,s,a.dt)
 tags=heat.HeatAccount(solver,s,a.dt);solver.rhs=tags.rhs;actual=tags.step(0.,s)
 same={k:native[k].tobytes()==actual[k].tobytes() for k in native};assert all(same.values())
 solver.rhs=tags.native;breathing.fluid_velocity=original_velocity;uncorrected=solver.step(0.,s,a.dt);breathing.fluid_velocity=rounded_velocity
 unaffected={k:native[k].tobytes()==uncorrected[k].tobytes() for k in native if k!='observer_X'};assert all(unaffected.values())
 points=np.array([[.123,-.187,.34],[-.21,.1,-.44]]);m=max(abs(np.rint(solver.freq[np.abs(solver.freq)<solver.n/3]).astype(int)))
 g=np.stack([np.sin(2*np.pi*m*(solver.xyz[...,0]+.5)),np.cos(2*np.pi*m*(solver.xyz[...,1]+.5)),np.sin(2*np.pi*(solver.xyz[...,2]+.5))],-1)
 expected=np.stack([np.sin(2*np.pi*m*(points[:,0]+.5)),np.cos(2*np.pi*m*(points[:,1]+.5)),np.sin(2*np.pi*(points[:,2]+.5))],-1)
 error=float(abs(rounded_velocity(solver,g,points)-expected).max());assert error<1e-12
 # Benchmark several evolving tagged steps, not just zero-flow initialization.
 solver.rhs=tags.rhs;current=actual;begin=time.monotonic()
 for frame in range(1,5):current=tags.step(frame*a.dt,current)
 elapsed=(time.monotonic()-begin)/4
 r={'status':'PASS','grid':a.n,'actual_step':a.dt,'runner_sha256':sha(__file__),'input_manifest_sha256':sha(HERE/'inputs.json'),'tagged_native_arrays_bitwise_equal':same,'passive_correction_other_arrays_unchanged':unaffected,'passive_index_correction_position_difference':float(abs(native['observer_X']-uncorrected['observer_X']).max()),'analytic_Fourier_sample_error':error,'tag_reconstruction':tags.max_reconstruction,'seconds_per_early_tagged_step':elapsed,'estimated_run_minutes_from_early_steps':elapsed*1.6/a.dt/60,'verified_utc':stamp()}
 dump(OUT/f'pilot-n{a.n}.json',r);print(json.dumps(r),flush=True)
def global_row(tags,t,side,s):
 means=tags.q.mean(axis=(0,1,2));expected=tags.source_totals.copy();expected[0]+=tags.initial_mean
 err=float(abs(means-expected).max());tags.max_tag_mean_error=max(tags.max_tag_mean_error,err)
 ledger=float(s['ledger'][3])-tags.initial_ledger;residual=float(s['g'][...,4].mean())-(tags.initial_mean+ledger+tags.write_total);tags.max_budget=max(tags.max_budget,abs(residual))
 assert tags.max_budget<1e-12 and tags.max_tag_mean_error<1e-14
 row={'time':t,'side':side,'thermal_mean':float(s['g'][...,4].mean()),'continuous_ledger':ledger,'write_total':tags.write_total,'budget_residual':residual,'reconstruction_max':float(abs(tags.q.sum(axis=-1)-s['g'][...,4]).max()),'temperature_min':float((1+s['g'][...,4]).min())}
 for i,name in enumerate(NAMES):row[name+'_mean']=float(means[i]);row[name+'_expected_mean']=float(expected[i])
 return row
def run():
 tag=f'n{a.n}_dt'+str(a.dt).replace('.','p');folder=OUT/tag;folder.mkdir(parents=True,exist_ok=True);assert not (folder/'status.json').exists(),'Existing run: inspect before restart'
 pilot=load(OUT/f'pilot-n{a.n}.json');assert pilot['status']=='PASS' and pilot['runner_sha256']==sha(__file__)
 solver,s,case,inputs=setup();tags=heat.HeatAccount(solver,s,a.dt);solver.rhs=tags.rhs
 events={round(e['end']/a.dt):e for e in case['events']};starts={};steps=round(1.6/a.dt);rows=[];writes=[];checks=[];fields=[];native=[];frames=[];times=[];sides=[];totals=[];births=0
 begin=time.monotonic();source_hash=sha(__file__);status={'status':'running','run':tag,'grid':a.n,'actual_step':a.dt,'started_utc':stamp(),'completed_steps':0,'total_steps':steps};dump(folder/'status.json',status)
 def save(t,side):frames.append(round(t/a.dt));times.append(t);sides.append(side);fields.append(tags.q.copy());native.append(s['g'].copy());totals.append(tags.source_totals.copy())
 try:
  for frame in range(steps+1):
   t=round(frame*a.dt,12)
   if frame:
    s=tags.step(round((frame-1)*a.dt,12),s);tail=s['observer_X'][-2:].copy();points,added=solver.trail.refine(s['observer_X'][:-2],t);s['observer_X']=np.vstack([points,tail]);births+=len(added)
   assert all(np.isfinite(v).all() for v in s.values()) and np.isfinite(tags.q).all()
   event=events.get(frame)
   if event:
    rows.append(global_row(tags,t,'before_write',s));save(t,'before_write');before=s;record=solver.make_event(before,starts.pop(event['event_id']),event)
    payload=solver.fabric.payload(record);s,account=solver.write_event(before,record);slot=account['slot'];sl=slice(slot*solver.fabric.bits_per_slot,(slot+1)*solver.fabric.bits_per_slot)
    for k in before:
     if k not in ['b','g','write_work']:np.testing.assert_array_equal(s[k],before[k])
    np.testing.assert_array_equal(s['g'][...,:4],before['g'][...,:4]);tags.write(before,s,event,account)
    decoded=next(r for _,r in solver.read_material(s) if r['event_id']==event['event_id']);assert solver.fabric.payload(decoded)==payload
    bits=np.unpackbits(np.frombuffer(payload,dtype=np.uint8),bitorder='little');target=solver.c.rest_amplitude*(2*bits.astype(float)-1);weights=solver.fabric.weight[sl];q=weights*solver.c.stroke_drag*(target-before['b'][sl])**2/solver.c.stroke_duration
    assert abs(float(q.sum())-account['heat'])<1e-18
    edge=2*HEADER*8;regions={'header':q[:edge],'strain':q[edge:-32],'checksum':q[-32:]}
    (folder/'records').mkdir(exist_ok=True);(folder/'records'/f'write-{event["event_id"]}.bin').write_bytes(payload)
    np.savez_compressed(folder/'records'/f'write-{event["event_id"]}.npz',before_b=before['b'][sl],weights=weights,target=target,cell_heat=q,prewrite_F=before['F'],material_X=before['X'],raw_strain=record['delta_E'],quantized_strain=decoded['delta_E'])
    writes.append({'event_id':event['event_id'],'time':t,'account':account,'payload_sha256':hashlib.sha256(payload).hexdigest(),'payload_bytes':len(payload),'one_bits':int(bits.sum()),'region_heat':{k:float(v.sum()) for k,v in regions.items()},'deposited_mean':float((s['g'][...,4]-before['g'][...,4]).mean()),'birth_centroid':tags.birth_centers[3+event['event_id']].tolist(),'decoded_strain_error':float(abs(decoded['delta_E']-record['delta_E']).max()),'native_other_fields_preserved_by_write':True})
   for e in case['events']:
    if round(e['start']/a.dt)==frame:starts[e['event_id']]=s['F'].copy()
   side='after_write' if event else 'at';rows.append(global_row(tags,t,side,s))
   if frame%round(.1/a.dt)==0:save(t,side)
   if a.n==16 and frame<=600 and frame%50==0:
    old=heat.load_state(ROOT/'work/heat-follow/inputs/baseline'/f'state-{frame:04d}.npz');errors={k:float(abs(s[k]-v).max()) for k,v in old.items()};assert max(errors.values())<3e-13,(t,errors);checks.append({'time':t,'maximum_array_error':max(errors.values())})
   if frame%round(.1/a.dt)==0:
    status.update(completed_steps=frame,model_time=t,elapsed_seconds=time.monotonic()-begin);dump(folder/'status.json',status);print(json.dumps(status),flush=True)
  assert not starts and len(writes)==3 and sha(__file__)==source_hash and frozen()==inputs
  with (folder/'history.csv').open('w',newline='',encoding='utf-8') as f:w=csv.DictWriter(f,list(rows[0]));w.writeheader();w.writerows(rows)
  np.savez_compressed(folder/'fields.npz',frame=frames,time=times,side=np.array(sides),components=np.array(fields),native_g=np.array(native),source_totals=np.array(totals),birth_centers=np.array([tags.birth_centers[i] for i in [3,4,5]]),birth_fields=np.stack([tags.birth_fields[i] for i in [3,4,5]],axis=-1),component_names=np.array(NAMES))
  np.savez_compressed(folder/'exit-state.npz',**s)
  result={'run':tag,'status':'completed','grid':a.n,'actual_step':a.dt,'end':1.6,'threshold':1,'writes':writes,'baseline_checks':checks,'additional_observer_births':births,'recorded_rows':len(rows),'field_snapshots':len(fields),'max_field_reconstruction':tags.max_reconstruction,'max_rhs_reconstruction':tags.max_rhs_reconstruction,'max_budget_residual':tags.max_budget,'max_tag_mean_error':tags.max_tag_mean_error,'minimum_unfiltered_net_viscous':tags.minimum_net_viscous,'minimum_unfiltered_structural_release':tags.minimum_structural,'maximum_extraction_fraction_of_viscous_heating':tags.maximum_extraction_ratio,'runner_sha256':source_hash,'input_manifest_sha256':sha(HERE/'inputs.json'),'input_files_sha256':inputs,'runtime':{'python':sys.version,'numpy':np.__version__},'source_unchanged':True,'completed_utc':stamp(),'elapsed_seconds':time.monotonic()-begin,'files_sha256':{p.relative_to(folder).as_posix():sha(p) for p in folder.rglob('*') if p.is_file() and p.name!='status.json'}}
  dump(folder/'receipt.json',result);status.update(status='completed',completed_steps=steps,elapsed_seconds=result['elapsed_seconds']);dump(folder/'status.json',status);print(json.dumps({'completed':tag,'seconds':result['elapsed_seconds']}),flush=True)
 except BaseException as exc:
  status.update(status='failed',error=repr(exc),traceback=traceback.format_exc());dump(folder/'status.json',status);raise
if a.mode=='pilot':pilot()
else:run()
