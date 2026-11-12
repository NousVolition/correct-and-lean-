"""Bind finite follow-up observations to exact-decimal Lean statements."""
import csv,json,re,sys
from decimal import Decimal
from pathlib import Path
import numpy as np
sys.set_int_max_str_digits(30000)
ROOT=Path(__file__).resolve().parents[2];LEAN=ROOT/'outputs/observer540-872-lean';DATA=LEAN/'source-data'
TAGS=['n40_dt0p0005','n48_dt0p0005','n48_dt0p00025'];IDS=[540,872]
REGIONS=['near540_only','near872_only','near_both','near_neither','later_source']
PC=REGIONS+['C','theta'];WC=['entry_original','original_inside','original_elsewhere','other_origin_inside','later_source_inside','native_total_inside']
FC=['F_max_change','m_max_change','m_min_step_change'];MC=['max_reconstruction_defect','max_original_global_drift','max_source_account_error','minimum_component']
CC=['time_before','time_after','distance_before','distance_after','C_before','C_after','theta_before','theta_after']
CLASSES=['stayed','left','returned','arrived','visited','outside']
def rows(p):
    with p.open(newline='',encoding='utf-8') as f:return list(csv.DictReader(f))
def read(p):return json.loads(p.read_text(encoding='utf-8'))
def write(p,s):p.write_text(s,encoding='utf-8')
def generate():
    analysis=read(DATA/'analysis.json');hist=rows(DATA/'neighbor-histories.csv');fields=rows(DATA/'entry-material-fields.csv');cross=rows(DATA/'crossing-readouts.csv')
    windows=[rows(DATA/f'{t}-window-history.csv') for t in TAGS];points=[rows(DATA/f'{t}-point-history.csv') for t in TAGS];results=[read(DATA/f'{t}-result.json') for t in TAGS]
    pair=rows(DATA/'pair-wide-origin-readouts.csv');paircols=['pair_initial_inside_origin','pair_initial_outside_origin','later_source','native_C']
    values=[r[k] for table in windows for r in table for k in WC]+[r[k] for table in points for r in table for k in PC]
    values += [r[k] for r in fields for k in FC]+[r[k] for r in cross for k in CC]+[str(r[k]) for r in results for k in MC]+[r[k] for r in pair for k in paircols]
    places=max(24,max(-Decimal(v).as_tuple().exponent for v in values));assert places<=100
    scale=10**places;tol=10**(places-12);tiny=2*10**(places-15);source_tol=10**(places-10)
    def num(v):
        sign,digits,e=Decimal(str(v)).as_tuple();assert e+places>=0
        n=(-1 if sign else 1)*int(''.join(map(str,digits)))*10**(e+places)
        return str(n) if n>=0 else '('+str(n)+')'
    targets=[]
    for module in ['OriginTracking','FollowingLabels']:
        targets += [module+'.'+n for n in re.findall(r'^theorem (\w+)',(LEAN/(module+'.lean')).read_text(encoding='utf-8'),re.M)]
    text=['import FollowingLabels\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\nset_option exponentiation.threshold 1000\nnamespace RecordedFollowing\nopen OriginTracking\n',f'def decimalScale : Nat := {scale}\ndef tolerance : Nat := {tol}\n']
    text += ['structure Point where\n  step : Nat\n  only540 : Int\n  only872 : Int\n  shared : Int\n  neither : Int\n  added : Int\n  current : Int\n  theta : Int\n  deriving DecidableEq, Repr\n',
      'def PointGood (p : Point) : Prop := (p.current-p.only540-p.only872-p.shared-p.neither-p.added).natAbs ≤ tolerance ∧ p.only540 ≥ -(Int.ofNat tolerance) ∧ p.only872 ≥ -(Int.ofNat tolerance) ∧ p.shared ≥ -(Int.ofNat tolerance) ∧ p.neither ≥ -(Int.ofNat tolerance) ∧ p.added ≥ -(Int.ofNat tolerance)\ninstance (p : Point) : Decidable (PointGood p) := by unfold PointGood; infer_instance\n',
      'def WindowGood (a : Account) : Prop := Within a tolerance ∧ a.oldInside ≥ -(Int.ofNat tolerance) ∧ a.oldOutside ≥ -(Int.ofNat tolerance) ∧ a.incoming ≥ -(Int.ofNat tolerance) ∧ a.added ≥ -(Int.ofNat tolerance)\ninstance (a : Account) : Decidable (WindowGood a) := by unfold WindowGood; infer_instance\n',
      'structure FieldChange where\n  id : Nat\n  deformation : Int\n  materialField : Int\n  minimumStep : Int\n  deriving DecidableEq, Repr\n',
      'structure Crossing where\n  id : Nat\n  stepBefore : Nat\n  stepAfter : Nat\n  timeBefore : Int\n  timeAfter : Int\n  distanceBefore : Int\n  distanceAfter : Int\n  cBefore : Int\n  cAfter : Int\n  thetaBefore : Int\n  thetaAfter : Int\n  deriving DecidableEq, Repr\n',
      'structure PairOrigin where\n  original : Int\n  other : Int\n  added : Int\n  current : Int\n  deriving DecidableEq, Repr\n']
    def definition(name,typ,data):text.append(f'def {name} : List {typ} := [\n'+',\n'.join('⟨'+', '.join(map(str,r))+'⟩' for r in data)+'\n]\n')
    def theorem(name,claim):targets.append('RecordedFollowing.'+name);text.append(f'theorem {name} : {claim} := by decide\n')
    payloads={};allpayloads=[]
    for tag in TAGS:
        with np.load(DATA/f'{tag}-memory-payloads.npz') as z:
            entry=[(int(k),v.tobytes()) for k,v in zip(z['entry_ids'],z['entry_payloads']) if k>=0]
            snapshots=[[(int(k),v.tobytes()) for k,v in zip(keys,vals) if k>=0] for keys,vals in zip(z['ids'],z['payloads'])]
        for ss in [entry]+snapshots:
            for _,raw in ss:
                if raw not in payloads:payloads[raw]=f'payload{len(payloads)}'
        allpayloads.append((entry,snapshots))
    for raw,name in payloads.items():text.append(f'def {name} : Nat := {int.from_bytes(bytes([1])+raw,"big")}\n')
    for j,tag in enumerate(TAGS):
        steps=results[j]['steps']
        for owner in IDS:
            prefix=f'run{j}Label{owner}'
            for pop,suffix in [('material','Material'),('observer','Observers')]:
                records=[r for r in hist if r['run']==tag and int(r['observer'])==owner and r['population']==pop]
                definition(prefix+suffix,'History',[(r['id'],r['bits']) for r in records])
                expected='List.range 384' if pop=='material' else f'(List.range 926).filter (fun i => i != {owner})'
                theorem(prefix+'_'+pop+'_ids',f'({prefix+suffix}.map History.id) = ({expected})')
                theorem(prefix+'_'+pop+'_history_bounds',f'∀ h ∈ {prefix+suffix}, h.bits < 2^{steps+1}')
                summary=next(r for r in analysis['primary_neighbors'] if r['run']==tag and r['observer']==owner and r['population']==pop)
                theorem(prefix+'_'+pop+'_classification',f'counts {prefix+suffix} {steps} = ['+', '.join(str(summary[c]) for c in CLASSES)+']')
            fr=[r for r in fields if r['run']==tag and int(r['observer'])==owner]
            definition(prefix+'Fields','FieldChange',[(r['material_id'],*[num(r[k]) for k in FC]) for r in fr])
            theorem(prefix+'_entry_material_ids',f'({prefix}Fields.map FieldChange.id) = (({prefix}Material.filter (fun h => h.bits % 2 == 1)).map History.id)')
            theorem(prefix+'_material_fields_change',f'∀ a ∈ {prefix}Fields, a.deformation > 0 ∧ a.materialField > 0 ∧ a.minimumStep ≥ 0')
            pp=[r for r in points[j] if int(r['observer'])==owner]
            definition(prefix+'Points','Point',[(r['step'],*[num(r[k]) for k in PC]) for r in pp])
            theorem(prefix+'_point_coverage',f'({prefix}Points.map Point.step) = List.range {steps+1}')
            theorem(prefix+'_point_origin_accounts',f'∀ p ∈ {prefix}Points, PointGood p')
            ww=[r for r in windows[j] if int(r['observer'])==owner]
            definition(prefix+'Windows','Account',[[num(r[k]) for k in WC] for r in ww])
            theorem(prefix+'_window_count',f'{prefix}Windows.length = {len(ww)}')
            theorem(prefix+'_window_origin_accounts',f'∀ a ∈ {prefix}Windows, WindowGood a')
            endpoint=ww[-1];assert int(endpoint['step'])==steps
            text.append(f'def {prefix}Endpoint : Account := ⟨'+', '.join(num(endpoint[k]) for k in WC)+'⟩\n')
            theorem(prefix+'_endpoint_mixture',f'{prefix}Endpoint.oldOutside > 0 ∧ {prefix}Endpoint.incoming > 0 ∧ {prefix}Endpoint.added > 0 ∧ {prefix}Endpoint.oldInside < {prefix}Endpoint.entry')
            # Decimal rounding intervals for the plotted retained percentage (one decimal place).
            retention=Decimal(endpoint['original_inside'])/Decimal(endpoint['entry_original'])*100
            tenths=int((retention*10).quantize(Decimal(1)))
            theorem(prefix+'_retained_percentage_rounding',f'{2*tenths-1} * {prefix}Endpoint.entry ≤ 2000 * {prefix}Endpoint.oldInside ∧ 2000 * {prefix}Endpoint.oldInside < {2*tenths+1} * {prefix}Endpoint.entry')
            crossing=next(r for r in cross if r['run']==tag and int(r['observer'])==owner)
            text.append(f'def {prefix}Crossing : Crossing := ⟨'+', '.join([str(owner),crossing['step_before'],crossing['step_after']]+[num(crossing[k]) for k in CC])+'⟩\n')
            bits=sum((1<<int(r['step'])) for r in pp if r['inside_pair_wide']=='True')
            text.append(f'def {prefix}PairHistory : History := ⟨{owner}, {bits}⟩\n')
            after=int(crossing['step_after']);wanted=f'2^{after}-1' if owner==540 else f'2^{steps+1}-2^{after}'
            theorem(prefix+'_single_recorded_crossing',f'{prefix}PairHistory.id = {owner} ∧ {prefix}PairHistory.bits = {wanted} ∧ classify {prefix}PairHistory {steps} = '+('.left' if owner==540 else '.arrived'))
            c=prefix+'Crossing';rad=num('.1');side=f'{c}.distanceBefore ≤ {rad} ∧ {c}.distanceAfter > {rad}' if owner==540 else f'{c}.distanceBefore > {rad} ∧ {c}.distanceAfter ≤ {rad}'
            theorem(prefix+'_crossing_bracket',f'{c}.id = {owner} ∧ {c}.stepAfter = {c}.stepBefore+1 ∧ {side} ∧ ({c}.timeAfter-{c}.timeBefore-({num(results[j]["dt"])})).natAbs ≤ {tiny}')
            theorem(prefix+'_crossing_readouts_change',f'{c}.cBefore ≠ {c}.cAfter ∧ {c}.thetaBefore ≠ {c}.thetaAfter')
        pp=[r for r in pair if r['run']==tag];definition(f'run{j}PairOrigins','PairOrigin',[[num(r[k]) for k in paircols] for r in pp])
        theorem(f'run{j}_separate_pair_origin_accounts',f'run{j}PairOrigins.length = {len(pp)} ∧ ∀ a ∈ run{j}PairOrigins, (a.current-a.original-a.other-a.added).natAbs ≤ tolerance')
        entry,snapshots=allpayloads[j];fmt=lambda rs:'['+', '.join('('+str(k)+', '+payloads[b]+')' for k,b in rs)+']'
        text.append(f'def run{j}Entry : List (Nat × Nat) := {fmt(entry)}\n')
        text.append(f'def run{j}Memory : List (List (Nat × Nat)) := [\n'+',\n'.join(fmt(r) for r in snapshots)+'\n]\n')
        theorem(f'run{j}_shared_memory_coverage',f'run{j}Memory.length = {steps+1} ∧ (run{j}Entry.map Prod.fst) = [0,1,2]')
        theorem(f'run{j}_shared_memory_payloads',f'∀ row ∈ run{j}Memory, row = run{j}Entry')
        v=[num(results[j][k]) for k in MC]
        theorem(f'run{j}_reported_numerical_bounds',f'({v[0]} : Int).natAbs ≤ {tol} ∧ ({v[1]} : Int).natAbs ≤ {tol} ∧ ({v[2]} : Int).natAbs ≤ {source_tol} ∧ ({v[3]} : Int) ≥ -({tol} : Int)')
    text.append('end RecordedFollowing\n');write(LEAN/'RecordedFollowing.lean','\n'.join(text))
    write(LEAN/'CheckAxioms.lean','import RecordedFollowing\n'+'\n'.join('#print axioms '+t for t in targets)+'\n')
    write(LEAN/'targets.json',json.dumps(targets,indent=2)+'\n')
    write(LEAN/'data-generation.json',json.dumps({'decimal_places':places,'target_count':len(targets),'neighbor_histories':len(hist),'observer_ids':IDS,'primary_individual_radius':.075,'original_pair_crossing_radius':.1,'scope':'Exact recorded finite histories, shared bytes and signed decimal origin accounts. No fluid evolution, interpolation, physical ownership or complete inventory proof.'},indent=2)+'\n')
    print(json.dumps({'targets':len(targets),'neighbor_histories':len(hist),'decimal_places':places}))
if __name__=='__main__':generate()
