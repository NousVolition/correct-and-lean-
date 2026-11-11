"""Cross-run convergence metrics; no fitted order is assumed."""
import argparse,csv,json,hashlib,time
from pathlib import Path
import numpy as np
from scipy.signal import resample
from run_study import OUT,coeff,curl,on_grid,dump,readcsv

TAGS=['n16_dt0p002','n16_dt0p001','n16_dt0p0005','n24_dt0p0005','n32_dt0p0005','n32_dt0p00025']
PAIRS=[('time16_2_1',TAGS[0],TAGS[1]),('time16_1_half',TAGS[1],TAGS[2]),
       ('space16_24',TAGS[2],TAGS[3]),('space24_32',TAGS[3],TAGS[4]),
       ('time32_half_quarter',TAGS[4],TAGS[5])]
CONVENTIONS=['fixed','reselected']
GAP_COLUMNS=['local_gap','extended_gap','window_benefit','local_closest_arclength','extended_closest_arclength']

def savecsv(path,rows):
    if not rows:return
    with path.open('w',encoding='utf-8',newline='') as f:
        writer=csv.DictWriter(f,list(rows[0]));writer.writeheader();writer.writerows(rows)

def gaps(tag,path=None):
    folder=OUT/tag
    if path is None:
        path=folder/('gaps_grid192_ds1024_consistent.csv' if tag==TAGS[0] else 'gaps_grid192_ds1024.csv')
    rows=readcsv(path)
    times=sorted({float(r['time']) for r in rows})
    data=np.full((len(times),2,25,len(GAP_COLUMNS)),np.nan)
    seen=set()
    for r in rows:
        ix=(times.index(float(r['time'])),CONVENTIONS.index(r['convention']),int(r['seed']))
        assert ix not in seen;seen.add(ix)
        data[ix]=[float(r[k]) for k in GAP_COLUMNS]
    assert np.isfinite(data).all()
    assert data.shape[1:]==(2,25,5)
    return np.asarray(times),data

def common_fields(grid,size=64):
    # Velocity has the retained Fourier cutoff. C retains its complete native
    # finite-volume spectrum, including Nyquist modes. signal.resample correctly
    # splits even-grid Nyquist modes during interpolation to a common grid.
    n=grid.shape[0];f,u=coeff(grid[...,:3],n)
    fields=dict(velocity=on_grid(u,f,size),vorticity=on_grid(curl(u,f),f,size))
    for name,index in [('context',3),('excess_temperature',4)]:
        a=grid[...,index]
        for axis in range(3):a=resample(a,size,axis=axis)
        fields[name]=a
    return fields

def l2(a):
    return float(np.sqrt(np.mean(np.sum(a*a,axis=-1) if a.ndim==4 else a*a)))

def maxnorm(a):
    return float(np.max(np.linalg.norm(a,axis=-1) if a.ndim==4 else abs(a)))

