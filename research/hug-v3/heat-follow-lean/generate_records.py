"""Exact decimal certificates for saved heat-source accounts, not a fluid proof."""
import csv,hashlib,json,re,shutil
from decimal import Decimal
from pathlib import Path
LEAN=Path(__file__).resolve().parent;DATA=LEAN/'source-data';OUT=LEAN.parent/'heat-follow'
TAGS=['n16_dt0p002','n16_dt0p001'];NAMES=['initial_warmth','net_viscous_heat','structural_release','write_0','write_1','write_2']
COLS=['thermal_mean']+[n+'_mean' for n in NAMES]+['net_viscous_heat_expected_mean','structural_release_expected_mean','continuous_ledger','write_total']
SPREAD=['birth_effective_volume','final_effective_volume','birth_peak','final_peak','birth_outside025_share','final_outside025_share','birth_negative_to_net_ratio','final_negative_to_net_ratio']
COMPARE=['relative_deposited_heat_change','normalized_field_L1_max_at_common_snapshots','outside025_share_max_change']
def load(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def readrows(p):
    with p.open(newline='',encoding='utf-8') as f:return list(csv.DictReader(f))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
CHECK_ONLY=False
def write(p,s):
    if CHECK_ONLY:assert p.read_text(encoding='utf-8')==s,'Transcription mismatch: '+p.name
    else:p.parent.mkdir(parents=True,exist_ok=True);p.write_text(s,encoding='utf-8')
def generate(copy_sources=True,check_only=False):
    global CHECK_ONLY
    CHECK_ONLY=check_only
    DATA.mkdir(parents=True,exist_ok=True)
    if copy_sources:
        for tag in TAGS:
            for f in ['history.csv','receipt.json']:shutil.copyfile(OUT/tag/f,DATA/(tag+'-'+f))
        shutil.copyfile(OUT/'analysis.json',DATA/'analysis.json')
    analysis=load(DATA/'analysis.json');tables=[readrows(DATA/(tag+'-history.csv')) for tag in TAGS]
    receipts=[load(DATA/(tag+'-receipt.json')) for tag in TAGS]
    values=[r[k] for rows in tables for r in rows for k in COLS]
    values += [str(w[k]) for run in analysis['runs'] for w in run['writes'] for k in SPREAD+['deposited_heat']]
    values += [str(v[k]) for v in analysis['time_step_comparison'] for k in COMPARE]
    values += [str(r[k]) for r in receipts for k in ['max_field_reconstruction','max_rhs_reconstruction','max_budget_residual','max_tag_mean_error']]
    places=max(30,max(-Decimal(v).as_tuple().exponent for v in values));scale=10**places
    def num(value):
        sign,digits,e=Decimal(str(value)).as_tuple();assert places+e>=0
        n=(-1 if sign else 1)*int(''.join(map(str,digits)))*10**(places+e)
        return str(n) if n>=0 else '('+str(n)+')'
    globals_=10**(places-12);tags_=10**(places-14)
    targets=['HeatAccounting.'+n for n in re.findall(r'^theorem (\w+)',(LEAN/'HeatAccounting.lean').read_text(encoding='utf-8'),re.M)]
    text=['import HeatAccounting\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\nnamespace RecordedHeat\n',f'def decimalScale : Nat := {scale}\ndef globalTolerance : Nat := {globals_}\ndef tagTolerance : Nat := {tags_}\n',
      'structure Row where\n  step : Nat\n  phase : Nat\n  thermal : Int\n  initial : Int\n  viscous : Int\n  released : Int\n  w0 : Int\n  w1 : Int\n  w2 : Int\n  integratedViscous : Int\n  integratedRelease : Int\n  continuousLedger : Int\n  writeLedger : Int\n  deriving DecidableEq, Repr\n',
      'def expectedWrite (r : Row) (birth : Nat) (amount : Int) : Int :=\n  if birth < r.step ∨ (birth = r.step ∧ r.phase = 2) then amount else 0\n',
      'def Good (initial h0 h1 h2 : Int) (f0 f1 f2 : Nat) (r : Row) : Prop :=\n  (r.thermal-(r.initial+r.viscous+r.released+r.w0+r.w1+r.w2)).natAbs ≤ globalTolerance ∧\n  (r.thermal-(initial+r.continuousLedger+r.writeLedger)).natAbs ≤ globalTolerance ∧\n  (r.initial-initial).natAbs ≤ tagTolerance ∧\n  (r.viscous-r.integratedViscous).natAbs ≤ tagTolerance ∧\n  (r.released-r.integratedRelease).natAbs ≤ tagTolerance ∧\n  (r.continuousLedger-r.integratedViscous-r.integratedRelease).natAbs ≤ tagTolerance ∧\n  (r.w0-expectedWrite r f0 h0).natAbs ≤ tagTolerance ∧\n  (r.w1-expectedWrite r f1 h1).natAbs ≤ tagTolerance ∧\n  (r.w2-expectedWrite r f2 h2).natAbs ≤ tagTolerance ∧\n  (r.writeLedger-expectedWrite r f0 h0-expectedWrite r f1 h1-expectedWrite r f2 h2).natAbs ≤ tagTolerance\n',
      'instance (initial h0 h1 h2 : Int) (f0 f1 f2 : Nat) (r : Row) : Decidable (Good initial h0 h1 h2 f0 f1 f2 r) := by unfold Good; infer_instance\n']
    def theorem(name,statement):targets.append('RecordedHeat.'+name);text.append(f'theorem {name} : {statement} := by decide\n')
    for j,(rows,receipt,summary) in enumerate(zip(tables,receipts,analysis['runs'])):
        prefix=f'run{j}';dt=Decimal(str(receipt['actual_step']));initial=num(rows[0]['thermal_mean']);heats=[num(w['account']['heat']) for w in receipt['writes']];births=[round(t/float(dt)) for t in [.4,.8,1.2]]
        text.append(f'def {prefix}Initial : Int := {initial}\n')
        for i,h in enumerate(heats):text.append(f'def {prefix}H{i} : Int := {h}\n')
        blocknames=[]
        for start in range(0,len(rows),100):
            name=f'{prefix}Rows{start//100}';blocknames.append(name);data=[]
            for r in rows[start:start+100]:
                step=int(Decimal(r['time'])/dt);phase={'before_write':0,'at':1,'after_write':2}[r['side']]
                data.append('⟨'+', '.join([str(step),str(phase)]+[num(r[k]) for k in COLS])+'⟩')
            text.append(f'def {name} : List Row := [\n'+',\n'.join(data)+'\n]\n')
            theorem(f'{name}_accounts',f'∀ r ∈ {name}, Good {prefix}Initial {prefix}H0 {prefix}H1 {prefix}H2 '+ ' '.join(map(str,births))+' r')
        text.append(f'def {prefix}Rows : List Row := ['+', '.join(blocknames)+'].flatten\n')
        theorem(prefix+'_coverage',f'({prefix}Rows.filter (fun r => r.phase != 0)).map Row.step = List.range {round(1.6/float(dt))+1} ∧ ({prefix}Rows.filter (fun r => r.phase == 0)).map Row.step = {births} ∧ ({prefix}Rows.filter (fun r => r.phase == 2)).map Row.step = {births}')
        a,b,c=[prefix+'H'+str(i) for i in range(3)]
        theorem(prefix+'_three_writes_accumulate',f'0 < {a} ∧ {a} < {a}+{b} ∧ {a}+{b} < {a}+{b}+{c}')
        for i,w in enumerate(summary['writes']):
            vals=[num(w[k]) for k in SPREAD];name=f'{prefix}Write{i}Spread'
            text.append(f'def {name} : List Int := ['+', '.join(vals)+']\n')
            theorem(name+'_recorded_spread',f'({vals[1]} : Int) > {vals[0]} ∧ ({vals[3]} : Int) < {vals[2]} ∧ ({vals[5]} : Int) > {vals[4]}')
            theorem(name+'_signed_ripples_retained',f'(0 : Int) < {vals[6]} ∧ ({vals[6]} : Int) < {num(".025")} ∧ (0 : Int) < {vals[7]} ∧ ({vals[7]} : Int) < {num(".002")}')
        final=rows[-1];increase=f'(({num(final["thermal_mean"])} : Int)-{prefix}Initial)';writes=f'({a}+{b}+{c})'
        theorem(prefix+'_writes_are_20p7_percent_of_increase',f'2065*{increase} ≤ 10000*{writes} ∧ 10000*{writes} < 2075*{increase}')
        limits=[num(receipt[k]) for k in ['max_field_reconstruction','max_rhs_reconstruction','max_budget_residual','max_tag_mean_error']]
        theorem(prefix+'_reported_solver_bounds',f'({limits[0]} : Int).natAbs ≤ globalTolerance ∧ ({limits[1]} : Int).natAbs ≤ {num("1e-11")} ∧ ({limits[2]} : Int).natAbs ≤ globalTolerance ∧ ({limits[3]} : Int).natAbs ≤ tagTolerance')
    for i,c in enumerate(analysis['time_step_comparison']):
        theorem(f'write{i}_time_step_heat_checks',f'100*(run0H{i}-run1H{i}).natAbs ≤ run0H{i}.natAbs ∧ ({num(c[COMPARE[1]])} : Int) ≤ {num(".01")} ∧ ({num(c[COMPARE[2]])} : Int) ≤ {num(".005")}')
        theorem(f'write{i}_recorded_checksums_differ',f'({c["both_crc"][0]} : Nat) ≠ {c["both_crc"][1]}')
    text.append('end RecordedHeat\n');code='\n'.join(text)
    write(LEAN/'RecordedHeat.lean',code);write(LEAN/'CheckAxioms.lean','import RecordedHeat\n'+'\n'.join('#print axioms '+n for n in targets)+'\n');write(LEAN/'targets.json',json.dumps(targets,indent=2)+'\n')
    generation={'decimal_places':places,'decimal_scale':str(scale),'target_count':len(targets),'dense_rows':sum(map(len,tables)),'source_columns':COLS,'phase_encoding':{'before_write':0,'at':1,'after_write':2},'rows_per_proof_block':100,'global_tolerance':'1e-12','tag_tolerance':'1e-14','scope':'Exact decimal integers from every saved row and the independently recounted scalar diagnostics. No proof of the simulation, source transcription, positive heat parcels, or grid convergence.'}
    write(LEAN/'generation.json',json.dumps(generation,indent=2)+'\n');print(json.dumps({'targets':len(targets),'dense_rows':sum(map(len,tables)),'decimal_places':places,'Lean_bytes':len(code.encode())}))
if __name__=='__main__':
    import argparse
    parser=argparse.ArgumentParser();parser.add_argument('--check',action='store_true');args=parser.parse_args()
    generate(copy_sources=False,check_only=args.check)
