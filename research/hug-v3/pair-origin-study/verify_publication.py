"""Recount published origin records and reject stale proof receipts.

This does not run the fluid solver or rederive geometry from omitted positions.
"""
import argparse,copy,csv,gzip,hashlib,importlib.util,json,re
from pathlib import Path
import numpy as np
HERE=Path(__file__).resolve().parent;REPO=HERE.parents[2];LEAN=HERE.parent/'pair-origin-lean'
TAGS=['n40_dt0p0005','n48_dt0p0005','n48_dt0p00025'];RADII=[.05,.075,.1]
CLASSES=['stayed','left','returned','arrived','visited','outside']
def load(p):return json.loads(p.read_text(encoding='utf-8'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def rows(p):
    opener=gzip.open if p.suffix=='.gz' else open
    with opener(p,'rt',newline='',encoding='utf-8') as f:return list(csv.DictReader(f))
def current_inputs():
    return {p.relative_to(LEAN).as_posix():sha(p) for p in sorted(LEAN.rglob('*'))
            if p.is_file() and (p.suffix in ['.lean','.csv','.npz','.json','.py','.toml'] or p.name=='lean-toolchain')
            and p.name!='receipt.json' and 'evidence' not in p.relative_to(LEAN).parts}
def fingerprint(inputs):return hashlib.sha256(json.dumps(inputs,sort_keys=True,separators=(',',':')).encode()).hexdigest()
def check_receipt(r,inputs,targets):
    assert r['status']=='PASS' and r['proof_inputs']==inputs,'Stale proof inputs'
    assert r['proof_input_fingerprint']==fingerprint(inputs),'Wrong fingerprint'
    assert r['targets']==targets and r['target_count']==len(targets)==77,'Wrong targets'
    assert set(r['axiom_dependencies'])==set(targets)
    assert all(set(v)<={'propext','Quot.sound'} for v in r['axiom_dependencies'].values())
    assert r['no_added_axioms'] and r['no_sorry'] and r['no_native_decide']
    assert set(r['checks'])=={'OriginTracking.lean','RecordedOrigins.lean','CheckAxioms.lean'}
    assert all(v['exit_code']==0 for v in r['checks'].values())
def match_fresh(fresh,saved):
    check_receipt(fresh,current_inputs(),load(LEAN/'targets.json'))
    for key in ['proof_input_fingerprint','proof_inputs','targets','axiom_dependencies','data_certificate_check']:
        assert fresh[key]==saved[key],key+' changed in fresh check'
def classify(h):
    if h[0]:return 'left' if not h[-1] else 'stayed' if h.all() else 'returned'
    return 'arrived' if h[-1] else 'visited' if h.any() else 'outside'
def unique(table,key):
    result={key(r):r for r in table};assert len(result)==len(table),'Duplicate observations';return result
def check():
    manifest=load(HERE/'publication-manifest.json')
    for rel,digest in manifest.items():assert sha(REPO/rel)==digest,rel+' changed'
    saved=load(LEAN/'receipt.json');check_receipt(saved,current_inputs(),load(LEAN/'targets.json'))
    spec=importlib.util.spec_from_file_location('origin_certificate',LEAN/'check_certificate.py')
    certificate=importlib.util.module_from_spec(spec);spec.loader.exec_module(certificate)
    assert certificate.check()==saved['data_certificate_check']
    data=LEAN/'source-data';analysis=load(HERE/'analysis.json')
    assert sha(HERE/'analysis.json')==sha(data/'analysis.json')
    provenance=load(HERE/'provenance.json')
    assert sha(HERE/'identity-classification.csv.gz')==provenance['compressed_classification_sha256']
    assert hashlib.sha256(gzip.decompress((HERE/'identity-classification.csv.gz').read_bytes())).hexdigest()==provenance['uncompressed_classification_sha256']
    summary=unique(rows(HERE/'identity-summary.csv'),lambda r:(r['run'],r['population'],float(r['radius']),r['view']))
    identities=unique(rows(HERE/'identity-classification.csv.gz'),lambda r:(r['run'],r['population'],float(r['radius']),r['view'],int(r['id'])))
    crossing=unique(rows(HERE/'crossings.csv'),lambda r:(r['run'],r['population'],float(r['radius']),r['view'],int(r['id']),float(r['last_time_before']),float(r['first_time_after'])))
    fields=unique(rows(data/'material-field-changes.csv'),lambda r:(r['run'],int(r['id'])))
    seen_summaries=set();seen_ids=set();seen_crossings=set();histories=0;windows={}
    for tag in TAGS:
        result=load(data/f'{tag}-result.json');status=load(HERE/'runs'/tag/'status.json')
        assert status['status']=='complete' and all(status['criteria'].values()) and all(result['criteria'].values())
        assert result['code_sha256']==sha(HERE/'source/run_origins.py')
        assert result['start']==1.2 and result['end']==1.3 and result['radii']==RADII
        with np.load(data/f'{tag}-membership.npz') as z:
            times=z['times'];steps=result['steps']
            assert np.allclose(times,1.2+np.arange(steps+1)*result['dt'],rtol=0,atol=2e-15)
            assert np.array_equal(z['radii'],RADII)
            for pop,expected_ids in [('material',np.arange(384)),('observer',np.array([i for i in range(926) if i not in [825,850]]))]:
                ids=z[pop+'_ids'];assert np.array_equal(ids,expected_ids)
                member=z[pop];assert member.shape==(steps+1,len(ids),3,3) and member.dtype==np.bool_
                for ri,radius in enumerate(RADII):
                    assert np.array_equal(member[:,:,ri,2],member[:,:,ri,0]|member[:,:,ri,1])
                    for vi,view in enumerate(['A','B','union']):
                        key=(tag,pop,radius,view);s=summary[key];seen_summaries.add(key)
                        h=member[:,:,ri,vi];classes=[classify(h[:,i]) for i in range(len(ids))]
                        assert int(s['entry'])==h[0].sum() and int(s['exit'])==h[-1].sum()
                        assert [int(s[k]) for k in CLASSES]==[classes.count(k) for k in CLASSES]
                        for i,identity in enumerate(ids):
                            key_id=key+(int(identity),);r=identities[key_id];seen_ids.add(key_id)
                            assert r['classification']==classes[i]
                            assert (r['entry_inside']=='True')==bool(h[0,i]) and (r['exit_inside']=='True')==bool(h[-1,i])
                            flips=np.flatnonzero(h[1:,i]!=h[:-1,i])+1;assert int(r['crossings'])==len(flips)
                            if pop=='material':
                                for name in ['F_max_change','m_max_change','m_min_step_change']:assert r[name]==fields[(tag,int(identity))][name]
                            for step in flips:
                                key_cross=key_id+(float(times[step-1]),float(times[step]));c=crossing[key_cross];seen_crossings.add(key_cross)
                                assert c['event']==('arrive' if h[step,i] else 'leave')
                            histories+=1
        table=rows(data/f'{tag}-context-window-origins.csv');windows[tag]=[r for r in table if float(r['radius'])==.075]
        keyed=unique(table,lambda r:(float(r['time']),float(r['radius'])))
        assert len(keyed)==153 and all(r['run']==tag for r in table)
        assert set(keyed)=={(round(1.2+i*.002,12),radius) for i in range(51) for radius in RADII}
        for endpoint in [r for r in analysis['context_endpoints'] if r['run']==tag]:
            original=keyed[(1.3,endpoint['radius'])]
            for k,v in original.items():assert endpoint[k]==(v if k=='run' else float(v))
            assert abs(endpoint['original_inside_fraction_of_entry']-float(original['original_inside_now'])/float(original['entry_inside_context']))<1e-15
    assert seen_summaries==set(summary) and seen_ids==set(identities) and seen_crossings==set(crossing)
    assert histories==35316
    comparisons=load(HERE/'origin-comparisons.json')
    for r in comparisons:
        first,last=(TAGS[0],TAGS[1]) if r['comparison']=='40 to 48 grid' else (TAGS[1],TAGS[2])
        key=r['quantity'];a=np.array([float(x[key])/float(x['entry_inside_context']) for x in windows[first]])
        b=np.array([float(x[key])/float(x['entry_inside_context']) for x in windows[last]])
        assert abs(r['maximum_common_time_difference_percentage_points']-float(100*abs(a-b).max()))<1e-12
        assert abs(r['endpoint_signed_difference_percentage_points']-float(100*(b[-1]-a[-1])))<1e-12
    assert len(comparisons)==10
    values=load(HERE/'report-values.json');fine=windows[TAGS[-1]][-1]
    assert values['primary_endpoint']==fine and values['diagram_sha256']==sha(HERE/'pair25-origins.png')
    assert values['lean_target_count']==77
    for label,key in [('retained_origin_percent','original_inside_now'),('elsewhere_origin_percent','original_elsewhere_now'),('inside_outside_origin_percent_of_entry','outside_origin_inside_now'),('inside_later_source_percent_of_entry','later_source_inside_now'),('total_inside_percent_of_entry','total_inside_now')]:
        assert abs(values[label]-100*float(fine[key])/float(fine['entry_inside_context']))<1e-12
    published=HERE/'github-lean-receipt.json'
    if published.exists():
        github=load(published);match_fresh(github,saved);context=github['execution_context']
        assert context['repository']=='NousVolition/hug-sims-lean-proofs'
        assert context['run_url']=='https://github.com/NousVolition/hug-sims-lean-proofs/actions/runs/'+str(context['run_id'])
        assert re.fullmatch('[0-9a-f]{40}',context['checkout_sha'])
    return {'status':'PASS','proof_input_fingerprint':saved['proof_input_fingerprint'],'target_count':77,'targets':saved['targets'],'classification_rows_recounted':histories,'summary_rows_recounted':len(summary),'crossing_rows_recounted':len(crossing),'source_certificate':saved['data_certificate_check'],'manifest_files':len(manifest),'fluid_solver_rerun':False,'omitted_positions_and_origin_grids_rechecked':False}
def self_test():
    saved=load(LEAN/'receipt.json');inputs=current_inputs();targets=load(LEAN/'targets.json');variants=[]
    r=copy.deepcopy(saved);r['proof_input_fingerprint']='0'*64;variants.append(r)
    r=copy.deepcopy(saved);r['targets']=r['targets'][:-1];variants.append(r)
    r=copy.deepcopy(saved);r['proof_inputs']['OriginTracking.lean']='0'*64;variants.append(r)
    r=copy.deepcopy(saved);r['axiom_dependencies'][targets[0]]=['sorryAx'];variants.append(r)
    for r in variants:
        try:check_receipt(r,inputs,targets)
        except AssertionError:pass
        else:raise AssertionError('Invalid receipt accepted')
    return len(variants)
if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--fresh',type=Path);parser.add_argument('--self-test',action='store_true');args=parser.parse_args()
    result=check()
    if args.fresh:match_fresh(load(args.fresh),load(LEAN/'receipt.json'));result['fresh_proof_matches']=True
    if args.self_test:result['receipt_refusal_tests_passed']=self_test()
    print(json.dumps(result,indent=2))
