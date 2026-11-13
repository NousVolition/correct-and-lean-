"""Material-only readout, independent restart, and physical-code intervention."""
from material_trust import *

results={}
pair=lambda a:[float(a[0,1]),float(a[1,0])]
for name in ('both-trusting','a-trusting','b-trusting','both-untrusting'):
    folder=ROOT/'runs'/name;s=Session.load(folder/'checkpoint.zip')
    assert s.frame==650 and len(s.records)==3 and len(s.history)==654
    assert len(s.write_accounts)==654  # Initial sample + 650 samples + 3 events.
    fresh,_=build_solver(s.settings)
    with np.load(folder/'material-only.npz',allow_pickle=False) as z:
        assert set(z.files)=={'F','b'}
        minimal={k:z[k] for k in z.files}
        recovered=fresh.read_material(minimal)
    assert plain([r for _,r in recovered])==[s.read_trust_memory(i) for i in range(3)]
    _,journal=fresh.fabric.read_bundle(minimal['F'],minimal['b'])
    assert len(journal['times'])==651
    for event_id,count in enumerate((201,401,601)):
        p=recovered[event_id][1]['leadup']['profile']
        assert len(p['times'])==count and p['times'][0]==0
    sampled=[h for h in s.history if h['phase']!='after_write']
    max_errors={'trust':0.,'positions':0.,'features':0.}
    for k,h in enumerate(sampled):
        max_errors['trust']=max(max_errors['trust'],float(np.max(np.abs(journal['trust'][k]-[h['trust'][0][1],h['trust'][1][0]]))))
        max_errors['positions']=max(max_errors['positions'],float(np.max(np.abs(journal['positions'][k]-h['speck_positions']))))
        af=journal['actor_features'][k]
        feature=.5*(af[:,None,:]+af[None,:,:])
        max_errors['features']=max(max_errors['features'],float(np.max(np.abs(feature-h['memory_feature']))))
    assert max(max_errors.values())<=.00005+1e-14
    rates=trust_reading(s.solver,s.state)[2]
    np.testing.assert_allclose(rates,s.solver.rhs(s.t,s.state)['relation'][...,2],rtol=0,atol=3e-15)
    work=sum(a['work'] for a in s.write_accounts)
    assert abs(work-float(s.state['write_work']))<1e-12
    assert all(abs(a['work']-a['stored']-a['heat'])<1e-13 and a['heat']>=0 and a['required_budget']<=.02 for a in s.write_accounts)
    values=np.array([h['trust'] for h in s.history]);assert values.min()>=0 and values.max()<=1
    results[name]=dict(status='PASS',frame=s.frame,events=3,readings=654,material_samples=651,
        prefix_lengths=[201,401,601],material_only_read_exact=True,quantization_max_errors=max_errors,
        final_trust=pair(s.state['relation'][...,2]),write_work=work,
        sample_write_work=sum(a['work'] for a in s.write_accounts if a['kind']=='material_leadup_sample'),
        write_heat=sum(a['heat'] for a in s.write_accounts),
        max_required_budget=max(a['required_budget'] for a in s.write_accounts),
        final_min_abs_b=float(np.min(np.abs(s.state['b']))))

folder=ROOT/'runs/a-trusting'
settings=Settings(1,0)
baseline=Session.from_body(folder/'body-at-1.2.npz',settings)
changed=Session.from_body(folder/'body-at-1.2.npz',settings)
f=changed.solver.fabric
_,journal=f.read_bundle(changed.state['F'],changed.state['b'])
events_before=[r for _,r in baseline.solver.read_material(baseline.state)]
for k in range(600):
    if k in (200,400):continue  # Preserve each original event's endpoint feature.
    endpoint=200 if k<200 else 400 if k<400 else 600
    payload=f.encode_sample(k,journal['actor_ids'],journal['actor_features'][endpoint],journal['trust'][k],journal['positions'][k])
    bits=np.unpackbits(np.frombuffer(payload,dtype=np.uint8),bitorder='little')
    start=f.event_size+k*ROW_BYTES*8
    changed.state['b'][start:start+ROW_BYTES*8]=f.c.rest_amplitude*(2*bits.astype(float)-1)
np.testing.assert_array_equal(baseline.state['b'][:f.event_size],changed.state['b'][:f.event_size])
for key in baseline.state:
    if key!='b':np.testing.assert_array_equal(baseline.state[key],changed.state[key])
for a,b in zip(events_before,[r for _,r in changed.solver.read_material(changed.state)]):
    assert plain({k:v for k,v in a.items() if k!='leadup'})==plain({k:v for k,v in b.items() if k!='leadup'})
    np.testing.assert_array_equal(a['leadup']['profile']['features'][-1],b['leadup']['profile']['features'][-1])
    np.testing.assert_array_equal(a['leadup']['trust'],b['leadup']['trust'])
    np.testing.assert_array_equal(a['leadup']['positions'],b['leadup']['positions'])
rates_before=pair(trust_reading(baseline.solver,baseline.state)[2])
rates_changed=pair(trust_reading(changed.solver,changed.state)[2])
assert all(abs(a-b)>1e-7 for a,b in zip(rates_before,rates_changed))
baseline.history=[];baseline.records=[];baseline.write_accounts=[]
changed.history=[];changed.records=[];changed.write_accounts=[]
baseline.advance();changed.advance()
finished=Session.load(folder/'checkpoint.zip')
for key in baseline.state:np.testing.assert_array_equal(baseline.state[key],finished.state[key],err_msg=key)
expected_history=[h for h in finished.history if h['time']>1.2]
assert len(baseline.history)==len(expected_history)
for actual,expected in zip(baseline.history,expected_history):
    assert {k:v for k,v in actual.items() if k!='sequence'}=={k:v for k,v in expected.items() if k!='sequence'}
# Sequence numbers restart in an audit-free run; physical results and subsequent sample bytes must be exact.
assert plain(baseline.solver.fabric.read_bundle(baseline.state['F'],baseline.state['b'])[1])==plain(finished.solver.fabric.read_bundle(finished.state['F'],finished.state['b'])[1])
final_base=pair(baseline.state['relation'][...,2]);final_changed=pair(changed.state['relation'][...,2])
assert all(abs(a-b)>1e-7 for a,b in zip(final_base,final_changed))
intervention=dict(at=1.2,until=1.3,current_nonfabric_state_exactly_equal=True,
    original_event_cell_arrays_exactly_equal=True,event_payloads_exactly_equal=True,
    stored_trust_positions_and_event_endpoint_features_preserved=True,
    changed='Earlier context/strain feature codes in the material journal, with corresponding CRCs.',
    rates_original_material=rates_before,rates_changed_material=rates_changed,
    final_trust_original_material=final_base,final_trust_changed_material=final_changed,
    body_only_restart_future_exact=True,
    qualification='Diagnostic alternative material initial state, not an accepted append-only write or a proven reachable history. Only b differs at the fork. Its later effect includes recall and constitutive feedback; no identical-full-state or universal claim.')
(ROOT/'verification').mkdir(exist_ok=True)
atomic_bytes(ROOT/'verification/full-runs.json',json_bytes(dict(status='PASS',runs=results,intervention=intervention,source_fingerprint=source_fingerprint())))
atomic_bytes(ROOT/'verification/material-intervention.json',json_bytes(intervention))
print(json.dumps(dict(runs=results,intervention=intervention),indent=2))
