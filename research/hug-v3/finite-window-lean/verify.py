"""Regenerate exact decimal checks and compile with the Lean kernel.

Inputs are preserved under evidence/. Decimal-to-integer conversion is exact;
all values share the positive denominator declared as decimalScale in Lean.
The Lean proofs use decide (kernel reduction), never native_decide.
"""
import argparse
import csv
from datetime import datetime, timezone
from decimal import Decimal
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess

HERE = Path(__file__).resolve().parent
EVIDENCE = HERE/'evidence'
EVIDENCE.mkdir(exist_ok=True)
parser = argparse.ArgumentParser()
parser.add_argument('--lean', default=shutil.which('lean'))
parser.add_argument('--pairs', type=Path)
parser.add_argument('--statistics', type=Path)
args=parser.parse_args()
if not args.lean:
    parser.error('Provide --lean or put the pinned Lean version on PATH.')

for source,name in [(args.pairs,'source-pairs.csv'),(args.statistics,'source-statistics.csv')]:
    if source is not None:
        destination=EVIDENCE/name
        if destination.exists() and destination.read_bytes()!=source.read_bytes():
            raise RuntimeError(f'Refusing to overwrite different preserved input: {name}')
        destination.write_bytes(source.read_bytes())

def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def csv_rows(path):
    with path.open(encoding='utf-8-sig',newline='') as stream:
        return list(csv.DictReader(stream))

pairs=csv_rows(EVIDENCE/'source-pairs.csv')
stats=csv_rows(EVIDENCE/'source-statistics.csv')
index={(int(r['frame']),int(r['seed'])):r for r in pairs}
stat_index={int(r['frame']):r for r in stats}
assert len(pairs)==len(index)==1275
assert set(index)=={(f,s) for f in range(550,601) for s in range(25)}
assert len(stats)==len(stat_index)==51 and set(stat_index)==set(range(550,601))
time_residuals=[abs(Decimal(r['time'])-Decimal(r['frame'])*Decimal('.002')) for r in pairs]
assert max(time_residuals)<=Decimal('1e-15')
assert all(Decimal(r['model_time'])==Decimal(r['frame'])*Decimal('.002') for r in stats)

pair_fields=['local_nearest_distance','extended_nearest_distance']
stat_fields=[f'{prefix}_{kind}' for prefix in ['local_0_375','extended_0_75']
             for kind in ['minimum','median','maximum']]
values=[Decimal(r[k]) for r in pairs for k in pair_fields]
values += [Decimal(r[k]) for r in stats for k in stat_fields]
assert all(x.is_finite() and x>=0 for x in values)
digits=max(max(0,-x.as_tuple().exponent) for x in values)

def integer(text):
    # Work from decimal tuples, avoiding Decimal's arithmetic context rounding.
    d=Decimal(text)
    sign,coefficient,exponent=d.as_tuple()
    assert not sign and exponent+digits>=0
    n=int(''.join(map(str,coefficient))) * 10**(exponent+digits)
    assert Decimal(n).scaleb(-digits)==d
    return n

def seq(vals): return '['+', '.join(str(x) for x in vals)+']'
lines=['''import WindowGap
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000
namespace RecordedWindows
/- Exact decimal numerators from the preserved CSV files. All distances have
the same positive denominator decimalScale. These are recorded data values,
not a proof that a numerical solver produced a physical fluid trajectory. -/
structure Row where
  frame : Nat
  shortGaps : List Nat
  longGaps : List Nat
  shortMin : Nat
  shortMedian : Nat
  shortMax : Nat
  longMin : Nat
  longMedian : Nat
  longMax : Nat
''',f'def decimalScale : Nat := 10 ^ {digits}\n']
for frame in range(550,601):
    short=[integer(index[frame,s]['local_nearest_distance']) for s in range(25)]
    long=[integer(index[frame,s]['extended_nearest_distance']) for s in range(25)]
    metrics=[integer(stat_index[frame][k]) for k in stat_fields]
    lines.append(f'def frame{frame} : Row :=\n  ⟨{frame},\n    {seq(short)},\n    {seq(long)},\n    '+', '.join(map(str,metrics))+'⟩\n')
lines += ['def rows : List Row := '+seq(f'frame{i}' for i in range(550,601))+'\n', '''
/-- For 25 values, at least 13 on either side verifies the middle value.
Min/max are checked as bounds and as values attained in the record. -/
def summaryChecks (values : List Nat) (lo middle hi : Nat) : Bool :=
  values.length == 25 &&
  values.all (fun x => decide (lo ≤ x)) && values.any (fun x => x == lo) &&
  values.all (fun x => decide (x ≤ hi)) && values.any (fun x => x == hi) &&
  decide (13 ≤ (values.filter (fun x => decide (x ≤ middle))).length) &&
  decide (13 ≤ (values.filter (fun x => decide (middle ≤ x))).length)

def extentCheck (r : Row) : Bool :=
  r.shortGaps.length == 25 && r.longGaps.length == 25 &&
  (r.shortGaps.zip r.longGaps).all (fun pair => decide (pair.2 ≤ pair.1))

def bothSummariesCheck (r : Row) : Bool :=
  summaryChecks r.shortGaps r.shortMin r.shortMedian r.shortMax &&
  summaryChecks r.longGaps r.longMin r.longMedian r.longMax

theorem decimal_scale_is_positive : 0 < decimalScale := by decide

theorem complete_frame_sequence : rows.map Row.frame = List.range' 550 51 := by decide

theorem all_1275_recorded_extents_pass : rows.all extentCheck = true := by decide

theorem all_51_medians_and_ranges_pass : rows.all bothSummariesCheck = true := by decide

theorem gap_is_already_positive_at_1_102 :
    0 < frame551.longMin ∧ frame551.frame = 551 := by decide

theorem final_recorded_median_is_smaller_with_longer_trace :
    frame600.longMedian < frame600.shortMedian := by decide

theorem final_pair_20_gap_is_smaller_with_longer_trace :
    (frame600.longGaps.drop 20).headD 0 < (frame600.shortGaps.drop 20).headD 0 := by decide

end RecordedWindows
''']
(HERE/'RecordedWindows.lean').write_text('\n'.join(lines),encoding='utf-8',newline='\n')

