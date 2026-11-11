"""Refusal checks independent of the publication hash gate."""
from pathlib import Path
import csv
import json
import shutil
import tempfile
import unittest
import verify

class RecordRefusals(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory()
        self.root=Path(self.temp.name)/'records'
        shutil.copytree(verify.ROOT,self.root,ignore=shutil.ignore_patterns('__pycache__','mpl-config'))

    def tearDown(self):
        self.temp.cleanup()

    def write_csv(self,p,rows):
        with p.open('w',encoding='utf-8',newline='') as f:
            writer=csv.DictWriter(f,fieldnames=list(rows[0]));writer.writeheader();writer.writerows(rows)

    def test_duplicate_identity_with_same_row_count(self):
        p=self.root/'runs/n32_dt0p0005/gaps-primary.csv'
        rows=verify.read_csv(p)
        rows[0]['seed']=rows[1]['seed']
        self.write_csv(p,rows)
        with self.assertRaisesRegex(ValueError,'Duplicate pair identity'):
            verify.verify_data(self.root)

    def test_edited_comparison_number(self):
        p=self.root/'gap-comparisons.csv'
        rows=verify.read_csv(p);rows[0]['max_pair_gap_change']='0'
        self.write_csv(p,rows)
        with self.assertRaisesRegex(ValueError,'maximum'):
            verify.verify_data(self.root)

    def test_failure_relabelled_as_success(self):
        p=self.root/'analysis-summary.json';data=json.loads(p.read_text())
        data['conventions']['fixed']['spatial_gap_size_targets_met']=True
        p.write_text(json.dumps(data),encoding='utf-8')
        with self.assertRaisesRegex(ValueError,'Analysis summary differs'):
            verify.verify_data(self.root)

if __name__=='__main__':
    unittest.main()
