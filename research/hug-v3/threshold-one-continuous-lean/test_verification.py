import subprocess,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
from verify import validate_axioms,run_logged_process,scope_modules,EXPERIMENTAL_MODULES

class VerificationBoundary(unittest.TestCase):
    def test_foundation_scope_excludes_unverified_component_pilot(self):
        self.assertTrue(EXPERIMENTAL_MODULES.isdisjoint(scope_modules('foundations')))
        self.assertTrue(EXPERIMENTAL_MODULES.issubset(scope_modules('all')))
    def test_actual_empty_axiom_format(self):
        self.assertEqual(validate_axioms("'t' does not depend on any axioms",['t']),{'t':[]})
    def test_standard_real_axioms(self):
        self.assertEqual(validate_axioms("'t' depends on axioms: [propext, Classical.choice, Quot.sound]",['t'])['t'],
            ['propext','Classical.choice','Quot.sound'])
    def test_reject_missing_theorem(self):
        with self.assertRaises(ValueError):validate_axioms("'t' depends on axioms: []",['t','missing'])
    def test_reject_untrusted_computation(self):
        with self.assertRaises(ValueError):validate_axioms("'t' depends on axioms: [Lean.ofReduceBool]",['t'])
    def test_reject_sorry(self):
        with self.assertRaises(ValueError):validate_axioms("'t' depends on axioms: [sorryAx]",['t'])
    def test_timeout_preserves_diagnostics_and_raises(self):
        def time_out(cmd,**kwargs):
            raise subprocess.TimeoutExpired(cmd,1,output=b'partial compiler diagnostic\n',
                stderr=b'partial stderr diagnostic\n')
        with tempfile.TemporaryDirectory() as directory:
            log=Path(directory)/'failed.log'
            with patch('verify.subprocess.run',side_effect=time_out):
                with self.assertRaises(subprocess.TimeoutExpired):
                    run_logged_process(['lean','example.lean'],directory,log,timeout=1)
            self.assertIn('partial compiler diagnostic',log.read_text())
            self.assertIn('partial stderr diagnostic',log.read_text())
            self.assertIn('no successful verification receipt',log.read_text())

if __name__=='__main__':unittest.main()
