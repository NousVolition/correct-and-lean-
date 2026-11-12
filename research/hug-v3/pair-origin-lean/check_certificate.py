"""Match finite Lean constants to all saved membership bits, bytes and decimals."""
import csv,json,re,sys
from decimal import Decimal
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parent;DATA=ROOT/'source-data'
TAGS=['n40_dt0p0005','n48_dt0p0005','n48_dt0p00025']
def rows(p):
    with p.open(newline='',encoding='utf-8') as f:return list(csv.DictReader(f))
def check(text=None):
    sys.set_int_max_str_digits(30000)
    text=text if text is not None else (ROOT/'RecordedOrigins.lean').read_text(encoding='utf-8')
    scale=int(re.search(r'def decimalScale : Nat := (\d+)',text).group(1));places=len(str(scale))-1
    assert scale==10**places
    def number(v):
        sign,digits,exponent=Decimal(str(v)).as_tuple();assert exponent+places>=0
        return (-1 if sign else 1)*int(''.join(map(str,digits)))*10**(exponent+places)
    def block(name,typ):return re.search(r'def '+name+r' : '+re.escape(typ)+r' := \[\n(.*?)\n\]',text,re.S).group(1)
    def tuples(name,typ):return [tuple(int(v.strip().strip('()')) for v in row.split(',')) for row in re.findall(r'⟨([^⟩]+)⟩',block(name,typ))]
    hist_csv=rows(DATA/'history-numbers.csv');history_count=0;bit_count=0;payload_count=0;window_count=0;point_count=0;field_count=0;wide_count=0;wide_bits=0
    payloads={}
    for name,value in re.findall(r'def (payload\d+) : Nat := (\d+)',text):
        n=int(value);size=(n.bit_length()-1)//8
        assert n.bit_length()==8*size+1
        payloads[name]=(n-(1<<(8*size))).to_bytes(size,'big')
    def record_list(raw):return [(int(key),payloads[p]) for key,p in re.findall(r'\((\d+), (payload\d+)\)',raw)]
    for j,tag in enumerate(TAGS):
        info=json.loads((DATA/f'{tag}-result.json').read_text())
        steps=info['steps']
        field_table=[r for r in rows(DATA/'material-field-changes.csv') if r['run']==tag]
        assert tuples(f'run{j}Fields','List FieldChange')==[(int(r['id']),*[number(r[k]) for k in ['F_max_change','m_max_change','m_min_step_change']]) for r in field_table],'Material field decimal mismatch'
        field_count+=len(field_table)
        with np.load(DATA/f'{tag}-membership.npz') as z:
            assert len(z['times'])==steps+1 and list(z['radii'])==[.05,.075,.1]
            for population,name in [('observer','Observers'),('material','Material')]:
                matrix=z[population][:,:,1,2];ids=z[population+'_ids']
                packed=np.packbits(matrix,axis=0,bitorder='little')
                expected=[(int(identity),int.from_bytes(packed[:,i].tobytes(),'little')) for i,identity in enumerate(ids)]
                assert tuples(f'run{j}{name}','List History')==expected,'Membership history mismatch'
                from_csv=[(int(r['id']),int(r['membership_bits'])) for r in hist_csv if r['run']==tag and r['population']==population]
                assert from_csv==expected,'History table mismatch'
                assert all(int(r['steps'])==steps for r in hist_csv if r['run']==tag and r['population']==population)
                history_count+=len(ids);bit_count+=matrix.size
            matrix=z['observer'][:,:,2,2];ids=z['observer_ids'];packed=np.packbits(matrix,axis=0,bitorder='little')
            assert tuples(f'run{j}WideObservers','List History')==[(int(identity),int.from_bytes(packed[:,i].tobytes(),'little')) for i,identity in enumerate(ids)],'Wider membership mismatch'
            wide_count+=len(ids);wide_bits+=matrix.size
        for label,filename,typ,cols in [
            ('Windows','context-window-origins.csv','List Account',['entry_inside_context','original_inside_now','original_elsewhere_now','outside_origin_inside_now','later_source_inside_now','total_inside_now']),
            ('Points','context-point-origins.csv','List PointAccount',['original_inside','outside_origin','later_source','native_context'])]:
            table=rows(DATA/f'{tag}-{filename}')
            assert tuples(f'run{j}{label}',typ)==[tuple(number(r[k]) for k in cols) for r in table],'Origin decimal mismatch'
            if label=='Windows':window_count+=len(table)
            else:point_count+=len(table)
        with np.load(DATA/f'{tag}-payloads.npz') as z:
            entry=[(int(k),v.tobytes()) for k,v in zip(z['entry_ids'],z['entry_payloads']) if k>=0]
            snapshots=[[(int(k),v.tobytes()) for k,v in zip(keys,values) if k>=0] for keys,values in zip(z['ids'],z['payloads'])]
        endpoint=next(r for r in rows(DATA/f'{tag}-context-window-origins.csv') if float(r['time'])==1.3 and float(r['radius'])==.075)
        cols=['entry_inside_context','original_inside_now','original_elsewhere_now','outside_origin_inside_now','later_source_inside_now','total_inside_now']
        endpoint_literal=re.search(r'def run'+str(j)+r'Endpoint : Account := ⟨([^⟩]+)⟩',text).group(1)
        assert tuple(int(x.strip().strip('()')) for x in endpoint_literal.split(','))==tuple(number(endpoint[k]) for k in cols),'Endpoint source mismatch'
        entry_text=re.search(r'def run'+str(j)+r'Entry : List \(Nat × Nat\) := (\[[^\n]*\])',text).group(1)
        assert record_list(entry_text)==entry,'Entry payload mismatch'
        literal=block(f'run{j}Memory','List (List (Nat × Nat))')
        parsed=[record_list(line) for line in literal.splitlines()]
        assert parsed==snapshots,'Complete recorded payload mismatch'
        payload_count+=sum(len(s) for s in snapshots)
        metric=['max_context_reconstruction_defect','max_global_original_component_drift','max_later_source_account_defect','minimum_origin_component']
        theorem=re.search(r'theorem run'+str(j)+r'_reported_numerical_checks : (.*?) := by decide',text).group(1)
        for k in metric:
            value=number(info[k]);literal='('+str(value)+')' if value<0 else str(value)
            assert '('+literal+' : Int)' in theorem,'Reported numerical metric mismatch'
    return {'histories_matched':history_count,'membership_bits_matched':int(bit_count),'wider_observer_histories_matched':wide_count,'wider_observer_membership_bits_matched':int(wide_bits),'full_record_payloads_matched':payload_count,'window_accounts_matched':window_count,'point_accounts_matched':point_count,'material_field_records_matched':field_count,'decimal_scale':str(scale),'source_data_match':True}
