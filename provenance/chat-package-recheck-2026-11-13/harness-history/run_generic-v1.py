"""Fresh compilation and frozen-publication rechecks; never rewrites a proof source.

New Comparator references import the frozen published modules themselves. These
are kernel/axiom/nanoda rechecks, not independent specifications of the models.
"""
import hashlib,json,os,re,shutil,subprocess,tempfile,time
from pathlib import Path
from datetime import datetime,timezone
HERE=Path(__file__).resolve().parent
SOURCE=HERE.parent/'recent-research-publication-20261112/repository/research/chat-research-update-2026-11-12'
OUT=HERE/'private-generic'; OUT.mkdir(exist_ok=True)
CACHE=Path('$USER_HOME/verification'); UP=CACHE/'project'
LEAN=Path('/opt/lean-audit/lean-4.34.0-rc2-linux/bin/lean')
LAKE=CACHE/'bin/lake'
ENV=os.environ.copy();ENV.update(PATH=f'{CACHE}/bin:{LEAN.parent}:/usr/local/bin:/usr/bin:/bin',XDG_RUNTIME_DIR=f'/run/user/{os.getuid()}',DBUS_SESSION_BUS_ADDRESS=f'unix:path=/run/user/{os.getuid()}/bus',LEAN_NUM_THREADS='4')
assert os.getuid()!=0
def now():return datetime.now(timezone.utc).isoformat()
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def command(args,cwd,log,timeout=10800):
    start=now()
    with log.open('w') as f:
        result=subprocess.run([str(a) for a in args],cwd=cwd,env=ENV,stdout=f,stderr=subprocess.STDOUT,timeout=timeout)
    return {'command':[str(a) for a in args],'started_at_utc':start,'finished_at_utc':now(),'exit':result.returncode,'log_sha256':sha(log)}
groups={}
for category in ['energy','geometry']:
    for p in sorted((SOURCE/category).iterdir()):
        if not p.is_dir():continue
        root=p/'lean' if category=='geometry' else p
        files=list(root.glob('*.lean'))
        if files:groups[str(p.relative_to(SOURCE))]=files
rat=SOURCE/'geometry/SIMS rational readout check/corrected/SIMSLatentReadout.lean'
groups['geometry/SIMS rational readout check/corrected']=[rat]
batches={
 'energy-as':{g:f for g,f in groups.items() if g.startswith('energy/') and g!='energy/hug-lean-proofs'},
 'energy-hug':{'energy/hug-lean-proofs':groups['energy/hug-lean-proofs']},
 'geometry-real':{g:f for g,f in groups.items() if g.startswith('geometry/') and not g.endswith('/corrected')},
 'geometry-rational':{'geometry/SIMS rational readout check/corrected':[rat]},
}
manifest=json.loads((SOURCE/'publication-manifest.json').read_text())
lean_inputs={x['path'].split('chat-research-update-2026-11-12/',1)[1]:x['published_sha256'] for x in manifest['files'] if x['path'].endswith('.lean')}
assert len(lean_inputs)==161
assert all(sha(SOURCE/p)==h for p,h in lean_inputs.items())
write(OUT/'all-published-lean-inputs.json',{'publication_commit':'2fb9e611e2f56a15db22f88e6e41ca5e0054fda6','verified_at_utc':now(),'files':lean_inputs,'equations_and_proof_sources_unchanged':True})
def setup(name,selected):
    stage=Path(tempfile.mkdtemp(prefix='fresh-added-'+name+'-20261113-'))
    pkg=stage/'package';pkg.mkdir()
    origins={};hashes={}
    for group,files in selected.items():
        for p in files:
            h=sha(p);assert p.name not in hashes or hashes[p.name]==h,p.name
            shutil.copyfile(p,pkg/p.name);hashes[p.name]=h
            origins.setdefault(p.name,[]).append(str(p.relative_to(SOURCE)))
    modules=sorted(p[:-5] for p in hashes)
    lake='name = "FreshPublishedAudit"\nversion = "0.1.0"\ndefaultTargets = ["PublishedReference", "PublishedSolution"]\n\n[[require]]\nname = "mathlib"\ngit = "https://github.com/leanprover-community/mathlib4.git"\nrev = "85e3a25e006c35636f0e53b0e9296caca2685bc0"\n'
    for m in modules+['PublishedReference','PublishedSolution']:
        lake+=f'\n[[lean_lib]]\nname = "{m}"\n'
    (pkg/'lakefile.toml').write_text(lake)
    frozen_manifest=json.loads((SOURCE/'energy/hug-lean-proofs/lake-manifest.json').read_text())
    frozen_manifest['name']='FreshPublishedAudit';write(pkg/'lake-manifest.json',frozen_manifest)
    (pkg/'lean-toolchain').write_text('leanprover/lean4:v4.34.0-rc2\n')
    imports=''.join('import '+m+'\n' for m in modules)
    (pkg/'PublishedReference.lean').write_text(imports)
    (pkg/'PublishedSolution.lean').write_text(imports)
    (pkg/'.lake/packages').mkdir(parents=True)
    for p in (UP/'.lake/packages').iterdir(): (pkg/'.lake/packages'/p.name).symlink_to(p,target_is_directory=True)
    return pkg,origins,hashes,modules
