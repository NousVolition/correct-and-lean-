"""Same-label comparisons for the finite 40/48-grid extension."""
import os
os.environ.setdefault('OPENBLAS_NUM_THREADS', '1')
os.environ.setdefault('OMP_NUM_THREADS', '1')
import sys
sys.dont_write_bytecode = True
import csv, hashlib, json
from datetime import datetime, timezone
from pathlib import Path
import numpy as np

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'outputs/fluid-finer-grid'
OLD = ROOT / 'outputs/fluid-convergence'
sys.path.insert(0, str(ROOT / 'work/fluid-convergence'))
from run_study import coeff, curl, at, trace, nearest
from compare_results import common_fields, l2, maxnorm

NEW = ['n40_dt0p0005', 'n48_dt0p0005', 'n48_dt0p00025']
ALL = ['n24_dt0p0005', 'n32_dt0p0005'] + NEW
COMPARISONS = [('space24_32', ALL[0], ALL[1]),
               ('space32_40', ALL[1], ALL[2]),
               ('space40_48', ALL[2], ALL[3]),
               ('time48_half', ALL[3], ALL[4])]
COLUMNS = ['local_gap', 'extended_gap', 'window_benefit',
           'local_closest_arclength', 'extended_closest_arclength']

def folder(tag):
    return (OUT if tag in NEW else OLD) / tag

def readjson(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))

def dump(path, value):
    path.write_text(json.dumps(value, indent=2, allow_nan=False)+'\n', encoding='utf-8')

def rows(path):
    with path.open(encoding='utf-8-sig', newline='') as f:
        return list(csv.DictReader(f))

def savecsv(path, values):
    if not values:
        return
    with path.open('w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, list(values[0]))
        writer.writeheader()
        writer.writerows(values)

def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda:f.read(1<<20), b''):
            h.update(block)
    return h.hexdigest()

def load_gaps(tag, name='gaps_grid192_ds1024.csv'):
    source = rows(folder(tag)/name)
    values = [r for r in source if r['convention']=='fixed']
    assert len(values)==1275, (tag, name, len(values))
    times = sorted({float(r['time']) for r in values})
    np.testing.assert_allclose(times, np.arange(550,601)*.002, rtol=0, atol=1e-14)
    result = np.full((51,25,5), np.nan)
    seen = set()
    for r in values:
        ix = (times.index(float(r['time'])), int(r['seed']))
        assert ix not in seen and 0<=ix[1]<25
        seen.add(ix)
        result[ix] = [float(r[k]) for k in COLUMNS]
    assert np.isfinite(result).all()
    assert (result[:,:,1] <= result[:,:,0]+1e-13).all()
    np.testing.assert_allclose(result[:,:,2], result[:,:,0]-result[:,:,1], rtol=0, atol=1e-14)
    assert ((result[:,:,3]>=0)&(result[:,:,3]<=.375+1e-13)).all()
    assert ((result[:,:,4]>=0)&(result[:,:,4]<=.75+1e-13)).all()
    return np.asarray(times), result

def pair_metrics(a,b):
    d = abs(b[:,:,:2]-a[:,:,:2])
    median = np.median(d, axis=1)
    worst = np.unravel_index(int(np.argmax(d)),d.shape)
    return dict(max_pair_gap_change=float(d.max()),
        max_time_median_abs_pair_change=float(median.max()),
        final_max_pair_gap_change=float(d[-1].max()),
        final_median_abs_pair_change=float(np.median(d[-1],axis=0).max()),
        max_initial_pair_gap_change=float(d[0].max()),
        max_gap_growth_difference=float(abs((b[:,:,:2]-b[0,:,:2])-(a[:,:,:2]-a[0,:,:2])).max()),
        max_closest_arclength_change=float(abs(b[:,:,3:5]-a[:,:,3:5]).max()),
        final_pairs_with_closest_shift_above_0p02=int(np.any(abs(b[-1,:,3:5]-a[-1,:,3:5])>.02,axis=1).sum()),
        all_time_pairs_exceeding_gap_target=int(np.any(d>.001,axis=(0,2)).sum()),
        final_pairs_exceeding_gap_target=int(np.any(d[-1]>.001,axis=1).sum()),
        worst_frame_index=int(worst[0]),worst_seed=int(worst[1]),
        worst_window=['local','extended'][worst[2]],
        gap_size_targets_met=bool(d.max()<=.001 and median.max()<=.0005))

