"""Independently match actual Lean literals to saved bits, stencils, bytes and decimals."""
import csv,json,re,sys
from decimal import Decimal
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parent;DATA=ROOT/'source-data'
TAGS=['n40_dt0p0005','n48_dt0p0005','n48_dt0p00025'];IDS=[540,872]
REGIONS=['near540_only','near872_only','near_both','near_neither','later_source']
PC=REGIONS+['C','theta'];WC=['entry_original','original_inside','original_elsewhere','other_origin_inside','later_source_inside','native_total_inside']
FC=['F_max_change','m_max_change','m_min_step_change'];MC=['max_reconstruction_defect','max_original_global_drift','max_source_account_error','minimum_component']
CC=['time_before','time_after','distance_before','distance_after','C_before','C_after','theta_before','theta_after']
def rows(p):
    with p.open(newline='',encoding='utf-8') as f:return list(csv.DictReader(f))
def read(p):return json.loads(p.read_text(encoding='utf-8'))
def check(text=None):
    sys.set_int_max_str_digits(30000)
    text=text if text is not None else (ROOT/'RecordedFollowing.lean').read_text(encoding='utf-8')
    scale=int(re.search(r'def decimalScale : Nat := (\d+)',text).group(1));places=len(str(scale))-1;assert scale==10**places
    assert int(re.search(r'def tolerance : Nat := (\d+)',text).group(1))==10**(places-12)
    def number(v):
        sign,digits,e=Decimal(str(v)).as_tuple();assert e+places>=0
        return (-1 if sign else 1)*int(''.join(map(str,digits)))*10**(e+places)
    def block(name,typ):return re.search(r'def '+name+r' : '+re.escape(typ)+r' := \[\n(.*?)\n\]',text,re.S).group(1)
    def parse(raw):return tuple(int(v.strip().strip('()')) for v in raw.split(','))
    def tuples(name,typ):return [parse(r) for r in re.findall(r'⟨([^⟩]+)⟩',block(name,'List '+typ))]
    def literal(name,typ):return parse(re.search(r'def '+name+r' : '+typ+r' := ⟨([^⟩]+)⟩',text).group(1))
    histories=rows(DATA/'neighbor-histories.csv');fields=rows(DATA/'entry-material-fields.csv');crossings=rows(DATA/'crossing-readouts.csv');pair=rows(DATA/'pair-wide-origin-readouts.csv')
    count=dict(neighbor_histories=0,neighbor_bits=0,point_accounts=0,window_accounts=0,crossing_records=0,pair_history_bits=0,material_field_records=0,shared_record_payloads=0,separate_pair_origin_accounts=0)
    payloads={}
    for name,value in re.findall(r'def (payload\d+) : Nat := (\d+)',text):
        n=int(value);size=(n.bit_length()-1)//8;assert n.bit_length()==8*size+1
        payloads[name]=(n-(1<<(8*size))).to_bytes(size,'big')
    def record_list(raw):return [(int(key),payloads[p]) for key,p in re.findall(r'\((\d+), (payload\d+)\)',raw)]
    max_stencil_error=0.
    for j,tag in enumerate(TAGS):
        info=read(DATA/f'{tag}-result.json');steps=info['steps'];assert all(info['criteria'].values())
        points=rows(DATA/f'{tag}-point-history.csv');windows=rows(DATA/f'{tag}-window-history.csv')
        with np.load(DATA/f'{tag}-point-stencils.npz') as z:
            p=z['positions'];n=info['n'];xyz=((p[:,:2]+.5)%1)*n;low=np.floor(xyz).astype(int);frac=xyz-low
            off=np.array([[a,b,c] for a in [0,1] for b in [0,1] for c in [0,1]])
            nodes=(low[:,:,None,:]+off)%n;weights=np.prod(np.where(off,frac[:,:,None,:],1-frac[:,:,None,:]),axis=-1)
            assert np.array_equal(nodes,z['nodes']) and np.max(abs(weights-z['weights']))<2e-15
            native=np.einsum('spo,spof->spf',weights,z['native_corners']);origins=np.einsum('spo,spof->spf',weights,z['origin_corners'])
            error=max(float(abs(native-z['native_values']).max()),float(abs(origins-z['origin_values']).max()));max_stencil_error=max(error,max_stencil_error);assert error<=1e-12
            distance=np.linalg.norm((p[:,:2,None]-p[:,None,2:]+.5)%1-.5,axis=-1).min(axis=-1)
        with np.load(DATA/f'{tag}-membership.npz') as z:
            assert len(z['times'])==steps+1 and list(z['radii'])==[.05,.075,.1]
            for oi,owner in enumerate(IDS):
                prefix=f'run{j}Label{owner}'
                for pop,suffix in [('material','Material'),('observer','Observers')]:
                    matrix=z[f'{owner}_{pop}'][:,:,1];ids=z[f'{owner}_{pop}_ids'];packed=np.packbits(matrix,axis=0,bitorder='little')
                    expected=[(int(identity),int.from_bytes(packed[:,i].tobytes(),'little')) for i,identity in enumerate(ids)]
                    assert tuples(prefix+suffix,'History')==expected,'Neighbor identity or history mismatch'
                    hh=[r for r in histories if r['run']==tag and int(r['observer'])==owner and r['population']==pop]
                    assert [(int(r['id']),int(r['bits'])) for r in hh]==expected and all(int(r['steps'])==steps for r in hh)
                    count['neighbor_histories']+=len(ids);count['neighbor_bits']+=int(matrix.size)
                ff=[r for r in fields if r['run']==tag and int(r['observer'])==owner]
                assert tuples(prefix+'Fields','FieldChange')==[(int(r['material_id']),*[number(r[k]) for k in FC]) for r in ff],'Material field mismatch'
                count['material_field_records']+=len(ff)
                pp=[r for r in points if int(r['observer'])==owner]
                assert [int(r['step']) for r in pp]==list(range(steps+1))
                assert tuples(prefix+'Points','Point')==[(int(r['step']),*[number(r[k]) for k in PC]) for r in pp],'Point decimal mismatch'
                for r in pp:
                    si=int(r['step']);assert float(r['time'])==z['times'][si]
                    assert abs(float(r['distance_pair_union'])-distance[si,oi])<=2e-15
                    assert (r['inside_pair_wide']=='True')==(distance[si,oi]<=.1)
                    for k,name in enumerate(['u_x','u_y','u_z','C','theta']):assert abs(float(r[name])-native[si,oi,k])<=1e-12
                    for k,name in enumerate(REGIONS):assert abs(float(r[name])-origins[si,oi,k])<=1e-12
                count['point_accounts']+=len(pp)
                ww=[r for r in windows if int(r['observer'])==owner]
                assert [int(r['step']) for r in ww]==info['saved_field_steps']
                assert tuples(prefix+'Windows','Account')==[tuple(number(r[k]) for k in WC) for r in ww],'Window decimal mismatch'
                assert literal(prefix+'Endpoint','Account')==tuple(number(ww[-1][k]) for k in WC),'Endpoint source mismatch'
                count['window_accounts']+=len(ww)
                c=next(r for r in crossings if r['run']==tag and int(r['observer'])==owner)
                expected=(owner,int(c['step_before']),int(c['step_after']),*[number(c[k]) for k in CC])
                assert literal(prefix+'Crossing','Crossing')==expected,'Crossing decimal mismatch'
                for phase in ['before','after']:
                    si=int(c['step_'+phase]);assert float(c['time_'+phase])==z['times'][si]
                    assert abs(float(c['distance_'+phase])-distance[si,oi])<=2e-15
                    assert abs(float(c['C_'+phase])-native[si,oi,3])<=2e-15
                    assert abs(float(c['theta_'+phase])-native[si,oi,4])<=2e-15
                expected_bits=sum(1<<int(r['step']) for r in pp if r['inside_pair_wide']=='True')
                assert literal(prefix+'PairHistory','History')==(owner,expected_bits),'Pair crossing history mismatch'
                count['crossing_records']+=1;count['pair_history_bits']+=steps+1
        pp=[r for r in pair if r['run']==tag];cols=['pair_initial_inside_origin','pair_initial_outside_origin','later_source','native_C']
        assert tuples(f'run{j}PairOrigins','PairOrigin')==[tuple(number(r[k]) for k in cols) for r in pp],'Separate pair-origin decimal mismatch'
        count['separate_pair_origin_accounts']+=len(pp)
        with np.load(DATA/f'{tag}-memory-payloads.npz') as z:
            entry=[(int(k),v.tobytes()) for k,v in zip(z['entry_ids'],z['entry_payloads']) if k>=0]
            snapshots=[[(int(k),v.tobytes()) for k,v in zip(keys,vals) if k>=0] for keys,vals in zip(z['ids'],z['payloads'])]
        entrytext=re.search(r'def run'+str(j)+r'Entry : List \(Nat × Nat\) := (\[[^\n]*\])',text).group(1)
        assert record_list(entrytext)==entry,'Entry payload mismatch'
        assert [record_list(line) for line in block(f'run{j}Memory','List (List (Nat × Nat))').splitlines()]==snapshots,'Recorded shared payload mismatch'
        count['shared_record_payloads']+=sum(len(s) for s in snapshots)
        statement=re.search(r'theorem run'+str(j)+r'_reported_numerical_bounds : (.*?) := by decide',text).group(1)
        for k in MC:
            v=number(info[k]);s='('+str(v)+')' if v<0 else str(v)
            assert '('+s+' : Int)' in statement,'Reported bound source mismatch'
    return dict(status='PASS',**count,decimal_scale=str(scale),maximum_independent_stencil_error=max_stencil_error,source_data_match=True,scope='External source binding and floating-point stencil recount, not a Lean proof of simulation or interpolation.')