def run_batch(name,selected):
    dest=OUT/name;dest.mkdir(exist_ok=False)
    pkg,origins,hashes,modules=setup(name,selected)
    record={'batch':name,'groups':list(selected),'origins':origins,'source_hashes':hashes,'status':'RUNNING','started_at_utc':now(),'reference_kind':'published-source self-replay; no independent specification','stage':str(pkg)}
    write(dest/'record.json',record)
    print(json.dumps({'start':name,'time':now()}),flush=True)
    record['discovery_build']=command([LAKE,'build','PublishedSolution'],pkg,dest/'discovery-build.log')
    if record['discovery_build']['exit']:
        record.update(status='FAIL',finished_at_utc=now());write(dest/'record.json',record);return record
    enum='import Lean\n'+''.join('import '+m+'\n' for m in modules)+'\nopen Lean Elab Command\nrun_cmd do\n  let env ← getEnv\n  let modules : Array Name := #['+', '.join('`'+m for m in modules)+']\n  for (name, info) in env.constants.toList do\n    if let .thmInfo _ := info then\n      if let some idx := env.getModuleIdxFor? name then\n        if modules.contains env.header.moduleNames[idx]! && !name.toString.startsWith "_" then\n          logInfo m!"FRESH_THEOREM {name}"\n'
    (pkg/'Enumerate.lean').write_text(enum)
    record['enumeration']=command([LAKE,'env',LEAN,'Enumerate.lean'],pkg,dest/'enumeration.log')
    assert record['enumeration']['exit']==0,'enumeration harness failed; inspect log'
    targets=sorted(set(re.findall(r'FRESH_THEOREM (\S+)',(dest/'enumeration.log').read_text())))
    assert targets
    record['targets']=targets
    cfg={'challenge_module':'PublishedReference','solution_module':'PublishedSolution','enable_nanoda':True,'permitted_axioms':['propext','Quot.sound','Classical.choice'],'theorem_names':targets}
    write(pkg/'comparator.json',cfg)
    audit=''.join('import '+m+'\n' for m in modules)+'\n'+''.join('#print axioms '+n+'\n' for n in targets)
    (pkg/'FreshAxioms.lean').write_text(audit)
    frozen={p.name:sha(p) for p in pkg.iterdir() if p.is_file() and p.name!='Enumerate.lean'}
    freeze={'created_at_utc':now(),'reference_kind':record['reference_kind'],'files':frozen,'targets':targets,'origins':origins}
    write(dest/'reference-freeze.json',freeze)
    # A second, empty project cache for the actual frozen replay. Discovery
    # output is retained but never supplied as a local compiled dependency.
    final=Path(tempfile.mkdtemp(prefix='fresh-added-'+name+'-final-20261113-'))
    for p in pkg.iterdir():
        if p.is_file() and p.name!='Enumerate.lean':shutil.copyfile(p,final/p.name)
    (final/'.lake/packages').mkdir(parents=True)
    for p in (UP/'.lake/packages').iterdir():(final/'.lake/packages'/p.name).symlink_to(p,target_is_directory=True)
    assert not (final/'.lake/build').exists()
    record['final_stage']=str(final);record['frozen_before_final_build']=True
    write(dest/'record.json',record)
    systemd=['systemd-run','--user','--wait','--pipe','--collect','--property=RestrictAddressFamilies=~AF_UNIX','-E','PATH='+ENV['PATH'],'-E','COMPARATOR_LANDRUN='+str(CACHE/'bin/landrun'),'-E','COMPARATOR_LEAN4EXPORT='+str(UP/'.lake/packages/lean4export/.lake/build/bin/lean4export'),'-E','COMPARATOR_NANODA='+str(CACHE/'nanoda_lib/target/release/nanoda_bin'),'--working-directory='+str(final),'--',LAKE,'env',UP/'.lake/packages/Comparator/.lake/build/bin/comparator','comparator.json']
    record['comparator']=command(systemd,final,dest/'comparator.log')
    record['axioms']=command([LAKE,'env',LEAN,'FreshAxioms.lean'],final,dest/'axioms.log')
    record['lean_build']=command([LAKE,'build'],final,dest/'lean-build.log')
    record['sources_unchanged']=all(sha(final/n)==h for n,h in frozen.items()) and all(sha(SOURCE/n)==h for n,h in lean_inputs.items())
    record['objects']={str(p.relative_to(final)):sha(p) for p in (final/'.lake/build').rglob('*.olean')}
    record['finished_at_utc']=now()
    record['status']='PASS' if all(record[x]['exit']==0 for x in ['comparator','axioms','lean_build']) and record['sources_unchanged'] else 'FAIL'
    write(dest/'record.json',record)
    for n in ['PublishedReference.lean','PublishedSolution.lean','FreshAxioms.lean','comparator.json','lakefile.toml','lake-manifest.json','lean-toolchain']:
        shutil.copyfile(final/n,dest/n)
    print(json.dumps({'finish':name,'status':record['status'],'targets':len(targets),'time':now()}),flush=True)
    return record
results=[]
for name,selected in batches.items():
    try: results.append(run_batch(name,selected))
    except Exception as e:
        error={'batch':name,'status':'HARNESS_ERROR','error':repr(e),'time':now()};results.append(error);print(json.dumps(error),flush=True)
write(OUT/'summary.json',results)
