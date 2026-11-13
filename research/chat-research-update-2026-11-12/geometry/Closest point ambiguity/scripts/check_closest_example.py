"""Check new exact-fluid examples in the existing pinned Lean installation."""
from pathlib import Path
import datetime, hashlib, json, os, re, shutil, subprocess, sys

ROOT = Path('$USER_HOME/Documents/Codex/2026-11-10/lo')
OUT = ROOT / 'outputs/Closest point ambiguity'
SOURCE = OUT / 'lean'
LOGS = OUT / 'logs'
LOGS.mkdir(exist_ok=True)
OLD = ROOT / 'outputs/Ambiguity theorem checks'
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
prior = json.loads((OLD/'Lean verification.json').read_text())
project = Path('$USER_HOME/verification/project')
lean = Path('/opt/lean-audit/lean-4.34.0-rc2-linux/bin/lean')
lake = Path('$USER_HOME/verification/bin/lake')
assert sha(lean) == prior['lean_binary_sha256']
mathlib = project/'.lake/packages/mathlib'
commit = subprocess.check_output(['git','-C',str(mathlib),'rev-parse','HEAD'],text=True).strip()
assert commit == prior['mathlib_commit']
assert not subprocess.check_output(['git','-C',str(mathlib),'status','--porcelain=v1','--untracked-files=no'],text=True).strip()
base = next(r for r in prior['modules'] if r['module']=='SIMSLatentReadout')
for suffix, key in [('.lean','source_sha256'),('.olean','object_sha256')]:
    p = OLD/'lean'/('SIMSLatentReadout'+suffix)
    assert sha(p) == base[key]
    shutil.copy2(p,SOURCE/p.name)
env = dict(os.environ)
env['PATH'] = str(lean.parent)+':'+str(lake.parent)+':'+env.get('PATH','')
env['LEAN_PATH'] = str(SOURCE)
env['LEAN_NUM_THREADS'] = '1'
name = sys.argv[1]
path = SOURCE/(name+'.lean')
code = path.read_text()
assert not re.search(r'\b(sorry|admit|axiom|native_decide|implemented_by)\b',code)
obj = SOURCE/(name+'.olean')
before = sha(path)
command = [str(lake),'env',str(lean),'--root='+str(SOURCE),'-o',str(obj),str(path)]
started = datetime.datetime.now(datetime.timezone.utc).isoformat()
run_id = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S')
result = subprocess.run(command,cwd=project,env=env,stdout=subprocess.PIPE,
                        stderr=subprocess.STDOUT,text=True,timeout=180)
log = LOGS/(name+'-'+run_id+'.log')
log.write_text(result.stdout)
assert sha(path)==before
axioms = sorted({a.strip() for match in re.findall(r'depends on axioms: \[([^\]]*)\]',result.stdout)
                 for a in match.split(',') if a.strip()})
reports = re.findall(r"'([^']+)' (?:depends on axioms|does not depend on any axioms)",result.stdout)
expected = len(re.findall(r'^#print axioms ',code,re.M))
passed = result.returncode==0 and set(axioms)<={'propext','Quot.sound','Classical.choice'} and len(reports)==expected
row = dict(module=name,status='PASS' if passed else 'FAIL',exit_code=result.returncode,
    source_sha256=before,object_sha256=sha(obj) if result.returncode==0 and obj.exists() else None,
    log=str(log),log_sha256=sha(log),axioms=axioms,axiom_reports=reports,
    started_at_utc=started,finished_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
    command=command,lean_binary_sha256=sha(lean),mathlib_commit=commit,
    base_theorem_source_sha256=base['source_sha256'],base_theorem_object_sha256=base['object_sha256'])
(OUT/(name+' verification.json')).write_text(json.dumps(row,indent=2)+'\n')
print(json.dumps({'module':name,'status':row['status'],'axiom_reports':len(reports),'log':str(log)}),flush=True)
print(result.stdout,flush=True)
raise SystemExit(0 if passed else 1)
