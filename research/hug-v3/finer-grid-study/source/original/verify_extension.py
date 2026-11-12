"""Independent standard-library recount of every same-pair comparison."""
import csv,hashlib,json,math,statistics
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'outputs/fluid-finer-grid'
OLD=ROOT/'outputs/fluid-convergence'

def rows(path):
    with path.open(encoding='utf-8-sig',newline='') as f:return list(csv.DictReader(f))

def main():
    summary=json.loads((OUT/'analysis-summary.json').read_text())
    inputs=json.loads((OUT/'analysis-inputs.json').read_text())
    for name,expected in inputs.items():
        h=hashlib.sha256()
        with (ROOT/name).open('rb') as f:
            for part in iter(lambda:f.read(1<<20),b''):h.update(part)
        assert h.hexdigest()==expected,name
    data={}
    for tag in ['n24_dt0p0005','n32_dt0p0005']+summary['completed_new_runs']:
        folder=(OUT if tag in summary['completed_new_runs'] else OLD)/tag
        selected={}
        for r in rows(folder/'gaps_grid192_ds1024.csv'):
            if r['convention']!='fixed':continue
            key=(round(float(r['time']),6),int(r['seed']))
            assert key not in selected,key
            selected[key]=[float(r['local_gap']),float(r['extended_gap'])]
        assert len(selected)==1275
        assert all(math.isfinite(v) for pair in selected.values() for v in pair)
        data[tag]=selected
    checks=[];pair_checks=0;window_checks=0
    window_records={(r['comparison'],r['window']):r for r in rows(OUT/'window-comparisons.csv')}
    pair_records={(r['comparison'],int(r['seed']),r['window']):r for r in rows(OUT/'per-pair-comparisons.csv')}
    for r in rows(OUT/'gap-comparisons.csv'):
        a,b=data[r['coarse']],data[r['fine']]
        assert a.keys()==b.keys()
        times=sorted({key[0] for key in a})
        diffs={(t,s,k):abs(b[t,s][k]-a[t,s][k]) for t,s in a for k in [0,1]}
        maximum=max(diffs.values())
        med=max(statistics.median(diffs[t,s,k] for s in range(25)) for t in times for k in [0,1])
        final=max(diffs[times[-1],s,k] for s in range(25) for k in [0,1])
        for field,value in [('max_pair_gap_change',maximum),('max_time_median_abs_pair_change',med),('final_max_pair_gap_change',final)]:
            assert abs(float(r[field])-value)<2e-14,(r['comparison'],field)
        assert (r['gap_size_targets_met']=='True')==(maximum<=.001 and med<=.0005)
        for k,w in enumerate(['local','extended']):
            wr=window_records[r['comparison'],w]
            wm=max(diffs[t,s,k] for t in times for s in range(25))
            wd=max(statistics.median(diffs[t,s,k] for s in range(25)) for t in times)
            assert abs(float(wr['maximum_change'])-wm)<2e-14
            assert abs(float(wr['maximum_median_absolute_change'])-wd)<2e-14
            assert (wr['targets_met']=='True')==(wm<=.001 and wd<=.0005)
            window_checks+=1
        for s in range(25):
            for k,w in enumerate(['local','extended']):
                p=pair_records[r['comparison'],s,w]
                assert abs(float(p['maximum_change'])-max(diffs[t,s,k] for t in times))<2e-14
                assert abs(float(p['final_change'])-diffs[times[-1],s,k])<2e-14
                pair_checks+=1
        checks.append(dict(comparison=r['comparison'],maximum=maximum,median=med,final_maximum=final,targets_met=maximum<=.001 and med<=.0005))
    assert len(pair_records)==pair_checks==200
    assert len(window_records)==window_checks==8
    last={r['comparison']:r for r in checks}
    assert summary['spatial_pair_gap_targets_met']==last['space40_48']['targets_met']
    assert summary['finest_time_step_gap_targets_met']==last['time48_half']['targets_met']
    decision=(summary['spatial_pair_gap_targets_met'] and summary['successive_spatial_max_differences_decreased']
        and summary['finest_time_step_gap_targets_met'] and summary['tracing_controls_met'] and summary['diagnostic_thresholds_met'])
    assert summary['same_pair_gaps_settled_within_declared_tests']==decision
    meters=json.loads((OUT/'meter-checks.json').read_text())
    prime_rows=rows(OUT/'prime-meter.csv');local_rows=rows(OUT/'same-pair-local-meter.csv')
    assert len(prime_rows)==meters['prime_rows']==80
    assert len(local_rows)==meters['same_pair_readings']==6375
    assert len({(r['run'],r['prime'],r['side']) for r in prime_rows})==80
    assert len({(r['run'],r['model_time'],r['pair']) for r in local_rows})==6375
    initial={r['run']:float(r['energy']) for r in prime_rows if r['prime']=='2'}
    primes=[2,3,5,7,11,13,17,19,23,29,31,37,41]
    for r in prime_rows:
        assert abs(float(r['model_time'])-.1*primes.index(int(r['prime'])))<1e-12
        balance=float(r['energy'])-initial[r['run']]-float(r['source_work'])-float(r['breathing_work'])-float(r['write_work'])
        assert abs(balance-float(r['signed_energy_balance']))<1e-14
    for r in local_rows:
        time=round(float(r['model_time']),6)
        key=(time,int(r['pair']))
        source=data[r['run']][key]
        assert abs(float(r['local_gap'])-source[0])<1e-14
        assert abs(float(r['extended_gap'])-source[1])<1e-14
        assert int(r['original_0p002_step'])==round(time/.002)
        assert r['prime']==('37' if time==1.1 else '41' if time==1.2 else '')
        assert r['side']==('before_write' if time==1.2 else 'at')
        for side in ['A','B']:
            assert all(math.isfinite(float(r[side+'_'+field])) for field in ['vorticity','local_spin','strain_norm','rotation_norm','Q','divergence'])
            assert abs(float(r[side+'_local_spin'])-.5*float(r[side+'_vorticity']))<1e-14
            q=.5*(float(r[side+'_rotation_norm'])**2-float(r[side+'_strain_norm'])**2)
            assert abs(q-float(r[side+'_Q']))<1e-14
    write_audit=json.loads((OUT/'write-code-audit.json').read_text())
    for name,expected in write_audit['input_hashes'].items():
        assert hashlib.sha256((ROOT/name).read_bytes()).hexdigest()==expected,name
    assert len(write_audit['receipts'])==write_audit['decoded_records']==12
    for r in write_audit['receipts']:
        p=(OLD if r['run'].startswith('n32_') else OUT)/r['run']/'events.json'
        original=next(x for x in json.loads(p.read_text()) if x['event_id']==r['event_id'])
        assert r['receipt_crc']==original['crc'] and r['time']==original['time']
        assert r['repacked_crc_matches']
    result=dict(scope='Independent recount of saved comparisons; not a new simulation or Lean check.',
        input_hashes_checked=len(inputs),fixed_pair_rows_checked=1275*len(data),
        per_pair_window_comparisons_checked=pair_checks,window_comparisons_checked=window_checks,comparisons=checks,
        prime_meter_rows_recounted=len(prime_rows),local_meter_rows_recounted=len(local_rows),
        local_meter_gap_and_time_joins_checked=len(local_rows),
        write_audit_source_hashes_checked=len(write_audit['input_hashes']),write_receipt_crcs_recounted=12,
        recorded_conclusion_matches=True,lean_run=False)
    (OUT/'independent-recount.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(result,indent=2),flush=True)

if __name__=='__main__':main()
