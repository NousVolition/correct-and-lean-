"""Targeted original-source check and reconciliation of existing path evidence.
No solver import, time stepping, fitted coefficient, or physical-energy claim.
"""
from pathlib import Path
from datetime import datetime,timezone
import csv,json,hashlib,zipfile,xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'outputs/carrying-history-G'
REPO=Path(r'$USER_HOME\Documents\Codex\2026-11-11\ang-mills-as-an-instance-the\work\github-publication')
OLD=Path(r'$USER_HOME\Documents\Codex\2026-10-08\referenced-chatgpt-conversation-this-is-an-2\outputs\hug-field-specification')
NATIVE=Path(r'$USER_HOME\Documents\Codex\2026-11-11\new-chat-13\tick41-readonly-check\inputs\declared-source')
DOC=Path(r'$USER_HOME\OneDrive\Desktop\Plain_Language_Corpus_Math_and_Logic_Corrected.docx')
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
targets={
    REPO/'research/comparisons/hug-navier-single-system-scope-correction.md':[(3,35)],
    REPO/'lean/hug-existence-lean/sources/interaction-equation.md':[(8,67),(125,163)],
    REPO/'lean/hug-navier-single-system-lean/FullModel.lean':[(1,15),(89,117)],
    OLD/'latest_interaction_design.json':[(1,58)],
    OLD/'COUPLED_FIELD.md':[(9,22),(70,87),(181,199)],
    NATIVE/'structural_hug.py':[(48,77),(175,226)],
    NATIVE/'continuum.py':[(158,176),(186,232),(242,260)]}
pathfile=ROOT/'outputs/unwrapped-carrying-history/path-history-12-16.csv'
ratefile=ROOT/'outputs/full-carrying-energy/activation-history.csv'
pairfile=ROOT/'outputs/paired-context-energy/checkpoints.csv'
historical=[ROOT/'outputs/unwrapped-carrying-history/verification.json',
    ROOT/'outputs/full-carrying-energy/verification.json',
    ROOT/'outputs/paired-context-energy/verification.json',
    ROOT/'outputs/nonlocal-history-energy/source-check.json',
    ROOT/'outputs/unwrapped-carrying-history/UnwrappedWork.lean',
    ROOT/'outputs/full-carrying-energy/FullCarrying.lean']
hashes={str(p):sha(p) for p in [DOC,*targets,pathfile,ratefile,pairfile,*historical]}
prior=json.loads(historical[3].read_text(encoding='utf-8'))
assert hashes[str(DOC)]==prior['input_sha256'][str(DOC)]
with zipfile.ZipFile(DOC) as z:
    tree=ET.fromstring(z.read('word/document.xml'))