def self_test():
    text=(ROOT/'RecordedOrigins.lean').read_text(encoding='utf-8');variants=[]
    m=re.search(r'def run0Observers : List History := \[\n⟨(\d+), (\d+)⟩',text)
    variants.append(text[:m.start(2)]+str(int(m.group(2))^1)+text[m.end(2):])
    variants.append(text[:m.start(1)]+str(int(m.group(1))+1)+text[m.end(1):])
    m=re.search(r'def run0Windows : List Account := \[\n⟨(\d+)',text)
    variants.append(text[:m.start(1)]+str(int(m.group(1))+1)+text[m.end(1):])
    m=re.search(r'def payload0 : Nat := (\d+)',text)
    variants.append(text[:m.start(1)]+str(int(m.group(1))+1)+text[m.end(1):])
    m=re.search(r'def run0Fields : List FieldChange := \[\n⟨\d+, (\d+)',text)
    variants.append(text[:m.start(1)]+str(int(m.group(1))+1)+text[m.end(1):])
    m=re.search(r'def run0WideObservers : List History := \[\n⟨\d+, (\d+)⟩',text)
    variants.append(text[:m.start(1)]+str(int(m.group(1))^1)+text[m.end(1):])
    for changed in variants:
        try:check(changed)
        except AssertionError:pass
        else:raise AssertionError('Altered origin evidence accepted')
    return len(variants)
if __name__=='__main__':
    result=check()
    if '--self-test' in sys.argv:result['tamper_tests_passed']=self_test()
    print(json.dumps(result,indent=2))