def build(partial=False):
    available=[t for t in TAGS if (OUT/t/'summary.json').exists() and (OUT/t/('gaps_grid192_ds1024_consistent.csv' if t==TAGS[0] else 'gaps_grid192_ds1024.csv')).exists()]
    if not partial:assert available==TAGS,('missing completed runs/measurements',set(TAGS)-set(available))
    if not partial:
        # The independently running finite tracing-control queue can finish
        # shortly after the last integration. Wait for its receipts, never
        # duplicate its measurements or lower the tracing requirement.
        started=time.monotonic()
        while True:
            missing=[t for t in TAGS if not (OUT/t/('gaps_grid256_ds2048_consistent.json' if t==TAGS[0] else 'gaps_grid256_ds2048.json')).exists()]
            if not missing:break
            if time.monotonic()-started>600:raise TimeoutError('Required finer tracing controls not ready: '+str(missing))
            print('Waiting for finer tracing control:',missing,flush=True);time.sleep(20)
    data={};runstats=[];gapstats=[];diagnostics=[];fieldcache={}
    for tag in available:
        summary=json.loads((OUT/tag/'summary.json').read_text(encoding='utf-8'))
        assert summary['full_history'] and summary['steps']==round(1.2/summary['dt'])
        times,values=gaps(tag);assert len(times)==51;data[tag]=values
        with np.load(OUT/tag/'prime-fields.npz') as z:
            gs=z['g'];assert len(gs)==13
        fieldcache[tag]=gs
        ds=json.loads((OUT/tag/'diagnostics.json').read_text(encoding='utf-8'))
        runstats.append(dict(run=tag,n=summary['n'],dt=summary['dt'],steps=summary['steps'],
            elapsed_seconds=summary['elapsed_seconds'],max_energy_balance=max(abs(r['energy_balance']) for r in ds),
            final_energy_balance=ds[-1]['energy_balance'],max_divergence=max(abs(r['div_error']) for r in ds),
            max_context_balance=max(abs(r['C_balance']) for r in ds),max_det_error=max(r['det_error'] for r in ds),
            min_temperature=min(r['min_temperature'] for r in ds),event_crcs='|'.join(str(e['crc']) for e in summary['events'])))
        for r in ds:diagnostics.append(dict(run=tag,**r))
        for c,convention in enumerate(CONVENTIONS):
            for it,t in enumerate(times):
                for k,window in enumerate(['local','extended']):
                    v=values[it,c,:,k]
                    gapstats.append(dict(run=tag,n=summary['n'],dt=summary['dt'],time=t,convention=convention,window=window,
                        min_gap=float(v.min()),median_gap=float(np.median(v)),max_gap=float(v.max()),
                        median_change_from_initial=float(np.median(v-values[0,c,:,k])),
                        max_window_benefit=float(values[it,c,:,2].max()),
                        positive_benefit_count=int(np.sum(values[it,c,:,2]>5e-5))))
    comparisons=[];fieldrows=[]
    for name,coarse,fine in PAIRS:
        if coarse not in data or fine not in data:continue
        a,b=data[coarse],data[fine];delta=b-a
        for c,convention in enumerate(CONVENTIONS):
            d=abs(delta[:,c,:,:2]);md=np.median(d,axis=1)
            final=abs(delta[-1,c,:,:2])
            s=abs(delta[:,c,:,3:5])
            comparisons.append(dict(comparison=name,coarse=coarse,fine=fine,convention=convention,
                max_pair_gap_change=float(d.max()),max_time_median_abs_pair_gap_change=float(md.max()),
                max_time_gap_median_change=float(abs(np.median(b[:,c,:,:2],axis=1)-np.median(a[:,c,:,:2],axis=1)).max()),
                final_max_pair_gap_change=float(final.max()),final_median_abs_pair_gap_change=float(np.median(final,axis=0).max()),
                max_initial_pair_gap_change=float(d[0].max()),
                max_change_in_gap_growth=float(abs((b[:,c,:,:2]-b[0,c,:,:2])-(a[:,c,:,:2]-a[0,c,:,:2])).max()),
                max_window_benefit_change=float(abs(delta[:,c,:,2]).max()),
                final_max_window_benefit_change=float(abs(delta[-1,c,:,2]).max()),
                max_closest_arclength_change=float(s.max()),
                final_max_closest_arclength_change=float(s[-1].max()),
                final_pair_count_closest_shift_gt_0p02=int(np.sum(np.any(s[-1]>.02,axis=1))),
                all_time_pair_count_closest_shift_gt_0p02=int(np.sum(np.any(s>.02,axis=(0,2)))),
                gap_size_targets_met=bool(d.max()<=.001 and md.max()<=.0005)))
        for j in range(13):
            left=common_fields(fieldcache[coarse][j]);right=common_fields(fieldcache[fine][j])
            for quantity in left:
                diff=right[quantity]-left[quantity];rms=l2(right[quantity]);error=l2(diff)
                fieldrows.append(dict(comparison=name,coarse=coarse,fine=fine,time=j*.1,quantity=quantity,
                    absolute_l2=error,relative_l2=error/rms if rms>0 else 0.,max_error=maxnorm(diff),reference_rms=rms))
    savecsv(OUT/'run-diagnostics-summary.csv',runstats)
    savecsv(OUT/'gap-summaries.csv',gapstats)
    savecsv(OUT/'gap-comparisons.csv',comparisons)
    savecsv(OUT/'field-comparisons.csv',fieldrows)
    savecsv(OUT/'prime-diagnostics.csv',diagnostics)
    tracing=[]
    for tag in available:
        standard=data[tag]
        folder=OUT/tag
        for file in sorted(folder.glob('gaps_*.csv')):
            if file.name in ['gaps_grid192_ds1024.csv','gaps_grid192_ds1024_consistent.csv']:continue
            times,other=gaps(tag,file)
            indices=[round((t-1.1)/.002) for t in times]
            # Baseline archived endpoint/direct controls used the original
            # reselected pairs; record this conservative combined difference.
            d=other-standard[indices]
            tracing.append(dict(run=tag,measurement=file.name,frames=len(times),
                accepted_control=('grid256' in file.name or 'direct_ds1024' in file.name or 'direct_ds2048' in file.name),
                max_gap_difference=float(abs(d[...,:2]).max()),max_benefit_difference=float(abs(d[...,2]).max()),
                max_closest_arclength_difference=float(abs(d[...,3:5]).max()),
                min_direction=min(float(r['minimum_direction']) for r in readcsv(file))))
        for file in sorted(folder.glob('spot-direct-ds*.json')):
            checks=json.loads(file.read_text(encoding='utf-8'))
            tracing.append(dict(run=tag,measurement=file.name,frames=len(checks),
                accepted_control=True,
                max_gap_difference=max(r['max_dense_gap_error'] for r in checks),
                max_benefit_difference='',
                max_closest_arclength_difference=max(r['max_dense_closest_arclength_error'] for r in checks),
                min_direction=min(r['minimum_direction'] for r in checks)))
    savecsv(OUT/'tracing-comparisons.csv',tracing)
    preserved=json.loads((OUT/'input-sha256.json').read_text(encoding='utf-8'))
    unchanged=all(hashlib.sha256(Path(p).read_bytes()).hexdigest()==h for p,h in preserved.items())
    assert unchanged
    verdict=dict(completed_runs=available,required_runs=TAGS,complete_matrix=available==TAGS,
        gap_target_max=.001,gap_target_median=.0005,velocity_relative_target=.01,vorticity_relative_target=.05,
        tracing_gap_target=.00005,primary_tracing='grid192 ds1/1024',finer_tracing_control='grid256 ds1/2048',
        common_field_grid=64,original_21_inputs_unchanged=unchanged)
    if available==TAGS:
        by={(r['comparison'],r['convention']):r for r in comparisons}
        # Floating time generated j*.1 is 1.2000000000000002 on this runtime.
        last=[r for r in fieldrows if r['comparison']=='space24_32' and abs(r['time']-1.2)<1e-12]
        fieldmet=all(r['relative_l2']<(.01 if r['quantity']=='velocity' else .05) for r in last if r['quantity'] in ['velocity','vorticity'])
        verdict['last_spatial_field_size_targets_met']=fieldmet
        verdict['last_spatial_field_differences_decreased']={}
        for quantity in ['velocity','vorticity']:
            earlier=next(r for r in fieldrows if r['comparison']=='space16_24' and r['quantity']==quantity and abs(r['time']-1.2)<1e-12)
            later=next(r for r in last if r['quantity']==quantity)
            verdict['last_spatial_field_differences_decreased'][quantity]=later['absolute_l2']<earlier['absolute_l2']
        verdict['conventions']={}
        for c in CONVENTIONS:
            early=by['space16_24',c];late=by['space24_32',c]
            firsttime=by['time16_2_1',c];lasttime=by['time16_1_half',c]
            verdict['conventions'][c]=dict(
                spatial_gap_size_targets_met=late['gap_size_targets_met'],
                spatial_max_gap_difference_decreased=late['max_pair_gap_change']<early['max_pair_gap_change'],
                n16_time_gap_size_targets_met=lasttime['gap_size_targets_met'],
                n16_time_max_gap_difference_decreased=lasttime['max_pair_gap_change']<firsttime['max_pair_gap_change'],
                n32_time_gap_size_targets_met=by['time32_half_quarter',c]['gap_size_targets_met'])
        verdict['tracing_size_target_met']=all(r['max_gap_difference']<=.00005 for r in tracing if r['accepted_control'])
    dump(OUT/('analysis-summary-partial.json' if partial else 'analysis-summary.json'),verdict)
    print(json.dumps(verdict,indent=2))

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--partial',action='store_true');a=p.parse_args();build(a.partial)
