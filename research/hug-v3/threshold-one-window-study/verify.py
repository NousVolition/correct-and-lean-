"""Recount the saved numerical results, verify hashes and run a sign/metric check."""
import argparse, csv, hashlib, json, platform, sys
from datetime import datetime, timezone
from pathlib import Path
import numpy as np
import scipy
from measure import WINDOWS, field_at, measure, periodic

HERE=Path(__file__).resolve().parent
def load(name):return json.loads((HERE/name).read_text())
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    parser=argparse.ArgumentParser()
    parser.add_argument("--output",type=Path,help="Write a fresh receipt outside the sealed evidence directory")
    args=parser.parse_args()
    bundle=load('bundle-sha256.json')
    for name,expected in bundle.items():
        assert digest(HERE/name)==expected,'Published evidence changed: '+name
    sources=load('source-manifest.json')
    for name,row in sources.items():
        assert digest(HERE/name)==row['sha256'],name
    published=load('saved/published-provenance.json')['content']
    published=json.loads(published)
    published_matches=[]
    provenance_matches=[]
    for name,expected in published['original_files_sha256'].items():
        p=HERE/'saved'/name
        if p.exists():
            record=sources['saved/'+name]
            assert record['original_sha256']==expected,name
            provenance_matches.append(name)
            if digest(p)==expected:published_matches.append(name)
            else:assert name=='Configuration.json',name
    config=load('saved/Configuration.json')
    public_config=json.loads(load('saved/published-configuration.json')['content'])
    assert config['effective_config']==public_config['effective_config']
    assert sorted(config['sources'].values())==sorted(public_config['source_artifacts_sha256'].values())
    assert config['actual_step']==public_config['actual_step']==.002
    assert config['effective_config']['threshold']==1 and config['effective_config']['n']==16
    rows=load('measurements.json');tight=load('measurements-tight.json')
    meta=load('snapshots.json')
    assert len(rows)==len(meta)==40 and len(tight)==6
    by={r['label']:r for r in rows};tby={r['label']:r for r in tight}
    assert len(by)==len(rows)
    nested_count=0
    for row in rows:
        assert row['join_error']==0 and row['min_rhs_omega']>1e-10 and row['min_sampled_omega']>1e-10
        for a,(alo,ahi) in WINDOWS.items():
            win=row['windows'][a]
            assert win['bounds']==[alo,ahi]
            assert alo<=win['winner']['s']<=ahi
            assert win['winner']['d']==min(x['d'] for x in win['candidates'])
            for b,(blo,bhi) in WINDOWS.items():
                if a!=b and blo<=alo and ahi<=bhi:
                    assert row['windows'][b]['winner']['d']<=win['winner']['d']+2e-12
                    nested_count+=1
    with (HERE/'measurements.csv').open(newline='') as f:flat=list(csv.DictReader(f))
    assert len(flat)==240
    for r in flat:
        winner=by[r['label']]['windows'][r['window']]['winner']
        assert float(r['s'])==winner['s'] and float(r['d'])==winner['d']
        assert float(r['time'])==by[r['label']]['time']
    max_d=max(abs(r['windows'][w]['winner']['d']-by[r['label']]['windows'][w]['winner']['d']) for r in tight for w in WINDOWS)
    max_s=max(abs(r['windows'][w]['winner']['s']-by[r['label']]['windows'][w]['winner']['s']) for r in tight for w in WINDOWS)
    assert max_d<1e-9 and max_s<1e-7
    events=[]
    with np.load(HERE/'snapshots.npz') as z:omega,pairs=z['omega'],z['pairs']
    for i in (1,2,3):
        l,r=by[f'event-{i}-left'],by[f'event-{i}-right']
        assert r['time']-l['time']<=2e-9
        assert abs(r['windows']['forward_075']['winner']['s']-l['windows']['forward_075']['winner']['s'])>.1
        comparisons={}
        for w in WINDOWS:
            a,b=l['windows'][w]['winner'],r['windows'][w]['winner']
            comparisons[w]={'left_s':a['s'],'right_s':b['s'],'left_d':a['d'],'right_d':b['d'],
                            'point_movement_periodic':float(np.linalg.norm(periodic(np.array(b['p'])-a['p']))),
                            'left_gap_reduction_vs_original':l['windows']['forward_075']['winner']['d']-a['d']}
        for w in ('both_075','both_150','both_300'):
            assert comparisons[w]['left_s']<0 and comparisons[w]['right_s']<0
            assert abs(comparisons[w]['right_s']-comparisons[w]['left_s'])<2e-6
            assert comparisons[w]['left_gap_reduction_vs_original']>0
        for side in (l,r):
            assert side['saved_distance_error']<2e-9 and side['saved_arc_error']<2e-7
        k=l['index'];A,B=pairs[k];v=field_at(omega[k],A)
        derivative=float(np.dot(periodic(A-B),v/np.linalg.norm(v))/np.linalg.norm(periodic(A-B)))
        events.append({'event':i,'bracket':[l['time'],r['time']],
                       'distance_derivative_at_A':derivative,'windows':comparisons})
    # Independent analytic fixture catches reversed arclength and omission of
    # periodic distance: x(s)=(s,0,0), B=(-0.1,0.05,0).
    constant=np.zeros((11,11,11,3),dtype=complex);constant[5,5,5,0]=1
    fixture=measure(constant,np.array([[0.,0,0],[-.1,.05,0]]))
    assert abs(fixture['windows']['forward_075']['winner']['d']-np.hypot(.1,.05))<1e-12
    assert abs(fixture['windows']['both_075']['winner']['s']+.1)<1e-12
    for w in ('both_075','forward_150','forward_300','both_150','both_300'):
        assert abs(fixture['windows'][w]['winner']['d']-.05)<1e-12
    # Keep unresolved route changes as sampled observations, not resolved events.
    changes=[]
    scan=sorted([r for r in rows if not r['label'].startswith('event-')],key=lambda r:r['time'])
    for l,r in zip(scan,scan[1:]):
        if r['time']-l['time']>.000251:continue
        for w in WINDOWS:
            a,b=l['windows'][w]['winner'],r['windows'][w]['winner']
            if abs(a['s']-b['s'])>.1:
                changes.append({'window':w,'sample_bracket':[l['time'],r['time']],
                                'left_s':a['s'],'right_s':b['s'],
                                'status':'Coarse route-change candidate only; not bisected or exhaustively counted.'})
    endpoint_winners=[{'time':r['time'],'window':w,**r['windows'][w]['winner']} for r in rows for w in WINDOWS
                      if r['windows'][w]['winner']['kind']!='interior']
    replay=load('replay-checks.json')
    assert replay['max_saved_pair_error']<2e-14
    endpoint_replay_error=max(abs(r['endpoint_difference_from_native'][k]-r['saved_endpoint_difference'][k])
                              for r in replay['endpoints'] for k in r['endpoint_difference_from_native'])
    assert endpoint_replay_error<3e-12
    result={'status':'PASS','verified_at_utc':datetime.now(timezone.utc).isoformat(),
            'kind':'Numerical replay, line measurement and arithmetic checks; not Lean verification',
            'versions':{'python':sys.version,'numpy':np.__version__,'scipy':scipy.__version__,'platform':platform.platform()},
            'published_source_files_verified':len(sources),
            'published_bundle_files_verified':len(bundle),
            'original_provenance_records_matched':provenance_matches,
            'original_personal_paths_not_consulted':True,
            'files_matching_published_original_hashes':published_matches,
            'snapshot_count':len(rows),'window_readings':len(flat),'strict_window_inclusion_comparisons':nested_count,
            'max_saved_pair_error':replay['max_saved_pair_error'],
            'max_endpoint_difference_replay_error':endpoint_replay_error,
            'max_saved_forward_distance_error':max(r.get('saved_distance_error',0) for r in rows),
            'max_saved_forward_arclength_error':max(r.get('saved_arc_error',0) for r in rows),
            'tighter_trace_max_distance_difference':max_d,'tighter_trace_max_arclength_difference':max_s,
            'min_rhs_vorticity_all_measurements':min(r['min_rhs_omega'] for r in rows),
            'min_sampled_vorticity_all_measurements':min(r['min_sampled_omega'] for r in rows),
            'analytic_periodic_signed_trace_fixture':'PASS','events':events,
            'sampled_route_change_candidates':changes,'endpoint_winners':endpoint_winners,
            'limits':['Fixed 16^3 spatial grid and inherited dt=0.002 history.',
                      '40 observation times; no exhaustive extended-window event count.',
                      'Maximum signed extent [-3,3]; global closest point and closed circulation not established.',
                      'Tighter line integration is checked at the six saved event sides, not every observation time.',
                      'No Lean theorem or kernel check for these threshold-1 trajectories or new measurements.']}
    if args.output:
        assert args.output.resolve().parent!=HERE,'Keep fresh receipts outside the sealed evidence directory'
        args.output.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:v for k,v in result.items() if k not in ('events','sampled_route_change_candidates','endpoint_winners')},indent=2))
if __name__=='__main__':main()
