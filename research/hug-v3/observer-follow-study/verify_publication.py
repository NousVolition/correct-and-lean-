"""Recount published records and reject stale receipts; does not run the solver."""
import argparse,copy,csv,hashlib,importlib.util,json,re
from pathlib import Path
import numpy as np
HERE=Path(__file__).resolve().parent;REPO=HERE.parents[2];LEAN=HERE.parent/'observer-follow-lean'
TAGS=['n40_dt0p0005','n48_dt0p0005','n48_dt0p00025'];IDS=[540,872];RADII=[.05,.075,.1];CLASSES=['stayed','left','returned','arrived','visited','outside']
def load(p):return json.loads(p.read_text(encoding='utf-8'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def rows(p):
    with p.open(newline='',encoding='utf-8') as f:return list(csv.DictReader(f))
def current_inputs():
    return {p.relative_to(LEAN).as_posix():sha(p) for p in sorted(LEAN.rglob('*')) if p.is_file() and (p.suffix in ['.lean','.csv','.npz','.json','.py','.toml'] or p.name=='lean-toolchain') and p.name!='receipt.json' and 'evidence' not in p.relative_to(LEAN).parts}
def fingerprint(x):return hashlib.sha256(json.dumps(x,sort_keys=True,separators=(',',':')).encode()).hexdigest()
def check_receipt(r,inputs,targets):
    assert r['status']=='PASS' and r['proof_inputs']==inputs,'Stale inputs'
    assert r['proof_input_fingerprint']==fingerprint(inputs),'Wrong fingerprint'
    assert r['targets']==targets and r['target_count']==len(targets)==134,'Wrong targets'
    assert set(r['axiom_dependencies'])==set(targets)
    assert all(set(v)<={'propext','Quot.sound'} for v in r['axiom_dependencies'].values())
    assert r['no_added_axioms'] and r['no_sorry'] and r['no_native_decide']
    assert set(r['checks'])=={'OriginTracking.lean','FollowingLabels.lean','RecordedFollowing.lean','CheckAxioms.lean'}
    assert all(v['exit_code']==0 for v in r['checks'].values())
def match_fresh(fresh,saved):
    check_receipt(fresh,current_inputs(),load(LEAN/'targets.json'))
    for key in ['proof_input_fingerprint','proof_inputs','targets','axiom_dependencies','data_certificate_check']:assert fresh[key]==saved[key],key+' changed'
def classify(h):
    if h[0]:return 'left' if not h[-1] else 'stayed' if h.all() else 'returned'
    return 'arrived' if h[-1] else 'visited' if h.any() else 'outside'
def check():
    manifest=load(HERE/'publication-manifest.json')
    for rel,digest in manifest.items():assert sha(REPO/rel)==digest,rel+' changed'
    saved=load(LEAN/'receipt.json');check_receipt(saved,current_inputs(),load(LEAN/'targets.json'))
    spec=importlib.util.spec_from_file_location('follow_certificate',LEAN/'check_certificate.py');certificate=importlib.util.module_from_spec(spec);spec.loader.exec_module(certificate)
    c=certificate.check();expected=dict(saved['data_certificate_check']);expected.pop('tamper_tests_passed');assert c==expected
    data=LEAN/'source-data';a=load(HERE/'analysis.json');assert sha(HERE/'analysis.json')==sha(data/'analysis.json')
    for name in ['crossing-readouts.csv','entry-material-fields.csv','pair-wide-origin-readouts.csv']:assert sha(HERE/name)==sha(data/name)
    summaries=rows(HERE/'neighbor-summary.csv');summary={(r['run'],int(r['observer']),r['population'],float(r['radius'])):r for r in summaries};assert len(summary)==len(summaries)==36
    neighbors={};windows={};history_count=0
    for tag in TAGS:
        info=load(data/f'{tag}-result.json');status=load(HERE/'runs'/tag/'status.json')
        assert status['status']=='complete' and all(status['criteria'].values()) and all(info['criteria'].values())
        assert info['code_sha256']==sha(HERE/'source/run_follow.py') and info['start']==1.2 and info['end']==1.3
        with np.load(data/f'{tag}-membership.npz') as z:
            steps=info['steps'];assert np.allclose(z['times'],1.2+np.arange(steps+1)*info['dt'],rtol=0,atol=2e-15)
            assert list(z['radii'])==RADII
            for owner in IDS:
                for pop in ['material','observer']:
                    h=z[f'{owner}_{pop}'];ids=z[f'{owner}_{pop}_ids'];expected=np.arange(384) if pop=='material' else np.array([i for i in range(926) if i!=owner])
                    assert np.array_equal(ids,expected) and h.shape==(steps+1,len(ids),3) and h.dtype==np.bool_
                    neighbors[(tag,owner,pop)]=h[:,:,1].copy()
                    for ri,radius in enumerate(RADII):
                        hh=h[:,:,ri];cl=[classify(hh[:,i]) for i in range(len(ids))];s=summary[(tag,owner,pop,radius)]
                        assert int(s['entry'])==hh[0].sum() and int(s['exit'])==hh[-1].sum()
                        assert [int(s[k]) for k in CLASSES]==[cl.count(k) for k in CLASSES]
                        history_count+=len(ids)
        ww=rows(data/f'{tag}-window-history.csv');windows[tag]={i:{round(float(r['time']),9):r for r in ww if int(r['observer'])==i} for i in IDS}
        for r in a['window_endpoints']:
            if r['run']!=tag:continue
            original=windows[tag][int(r['observer'])][1.3]
            for k,v in original.items():assert r[k]==(v if k=='run' else float(v))
            assert abs(r['retained_starting_context_fraction']-float(original['original_inside'])/float(original['entry_original']))<1e-15
            assert abs(r['elsewhere_starting_context_fraction']-float(original['original_elsewhere'])/float(original['entry_original']))<1e-15
            assert abs(r['local_total_fraction_of_entry']-float(original['native_total_inside'])/float(original['entry_original']))<1e-15
    assert history_count==23562
    for r in a['context_grid_time_comparisons']:
        first,last=(TAGS[0],TAGS[1]) if r['comparison']=='grid40_48' else (TAGS[1],TAGS[2]);i=r['observer'];aa=windows[first][i];bb=windows[last][i]
        common=sorted(set(aa)&set(bb));common=[t for t in common if abs((t-1.2)/.002-round((t-1.2)/.002))<1e-8];assert len(common)==r['common_times']==51
        for col,m in r['metrics'].items():
            d=np.array([100*(float(bb[t][col])/float(bb[t]['entry_original'])-float(aa[t][col])/float(aa[t]['entry_original'])) for t in common])
            assert abs(m['endpoint_delta_percentage_points']-d[-1])<1e-12 and abs(m['max_common_time_delta_percentage_points']-abs(d).max())<1e-12
    for r in a['neighbor_grid_time_comparisons']:
        first,last=(TAGS[0],TAGS[1]) if r['comparison']=='grid40_48' else (TAGS[1],TAGS[2]);key=(r['observer'],r['population']);aa=neighbors[(first,*key)];bb=neighbors[(last,*key)]
        if r['comparison']=='half_time48':bb=bb[::2]
        assert int((aa!=bb).sum())==r['different_memberships'] and int((aa!=bb).any(axis=0).sum())==r['ids_with_any_difference']
    qa=load(HERE/'local-evidence/diagram-review.json');assert qa['inspected'] and qa['diagram_sha256']==sha(HERE/'following-540-872.png')
    if (HERE/'github-lean-receipt.json').exists():
        github=load(HERE/'github-lean-receipt.json');match_fresh(github,saved);ctx=github['execution_context']
        assert ctx['repository']=='NousVolition/hug-sims-lean-proofs' and ctx['run_url']=='https://github.com/NousVolition/hug-sims-lean-proofs/actions/runs/'+str(ctx['run_id'])
        assert re.fullmatch('[0-9a-f]{40}',ctx['checkout_sha'])
    return {'status':'PASS','proof_input_fingerprint':saved['proof_input_fingerprint'],'target_count':134,'targets':saved['targets'],'three_radius_histories_recounted':history_count,'neighbor_summary_rows':36,'crossings_source_matched':6,'source_certificate':c,'manifest_files':len(manifest),'fluid_solver_rerun':False,'full_native_states_all_neighbor_positions_and_origin_grids_rechecked':False,'selected_positions_and_point_stencils_recounted':True}
def self_test():
    saved=load(LEAN/'receipt.json');inputs=current_inputs();targets=load(LEAN/'targets.json');variants=[]
    r=copy.deepcopy(saved);r['proof_input_fingerprint']='0'*64;variants.append(r)
    r=copy.deepcopy(saved);r['targets']=r['targets'][:-1];variants.append(r)
    r=copy.deepcopy(saved);r['proof_inputs']['FollowingLabels.lean']='0'*64;variants.append(r)
    r=copy.deepcopy(saved);r['axiom_dependencies'][targets[0]]=['sorryAx'];variants.append(r)
    for r in variants:
        try:check_receipt(r,inputs,targets)
        except AssertionError:pass
        else:raise AssertionError('Invalid receipt accepted')
    return len(variants)
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--fresh',type=Path);p.add_argument('--self-test',action='store_true');args=p.parse_args()
    result=check()
    if args.fresh:match_fresh(load(args.fresh),load(LEAN/'receipt.json'));result['fresh_proof_matches']=True
    if args.self_test:result['receipt_refusal_tests_passed']=self_test()
    print(json.dumps(result,indent=2))
