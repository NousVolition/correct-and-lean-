"""Record verified local work without advancing the published GitHub checkpoint."""
import hashlib,json,re
from datetime import datetime,timezone
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];WORK=ROOT/'work/observer540-872';OUT=ROOT/'outputs/observer540-872';LEAN=ROOT/'outputs/observer540-872-lean'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def dump(p,x):p.write_text(json.dumps(x,indent=2,allow_nan=False)+'\n',encoding='utf-8')
def main():
    proof=read(LEAN/'receipt.json');analysis=read(OUT/'analysis.json');qa=read(WORK/'diagram-review.json')
    assert proof['status']=='PASS' and proof['target_count']==134
    assert len(proof['data_certificate_check']['tamper_tests_passed'])==8
    assert qa['inspected'] and qa['diagram_sha256']==sha(OUT/'following-540-872.png')
    for rel,digest in proof['proof_inputs'].items():assert sha(LEAN/rel)==digest,rel
    fingerprint=hashlib.sha256(json.dumps(proof['proof_inputs'],sort_keys=True,separators=(',',':')).encode()).hexdigest()
    assert fingerprint==proof['proof_input_fingerprint'] and proof['targets']==read(LEAN/'targets.json')
    for rel,digest in analysis['input_hashes'].items():assert sha(ROOT/rel)==digest,rel
    assert all(all(r['runtime_criteria'].values()) for r in analysis['runs'])
    assert all(r['exit_code']==0 for r in read(OUT/'process-exits.json'))
    assert sha(WORK/'run_follow.py')=='c831ff07eff9f98b16be8d7dce28e8fbff49846c792c10907133014bd94f0043'
    prior=read(ROOT/'work/pair25-origins/review-receipt.json')
    preserved={k:v for k,v in prior['files_sha256'].items() if k in ['outputs/pair25-origins-lean/receipt.json','outputs/pair25-origins/analysis.json','work/pair25-origins/run_origins.py']}
    preserved.update(prior['historical_receipts_preserved'])
    for rel,digest in preserved.items():assert sha(ROOT/rel)==digest,(rel,'historical source changed')
    for page in [OUT/'README.md',LEAN/'README.md']:
        for target in re.findall(r'\]\(([^)]+)\)',page.read_text(encoding='utf-8')):
            if not target.startswith(('http:','https:')):assert (page.parent/target).exists(),(page,target)
    now=datetime.now(timezone.utc).isoformat()
    files=[WORK/p for p in ['PLAN.md','run_follow.py','analyze_follow.py','generate_lean.py','build_report.py','finalize.py','diagram-review.json']]
    files += [OUT/p for p in ['pilot.json','analysis.json','README.md','neighbor-summary.csv','crossing-readouts.csv','entry-material-fields.csv','pair-wide-origin-readouts.csv','following-540-872.png','following-540-872.svg','following-540-872.pdf','process-exits.json']]
    files += [LEAN/'receipt.json',LEAN/'README.md']
    review={'status':'COMPLETE_LOCAL','verified_utc':now,'request':'Follow 540 as it leaves and 872 as it enters; inspect what stays, changes and accompanies each; check recorded results in Lean.','observer_ids':[540,872],'interval':[1.2,1.3],'entry':'after-write tick 41, historical threshold-0.015 breathing-on state','primary_individual_radius':.075,'original_pair_crossing_radius':.1,'runs':analysis['runs'],'crossings':analysis['crossings'],'window_endpoints':analysis['window_endpoints'],'point_endpoints':analysis['point_endpoints'],'context_grid_time_comparisons':analysis['context_grid_time_comparisons'],'neighbor_grid_time_comparisons':analysis['neighbor_grid_time_comparisons'],'lean_target_count':proof['target_count'],'proof_input_fingerprint':fingerprint,'data_certificate':proof['data_certificate_check'],'diagram_review':qa,'historical_receipts_preserved':preserved,'files_sha256':{p.relative_to(ROOT).as_posix():sha(p) for p in files},'publication':'local only; no new GitHub commit or run','limits':analysis['limits']}
    dump(WORK/'review-receipt.json',review)
    cp_path=ROOT/'work/front-page-checkpoint.json';before=read(cp_path);cp=dict(before)
    summary={'status':'local_verified','verified_utc':now,'report':'outputs/observer540-872/README.md','diagram':'outputs/observer540-872/following-540-872.png','review_receipt':'work/observer540-872/review-receipt.json','lean_receipt':'outputs/observer540-872-lean/receipt.json','lean_targets':proof['target_count'],'proof_input_fingerprint':fingerprint,'observer_ids':[540,872],'interval':[1.2,1.3],'primary_individual_radius':.075,'original_pair_crossing_radius':.1,'original_material_neighbors_stayed_each':8,'original_context_remaining_nearby_at_exit_percent':{str(int(r['observer'])):100*r['retained_starting_context_fraction'] for r in analysis['window_endpoints'] if r['run']=='n48_dt0p00025'},'complete_physical_retention':'unestablished','new_origin_share_grid_convergence':'unestablished','publication':'not requested for this follow-up'}
    cp['observer_follow_study']=summary;dump(cp_path,cp);after=read(cp_path)
    assert {k:v for k,v in after.items() if k!='observer_follow_study'}=={k:v for k,v in before.items() if k!='observer_follow_study'}
    dump(WORK/'checkpoint.json',{'completed_utc':now,'review_receipt':'work/observer540-872/review-receipt.json','github_verified_commit_preserved':before['github']['verified_commit'],'last_full_review_utc_preserved':before['last_full_review_utc'],'new_local_study':summary})
    (WORK/'ACTIVE.md').write_text('# Following 540 and 872 completed locally\n\nAll three passive-origin continuations, independent saved-data recount, Lean source/refusal checks, all134 theorem targets, axiom audit, diagram inspection and local checkpoint are complete. See review-receipt.json, outputs/observer540-872/README.md and outputs/observer540-872-lean/receipt.json. No new publication was requested. Published GitHub checkpoint and earlier studies/receipts remain unchanged. Complete physical inventory/retention and new origin-share grid convergence remain unestablished.\n',encoding='utf-8')
    print(json.dumps({'status':review['status'],'lean_targets':proof['target_count'],'fingerprint':fingerprint,'github_checkpoint_preserved':before['github']['verified_commit'],'retained_percent':summary['original_context_remaining_nearby_at_exit_percent']},indent=2))
if __name__=='__main__':main()
