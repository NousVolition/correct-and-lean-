"""Bind saved heat records to the exact proofs, then build and audit every target."""
import argparse,copy,hashlib,json,os,re,subprocess,sys,tomllib
from datetime import datetime,timezone
from pathlib import Path
ROOT=Path(__file__).resolve().parent;REPO=ROOT.parents[2];STUDY=ROOT.parent/'heat-follow-study'
PIN='85e3a25e006c35636f0e53b0e9296caca2685bc0'
ALLOWED={'propext','Classical.choice','Quot.sound'}
AXIOM=re.compile(r"'([^']+)' (?:depends on axioms:\s*\[([^\]]*)\]|does not depend on any axioms)\.?\Z",re.S)
def load(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def fingerprint(x):return hashlib.sha256(json.dumps(x,sort_keys=True,separators=(',',':')).encode()).hexdigest()
def parse_axioms(text,targets,json_lines=False):
    found={}
    for line in text.splitlines():
        if json_lines:
            message=json.loads(line);assert message.get('severity')!='error',message;line=str(message.get('data','')).strip()
        m=AXIOM.fullmatch(line.strip())
        if not m:continue
        name,used=m.groups();values=[v.strip() for v in used.split(',') if v.strip()] if used else []
        assert name in targets and set(values)<=ALLOWED,(name,values)
        if name in found:assert found[name]==values
        found[name]=values
    assert set(found)==set(targets),'Missing dependency reports'
    return found
def validate_receipt(r,manifest,targets):
    assert r['status']=='PASS' and r['lake_build']=='PASS' and r['target_count']==len(targets)==56
    for key in ['proof_inputs','proof_input_fingerprint','publication_inputs','publication_input_fingerprint']:assert r[key]==manifest[key],'Stale '+key
    assert r['targets']==targets and r['axiom_dependencies']==load(ROOT/'expected-axioms.json')
    assert r['mathlib_revision']==PIN and r['no_added_axioms'] and r['no_sorry'] and r['no_native_decide']
    assert r['source_transcription']=='PASS' and r['simulation_rerun'] is False
def check_saved():
    manifest=load(ROOT/'publication-manifest.json');local=load(ROOT/'receipt.json');targets=load(ROOT/'targets.json')
    for rel,h in manifest['publication_inputs'].items():
        p=(REPO/rel).resolve();assert p.is_relative_to(REPO) and p.is_file() and sha(p)==h,'Changed publication input: '+rel
    assert fingerprint(manifest['publication_inputs'])==manifest['publication_input_fingerprint']
    assert manifest['proof_inputs']==local['proof_inputs'] and manifest['proof_input_fingerprint']==local['proof_input_fingerprint']
    assert fingerprint(manifest['proof_inputs'])==manifest['proof_input_fingerprint']
    for rel,h in manifest['proof_inputs'].items():assert sha(ROOT/rel)==h,'Changed proof input: '+rel
    assert local['status']=='PASS' and local['target_count']==56 and local['targets']==targets
    declarations=[]
    for filename,ns in [('HeatAccounting.lean','HeatAccounting'),('RecordedHeat.lean','RecordedHeat')]:
        text=(ROOT/filename).read_text(encoding='utf-8');declarations += [ns+'.'+n for n in re.findall(r'^theorem (\w+)',text,re.M)]
        assert not re.search(r'\b(sorryAx|sorry|admit|axiom|native_decide|unsafe|implemented_by)\b',text),filename
    assert declarations==targets and len(set(targets))==56
    assert sorted(p.name for p in ROOT.glob('*.lean'))==['CheckAxioms.lean','HeatAccounting.lean','RecordedHeat.lean']
    audit=(ROOT/'CheckAxioms.lean').read_text(encoding='utf-8')
    assert re.findall(r'^#print axioms (\S+)',audit,re.M)==targets
    expected=load(ROOT/'expected-axioms.json');assert local['axiom_dependencies']==expected
    assert sum(bool(v) for v in expected.values())==4 and all(not expected[t] for t in targets[4:])
    for f,h in local['logs_sha256'].items():assert sha(ROOT/f)==h
    for f in ['general-check.exit','recorded-check.exit','axioms.exit']:assert (ROOT/f).read_text(encoding='utf-8-sig').strip()=='0'
    assert parse_axioms((ROOT/'axioms.log').read_text(encoding='utf-8-sig'),targets)==expected
    check=subprocess.run([sys.executable,'generate_records.py','--check'],cwd=ROOT,capture_output=True,text=True,timeout=60)
    assert check.returncode==0,check.stdout+check.stderr
    assert load(ROOT/'generation.json')['dense_rows']==2408
    provenance=load(STUDY/'provenance.json');repro=STUDY/'reproduction/work/heat-follow'
    frozen=load(repro/'inputs/manifest.json');assert len(frozen)==42
    for entry in frozen:assert sha(repro/'inputs'/entry['path'])==entry['sha256']
    for tag in ['n16_dt0p002','n16_dt0p001']:
        r=load(STUDY/tag/'receipt.json');assert r['status']=='completed' and r['grid']==16 and r['end']==1.6
        assert sha(repro/'run_heat.py')==r['runner_sha256']==provenance['original_runner_sha256']
        assert r['input_manifest_sha256']==provenance['original_input_manifest_sha256']
        for rel,h in r['input_files_sha256'].items():
            edit=provenance['path_only_input_edits'].get(rel)
            assert sha(repro/'inputs'/rel)==(edit['published_sha256'] if edit else h)
            if edit:assert edit['original_sha256']==h
        for rel,h in r['files_sha256'].items():assert sha(STUDY/tag/rel)==h
        for f in ['receipt.json','history.csv']:assert sha(STUDY/tag/f)==sha(ROOT/'source-data'/(tag+'-'+f))
    assert sha(STUDY/'analysis.json')==sha(ROOT/'source-data/analysis.json')
    analysis=load(STUDY/'analysis.json');assert analysis['time_step_all_criteria_pass'] and len(analysis['runs'])==2
    assert all(c['both_crc'][0]!=c['both_crc'][1] for c in analysis['time_step_comparison'])
    if (ROOT/'github-lean-receipt.json').exists():
        saved=load(ROOT/'github-lean-receipt.json');validate_receipt(saved,manifest,targets)
        c=saved['execution_context'];assert c['repository']=='NousVolition/hug-sims-lean-proofs'
        assert c['run_url']=='https://github.com/NousVolition/hug-sims-lean-proofs/actions/runs/'+str(c['run_id'])
    return manifest,targets
def self_test(manifest,targets):
    good={**manifest,'status':'PASS','lake_build':'PASS','target_count':56,'targets':targets,'axiom_dependencies':load(ROOT/'expected-axioms.json'),'mathlib_revision':PIN,'no_added_axioms':True,'no_sorry':True,'no_native_decide':True,'source_transcription':'PASS','simulation_rerun':False}
    validate_receipt(good,manifest,targets);bad=[]
    for key in ['proof_input_fingerprint','publication_input_fingerprint']:
        r=copy.deepcopy(good);r[key]='0'*64;bad.append(r)
    r=copy.deepcopy(good);r['targets']=targets[:-1];bad.append(r)
    r=copy.deepcopy(good);r['axiom_dependencies'][targets[-1]]=['sorryAx'];bad.append(r)
    r=copy.deepcopy(good);r['proof_inputs']['RecordedHeat.lean']='0'*64;bad.append(r)
    r=copy.deepcopy(good);r['lake_build']='NOT_RUN';bad.append(r)
    for r in bad:
        try:validate_receipt(r,manifest,targets)
        except AssertionError:pass
        else:raise AssertionError('Invalid receipt accepted')
    return len(bad)
def main():
    p=argparse.ArgumentParser();p.add_argument('--check-only',action='store_true');p.add_argument('--self-test',action='store_true');a=p.parse_args()
    manifest,targets=check_saved();result={'status':'PASS','targets':len(targets),'rows':2408,'proof_input_fingerprint':manifest['proof_input_fingerprint'],'publication_input_fingerprint':manifest['publication_input_fingerprint']}
    if a.self_test:result['invalid_receipts_refused']=self_test(manifest,targets)
    if a.check_only:print(json.dumps(result));return
    out=ROOT/'github-evidence';out.mkdir(exist_ok=True)
    version=subprocess.check_output(['lake','env','lean','--version'],cwd=ROOT,text=True,timeout=60).strip();assert 'version 4.34.0-rc2' in version
    actual=subprocess.check_output(['git','-C',str(ROOT/'.lake/packages/mathlib'),'rev-parse','HEAD'],text=True,timeout=60).strip()
    pinned=next(p['rev'] for p in tomllib.loads((ROOT/'lakefile.toml').read_text())['require'] if p['name']=='mathlib');assert actual==pinned==PIN
    with (out/'lake-build.log').open('w',encoding='utf-8') as log:built=subprocess.run(['lake','build'],cwd=ROOT,stdout=log,stderr=subprocess.STDOUT,text=True,timeout=900)
    (out/'lake-build.exit').write_text(str(built.returncode)+'\n');assert built.returncode==0,'Lake build failed'
    audit=subprocess.run(['lake','env','lean','--json','CheckAxioms.lean'],cwd=ROOT,capture_output=True,text=True,encoding='utf-8',timeout=240)
    (out/'axioms.jsonl').write_text(audit.stdout,encoding='utf-8');(out/'axioms.stderr.log').write_text(audit.stderr,encoding='utf-8');assert audit.returncode==0
    axioms=parse_axioms(audit.stdout,targets,json_lines=True);assert axioms==load(ROOT/'expected-axioms.json')
    assert check_saved()==(manifest,targets)
    context={'repository':os.environ.get('GITHUB_REPOSITORY'),'checkout_sha':os.environ.get('GITHUB_SHA'),'pull_request_head_sha':os.environ.get('PR_HEAD') or None,'event':os.environ.get('GITHUB_EVENT_NAME'),'run_id':int(os.environ['GITHUB_RUN_ID']) if os.environ.get('GITHUB_RUN_ID') else None,'run_attempt':int(os.environ.get('GITHUB_RUN_ATTEMPT','1')),'run_url':os.environ.get('GITHUB_SERVER_URL','https://github.com')+'/'+os.environ.get('GITHUB_REPOSITORY','')+'/actions/runs/'+os.environ.get('GITHUB_RUN_ID','')}
    receipt={**manifest,'status':'PASS','verified_utc':datetime.now(timezone.utc).isoformat(),'compiler':version,'mathlib_revision':actual,'lake_build':'PASS','target_count':56,'targets':targets,'recorded_global_account_rows':2408,'axiom_dependencies':axioms,'no_added_axioms':True,'no_sorry':True,'no_native_decide':True,'source_transcription':'PASS','simulation_rerun':False,'execution_context':context,'logs_sha256':{p.name:sha(p) for p in sorted(out.iterdir()) if p.is_file() and p.name!='github-lean-receipt.json'},'scope':'Four finite rules under explicit hypotheses and 52 recorded-data declarations. External file binding/transcription is separate. No Lean execution or verification of fluid evolution, array-derived metrics, zero-sum solver/PDE flux, physical heat parcels or spatial convergence. The residual encoding example is separate and outside these targets.'}
    validate_receipt(receipt,manifest,targets);(out/'github-lean-receipt.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8')
    print('HEAT_FOLLOW_GITHUB_RECEIPT_BEGIN');print(json.dumps(receipt,sort_keys=True));print('HEAT_FOLLOW_GITHUB_RECEIPT_END')
if __name__=='__main__':main()
