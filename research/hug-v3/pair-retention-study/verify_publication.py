"""Recount published observations and reject stale proof/publication receipts.

No fluid solver steps are executed; omitted full-state arrays are not rechecked.
"""
import argparse,copy,csv,hashlib,importlib.util,json,re,sys,zlib,struct
from pathlib import Path
import numpy as np

HERE=Path(__file__).resolve().parent
REPO=HERE.parents[2]
LEAN=HERE.parent/'pair-retention-lean'
TAGS=['n40_dt0p0005','n48_dt0p0005','n48_dt0p00025']
def load(p):return json.loads(p.read_text(encoding='utf-8'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def rows(p):
    with p.open(newline='',encoding='utf-8') as f:return list(csv.DictReader(f))
def fingerprint(inputs):return hashlib.sha256(json.dumps(inputs,sort_keys=True,separators=(',',':')).encode()).hexdigest()
def current_inputs():
    return {p.relative_to(LEAN).as_posix():sha(p) for p in sorted(LEAN.rglob('*'))
            if p.is_file() and (p.suffix in ['.lean','.csv','.npz','.json','.py','.toml'] or p.name=='lean-toolchain')
            and p.name!='receipt.json' and 'evidence' not in p.relative_to(LEAN).parts}
def check_receipt(receipt,inputs,targets):
    assert receipt['status']=='PASS'
    assert receipt['proof_inputs']==inputs,'Stale proof inputs'
    assert receipt['proof_input_fingerprint']==fingerprint(inputs),'Wrong proof fingerprint'
    assert receipt['targets']==targets and receipt['target_count']==len(targets)==40,'Stale target list'
    assert set(receipt['axiom_dependencies'])==set(targets)
    assert all(set(v)<= {'propext','Quot.sound'} for v in receipt['axiom_dependencies'].values())
    assert receipt['no_added_axioms'] and receipt['no_sorry'] and receipt['no_native_decide']
    assert len(receipt['checks'])==4 and all(v['exit_code']==0 for v in receipt['checks'].values())
def match_fresh(fresh,saved):
    check_receipt(fresh,current_inputs(),load(LEAN/'targets.json'))
    for k in ['proof_input_fingerprint','proof_inputs','targets','axiom_dependencies','data_certificate_check']:
        assert fresh[k]==saved[k],k+' differs in fresh run'
def local_account(table,tag):
    expected={(round(1.2+i*.002,6),p,f) for i in range(51) for p in ['A','B'] for f in ['C','theta']}
    keys=[(round(float(r['time']),6),r['point'],r['field']) for r in table]
    assert len(keys)==len(set(keys))==204 and set(keys)==expected
    assert all(r['run']==tag for r in table)
    maximum=0.
    for r in table:
        change=float(r['current'])-float(r['entry'])
        error=change-sum(float(r[c]) for c in ['diffusion_or_conduction','source_or_heat_exchange','advection_interpolation'])
        assert abs(error-float(r['residual']))<2e-15
        assert abs(change-float(r['change']))<2e-15
        maximum=max(maximum,abs(error))
    return maximum
def check():
    manifest=load(HERE/'publication-manifest.json')
    for rel,digest in manifest.items():assert sha(REPO/rel)==digest,rel+' publication bytes differ'
    saved=load(LEAN/'receipt.json');inputs=current_inputs();targets=load(LEAN/'targets.json')
    check_receipt(saved,inputs,targets)
    spec=importlib.util.spec_from_file_location('pair_certificate',LEAN/'check_certificate.py')
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    certificate=module.check()
    assert certificate==saved['data_certificate_check']
    analysis=load(HERE/'analysis.json');data=LEAN/'source-data';record_count=0;residuals={}
    assert sha(HERE/'analysis.json')==sha(data/'analysis.json')
    assert sha(HERE/'cell-aware-check.json')==sha(data/'cell-aware-check.json')
    for j,tag in enumerate(TAGS):
        run=load(data/tag/'result.json');audit=analysis['runs'][j]
        assert run['start']==1.2 and run['end']==1.3 and run['samples']==51 and run['no_new_write']
        assert not run['full_private_inventory_established']
        assert run['code_sha256']==sha(HERE/'source/run_retention.py')
        maximum=local_account(rows(data/tag/'local-budgets.csv'),tag)
        assert maximum==audit['independent_max_local_residual']
        assert (maximum<=1e-6)==run['criteria']['local_budget_target_met']==(j!=0)
        residuals[tag]=maximum
        glob=rows(data/tag/'global-accounts.csv')
        assert [round(float(r['time']),6) for r in glob]==[round(1.2+i*.002,6) for i in range(51)]
        for row in glob:
            assert int(row['records'])==3 and row['entry_records_retained']=='True'
            for name,supply,limit in [('context','context_source',1e-10),('energy','external_work',1e-6)]:
                defect=float(row[name+'_increment'])-float(row[supply+'_increment'])
                assert abs(defect-float(row[name+'_residual']))<2e-15 and abs(defect)<=limit
        with np.load(data/tag/'record-payloads.npz') as z:
            assert len(z['times'])==51
            original={int(k):v.tobytes() for k,v in zip(z['entry_ids'],z['entry_payloads']) if k>=0}
            assert len(original)==3
            for keys,values in zip(z['ids'],z['payloads']):
                live=[int(k) for k in keys if k>=0];assert len(live)==len(set(live))==3
                now={int(k):v.tobytes() for k,v in zip(keys,values) if k>=0}
                assert now==original
                for value in now.values():assert zlib.crc32(value[:-4])==struct.unpack('<I',value[-4:])[0]
                record_count+=3
        with np.load(HERE/'runs'/tag/'pair-positions.npz') as z:
            assert z['positions'].shape==(51,2,3)
            assert np.allclose(z['times'],np.linspace(1.2,1.3,51),rtol=0,atol=2e-15)
    corrected=local_account(rows(data/'cellaware40/local-budgets.csv'),TAGS[0])
    correction=load(HERE/'cell-aware-check.json')
    assert corrected<=1e-6 and abs(corrected-correction['corrected_max_residual'])<2e-15
    assert sha(HERE/'runs/cellaware40/pair-positions.npz')==sha(HERE/'runs'/TAGS[0]/'pair-positions.npz')
    assert sha(HERE/'runs/cellaware40/record-payloads.npz')==sha(data/TAGS[0]/'record-payloads.npz')
    old=load(data/TAGS[0]/'result.json');new=load(data/'cellaware40/result.json')
    assert old['inventory']==new['inventory'],'Recorded state fingerprints changed'
    assert not analysis['complete_private_inventory_established']
    github=HERE/'github-lean-receipt.json'
    if github.exists():
        published=load(github);match_fresh(published,saved)
        context=published['execution_context']
        assert context['repository']=='NousVolition/hug-sims-lean-proofs'
        assert context['run_url'].endswith('/actions/runs/'+str(context['run_id']))
        assert re.fullmatch('[0-9a-f]{40}',context['checkout_sha'])
    return {'status':'PASS','proof_input_fingerprint':saved['proof_input_fingerprint'],'targets':targets,
            'target_count':40,'payload_checks':record_count,'local_accounts':816,'global_accounts':306,
            'original_local_residuals':residuals,'corrected_local_residual':corrected,
            'manifest_files':len(manifest),'fluid_solver_rerun':False,'omitted_full_states_rechecked':False}
def self_test():
    saved=load(LEAN/'receipt.json');inputs=current_inputs();targets=load(LEAN/'targets.json')
    variants=[]
    bad=copy.deepcopy(saved);bad['proof_input_fingerprint']='0'*64;variants.append(bad)
    bad=copy.deepcopy(saved);bad['targets']=bad['targets'][:-1];variants.append(bad)
    bad=copy.deepcopy(saved);bad['proof_inputs']['CarryingInventory.lean']='0'*64;variants.append(bad)
    bad=copy.deepcopy(saved);bad['axiom_dependencies'][targets[0]]=['sorryAx'];variants.append(bad)
    for bad in variants:
        try:check_receipt(bad,inputs,targets)
        except AssertionError:pass
        else:raise AssertionError('Invalid receipt accepted')
    return len(variants)
if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--fresh',type=Path);parser.add_argument('--self-test',action='store_true');args=parser.parse_args()
    result=check()
    if args.fresh:match_fresh(load(args.fresh),load(LEAN/'receipt.json'));result['fresh_proof_matches']=True
    if args.self_test:result['receipt_refusal_tests_passed']=self_test()
    print(json.dumps(result,indent=2))
