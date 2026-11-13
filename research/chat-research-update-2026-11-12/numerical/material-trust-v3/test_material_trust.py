import copy,tempfile,unittest
from pathlib import Path
from material_trust import Session,Settings,np,trust_reading,MemoryReadError,CapacityError,ROWS,ROW_BYTES

def short_session():
    s=Session(Settings(.2,.8,horizon=.018))
    events=copy.deepcopy(s.case['events'])
    for e,start,end in zip(events,(0.,.002,.008),(.004,.008,.012)):e.update(start=start,end=end)
    s.case={**s.case,'events':events};s.starts={0:s.state['F'].copy()};return s

class MaterialTests(unittest.TestCase):
    def test_traction_only_probe_is_exactly_original_probe(self):
        from structural_hug import Fabric
        s=Session(Settings(.2,.8,horizon=.004));s.advance()
        f=s.solver.fabric
        for actual,expected in zip(f.probe(s.state['F'],s.state['b']),Fabric.probe(f,s.state['F'],s.state['b'])):
            np.testing.assert_array_equal(actual,expected)

    def test_material_roundtrip_all_samples_and_independent_starts(self):
        for a,b in ((0,0),(0,1),(1,0),(1,1)):
            s=Session(Settings(a,b,horizon=.004));s.advance()
            _,j=s.solver.fabric.read_bundle(s.state['F'],s.state['b'])
            self.assertEqual(len(j['times']),3);np.testing.assert_array_equal(j['trust'][0],[a,b])
            np.testing.assert_array_equal(j['times'],[0,.002,.004])
            self.assertEqual(j['actor_ids'],[0,1])
            for k,h in enumerate(s.history):
                np.testing.assert_allclose(j['positions'][k],h['speck_positions'],rtol=0,atol=.00005)
                np.testing.assert_allclose(j['trust'][k],[h['trust'][0][1],h['trust'][1][0]],rtol=0,atol=.00005)

    def test_material_event_read_is_independent_of_all_software_archives(self):
        s=short_session();s.advance(7)
        expected=s.read_trust_memory(2);rates=trust_reading(s.solver,s.state)[2]
        self.assertEqual(expected['leadup']['profile']['times'][0],0.)
        self.assertEqual(expected['leadup']['profile']['times'][-1],.012)
        s.history=[];s.records=[];s.write_accounts=[]
        s.solver.leadup='POISON';s.solver.recall_profiles={2:'POISON'}
        self.assertEqual(expected,s.read_trust_memory(2))
        np.testing.assert_array_equal(rates,trust_reading(s.solver,s.state)[2])
        s.advance()  # Future material writes also require no historical software samples.
        self.assertEqual(expected,s.read_trust_memory(2))

    def test_body_only_restart_continues_with_identical_future(self):
        s=short_session();s.advance(7)
        with tempfile.TemporaryDirectory() as tmp:
            p=Path(tmp)/'body.npz';p.write_bytes(s.state_bytes())
            r=Session.from_body(p,s.settings);r.case=copy.deepcopy(s.case)
            self.assertEqual(s.read_trust_memory(2),r.read_trust_memory(2))
            self.assertEqual(len(r.history),1)
            s.advance();r.advance()
            for k in s.state:np.testing.assert_array_equal(s.state[k],r.state[k],err_msg=k)
            self.assertEqual(s.read_trust_memory(2),r.read_trust_memory(2))

    def test_probe_corruption_is_not_repaired_from_logs(self):
        s=short_session();s.advance(3);s.solver.retrieve(s.t,s.state)
        p=s.solver.fabric.event_size+20
        good=s.state['b'][p];s.state['b'][p]=0
        with self.assertRaises(MemoryReadError):s.read_trust_memory(0)
        s.state['b'][p]=-good
        with self.assertRaisesRegex(MemoryReadError,'checksum'):s.read_trust_memory(0)

    def test_work_heat_and_unchanged_old_cells(self):
        s=Session(Settings(.3,.7,horizon=.004));s.state=s.solver.step(0,s.state,.002)
        before={k:v.copy() for k,v in s.state.items()};f=s.solver.fabric
        after,account=s.solver.write_sample(before,1)
        np.testing.assert_array_equal(before['b'][:f.event_size],after['b'][:f.event_size])
        self.assertAlmostEqual(f.energy(after['F'],after['b'])-f.energy(before['F'],before['b']),account['stored'],places=14)
        self.assertAlmostEqual(account['stored']+account['heat'],account['work'],places=15)
        self.assertAlmostEqual(float(after['write_work']-before['write_work']),account['work'],places=15)
        self.assertAlmostEqual(float((after['g'][...,4]-before['g'][...,4]).mean()),account['heat'],places=14)
        self.assertGreater(account['heat'],0);self.assertLessEqual(account['peak_work'],account['required_budget']+1e-15)
        self.assertEqual(f.size,f.event_size+ROWS*ROW_BYTES*8)

    def test_budget_range_duplicate_and_capacity_refuse_without_mutation(self):
        s=Session(Settings(.3,.7,horizon=.004));before=s.state['b'].copy()
        with self.assertRaisesRegex(ValueError,'budget'):s.solver.write_sample(s.state,1,budget=0)
        np.testing.assert_array_equal(before,s.state['b'])
        with self.assertRaisesRegex(ValueError,'append'):s.solver.write_sample(s.state,0)
        values=s.solver.sample_values(s.state)
        with self.assertRaises(CapacityError):s.solver.fabric.encode_sample(ROWS,(0,1),*values)
        bad=copy.deepcopy(values);bad[0][0,0]=100
        with self.assertRaisesRegex(ValueError,'range'):s.solver.fabric.encode_sample(1,(0,1),*bad)

    def test_original_trust_rhs_and_no_future_outcomes(self):
        s=short_session()
        np.testing.assert_array_equal(s.solver.retrieve(0,s.state)[0],0)
        for _ in range(8):
            np.testing.assert_allclose(trust_reading(s.solver,s.state)[2],s.solver.rhs(s.t,s.state)['relation'][...,2],rtol=0,atol=3e-15)
            s.step()

    def test_material_prefix_relevance_is_causal(self):
        s=short_session();s.advance(7)
        _,journal=s.solver.fabric.read_bundle(s.state['F'],s.state['b'])
        rate=trust_reading(s.solver,s.state)[2]
        f=s.solver.fabric
        # Controlled physical-code intervention: replace an earlier sample feature
        # and recompute CRC. It is not claimed to be a naturally reachable history.
        payload=f.encode_sample(0,journal['actor_ids'],journal['actor_features'][0]+.2,journal['trust'][0],journal['positions'][0])
        bits=np.unpackbits(np.frombuffer(payload,dtype=np.uint8),bitorder='little')
        s.state['b'][f.event_size:f.event_size+ROW_BYTES*8]=f.c.rest_amplitude*(2*bits.astype(float)-1)
        after=trust_reading(s.solver,s.state)[2]
        self.assertGreater(abs(after[0,1]-rate[0,1]),1e-7)
        self.assertGreater(abs(after[1,0]-rate[1,0]),1e-7)

if __name__=='__main__':unittest.main(verbosity=2)
