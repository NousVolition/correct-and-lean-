import csv,json,re,sys
from decimal import Decimal
from pathlib import Path
import numpy as np
sys.set_int_max_str_digits(30000)
ROOT=Path(__file__).resolve().parents[2]
LEAN=ROOT/'outputs/pair25-origins-lean';DATA=LEAN/'source-data'
TAGS=['n40_dt0p0005','n48_dt0p0005','n48_dt0p00025']
def rows(p):
    with p.open(newline='',encoding='utf-8') as f:return list(csv.DictReader(f))
def write(p,text):p.write_text(text,encoding='utf-8')
def generate():
    allhist=rows(DATA/'history-numbers.csv');analysis=json.loads((DATA/'analysis.json').read_text())
    windows=[rows(DATA/f'{t}-context-window-origins.csv') for t in TAGS]
    points=[rows(DATA/f'{t}-context-point-origins.csv') for t in TAGS]
    results=[json.loads((DATA/f'{t}-result.json').read_text()) for t in TAGS]
    fields=rows(DATA/'material-field-changes.csv')
    wc=['entry_inside_context','original_inside_now','original_elsewhere_now','outside_origin_inside_now','later_source_inside_now','total_inside_now']
    pc=['original_inside','outside_origin','later_source','native_context']
    mc=['max_context_reconstruction_defect','max_global_original_component_drift','max_later_source_account_defect','minimum_origin_component']
    values=[r[k] for table in windows for r in table for k in wc]+[r[k] for table in points for r in table for k in pc]+[str(r[k]) for r in results for k in mc]
    values += [r[k] for r in fields for k in ['F_max_change','m_max_change','m_min_step_change']]
    places=max(24,max(-Decimal(x).as_tuple().exponent for x in values));assert places<=100
    scale=10**places;tol=10**(places-12);source_tol=10**(places-10)
    def number(x):
        sign,digits,exponent=Decimal(str(x)).as_tuple()
        v=(-1 if sign else 1)*int(''.join(map(str,digits)))*10**(exponent+places)
        return str(v) if v>=0 else '('+str(v)+')'
    general=re.findall(r'^theorem (\w+)',(LEAN/'OriginTracking.lean').read_text(encoding='utf-8'),re.M)
    targets=['OriginTracking.'+x for x in general]
    text=['import OriginTracking\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\nnamespace RecordedOrigins\nopen OriginTracking\n',f'def decimalScale : Nat := {scale}\ndef tolerance : Nat := {tol}\n',
          'structure PointAccount where\n  original : Int\n  incoming : Int\n  added : Int\n  current : Int\n  deriving DecidableEq, Repr\n',
          'def PointGood (a : PointAccount) : Prop :=\n  (a.current-a.original-a.incoming-a.added).natAbs ≤ tolerance ∧\n  a.original ≥ -(Int.ofNat tolerance) ∧ a.incoming ≥ -(Int.ofNat tolerance) ∧ a.added ≥ -(Int.ofNat tolerance)\ninstance (a : PointAccount) : Decidable (PointGood a) := by unfold PointGood; infer_instance\n',
          'def WindowGood (a : Account) : Prop := Within a tolerance ∧\n  a.oldInside ≥ -(Int.ofNat tolerance) ∧ a.oldOutside ≥ -(Int.ofNat tolerance) ∧\n  a.incoming ≥ -(Int.ofNat tolerance) ∧ a.added ≥ -(Int.ofNat tolerance)\ninstance (a : Account) : Decidable (WindowGood a) := by unfold WindowGood; infer_instance\n']
    payloads={};run_records=[]
    text.append('structure FieldChange where\n  id : Nat\n  deformation : Int\n  materialField : Int\n  minimumStep : Int\n  deriving DecidableEq, Repr\n')
    for tag in TAGS:
        with np.load(DATA/f'{tag}-payloads.npz') as z:
            entry=[(int(k),v.tobytes()) for k,v in zip(z['entry_ids'],z['entry_payloads']) if k>=0]
            snapshots=[[(int(k),v.tobytes()) for k,v in zip(keys,values) if k>=0] for keys,values in zip(z['ids'],z['payloads'])]
        for records in [entry]+snapshots:
            for _,raw in records:
                if raw not in payloads:payloads[raw]=f'payload{len(payloads)}'
        run_records.append((entry,snapshots))
    for raw,name in payloads.items():text.append(f'def {name} : Nat := {int.from_bytes(bytes([1])+raw,"big")}\n')
    def theorem(name,claim):
        targets.append('RecordedOrigins.'+name);text.append(f'theorem {name} : {claim} := by decide\n')
    for j,tag in enumerate(TAGS):
        steps=results[j]['steps']
        table=[r for r in fields if r['run']==tag]
        body=',\n'.join('⟨'+r['id']+', '+', '.join(number(r[k]) for k in ['F_max_change','m_max_change','m_min_step_change'])+'⟩' for r in table)
        text.append(f'def run{j}Fields : List FieldChange := [\n{body}\n]\n')
        theorem(f'run{j}_material_field_ids',f'(run{j}Fields.map FieldChange.id) = List.range 384')
        theorem(f'run{j}_material_fields_change',f'∀ a ∈ run{j}Fields, a.deformation > 0 ∧ a.materialField > 0')
        theorem(f'run{j}_material_field_no_recorded_decrease',f'∀ a ∈ run{j}Fields, a.minimumStep ≥ 0')
        for population,lean_name in [('observer','Observers'),('material','Material')]:
            records=[r for r in allhist if r['run']==tag and r['population']==population]
            body=',\n'.join('⟨'+r['id']+', '+r['membership_bits']+'⟩' for r in records)
            text.append(f'def run{j}{lean_name} : List History := [\n{body}\n]\n')
            ids='(List.range 926).filter (fun i => i != 825 && i != 850)' if population=='observer' else 'List.range 384'
            theorem(f'run{j}_{population}_ids',f'(run{j}{lean_name}.map History.id) = ({ids})')
            theorem(f'run{j}_{population}_history_bounds',f'∀ h ∈ run{j}{lean_name}, h.bits < 2^{steps+1}')
            summary=next(r for r in analysis['primary_union'] if r['run']==tag and r['population']==population)
            counts=', '.join(str(summary[c]) for c in ['stayed','left','returned','arrived','visited','outside'])
            theorem(f'run{j}_{population}_classification',f'counts run{j}{lean_name} {steps} = [{counts}]')
        # The wider union is a declared sensitivity view, not a replacement for the primary view.
        with np.load(DATA/f'{tag}-membership.npz') as z:
            wider=z['observer'][:,:,2,2];wider_ids=z['observer_ids']
        packed=np.packbits(wider,axis=0,bitorder='little')
        records=[(int(identity),int.from_bytes(packed[:,i].tobytes(),'little')) for i,identity in enumerate(wider_ids)]
        text.append(f'def run{j}WideObservers : List History := [\n'+',\n'.join('⟨'+str(i)+', '+str(b)+'⟩' for i,b in records)+'\n]\n')
        theorem(f'run{j}_wide_observer_ids',f'(run{j}WideObservers.map History.id) = ((List.range 926).filter (fun i => i != 825 && i != 850))')
        theorem(f'run{j}_wide_observer_history_bounds',f'∀ h ∈ run{j}WideObservers, h.bits < 2^{steps+1}')
        def classify(bits):
            first=bits%2==1;last=bits//2**steps%2==1
            return ('left' if not last else 'stayed' if bits==2**(steps+1)-1 else 'returned') if first else ('arrived' if last else 'visited' if bits else 'outside')
        wide_counts=[sum(classify(b)==c for _,b in records) for c in ['stayed','left','returned','arrived','visited','outside']]
        theorem(f'run{j}_wide_observer_classification',f'counts run{j}WideObservers {steps} = ['+', '.join(map(str,wide_counts))+']')
        left=[i for i,b in records if classify(b)=='left'];arrived=[i for i,b in records if classify(b)=='arrived']
        theorem(f'run{j}_wide_departing_and_arriving_ids',f'((run{j}WideObservers.filter (fun h => classify h {steps} == .left)).map History.id) = {left} ∧ ((run{j}WideObservers.filter (fun h => classify h {steps} == .arrived)).map History.id) = {arrived}')
        for label,table,columns,typ,predicate in [('Windows',windows[j],wc,'Account','WindowGood'),('Points',points[j],pc,'PointAccount','PointGood')]:
            body=',\n'.join('⟨'+', '.join(number(r[k]) for k in columns)+'⟩' for r in table)
            text.append(f'def run{j}{label} : List {typ} := [\n{body}\n]\n')
            theorem(f'run{j}_{label.lower()}_count',f'run{j}{label}.length = {len(table)}')
            theorem(f'run{j}_{label.lower()}_accounts',f'∀ a ∈ run{j}{label}, {predicate} a')
        endpoint=next(r for r in windows[j] if float(r['time'])==1.3 and float(r['radius'])==.075)
        text.append(f'def run{j}Endpoint : Account := ⟨'+', '.join(number(endpoint[k]) for k in wc)+'⟩\n')
        endpoint_claim=f'run{j}Endpoint.oldOutside > 0 ∧ run{j}Endpoint.incoming > 0 ∧ run{j}Endpoint.added > 0 ∧ run{j}Endpoint.oldInside < run{j}Endpoint.entry'
        observed=all(Decimal(endpoint[k])>0 for k in ['original_elsewhere_now','outside_origin_inside_now','later_source_inside_now']) and Decimal(endpoint['original_inside_now'])<Decimal(endpoint['entry_inside_context'])
        theorem(f'run{j}_endpoint_origin_change',endpoint_claim if observed else '¬ ('+endpoint_claim+')')
        entry,snapshots=run_records[j]
        fmt=lambda rs:'['+', '.join('('+str(k)+', '+payloads[raw]+')' for k,raw in rs)+']'
        text.append(f'def run{j}Entry : List (Nat × Nat) := {fmt(entry)}\n')
        text.append(f'def run{j}Memory : List (List (Nat × Nat)) := [\n'+',\n'.join(fmt(r) for r in snapshots)+'\n]\n')
        theorem(f'run{j}_memory_sample_count',f'run{j}Memory.length = {len(snapshots)}')
        theorem(f'run{j}_memory_payloads',f'∀ row ∈ run{j}Memory, row = run{j}Entry')
        v=[number(results[j][k]) for k in mc]
        theorem(f'run{j}_reported_numerical_checks',f'({v[0]} : Int).natAbs ≤ {tol} ∧ ({v[1]} : Int).natAbs ≤ {tol} ∧ ({v[2]} : Int).natAbs ≤ {source_tol} ∧ ({v[3]} : Int) ≥ -({tol} : Int)')
    text.append('end RecordedOrigins\n');write(LEAN/'RecordedOrigins.lean','\n'.join(text))
    write(LEAN/'CheckAxioms.lean','import RecordedOrigins\n'+'\n'.join('#print axioms '+t for t in targets)+'\n')
    write(LEAN/'targets.json',json.dumps(targets,indent=2)+'\n')
    write(LEAN/'data-generation.json',json.dumps({'decimal_places':places,'targets':len(targets),'histories':len(allhist),'primary_identity_view':'union of moving A/B windows, radius 0.075','context_radii':[.05,.075,.1],'scope':'Exact recorded membership bits, full memory bytes and signed decimal context accounts; no geometry or fluid evolution proof.'},indent=2)+'\n')
    print(json.dumps({'targets':len(targets),'histories':len(allhist),'decimal_places':places}))
if __name__=='__main__':generate()
