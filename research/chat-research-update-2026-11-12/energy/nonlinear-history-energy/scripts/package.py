from pathlib import Path
import json,hashlib,shutil,zipfile,ast
from datetime import datetime,timezone
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'outputs/nonlinear-history-energy';WORK=ROOT/'work/nonlinear-history-energy'
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
sources=json.loads((OUT/'source-check.json').read_text(encoding='utf-8'))
numeric=json.loads((OUT/'nonlinear-storage-check.json').read_text())
for report in [sources,numeric]:
    for path,h in report['input_sha256'].items():assert sha(path)==h
assert sources['sources_unchanged'] and numeric['source_files_and_saved_states_unchanged']
assert numeric['new_solver_steps']==0 and numeric['saved_states']==62
assert numeric['max_decomposition_vs_native_error']<1e-18
assert numeric['max_nonlinear_relaxation_heat_defect']<1e-18
assert numeric['max_virtual_stress_contraction_defect']<1e-16
assert sha(numeric['inherited_evidence']['source'])==numeric['inherited_evidence']['sha256']
(OUT/'scripts').mkdir(exist_ok=True);(OUT/'proof-evidence').mkdir(exist_ok=True)
for p in WORK.glob('*.py'):
    ast.parse(p.read_text(encoding='utf-8'));shutil.copy2(p,OUT/'scripts'/p.name)
shutil.copy2(WORK/'PLAN.md',OUT/'PLAN.md')
assert sha(OUT/'scripts/decompose_storage.py')==numeric['script_sha256']
records=[]
for folder,module,logname,targets in [
    ('hug-lean-proofs','ClayFabric','ProofAudit',['ClayFabric.energy_has_derivative_gradient','ClayFabric.settling_turns_energy_into_heat']),
    ('hug-source-energy-connection','RecordEnergyConnection','SourceConnectionAudit',['HugSourceEnergy.record_energy_balance']),
    ('full-carrying-energy','FullCarrying','FullCarryingAudit',['FullCarrying.complete_existing_transfers']),
    ('s-gradient-energy','GradientStorage','GradientStorageAudit',['GradientStorage.initial_minimum_cannot_pay'])]:
    base=ROOT/'outputs'/folder
    source=base/(module+'.lean');receipt=base/'verification.json'
    # Match the complete package's own hash manifest, then its successful log.
    manifest=json.loads((base/'SHA256SUMS.json').read_text(encoding='utf-8-sig'))
    assert manifest[module+'.lean'].lower()==sha(source)
    assert manifest['verification.json'].lower()==sha(receipt)
    possible=list((base/'logs').rglob(logname+'.log'))
    if not possible:
        # Older package names its audit module differently; choose only an
        # existing log containing every named theorem and no sorryAx.
        possible=[p for p in (base/'logs').rglob('*.log') if all(t in p.read_text(encoding='utf-8-sig') for t in targets)]
    assert possible,(folder,logname)
    log=next(p for p in possible if all(t in p.read_text(encoding='utf-8-sig') for t in targets))
    content=log.read_text(encoding='utf-8-sig');assert 'sorryAx' not in content and 'error:' not in content
    relative=log.relative_to(base)
    logged_hash=manifest.get(str(relative),manifest.get(relative.as_posix()))
    assert logged_hash and logged_hash.lower()==sha(log)
    copied=OUT/'proof-evidence'/folder;copied.mkdir(exist_ok=True)
    for p in [source,log,receipt]:shutil.copy2(p,copied/p.name)
    records.append(dict(package=folder,module=module,targets=targets,source_sha256=sha(source),receipt_sha256=sha(receipt),audit_sha256=sha(log),
        status='Inherited successful proof evidence, hashes checked; not recompiled in this task'))
result=dict(checked_utc=datetime.now(timezone.utc).isoformat(),source_check='COMPLETE within declared readable-source scope',numerical_checks='PASS',
    requested_nonlinear_storage='NOT IDENTIFIED from checked original notes. Known later nonlinear stored-energy terms are already included and their releases go through existing heat/stress transfers.',
    new_solver_steps=0,new_Lean_compilations=0,new_theorems=0,saved_states=62,proof_evidence=records,
    original_equations_notes_and_saved_states_unchanged=True,
    missing_specification='An independently defined full-state/history energy functional whose derivative cancels the activation remainder along the unchanged evolution, including event balance and without double-counting material/heat energy.',
    limitations=['No universal no-go theorem for nonlinear/nonlocal/history-dependent functionals',
        'Archived readable source text only, not skipped board objects/images or live updates',
        'Floating-point saved-state checks do not prove a continuum trajectory',
        'Original A/S branch and later nonlinear material implementation retain distinct provenance'])
(OUT/'verification.json').write_text(json.dumps(result,indent=2)+'\n')
hashes={str(p.relative_to(OUT)):sha(p) for p in sorted(OUT.rglob('*')) if p.is_file() and p.name!='SHA256SUMS.json'}
(OUT/'SHA256SUMS.json').write_text(json.dumps(hashes,indent=2)+'\n')
archive=ROOT/'outputs/nonlinear-history-energy.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
    for p in sorted(OUT.rglob('*')):
        if p.is_file():z.write(p,'nonlinear-history-energy/'+str(p.relative_to(OUT)))
with zipfile.ZipFile(archive) as z:assert z.testzip() is None
print(json.dumps(result,indent=2))
