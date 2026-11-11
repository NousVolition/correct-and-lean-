"""Recount published numerical records; does not run a fluid solver or Lean."""
from pathlib import Path
import argparse
import csv
import hashlib
import json
import math
import statistics

ROOT = Path(__file__).resolve().parent
TAGS = ['n16_dt0p002','n16_dt0p001','n16_dt0p0005','n24_dt0p0005','n32_dt0p0005','n32_dt0p00025']
COMPARISONS = [('time16_2_1',0,1),('time16_1_half',1,2),('space16_24',2,3),('space24_32',3,4),('time32_half_quarter',4,5)]
CONVENTIONS = ['fixed','reselected']
WINDOWS = ['local','extended']

def require(condition, message):
    if not condition:
        raise ValueError(message)

def read_json(p):
    return json.loads(p.read_text(encoding='utf-8-sig'))

def read_csv(p):
    with p.open(encoding='utf-8-sig',newline='') as f:
        return list(csv.DictReader(f))

def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

def close(actual, expected, label):
    require(math.isfinite(float(actual)) and math.isfinite(float(expected)), 'Nonfinite '+label)
    require(math.isclose(float(actual),float(expected),abs_tol=1e-13,rel_tol=2e-10), f'{label}: {actual} != {expected}')

def load_pairs(p, tag):
    rows=read_csv(p); out={}
    require(len(rows)==2550, f'Incomplete pair table: {p}')
    for r in rows:
        t=float(r['time']); i=round((t-1.1)/.002); seed=int(r['seed']); c=r['convention']
        require(r['run']==tag and 0<=i<51 and 0<=seed<25 and c in CONVENTIONS, 'Unexpected pair identity')
        close(t,1.1+i*.002,'common time')
        key=(c,i,seed)
        require(key not in out, 'Duplicate pair identity')
        v=tuple(float(r[k]) for k in ['local_gap','extended_gap','window_benefit','local_closest_arclength','extended_closest_arclength'])
        require(all(math.isfinite(x) for x in v), 'Nonfinite pair value')
        require(0<=v[1]<=v[0]+1e-13, 'Nested-window gap violation')
        close(v[2],v[0]-v[1],'window benefit')
        require(0<=v[3]<=.375+1e-12 and 0<=v[4]<=.75+1e-12, 'Closest point outside finite trace')
        out[key]=v
    require(len(out)==2550, 'Missing pair identities')
    return out

