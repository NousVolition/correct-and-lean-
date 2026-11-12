import csv
import unittest
from copy import deepcopy
from pathlib import Path
import numpy as np
from analyze_retention import payload_check, validate_rows, read_csv, OUT

class Refusals(unittest.TestCase):
    def setUp(self):
        with np.load(OUT/"n40_dt0p0005/record-payloads.npz") as z:
            self.ep=z["entry_payloads"];self.ei=z["entry_ids"]
            self.pa=z["payloads"].copy();self.ids=z["ids"].copy()
        self.rows=read_csv(OUT/"n40_dt0p0005/local-budgets.csv")
    def test_same_id_different_content_is_not_retention(self):
        self.pa[-1,0,10]^=1
        result=payload_check(self.ep,self.ei,self.pa,self.ids)
        self.assertFalse(result["all_entry_payloads_retained"])
        self.assertFalse(result["all_payload_crcs_valid"])
    def test_missing_record_is_not_retention(self):
        self.ids[-1,1]=-1
        self.assertFalse(payload_check(self.ep,self.ei,self.pa,self.ids)["all_entry_payloads_retained"])
    def test_duplicate_pair_time_does_not_count_as_coverage(self):
        self.rows[1]=deepcopy(self.rows[0])
        with self.assertRaisesRegex(AssertionError,"Missing, duplicate"):
            validate_rows(self.rows,"n40_dt0p0005")
    def test_omitting_exchange_does_not_close_account(self):
        self.rows[-1]["source_or_heat_exchange"]="0"
        with self.assertRaisesRegex(AssertionError,"Recorded budget residual differs"):
            validate_rows(self.rows,"n40_dt0p0005")

if __name__=="__main__":unittest.main()
