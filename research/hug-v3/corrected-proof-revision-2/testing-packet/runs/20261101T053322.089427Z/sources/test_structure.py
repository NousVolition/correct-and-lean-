"""Independent acceptance probes for the declared synthetic mechanism."""
from pathlib import Path
import json,io,copy,unittest
ROOT=Path(__file__).resolve().parent
from preflight import approve
approve('unit')
import numpy as np
from structural_hug import Solver,Config,Fabric,MemoryReadError,CapacityError,outcome_score,strain_tensor

def record(so,origin=0,recipient=1,event_id=0,start=0.,end=.4,observed=.6,report=.5,predecessors=0):
    return dict(origin=origin,recipient=recipient,event_id=event_id,start=start,end=end,predecessors=predecessors,
                observed=observed,recipient_report=report,context=np.array([.6,.4]),recognition=.7,authority=.4,
                actions=np.array([.2,.1,.3,.5,.1,.4,.2]),delta_E=np.zeros((so.P,6)))

class StructureTests(unittest.TestCase):
    def setUp(self):
        self.so=Solver(Config(n=12,radial=2,polar=4,azimuth=8,end=.02));self.s=self.so.initial()
    def write(self,r,s=None):return self.so.write_event(self.s if s is None else s,r)[0]
    def test_01_refusal_is_not_an_outcome_input(self):
        self.assertEqual(outcome_score(.6,.4),.5)
        self.assertAlmostEqual(outcome_score(-.8,-.4),-.6,places=14)
        self.assertIsNone(outcome_score(None,None))
        self.assertEqual(outcome_score(None,.4),.4)
    def test_02_protective_refusal_and_harmful_cooperation(self):
        r=record(self.so);r['actions'][:]=0;r['actions'][3]=1
        s=self.write(r);m=self.so.retrieve(.4,s)[0]
        self.assertGreater(m[1,0,0],0);self.assertEqual(m[1,0,1],0)
        self.assertEqual(float(m[0,1].sum()),0)
        r=record(self.so,observed=-.7,report=-.5);r['actions'][:]=0;r['actions'][1]=1
        s=self.write(r);m=self.so.retrieve(.4,s)[0]
        self.assertEqual(m[1,0,0],0);self.assertGreater(m[1,0,1],0)
    def test_03_action_label_swap_does_not_relabel_same_consequence(self):
        r=record(self.so);r2=copy.deepcopy(r);r2['actions']=r['actions'][::-1]
        a=self.so.retrieve(.4,self.write(r))[0];b=self.so.retrieve(.4,self.write(r2))[0]
        np.testing.assert_allclose(a,b,atol=1e-13)
    def test_04_unknown_outcome_is_retained_not_made_safe(self):
        s=self.write(record(self.so,observed=None,report=None))
        r=self.so.read_material(s)[0][1]
        self.assertIsNone(r['observed']);self.assertIsNone(r['recipient_report'])
        self.assertEqual(self.so.retrieve(.4,s)[1].sum(),0)
    def test_05_every_material_tensor_component_roundtrips(self):
        rng=np.random.default_rng(2401);r=record(self.so)
        r['delta_E']=rng.uniform(-.2,.2,(self.so.P,6))
        decoded=self.so.read_material(self.write(r))[0][1]
        self.assertLessEqual(np.max(abs(decoded['delta_E']-r['delta_E'])),.5*self.so.c.strain_quantum+1e-15)
        for key in ['origin','recipient','event_id','predecessors']:self.assertEqual(decoded[key],r[key])
    def test_06_origin_recipient_swap_is_distinct(self):
        a=self.write(record(self.so));b=self.write(record(self.so,origin=1,recipient=0))
        self.assertFalse(np.array_equal(self.so.fabric.probe(a['F'],a['b'])[1],self.so.fabric.probe(b['F'],b['b'])[1]))
        self.assertEqual(self.so.read_material(a)[0][1]['origin'],0)
        self.assertEqual(self.so.read_material(b)[0][1]['origin'],1)
    def test_07_order_and_concurrency_are_explicit(self):
        first=self.write(record(self.so));second=self.write(record(self.so,event_id=1,start=.4,end=.8,predecessors=1),first)
        self.assertEqual(self.so.read_material(second)[1][1]['predecessors'],1)
        overlap=self.write(record(self.so,event_id=1,start=.2,end=.8,predecessors=0),first)
        self.assertEqual(self.so.read_material(overlap)[1][1]['predecessors'],0)
        self.assertFalse(np.array_equal(second['b'],overlap['b']))
    def test_08_reverse_histories_with_matched_totals_remain_distinct(self):
        a=self.write(record(self.so,origin=0,recipient=1))
        a=self.write(record(self.so,event_id=1,origin=2,recipient=3,start=.4,end=.8,predecessors=1),a)
        b=self.write(record(self.so,origin=2,recipient=3))
        b=self.write(record(self.so,event_id=1,origin=0,recipient=1,start=.4,end=.8,predecessors=1),b)
        self.assertNotEqual([r['origin'] for _,r in self.so.read_material(a)],[r['origin'] for _,r in self.so.read_material(b)])
    def test_09_archive_cannot_supply_retrieval(self):
        s=self.write(record(self.so));expected=self.so.retrieve(.4,s)[0]
        class Poison:
            def __iter__(self):raise AssertionError('archive accessed')
            def __len__(self):raise AssertionError('archive accessed')
            def __getitem__(self,k):raise AssertionError('archive accessed')
        self.so.records=Poison();self.so.record_times=Poison();self.so._archive_cache=Poison()
        np.testing.assert_array_equal(self.so.retrieve(.4,s)[0],expected)
        self.so.rhs(.4,s)
        with self.assertRaises(RuntimeError):self.so.episode(s)
    def test_10_body_only_checkpoint_and_fresh_reader(self):
        s=self.write(record(self.so));data=io.BytesIO();np.savez(data,F=s['F'],b=s['b'],X=self.so.X0,V=self.so.V);data.seek(0)
        stored=np.load(data);fresh=Fabric(self.so.c,stored['X'],stored['V'])
        read=fresh.decode_probe(*fresh.probe(stored['F'],stored['b']))
        self.assertEqual(read[0][1]['recipient'],1)
        self.assertEqual(set(stored.files),{'F','b','X','V'})
    def test_11_mechanical_probe_matches_energy_derivative(self):
        fabric=self.so.fabric;c=self.so.c;b=fabric.initial();e=np.linspace(-.15,.15,fabric.size)
        h=1e-6
        numeric=(fabric.energy_force(e+h,b)[0]-fabric.energy_force(e-h,b)[0])/(2*h)
        np.testing.assert_allclose(numeric,fabric.energy_force(e,b)[1],atol=1e-11)
    def test_12_stress_is_derived_from_same_energy(self):
        fabric=self.so.fabric;s=self.write(record(self.so));F=s['F'].copy();F[:]=np.diag([1.1,1/1.1,1])
        L=np.array([[.1,.2,0],[0,-.1,0],[0,0,0]]);h=1e-6
        W,tau,_,_=fabric.constitutive(F,s['b'])
        numeric=(fabric.energy(F+h*(L@F),s['b'])-fabric.energy(F-h*(L@F),s['b']))/(2*h)
        analytic=float(np.sum(self.so.V[:,None,None]*tau*L))
        self.assertLess(abs(numeric-analytic),1e-10)
    def test_13_material_change_affects_stress_and_fields(self):
        a=self.write(record(self.so));r=record(self.so);r['delta_E'][:,0]=.1;b=self.write(r)
        ra=self.so.rhs(.4,a);rb=self.so.rhs(.4,b)
        self.assertGreater(np.linalg.norm(ra['g'][...,:3]-rb['g'][...,:3]),1e-9)
    def test_14_rotation_preserves_readout_and_energy(self):
        s=self.write(record(self.so));q=np.array([[0,-1,0],[1,0,0],[0,0,1]])
        f=q@s['F'];original=self.so.fabric.read(s['F'],s['b']);rot=self.so.fabric.read(f,s['b'])
        self.assertEqual(original[0][1]['origin'],rot[0][1]['origin'])
        self.assertAlmostEqual(self.so.fabric.energy(f,s['b']),self.so.fabric.energy(s['F'],s['b']),places=13)
    def test_15_restructuring_changes_rest_strain_without_reset(self):
        s=self.write(record(self.so));b=s['b'].copy();F=s['F'].copy();F[:]=np.diag([1.15,1/1.15,1])
        for _ in range(100):
            k1=self.so.fabric.constitutive(F,b)[3];k2=self.so.fabric.constitutive(F,b+.005*k1)[3];b+=.0025*(k1+k2)
        self.assertGreater(np.linalg.norm(b-s['b']),1e-4)
        r=self.so.fabric.read(F,b)[0][1];self.assertEqual(r['origin'],0)
    def test_16_positive_dissipation_is_free_energy_loss(self):
        fabric=self.so.fabric;s=self.write(record(self.so));W,tau,heat,bd=fabric.constitutive(s['F'],s['b'])
        h=1e-5;derivative=(fabric.energy(s['F'],s['b']+h*bd)-fabric.energy(s['F'],s['b']-h*bd))/(2*h)
        self.assertLess(abs(derivative+np.dot(self.so.V,heat)),1e-10)
        self.assertGreaterEqual(heat.min(),0)
    def test_17_write_work_matches_stored_energy_and_heat(self):
        E0=self.so.rhs(0,self.s,True)[1]['energy'];s,account=self.so.write_event(self.s,record(self.so))
        E1=self.so.rhs(.4,s,True)[1]['energy']
        self.assertLess(abs(E1-E0-account['work']),1e-12);self.assertGreater(account['heat'],0)
        self.assertGreaterEqual(account['required_budget']+1e-15,account['peak_work'])
        self.assertGreaterEqual(account['peak_work']+1e-15,account['work'])
        np.testing.assert_array_equal(self.s['g'][...,3],s['g'][...,3])
    def test_18_zero_budget_refuses_without_mutation(self):
        before=self.s['b'].copy()
        with self.assertRaises(ValueError):self.so.write_event(self.s,record(self.so),budget=0.)
        np.testing.assert_array_equal(self.s['b'],before)
    def test_19_capacity_failure_does_not_overwrite(self):
        so=Solver(Config(n=12,radial=2,polar=4,azimuth=8,capacity=1));s=so.initial()
        s=so.write_event(s,record(so))[0];before=s['b'].copy()
        with self.assertRaises(CapacityError):so.write_event(s,record(so,event_id=1))
        np.testing.assert_array_equal(s['b'],before)
    def test_20_range_and_missing_material_data_refuse(self):
        r=record(self.so);r['delta_E'][:]=9
        with self.assertRaises(ValueError):self.write(r)
        r=record(self.so);del r['delta_E']
        with self.assertRaises(ValueError):self.write(r)
    def test_21_bounded_probe_noise_preserves_code(self):
        s=self.write(record(self.so));fabric=self.so.fabric
        noise=np.random.default_rng(2402).uniform(-.05,.05,(2,fabric.size))*self.so.c.micro_k*self.so.c.rest_amplitude
        r=fabric.decode_probe(*fabric.probe(s['F'],s['b'],noise))[0][1]
        self.assertEqual(r['origin'],0);self.assertEqual(r['recipient'],1)
    def test_22_ambiguity_and_bit_flip_are_visible_failures(self):
        s=self.write(record(self.so));b=s['b'].copy();b[100]=0
        with self.assertRaises(MemoryReadError):self.so.fabric.read(s['F'],b)
        b=s['b'].copy();b[100]*=-1
        with self.assertRaises(MemoryReadError):self.so.fabric.read(s['F'],b)
    def test_23_feedback_reads_consequences_from_structure(self):
        positive=self.write(record(self.so));negative=self.write(record(self.so,observed=-.6,report=-.5))
        da=self.so.rhs(.4,positive);db=self.so.rhs(.4,negative)
        self.assertGreater(np.linalg.norm(da['relation']-db['relation']),1e-5)
        self.assertGreater(np.linalg.norm(da['responses']-db['responses']),1e-5)
    def test_24_context_and_all_responses_remain_coupled(self):
        s=self.write(record(self.so));base=self.so.rhs(.4,s)
        for k in range(7):
            changed={key:v.copy() for key,v in s.items()};changed['responses'][0,1,k]=.5
            ds=self.so.rhs(.4,changed)
            self.assertGreater(sum(np.linalg.norm(ds[x]-base[x]) for x in ['expression','context','relation','norm','logradius']),1e-5)
    def test_25_partial_interval_order_is_derived_from_material(self):
        s=self.write(record(self.so));event=dict(origin=2,recipient=3,event_id=1,start=.4,end=.8,observed=.4,recipient_report=.4)
        r=self.so.make_event(s,self.s['F'],event);self.assertEqual(r['predecessors'],1)
        event['start']=.2;r=self.so.make_event(s,self.s['F'],event);self.assertEqual(r['predecessors'],0)
    def test_26_shape_without_fabric_is_insufficient(self):
        s=self.write(record(self.so));self.assertEqual(len(self.so.fabric.read(s['F'],self.so.fabric.initial())),0)
        self.assertEqual(len(self.so.fabric.read(s['F'],s['b'])),1)
    def test_27_joint_step_retains_event_and_source(self):
        s=self.write(record(self.so));s['A']=np.array(.1)
        after=self.so.step(.4,s,.0025)
        self.assertEqual(self.so.read_material(after)[0][1]['origin'],0)
        self.assertNotEqual(float(after['g'][...,3].mean()),0)
        self.assertLess(np.max(abs(after['context'].sum(-1)-1)),1e-12)

if __name__=='__main__':
    suite=unittest.defaultTestLoader.loadTestsFromTestCase(StructureTests)
    result=unittest.TextTestRunner(verbosity=2).run(suite)
    summary=dict(run=result.testsRun,passed=result.testsRun-len(result.failures)-len(result.errors),
                 failures=[str(t)+': '+trace for t,trace in result.failures],errors=[str(t)+': '+trace for t,trace in result.errors],
                 scope='Synthetic constitutive and code verification, not physical clay calibration')
    (ROOT/'unit_results.json').write_text(json.dumps(summary,indent=2)+'\n')
    raise SystemExit(not result.wasSuccessful())