def direct_gap(tag,j,seed,k):
    with np.load(folder(tag)/'window.npz') as z:
        f=z['freq']; w=curl(z['velocity'][j],f); obs=z['observers'][j]
    path, low=trace(lambda p:at(w,f,p),obs[seed][None],1/2048,.75)
    cut=path[:769] if k==0 else path
    gap, arc=nearest(cut,obs[25+seed][None])
    return float(gap[0]),float(arc[0]/2048),float(low)

def main():
    code_paths=list((ROOT/'work/fluid-finer-grid').glob('*.py'))+[ROOT/'work/fluid-finer-grid/PLAN.md']
    inputs={str(p.relative_to(ROOT)):digest(p) for p in code_paths}
    data={}; summaries={}; diagnostics=[]; tracing=[]; perpair=[]; fields=[]; direct=[]; boundaries=[]
    old_config=readjson(OLD/'n32_dt0p0005/summary.json')['config']
    for tag in ALL:
        p=folder(tag); s=readjson(p/'summary.json'); summaries[tag]=s
        assert s['full_history'] and s['steps']==round(1.2/s['dt'])
        assert {k:v for k,v in s['config'].items() if k!='n'} == {k:v for k,v in old_config.items() if k!='n'}
        assert s['source_manifest']==readjson(OLD/'n32_dt0p0005/summary.json')['source_manifest']
        assert [e['time'] for e in s['events']]==[.4,.8,1.2]
        if tag in NEW:
            assert readjson(p/'status.json')['status']=='complete'
        times,a=load_gaps(tag); data[tag]=a
        for k,window in enumerate(['local','extended']):
            arc=a[:,:,3+k];end=[.375,.75][k]
            boundaries.append(dict(run=tag,window=window,near_boundary_distance=1/2048,
                samples_at_start=int((arc<=1e-12).sum()),
                samples_at_end=int((arc>=end-1e-12).sum()),
                samples_within_one_fine_trace_step_of_boundary=int(((arc<=1/2048)|(arc>=end-1/2048)).sum()),
                final_pairs_at_start=int((arc[-1]<=1e-12).sum()),
                final_pairs_at_end=int((arc[-1]>=end-1e-12).sum()),
                final_pairs_near_boundary=int(((arc[-1]<=1/2048)|(arc[-1]>=end-1/2048)).sum())))
        with np.load(p/'window.npz') as z:
            assert z['observers'].shape==(51,125,3)
            assert z['velocity'].shape[0]==51
            np.testing.assert_allclose(z['times'],times,rtol=0,atol=1e-14)
        with np.load(p/'prime-fields.npz') as z:
            g=z['g']; initial=z['initial']; assert len(g)==13
            assert np.isfinite(g).all()
            with np.load(OLD/'initial-native.npz') as source:
                f,h=coeff(source['g'],16)
                from run_study import on_grid
                np.testing.assert_array_equal(initial,on_grid(h,f,s['n']))
        ds=readjson(p/'diagnostics.json')
        diagnostics.append(dict(run=tag,n=s['n'],dt=s['dt'],steps=s['steps'],
            integration_seconds=s['elapsed_seconds'],
            max_divergence=max(abs(r['div_error']) for r in ds),
            max_context_balance=max(abs(r['C_balance']) for r in ds),
            max_abs_energy_balance=max(abs(r['energy_balance']) for r in ds),
            final_energy_balance=ds[-1]['energy_balance'],
            max_det_error=max(r['det_error'] for r in ds),
            minimum_temperature=min(r['min_temperature'] for r in ds),
            event_crcs='|'.join(str(r['crc']) for r in s['events'])))
        _,finer=load_gaps(tag,'gaps_grid256_ds2048.csv')
        err=abs(finer[:,:,:2]-a[:,:,:2]); ix=np.unravel_index(int(np.argmax(err)),err.shape)
        tracing.append(dict(run=tag,max_gap_difference=float(err.max()),
            max_closest_arclength_difference=float(abs(finer[:,:,3:5]-a[:,:,3:5]).max()),
            target=.00005,target_met=bool(err.max()<=.00005),
            worst_time=float(times[ix[0]]),worst_seed=int(ix[1]),worst_window=['local','extended'][ix[2]]))
        for name in ['summary.json','diagnostics.json','events.json','window.npz','prime-fields.npz',
                     'gaps_grid192_ds1024.csv','gaps_grid256_ds2048.csv']:
            inputs[str((p/name).relative_to(ROOT))]=digest(p/name)
        if tag in NEW:
            # Direct evaluation at the most sensitive measured case and the
            # largest final local gap. These are named spot checks, not all-case bounds.
            cases={(int(ix[0]),int(ix[1]),int(ix[2])),(50,int(np.argmax(a[-1,:,0])),0)}
            for j,seed,k in sorted(cases):
                value,arc,low=direct_gap(tag,j,seed,k)
                direct.append(dict(kind='readout_spot',run=tag,time=float(times[j]),seed=seed,
                    window=['local','extended'][k],primary=float(a[j,seed,k]),direct=value,
                    discrepancy=abs(value-a[j,seed,k]),minimum_direction=low))
                print('DIRECT READOUT',direct[-1],flush=True)
    comparisons=[]; window_comparisons=[]
    for name,left,right in COMPARISONS:
        a,b=data[left],data[right]
        result=dict(comparison=name,coarse=left,fine=right,**pair_metrics(a,b))
        comparisons.append(result)
        for k,window in enumerate(['local','extended']):
            d=abs(b[:,:,k]-a[:,:,k]);med=np.median(d,axis=1)
            window_comparisons.append(dict(comparison=name,window=window,
                maximum_change=float(d.max()),maximum_median_absolute_change=float(med.max()),
                final_maximum_change=float(d[-1].max()),
                pairs_exceeding_target=int(np.any(d>.001,axis=0).sum()),
                final_pairs_exceeding_target=int((d[-1]>.001).sum()),
                targets_met=bool(d.max()<=.001 and med.max()<=.0005)))
        for seed in range(25):
            for k,window in enumerate(['local','extended']):
                d=abs(b[:,seed,k]-a[:,seed,k])
                perpair.append(dict(comparison=name,seed=seed,window=window,
                    maximum_change=float(d.max()),worst_time=float(times[int(np.argmax(d))]),
                    initial_change=float(d[0]),final_change=float(d[-1]),
                    coarse_final_gap=float(a[-1,seed,k]),fine_final_gap=float(b[-1,seed,k]),
                    maximum_closest_shift=float(abs(b[:,seed,k+3]-a[:,seed,k+3]).max()),
                    final_closest_shift=float(abs(b[-1,seed,k+3]-a[-1,seed,k+3])),
                    target_met=bool(d.max()<=.001)))
        gs=[]; spectra=[]
        for tag in [left,right]:
            with np.load(folder(tag)/'prime-fields.npz') as z:g=z['g'][-1]
            gs.append(common_fields(g,size=96))
            f,h=coeff(g[...,:3],g.shape[0]);spectra.append((f,h,curl(h,f)))
        for q in gs[0]:
            error=l2(gs[1][q]-gs[0][q]);ref=l2(gs[1][q])
            row=dict(comparison=name,quantity=q,absolute_l2=error,reference_rms=ref,
                     relative_l2=error/ref if ref else 0,max_error=maxnorm(gs[1][q]-gs[0][q]))
            if q in ['velocity','vorticity']:
                k=1 if q=='velocity' else 2
                low=min(s[0].min() for s in spectra);high=max(s[0].max() for s in spectra)
                ps=[]
                for s in spectra:
                    p=np.zeros((high-low+1,)*3+(3,),complex);ix=s[0]-low;p[np.ix_(ix,ix,ix)]=s[k];ps.append(p)
                parseval=float(np.sqrt(np.sum(abs(ps[1]-ps[0])**2)))
                assert abs(error-parseval)<1e-12
                row['independent_parseval_l2']=parseval
                row['parseval_discrepancy']=abs(error-parseval)
            else:
                row['independent_parseval_l2']='';row['parseval_discrepancy']=''
            fields.append(row)
        if name in ['space32_40','space40_48']:
            j=result['worst_frame_index'];seed=result['worst_seed'];k=['local','extended'].index(result['worst_window'])
            lv,_,llow=direct_gap(left,j,seed,k);rv,_,rlow=direct_gap(right,j,seed,k)
            primary=float(b[j,seed,k]-a[j,seed,k])
            direct.append(dict(kind='spatial_worst',run=name,time=float(times[j]),seed=seed,
                window=['local','extended'][k],primary=primary,direct=rv-lv,
                discrepancy=abs(primary-(rv-lv)),minimum_direction=min(llow,rlow)))
            print('DIRECT SPATIAL',direct[-1],flush=True)
    old_inputs=readjson(OLD/'input-sha256.json')
    for path,expected in old_inputs.items():assert digest(Path(path))==expected,path
    old_outputs=readjson(OLD/'SHA256SUMS.json')
    for path,expected in old_outputs.items():assert digest(OLD/path)==expected,path
    old_code=readjson(OLD/'study-code-sha256.json')
    for path,expected in old_code.items():assert digest(ROOT/'work/fluid-convergence'/path)==expected,path
    for name in ['initial-native.npz','observer-labels.npz','observer-labels.json']:
        assert digest(OUT/name)==digest(OLD/name)
        inputs[str((OUT/name).relative_to(ROOT))]=digest(OUT/name)
    by={r['comparison']:r for r in comparisons}
    spatial=by['space40_48']; temporal=by['time48_half']
    decreasing=(spatial['max_pair_gap_change']<by['space32_40']['max_pair_gap_change']<by['space24_32']['max_pair_gap_change'])
    trace_ok=all(x['target_met'] for x in tracing) and all(x['discrepancy']<=.00005 for x in direct)
    diagnostic_ok=all(x['max_divergence']<1e-10 and x['max_context_balance']<1e-10 and x['minimum_temperature']>0 for x in diagnostics)
    final_fields={r['quantity']:r['relative_l2'] for r in fields if r['comparison']=='space40_48'}
    verdict=dict(observed_utc=datetime.now(timezone.utc).isoformat(),
        scope='Local numerical refinement of same material pairs; no Lean run and no GitHub publication.',
        completed_new_runs=NEW,prime_tick=41,model_time=1.2,pairs=25,times=51,
        gap_target_max=.001,gap_target_median=.0005,tracing_target=.00005,
        spatial_pair_gap_targets_met=spatial['gap_size_targets_met'],
        successive_spatial_max_differences_decreased=bool(decreasing),
        finest_time_step_gap_targets_met=temporal['gap_size_targets_met'],
        tracing_controls_met=trace_ok,diagnostic_thresholds_met=diagnostic_ok,
        same_pair_gaps_settled_within_declared_tests=bool(spatial['gap_size_targets_met'] and decreasing and temporal['gap_size_targets_met'] and trace_ok and diagnostic_ok),
        last_spatial=spatial,last_time_step=temporal,final_field_relative_l2=final_fields,
        last_spatial_by_window=[r for r in window_comparisons if r['comparison']=='space40_48'],
        final_velocity_vorticity_targets_met=bool(final_fields['velocity']<.01 and final_fields['vorticity']<.05),
        finest_time_step_energy_defect_decreased=bool(diagnostics[-1]['max_abs_energy_balance'] < diagnostics[-2]['max_abs_energy_balance']),
        event_payload_crcs_match_32_40_48=bool(len({r['event_crcs'] for r in diagnostics if r['run'] in ['n32_dt0p0005','n40_dt0p0005','n48_dt0p0005']})==1),
        event_payload_crcs_match_finest_time_halving=bool(diagnostics[-1]['event_crcs']==diagnostics[-2]['event_crcs']),
        original_input_hashes_unchanged=len(old_inputs),original_output_hashes_unchanged=len(old_outputs),
        original_code_hashes_unchanged=len(old_code),labels_match_original=True,
        material_quadrature_points=384,full_continuum_convergence_proved=False,
        lean_run=False,published_on_github=False)
    for filename,values in [('gap-comparisons.csv',comparisons),('per-pair-comparisons.csv',perpair),
            ('field-comparisons.csv',fields),('diagnostics-summary.csv',diagnostics),
            ('tracing-comparisons.csv',tracing),('direct-checks.csv',direct),('boundary-minima.csv',boundaries),
            ('window-comparisons.csv',window_comparisons)]:
        savecsv(OUT/filename,values)
    dump(OUT/'analysis-inputs.json',inputs)
    dump(OUT/'analysis-summary.json',verdict)
    print(json.dumps(verdict,indent=2),flush=True)
    # The additional meter request changes readouts only. The running solver
    # jobs and the gap decision above retain their original definitions.
    from meter_readouts import main as build_meters
    build_meters()
    from audit_write_codes import main as audit_writes
    audit_writes()

if __name__=='__main__':
    main()
