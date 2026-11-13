from pathlib import Path
from datetime import datetime,timezone
import json,hashlib,shutil,zipfile,ast,re
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'outputs/paired-context-energy';WORK=ROOT/'work/paired-context-energy'
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
numeric=json.loads((OUT/'potential-check.json').read_text())
source=json.loads((OUT/'source-check.json').read_text(encoding='utf-8'))
for result in (numeric,source):
    for path,h in result['input_sha256'].items():assert sha(path)==h
assert numeric['status']=='PASS' and numeric['saved_states']==62 and numeric['new_solver_steps']==0
assert numeric['initial']['potential']==0 and numeric['final']['potential']>0
assert numeric['maxima']['actual_pairgrid_max']==0
assert numeric['finest_directional_check_max_error']<1e-12
assert source['sources_unchanged'] and numeric['original_sources_states_and_loaded_arrays_unchanged']
build=WORK/'logs-proof-3';records=json.loads((build/'build-results.json').read_text(encoding='utf-8-sig'))
for row in records:
    assert row['exit_code']==0 and row['source_unchanged']
    assert sha(row['source'])==row['source_sha256'].lower()
    assert sha(row['log'])==row['log_sha256'].lower()
assert [r['module'] for r in records]==['PairContext','PairContextAudit']
audit=(build/'PairContextAudit.log').read_text(encoding='utf-8-sig')
names=['log_cosh_rate','potential_nonnegative','potential_zero','moving_potential_rate','zero_context_cannot_pay']
for name in names:
    expected=f"'PairContext.{name}' depends on axioms: [propext, Classical.choice, Quot.sound]"
    assert expected in audit
assert 'sorryAx' not in audit and not re.search(r'\b(sorry|admit|axiom)\b',(OUT/'PairContext.lean').read_text())
for folder in ('scripts','logs'):(OUT/folder).mkdir(exist_ok=True)
for p in WORK.glob('*.py'):
    ast.parse(p.read_text(encoding='utf-8'));shutil.copy2(p,OUT/'scripts'/p.name)
for p in build.iterdir():
    if p.is_file():shutil.copy2(p,OUT/'logs'/p.name)
shutil.copy2(WORK/'PLAN.md',OUT/'PLAN.md')
assert sha(OUT/'scripts/check_potential.py')==numeric['script_sha256']
assert sha(OUT/'scripts/source_check.py')==source['script_sha256']
priorpath=ROOT/'outputs/full-carrying-energy/activation-results.json'
prior=json.loads(priorpath.read_text());endpoint=next(r for r in prior['endpoints'] if r['grid']==16)
assert abs(endpoint['history_endpoint']-1.0654747938026771e-5)<1e-18
result=dict(checked_utc=datetime.now(timezone.utc).isoformat(),
    source_trace='CHECKED: old pair law is an added, later superseded realization; not derived from carrying continuity alone',
    requested_energy_closure='NOT ESTABLISHED: this specific canonical potential cannot pay the positive net residual from zero initial context. Additional configuration/history energy remains unspecified.',
    numerical_checks='PASS',Lean_compilation='PASS',axiom_audit='PASS',
    new_proved_statements=['PairContext.'+v for v in names],
    Lean_version=(build/'lean-version.txt').read_text(encoding='utf-8-sig').strip(),
    mathlib_commit='85e3a25e006c35636f0e53b0e9296caca2685bc0',
    build_attempts=dict(first_two='Unsuccessful local proof drafts, preserved in work/logs-proof-1 and work/logs-proof-2',
        final='logs-proof-3: both final modules exit 0; no unresolved formalization in the five stated lemmas'),
    formal_scope='Finite log-cosh chain rule and initial-minimum result, conditional on the declared derivatives and nonnegative weights. Moving-kernel adjoint collapse is an analytic derivation with numerical checks, not additionally formalized here.',
    saved_states=62,new_solver_steps=0,physical_equation_changes=0,
    diagnostic_potential_change=numeric['final']['potential']-numeric['initial']['potential'],
    diagnostic_units=numeric['raw_units'],
    remaining_energy_demand=dict(amount=endpoint['history_endpoint'],units='model energy',
        provenance='Earlier endpoint activation-height account, retained as historical numerical evidence',
        source=str(priorpath),sha256=sha(priorpath)),
    source_notes_equations_and_saved_states_unchanged=True,
    limitations=['The old reference-pair prescription is evaluated diagnostically at the current saved resolution, not activated in the equations',
        'No physical energy conversion or independent configuration/history-only energy law has been supplied',
        'No universal impossibility theorem for gravitational or all-history energy',
        'No new full-corpus or live-board search; prior readable-source coverage and exclusions are retained',
        'The full PDE and its numerical trajectory are not formally verified by these finite lemmas'])
(OUT/'verification.json').write_text(json.dumps(result,indent=2)+'\n')
hashes={str(p.relative_to(OUT)):sha(p) for p in sorted(OUT.rglob('*')) if p.is_file() and p.name!='SHA256SUMS.json'}
(OUT/'SHA256SUMS.json').write_text(json.dumps(hashes,indent=2)+'\n')
archive=ROOT/'outputs/paired-context-energy.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
    for p in sorted(OUT.rglob('*')):
        if p.is_file():z.write(p,'paired-context-energy/'+str(p.relative_to(OUT)))
with zipfile.ZipFile(archive) as z:assert z.testzip() is None
print(json.dumps(result,indent=2))