def self_test():
    text=(ROOT/'RecordedFollowing.lean').read_text(encoding='utf-8')
    tests=[('neighbor bit',r'def run0Label540Observers : List History := \[\n⟨\d+, (\d+)'),('neighbor identity',r'def run0Label540Observers : List History := \[\n⟨(\d+)'),('window decimal',r'def run0Label540Windows : List Account := \[\n⟨(\d+)'),('point origin decimal',r'def run0Label540Points : List Point := \[\n⟨\d+, (\d+)'),('shared record byte',r'def payload0 : Nat := (\d+)'),('material field',r'def run0Label540Fields : List FieldChange := \[\n⟨\d+, (\d+)'),('crossing time',r'def run0Label540Crossing : Crossing := ⟨\d+, \d+, \d+, (\d+)'),('pair history bit',r'def run0Label540PairHistory : History := ⟨\d+, (\d+)')]
    passed=[]
    for name,pattern in tests:
        match=re.search(pattern,text);assert match,pattern
        changed=text[:match.start(1)]+str(int(match.group(1))+1)+text[match.end(1):]
        try:check(changed)
        except AssertionError:passed.append(name)
        else:raise AssertionError('Altered evidence accepted: '+name)
    return passed
if __name__=='__main__':
    result=check()
    if '--self-test' in sys.argv:result['tamper_tests_passed']=self_test()
    print(json.dumps(result,indent=2))
