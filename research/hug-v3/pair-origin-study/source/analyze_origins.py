"""Independent saved-state geometry, identities and context-origin recount."""
import csv,hashlib,json,sys,zlib,struct
from pathlib import Path
from decimal import Decimal
import numpy as np
from scipy.ndimage import map_coordinates
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'outputs/pair25-origins';LEAN=ROOT/'outputs/pair25-origins-lean'
TAGS=['n40_dt0p0005','n48_dt0p0005','n48_dt0p00025'];RADII=[.05,.075,.1]
CLASSES=['stayed','left','returned','arrived','visited','outside']
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def readrows(p):
    with p.open(newline='',encoding='utf-8') as f:return list(csv.DictReader(f))
def dump(p,x):p.write_text(json.dumps(x,indent=2,allow_nan=False)+'\n',encoding='utf-8')
def csvout(p,rows):
    with p.open('w',newline='',encoding='utf-8') as f:
        w=csv.DictWriter(f,list(rows[0]));w.writeheader();w.writerows(rows)
def distances(points,centers):
    # Independent periodic minimum-image expression, including boundary wrap.
    d=((points[:,:,None,:]-centers[:,None,:,:]+.5)%1)-.5
    mag=np.linalg.norm(d,axis=-1)
    return np.concatenate([mag,mag.min(axis=-1,keepdims=True)],axis=-1)
def classify(history):
    first=bool(history[0]);last=bool(history[-1])
    if first:return 'left' if not last else 'stayed' if bool(history.all()) else 'returned'
    return 'arrived' if last else 'visited' if bool(history.any()) else 'outside'
def masks(histories):
    packed=np.packbits(histories,axis=0,bitorder='little')
    return [int.from_bytes(packed[:,i].tobytes(),'little') for i in range(histories.shape[1])]
