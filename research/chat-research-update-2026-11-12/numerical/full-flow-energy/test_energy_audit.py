import unittest
from energy_audit import *

class EnergyTests(unittest.TestCase):
    def test_energy_matches_original_diagnostic_and_rhs_identity(self):
        for arm in ('journal','control'):
            run=AuditRun(arm,1);run.step()
            _,stats,_=run.solver.rhs(run.t,run.state,True)
            self.assertAlmostEqual(stats['energy'],run.meter.energy(run.state)['total'],places=14)
            self.assertLess(run.meter.max_stage_error,1e-13)
            self.assertLess(run.meter.max_heat_error,1e-13)
            self.assertLess(run.meter.max_extraction_error,1e-13)
            self.assertLess(run.max_write_error,1e-13)
            self.assertLess(run.max_thermal_jump_error,1e-13)

    def test_initial_difference_and_time_zero_write_are_included(self):
        on=AuditRun('journal',1);off=AuditRun('control',1)
        self.assertGreater(on.initial['total']-off.initial['total'],0)
        self.assertGreater(on.rows[-1]['work'],0)
        self.assertEqual(off.rows[-1]['work'],0)
        self.assertLess(abs(on.rows[-1]['total_residual']),1e-13)
        self.assertEqual(on.rows[0]['total_change'],0)

    def test_refinement_does_not_change_journal_write_schedule(self):
        a=AuditRun('journal',1);b=AuditRun('journal',2)
        a.step();b.step()
        self.assertEqual([w['time'] for w in a.writes],[w['time'] for w in b.writes])
        self.assertEqual(a.state['b'].shape,b.state['b'].shape)
        self.assertEqual(len(b.solver.fabric.read_bundle(b.state['F'],b.state['b'])[1]['times']),2)

if __name__=='__main__':unittest.main(verbosity=2)
