"""Recount published numerical records; no fluid solver, field replay or Lean run."""
import argparse,csv,hashlib,json,math,statistics
from pathlib import Path
ROOT=Path(__file__).resolve().parent
TAGS=['n24_dt0p0005','n32_dt0p0005','n40_dt0p0005','n48_dt0p0005','n48_dt0p00025']
COMPARISONS=[('space24_32',0,1),('space32_40',1,2),('space40_48',2,3),('time48_half',3,4)]
COLS=['local_gap','extended_gap','window_benefit','local_closest_arclength','extended_closest_arclength']
TARGETS=['publication and provenance fingerprints','same material pairs at 51 times and both windows',
         'all-pair endpoint agreement and earlier failures','finest time-step and tracing records',
         'sampled diagnostics and recorded field arithmetic','prime energy and local meter joins',
         'stored write audit matched to run receipts']
def require(value,message):
    if not value:raise ValueError(message)
def close(a,b,message):require(math.isfinite(float(a)) and math.isfinite(float(b)) and abs(float(a)-float(b))<2e-14,message)
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read_json(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def read_csv(p):
    with p.open(encoding='utf-8-sig',newline='') as f:return list(csv.DictReader(f))
def load_pairs(path):
    selected={}
    for r in read_csv(path):
        if r['convention']!='fixed':continue
        t=float(r['time']);i=round((t-1.1)/.002);s=int(r['seed']);key=(i,s)
        require(0<=i<=50 and 0<=s<25,'Pair outside declared interval')
        close(t,1.1+.002*i,'Incorrect saved time')
        require(key not in selected,'Duplicate pair identity')
        v=tuple(float(r[k]) for k in COLS)
        require(all(math.isfinite(x) for x in v),'Nonfinite pair data')
        require(0<=v[1]<=v[0]+1e-13,'Nested-window distance invalid')
        close(v[2],v[0]-v[1],'Window benefit invalid')
        require(0<=v[3]<=.375+1e-13 and 0<=v[4]<=.75+1e-13,'Closest point outside window')
        selected[key]=v
    require(len(selected)==1275,'Incomplete same-pair table')
    return selected
def metrics(a,b):
    d={(i,s,k):abs(b[i,s][k]-a[i,s][k]) for i in range(51) for s in range(25) for k in range(2)}
    worst=max(d,key=d.get)
    maximum=max(d.values());median=max(statistics.median(d[i,s,k] for s in range(25)) for i in range(51) for k in range(2))
    return dict(max_pair_gap_change=maximum,max_time_median_abs_pair_change=median,
        final_max_pair_gap_change=max(d[50,s,k] for s in range(25) for k in range(2)),
        final_median_abs_pair_change=max(statistics.median(d[50,s,k] for s in range(25)) for k in range(2)),
        max_initial_pair_gap_change=max(d[0,s,k] for s in range(25) for k in range(2)),
        max_gap_growth_difference=max(abs((b[i,s][k]-b[0,s][k])-(a[i,s][k]-a[0,s][k])) for i in range(51) for s in range(25) for k in range(2)),
        max_closest_arclength_change=max(abs(b[i,s][k]-a[i,s][k]) for i in range(51) for s in range(25) for k in [3,4]),
        final_pairs_with_closest_shift_above_0p02=sum(any(abs(b[50,s][k]-a[50,s][k])>.02 for k in [3,4]) for s in range(25)),
        all_time_pairs_exceeding_gap_target=sum(any(d[i,s,k]>.001 for i in range(51) for k in range(2)) for s in range(25)),
        final_pairs_exceeding_gap_target=sum(any(d[50,s,k]>.001 for k in range(2)) for s in range(25)),
        worst_frame_index=worst[0],worst_seed=worst[1],worst_window=['local','extended'][worst[2]],
        gap_size_targets_met=maximum<=.001 and median<=.0005)
def check_metrics(actual,record,label):
    for k,v in actual.items():
        if isinstance(v,bool):require(record[k] in [v,str(v)],label+' '+k)
        elif isinstance(v,str):require(record[k]==v,label+' '+k)
        else:close(v,record[k],label+' '+k)
def verify_data(root=ROOT):
    summary=read_json(root/'analysis-summary.json');completion=read_json(root/'completion.json')
    require(completion['status']=='complete','Incomplete study')
    require(summary['completed_new_runs']==TAGS[2:],'Changed run matrix')
    require(summary['prime_tick']==41 and summary['model_time']==1.2,'Changed endpoint')
    for k,v in [('gap_target_max',.001),('gap_target_median',.0005),('tracing_target',.00005)]:close(summary[k],v,k)
    data={};controls={};runs={};diags={};events={};steps=0
    for tag in TAGS:
        p=root/'runs'/tag;r=read_json(p/'summary.json');runs[tag]=r
        require(r['full_history'] and r['steps']==round(1.2/r['dt']),'Incomplete run')
        require(f"n{r['n']}_dt{str(r['dt']).replace('.', 'p')}"==tag,'Changed run settings')
        require(r['config']['n']==r['n'],'Configuration grid mismatch')
        steps+=r['steps'];data[tag]=load_pairs(p/'gaps-primary.csv');controls[tag]=load_pairs(p/'gaps-finer-trace.csv')
        diags[tag]=read_json(p/'diagnostics.json');events[tag]=read_json(p/'events.json')
        require([v['time'] for v in events[tag]]==[.4,.8,1.2],'Changed write schedule')
        if tag in TAGS[2:]:require(read_json(p/'completed-status.json')['status']=='complete','Missing completion')
    base={k:v for k,v in runs[TAGS[0]]['config'].items() if k!='n'}
    for r in runs.values():require({k:v for k,v in r['config'].items() if k!='n'}==base,'Physical configuration changed')
    recorded={r['comparison']:r for r in read_csv(root/'gap-comparisons.csv')}
    require(len(recorded)==4,'Missing comparison')
    result={};windows={(r['comparison'],r['window']):r for r in read_csv(root/'window-comparisons.csv')}
    pairs={(r['comparison'],int(r['seed']),r['window']):r for r in read_csv(root/'per-pair-comparisons.csv')}
    require(len(windows)==8 and len(pairs)==200,'Incomplete comparison detail')
    for name,ai,bi in COMPARISONS:
        a,b=data[TAGS[ai]],data[TAGS[bi]];m=metrics(a,b);result[name]=m
        require((recorded[name]['coarse'],recorded[name]['fine'])==(TAGS[ai],TAGS[bi]),'Mismatched comparison runs')
        check_metrics(m,recorded[name],name)
        for k,w in enumerate(['local','extended']):
            d={(i,s):abs(b[i,s][k]-a[i,s][k]) for i in range(51) for s in range(25)}
            maximum=max(d.values());median=max(statistics.median(d[i,s] for s in range(25)) for i in range(51))
            wr=windows[name,w]
            close(maximum,wr['maximum_change'],'Window maximum');close(median,wr['maximum_median_absolute_change'],'Window median')
            require(wr['targets_met']==str(maximum<=.001 and median<=.0005),'Window target decision')
            for s in range(25):
                p=pairs[name,s,w]
                close(max(d[i,s] for i in range(51)),p['maximum_change'],'Per-pair maximum')
                close(d[50,s],p['final_change'],'Per-pair endpoint')
    check_metrics(result['space40_48'],summary['last_spatial'],'Summary spatial')
    check_metrics(result['time48_half'],summary['last_time_step'],'Summary time')
    trace_rows={r['run']:r for r in read_csv(root/'tracing-comparisons.csv')};trace_max={}
    for tag in TAGS:
        maximum=max(abs(data[tag][key][k]-controls[tag][key][k]) for key in data[tag] for k in range(2))
        trace_max[tag]=maximum;close(maximum,trace_rows[tag]['max_gap_difference'],'Tracing maximum')
        require(trace_rows[tag]['target_met']==str(maximum<=.00005),'Tracing target decision')
    direct=read_csv(root/'direct-checks.csv')
    for r in direct:close(abs(float(r['primary'])-float(r['direct'])),r['discrepancy'],'Direct spot arithmetic')
    trace_pass=max(trace_max.values())<=.00005 and all(float(r['discrepancy'])<=.00005 for r in direct)
    diag_pass=all(abs(r['div_error'])<1e-10 and abs(r['C_balance'])<1e-10 and r['min_temperature']>0 for ds in diags.values() for r in ds)
    trend=result['space40_48']['max_pair_gap_change']<result['space32_40']['max_pair_gap_change']<result['space24_32']['max_pair_gap_change']
    expected=dict(spatial_pair_gap_targets_met=result['space40_48']['gap_size_targets_met'],
        finest_time_step_gap_targets_met=result['time48_half']['gap_size_targets_met'],
        tracing_controls_met=trace_pass,diagnostic_thresholds_met=diag_pass,successive_spatial_max_differences_decreased=trend)
    expected['same_pair_gaps_settled_within_declared_tests']=all(expected.values())
    for k,v in expected.items():require(summary[k]==v,'Summary decision differs: '+k)
    require(completion['same_pair_gaps_settled_within_declared_tests']==expected['same_pair_gaps_settled_within_declared_tests'],'Completion decision differs')
    require(result['space40_48']['final_pairs_exceeding_gap_target']==0,'Endpoint agreement changed')
    require(result['space40_48']['all_time_pairs_exceeding_gap_target']==8,'Earlier failure count changed')
    require(not expected['spatial_pair_gap_targets_met'] and expected['finest_time_step_gap_targets_met'],'Recorded pass/fail findings changed')
    for r in read_csv(root/'field-comparisons.csv'):
        reference=float(r['reference_rms']);absolute=float(r['absolute_l2'])
        close(r['relative_l2'],absolute/reference if reference else 0,'Recorded field arithmetic')
        if r['independent_parseval_l2']:close(absolute,r['independent_parseval_l2'],'Recorded Parseval comparison')
    prime=read_csv(root/'prime-meter.csv');local=read_csv(root/'same-pair-local-meter.csv')
    require(len(prime)==80 and len(local)==6375,'Incomplete meter')
    require(len({(r['run'],r['prime'],r['side']) for r in prime})==80,'Duplicate prime meter identity')
    require(len({(r['run'],r['model_time'],r['pair']) for r in local})==6375,'Duplicate local meter identity')
    labels=[2,3,5,7,11,13,17,19,23,29,31,37,41]
    initial={r['run']:float(r['energy']) for r in prime if r['prime']=='2'}
    for r in prime:
        close(float(r['model_time']),labels.index(int(r['prime']))*.1,'Prime clock')
        source=next(v for v in diags[r['run']] if abs(v['time']-float(r['model_time']))<1e-12 and v['side']==r['side'])
        close(r['energy'],source['energy'],'Prime source energy')
        balance=float(r['energy'])-initial[r['run']]-float(r['source_work'])-float(r['breathing_work'])-float(r['write_work'])
        close(balance,r['signed_energy_balance'],'Prime energy ledger')
    for r in local:
        t=float(r['model_time']);i=round((t-1.1)/.002);pair=int(r['pair'])
        close(t,1.1+.002*i,'Local meter time')
        require(int(r['original_0p002_step'])==550+i,'Local meter sample index')
        require(r['prime']==('37' if i==0 else '41' if i==50 else ''),'Local prime label')
        require(r['side']==('before_write' if i==50 else 'at'),'Local write side')
        for k,w in enumerate(['local','extended']):
            close(r[w+'_gap'],data[r['run']][i,pair][k],'Local meter gap join')
            close(r[w+'_closest_arclength'],data[r['run']][i,pair][k+3],'Local meter closest-point join')
        for who in ['A','B']:
            close(r[who+'_local_spin'],.5*float(r[who+'_vorticity']),'Local spin arithmetic')
            close(r[who+'_Q'],.5*(float(r[who+'_rotation_norm'])**2-float(r[who+'_strain_norm'])**2),'Local Q arithmetic')
    focus=read_csv(root/'gap-change-focus-meter.csv');require(len(focus)==8,'Incomplete focused meter')
    for r in focus:
        m=result[r['comparison']];close(r['model_time'],1.1+.002*m['worst_frame_index'],'Focused meter time')
        require(int(r['pair'])==m['worst_seed'],'Focused meter pair')
    write=read_json(root/'write-code-audit.json')
    require(write['decoded_records']==len(write['receipts'])==12,'Write-audit count')
    for r in write['receipts']:
        e=next(e for e in events[r['run']] if e['event_id']==r['event_id'])
        require(e['crc']==r['receipt_crc'] and e['time']==r['time'] and r['repacked_crc_matches'],'Write receipt mismatch')
    require(all(r['records_identical'] for r in write['comparisons'] if r['fine']==TAGS[-1]),'Time-step write records differ')
    return dict(scope=__doc__,verification_targets=TARGETS,comparison_runs=5,new_integrations_in_saved_receipts=3,
        saved_comparison_integration_steps=steps,primary_same_pair_rows=6375,per_pair_window_comparisons=200,
        prime_meter_rows=80,local_meter_rows=6375,write_receipt_crcs_checked=12,
        endpoint_pairs_within_target=25,earlier_pairs_exceeding_target=8,
        last_spatial=result['space40_48'],last_time_step=result['time48_half'],
        decisions=expected,finer_tracing_maxima=trace_max,
        fluid_integrations_recomputed=False,full_field_readouts_recomputed=False,material_records_decoded_here=False,lean_run=False)
def verify(root=ROOT):
    manifest=read_json(root/'publication-manifest.json')
    for name,expected in manifest['files'].items():require(digest(root/name)==expected,'Publication digest mismatch: '+name)
    for r in read_json(root/'provenance.json')['files']:
        require(digest(root/r['published_path'])==r['public_sha256'],'Source mapping mismatch')
    result=verify_data(root);result['publication_hashes_checked']=len(manifest['files'])
    result['publication_manifest_sha256']=digest(root/'publication-manifest.json')
    return result
if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output',type=Path);args=p.parse_args()
    text=json.dumps(verify(),indent=2)+'\n'
    if args.output:args.output.write_text(text,encoding='utf-8',newline='\n')
    print(text,end='')
