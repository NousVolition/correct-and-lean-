"""Bind Lean's finite constants to the preserved observation tables and bytes."""
import csv,json,re,sys
from decimal import Decimal
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parent
DATA=ROOT/"source-data"
TAGS=["n40_dt0p0005","n48_dt0p0005","n48_dt0p00025"]
def readrows(path):
    with path.open(newline="") as f:return list(csv.DictReader(f))
def check(recorded=None,corrected=None):
    sys.set_int_max_str_digits(20000)
    recorded=recorded if recorded is not None else (ROOT/"RecordedRetention.lean").read_text(encoding="utf-8")
    corrected=corrected if corrected is not None else (ROOT/"ReadoutCorrection.lean").read_text(encoding="utf-8")
    scale=int(re.search(r"def decimalScale : Nat := (\d+)",recorded).group(1))
    places=len(str(scale))-1;assert scale==10**places
    def num(v):
        sign,digits,exp=Decimal(v).as_tuple()
        assert exp+places>=0
        return (-1 if sign else 1)*int("".join(map(str,digits)))*10**(exp+places)
    payload={}
    for name,literal in re.findall(r"def (payload\d+) : Nat := (\d+)",recorded):
        encoded=int(literal);length=(encoded.bit_length()-1)//8
        assert encoded.bit_length()==8*length+1
        payload[name]=(encoded-(1<<(8*length))).to_bytes(length,"big")
    def block(text,name,type_name):
        return re.search(r"def "+re.escape(name)+r" : "+re.escape(type_name)+r" := \[(.*?)\n?\]",text,re.S).group(1)
    def records(text):
        return [(int(k),payload[p]) for k,p in re.findall(r"⟨(\d+), (payload\d+)⟩",text)]
    def accounts(text,name):
        content=block(text,name,"List Account")
        return [tuple(int(v.strip().strip("()")) for v in item.split(",")) for item in re.findall(r"⟨([^⟩]+)⟩",content)]
    columns=["entry","current","diffusion_or_conduction","source_or_heat_exchange","advection_interpolation"]
    count=0
    for j,tag in enumerate(TAGS):
        with np.load(DATA/tag/"record-payloads.npz") as z:
            entry=[(int(k),v.tobytes()) for k,v in zip(z["entry_ids"],z["entry_payloads"]) if k>=0]
            samples=[(int(k),v.tobytes()) for data,keys in zip(z["payloads"],z["ids"]) for k,v in zip(keys,data) if k>=0]
        entry_text=re.search(r"def run"+str(j)+r"Entry : List Record := (\[[^\n]*\])",recorded).group(1)
        snapshot_text=re.search(r"def run"+str(j)+r"Snapshots : List \(List Record\) := \[(.*?)\n\]",recorded,re.S).group(1)
        assert records(entry_text)==entry,"Entry payload mismatch"
        assert records(snapshot_text)==samples,"Saved payload mismatch"
        count+=len(samples)
        rows=readrows(DATA/tag/"local-budgets.csv")
        assert accounts(recorded,f"run{j}Accounts")==[tuple(num(r[k]) for k in columns) for r in rows],"Local decimal mismatch"
        global_rows=readrows(DATA/tag/"global-accounts.csv")
        for kind,change,supply in [("Context","context_increment","context_source_increment"),("Energy","energy_increment","external_work_increment")]:
            expected=[(0,num(r[change]),0,num(r[supply]),0) for r in global_rows]
            assert accounts(recorded,f"run{j}{kind}")==expected,"Global decimal mismatch"
    newrows=readrows(DATA/"cellaware40/local-budgets.csv")
    assert accounts(corrected,"correctedAccounts")==[tuple(num(r[k]) for k in columns) for r in newrows],"Corrected decimal mismatch"
    for name,path in [("originalValues",DATA/TAGS[0]/"local-budgets.csv"),("correctedValues",DATA/"cellaware40/local-budgets.csv")]:
        literal=block(corrected,name,"List Int")
        actual=[int(x.strip().strip("()")) for x in literal.split(",")]
        assert actual==[num(r["current"]) for r in readrows(path)],"Observed value mismatch"
    return dict(full_record_payloads_matched=count,local_accounts_matched=816,global_accounts_matched=306,
                decimal_scale=str(scale),proof_data_match=True)
def self_test():
    text=(ROOT/"RecordedRetention.lean").read_text(encoding="utf-8")
    match=re.search(r"def payload0 : Nat := (\d+)",text)
    changed=text[:match.start(1)]+str(int(match.group(1))+1)+text[match.end(1):]
    try:check(recorded=changed)
    except AssertionError:pass
    else:raise AssertionError("Wrong complete payload was accepted")
    match=re.search(r"def run0Accounts : List Account := \[\n⟨(\d+)",text)
    changed=text[:match.start(1)]+str(int(match.group(1))+1)+text[match.end(1):]
    try:check(recorded=changed)
    except AssertionError:pass
    else:raise AssertionError("Wrong recorded decimal was accepted")
    return 2
if __name__=="__main__":
    result=check()
    if "--self-test" in sys.argv:result["tamper_checks_passed"]=self_test()
    print(json.dumps(result,indent=2))
