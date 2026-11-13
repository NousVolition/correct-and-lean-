import argparse,hashlib,json,os,subprocess,tempfile
from datetime import datetime,timezone
from pathlib import Path
HERE=Path(__file__).resolve().parent
SRC=HERE.parent/'recent-research-publication-20261112/repository/research/chat-research-update-2026-11-12'
CACHE=Path('$USER_HOME/verification');LEAN=Path('/opt/lean-audit/lean-4.34.0-rc2-linux/bin/lean')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def now():return datetime.now(timezone.utc).isoformat()
ap=argparse.ArgumentParser();ap.add_argument('which',choices=['edge','geometry']);a=ap.parse_args()
out=HERE/'private-supplemental'/a.which;out.mkdir(parents=True,exist_ok=False)
if a.which=='edge':
    prior=HERE/'private-vortex/as-vortex-edge-control-lean';record=json.loads((prior/'record.json').read_text());assert record['status']=='PASS'
    expected=sha(prior/'evidence/comparator.log')
    matches=[p/'as-vortex-edge-control-lean' for p in CACHE.glob('edge-control-replay.*') if (p/'as-vortex-edge-control-lean/evidence/comparator.log').is_file() and sha(p/'as-vortex-edge-control-lean/evidence/comparator.log')==expected]
    assert len(matches)==1,matches
    cwd=matches[0];source=SRC/'vortex/as-vortex-edge-control-lean/examples/SpecificProbe.lean'
    role='Published worked-example theorem; supplemental Lean and axiom check; not an added Comparator target'
else:
    record=json.loads((HERE/'private-generic/geometry-real/record.json').read_text());assert record['status']=='PASS'
    cwd=Path(record['final_stage']);source=SRC/'geometry/Closest point ambiguity/diagnostics/DerivativeProbe.lean'
    role='Preserved diagnostic attempt; not an accepted proof target'
dest=Path(tempfile.mkdtemp(prefix='fresh-proof-supplement-'))/(source.stem+'.olean')
env=os.environ.copy();env.update(PATH=f'{CACHE}/bin:{LEAN.parent}:/usr/local/bin:/usr/bin:/bin',LEAN_NUM_THREADS='2')
cmd=[str(CACHE/'bin/lake'),'env',str(LEAN),'--root='+str(source.parent),'-o',str(dest),str(source)]
rec={'role':role,'source':str(source.relative_to(SRC)),'source_sha256':sha(source),'started_at_utc':now(),'command':cmd,'dependency_check_record':str(prior/'record.json') if a.which=='edge' else str(HERE/'private-generic/geometry-real/record.json'),'fresh_dependency_build_reused':True,'comparator_run_for_supplement':False}
with (out/'lean.log').open('w') as f:r=subprocess.run(cmd,cwd=cwd,env=env,stdout=f,stderr=subprocess.STDOUT,timeout=600)
rec.update(status='PASS' if r.returncode==0 else 'FAIL',exit=r.returncode,finished_at_utc=now(),log_sha256=sha(out/'lean.log'),source_unchanged=sha(source)==rec['source_sha256'],object_sha256=sha(dest) if dest.exists() else None)
(out/'record.json').write_text(json.dumps(rec,indent=2)+'\n');print(json.dumps(rec,indent=2))
