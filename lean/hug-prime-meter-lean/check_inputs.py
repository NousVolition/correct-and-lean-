"""Bind the measured binary64 inputs to the finite Lean certificate. Python standard library only."""
import argparse
import csv
from fractions import Fraction
import hashlib
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parent
FILES = {
    "evidence/off.json": "fd6c7b6fd112c4c5d9c1c07f066db07c4c1ea59d43d1044bcc63e70934813c11",
    "evidence/on.json": "d1805fff1e3db27ad4319fb985d79bc8b0a054da800b057accfe0beaa5fbe35d",
    "evidence/prime-meter.csv": "62d94cad5b16e340a19fb307ef8bf0d13a176429b353a74172f76c306a6ce4bc",
}
WORK_KEYS = ("source_work", "squeeze_work", "breathing_work", "write_work")
COST_KEYS = ("work", "heat", "stored")
PHASES = {"at": "atTick", "before_write": "beforeWrite", "after_write": "afterWrite",
          "before_fourth_write": "beforeFourth", "after_fourth_write": "afterFourth"}


def atoms(value):
    """The CSV/receipt strings round-trip to the simulation's binary64 values."""
    x = float(value)
    if not math.isfinite(x):
        raise ValueError("Nonfinite input")
    n, d = x.as_integer_ratio()
    if (2**77) % d:
        raise ValueError("Input requires finer precision than 2^-77")
    return str(n * ((2**77) // d))


def tenths(value):
    t = Fraction(str(value)) * 10
    if t.denominator != 1:
        raise ValueError(f"Not a meter time: {value}")
    return str(t.numerator)


def record(fields):
    return "⟨" + ", ".join(fields).replace(", \n", ",\n") + "⟩"


def ledger(obj, prefix=""):
    last = ("computed_energy", "signed_hug_energy_residual") if prefix else ("energy", "energy_residual")
    return record(atoms(obj[prefix+k]) for k in (*WORK_KEYS, *last))


def tick_row(row):
    raw_cost = [row["fourth_write_"+k] for k in COST_KEYS]
    if any(raw_cost) != all(raw_cost):
        raise ValueError("Partial fourth-write account")
    cost = "some " + record(atoms(x) for x in raw_cost) if all(raw_cost) else "none"
    header = [tenths(row["model_time"]), row["prime"], row["mentor_tick"], row["traveler_tick"],
              {"saved meter": "false", "extended meter": "true"}[row["label_source"]],
              "."+PHASES[row["phase"]], row["three_write_count"], row["four_write_count"], atoms(row["starting_energy"])]
    return record([*header, "\n     "+ledger(row,"three_"), "\n     "+ledger(row,"four_"),
                   atoms(row["three_expected_energy"]), atoms(row["four_expected_energy"]),
                   atoms(row["four_minus_three_signed_residual"]), cost])


def receipt(obj, arm):
    event = obj["added_event"]
    pre = obj["figure_prewrite_1_6"]
    post = obj["postwrite_samples"][0]
    three = obj["figure_endpoint_receipt"]
    four = obj["postwrite_samples"][-1]
    if not (obj["arm"] == arm and pre["time"] == post["time"] == event["end"] and three["time"] == four["time"]):
        raise ValueError("Receipt labels do not match")
    fields = [atoms(obj["reference_initial_energy"]), str(event["event_id"]), str(obj["write_account"]["slot"]),
              tenths(event["start"]), tenths(event["end"]), tenths(four["time"]),
              record(atoms(obj["write_account"][k]) for k in COST_KEYS)]
    return record(fields + ["\n     "+ledger(r) for r in (pre, post, three, four)])


def generate():
    for name, expected in FILES.items():
        if hashlib.sha256((ROOT/name).read_bytes()).hexdigest() != expected:
            raise ValueError(f"Original input hash mismatch: {name}")
    with (ROOT/"evidence/prime-meter.csv").open(encoding="utf-8", newline="") as f:
        rows = list(csv.DictReader(f))
    if len(rows) != 82 or {r["arm"] for r in rows} != {"off", "on"}:
        raise ValueError("Unexpected number of input rows or arms")
    lines = ["import PrimeMeter.Types", "", "/-! Exact binary64 values in units of 2⁻⁷⁷.",
             "Generated from the two authenticated receipts and the paired meter CSV. -/", "",
             "namespace HugPrimeMeter.Recorded", ""]
    for arm in ("off","on"):
        r = json.loads((ROOT/f"evidence/{arm}.json").read_bytes())
        lines += [f"def {arm}Receipt : Receipt :=", "  "+receipt(r, arm), "",
                  f"def {arm}Rows : List TickRow := ["]
        body = [tick_row(row) for row in rows if row["arm"] == arm]
        lines += ["  " + ",\n  ".join(body) + "]", ""]
    lines += ["end HugPrimeMeter.Recorded", ""]
    return "\n".join(lines).encode("utf8")


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--write", action="store_true", help="Regenerate the Lean data file")
    args = p.parse_args()
    data = generate()
    target = ROOT/"PrimeMeter/Recorded.lean"
    if args.write:
        target.write_bytes(data)
    elif target.read_bytes() != data:
        raise SystemExit("Lean literals differ from the measured inputs")
    print("PASS: verified all three source-data hashes, both receipts, and 82 meter rows.")
