"""Save a local study checkpoint without advancing historical GitHub evidence."""
import hashlib,json,re
from datetime import datetime,timezone
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];WORK=ROOT/'work/pair25-origins'
OUT=ROOT/'outputs/pair25-origins';LEAN=ROOT/'outputs/pair25-origins-lean'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def dump(p,x):p.write_text(json.dumps(x,indent=2,allow_nan=False)+'\n',encoding='utf-8')
def main():
    proof=read(LEAN/'receipt.json');analysis=read(OUT/'analysis.json');values=read(OUT/'report-values.json')
    cert=read(WORK/'certificate-selftest.json');qa=read(WORK/'diagram-review.json')
    assert proof['status']=='PASS' and cert['tamper_tests_passed']==6
    assert qa['inspected'] and qa['diagram_sha256']==sha(OUT/'pair25-origins.png')
    for rel,digest in proof['proof_inputs'].items():assert sha(LEAN/rel)==digest,rel
    canonical=json.dumps(proof['proof_inputs'],sort_keys=True,separators=(',',':'))
    assert hashlib.sha256(canonical.encode()).hexdigest()==proof['proof_input_fingerprint']
    assert proof['targets']==read(LEAN/'targets.json')
    assert all(all(r['runtime_checks'].values()) for r in analysis['runs'])
    assert all(r['exit_code']==0 for r in read(OUT/'process-exits.json'))
    preserved={
      'outputs/pair25-retention-lean/receipt.json':'8790858b9e5dc3942707a8e201b0dba4aaa4cd76e277c4e6975f89bfb5553f31',
      'work/pair25-publication-evidence/publication-receipt.json':'fed25abac31ee5c82ced22da9c0f30825fc6cb6574bf296be7eb5aea3173cee0'}
    for rel,digest in preserved.items():assert sha(ROOT/rel)==digest
    # Markdown links must resolve locally; external links are not probed here.
    for page in [OUT/'README.md',LEAN/'README.md']:
        for target in re.findall(r'\]\(([^)]+)\)',page.read_text(encoding='utf-8')):
            if not target.startswith(('http:','https:')):assert (page.parent/target).exists(),(page,target)
    now=datetime.now(timezone.utc).isoformat()
    files=[WORK/'PLAN.md',WORK/'run_origins.py',WORK/'analyze_origins.py',WORK/'generate_lean.py',WORK/'build_report.py',WORK/'finalize.py',WORK/'certificate-selftest.json',WORK/'diagram-review.json',OUT/'analysis.json',OUT/'origin-comparisons.json',OUT/'README.md',OUT/'pair25-origins.png',OUT/'pair25-origins.svg',LEAN/'README.md',LEAN/'receipt.json']
    review={'status':'COMPLETE','verified_utc':now,'scope':'Local numerical origin tracking and finite Lean checks; complete physical inventory remains unresolved.','interval':[1.2,1.3],'entry':'after-write tick 41; not the earlier encounter entry at 1.1','primary_radius':.075,'run_count':3,'all_native_exit_arrays_unchanged':True,'finite_identity_memberships_agree_at_common_times':all(r['different_membership_observations']==0 for r in analysis['identity_comparisons']),'lean_target_count':proof['target_count'],'proof_input_fingerprint':proof['proof_input_fingerprint'],'data_certificate':cert,'endpoint_summary':values,'diagram_review':qa,'historical_receipts_preserved':preserved,'files_sha256':{p.relative_to(ROOT).as_posix():sha(p) for p in files},'publication':'local only; no new GitHub run or commit','limitations':analysis['limits']+['The time-1.1 starting inventory remains missing.','Window choices change the recorded shares; no continuum convergence criterion was declared.','Material-field numbers are finite measurements, not a formal proof of their evolution.']}
    dump(WORK/'review-receipt.json',review)
    cp_path=ROOT/'work/front-page-checkpoint.json';before=read(cp_path)
    cp=dict(before)
    cp['pair_origin_study']={'status':'local_verified','verified_utc':now,'report':'outputs/pair25-origins/README.md','diagram':'outputs/pair25-origins/pair25-origins.png','review_receipt':'work/pair25-origins/review-receipt.json','lean_receipt':'outputs/pair25-origins-lean/receipt.json','lean_targets':proof['target_count'],'proof_input_fingerprint':proof['proof_input_fingerprint'],'entry_time':1.2,'exit_time':1.3,'pair_id':24,'primary_radius':.075,'material_stayed':133,'other_observers_stayed':276,'starting_context_still_inside_percent':values['retained_origin_percent'],'starting_context_elsewhere_percent':values['elsewhere_origin_percent'],'inside_total_percent_of_entry':values['total_inside_percent_of_entry'],'complete_physical_retention':'unestablished','github_publication':'not requested for this follow-up'}
    cp['pair_origin_study']['wider_union']={'radius':.1,'entry_observer_count':364,'exit_observer_count':364,'departing_observer':540,'arriving_observer':872,'identities_agree_across_runs':True,'crossing_times_grid_converged':'unestablished','source':'outputs/pair25-origins/crossings.csv'}
    cp['pair_origin_study']['maximum_earlier_retained_context_grid_difference_pp']=next(r['maximum_common_time_difference_percentage_points'] for r in read(OUT/'origin-comparisons.json') if r['comparison']=='40 to 48 grid' and r['quantity']=='original_inside_now')
    dump(cp_path,cp)
    after=read(cp_path)
    assert {k:v for k,v in after.items() if k!='pair_origin_study'}=={k:v for k,v in before.items() if k!='pair_origin_study'}
    dump(WORK/'checkpoint.json',{'completed_utc':now,'review_receipt':'work/pair25-origins/review-receipt.json','github_verified_commit_preserved':before['github']['verified_commit'],'last_full_review_utc_preserved':before['last_full_review_utc'],'new_local_study':after['pair_origin_study']})
    (WORK/'ACTIVE.md').write_text('# Pair 25 origin tracking completed locally\n\nAll three continuations, independent saved-data recount, Lean certificate/refusal tests, compilation/axiom audit, diagram review and local checkpoint are complete. See review-receipt.json and outputs/pair25-origins/README.md. No new publication was requested. Previous GitHub checkpoint and historical receipts remain unchanged.\n',encoding='utf-8')
    print(json.dumps({'status':'COMPLETE','lean_targets':proof['target_count'],'fingerprint':proof['proof_input_fingerprint'],'retained_origin_percent':values['retained_origin_percent'],'elsewhere_origin_percent':values['elsewhere_origin_percent'],'historical_github_commit_preserved':before['github']['verified_commit']},indent=2))
if __name__=='__main__':main()
