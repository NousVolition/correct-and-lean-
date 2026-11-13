"""Compile preserved original drafts separately; never repairs their sources."""
import hashlib,json,os,re,shutil,subprocess,tempfile
from pathlib import Path
from datetime import datetime,timezone
HERE=Path(__file__).resolve().parent
SRC=HERE.parent/'recent-research-publication-20261112/repository/research/chat-research-update-2026-11-12'
OUT=HERE/'private-archived';OUT.mkdir(exist_ok=False)
CACHE=Path('$USER_HOME/verification');LEAN=Path('/opt/lean-audit/lean-4.34.0-rc2-linux/bin/lean')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def now():return datetime.now(timezone.utc).isoformat()
env=os.environ.copy();env['PATH']=str(CACHE/'bin')+':'+str(LEAN.parent)+':/usr/bin:/bin'
libpaths=subprocess.check_output([str(CACHE/'bin/lake'),'env','printenv','LEAN_PATH'],cwd=CACHE/'project',env=env,text=True).strip()
stage=Path(tempfile.mkdtemp(prefix='fresh-archived-drafts-20261113-'))
obj=stage/'objects';obj.mkdir()
env.update(LEAN_PATH=str(obj)+':'+libpaths,LEAN_NUM_THREADS='2')
files=[SRC/'energy/hug-lean-proofs'/n for n in ['HugModel.lean','ActiveHugModel.lean']]
files+=list((SRC/'energy/hug-lean-proofs/originals').glob('*.lean'))
files+=[SRC/'geometry/SIMS rational readout check/SIMSLatentReadout.lean']
results=[]
for p in files:
    rel=str(p.relative_to(SRC));name=p.stem
    dest=stage/(name+'.lean');shutil.copyfile(p,dest)
    rec={'source':rel,'source_sha256':sha(p),'started_at_utc':now(),'role':'dependency' if p.parent.name=='hug-lean-proofs' else 'archived original draft'}
    cmd=[str(LEAN),'--root='+str(stage),'-o',str(obj/(name+'.olean')),str(dest)]
    log=OUT/(name+'.log')
    with log.open('w') as f:r=subprocess.run(cmd,env=env,cwd=stage,stdout=f,stderr=subprocess.STDOUT,timeout=900)
    rec.update(exit=r.returncode,status='PASS' if r.returncode==0 else 'FAIL',finished_at_utc=now(),command=cmd,log_sha256=sha(log),source_unchanged=sha(dest)==sha(p))
    results.append(rec)
    (OUT/'results.json').write_text(json.dumps(results,indent=2)+'\n')
    print(json.dumps({'source':rel,'status':rec['status'],'time':now()}),flush=True)
