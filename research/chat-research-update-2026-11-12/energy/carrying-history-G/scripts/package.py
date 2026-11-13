from pathlib import Path
from datetime import datetime,timezone
import json,hashlib,re,shutil,ast,zipfile
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'outputs/carrying-history-G';WORK=ROOT/'work/carrying-history-G'
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
source=json.loads((OUT/'source-check.json').read_text(encoding='utf-8'))
trace=json.loads((OUT/'trace-check.json').read_text())
for p,h in trace['input_sha256'].items():assert sha(p)==h
assert source['matches_prior_docx_hash'] and trace['original_sources_and_prior_outputs_unchanged']
assert trace['reused_path_times']==601 and trace['reused_pair_samples']==62
assert trace['new_solver_steps']==0 and trace['new_raw_frame_evaluations']==0
assert trace['endpoint_identity_max_defect']<1e-18
logs=WORK/'logs-proof-1';records=json.loads((logs/'build-results.json').read_text(encoding='utf-8-sig'))
assert [r['module'] for r in records]==['HistoryRequirement','HistoryRequirementAudit']
for r in records:
    assert r['exit_code']==0 and r['source_unchanged']
    assert sha(r['source'])==r['source_sha256'].lower()
    assert sha(r['log'])==r['log_sha256'].lower()
audit=(logs/'HistoryRequirementAudit.log').read_text(encoding='utf-8-sig')
compact=re.sub(r'\s+',' ',audit)
names=['accumulated_rate','any_balancing_G_has_required_trace','adding_increasing_potential_increases_debit']
for name in names:
    assert f"'HistoryRequirement.{name}' depends on axioms: [propext, Classical.choice, Quot.sound]" in compact
assert 'sorryAx' not in audit
assert not re.search(r'\b(sorry|admit|axiom)\b',(OUT/'HistoryRequirement.lean').read_text())
for folder in ('scripts','logs'):(OUT/folder).mkdir(exist_ok=True)
for p in WORK.glob('*.py'):
    ast.parse(p.read_text(encoding='utf-8'));shutil.copy2(p,OUT/'scripts'/p.name)
for p in logs.iterdir():
    if p.is_file():shutil.copy2(p,OUT/'logs'/p.name)
shutil.copy2(WORK/'PLAN.md',OUT/'PLAN.md')
assert sha(OUT/'scripts/check_sources_and_trace.py')==trace['script_sha256']==source['script_sha256']
result=dict(checked_utc=datetime.now(timezone.utc).isoformat(),
    original_physical_energy_G='NOT IDENTIFIED in checked original and retained relationship/history passages',
    physical_total_energy_conservation='NOT ESTABLISHED for the selected original A/S system by this check',
    conditional_history_account='Its required trace is derived and can be defined causally from the existing carrying/activation history. Calling this constructed account physical energy remains an additional identification.',
    source_check='PASS: targeted primary DOCX and known relationship/history sources; broader archived review remains historical',
    arithmetic='PASS: 601 prior path times reconciled; 62 prior pair-potential samples retained with symbolic units conversion',
    new_Lean_compilation='PASS',axiom_audit='PASS',theorems=['HistoryRequirement.'+n for n in names],
    formal_scope='Necessary trajectory change of a G already assumed to have the balancing rate. No independent physical functional or PDE existence is asserted.',
    Lean_version=(logs/'lean-version.txt').read_text(encoding='utf-8-sig').strip(),
    mathlib_commit='85e3a25e006c35636f0e53b0e9296caca2685bc0',
    required_endpoint_change_without_pair=trace['final']['required_G_change'],
    with_pair='Delta G = -1.0654747938026771e-5 - lambda*7.604657325036376e-9; lambda is the unknown nonnegative conversion from raw context-potential units to model energy',
    new_simulation_steps=0,new_raw_frame_evaluations=0,new_original_corpus_sweep=False,
    original_equations_source_notes_saved_data_and_prior_receipts_unchanged=True,
    limitations=['Current source search is bounded, not exhaustive across all notes/chats/images/live boards',
        'Numerical histories and prior physical-transfer checks were reused, not rerun',
        'Endpoint and native-stage quadrature differences are retained explicitly',
        'No universal nonexistence claim for nonlocal or full-history energy',
        'No arbitrary energy scale, reservoir or negative-work account is presented as a discovered physical law'])
(OUT/'verification.json').write_text(json.dumps(result,indent=2)+'\n')
hashes={str(p.relative_to(OUT)):sha(p) for p in sorted(OUT.rglob('*')) if p.is_file() and p.name!='SHA256SUMS.json'}
(OUT/'SHA256SUMS.json').write_text(json.dumps(hashes,indent=2)+'\n')
archive=ROOT/'outputs/carrying-history-G.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
    for p in sorted(OUT.rglob('*')):
        if p.is_file():z.write(p,'carrying-history-G/'+str(p.relative_to(OUT)))
with zipfile.ZipFile(archive) as z:assert z.testzip() is None
print(json.dumps(result,indent=2))
