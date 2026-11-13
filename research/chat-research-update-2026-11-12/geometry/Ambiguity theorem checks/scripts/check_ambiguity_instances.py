"""Compile in the existing pinned Linux Lean environment, saving every outcome."""
from pathlib import Path
import datetime, hashlib, json, os, re, subprocess

ROOT = Path('$USER_HOME/Documents/Codex/2026-11-10/lo')
OUT = ROOT / 'outputs/Ambiguity theorem checks'
SOURCE = OUT / 'lean'
LOGS = OUT / 'logs'
LOGS.mkdir(exist_ok=True)
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
project = Path('$USER_HOME/verification/project')
lean = Path('/opt/lean-audit/lean-4.34.0-rc2-linux/bin/lean')
lake = Path('$USER_HOME/verification/bin/lake')
prior = json.loads((ROOT/'outputs/SIMS rational readout check/corrected/verification.json').read_text())
env = dict(os.environ)
env['PATH'] = str(lean.parent)+':'+str(lake.parent)+':'+env.get('PATH','')
env['LEAN_PATH'] = str(SOURCE)
env['LEAN_NUM_THREADS'] = '1'
assert sha(lean) == prior['lean_binary_sha256']
mathlib = project/'.lake/packages/mathlib'
commit = subprocess.check_output(['git','-C',str(mathlib),'rev-parse','HEAD'],text=True).strip()
assert commit == prior['mathlib_commit']
assert not subprocess.check_output(['git','-C',str(mathlib),'status','--porcelain=v1','--untracked-files=no'],text=True).strip()
modules = ['SIMSLatentReadout','Volterra','TwoMemory','TwoMemoryTransport','YangMillsCueTest',
           'Tick41SavedWrite','Tick41SavedReturns','AmbiguityInstances']
previous_path = OUT/'Lean verification.json'
previous = json.loads(previous_path.read_text()) if previous_path.exists() else {}
cached = {r['module']:r for r in previous.get('modules',[])}
results = []
dependency_rebuilt = False
for name in modules:
    path = SOURCE/(name+'.lean')
    old = sha(path)
    code = path.read_text()
    assert not re.search(r'\b(sorry|admit|axiom|native_decide|implemented_by)\b',code), name
    obj = SOURCE/(name+'.olean')
    saved = cached.get(name,{})
    if (not dependency_rebuilt and saved.get('status')=='PASS' and saved.get('source_sha256')==old
            and obj.exists() and saved.get('object_sha256')==sha(obj)):
        results.append(saved)
        print(json.dumps({'module':name,'status':'previous successful check retained'}),flush=True)
        continue
    dependency_rebuilt = True
    command = [str(lake),'env',str(lean),'--root='+str(SOURCE),'-o',str(obj),str(path)]
    started = datetime.datetime.now(datetime.timezone.utc).isoformat()
    result = subprocess.run(command,cwd=project,env=env,stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT,text=True,timeout=180)
    (LOGS/(name+'.log')).write_text(result.stdout)
    assert sha(path)==old
    axioms = sorted({a.strip() for match in re.findall(r'depends on axioms: \[([^\]]*)\]',result.stdout)
                     for a in match.split(',') if a.strip()})
    reports = re.findall(r"'([^']+)' (?:depends on axioms|does not depend on any axioms)",result.stdout)
    passed = result.returncode==0 and set(axioms)<={'propext','Quot.sound','Classical.choice'}
    if name=='AmbiguityInstances':
        expected = len(re.findall(r'^#print axioms ',code,re.M))
        passed = passed and len(reports)==expected
    row = dict(module=name,status='PASS' if passed else 'FAIL',exit_code=result.returncode,
               source_sha256=old,object_sha256=sha(obj) if result.returncode==0 and obj.exists() else None,
               log_sha256=sha(LOGS/(name+'.log')),axioms=axioms,
               axiom_reports=reports,started_at_utc=started,
               finished_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),command=command)
    results.append(row)
    report = dict(status='PASS' if len(results)==len(modules) and passed else 'RUNNING' if passed else 'FAIL',
                  lean_binary_sha256=sha(lean),mathlib_commit=commit,modules=results)
    (OUT/'Lean verification.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({'module':name,'status':row['status'],'axiom_reports':len(reports)}),flush=True)
    if not passed:
        print(result.stdout,flush=True)
        raise SystemExit(1)
print('All modules verified; no new axioms or placeholders.',flush=True)
