"""Bind the heat draft to its sources, build it, and audit all twelve targets."""
import argparse,copy,gzip,hashlib,json,os,re,subprocess,tomllib
from datetime import datetime,timezone
from decimal import Decimal,getcontext
from pathlib import Path
getcontext().prec=80
ROOT=Path(__file__).resolve().parent
ALLOWED={'propext','Classical.choice','Quot.sound'}
AXIOM=re.compile(r"'([^']+)' (?:depends on axioms:\s*\[([^\]]*)\]|does not depend on any axioms)\.?\Z",re.S)
def load(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def fingerprint(inputs):return hashlib.sha256(json.dumps(inputs,sort_keys=True,separators=(',',':')).encode()).hexdigest()
def parse_axioms(text,targets,json_lines=False):
    seen={}
    for line in text.splitlines():
        if json_lines:
            message=json.loads(line)
            assert message.get('severity')!='error',message
            line=str(message.get('data','')).strip()
        match=AXIOM.fullmatch(line.strip())
        if not match:continue
        name,used=match.groups();values=[a.strip() for a in used.split(',') if a.strip()] if used else []
        assert name in targets and set(values)<=ALLOWED,(name,values)
        if name in seen:assert seen[name]==values
        seen[name]=values
    assert set(seen)==set(targets),'Missing axiom lists'
    return seen
def records(code=None,replay=None):
    code=code if code is not None else (ROOT/'HeatFromHolding.lean').read_text(encoding='utf-8')
    replay=replay if replay is not None else json.loads((ROOT/'source-data/tick41-replay-results.json').read_text(),parse_float=Decimal)
    parent=json.loads(gzip.decompress((ROOT/'source-data/threshold-one-parent-results.json.gz').read_bytes()).decode(),parse_float=Decimal)
    assert replay['run']=='threshold 1; breathing on; original native step 0.002' and replay['tick']==41 and replay['time']==Decimal('1.2')
    assert replay['frame']==600 and Decimal(str(parent['dt']))==Decimal('.002')
    account=replay['write_account'];prior=parent['receipts']['on']['writes'][2]['account'];values={}
    for key,name in [('work','recordedWork'),('stored','recordedStored'),('heat','recordedHeat')]:
        value=int(re.search(r'def '+name+r' : ℤ := (-?\d+)',code).group(1));assert Decimal(value)*Decimal('1e-27')==account[key],key+' differs from replay'
        values[key]=str(account[key])
    residual=account['work']-account['stored']-account['heat'];assert residual==Decimal('-9.954e-22') and abs(residual)<Decimal('1e-21')
    assert account['stored']-prior['stored']==Decimal('-3.706e-22')
    assert 'def strokeHeat (drag duration δ : ℝ) : ℝ := drag * δ * δ / duration' in code
    assert 'def writeWork (stored heat : ℝ) : ℝ := stored + heat' in code
    assert 'def viscosity (base feedback s : ℝ) : ℝ := base * Real.exp (-(feedback * s))' in code
    structural=(ROOT/'source-data/structural_hug.py').read_text();continuum=(ROOT/'source-data/continuum.py').read_text()
    for formula in ['delta=target-b','heat_cell=self.c.stroke_drag*delta*delta/self.c.stroke_duration','work=stored+dissipation',"out['g'][...,4]+=self.filter(heat_grid)"]:
        assert formula in structural,formula
    for setting in ['stroke_drag:float=.05','stroke_duration:float=.02']:assert setting in structural
    assert 'nu=c.nu*np.exp(-c.thermal_feedback*np.tanh(theta/.03))' in continuum and 'thermal_feedback:float=.35' in continuum
    return {'status':'PASS','run':replay['run'],'tick':41,'time':'1.2','recorded_decimals':values,'scale':'1e-27','balance_residual':str(residual),'balance_tolerance':'1e-21','parent_stored':str(prior['stored']),'replay_stored_minus_parent':str(account['stored']-prior['stored']),'formula_transcription_matched':True,'simulation_rerun':False,'scope':'External source transcription and exact decimal comparison, not a Lean proof of Python, tanh linkage or fluid evolution.'}
def validate_receipt(receipt,inputs,targets,source_check):
    assert receipt['status']=='PASS' and receipt['target_count']==len(targets)==12
    assert receipt['proof_inputs']==inputs and receipt['proof_input_fingerprint']==fingerprint(inputs),'Stale fingerprint'
    assert receipt['targets']==targets and receipt['source_check']==source_check,'Stale targets or source record'
    assert receipt['axiom_dependencies']==load(ROOT/'expected-axioms.json')
    assert receipt['mathlib_revision']=='85e3a25e006c35636f0e53b0e9296caca2685bc0'
    assert receipt['lake_build']=='PASS' and receipt['no_added_axioms'] and receipt['no_sorry'] and receipt['no_native_decide']
def check_saved():
    manifest=load(ROOT/'publication-manifest.json');inputs=manifest['proof_inputs']
    for rel,digest in manifest['files'].items():
        p=(ROOT/rel).resolve();assert p.is_relative_to(ROOT) and p.is_file() and sha(p)==digest,'Changed publication: '+rel
    assert set(inputs)==set(manifest['files'])-{'README.md','provenance.json','.gitattributes','.gitignore'},'Input coverage mismatch'
    assert all(v==manifest['files'][k] for k,v in inputs.items())
    assert manifest['proof_input_fingerprint']==fingerprint(inputs)
    code=(ROOT/'HeatFromHolding.lean').read_text(encoding='utf-8');targets=load(ROOT/'targets.json')
    assert targets==['HeatFromHolding.'+n for n in re.findall(r'^theorem (\w+)',code,re.M)] and len(targets)==len(set(targets))==12
    assert [p.name for p in sorted(ROOT.glob('*.lean'))]==['CheckAxioms.lean','HeatFromHolding.lean']
    for name in ['HeatFromHolding.lean','CheckAxioms.lean']:
        text=(ROOT/name).read_text(encoding='utf-8');assert not re.search(r'\b(sorryAx|sorry|admit|axiom|native_decide|unsafe|implemented_by)\b',text),name
    assert re.findall(r'^#print axioms (\S+)',(ROOT/'CheckAxioms.lean').read_text(),re.M)==targets
    original=load(ROOT/'local-evidence/receipt.json');assert original['status']=='PASS_FOR_THE_12_STATED_THEOREMS'
    assert sha(ROOT/'HeatFromHolding.lean')==original['source_sha256'] and original['targets']==targets
    assert (ROOT/'local-evidence/original-compilation.exit').read_text(encoding='utf-8-sig').strip()=='0'
    assert (ROOT/'local-evidence/all-dependencies.exit').read_text(encoding='utf-8-sig').strip()=='0'
    expected={'HeatFromHolding.'+k:v for k,v in original['axiom_dependencies'].items()}
    assert expected==load(ROOT/'expected-axioms.json')
    assert parse_axioms((ROOT/'local-evidence/all-dependencies.log').read_text(encoding='utf-8-sig'),targets)==expected
    provenance=load(ROOT/'provenance.json');assert sha(ROOT/'local-evidence/receipt.json')==provenance['published_local_receipt_sha256']
    for rel,data in provenance['source_files'].items():
        assert sha(ROOT/rel)==data['published_sha256']
        raw=(ROOT/rel).read_bytes();raw=gzip.decompress(raw) if data['encoding'].startswith('gzip') else raw
        expected=data['published_uncompressed_sha256'] if data['encoding']=='gzip_path_labels' else data['original_sha256']
        assert hashlib.sha256(raw).hexdigest()==expected
        if data['encoding']=='gzip_path_labels':
            assert data['path_label_replacements']==8 and raw.count(b'local-source\\\\')==8
            assert b'C:\\\\Users' not in raw and b'C:/Users' not in raw
    source_check=records()
    if (ROOT/'github-lean-receipt.json').exists():
        published=load(ROOT/'github-lean-receipt.json');validate_receipt(published,inputs,targets,source_check)
        context=published['execution_context'];assert context['repository']=='NousVolition/hug-sims-lean-proofs'
        assert context['run_url']=='https://github.com/NousVolition/hug-sims-lean-proofs/actions/runs/'+str(context['run_id'])
        assert re.fullmatch('[a-f0-9]{40}',context['checkout_sha'])
    return inputs,targets,source_check
def self_test(inputs,targets,source_check):
    code=(ROOT/'HeatFromHolding.lean').read_text(encoding='utf-8');match=re.search(r'def recordedWork : ℤ := (\d+)',code)
    changed=code[:match.start(1)]+str(int(match.group(1))+1)+code[match.end(1):]
    replay=json.loads((ROOT/'source-data/tick41-replay-results.json').read_text(),parse_float=Decimal);replay['run']='threshold 0.015'
    for action in [lambda:records(code=changed),lambda:records(replay=replay)]:
        try:action()
        except AssertionError:pass
        else:raise AssertionError('Changed source accepted')
    good={'status':'PASS','target_count':12,'targets':targets,'proof_inputs':inputs,'proof_input_fingerprint':fingerprint(inputs),'source_check':source_check,'axiom_dependencies':load(ROOT/'expected-axioms.json'),'mathlib_revision':'85e3a25e006c35636f0e53b0e9296caca2685bc0','lake_build':'PASS','no_added_axioms':True,'no_sorry':True,'no_native_decide':True}
    validate_receipt(good,inputs,targets,source_check)
    variants=[]
    r=copy.deepcopy(good);r['proof_input_fingerprint']='0'*64;variants.append(r)
    r=copy.deepcopy(good);r['targets']=targets[:-1];variants.append(r)
    r=copy.deepcopy(good);r['axiom_dependencies'][targets[0]]=['sorryAx'];variants.append(r)
    r=copy.deepcopy(good);r['proof_inputs']['HeatFromHolding.lean']='0'*64;variants.append(r)
    for r in variants:
        try:validate_receipt(r,inputs,targets,source_check)
        except AssertionError:pass
        else:raise AssertionError('Stale receipt accepted')
    return {'source_refusals':2,'receipt_refusals':4}
def main():
    parser=argparse.ArgumentParser();parser.add_argument('--check-only',action='store_true');parser.add_argument('--self-test',action='store_true');args=parser.parse_args()
    inputs,targets,source_check=check_saved();result={'status':'PASS','targets':len(targets),'fingerprint':fingerprint(inputs),'source_check':source_check}
    if args.self_test:result['refusal_tests']=self_test(inputs,targets,source_check)
    if args.check_only:print(json.dumps(result,indent=2));return
    output=ROOT/'github-evidence';output.mkdir(exist_ok=True)
    version=subprocess.check_output(['lake','env','lean','--version'],cwd=ROOT,text=True,timeout=60).strip();assert 'version 4.34.0-rc2' in version
    pinned=next(p['rev'] for p in tomllib.loads((ROOT/'lakefile.toml').read_text())['require'] if p['name']=='mathlib')
    actual=subprocess.check_output(['git','-C',str(ROOT/'.lake/packages/mathlib'),'rev-parse','HEAD'],text=True,timeout=60).strip();assert actual==pinned
    with (output/'lake-build.log').open('w',encoding='utf-8') as log:
        built=subprocess.run(['lake','build'],cwd=ROOT,stdout=log,stderr=subprocess.STDOUT,text=True,timeout=900)
    (output/'lake-build.exit').write_text(str(built.returncode)+'\n');assert built.returncode==0,'Lake build failed'
    audit=subprocess.run(['lake','env','lean','--json','CheckAxioms.lean'],cwd=ROOT,capture_output=True,text=True,encoding='utf-8',timeout=240)
    (output/'axioms.jsonl').write_text(audit.stdout,encoding='utf-8');(output/'axioms.stderr.log').write_text(audit.stderr,encoding='utf-8');assert audit.returncode==0
    axioms=parse_axioms(audit.stdout,targets,json_lines=True);assert axioms==load(ROOT/'expected-axioms.json')
    assert check_saved()==(inputs,targets,source_check)
    context={'repository':os.environ.get('GITHUB_REPOSITORY'),'checkout_sha':os.environ.get('GITHUB_SHA'),'pull_request_head_sha':os.environ.get('PR_HEAD') or None,'event':os.environ.get('GITHUB_EVENT_NAME'),'run_id':int(os.environ['GITHUB_RUN_ID']) if os.environ.get('GITHUB_RUN_ID') else None,'run_attempt':int(os.environ.get('GITHUB_RUN_ATTEMPT','1')),'run_url':os.environ.get('GITHUB_SERVER_URL','https://github.com')+'/'+os.environ.get('GITHUB_REPOSITORY','')+'/actions/runs/'+os.environ.get('GITHUB_RUN_ID','')}
    receipt={'status':'PASS','verified_utc':datetime.now(timezone.utc).isoformat(),'compiler':version,'mathlib_revision':actual,'lake_build':'PASS','proof_inputs':inputs,'proof_input_fingerprint':fingerprint(inputs),'targets':targets,'target_count':12,'axiom_dependencies':axioms,'no_added_axioms':True,'no_sorry':True,'no_native_decide':True,'source_check':source_check,'execution_context':context,'logs_sha256':{p.name:sha(p) for p in sorted(output.iterdir()) if p.is_file() and p.name!='github-lean-receipt.json'},'scope':'The twelve supplied scalar/formula and exact-recorded-number theorems only. Source transcription is external. No heat spreading, accumulation, tanh linkage, trajectories or full fluid/retention proof.'}
    validate_receipt(receipt,inputs,targets,source_check)
    (output/'github-lean-receipt.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8')
    print('HEAT_GITHUB_RECEIPT_BEGIN');print(json.dumps(receipt,sort_keys=True));print('HEAT_GITHUB_RECEIPT_END')
if __name__=='__main__':main()
