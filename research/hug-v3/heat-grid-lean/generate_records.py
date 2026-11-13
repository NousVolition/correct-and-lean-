"""Exact-decimal global accounts, grid criteria, and complete recorded-word comparisons."""
import argparse,csv,hashlib,json,re,shutil,struct
from decimal import Decimal,ROUND_HALF_UP,localcontext
from pathlib import Path
PKG=Path(__file__).resolve().parent;DATA=PKG/'source-data';STUDY=PKG.parent/'heat-grid'
TAGS=['n16_dt0p002','n24_dt0p002','n32_dt0p002','n40_dt0p002','n40_dt0p001']
NAMES=['initial_warmth','net_viscous_heat','structural_release','write_0','write_1','write_2']
COLS=['thermal_mean']+[n+'_mean' for n in NAMES]+['net_viscous_heat_expected_mean','structural_release_expected_mean','continuous_ledger','write_total']
SPREAD=['birth_effective_volume','final_effective_volume','birth_peak','final_peak','birth_outside025_share','final_outside025_share','birth_negative_to_net_ratio','final_negative_to_net_ratio']
LIMITS={'relative_deposited_heat_change':'.01','normalized_field_L1':'.01','outside_share_difference':'.005','effective_volume_relative_difference':'.01','peak_relative_difference':'.01'}
def load(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def rows(p):
 with p.open(newline='',encoding='utf-8') as f:return list(csv.DictReader(f))
def numbers(v):
 if isinstance(v,bool):return []
 if isinstance(v,(int,float)):return [str(v)]
 if isinstance(v,dict):return sum((numbers(x) for x in v.values()),[])
 if isinstance(v,list):return sum((numbers(x) for x in v),[])
 return []
def prepare():
 DATA.mkdir(exist_ok=True)
 analysis=load(STUDY/'analysis.json');assert analysis['status']=='completed' and len(analysis['runs'])==5
 shutil.copyfile(STUDY/'analysis.json',DATA/'analysis.json')
 for tag in TAGS:
  receipt=load(STUDY/tag/'receipt.json');assert receipt['status']=='completed'
  for filename in ['history.csv','receipt.json']:shutil.copyfile(STUDY/tag/filename,DATA/(tag+'-'+filename))
  for i in range(3):shutil.copyfile(STUDY/tag/'records'/f'write-{i}.bin',DATA/f'{tag}-write-{i}.bin')
def generate(check=False):
 analysis=load(DATA/'analysis.json');tables=[rows(DATA/(t+'-history.csv')) for t in TAGS];receipts=[load(DATA/(t+'-receipt.json')) for t in TAGS]
 for tag,r in zip(TAGS,receipts):
  assert sha(DATA/(tag+'-history.csv'))==r['files_sha256']['history.csv']
  for i in range(3):assert sha(DATA/f'{tag}-write-{i}.bin')==r['files_sha256'][f'records/write-{i}.bin']
 values=[r[k] for table in tables for r in table for k in COLS]+numbers(analysis)+numbers(receipts)
 places=max(34,max(-Decimal(v).as_tuple().exponent for v in values));scale=10**places
 def num(v):
  sign,digits,e=Decimal(str(v)).as_tuple();assert places+e>=0
  n=(-1 if sign else 1)*int(''.join(map(str,digits)))*10**(places+e)
  return str(n) if n>=0 else '('+str(n)+')'
 def relation(left,right,kind='le'):
  a,b=Decimal(str(left)),Decimal(str(right))
  if kind=='le':return f'({num(left)} : Int) ≤ {num(right)}' if a<=b else f'({num(right)} : Int) < {num(left)}'
  return f'({num(left)} : Int) < {num(right)}' if a<b else f'({num(right)} : Int) ≤ {num(left)}'
 targets=[]
 for file,ns in [('HeatAccounting.lean','HeatAccounting'),('WordAccounting.lean','WordAccounting')]:
  targets += [ns+'.'+n for n in re.findall(r'^theorem (\w+)',(PKG/file).read_text(encoding='utf-8'),re.M)]
 text=['import HeatAccounting\nimport WordAccounting\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\nnamespace RecordedHeatGrid\n',f'def decimalScale : Nat := {scale}\ndef globalTolerance : Nat := {10**(places-12)}\ndef tagTolerance : Nat := {10**(places-14)}\n',
 'structure Row where\n  step : Nat\n  phase : Nat\n  thermal : Int\n  initial : Int\n  viscous : Int\n  released : Int\n  w0 : Int\n  w1 : Int\n  w2 : Int\n  integratedViscous : Int\n  integratedRelease : Int\n  continuousLedger : Int\n  writeLedger : Int\n  deriving DecidableEq, Repr\n',
 'def expectedWrite (r : Row) (birth : Nat) (amount : Int) : Int :=\n  if birth < r.step ∨ (birth = r.step ∧ r.phase = 2) then amount else 0\n',
 'def Good (initial h0 h1 h2 : Int) (f0 f1 f2 : Nat) (r : Row) : Prop :=\n  (r.thermal-(r.initial+r.viscous+r.released+r.w0+r.w1+r.w2)).natAbs ≤ globalTolerance ∧\n  (r.thermal-(initial+r.continuousLedger+r.writeLedger)).natAbs ≤ globalTolerance ∧\n  (r.initial-initial).natAbs ≤ tagTolerance ∧\n  (r.viscous-r.integratedViscous).natAbs ≤ tagTolerance ∧\n  (r.released-r.integratedRelease).natAbs ≤ tagTolerance ∧\n  (r.continuousLedger-r.integratedViscous-r.integratedRelease).natAbs ≤ tagTolerance ∧\n  (r.w0-expectedWrite r f0 h0).natAbs ≤ tagTolerance ∧\n  (r.w1-expectedWrite r f1 h1).natAbs ≤ tagTolerance ∧\n  (r.w2-expectedWrite r f2 h2).natAbs ≤ tagTolerance ∧\n  (r.writeLedger-expectedWrite r f0 h0-expectedWrite r f1 h1-expectedWrite r f2 h2).natAbs ≤ tagTolerance\n',
 'instance (initial h0 h1 h2 : Int) (f0 f1 f2 : Nat) (r : Row) : Decidable (Good initial h0 h1 h2 f0 f1 f2 r) := by unfold Good; infer_instance\n']
 def theorem(name,statement):targets.append('RecordedHeatGrid.'+name);text.append(f'theorem {name} : {statement} := by decide\n')
 for j,(table,r,summary) in enumerate(zip(tables,receipts,analysis['runs'])):
  prefix=f'run{j}';dt=Decimal(str(r['actual_step']));births=[int(Decimal(str(t))/dt) for t in [.4,.8,1.2]]
  text.append(f'def {prefix}Initial : Int := {num(table[0]["thermal_mean"])}\n')
  for i,w in enumerate(r['writes']):text.append(f'def {prefix}H{i} : Int := {num(w["account"]["heat"])}\n')
  blocks=[]
  for start in range(0,len(table),100):
   name=f'{prefix}Rows{start//100}';blocks.append(name);data=[]
   for row in table[start:start+100]:
    step=int(Decimal(row['time'])/dt);phase={'before_write':0,'at':1,'after_write':2}[row['side']]
    data.append('⟨'+', '.join([str(step),str(phase)]+[num(row[k]) for k in COLS])+'⟩')
   text.append(f'def {name} : List Row := [\n'+',\n'.join(data)+'\n]\n')
   theorem(name+'_accounts',f'∀ r ∈ {name}, Good {prefix}Initial {prefix}H0 {prefix}H1 {prefix}H2 '+' '.join(map(str,births))+' r')
  text.append(f'def {prefix}Rows : List Row := ['+', '.join(blocks)+'].flatten\n')
  theorem(prefix+'_coverage',f'({prefix}Rows.filter (fun r => r.phase != 0)).map Row.step = List.range {int(Decimal("1.6")/dt)+1} ∧ ({prefix}Rows.filter (fun r => r.phase == 0)).map Row.step = {births} ∧ ({prefix}Rows.filter (fun r => r.phase == 2)).map Row.step = {births}')
  h=[prefix+'H'+str(i) for i in range(3)]
  theorem(prefix+'_three_writes_accumulate',f'0 < {h[0]} ∧ {h[0]} < {h[0]}+{h[1]} ∧ {h[0]}+{h[1]} < {h[0]}+{h[1]}+{h[2]}')
  for i,w in enumerate(summary['writes']):
   comparisons=[relation(w['birth_effective_volume'],w['final_effective_volume'],'lt'),relation(w['final_peak'],w['birth_peak'],'lt'),relation(w['birth_outside025_share'],w['final_outside025_share'],'lt')]
   theorem(f'{prefix}Write{i}_recorded_spread',' ∧ '.join(comparisons))
   theorem(f'{prefix}Write{i}_recorded_signed_ripples',f'(0 : Int) ≤ {num(w["birth_negative_to_net_ratio"])} ∧ (0 : Int) ≤ {num(w["final_negative_to_net_ratio"])} ∧ '+relation(w['birth_negative_to_net_ratio'],'.025')+' ∧ '+relation(w['final_negative_to_net_ratio'],'.002'))
   for observation in ['96','128']:
    birth,end=w['birth_common'][observation],w['final_common'][observation]
    comparisons=[relation(birth['effective_volume'],end['effective_volume'],'lt'),relation(end['peak'],birth['peak'],'lt'),relation(birth['outside025_share'],end['outside025_share'],'lt')]
    theorem(f'{prefix}Write{i}_observation{observation}_recorded_spread',' ∧ '.join(comparisons))
  with localcontext() as context:
   context.prec=100
   increase=Decimal(table[-1]['thermal_mean'])-Decimal(table[0]['thermal_mean']);heats=sum(Decimal(str(w['account']['heat'])) for w in r['writes']);tenths=int((heats/increase*1000).to_integral_value(rounding=ROUND_HALF_UP))
  inc=f'(({num(table[-1]["thermal_mean"])} : Int)-{prefix}Initial)';total='('+'+'.join(h)+')'
  theorem(prefix+'_write_share_rounding',f'{tenths*10-5}*{inc} ≤ 10000*{total} ∧ 10000*{total} < {tenths*10+5}*{inc}')
  bounds=[(r['max_field_reconstruction'],'1e-12'),(r['max_rhs_reconstruction'],'1e-11'),(r['max_budget_residual'],'1e-12'),(r['max_tag_mean_error'],'1e-14')]
  theorem(prefix+'_reported_solver_bounds',' ∧ '.join(relation(x,y) for x,y in bounds))
 for cindex,c in enumerate(analysis['comparisons']):
  left,right=TAGS.index(c['left']),TAGS.index(c['right'])
  for w in c['writes']:
   i=w['event_id'];name=f'comparison{cindex}Write{i}'
   theorem(name+'_criteria_classification',' ∧ '.join(relation(w[k],limit) for k,limit in LIMITS.items()))
   h0=Decimal(str(receipts[left]['writes'][i]['account']['heat']));h1=Decimal(str(receipts[right]['writes'][i]['account']['heat']))
   sign='≤' if 100*abs(h0-h1)<=abs(h0) else '>'
   theorem(name+'_exact_deposit_comparison',f'100*(run{left}H{i}-run{right}H{i}).natAbs {sign} run{left}H{i}.natAbs')
   for k in ['normalized_field_L1','outside_share_difference','effective_volume_relative_difference','peak_relative_difference','normalized_peak_relative_difference']:
    limits=[relation(row[k],str(w[k])) for row in w['history']]
    theorem(name+'_recorded_snapshot_maxima_'+k,' ∧ '.join(limits))
  theorem(f'comparison{cindex}_cumulative_heat',relation(c['maximum_relative_cumulative_write_heat'],'.01'))
  theorem(f'comparison{cindex}_observation_quadrature',relation(c['observation_quadrature_L1_difference_max'],'.001')+' ∧ '+relation(c['observation_quadrature_share_difference_max'],'.0005'))
 # Check the observed per-write refinement trends as well as the preset limits.
 previous,finest=analysis['comparisons'][1:3]
 for i in range(3):
  for k in LIMITS:
   theorem(f'finest_trend_write{i}_{k}',relation(finest['writes'][i][k],previous['writes'][i][k]))
 theorem('finest_trend_cumulative_heat',relation(finest['maximum_relative_cumulative_write_heat'],previous['maximum_relative_cumulative_write_heat']))
 # Complete bytes are checked separately from the numerical heat metrics.
 records={}
 for c in analysis['comparisons']:
  for w in c['writes']:
   r=w['record_bits'];records[(r['left'],r['right'],r['event_id'])]=r
 for r in analysis['reference16_cost_comparisons']:records[(r['left'],r['right'],r['event_id'])]=r
 wordtext=['import WordAccounting\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\nnamespace RecordedWords\n'];word_pairs=0
 for j,(key_,r) in enumerate(records.items()):
  left,right,i=key_;payloads=[(DATA/f'{tag}-write-{i}.bin').read_bytes() for tag in [left,right]];assert len(payloads[0])==len(payloads[1])==r['payload_bytes']
  for part,sl in {'header':slice(0,46),'strain':slice(46,-4),'checksum':slice(-4,None)}.items():
   pair=[struct.unpack('<'+'H'*(len(b[sl])//2),b[sl]) for b in payloads];stats=r['regions'][part];name=f'pair{j}_{part}';word_pairs+=len(pair[0])
   assert len(pair[0])==stats['words'] and len(pair[0])*2==stats['bytes']
   data=', '.join(f'({x}, {y})' for x,y in zip(*pair));wordtext.append(f'def {name} : List (Nat × Nat) := [{data}]\n')
   expected='⟨'+', '.join(str(stats[k]) for k in ['changed_bytes','changed_words','changed_bits','left_ones','right_ones'])+'⟩'
   statement=f'{name}.length = {stats["words"]} ∧ (∀ p ∈ {name}, p.1 < 65536 ∧ p.2 < 65536) ∧ WordAccounting.statistics {name} = {expected}'
   target=name+'_exact_word_comparison';wordtext.append(f'theorem {target} : {statement} := by decide\n');targets.append('RecordedWords.'+target)
  lhs,rhs=r['both_crc'];op='=' if lhs==rhs else '≠';target=f'pair{j}_checksum_relation';wordtext.append(f'theorem {target} : ({lhs} : Nat) {op} {rhs} := by decide\n');targets.append('RecordedWords.'+target)
  names=['heat_difference','changed_targets_at_right_prestate','prior_state_at_fixed_left_targets'];values=[num(r[k]) for k in names]
  theorem(f'pair{j}_recorded_cost_partition',f'(({values[0]} : Int)-{values[1]}-{values[2]}).natAbs ≤ {num("1e-18")}')
  for part,record in r['region_cost_partition'].items():
   values=[num(record[k]) for k in ['actual_heat_difference','changed_targets_at_right_prestate','prior_state_at_fixed_left_targets']]
   theorem(f'pair{j}_{part}_recorded_cost_partition',f'(({values[0]} : Int)-{values[1]}-{values[2]}).natAbs ≤ {num("1e-18")}')
 text.append('end RecordedHeatGrid\n');wordtext.append('end RecordedWords\n')
 sources={'RecordedHeatGrid.lean':'\n'.join(text),'RecordedWords.lean':'\n'.join(wordtext),'CheckAxioms.lean':'import RecordedHeatGrid\nimport RecordedWords\n'+'\n'.join('#print axioms '+t for t in targets)+'\n','targets.json':json.dumps(targets,indent=2)+'\n'}
 generation={'target_count':len(targets),'general_rules':5,'recorded_claims':len(targets)-5,'decimal_places':places,'decimal_scale':str(scale),'dense_rows':sum(map(len,tables)),'exact_record_comparisons':len(records),'word_pairs':word_pairs,'compared_bit_positions':16*word_pairs,'source_columns':COLS,'phase_encoding':{'before_write':0,'at':1,'after_write':2},'rows_per_proof_block':100,'global_tolerance':'1e-12','tag_tolerance':'1e-14','cost_partition_tolerance':'1e-18','scope':'Exact saved decimals, complete 16-bit record-word comparisons and finite algebra. Numeric failures are recorded as threshold exceedances. No solver execution, source-transcription proof, PDE evolution, positive heat parcels or continuum convergence.'}
 sources['generation.json']=json.dumps(generation,indent=2)+'\n'
 for name,content in sources.items():
  if check:assert (PKG/name).read_text(encoding='utf-8')==content,'Transcription mismatch: '+name
  else:(PKG/name).write_text(content,encoding='utf-8')
 print(json.dumps(generation))
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--prepare',action='store_true');p.add_argument('--check',action='store_true');a=p.parse_args()
 if a.prepare:prepare()
 generate(a.check)
