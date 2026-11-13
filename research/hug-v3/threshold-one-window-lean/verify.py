"""Recheck generated input, run Lean's kernel and Lake, and record all axiom reports."""
import argparse,json,os,re,shutil,subprocess
from datetime import datetime,timezone
from pathlib import Path
from generate import build
from certificate import HERE,MODULES,TARGETS,COUNTS,SCOPE,LIMITS,sha,manifest,proof_hashes,audit_source,validate

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--lean',default=shutil.which('lean'))
    parser.add_argument('--source-dir',type=Path,default=HERE.parent/'threshold-one-window-study')
    parser.add_argument('--work-dir',required=True,type=Path)
    args=parser.parse_args()
    if not args.lean:parser.error('Provide the pinned Lean executable with --lean or PATH.')
    work=args.work_dir.resolve();source=args.source_dir.resolve()
    assert not work.is_relative_to(HERE) and not work.is_relative_to(source),'Use a separate build directory'
    work.mkdir(parents=True,exist_ok=True)
    evidence=work/'evidence';evidence.mkdir(exist_ok=True)
    data,counts=build(source)
    assert counts==COUNTS
    assert (HERE/'WindowRecordData.lean').read_bytes()==data.encode('utf-8'),'Generated input differs'
    audit_source()
    inputs=proof_hashes();sources=manifest()['files']
    for name in inputs:shutil.copyfile(HERE/name,work/name)
    lean=Path(args.lean).resolve();lake=lean.with_name('lake.exe' if os.name=='nt' else 'lake')
    assert lake.is_file(),'The pinned Lean installation must include Lake'
    version=subprocess.check_output([str(lean),'--version'],text=True,encoding='utf-8').strip()
    assert 'version 4.34.0-rc2' in version,version
    env=dict(os.environ,LEAN_PATH=str(work),PATH=str(lean.parent)+os.pathsep+os.environ.get('PATH',''))
    started=datetime.now(timezone.utc).isoformat();runs=[]
    for module in MODULES+['lake build']:
        if module=='lake build':command=[str(lake),'build']
        else:
            command=[str(lean),'-DwarningAsError=true']
            if module!='CheckAxioms':command+=['-o',module+'.olean']
            command+=[module+'.lean']
        result=subprocess.run(command,cwd=work,env=env,capture_output=True,text=True,encoding='utf-8',timeout=240)
        log=module.replace(' ','-')+'.log'
        (evidence/log).write_text(result.stdout+result.stderr,encoding='utf-8',newline='\n')
        runs.append({'module':module,'exit_code':result.returncode,'command':[Path(command[0]).stem]+command[1:],
                     'log':'evidence/'+log,'log_sha256':sha(evidence/log)})
        print(f'{module}: exit {result.returncode}',flush=True)
        if result.returncode:
            print((result.stdout+result.stderr)[:12000],flush=True)
            raise SystemExit(result.returncode)
    audit=(evidence/'CheckAxioms.log').read_text(encoding='utf-8')
    axioms={n:[] for n in re.findall(r"'([^']+)' does not depend on any axioms",audit)}
    for n,used in re.findall(r"'([^']+)' depends on axioms:\s*\[([^\]]*)\]",audit):
        axioms[n]=[s.strip() for s in used.split(',') if s.strip()]
    assert axioms=={n:[] for n in TARGETS},axioms
    assert proof_hashes()==inputs
    assert all(sha(source/name)==expected for name,expected in sources.items())
    result={'status':'PASS','started_at_utc':started,'finished_at_utc':datetime.now(timezone.utc).isoformat(),
            'lean_version':version,'lean_binary_sha256':sha(lean),'proof_inputs_sha256':inputs,
            'source_data_sha256':sources,'source_commit':manifest()['source_commit'],
            'targets':TARGETS,'theorem_count':len(TARGETS),'axioms':axioms,'counts':counts,
            'runs':runs,'generated_input_matches':True,'source_inputs_unchanged':True,
            'native_decide_used':False,'scope':SCOPE,'limits':LIMITS}
    validate(result)
    (work/'receipt.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps({'status':'PASS','theorems':len(TARGETS),'axiom_dependencies':[],**counts},indent=2))
if __name__=='__main__':main()
