"""Compare the controlled readout repeat with the original fluid continuation."""
import csv,hashlib,json
from pathlib import Path
from decimal import Decimal
import numpy as np
from analyze_retention import validate_rows
ROOT=Path(__file__).resolve().parents[2]
OLD=ROOT/"outputs/pair25-retention/n40_dt0p0005"
NEW=ROOT/"outputs/pair25-retention-cellaware/n40_dt0p0005"
OUT=ROOT/"outputs/pair25-retention"
LEAN=ROOT/"outputs/pair25-retention-lean"
def digest(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def readrows(p):
    with p.open(newline="") as f:return list(csv.DictReader(f))
def main():
    assert json.loads((NEW/"status.json").read_text())["status"]=="complete"
    new=json.loads((NEW/"result.json").read_text())
    old=json.loads((OLD/"result.json").read_text())
    assert new["code_sha256"]==digest(ROOT/"work/pair25-retention/run_retention_cellaware.py")
    comparisons={}
    for file in ["entry-state.npz","exit-state.npz","pair-positions.npz","record-payloads.npz"]:
        with np.load(OLD/file) as a,np.load(NEW/file) as b:
            assert set(a.files)==set(b.files)
            identical={k:a[k].dtype==b[k].dtype and a[k].shape==b[k].shape and a[k].tobytes()==b[k].tobytes() for k in a.files}
            assert all(identical.values()),(file,identical)
            comparisons[file]=identical
    a,b=readrows(OLD/"local-budgets.csv"),readrows(NEW/"local-budgets.csv")
    maximum=validate_rows(b,"n40_dt0p0005")
    assert len(a)==len(b)==204
    for x,y in zip(a,b):
        for k in ["run","time","point","field","entry","current","change"]:assert x[k]==y[k],k
    result=dict(
        method="Heun dense output, split at trilinear interpolation-cell crossings; four Gauss nodes in each piece.",
        original_local_target=1e-6,original_max_residual=old["metrics"]["max_local_budget_residual"],
        corrected_max_residual=maximum,original_target_met=old["criteria"]["local_budget_target_met"],
        corrected_target_met=maximum<=1e-6,
        interpolation_cell_splits=new["metrics"]["interpolation_cell_splits"],
        every_entry_exit_state_array_byte_identical=True,
        all_saved_pair_positions_byte_identical=True,record_payloads_byte_identical=True,
        all_observed_local_values_identical=True,array_comparisons=comparisons,
        interpretation="The original 40-grid local accounting failure disappears when only the integration of the readout is changed. The fluid state, sampled local values and retained records are unchanged.",
        scope="Controlled numerical readout check, not a physical-loss, complete private-inventory or continuum-convergence theorem.",
        input_sha256={str(p.relative_to(ROOT)):digest(p) for p in [
            OLD/"result.json",NEW/"result.json",OLD/"local-budgets.csv",NEW/"local-budgets.csv",
            OLD/"exit-state.npz",NEW/"exit-state.npz",NEW/"pair-positions.npz",NEW/"record-payloads.npz"]})
    (OUT/"cell-aware-check.json").write_text(json.dumps(result,indent=2)+"\n")
    meta=json.loads((LEAN/"data-generation.json").read_text())
    places=meta["decimal_places"];scale=10**places
    def num(v):
        sign,digits,exp=Decimal(v).as_tuple()
        assert exp+places>=0
        return (-1 if sign else 1)*int("".join(map(str,digits)))*10**(exp+places)
    def term(n):return "("+str(n)+")" if n<0 else str(n)
    cols=["entry","current","diffusion_or_conduction","source_or_heat_exchange","advection_interpolation"]
    rows=["⟨"+", ".join(term(num(r[k])) for k in cols)+"⟩" for r in b]
    original=[num(r["current"]) for r in a];corrected=[num(r["current"]) for r in b]
    text="import RecordedRetention\nset_option maxRecDepth 100000\nset_option maxHeartbeats 10000000\nnamespace ReadoutCorrection\nopen CarryingInventory RecordedRetention\n"
    text+="def correctedAccounts : List Account := [\n"+",\n".join(rows)+"\n]\n"
    text+="def originalValues : List Int := ["+",".join(map(term,original))+"]\n"
    text+="def correctedValues : List Int := ["+",".join(map(term,corrected))+"]\n"
    text+="theorem same_recorded_values : originalValues = correctedValues := by decide\n"
    text+="theorem corrected_account_count : correctedAccounts.length = 204 := by decide\n"
    claim="∀ a ∈ correctedAccounts, Within a localTolerance"
    if not result["corrected_target_met"]:claim="¬ ("+claim+")"
    text+="theorem corrected_budget_verdict : "+claim+" := by decide\n"
    text+="end ReadoutCorrection\n"
    (LEAN/"ReadoutCorrection.lean").write_text(text,encoding="utf-8")
    targets=json.loads((LEAN/"targets.json").read_text())
    targets+=["ReadoutCorrection."+n for n in ["same_recorded_values","corrected_account_count","corrected_budget_verdict"]]
    (LEAN/"targets.json").write_text(json.dumps(targets,indent=2)+"\n")
    (LEAN/"CheckAxioms.lean").write_text("import ReadoutCorrection\n"+"\n".join("#print axioms "+n for n in targets)+"\n")
    print(json.dumps({k:v for k,v in result.items() if k not in ["input_sha256","array_comparisons"]},indent=2))
if __name__=="__main__":main()
