"""Compile and audit the finite package, retaining exact input/target evidence."""
import argparse,hashlib,json,os,re,subprocess
from datetime import datetime,timezone
from pathlib import Path
ROOT=Path(__file__).resolve().parent
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    parser=argparse.ArgumentParser();parser.add_argument('--lean',required=True);args=parser.parse_args()
    evidence=ROOT/'evidence';evidence.mkdir(exist_ok=True)
    from check_certificate import check,self_test
    certificate=check();certificate['tamper_tests_passed']=self_test()
    version=subprocess.run([args.lean,'--version'],check=True,capture_output=True,text=True,timeout=60).stdout.strip()
    expected=(ROOT/'lean-toolchain').read_text().strip().split(':v')[-1]
    assert 'version '+expected in version,(expected,version)
    targets=json.loads((ROOT/'targets.json').read_text());assert len(targets)==len(set(targets))
    sources=['OriginTracking.lean','FollowingLabels.lean','RecordedFollowing.lean','CheckAxioms.lean']
    declared=[]
    for name in sources:
        text=(ROOT/name).read_text(encoding='utf-8')
        assert not re.search(r'(?m)^\s*(axiom|unsafe)\b',text),name
        assert not re.search(r'\bsorry\b|\bnative_decide\b',text),name
        declared += [Path(name).stem+'.'+t for t in re.findall(r'^theorem (\w+)',text,re.M)]
    assert declared==targets,'Targets must cover every declared theorem in order'
    inputs={}
    for p in sorted(ROOT.rglob('*')):
        if p.is_file() and (p.suffix in ['.lean','.csv','.npz','.json','.py','.toml'] or p.name=='lean-toolchain'):
            if p.name=='receipt.json' or 'evidence' in p.relative_to(ROOT).parts:continue
            inputs[p.relative_to(ROOT).as_posix()]=digest(p)
    fingerprint=hashlib.sha256(json.dumps(inputs,sort_keys=True,separators=(',',':')).encode()).hexdigest()
    env=os.environ.copy();env['LEAN_PATH']=str(ROOT);logs={}
    for name in sources:
        result=subprocess.run([args.lean,'-o',str(ROOT/(Path(name).stem+'.olean')),str(ROOT/name)],cwd=ROOT,env=env,capture_output=True,text=True,encoding='utf-8',timeout=240)
        log=result.stdout+result.stderr;(evidence/(Path(name).stem+'.log')).write_text(log,encoding='utf-8')
        if result.returncode:raise RuntimeError(name+' did not compile:\n'+log[-5000:])
        logs[name]=dict(exit_code=result.returncode,log='evidence/'+Path(name).stem+'.log')
    ax=(evidence/'CheckAxioms.log').read_text(encoding='utf-8');dependencies={}
    for target in targets:
        found=re.search(re.escape("'"+target+"'")+r' depends on axioms: \[([^\]]*)\]',ax)
        no_axioms=("'"+target+"' does not depend on any axioms") in ax
        assert found or no_axioms,target+' absent from axiom log'
        deps=[] if no_axioms else [x.strip() for x in found.group(1).split(',') if x.strip()]
        assert set(deps)<=set(['propext','Classical.choice','Quot.sound']),(target,deps)
        dependencies[target]=deps
    for rel,h in inputs.items():assert digest(ROOT/rel)==h
    receipt=dict(status='PASS',verified_utc=datetime.now(timezone.utc).isoformat(),compiler=version,proof_input_fingerprint=fingerprint,proof_inputs=inputs,data_certificate_check=certificate,targets=targets,target_count=len(targets),axiom_dependencies=dependencies,checks=logs,no_added_axioms=True,no_sorry=True,no_native_decide=True,scope='Finite overlapping-view and identity rules; recorded neighbor and crossing histories, point/window origin decimals, selected material-field changes and full shared-record bytes. External source binding and stencil recount are separate. No fluid evolution, geometric membership, interpolation, continuous-time behavior or complete physical-retention proof.')
    (ROOT/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(dict(status='PASS',targets=len(targets),fingerprint=fingerprint,axiom_union=sorted({a for v in dependencies.values() for a in v}),source_check=certificate),indent=2))
if __name__=='__main__':main()
