"""Refusal checks at the source/certificate boundary; no simulation is run."""
import copy,json,tempfile,unittest
from pathlib import Path
from certificate import HERE,validate
from generate import build

class CertificateRefusalTests(unittest.TestCase):
    def setUp(self):self.receipt=json.loads((HERE/'receipt.json').read_text(encoding='utf-8'))
    def test_missing_theorem_refused(self):
        self.receipt['targets'].pop()
        with self.assertRaises(AssertionError):validate(self.receipt)
    def test_failed_compiler_refused(self):
        self.receipt['runs'][2]['exit_code']=1
        with self.assertRaises(AssertionError):validate(self.receipt)
    def test_added_axiom_refused(self):
        self.receipt['axioms'][self.receipt['targets'][0]]=['sorryAx']
        with self.assertRaises(AssertionError):validate(self.receipt)
    def test_stale_source_fingerprint_refused(self):
        self.receipt['source_data_sha256']['measurements.csv']='0'*64
        with self.assertRaises(AssertionError):validate(self.receipt)
    def test_changed_measurement_refused_before_generation(self):
        with tempfile.TemporaryDirectory() as folder:
            (Path(folder)/'measurements.json').write_text('[]',encoding='utf-8')
            with self.assertRaisesRegex(AssertionError,'Source drift'):build(Path(folder))
    def test_missing_axiom_report_refused(self):
        self.receipt['axioms'].pop(self.receipt['targets'][0])
        with self.assertRaises(AssertionError):validate(self.receipt)

if __name__=='__main__':unittest.main()
