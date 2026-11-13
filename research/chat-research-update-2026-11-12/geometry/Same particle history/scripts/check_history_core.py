"""Check only the explicitly scoped algebra / observation core."""
from pathlib import Path
import datetime,hashlib,json,os,re,shutil,subprocess
ROOT=Path('$USER_HOME/Documents/Codex/2026-11-10/lo')
OUT=ROOT/'outputs/Same particle history'
SOURCE=OUT/'lean'
LOGS=OUT/'logs'
LOGS.mkdir(exist_ok=True)
OLD=ROOT/'outputs/Closest point ambiguity'
previous=json.loads((OLD/'PeriodicNavierStokes verification.json').read_text())
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
for suffix,key in [('.lean','base_theorem_source_sha256'),('.olean','base_theorem_object_sha256')]:
    p=OLD/'lean'/('SIMSLatentReadout'+suffix)
    assert sha(p)==previous[key]
    shutil.copy2(p,SOURCE/p.name)
project=Path('$USER_HOME/verification/project')
lean=Path('/opt/lean-audit/lean-4.34.0-rc2-linux/bin/lean')
lake=Path('$USER_HOME/verification/bin/lake')
assert sha(lean)==previous['lean_binary_sha256']
mathlib=project/'.lake/packages/mathlib'
commit=subprocess.check_output(['git','-C',str(mathlib),'rev-parse','HEAD'],text=True).strip()
assert commit==previous['mathlib_commit']
assert not subprocess.check_output(['git','-C',str(mathlib),'status','--porcelain=v1','--untracked-files=no'],text=True).strip()
env=dict(os.environ)
env['PATH']=str(lean.parent)+':'+str(lake.parent)+':'+env.get('PATH','')
env['LEAN_PATH']=str(SOURCE)
env['LEAN_NUM_THREADS']='1'
p=SOURCE/'HistoryMatchCore.lean'
code=p.read_text()
assert not re.search(r'\b(sorry|admit|axiom|native_decide|implemented_by)\b',code)
before=sha(p)
obj=SOURCE/'HistoryMatchCore.olean'
command=[str(lake),'env',str(lean),'--root='+str(SOURCE),'-o',str(obj),str(p)]
stamp=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S')
run=subprocess.run(command,cwd=project,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=180)
log=LOGS/('HistoryMatchCore-'+stamp+'.log')
log.write_text(run.stdout)
assert sha(p)==before
axioms=sorted({a.strip() for m in re.findall(r'depends on axioms: \[([^\]]*)\]',run.stdout) for a in m.split(',') if a.strip()})
reports=re.findall(r"'([^']+)' (?:depends on axioms|does not depend on any axioms)",run.stdout)
passed=run.returncode==0 and set(axioms)<={'propext','Classical.choice','Quot.sound'} and len(reports)==len(re.findall(r'^#print axioms ',code,re.M))
row=dict(status='PASS' if passed else 'FAIL',scope='Conditional algebra, geometry and observation core only; no formal PDE witness or parameter existence construction.',
    source_sha256=before,object_sha256=sha(obj) if run.returncode==0 else None,
    exit_code=run.returncode,log=str(log),log_sha256=sha(log),axioms=axioms,
    axiom_reports=reports,command=command,lean_binary_sha256=sha(lean),mathlib_commit=commit,
    base_theorem_source_sha256=previous['base_theorem_source_sha256'],
    base_theorem_object_sha256=previous['base_theorem_object_sha256'],
    checked_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat())
(OUT/'Formal core verification.json').write_text(json.dumps(row,indent=2)+'\n')
print(json.dumps({'status':row['status'],'reports':len(reports),'scope':row['scope']}),flush=True)
print(run.stdout,flush=True)
raise SystemExit(0 if passed else 1)
