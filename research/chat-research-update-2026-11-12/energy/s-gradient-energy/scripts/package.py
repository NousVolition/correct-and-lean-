from pathlib import Path
import json,re,shutil,hashlib,sys,zipfile,ast
from datetime import datetime,timezone
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'outputs/s-gradient-energy';WORK=ROOT/'work/s-gradient-energy'
PRIOR=ROOT/'outputs/full-carrying-energy';BUILD=ROOT/'work/unforced-energy/build'
old=['FullModel','OriginalAS','OriginalASEnergy','OriginalASBalance','OriginalASIntegrated','EnergyAccounting','StorageRequirements','FullCarrying']
new=['GradientStorage','GradientStorageAudit'];sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
names=['GradientStorage.'+n for n in re.findall(r'^theorem\s+(\w+)',(OUT/'GradientStorage.lean').read_text(encoding='utf-8'),re.M)]
if sys.argv[1]=='prepare':
    for name in old:shutil.copy2(PRIOR/(name+'.lean'),OUT/(name+'.lean'))
    for name in ['lean-toolchain','lake-manifest.json']:shutil.copy2(PRIOR/name,OUT/name)
    cfg='name = "SGradientEnergy"\nversion = "0.1.0"\ndefaultTargets = ["GradientStorageAudit"]\n\n[[require]]\nname = "mathlib"\nscope = "leanprover-community"\ngit = "https://github.com/leanprover-community/mathlib4.git"\nrev = "85e3a25e006c35636f0e53b0e9296caca2685bc0"\n'
    for m in old+new:cfg+='\n[[lean_lib]]\nname = "'+m+'"\n'
    (OUT/'lakefile.toml').write_text(cfg)
    manifest=json.loads((OUT/'lake-manifest.json').read_text(encoding='utf-8-sig'));manifest['name']='SGradientEnergy'
    (OUT/'lake-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    script=(OUT/'build-native.ps1').read_text(encoding='utf-8-sig')
    script=re.sub(r'\[string\[\]\]\$Modules = @\(.*?\)',"[string[]]$Modules = @("+','.join("'"+m+"'" for m in old+new)+")",script,count=1,flags=re.S)
    (OUT/'build-native.ps1').write_text(script,encoding='utf-8')
    (OUT/'scripts').mkdir(exist_ok=True)
    for p in WORK.glob('*.py'):shutil.copy2(p,OUT/'scripts'/p.name)
    print('Prepared proof dependencies and reproduction scripts.')
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
    for m,folder in [('GradientStorage','logs-proof-2'),('GradientStorageAudit','logs-audit')]:
        r=json.loads((WORK/folder/'build-results.json').read_text(encoding='utf-8-sig'))
        if isinstance(r,list):r=next(r for r in r if r['module']==m)
        log=WORK/folder/(m+'.log')
        assert r['exit_code']==0 and r['source_unchanged'] and r['source_sha256'].lower()==sha(OUT/(m+'.lean'))
        assert r['log_sha256'].lower()==sha(log)
        assert not re.search(r'\berror:|\bwarning:',log.read_text(encoding='utf-8-sig'))
        shutil.copy2(log,OUT/'logs'/log.name);shutil.copy2(BUILD/(m+'.olean'),OUT/'compiled'/(m+'.olean'))
        r['origin']='Fresh Lean check in this task';receipts.append(r)
    audit=(OUT/'logs/GradientStorageAudit.log').read_text(encoding='utf-8-sig')
    found=re.findall(r"'([^']+)' depends on axioms: \[([^\]]*)\]",audit,re.S)
    assert {n for n,_ in found}==set(names)
    axioms=sorted({a.strip() for _,xs in found for a in xs.split(',') if a.strip()})
    assert set(axioms)<={'propext','Quot.sound','Classical.choice'}
    for m in old+['GradientStorage']:assert not re.search(r'\b(sorry|admit|axiom)\b',(OUT/(m+'.lean')).read_text(encoding='utf-8'))
    for p in (OUT/'scripts').glob('*.py'):ast.parse(p.read_text(encoding='utf-8'))
    scan=json.loads((OUT/'source-scan.json').read_text(encoding='utf-8'));saved=json.loads((OUT/'saved-norm-check.json').read_text())
    assert scan['sources_unchanged'] and saved['sources_and_states_unchanged']
    assert saved['saved_states_checked']==62 and saved['solver_steps']==0
    for data in [scan,saved]:
        for p,h in data['input_sha256'].items():assert sha(Path(p))==h
    assert sha(OUT/'scripts/check_saved_norms.py')==saved['script_sha256']
    assert all(d['embedded_math_objects']==0 and d['embedded_media_files']==[] for d in scan['documents'])
    base=json.loads((PRIOR/'verification.json').read_text())
    result=dict(checked_utc=datetime.now(timezone.utc).isoformat(),lean='PASS',new_theorem_count=len(names),theorems=names,axioms=axioms,sorryAx=False,
        source_energy_law='NOT IDENTIFIED in checked readable original material. Transport/source and norm budgets found; no independently specified store paying the activation demand.',
        positive_quadratic_candidate_result='Fails the required net-release sign from the saved zero initial scalar/gradient/A state; any-sign single-constant endpoint fits also fail earlier saved times.',
        original_equations_and_read_sources_unchanged=True,new_solver_steps=0,saved_states_read=62,
        document_count=len(scan['documents']),board_export_count=len(scan['board_read_scope']),unique_readable_board_items=scan['unique_readable_board_items'],
        limitations=['Initial-minimum and quadratic candidate classes only; no universal no-go for larger histories or nonlinear energies',
          'Gradient PDE commutator and spatial integration assumptions are explained analytically, not newly formalized',
          'Numerical observations are saved floating-point states, not a verified continuum trajectory',
          'Archived board readable text only; skipped foreign/image content and live updates untested',
          'No external kernel run; pinned dependency cache evidence inherited'],
        lean_version=base['lean_version'],dependency=base['dependency'])
    (OUT/'verification.json').write_text(json.dumps(result,indent=2)+'\n')
    (OUT/'logs/build-results.json').write_text(json.dumps(receipts,indent=2)+'\n')
    hashes={str(p.relative_to(OUT)):sha(p) for p in sorted(OUT.rglob('*')) if p.is_file() and p.name!='SHA256SUMS.json'}
    (OUT/'SHA256SUMS.json').write_text(json.dumps(hashes,indent=2)+'\n')
    archive=ROOT/'outputs/s-gradient-energy.zip'
    with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
        for p in sorted(OUT.rglob('*')):
            if p.is_file():z.write(p,'s-gradient-energy/'+str(p.relative_to(OUT)))
    with zipfile.ZipFile(archive) as z:assert z.testzip() is None
    print(json.dumps(result,indent=2))
