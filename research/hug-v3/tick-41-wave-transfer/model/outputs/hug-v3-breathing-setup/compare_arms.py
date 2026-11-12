"""Join completed prime observations by the same material label, time and write side."""
import csv
from itertools import zip_longest
import json
from pathlib import Path
import tempfile


HERE = Path(__file__).resolve().parent
JOIN = ("coincidence_prime","frame","model_time","side","marker_id")
METRICS = ("x_unwrapped","y_unwrapped","z_unwrapped","vx","vy","vz","C","source_C","theta",
           "structural_fabric_stress_frobenius","viscous_stress_frobenius")


def compare(root):
    target = root/"paired"
    if target.exists(): raise FileExistsError(target)
    with (HERE/"prime-times.csv").open(newline="") as f:
        schedule = list(csv.DictReader(f))
    expected = ((r["prime"],r["comparison_step"],r["model_time"],side,str(i))
                for r in schedule for side in r["read_sides"].split("|") for i in range(801))
    with tempfile.TemporaryDirectory(prefix="pair-",dir=root) as scratch:
        stage=Path(scratch)/"paired";stage.mkdir()
        with (root/"breathing_off/prime-markers.csv").open(newline="") as a, (root/"breathing_on/prime-markers.csv").open(newline="") as b, (stage/"prime-differences.csv").open("w",newline="") as f:
            writer=csv.writer(f,lineterminator="\n")
            writer.writerow((*JOIN,"s0_cube","z_off","z_on",*("delta_"+m for m in METRICS)))
            for key,off,on in zip_longest(expected,csv.DictReader(a),csv.DictReader(b)):
                if (key is None or off is None or on is None or off["arm"]!="off" or on["arm"]!="on" or
                        tuple(off[k] for k in JOIN)!=key or tuple(on[k] for k in JOIN)!=key or
                        off["s0_cube"]!=on["s0_cube"]):
                    raise ValueError(f"Incomplete or mismatched arm at {key}")
                writer.writerow((*key,off["s0_cube"],off["z_unwrapped"],on["z_unwrapped"],
                                 *(float(on[m])-float(off[m]) for m in METRICS)))
        with (root/"breathing_off/prime-states.jsonl").open() as a, (root/"breathing_on/prime-states.jsonl").open() as b, (stage/"prime-memory-and-work.jsonl").open("w",encoding="utf-8") as f:
            planned=((int(r["prime"]),side) for r in schedule for side in r["read_sides"].split("|"))
            for key,left,right in zip_longest(planned,a,b):
                if not key or not left or not right: raise ValueError("Incomplete prime state comparison")
                off,on=json.loads(left),json.loads(right)
                if any((row["prime"],row["side"])!=key for row in (off,on)):
                    raise ValueError("Mismatched memory snapshot")
                f.write(json.dumps(dict(prime=key[0],side=key[1],time=off["time"],off=off,on=on),allow_nan=False)+"\n")
        stage.rename(target)
    return target


if __name__=="__main__":
    print(compare(HERE/"results"))
