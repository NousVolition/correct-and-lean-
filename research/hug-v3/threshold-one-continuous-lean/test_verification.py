import unittest
from verify import validate_axioms

class VerificationBoundary(unittest.TestCase):
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

if __name__=='__main__':unittest.main()