def analyze():
    LEAN.mkdir(parents=True,exist_ok=True);(LEAN/'source-data').mkdir(exist_ok=True)
    summaries=[];identities=[];crossings=[];runs=[];context_endpoints=[];history_rows=[];field_rows=[];hashes={};memberships={}
    for run_index,tag in enumerate(TAGS):
        folder=OUT/tag;result=json.loads((folder/'result.json').read_text())
        assert json.loads((folder/'status.json').read_text())['status']=='complete'
        assert result['code_sha256']==sha(ROOT/'work/pair25-origins/run_origins.py')
        assert result['start']==1.2 and result['end']==1.3 and result['radii']==RADII
        for rel,digest in result['input_hashes'].items():assert sha(ROOT/rel)==digest
        for name in ['tracked-states.npz','record-payloads.npz','context-origins.npz','result.json','window-census.csv','context-window-origins.csv','context-point-origins.csv','exit-state.npz']:
            hashes[(folder/name).relative_to(ROOT).as_posix()]=sha(folder/name)
        prior=ROOT/'outputs/pair25-retention'/tag
        with np.load(folder/'exit-state.npz') as new,np.load(prior/'exit-state.npz') as old:
            exact={k:new[k].tobytes()==old[k].tobytes() for k in old.files}
            assert len(exact)==17 and all(exact.values())
            native_final=old['g'][...,3].copy()
        with np.load(prior/'entry-state.npz') as z:native_entry=z['g'][...,3].copy()
        with np.load(folder/'tracked-states.npz') as z:
            times=z['times'];observers=z['observer_positions'];material=z['material_positions'];F=z['material_F'];m=z['material_m']
            assert np.array_equal(z['observer_ids'],np.arange(926)) and np.array_equal(z['material_ids'],np.arange(384))
        steps=result['steps'];every=round(.002/result['dt'])
        assert len(times)==steps+1 and np.allclose(times,1.2+np.arange(steps+1)*result['dt'],rtol=0,atol=2e-15)
        assert observers.shape==(steps+1,926,3) and material.shape==(steps+1,384,3)
        assert F.shape==(steps+1,384,3,3) and m.shape==(steps+1,384,24,2)
        assert all(np.isfinite(x).all() for x in [observers,material,F,m])
        for filename,index in [('entry-state.npz',0),('exit-state.npz',-1)]:
            with np.load(prior/filename) as native:
                for stored,key in [(observers,'observer_X'),(material,'X'),(F,'F'),(m,'m')]:
                    assert np.array_equal(stored[index],native[key]),(tag,filename,key)
        for identity in range(384):
            field_rows.append({'run':tag,'id':identity,'F_max_change':float(abs(F[-1,identity]-F[0,identity]).max()),'m_max_change':float(abs(m[-1,identity]-m[0,identity]).max()),'m_min_step_change':float(np.diff(m[:,identity],axis=0).min())})
        with np.load(prior/'pair-positions.npz') as z:assert np.array_equal(observers[::every][:,[825,850]],z['positions'])
        centers=observers[:,[825,850]];observer_ids=np.array([i for i in range(926) if i not in [825,850]])
        census={(int(r['step']),r['population'],float(r['radius']),r['view']):r for r in readrows(folder/'window-census.csv')}
        assert len(census)==(steps+1)*18
        saved_members={};boundary_min=1.;boundary_ambiguous=0
        for population,points,ids in [('material',material,np.arange(384)),('observer',observers[:,observer_ids],observer_ids)]:
            dist=distances(points,centers)
            member=dist[:,:,None,:]<=np.asarray(RADII)[None,None,:,None]
            saved_members[population]=member;memberships[(tag,population)]=member[:, :,1,2].copy()
            for ri,radius in enumerate(RADII):
                for vi,view in enumerate(['A','B','union']):
                    inside=member[:,:,ri,vi];classes=[classify(inside[:,i]) for i in range(len(ids))]
                    counts={c:classes.count(c) for c in CLASSES}
                    assert sum(counts.values())==len(ids)
                    summary={'run':tag,'population':population,'radius':radius,'view':view,'entry':int(inside[0].sum()),'exit':int(inside[-1].sum()),**counts}
                    assert summary['entry']==counts['stayed']+counts['left']+counts['returned']
                    assert summary['exit']==counts['stayed']+counts['returned']+counts['arrived']
                    summaries.append(summary)
                    for si,t in enumerate(times):
                        row=census[(si,population,radius,view)]
                        assert int(row['inside'])==int(inside[si].sum()) and int(row['outside'])==len(ids)-int(inside[si].sum())
                        margin=abs(dist[si,:,vi]-radius)
                        assert int(row['near_boundary'])==int((margin<=1e-8).sum())
                        boundary_min=min(boundary_min,float(margin.min()));boundary_ambiguous+=int((margin<=1e-8).sum())
                    for index,identity in enumerate(ids):
                        mask=inside[:,index]
                        changes=np.flatnonzero(mask[1:]!=mask[:-1])+1
                        item={'run':tag,'population':population,'radius':radius,'view':view,'id':int(identity),'classification':classes[index],'entry_inside':bool(mask[0]),'exit_inside':bool(mask[-1]),'crossings':len(changes),'minimum_boundary_distance':float(abs(dist[:,index,vi]-radius).min())}
                        if population=='material':
                            item.update(F_max_change=float(abs(F[-1,index]-F[0,index]).max()),m_max_change=float(abs(m[-1,index]-m[0,index]).max()),m_min_step_change=float(np.diff(m[:,index],axis=0).min()))
                        else:item.update(F_max_change='',m_max_change='',m_min_step_change='')
                        identities.append(item)
                        for step in changes:
                            crossings.append({'run':tag,'population':population,'radius':radius,'view':view,'id':int(identity),'event':'arrive' if mask[step] else 'leave','last_time_before':float(times[step-1]),'first_time_after':float(times[step]),'distance_before':float(dist[step-1,index,vi]),'distance_after':float(dist[step,index,vi])})
            bits=masks(member[:,:,1,2])
            for identity,bits_value in zip(ids,bits):history_rows.append({'run':tag,'population':population,'id':int(identity),'steps':steps,'membership_bits':str(bits_value)})
        np.savez_compressed(LEAN/'source-data'/f'{tag}-membership.npz',times=times,material=saved_members['material'],observer=saved_members['observer'],material_ids=np.arange(384),observer_ids=observer_ids,radii=np.asarray(RADII))
        with np.load(folder/'record-payloads.npz') as z:
            ep,ei,pa,keys=[z[k].copy() for k in ['entry_payloads','entry_ids','payloads','ids']]
            assert list(ei)==[0,1,2,-1] and pa.shape[0]==steps+1
            assert all(np.array_equal(p,ep) and np.array_equal(k,ei) for p,k in zip(pa,keys))
            for value in ep[:3]:
                raw=value.tobytes();assert zlib.crc32(raw[:-4])==struct.unpack('<I',raw[-4:])[0]
        # Complete original bytes retained for the source-to-Lean data check.
        (LEAN/'source-data'/f'{tag}-payloads.npz').write_bytes((folder/'record-payloads.npz').read_bytes())
        origin_table=readrows(folder/'context-window-origins.csv');point_table=readrows(folder/'context-point-origins.csv')
        assert len(origin_table)==153 and len(point_table)==306
        rowmap={(round(float(r['time']),9),float(r['radius'])):r for r in origin_table};assert len(rowmap)==153
        pointmap={(round(float(r['time']),9),float(r['radius']),r['point']):r for r in point_table};assert len(pointmap)==306
        with np.load(folder/'context-origins.npz') as z:
            q=z['fields'];q0=z['initial'];qt=z['times']
            assert np.array_equal(z['radii'],np.array(RADII))
        assert q.shape==(51,result['n'],result['n'],result['n'],7)
        assert np.array_equal(q[0],q0)
        assert np.array_equal(qt,times[::every]) and np.isfinite(q).all()
        assert np.array_equal(q0[...,6],np.zeros_like(native_entry))
        for i in range(3):
            np.testing.assert_allclose(q[0,...,i]+q[0,...,i+3]+q[0,...,6],native_entry,rtol=0,atol=1e-12)
            np.testing.assert_allclose(q[-1,...,i]+q[-1,...,i+3]+q[-1,...,6],native_final,rtol=0,atol=1e-12)
        n=result['n'];axis=np.arange(n)/n-.5;xyz=np.stack(np.meshgrid(axis,axis,axis,indexing='ij'),-1)
        initial_sums=q0.mean(axis=(0,1,2));max_recount=0.;max_old_defect=0.;max_mix_defect=0.
        for si,t in enumerate(qt):
            center=centers[si*every]
            delta=((xyz[...,None,:]-center+.5)%1)-.5
            d=np.linalg.norm(delta,axis=-1).min(axis=-1)
            interp_xyz=(((center+.5)%1)*n).T
            sampled=np.stack([map_coordinates(q[si,...,c],interp_xyz,order=1,mode='grid-wrap',prefilter=False) for c in range(7)],axis=-1)
            for ri,radius in enumerate(RADII):
                row=rowmap[(round(float(t),9),radius)];mask=d<=radius
                if si==0:
                    assert np.array_equal(q0[...,ri],np.where(mask,native_entry,0.))
                    assert np.array_equal(q0[...,ri+3],np.where(~mask,native_entry,0.))
                expected={'entry_inside_context':initial_sums[ri],
                          'original_inside_now':np.where(mask,q[si,...,ri],0.).mean(),
                          'original_elsewhere_now':np.where(~mask,q[si,...,ri],0.).mean(),
                          'outside_origin_inside_now':np.where(mask,q[si,...,ri+3],0.).mean(),
                          'later_source_inside_now':np.where(mask,q[si,...,6],0.).mean(),
                          'original_global_now':q[si,...,ri].mean(),'later_source_global_now':q[si,...,6].mean()}
                for name,value in expected.items():max_recount=max(max_recount,abs(float(row[name])-float(value)))
                assert int(row['window_grid_cells'])==int(mask.sum())
                origin_defect=float(row['entry_inside_context'])-float(row['original_inside_now'])-float(row['original_elsewhere_now'])
                mix_defect=float(row['total_inside_now'])-sum(float(row[k]) for k in ['original_inside_now','outside_origin_inside_now','later_source_inside_now'])
                max_old_defect=max(max_old_defect,abs(origin_defect));max_mix_defect=max(max_mix_defect,abs(mix_defect))
                for p,name in enumerate(['A','B']):
                    point=pointmap[(round(float(t),9),radius,name)]
                    for field,index in [('original_inside',ri),('outside_origin',ri+3),('later_source',6)]:
                        max_recount=max(max_recount,abs(float(point[field])-float(sampled[p,index])))
                    assert abs(float(point['native_context'])-sum(float(point[k]) for k in ['original_inside','outside_origin','later_source']))<=1e-12
                if si==50:
                    initial=float(row['entry_inside_context']);current=float(row['total_inside_now'])
                    context_endpoints.append({**{k:(v if k=='run' else float(v)) for k,v in row.items()},'original_inside_fraction_of_entry':float(row['original_inside_now'])/initial,'original_elsewhere_fraction_of_entry':float(row['original_elsewhere_now'])/initial,'outside_origin_fraction_of_current':float(row['outside_origin_inside_now'])/current,'later_source_fraction_of_current':float(row['later_source_inside_now'])/current})
        assert max_recount<=1e-12 and max_old_defect<=1e-12 and max_mix_defect<=1e-12
        for name in ['context-window-origins.csv','context-point-origins.csv','result.json']:
            (LEAN/'source-data'/f'{tag}-{name}').write_bytes((folder/name).read_bytes())
        runs.append({'run':tag,'steps':steps,'native_exit_arrays_identical':exact,'minimum_boundary_distance':boundary_min,'ambiguous_membership_rows':boundary_ambiguous,'source_value_recount_error':max_recount,'origin_account_error':max_old_defect,'mixture_account_error':max_mix_defect,'saved_field_component_minimum':float(q.min()),'min_material_m_step_change':float(np.diff(m,axis=0).min()),'all_material_F_changed':bool(np.all(np.max(abs(F[-1]-F[0]),axis=(1,2))>0)),'memory_payload_checks':3*(steps+1),'runtime_checks':result['criteria']})
        del q,q0,observers,material,F,m
    comparisons=[]
    for first,last,kind in [(TAGS[0],TAGS[1],'grid40_48'),(TAGS[1],TAGS[2],'time48_half')]:
        for pop in ['material','observer']:
            a=memberships[(first,pop)];b=memberships[(last,pop)][::2] if kind=='time48_half' else memberships[(last,pop)]
            assert a.shape==b.shape
            comparisons.append({'comparison':kind,'population':pop,'different_membership_observations':int((a!=b).sum()),'ids_with_any_difference':int((a!=b).any(axis=0).sum()),'different_endpoint_memberships':int((a[-1]!=b[-1]).sum()),'scope':'Same stored identities, primary union window, common native times; not a continuum-convergence criterion.'})
    csvout(OUT/'identity-summary.csv',summaries);csvout(OUT/'identity-classification.csv',identities)
    if crossings:csvout(OUT/'crossings.csv',crossings)
    csvout(LEAN/'source-data/history-numbers.csv',history_rows)
    csvout(LEAN/'source-data/material-field-changes.csv',field_rows)
    result={'status':'independent saved-data recount completed','primary_radius':.075,'radii':RADII,'pair_id':24,'interval':[1.2,1.3],'runs':runs,'primary_union':[s for s in summaries if s['radius']==.075 and s['view']=='union'],'context_endpoints':context_endpoints,'identity_comparisons':comparisons,'shared_payload_checks':sum(r['memory_payload_checks'] for r in runs),'source_inputs_sha256':hashes,'limits':['Window membership is not physical ownership.','C is a signed context scalar, not water mass.','Between-step crossings and complete microscopic retention are unproved.','Stage extrema are runtime records; saved-state recount does not replay every stage.','No new GitHub publication in this task.']}
    dump(OUT/'analysis.json',result);dump(LEAN/'source-data/analysis.json',result)
    print(json.dumps({k:result[k] for k in ['status','primary_union','identity_comparisons','shared_payload_checks']},indent=2))
    return result
if __name__=='__main__':analyze()
