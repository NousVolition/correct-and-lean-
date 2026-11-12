"""Independent recount of following-label observations and saved context fields."""
import csv,hashlib,json,sys,struct,zlib
from pathlib import Path
import numpy as np
from scipy.ndimage import map_coordinates
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'outputs/observer540-872';LEAN=ROOT/'outputs/observer540-872-lean';DATA=LEAN/'source-data'
TAGS=['n40_dt0p0005','n48_dt0p0005','n48_dt0p00025'];IDS=[540,872];RADII=[.05,.075,.1];REGIONS=['near540_only','near872_only','near_both','near_neither','later_source'];CLASSES=['stayed','left','returned','arrived','visited','outside']
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def dump(p,x):p.write_text(json.dumps(x,indent=2,allow_nan=False)+'\n',encoding='utf-8')
def rows(p):
    with p.open(newline='',encoding='utf-8') as f:return list(csv.DictReader(f))
def csvout(p,rs):
    with p.open('w',newline='',encoding='utf-8') as f:
        w=csv.DictWriter(f,list(rs[0]));w.writeheader();w.writerows(rs)
def distance(a,b):return np.linalg.norm((a-b+.5)%1-.5,axis=-1)
def classify(h):
    if h[0]:return 'left' if not h[-1] else 'stayed' if h.all() else 'returned'
    return 'arrived' if h[-1] else 'visited' if h.any() else 'outside'
