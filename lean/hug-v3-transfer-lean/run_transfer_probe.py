from pathlib import Path
import sys,json,hashlib,time
ROOT=Path(__file__).resolve().parent;SRC=ROOT/'sources'
sys.path.insert(0,str(SRC));sys.stdout.reconfigure(encoding='utf-8',errors='backslashreplace')
import numpy as np
from preflight import approve
plan=json.loads((ROOT/'transfer-probe-plan.json').read_text())
declaration=approve(plan['source_case'])
from structural_hug import Solver
from run import run_case
out=ROOT/'numerical-evidence';out.mkdir(exist_ok=False)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
source=json.loads((ROOT/'source-audit.json').read_text())
before={n:sha(SRC/n) for n in source['source_files']}
assert before==source['source_files']
(out/'preflight.json').write_text(json.dumps(dict(plan_sha256=sha(ROOT/'transfer-probe-plan.json'),
    source_hashes=before,gate_manifest_sha256=declaration['manifest_sha256'],
    implementation='Unmodified run_case(main); write_event observer returns its original result unchanged.'),indent=2)+'\n')
original_write=Solver.write_event;captured={}
def observe_write(self,s,record,budget=None):
    result=original_write(self,s,record,budget)
    if record['event_id']==plan['capture_event_id']:
        assert not captured
        captured.update(solver=self,state={k:v.copy() for k,v in result[0].items()})
    return result
Solver.write_event=observe_write
try:
    result=run_case(plan['source_case'])
finally:
    Solver.write_event=original_write
assert captured
so=captured['solver'];s=captured['state'];t=plan['capture_time']
i=plan['student'];a=plan['first_teacher'];j=plan['second_teacher'];delta=plan['cooperation_increment']
np.savez_compressed(out/'actual-post-first-write.npz',**s)
boost={k:v.copy() for k,v in s.items()};boost['responses'][i,a,1]+=delta
assert 0<=boost['responses'][i,a,1]<=1
empty={k:v.copy() for k,v in s.items()};empty['b']=so.fabric.initial()
def evaluate(state):
    rates=so.rhs(t,state)
    assert set(rates)==set(state)
    assert all(np.isfinite(v).all() for v in rates.values())
    return rates
d=evaluate(s);db=evaluate(boost);de=evaluate(empty)
def clearance_rate(state,rates):
    gap=state['expression'][j]-state['norm'][i]
    return float(2*np.exp(state['logradius'][i,j])**2*rates['logradius'][i,j]-
        2*np.dot(gap,rates['expression'][j]-rates['norm'][i]))
alignment=float(np.dot(s['expression'][j]-s['norm'][i],s['expression'][a]-s['norm'][i]))
norm_expected=delta*(s['expression'][a]-s['norm'][i])/5
guard_expected=2*delta/5*alignment
guard_observed=clearance_rate(boost,db)-clearance_rate(s,d)
records=so.read_material(s);records_boost=so.read_material(boost);records_empty=so.read_material(empty)
assert [(slot,r['event_id']) for slot,r in records]==[(slot,r['event_id']) for slot,r in records_boost]
assert len(records)==1 and records[0][1]['event_id']==0 and not records_empty
m,_,_=so.retrieve(t,s);mb,_,_=so.retrieve(t,boost);me,_,_=so.retrieve(t,empty)
errors=dict(norm_rate=float(np.max(np.abs((db['norm'][i]-d['norm'][i])-norm_expected))),
    other_expression_rate=float(np.max(np.abs(db['expression'][j]-d['expression'][j]))),
    radius_rate=float(np.max(np.abs(db['logradius']-d['logradius']))),
    squared_guard_rate=abs(guard_observed-guard_expected),memory_after_response_change=float(np.max(np.abs(mb-m))))
assert max(errors.values())<plan['numerical_identity_absolute_tolerance'],errors
assert m[i,a,0]>0 and me[i,a,0]==0 and m[i,j,0]==0 and me[i,j,0]==0
assert d['responses'][i,a,1]>de['responses'][i,a,1]
probe=dict(status='PASS',plan_sha256=sha(ROOT/'transfer-probe-plan.json'),
    full_coordinates=sum(v.size for v in s.values()),main_steps=result['steps'],
    main_seconds=result['seconds'],main_final=result['final'],actual_capture_time=t,
    norm_rate_difference=(db['norm'][i]-d['norm'][i]).tolist(),norm_rate_expected=norm_expected.tolist(),
    alignment=alignment,squared_guard_rate_difference=guard_observed,squared_guard_rate_expected=guard_expected,
    first_pair_benefit_with_imprint=float(m[i,a,0]),first_pair_benefit_empty=float(me[i,a,0]),
    second_pair_direct_benefit=float(m[i,j,0]),
    first_pair_cooperation_rate_with_imprint=float(d['responses'][i,a,1]),
    first_pair_cooperation_rate_empty=float(de['responses'][i,a,1]),
    second_pair_cooperation_rate_difference_from_memory_probe=float(d['responses'][i,j,1]-de['responses'][i,j,1]),
    accumulator_rate_difference_from_memory_probe=float(d['A']-de['A']),
    full_field_rate_difference_l2_from_memory_probe=float(np.linalg.norm(d['g']-de['g'])),
    max_identity_error=max(errors.values()),errors=errors,
    limits=plan['assumptions'],probe_interpretation=plan['scope'])
after={n:sha(SRC/n) for n in source['source_files']};assert before==after
probe['source_files_unchanged']=True
(out/'probe-results.json').write_text(json.dumps(probe,indent=2,allow_nan=False)+'\n')
print(json.dumps(probe,indent=2),flush=True)
