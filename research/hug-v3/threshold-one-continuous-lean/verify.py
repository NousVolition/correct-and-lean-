"""Verify the published partial results. Never report a trajectory certificate.

Default: a fresh Lake build with the pinned manifest. For an offline installation,
--packages selects an already compiled Mathlib package directory and --lean selects
the matching compiler. All project modules are compiled anew in --output.
"""
import argparse,hashlib,json,os,re,shutil,subprocess,sys,tempfile,time
from datetime import datetime,timezone
from pathlib import Path
from generate_archive import generate

ROOT=Path(__file__).resolve().parent
MODULES=['FrozenPolynomial','FrozenNormalization','FrozenODE','FrozenField','FrozenArchive']
ALLOWED={'propext','Classical.choice','Quot.sound'}
PIN='85e3a25e006c35636f0e53b0e9296caca2685bc0'

def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def validate_axioms(log,targets):
    matches=re.findall(r"'([^']+)' depends on axioms: \[([^\]]*)\]",log,re.S)
    parsed={name:[] if not deps.strip() else [x.strip() for x in deps.split(',')]
        for name,deps in matches}
    for name in re.findall(r"'([^']+)' does not depend on any axioms",log):
        parsed[name]=[]
    if set(parsed)!=set(targets):raise ValueError('Axiom target coverage mismatch')
    for name,deps in parsed.items():
        if not set(deps)<=ALLOWED:raise ValueError('Unapproved axiom: '+name+': '+str(deps))
    return parsed

def check_inputs():
    with tempfile.TemporaryDirectory(prefix='frozen-inputs-') as tmp:
        generate(ROOT.parent/'threshold-one-window-study',Path(tmp))
        for name in ('FrozenArchive.lean','archive-inputs.json'):
            if (ROOT/name).read_bytes()!=(Path(tmp)/name).read_bytes():
                raise ValueError('Archive transcription differs: '+name)

def run(args):
    output=args.output.resolve();output.mkdir(parents=True,exist_ok=False)
    evidence=output/'evidence';evidence.mkdir()
    check_inputs()
    targets=json.loads((ROOT/'targets.json').read_text())
    found=[]
    for module in MODULES:
        text=(ROOT/(module+'.lean')).read_text(encoding='utf-8')
        namespace=re.search(r'^namespace (\S+)',text,re.M)[1]
        found += [namespace+'.'+m[1] for m in re.finditer(r'^theorem (\w+)',text,re.M)]
        if re.search(r'\b(sorry|admit|axiom|native_decide|ofReduceBool)\b',text):
            raise ValueError('Forbidden proof escape in '+module)
    if found!=targets:raise ValueError('Named theorem inventory differs')
    hashes={p.name:digest(p) for p in ROOT.iterdir() if p.is_file()
        and p.suffix in ('.lean','.toml','.json','.py') and p.name!='receipt.json'}
    runs=[]
    def command(name,cmd,cwd,env=None,timeout=1800):
        start=time.monotonic()
        result=subprocess.run(cmd,cwd=cwd,env=env,capture_output=True,text=True,
            encoding='utf-8',errors='replace',timeout=timeout)
        log=result.stdout+result.stderr
        (evidence/(name+'.log')).write_text(log,encoding='utf-8',newline='\n')
        runs.append({'name':name,'exit_code':result.returncode,'seconds':time.monotonic()-start,
            'log_sha256':digest(evidence/(name+'.log'))})
        print(json.dumps(runs[-1]),flush=True)
        if result.returncode or re.search(r'\b(warning|error):',log):
            raise ValueError('Compiler failure or warning: '+name+'\n'+log[:6000])
        return log
    lean=str(args.lean or shutil.which('lean') or 'lean')
    version=subprocess.check_output([lean,'--version'],text=True).strip()
    if '4.34.0-rc2' not in version:raise ValueError('Wrong Lean release: '+version)
    if args.packages:
        packages=args.packages.resolve()
        actual=subprocess.check_output(['git','-C',str(packages/'mathlib'),'rev-parse','HEAD'],text=True).strip()
        if actual!=PIN:raise ValueError('Wrong Mathlib revision')
        env=dict(os.environ)
        env['LEAN_PATH']=os.pathsep.join([str(output)]+[str(p/'.lake/build/lib/lean')
            for p in sorted(packages.iterdir()) if p.is_dir()])
        for module in MODULES+['CheckAxioms']:
            shutil.copyfile(ROOT/(module+'.lean'),output/(module+'.lean'))
            command(module,[lean,'-o',module+'.olean',module+'.lean'],output,env)
        mode='fresh direct Lean compilation, prebuilt pinned dependencies'
    else:
        if (ROOT/'.lake/build').exists():raise ValueError('Use a fresh checkout for the Lake receipt')
        command('lake-build',['lake','build'],ROOT)
        command('CheckAxioms',['lake','env','lean','CheckAxioms.lean'],ROOT)
        mode='fresh Lake build and explicit axiom report'
    axioms=validate_axioms((evidence/'CheckAxioms.log').read_text(encoding='utf-8'),targets)
    receipt={'verification_status':'PASS','requested_trajectory_certificate':'NOT_CERTIFIED',
        'scope':'General enclosure lemmas and global bounds on the six archived Fourier fields.',
        'certified_full_signed_traces':0,'required_full_signed_traces':6,
        'certified_directional_traces':0,'required_directional_traces':12,
        'certified_window_minima':0,'required_window_minima':36,
        'generated_at_utc':datetime.now(timezone.utc).isoformat(),'mode':mode,
        'lean_version':version,'mathlib_revision':PIN,'source_hashes':hashes,
        'named_theorem_count':len(targets),'axioms':axioms,'runs':runs,
        'transcription':'External regeneration and SHA-256 checks; not proved inside Lean.',
        'not_run':['Comparator','nanoda'],
        'execution_context':{'repository':os.getenv('GITHUB_REPOSITORY'),
          'checkout_sha':os.getenv('GITHUB_SHA'),'pull_request_head_sha':os.getenv('PR_HEAD'),
          'run_id':os.getenv('GITHUB_RUN_ID'),'run_attempt':os.getenv('GITHUB_RUN_ATTEMPT')}}
    (output/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps({'verification_status':'PASS','requested_trajectory_certificate':'NOT_CERTIFIED',
        'named_theorems':len(targets)}),flush=True)

if __name__=='__main__':
    if hasattr(sys.stdout,'reconfigure'):sys.stdout.reconfigure(encoding='utf-8',errors='replace')
    parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--packages',type=Path);parser.add_argument('--lean',type=Path)
    parser.add_argument('--require-trajectories',action='store_true')
    args=parser.parse_args()
    if args.require_trajectories:
        parser.exit(2,'NOT_CERTIFIED: no closed archived-field trajectory or whole-window minimum theorem is supplied.\n')
    run(args)
