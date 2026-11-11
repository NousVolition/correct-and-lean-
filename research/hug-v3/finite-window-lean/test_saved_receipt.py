"""The evidence gate must refuse stale inputs and mismatched proof coverage."""
import json
from pathlib import Path
import shutil
import tempfile
import unittest

from check_saved_receipt import check,ROOT

class ReceiptRejections(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory()
        self.root=Path(self.temp.name)/'package'
        shutil.copytree(ROOT,self.root,ignore=shutil.ignore_patterns('.lake','*.olean','*.ilean','__pycache__'))
        self.addCleanup(self.temp.cleanup)

    def test_changed_measurement_is_rejected(self):
        p=self.root/'evidence/source-pairs.csv'
        p.write_bytes(p.read_bytes().replace(b'1.1586656915179753e-07',b'2.1586656915179753e-07',1))
        with self.assertRaisesRegex(ValueError,'Stale saved receipt'):
            check(self.root)

    def test_missing_fresh_target_is_rejected(self):
        receipt=json.loads((self.root/'receipt.json').read_text())
        receipt['targets'].pop()
        p=Path(self.temp.name)/'fresh.json';p.write_text(json.dumps(receipt))
        with self.assertRaisesRegex(ValueError,'target list differs'):
            check(self.root,p)

    def test_failed_fresh_compile_is_rejected(self):
        receipt=json.loads((self.root/'receipt.json').read_text())
        receipt['runs'][0]['exit_code']=1
        p=Path(self.temp.name)/'fresh.json';p.write_text(json.dumps(receipt))
        with self.assertRaisesRegex(ValueError,'did not pass'):
            check(self.root,p)

if __name__=='__main__':unittest.main()
