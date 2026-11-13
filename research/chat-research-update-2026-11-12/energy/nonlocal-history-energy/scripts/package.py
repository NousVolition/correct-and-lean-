from pathlib import Path
import json,hashlib,shutil,zipfile,ast
from datetime import datetime,timezone
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'outputs/nonlocal-history-energy';WORK=ROOT/'work/nonlocal-history-energy'
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
source=json.loads((OUT/'source-check.json').read_text(encoding='utf-8'))
numerics=json.loads((OUT/'nonlocal-check.json').read_text())
pair=json.loads((OUT/'pair-potential-check.json').read_text())
for r in [source,numerics]:
    for p,h in r['input_sha256'].items():assert sha(p)==h
assert pair['status']=='PASS' and pair['source_unchanged'] and sha(pair['source'])==pair['source_sha256']
assert source['sources_unchanged'] and numerics['sources_and_states_unchanged'] and numerics['new_solver_steps']==0
assert numerics['saved_states']==62 and numerics['maxima']['explicit_pairgrid_max']==0
assert numerics['maxima']['residual_mean_minus_AS']<1e-12
assert numerics['maxima']['residual_after_minus_its_mean_max']<1e-12
(OUT/'scripts').mkdir(exist_ok=True)
for p in WORK.glob('*.py'):
    ast.parse(p.read_text(encoding='utf-8'));shutil.copy2(p,OUT/'scripts'/p.name)
shutil.copy2(WORK/'PLAN.md',OUT/'PLAN.md')
assert sha(OUT/'scripts/check_nonlocal.py')==numerics['script_sha256']
assert sha(OUT/'scripts/check_pair_potential.py')==pair['script_sha256']
oldpath=ROOT/'outputs/nonlinear-history-energy/nonlinear-storage-check.json'
old=json.loads(oldpath.read_text());energies=old['decomposed_energies']
precise=[energies['neo_hookean']['change'],energies['exponential_directional']['change'],
    energies['fabric_microstrain']['change']+energies['fabric_quartic_wells']['change'],energies['total_stored']['change']]
supplied=[1.092613e-6,7.824692e-7,4.320524e-8,1.918287e-6]
assert all(float(format(x,'.6e'))==v for x,v in zip(precise,supplied))
comparison=dict(source='User-pasted independent report in this chat; independent script and intermediate values not supplied',
    claimed_frames=[0,400,599,600],labels=['Base strain','Memory-weighted strain','Fabric total (microstrain plus quartic wells)','Total'],
    user_displayed_changes=supplied,previous_62_frame_check_changes=precise,all_match_at_displayed_precision=True,
    preserved_limits=['Four frames, not 62','Independent report did not check relaxation-to-heat accounting','Independent report did not inspect the original notes'],
    interpretation='Endpoint arithmetic corroboration only; the pasted fabric category groups two terms, not the quartic term alone.',
    comparison_evidence_sha256=sha(oldpath))
(OUT/'independent-comparison.json').write_text(json.dumps(comparison,indent=2)+'\n')
result=dict(checked_utc=datetime.now(timezone.utc).isoformat(),source_check='COMPLETE within declared readable-source scope',numerical_checks='PASS',
    requested_nonlocal_energy='NOT IDENTIFIED from checked original notes. Specified nonlocal redistribution/adjoint transfers preserve the global account; no separate stored-energy functional paying the activation remainder was supplied.',
    new_solver_steps=0,new_Lean_compilations=0,new_theorems=0,saved_states=62,
    original_equations_notes_and_saved_states_unchanged=True,
    global_flux_result='The diagnostic correction changes spatial variation only; its mean residual is unchanged and equals A/S power after breathing power is subtracted.',
    pair_potential_result='A log-cosh context potential is derivable for the older fixed-geometry pair law; it is absent in the saved run and is not a demonstrated physical energy closure.',
    independent_report_agreement='User-pasted four-frame endpoint changes match the prior 62-frame check at displayed precision; heat and source review remain separately attributed.',
    limitations=['No universal impossibility claim for nonlocal/history-dependent stored energy',
        'Periodic/closed boundary assumptions are essential for the no-net-flux statement',
        'Archived readable sources only; skipped images/foreign objects and live changes untested',
        'Finite numerical algebra and saved-state checks, not a formally verified continuum trajectory'])
(OUT/'verification.json').write_text(json.dumps(result,indent=2)+'\n')
hashes={str(p.relative_to(OUT)):sha(p) for p in sorted(OUT.rglob('*')) if p.is_file() and p.name!='SHA256SUMS.json'}
(OUT/'SHA256SUMS.json').write_text(json.dumps(hashes,indent=2)+'\n')
archive=ROOT/'outputs/nonlocal-history-energy.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
    for p in sorted(OUT.rglob('*')):
        if p.is_file():z.write(p,'nonlocal-history-energy/'+str(p.relative_to(OUT)))
with zipfile.ZipFile(archive) as z:assert z.testzip() is None
print(json.dumps(result,indent=2))
