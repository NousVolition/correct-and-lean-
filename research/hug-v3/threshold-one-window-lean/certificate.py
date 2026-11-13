"""Fixed certificate inventory and validation shared by local and CI checks."""
import hashlib,json,re
from pathlib import Path

HERE=Path(__file__).resolve().parent
NAMESPACE='ThresholdOneRecords.'
NAMES=[
 'decimal_scale_positive',
 'complete_record_counts',
 'forty_distinct_sample_labels',
 'recorded_candidate_count',
 'all_240_recorded_gaps_positive',
 'all_240_selected_arclengths_in_window',
 'all_recorded_candidates_in_window',
 'all_240_saved_minima_attained_and_minimal',
 'all_480_recorded_nested_window_inequalities',
 'all_18_event_side_backward_gaps_strictly_smaller',
 'all_18_event_side_selected_arclengths_negative',
 'six_backward075_improvements_exceed_0002',
 'three_saved_time_brackets_narrow',
 'three_original_recorded_arclength_changes_large',
 'nine_backward_recorded_arclength_changes_below_two_millionths',
 'first_two_forward150_recorded_gaps_improve',
 'third_forward_extensions_preserve_recorded_selection',
 'third_original_left_selection_is_A',
 'first_two_both300_recorded_gaps_improve_on_both150',
 'third_both300_and_both150_recorded_selections_agree',
 'tighter_records_match_event_labels_and_times',
 'all_36_tighter_distance_differences_bounded',
 'all_36_tighter_arclength_differences_bounded']
TARGETS=[NAMESPACE+n for n in NAMES]
MODULES=['WindowRecordTypes','WindowRecordData','WindowRecordChecks','CheckAxioms']
PROOF_FILES=[m+'.lean' for m in MODULES]+[
 'lean-toolchain','lakefile.toml','source-inputs.json','generate.py',
 'certificate.py','verify.py','check_receipt.py','test_certificate.py']
COUNTS={'decimal_places':19,'samples':40,'windows_per_sample':6,'candidate_count':1995,
        'recorded_nested_comparisons':480,'event_side_backward_comparisons':18,'tighter_comparisons':36}
SCOPE='Lean-kernel checks of the supplied threshold-1 recorded decimal numbers; no trajectory theorem.'
LIMITS=[
 'Source hashing and Decimal-to-integer transcription are external Python checks, not Lean theorems.',
 'Finite minima range over saved candidate lists, not every point of a continuous curve.',
 'Endpoint differences do not establish continuity or absence of intervening switches.',
 'No fluid solver or line-integrator correctness, trajectory, closure, disconnection or reconnection theorem.',
 'No spatial or full-history convergence theorem; the original numerical history is unchanged.',
 'Comparator and nanoda are not used for this package.']

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def manifest():return json.loads((HERE/'source-inputs.json').read_text(encoding='utf-8'))
def proof_hashes():return {name:sha(HERE/name) for name in PROOF_FILES}
def audit_source():
    names=[]
    for module in MODULES[:3]:
        text=(HERE/(module+'.lean')).read_text(encoding='utf-8')
        code=re.sub(r'/\-.*?\-/','',text,flags=re.S)
        code=re.sub(r'--[^\n]*','',code)
        assert not re.search(r'\b(sorry|admit|axiom|native_decide|unsafe|implemented_by|extern)\b',code),module
        names += re.findall(r'^theorem\s+(\w+)',code,re.M)
    assert names==NAMES,'Missing, additional or reordered theorem declaration'
    expected='import WindowRecordChecks\n'+'\n'.join('#print axioms '+n for n in TARGETS)+'\n'
    assert (HERE/'CheckAxioms.lean').read_bytes()==expected.encode('utf-8'),'Audit target mismatch'
def validate(receipt):
    assert receipt['status']=='PASS'
    assert 'version 4.34.0-rc2' in receipt['lean_version']
    assert receipt['proof_inputs_sha256']==proof_hashes(),'Proof/source input fingerprint differs'
    assert receipt['source_data_sha256']==manifest()['files'],'Source-data fingerprint differs'
    assert receipt['targets']==TARGETS and receipt['theorem_count']==len(TARGETS)
    assert receipt['axioms']=={n:[] for n in TARGETS},'Missing audit or nonempty dependency list'
    assert receipt['counts']==COUNTS
    assert [r['module'] for r in receipt['runs']]==MODULES+['lake build']
    assert all(r['exit_code']==0 for r in receipt['runs'])
    assert receipt['source_inputs_unchanged'] is True and receipt['generated_input_matches'] is True
    assert receipt['scope']==SCOPE and receipt['limits']==LIMITS
    assert receipt['native_decide_used'] is False
    return True
