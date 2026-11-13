from pathlib import Path
import json,re,shutil,hashlib,sys,zipfile,ast
from datetime import datetime,timezone
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'outputs/full-carrying-energy';WORK=ROOT/'work/full-carrying'
PRIOR=ROOT/'outputs/gravity-storage-derivation';BUILD=ROOT/'work/unforced-energy/build'
old=['FullModel','OriginalAS','OriginalASEnergy','OriginalASBalance','OriginalASIntegrated','EnergyAccounting','StorageRequirements']
new=['FullCarrying','FullCarryingAudit'];sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
names=['FullCarrying.'+n for n in re.findall(r'^theorem\s+(\w+)',(OUT/'FullCarrying.lean').read_text(encoding='utf-8'),re.M)]
if sys.argv[1]=='prepare':
    for name in old:shutil.copy2(PRIOR/(name+'.lean'),OUT/(name+'.lean'))
    for name in ['lean-toolchain','lake-manifest.json']:shutil.copy2(PRIOR/name,OUT/name)
    cfg='name = "FullCarryingEnergy"\nversion = "0.1.0"\ndefaultTargets = ["FullCarryingAudit"]\n\n[[require]]\nname = "mathlib"\nscope = "leanprover-community"\ngit = "https://github.com/leanprover-community/mathlib4.git"\nrev = "85e3a25e006c35636f0e53b0e9296caca2685bc0"\n'
    for m in old+new:cfg+='\n[[lean_lib]]\nname = "'+m+'"\n'
    (OUT/'lakefile.toml').write_text(cfg)
    manifest=json.loads((OUT/'lake-manifest.json').read_text(encoding='utf-8-sig'));manifest['name']='FullCarryingEnergy'
    (OUT/'lake-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    script=(OUT/'build-native.ps1').read_text(encoding='utf-8-sig')
    script=re.sub(r'\[string\[\]\]\$Modules = @\(.*?\)',"[string[]]$Modules = @("+','.join("'"+m+"'" for m in old+new)+")",script,count=1,flags=re.S)
    (OUT/'build-native.ps1').write_text(script,encoding='utf-8')
    (OUT/'scripts').mkdir(exist_ok=True)
    for name in ['diagnose_stages.py','follow_activation.py','check_pair25.py','verify_storage_rate.py','package.py']:
        shutil.copy2(WORK/name,OUT/'scripts'/name)
    shutil.copy2(WORK/'PLAN.md',OUT/'PLAN.md')
    print('Prepared sources, reproducibility metadata and diagnostic scripts.')
elif sys.argv[1]=='finalize':
    (OUT/'compiled').mkdir(exist_ok=True);(OUT/'logs/inherited').mkdir(parents=True,exist_ok=True)
    receipts=[];inherited=json.loads((PRIOR/'logs/build-results.json').read_text(encoding='utf-8-sig'))
    for m in old:
        r=next(r for r in inherited if r['module']==m)
        assert r['exit_code']==0 and r['source_sha256'].lower()==sha(OUT/(m+'.lean'))==sha(PRIOR/(m+'.lean'))
        assert sha(BUILD/(m+'.olean'))==sha(PRIOR/'compiled'/(m+'.olean'))
        shutil.copy2(BUILD/(m+'.olean'),OUT/'compiled'/(m+'.olean'))
        r['origin']='Inherited successful check; unchanged source/object hashes checked in this task';receipts.append(r)
    shutil.copy2(PRIOR/'verification.json',OUT/'logs/inherited/verification.json')
    for m,folder in [('FullCarrying','logs-proof-2'),('FullCarryingAudit','logs-audit')]:
        r=json.loads((WORK/folder/'build-results.json').read_text(encoding='utf-8-sig'))
        if isinstance(r,list):r=next(r for r in r if r['module']==m)
        log=WORK/folder/(m+'.log')
        assert r['exit_code']==0 and r['source_unchanged'] and r['source_sha256'].lower()==sha(OUT/(m+'.lean'))
        assert r['log_sha256'].lower()==sha(log)
        assert not re.search(r'\berror:|\bwarning:',log.read_text(encoding='utf-8-sig'))
        shutil.copy2(log,OUT/'logs'/log.name);shutil.copy2(BUILD/(m+'.olean'),OUT/'compiled'/(m+'.olean'))
        r['origin']='Fresh Lean check in this task';receipts.append(r)
    audit=(OUT/'logs/FullCarryingAudit.log').read_text(encoding='utf-8-sig')
    found=re.findall(r"'([^']+)' depends on axioms: \[([^\]]*)\]",audit,re.S)
    assert {n for n,_ in found}==set(names)
    axioms=sorted({a.strip() for _,xs in found for a in xs.split(',') if a.strip()})
    assert set(axioms)<={'propext','Quot.sound','Classical.choice'}
    for m in old+['FullCarrying']:assert not re.search(r'\b(sorry|admit|axiom)\b',(OUT/(m+'.lean')).read_text(encoding='utf-8'))
    for p in (OUT/'scripts').glob('*.py'):ast.parse(p.read_text(encoding='utf-8'))
    stage=json.loads((OUT/'stage-verification.json').read_text());pair=json.loads((OUT/'pair25-saved-check.json').read_text())
    activation=json.loads((OUT/'activation-results.json').read_text())
    storage=json.loads((OUT/'storage-rate-check.json').read_text())
    assert storage['status']=='PASS' and storage['state_unchanged']
    assert sha(OUT/'scripts/verify_storage_rate.py')==storage['script_sha256']
    assert stage['sources_and_saved_data_unchanged'] and pair['read_inputs_unchanged']
    assert stage['stage_count']==1200 and stage['checkpoint_count']==61 and stage['max_native_energy_rate_defect']<1e-12
    assert pair['status']=='PASS' and pair['new_solver_steps']==0
    for key in ['stage-verification.json','pair25-saved-check.json']:
        data=json.loads((OUT/key).read_text())
        for p,h in data['input_sha256'].items():assert sha(Path(p))==h
    assert sha(OUT/'scripts/diagnose_stages.py')==stage['script_sha256']
    assert sha(OUT/'scripts/follow_activation.py')==activation['script_sha256']
    notes=ROOT/'outputs/hug-source-energy-connection/sources'
    source_files=[notes/name for name in ['STRUCTURAL_MEMORY.md','COUPLED_FIELD.md','HOLDING_AND_ENERGY.md']]
    source_files.extend([PRIOR/'source-check.json',ROOT/'outputs/unwrapped-carrying-history/path-results-12-16.json'])
    source_files.extend([WORK/'activation-stage-parts.npz',ROOT/'work/unwrapped-history/force-history.npz'])
    source_hashes={str(p):sha(p) for p in source_files}
    base=json.loads((PRIOR/'verification.json').read_text())
    result=dict(checked_utc=datetime.now(timezone.utc).isoformat(),lean='PASS',new_theorem_count=len(names),theorems=names,axioms=axioms,sorryAx=False,
        requested_physical_storage='NOT IDENTIFIED. Full carrying activation relation derived; demand decomposed; existing material/heat transfers verified and already accounted.',
        original_equations_and_read_sources_unchanged=True,original_run_replayed_steps=600,pair25_new_solver_steps=0,
        pair25_membership_bits_recomputed=sum(r['membership_bits_recomputed'] for r in pair['runs']),
        native_rate_balance_max_error=stage['max_native_energy_rate_defect'],source_sha256=source_hashes,
        limitations=['Conditional finite-dimensional Lean identities, not a full PDE evolution or commutator proof',
          'No independently identified gravitational store or general total-energy conservation theorem',
          'Numerical activation split is resolution-dependent and includes a retained transport/discretization term',
          'Pair 25 and threshold-1 are different saved experiments',
          'No independent external kernel run; dependency cache pin inherited'],
        lean_version=base['lean_version'],dependency=base['dependency'])
    (OUT/'verification.json').write_text(json.dumps(result,indent=2)+'\n')
    (OUT/'logs/build-results.json').write_text(json.dumps(receipts,indent=2)+'\n')
    hashes={str(p.relative_to(OUT)):sha(p) for p in sorted(OUT.rglob('*')) if p.is_file() and p.name!='SHA256SUMS.json'}
    (OUT/'SHA256SUMS.json').write_text(json.dumps(hashes,indent=2)+'\n')
    archive=ROOT/'outputs/full-carrying-energy.zip'
    with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
        for p in sorted(OUT.rglob('*')):
            if p.is_file():z.write(p,'full-carrying-energy/'+str(p.relative_to(OUT)))
    with zipfile.ZipFile(archive) as z:assert z.testzip() is None
    print(json.dumps(result,indent=2))
