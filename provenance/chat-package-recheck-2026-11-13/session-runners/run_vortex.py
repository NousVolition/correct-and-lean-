"""Replays the five original frozen checks in new, isolated source copies."""
import concurrent.futures, hashlib, json, os, shutil, subprocess, tempfile, time
from pathlib import Path
from datetime import datetime, timezone
HERE=Path(__file__).resolve().parent
SOURCE=HERE.parent/'recent-research-publication-20261112/repository/research/chat-research-update-2026-11-12'
OUT=HERE/'private-vortex'; OUT.mkdir(exist_ok=True)
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def now(): return datetime.now(timezone.utc).isoformat()
jobs=['as-signed-vortex-lean','as-vortex-hline-lean','as-vortex-rescaling-lean','as-vortex-edge-control-lean','as-vortex-edge-control-lean/time-check']
assert os.getuid()!=0
def job(name):
    slug=name.replace('/','--')
    record={'package':'vortex/'+name,'started_at_utc':now(),'reference_kind':'original frozen challenge','status':'RUNNING'}
    dest=OUT/slug;dest.mkdir(exist_ok=False)
    stage=Path(tempfile.mkdtemp(prefix='fresh-added-vortex-20261113-'))
    source=stage/'sources'
    for item in jobs:
        old=SOURCE/'vortex'/item; new=source/item;new.mkdir(parents=True,exist_ok=True)
        for p in old.iterdir():
            if p.is_file() and (p.suffix=='.lean' or p.name in ['lakefile.toml','lake-manifest.json','lean-toolchain','comparator.json','reference-freeze.json','run-check.sh']): shutil.copyfile(p,new/p.name)
    pkg=source/name
    original=json.loads((pkg/'reference-freeze.json').read_text())
    assert all(sha(pkg/f)==h for f,h in original['files'].items())
    record['source_hashes']={str(p.relative_to(source)):sha(p) for p in source.rglob('*') if p.is_file()}
    record['targets']=json.loads((pkg/'comparator.json').read_text())['theorem_names']
    record['isolated_source']=str(pkg)
    (dest/'record.json').write_text(json.dumps(record,indent=2)+'\n')
    print(json.dumps({'start':name,'time':now()}),flush=True)
    with (dest/'runner.log').open('w') as log:
        proc=subprocess.run(['bash',str(pkg/'run-check.sh'),'verify'],stdout=log,stderr=subprocess.STDOUT,timeout=10800)
    record['runner_exit']=proc.returncode
    if (pkg/'evidence').exists(): shutil.copytree(pkg/'evidence',dest/'evidence')
    record['sources_unchanged']=all(sha(source/f)==h for f,h in record['source_hashes'].items())
    record['finished_at_utc']=now()
    record['status']='PASS' if proc.returncode==0 and record['sources_unchanged'] else 'FAIL'
    (dest/'record.json').write_text(json.dumps(record,indent=2)+'\n')
    print(json.dumps({'finish':name,'status':record['status'],'time':now()}),flush=True)
    return record
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
    futures={pool.submit(job,n):n for n in jobs}
    results=[]
    for f in concurrent.futures.as_completed(futures):
        try: results.append(f.result())
        except Exception as e:
            results.append({'package':futures[f],'status':'HARNESS_ERROR','error':repr(e),'time':now()})
            print(json.dumps(results[-1]),flush=True)
(OUT/'summary.json').write_text(json.dumps(results,indent=2)+'\n')