def analyze():
    DATA.mkdir(parents=True,exist_ok=True)
    hashes={};summaries=[];histories=[];crossings=[];window_endpoints=[];point_endpoints=[];run_checks=[];pair_origin_rows=[];neighbors={};field_records=[]
    old_analysis=read(ROOT/'outputs/pair25-origins/analysis.json')
    old_crossings=rows(ROOT/'outputs/pair25-origins/crossings.csv')
    for tag in TAGS:
        folder=OUT/tag;result=read(folder/'result.json');status=read(folder/'status.json')
        assert status['status']=='complete' and result['code_sha256']==sha(ROOT/'work/observer540-872/run_follow.py')
        for path,digest in result['input_hashes'].items():assert sha(ROOT/path)==digest
        for name in ['point-stencils.npz','origin-fields.npz','point-history.csv','window-history.csv','memory-payloads.npz','result.json','exit-state.npz']:
            hashes[(folder/name).relative_to(ROOT).as_posix()]=sha(folder/name)
        old=ROOT/'outputs/pair25-origins'/tag;prior=ROOT/'outputs/pair25-retention'/tag
        for name in ['tracked-states.npz','context-origins.npz']:
            path=(old/name).relative_to(ROOT).as_posix();assert sha(old/name)==old_analysis['source_inputs_sha256'][path];hashes[path]=sha(old/name)
        with np.load(prior/'entry-state.npz') as z:entry_C=z['g'][...,3].copy();entry_positions=z['observer_X'].copy()
        with np.load(folder/'exit-state.npz') as new,np.load(old/'exit-state.npz') as original:
            exact={k:new[k].tobytes()==original[k].tobytes() for k in original.files};assert len(exact)==17 and all(exact.values());exit_C=new['g'][...,3].copy()
        with np.load(old/'tracked-states.npz') as z:
            times=z['times'];observer_positions=z['observer_positions'];material_positions=z['material_positions'];F=z['material_F'];m=z['material_m']
        with np.load(folder/'point-stencils.npz') as z:stencils={k:z[k].copy() for k in z.files}
        positions=stencils['positions'];dt=result['dt'];steps=result['steps'];n=result['n']
        assert np.array_equal(positions,observer_positions[:,[540,872,825,850]])
        assert len(times)==steps+1 and np.allclose(times,1.2+np.arange(steps+1)*dt,rtol=0,atol=2e-15)
        assert np.array_equal(stencils['observer_ids'],IDS)
        point_table=rows(folder/'point-history.csv');point_map={(int(r['step']),int(r['observer'])):r for r in point_table}
        assert len(point_map)==len(point_table)==2*(steps+1)
        offsets=np.array([[a,b,c] for a in [0,1] for b in [0,1] for c in [0,1]])
        xyz=((positions[:,:2]+.5)%1)*n;base=np.floor(xyz).astype(int);frac=xyz-base
        nodes=(base[:,:,None,:]+offsets)%n;weights=np.prod(np.where(offsets,frac[:,:,None,:],1-frac[:,:,None,:]),axis=-1)
        assert np.array_equal(nodes,stencils['nodes']) and np.allclose(weights,stencils['weights'],rtol=0,atol=2e-15)
        values=np.einsum('spo,spof->spf',weights,stencils['native_corners']);qvalues=np.einsum('spo,spof->spf',weights,stencils['origin_corners'])
        point_error=max(float(abs(values-stencils['native_values']).max()),float(abs(qvalues-stencils['origin_values']).max()))
        assert point_error<=1e-12
        assert np.max(abs(stencils['origin_corners'].sum(axis=-1)-stencils['native_corners'][...,3]))<=1e-12
        delta=positions[:,:2,None]-positions[:,None,2:];mag=distance(delta,0.)
        pair_distance=mag.min(axis=-1);inside=pair_distance<=.1
        for si in range(steps+1):
            for pi,identity in enumerate(IDS):
                row=point_map[(si,identity)]
                assert float(row['time'])==times[si] and (row['inside_pair_wide']=='True')==inside[si,pi]
                for name,value in [('distance_A',mag[si,pi,0]),('distance_B',mag[si,pi,1]),('distance_pair_union',pair_distance[si,pi])]:assert abs(float(row[name])-value)<=2e-15
                for j,name in enumerate(['u_x','u_y','u_z','C','theta']):assert abs(float(row[name])-values[si,pi,j])<=1e-12
                for j,name in enumerate(REGIONS):assert abs(float(row[name])-qvalues[si,pi,j])<=1e-12
                assert abs(sum(float(row[k]) for k in REGIONS)-float(row['C']))<=1e-12
        for pi,identity in enumerate(IDS):
            flips=np.flatnonzero(inside[1:,pi]!=inside[:-1,pi])+1;assert len(flips)==1
            j=int(flips[0]);event='leave' if identity==540 else 'arrive'
            source=next(r for r in old_crossings if r['run']==tag and int(r['id'])==identity and r['view']=='union')
            assert float(source['last_time_before'])==times[j-1] and float(source['first_time_after'])==times[j]
            record={'run':tag,'observer':identity,'event':event,'step_before':j-1,'step_after':j,'time_before':float(times[j-1]),'time_after':float(times[j]),'distance_before':float(pair_distance[j-1,pi]),'distance_after':float(pair_distance[j,pi]),'C_before':float(values[j-1,pi,3]),'C_after':float(values[j,pi,3]),'theta_before':float(values[j-1,pi,4]),'theta_after':float(values[j,pi,4])}
            for k,name in enumerate(REGIONS):record[name+'_before']=float(qvalues[j-1,pi,k]);record[name+'_after']=float(qvalues[j,pi,k])
            crossings.append(record)
            point_endpoints.append({'run':tag,'observer':identity,'C_entry':float(values[0,pi,3]),'C_exit':float(values[-1,pi,3]),'theta_entry':float(values[0,pi,4]),'theta_exit':float(values[-1,pi,4]),'original_near_fraction_at_point_exit':float((qvalues[-1,pi,pi]+qvalues[-1,pi,2])/values[-1,pi,3]),'exit_origins':{k:float(qvalues[-1,pi,j]) for j,k in enumerate(REGIONS)}})
        memberships={};neighbor_min=1.;ambiguous=0
        for pi,identity in enumerate(IDS):
            for pop,allpoints,allids in [('material',material_positions,np.arange(384)),('observer',observer_positions,np.arange(926))]:
                ids=allids if pop=='material' else allids[allids!=identity]
                points=allpoints[:,ids];d=distance(points,positions[:,pi,None]);member=d[:,:,None]<=np.array(RADII)
                memberships[f'{identity}_{pop}']=member;memberships[f'{identity}_{pop}_ids']=ids
                neighbors[(tag,identity,pop)]=member[:,:,1].copy()
                for ri,radius in enumerate(RADII):
                    h=member[:,:,ri];classes=[classify(h[:,i]) for i in range(len(ids))]
                    summaries.append({'run':tag,'observer':identity,'population':pop,'radius':radius,'entry':int(h[0].sum()),'exit':int(h[-1].sum()),**{c:classes.count(c) for c in CLASSES}})
                    margin=abs(d-radius);neighbor_min=min(neighbor_min,float(margin.min()));ambiguous+=int((margin<=1e-8).sum())
                packed=np.packbits(member[:,:,1],axis=0,bitorder='little')
                for k,other in enumerate(ids):histories.append({'run':tag,'observer':identity,'population':pop,'id':int(other),'steps':steps,'bits':str(int.from_bytes(packed[:,k].tobytes(),'little'))})
                if pop=='material':
                    for other in ids[member[0,:,1]]:
                        field_records.append({'run':tag,'observer':identity,'material_id':int(other),'classification':classify(member[:,other,1]),'F_max_change':float(abs(F[-1,other]-F[0,other]).max()),'m_max_change':float(abs(m[-1,other]-m[0,other]).max()),'m_min_step_change':float(np.diff(m[:,other],axis=0).min())})
        np.savez_compressed(DATA/f'{tag}-membership.npz',times=times,radii=RADII,**memberships)
        with np.load(folder/'origin-fields.npz') as z:q=z['fields'];q0=z['initial'];field_steps=z['steps'];assert list(z['region_names'])==REGIONS
        assert np.array_equal(q[0],q0) and list(field_steps)==result['saved_field_steps']
        axis=np.arange(n)/n-.5;grid=np.stack(np.meshgrid(axis,axis,axis,indexing='ij'),axis=-1)
        da=distance(grid,positions[0,0])<=.075;db=distance(grid,positions[0,1])<=.075
        masks=[da&~db,db&~da,da&db,~da&~db]
        for i,mask in enumerate(masks):assert np.array_equal(q0[...,i],np.where(mask,entry_C,0.))
        assert not q0[...,4].any()
        assert np.max(abs(q[0].sum(axis=-1)-entry_C))<=1e-12 and np.max(abs(q[-1].sum(axis=-1)-exit_C))<=1e-12
        window_table=rows(folder/'window-history.csv');window_map={(int(r['step']),int(r['observer'])):r for r in window_table}
        assert len(window_map)==len(window_table)==len(field_steps)*2
        initial=q0.mean(axis=(0,1,2));window_error=0.;scipy_error=0.
        for qi,step in enumerate(field_steps):
            for pi,identity in enumerate(IDS):
                mask=distance(grid,positions[step,pi])<=.075;amount=np.where(mask[...,None],q[qi],0.).mean(axis=(0,1,2));row=window_map[(int(step),identity)]
                for j,name in enumerate(REGIONS):window_error=max(window_error,abs(float(row[name])-amount[j]))
                oldtag=q[qi,...,pi]+q[qi,...,2]
                expected={'entry_original':initial[pi]+initial[2],'original_inside':amount[pi]+amount[2],'original_elsewhere':np.where(~mask,oldtag,0.).mean(),'other_origin_inside':amount[1-pi]+amount[3],'later_source_inside':amount[4]}
                for name,value in expected.items():window_error=max(window_error,abs(float(row[name])-value))
                assert int(row['window_cells'])==mask.sum()
                assert abs(float(row['entry_original'])-float(row['original_inside'])-float(row['original_elsewhere']))<=1e-12
                assert abs(float(row['native_total_inside'])-float(row['original_inside'])-float(row['other_origin_inside'])-float(row['later_source_inside']))<=1e-12
                sample_xyz=(((positions[step,pi]+.5)%1)*n).reshape(3,1)
                independently=np.array([map_coordinates(q[qi,...,c],sample_xyz,order=1,mode='grid-wrap',prefilter=False)[0] for c in range(5)])
                scipy_error=max(scipy_error,float(abs(independently-qvalues[step,pi]).max()))
                nn=nodes[step,pi];assert np.array_equal(q[qi][nn[:,0],nn[:,1],nn[:,2]],stencils['origin_corners'][step,pi])
                if step==steps:
                    endpoint={k:(v if k=='run' else float(v)) for k,v in row.items()}
                    endpoint['retained_starting_context_fraction']=float(row['original_inside'])/float(row['entry_original'])
                    endpoint['elsewhere_starting_context_fraction']=float(row['original_elsewhere'])/float(row['entry_original'])
                    endpoint['local_total_fraction_of_entry']=float(row['native_total_inside'])/float(row['entry_original'])
                    window_endpoints.append(endpoint)
        assert window_error<=1e-12 and scipy_error<=1e-12
        # Existing pair-wide origins supply a distinct reference, not private cargo.
        with np.load(old/'context-origins.npz') as z:oldq=z['fields'];oldtimes=z['times']
        every=round(.002/dt)
        for si,t in enumerate(oldtimes):
            step=si*every;xyz=(((positions[step,:2]+.5)%1)*n).T
            samples=np.stack([map_coordinates(oldq[si,...,c],xyz,order=1,mode='grid-wrap',prefilter=False) for c in [2,5,6]],axis=-1)
            assert np.max(abs(samples.sum(axis=-1)-values[step,:,3]))<=1e-12
            for pi,identity in enumerate(IDS):pair_origin_rows.append({'run':tag,'time':float(t),'observer':identity,'pair_initial_inside_origin':float(samples[pi,0]),'pair_initial_outside_origin':float(samples[pi,1]),'later_source':float(samples[pi,2]),'native_C':float(values[step,pi,3])})
        with np.load(folder/'memory-payloads.npz') as z:
            ep=z['entry_payloads'];ei=z['entry_ids'];pa=z['payloads'];keys=z['ids']
            assert list(ei)==[0,1,2,-1] and len(pa)==steps+1
            assert all(np.array_equal(x,ep) for x in pa) and all(np.array_equal(x,ei) for x in keys)
            for value in ep[:3]:raw=value.tobytes();assert zlib.crc32(raw[:-4])==struct.unpack('<I',raw[-4:])[0]
        for name in ['point-stencils.npz','point-history.csv','window-history.csv','memory-payloads.npz','result.json']:(DATA/f'{tag}-{name}').write_bytes((folder/name).read_bytes())
        run_checks.append({'run':tag,'native_exit_arrays_equal':exact,'independent_point_stencil_error':point_error,'independent_field_sample_error':scipy_error,'independent_window_recount_error':window_error,'minimum_neighbor_boundary_distance':neighbor_min,'neighbor_boundary_ambiguous_observations':ambiguous,'shared_payload_comparisons':3*(steps+1),'runtime_criteria':result['criteria'],'sampled_fields':len(field_steps),'entry_overlap_context':float(initial[2]),'entry_original_context_540':float(initial[0]+initial[2]),'entry_original_context_872':float(initial[1]+initial[2]),'shared_entry_material_ids':np.flatnonzero(memberships['540_material'][0,:,1]&memberships['872_material'][0,:,1]).tolist()})
        del q,q0,oldq,F,m,observer_positions,material_positions
    comparisons=[];context_comparisons=[]
    for first,last,kind in [(TAGS[0],TAGS[1],'grid40_48'),(TAGS[1],TAGS[2],'half_time48')]:
        for identity in IDS:
            for pop in ['material','observer']:
                a=neighbors[(first,identity,pop)];b=neighbors[(last,identity,pop)][::2] if kind=='half_time48' else neighbors[(last,identity,pop)]
                assert a.shape==b.shape
                comparisons.append({'comparison':kind,'observer':identity,'population':pop,'different_memberships':int((a!=b).sum()),'ids_with_any_difference':int((a!=b).any(axis=0).sum())})
            first_rows=rows(OUT/first/'window-history.csv');last_rows=rows(OUT/last/'window-history.csv')
            aa={round(float(r['time']),9):r for r in first_rows if int(r['observer'])==identity}
            bb={round(float(r['time']),9):r for r in last_rows if int(r['observer'])==identity}
            common=sorted(set(aa)&set(bb));common=[t for t in common if abs((t-1.2)/.002-round((t-1.2)/.002))<1e-8]
            assert len(common)==51
            metrics={}
            for column in ['original_inside','original_elsewhere','other_origin_inside','later_source_inside','native_total_inside']:
                delta=np.array([100*(float(bb[t][column])/float(bb[t]['entry_original'])-float(aa[t][column])/float(aa[t]['entry_original'])) for t in common])
                metrics[column]={'endpoint_delta_percentage_points':float(delta[-1]),'max_common_time_delta_percentage_points':float(abs(delta).max())}
            context_comparisons.append({'comparison':kind,'observer':identity,'common_times':len(common),'metrics':metrics})
    csvout(OUT/'neighbor-summary.csv',summaries);csvout(DATA/'neighbor-histories.csv',histories);csvout(OUT/'crossing-readouts.csv',crossings);csvout(DATA/'crossing-readouts.csv',crossings)
    csvout(OUT/'entry-material-fields.csv',field_records);csvout(DATA/'entry-material-fields.csv',field_records);csvout(OUT/'pair-wide-origin-readouts.csv',pair_origin_rows);csvout(DATA/'pair-wide-origin-readouts.csv',pair_origin_rows)
    analysis={'status':'independent saved-data recount completed','observer_ids':IDS,'start':1.2,'end':1.3,'primary_local_radius':.075,'pair_crossing_radius':.1,'runs':run_checks,'primary_neighbors':[r for r in summaries if r['radius']==.075],'all_neighbor_summaries':summaries,'crossings':crossings,'window_endpoints':window_endpoints,'point_endpoints':point_endpoints,'neighbor_grid_time_comparisons':comparisons,'shared_payload_comparisons':sum(r['shared_payload_comparisons'] for r in run_checks),'input_hashes':hashes,'new_simulation_scope':'Passive region labels on repeated unchanged native trajectories; native positions, shared states and memory retain their original roles.','limits':['Observers have positions, not separately assigned private memory or material inventories.','C is model context, not water mass.','Overlapping local views are not disjoint parcels.','Physical transfer between observers and complete retention remain unestablished.','Crossing times and the new origin fractions have no declared continuum-convergence result.','Between-step crossings and unsaved full-state intermediate checks are not formal proofs.','Local follow-up only; no new GitHub publication requested.']}
    analysis['context_grid_time_comparisons']=context_comparisons
    dump(OUT/'analysis.json',analysis);dump(DATA/'analysis.json',analysis)
    print(json.dumps({'status':analysis['status'],'primary_neighbors':analysis['primary_neighbors'],'window_endpoints':window_endpoints,'checks':run_checks},indent=2))
if __name__=='__main__':analyze()