targets=[]
for module in ['WindowGap','RecordedWindows']:
    source=(HERE/f'{module}.lean').read_text(encoding='utf-8')
    # Do not allow proof holes or a native evaluator shortcut in source code.
    code=re.sub(r'/\-.*?\-/','',source,flags=re.S)
    code=re.sub(r'--[^\n]*','',code)
    assert not re.search(r'\b(sorry|admit|axiom|native_decide|unsafe)\b',code)
    targets += [module+'.'+n for n in re.findall(r'^theorem\s+(\w+)',source,re.M)]
(HERE/'CheckAxioms.lean').write_text('import WindowGap\nimport RecordedWindows\n'+'\n'.join('#print axioms '+n for n in targets)+'\n',encoding='utf-8',newline='\n')

env=dict(os.environ,LEAN_PATH=str(HERE))
lean=Path(args.lean).resolve()
version=subprocess.check_output([str(lean),'--version'],text=True,encoding='utf-8').strip()
assert 'version 4.34.0-rc2' in version,version
inputs={p.name:sha(p) for p in [HERE/'WindowGap.lean',HERE/'RecordedWindows.lean',HERE/'CheckAxioms.lean',
                              HERE/'lean-toolchain',HERE/'lakefile.toml',HERE/'verify.py']}
inputs.update({'evidence/'+p.name:sha(p) for p in EVIDENCE.glob('source-*.csv')})
started=datetime.now(timezone.utc).isoformat()
runs=[]
for module in ['WindowGap','RecordedWindows','CheckAxioms']:
    command=[str(lean),'-DwarningAsError=true']
    if module!='CheckAxioms':command += ['-o',module+'.olean']
    command += [module+'.lean']
    result=subprocess.run(command,cwd=HERE,env=env,capture_output=True,text=True,encoding='utf-8',timeout=180)
    (EVIDENCE/(module+'.log')).write_text(result.stdout+result.stderr,encoding='utf-8')
    runs.append({'module':module,'exit_code':result.returncode,'command':command})
    print(f'{module}: exit {result.returncode}',flush=True)
    if result.returncode:
        print(result.stdout+result.stderr,flush=True)
        raise SystemExit(result.returncode)

axioms_text=(EVIDENCE/'CheckAxioms.log').read_text(encoding='utf-8')
axioms={}
for name in re.findall(r"'([^']+)' does not depend on any axioms",axioms_text):axioms[name]=[]
for name,used in re.findall(r"'([^']+)' depends on axioms:\s*\[([^\]]*)\]",axioms_text):
    axioms[name]=[x.strip() for x in used.split(',') if x.strip()]
assert set(axioms)==set(targets),(set(targets)-set(axioms))
assert all(not used for used in axioms.values()),axioms
assert all(sha(HERE/name)==value for name,value in inputs.items())
receipt={'status':'PASS','started_at_utc':started,'finished_at_utc':datetime.now(timezone.utc).isoformat(),
         'lean_version':version,'lean_binary_sha256':sha(lean),'inputs_sha256':inputs,
         'theorem_count':len(targets),'targets':targets,'axioms':axioms,'runs':runs,
         'decimal_places':digits,'frames':51,'pairs_per_frame':25,'pairwise_comparisons':1275,
         'source_time_vs_nominal_frame_max_decimal_residual':str(max(time_residuals)),
         'time_mapping_scope':'Frames map to nominal time frame * 0.002; the source float time strings have rounding residuals. Distance strings are checked as exact decimals.',
         'source_inputs_unchanged_during_check':True,'native_decide_used':False,
         'scope':'Local Lean kernel proofs of nested-window rules and a finite sample counterexample, plus exact decimal checks of archived records.',
         'limits':['No fluid simulation or line integration was rerun.',
                   'No formal bridge from the simulator and its floating-point operations to these recorded decimals.',
                   'No proof of global line closure, disconnection, reconnection, or the supplied image-generation history.',
                   'The nearest-point and infimum theorems explicitly assume the respective minima/infima exist.',
                   'Counterexample is a sample-window construction, not a continuous fluid trajectory.',
                   'Local verification; not a GitHub Actions receipt or published Lean result.']}
(HERE/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'status':'PASS','theorems':len(targets),'axioms':sorted({a for used in axioms.values() for a in used}),
                  'recorded_pair_comparisons':1275,'frame_summaries':51,'decimal_places':digits},indent=2))