def verify_data(root):
    summary=read_json(root/'analysis-summary.json')
    receipt=read_json(root/'completion-receipt.json')
    require(summary['required_runs']==TAGS and summary['completed_runs']==TAGS and receipt['completed_runs']==TAGS, 'Run matrix changed')
    require(summary['complete_matrix'] is True, 'Incomplete matrix')
    for key,value in [('gap_target_max',.001),('gap_target_median',.0005),('velocity_relative_target',.01),('vorticity_relative_target',.05),('tracing_gap_target',.00005)]:
        close(summary[key],value,key)
    data={}; controls={}; steps=0
    for tag in TAGS:
        folder=root/'runs'/tag
        run=read_json(folder/'summary.json')
        require(run['full_history'] is True, 'A run lacks full history')
        require(run['steps']==round(1.2/run['dt']), 'Incomplete integration steps')
        require(f"n{run['n']}_dt{str(run['dt']).replace('.', 'p')}"==tag, 'Run settings changed')
        steps+=run['steps']
        data[tag]=load_pairs(folder/'gaps-primary.csv',tag)
        controls[tag]=load_pairs(folder/'gaps-finer-trace.csv',tag)
    require(steps==13800==receipt['total_successful_integration_steps'], 'Step total changed')

    recorded=read_csv(root/'gap-comparisons.csv')
    require(len(recorded)==10, 'Expected ten gap comparisons')
    lookup={(r['comparison'],r['convention']):r for r in recorded}
    require(len(lookup)==10, 'Duplicate comparison')
    results={}
    for name,ai,bi in COMPARISONS:
        a,b=data[TAGS[ai]],data[TAGS[bi]]
        for c in CONVENTIONS:
            r=lookup[name,c]
            require((r['coarse'],r['fine'])==(TAGS[ai],TAGS[bi]), 'Comparison runs changed')
            differences=[abs(b[c,i,s][w]-a[c,i,s][w]) for i in range(51) for s in range(25) for w in range(2)]
            maximum=max(differences)
            med=max(statistics.median(abs(b[c,i,s][w]-a[c,i,s][w]) for s in range(25)) for i in range(51) for w in range(2))
            close(maximum,r['max_pair_gap_change'],name+' maximum')
            close(med,r['max_time_median_abs_pair_gap_change'],name+' median absolute pair change')
            close(max(abs(b[c,50,s][w]-a[c,50,s][w]) for s in range(25) for w in range(2)),r['final_max_pair_gap_change'],name+' final maximum')
            passes=maximum<=.001 and med<=.0005
            require(r['gap_size_targets_met']==str(passes), 'Incorrect gap decision')
            results[name,c]={'maximum':maximum,'median_absolute_pair_change':med,'targets_met':passes}

    # These are the marks and whiskers in panel C, including all intermediate times.
    stats=read_csv(root/'gap-summaries.csv'); seen=set()
    require(len(stats)==6*51*2*2,'Incomplete gap summaries')
    for r in stats:
        tag=r['run']; c=r['convention']; i=round((float(r['time'])-1.1)/.002); w=WINDOWS.index(r['window'])
        key=(tag,c,i,w); require(key not in seen,'Duplicate gap summary');seen.add(key)
        values=[data[tag][c,i,s][w] for s in range(25)]
        for name,value in [('min_gap',min(values)),('median_gap',statistics.median(values)),('max_gap',max(values))]:
            close(value,r[name],'figure '+name)
    tracing={tag:max(abs(data[tag][k][w]-controls[tag][k][w]) for k in data[tag] for w in range(2)) for tag in TAGS}
    require(all(x<=.00005 for x in tracing.values()),'Finer tracing control failed')
    require(summary['tracing_size_target_met'] is True,'Incorrect tracing decision')

    # Field values remain saved numerical measurements. This verifies the table
    # arithmetic and independent recorded Parseval comparison, not the fields.
    fields=read_csv(root/'field-comparisons.csv')
    last={}
    for r in fields:
        ref=float(r['reference_rms']); absolute=float(r['absolute_l2'])
        close(float(r['relative_l2']),absolute/ref if ref else 0.,'field relative L2')
        if abs(float(r['time'])-1.2)<1e-12:
            last[r['comparison'],r['quantity']]=r
    for r in read_csv(root/'independent-field-checks.csv'):
        key=(r['comparison'],r['quantity'])
        close(r['parseval_relative_l2'],last[key]['relative_l2'],'independent field comparison')
    final_fields={q:float(last['space24_32',q]['relative_l2']) for q in ['velocity','vorticity']}
    require(final_fields['velocity']<.01 and final_fields['vorticity']<.05,'Recorded final field target changed')
    require(summary['last_spatial_field_size_targets_met'] is True,'Incorrect field decision')
    for q in final_fields:
        decreasing=float(last['space24_32',q]['absolute_l2'])<float(last['space16_24',q]['absolute_l2'])
        require(summary['last_spatial_field_differences_decreased'][q]==decreasing,'Incorrect field trend')
    for c in CONVENTIONS:
        expected={
            'spatial_gap_size_targets_met':results['space24_32',c]['targets_met'],
            'spatial_max_gap_difference_decreased':results['space24_32',c]['maximum']<results['space16_24',c]['maximum'],
            'n16_time_gap_size_targets_met':results['time16_1_half',c]['targets_met'],
            'n16_time_max_gap_difference_decreased':results['time16_1_half',c]['maximum']<results['time16_2_1',c]['maximum'],
            'n32_time_gap_size_targets_met':results['time32_half_quarter',c]['targets_met']}
        require(summary['conventions'][c]==expected,'Analysis summary differs from pair data')
    return {
        'scope':'Recount of saved numerical records; no fluid solver or Lean run.',
        'completed_runs':6,'integration_steps_in_saved_receipts':steps,'primary_pair_rows':15300,
        'gap_comparisons_recomputed':10,'figure_gap_summaries_recomputed':len(stats),
        'time_step_gap_checks':'PASS within declared tolerances',
        'spatial_pair_gap_checks':'FAIL declared tolerance; gaps remain grid-sensitive',
        'last_spatial':{c:results['space24_32',c] for c in CONVENTIONS},
        'last_time_step':{c:results['time32_half_quarter',c] for c in CONVENTIONS},
        'finer_tracing_max_gap_changes':tracing,
        'recorded_final_field_relative_l2':final_fields,
        'field_arrays_recomputed':False,'fluid_integrations_recomputed':False,'lean_run':False}

def verify(root=ROOT):
    manifest=read_json(root/'publication-manifest.json')
    for name,expected in manifest['files'].items():
        require(digest(root/name)==expected,'Publication digest mismatch: '+name)
    provenance=read_json(root/'provenance.json')
    for item in provenance['files']:
        require(digest(root/item['published_path'])==item['public_sha256'],'Source mapping mismatch')
    result=verify_data(root)
    result['publication_hashes_checked']=len(manifest['files'])
    return result

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path)
    args=parser.parse_args()
    result=verify()
    content=json.dumps(result,indent=2)+'\n'
    if args.output:
        args.output.write_text(content,encoding='utf-8',newline='\n')
    print(content,end='')