ns={'w':'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
paragraphs=[''.join(t.text or '' for t in e.findall('.//w:t',ns)) for e in tree.findall('.//w:p',ns)]
assert len(paragraphs)==638
selected=[]
for lo,hi in [(228,266),(498,529),(545,555)]:
    selected.extend(dict(paragraph=i,text=paragraphs[i-1]) for i in range(lo,hi+1))
excerpts=[]
for path,ranges in targets.items():
    lines=path.read_text(encoding='utf-8-sig').splitlines()
    for lo,hi in ranges:
        excerpts.append(dict(source=str(path),start_line=lo,end_line=min(hi,len(lines)),
            text='\n'.join(f'{i+1}: {lines[i]}' for i in range(lo-1,min(hi,len(lines))))))
source=dict(checked_utc=datetime.now(timezone.utc).isoformat(),read_only=True,
    original_docx=str(DOC),original_docx_paragraphs=len(paragraphs),matches_prior_docx_hash=True,
    original_passages=selected,implementation_and_intent_passages=excerpts,
    distinctions=[
        'The original A/S equations specify transport, source accumulation, activation and momentum; the checked passages do not specify a gravitational G.',
        'Carrying continuity is preserved through changing configurations; it is not interpreted as a constant energy or frozen state.',
        'The broader guard relationship leaves its response functions and physical stress as choices; it does not supply an A/S energy mapping.',
        'The retained scalar product S*R in the reciprocal-scaling example is a static algebraic relation, not the identified dynamic spatial-field energy.',
        'In the actual record implementation delta_E is a symmetric strain change. Material record energy is the already-accounted fabric energy, not another energy named delta_E.',
        'Social retrieval depends on retained records and feeds utility/source selection, but these passages do not assign its own independent energy debit.'
    ],historical_review='The broader original-corpus and archived-board searches remain historical evidence. No new exhaustive search of all notes, chats, images, or live boards is claimed.',
    input_sha256=hashes,script_sha256=sha(Path(__file__)))
(OUT/'source-check.json').write_text(json.dumps(source,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
def read_csv(path):
    with path.open(newline='') as f:return list(csv.DictReader(f))
paths={int(r['frame']):r for r in read_csv(pathfile) if r['sample']=='volume_16'}
rates={int(r['frame']):r for r in read_csv(ratefile) if r['grid']=='16'}
pairs={int(r['frame']):r for r in read_csv(pairfile)}
assert len(paths)==601 and len(rates)==601 and len(pairs)==62
rows=[];pair_rows=[]
for frame,row in paths.items():
    V=float(row['endpoint_height_energy']);J=float(row['activation_history_correction'])
    W=float(row['endpoint_trapezoid_work']);native=float(row['path_work']);jr=float(rates[frame]['history_rate_integral'])
    assert abs(J-float(rates[frame]['history_endpoint']))<1e-18
    derived=dict(frame=frame,time=float(row['time']),height_change=V,endpoint_demand=J,
        required_G_change=-J,endpoint_path_work=W,
        conditional_endpoint_balance=W+V-J,
        native_path_work=native,native_vs_endpoint_quadrature=native-W,
        rate_integral_demand=jr,required_G_rate_integral_change=-jr,
        conditional_native_rate_balance=native+V-jr)
    rows.append(derived)
    if frame in pairs:
        F=float(pairs[frame]['potential'])-float(pairs[0]['potential'])
        pair_rows.append(dict(frame=frame,time=derived['time'],required_G_constant=-J,
            required_G_coefficient_of_unknown_energy_conversion=-F,
            old_pair_potential_change_raw=F,
            conditional_balance_constant=W+V-J,conditional_balance_scale_coefficient=F-F))
def write_csv(name,values):
    with (OUT/name).open('w',newline='') as f:
        w=csv.DictWriter(f,list(values[0]));w.writeheader();w.writerows(values)
write_csv('required-history-trace.csv',rows)
write_csv('required-history-with-pair.csv',pair_rows)
max_endpoint=max(abs(r['conditional_endpoint_balance']) for r in rows)
assert max_endpoint<1e-18
assert all(r['old_pair_potential_change_raw']>=0 for r in pair_rows)
assert all(sha(p)==h for p,h in hashes.items())
result=dict(checked_utc=datetime.now(timezone.utc).isoformat(),status='PASS for source preservation and conditional arithmetic',
    independently_identified_physical_G='NOT IDENTIFIED in the scoped original/relationship/history passages',
    new_solver_steps=0,new_raw_frame_evaluations=0,
    reused_path_times=len(paths),reused_pair_samples=len(pairs),
    newly_checked='Reconciled existing path/source-rate tables, derived the required G trace, and retained a symbolic energy-unit conversion for the old context potential',
    final=rows[-1],with_pair_final=pair_rows[-1],
    endpoint_identity_max_defect=max_endpoint,
    final_source_rate_vs_endpoint_difference=rows[-1]['rate_integral_demand']-rows[-1]['endpoint_demand'],
    no_physical_energy_conversion_fitted=True,
    conclusion='The required history account can close the specified bookkeeping by construction. These data do not identify an independently prescribed physical G.',
    input_sha256=hashes,original_sources_and_prior_outputs_unchanged=True,
    script_sha256=sha(Path(__file__)))
(OUT/'trace-check.json').write_text(json.dumps(result,indent=2,allow_nan=False)+'\n')
print(json.dumps({k:result[k] for k in ['status','independently_identified_physical_G','reused_path_times','reused_pair_samples','final','with_pair_final','endpoint_identity_max_defect','final_source_rate_vs_endpoint_difference']},indent=2))
print('ORIGINAL PASSAGES')
for p in selected:
    if p['paragraph'] in [230,231,266,498,499,500,501,517,518,519,520,524,545]:print(json.dumps(p,ensure_ascii=False))
