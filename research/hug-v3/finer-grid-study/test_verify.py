"""Refuse identity errors and misleading endpoint/interval conclusions."""
import csv,json,shutil,tempfile,unittest
from pathlib import Path
import verify
class RefusalChecks(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();self.root=Path(self.temp.name)/'study'
        shutil.copytree(verify.ROOT,self.root,ignore=shutil.ignore_patterns('__pycache__','mpl-config'))
    def tearDown(self):self.temp.cleanup()
    def save_rows(self,p,rows):
        with p.open('w',encoding='utf-8',newline='') as f:
            w=csv.DictWriter(f,list(rows[0]));w.writeheader();w.writerows(rows)
    def test_duplicate_pair_with_same_row_count(self):
        p=self.root/'runs/n48_dt0p0005/gaps-primary.csv';rows=verify.read_csv(p)
        fixed=[r for r in rows if r['convention']=='fixed'];fixed[0]['seed']=fixed[1]['seed']
        self.save_rows(p,rows)
        with self.assertRaisesRegex(ValueError,'Duplicate pair identity'):verify.verify_data(self.root)
    def test_interval_failure_labelled_as_pass(self):
        p=self.root/'analysis-summary.json';r=verify.read_json(p);r['spatial_pair_gap_targets_met']=True;p.write_text(json.dumps(r))
        with self.assertRaisesRegex(ValueError,'Summary decision differs'):verify.verify_data(self.root)
    def test_endpoint_count_confused_with_interval(self):
        p=self.root/'analysis-summary.json';r=verify.read_json(p);r['last_spatial']['final_pairs_exceeding_gap_target']=8;p.write_text(json.dumps(r))
        with self.assertRaisesRegex(ValueError,'Summary spatial final_pairs'):verify.verify_data(self.root)
    def test_meter_gap_from_another_reading(self):
        p=self.root/'same-pair-local-meter.csv';rows=verify.read_csv(p);rows[0]['local_gap']=str(float(rows[0]['local_gap'])+.001);self.save_rows(p,rows)
        with self.assertRaisesRegex(ValueError,'Local meter gap join'):verify.verify_data(self.root)
if __name__=='__main__':unittest.main()
