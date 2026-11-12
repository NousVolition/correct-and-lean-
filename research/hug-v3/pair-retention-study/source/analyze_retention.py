"""Independent recount of stored retention observations. No solver steps."""
import csv, hashlib, json, sys, zlib, struct
from pathlib import Path
from decimal import Decimal
import numpy as np
from scipy.ndimage import map_coordinates
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/"outputs/pair25-retention"
LEAN=ROOT/"outputs/pair25-retention-lean"
TAGS=["n40_dt0p0005","n48_dt0p0005","n48_dt0p00025"]
def digest(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def read_csv(p):
    with p.open(newline="",encoding="utf-8") as f:return list(csv.DictReader(f))
def independent_sample(g,points):
    xyz=(((points+.5)%1)*g.shape[0]).T
    return np.stack([map_coordinates(g[...,c],xyz,order=1,mode="grid-wrap",prefilter=False) for c in range(5)],axis=1)
def payload_check(entry,entry_ids,payloads,ids):
    old={int(k):v.tobytes() for k,v in zip(entry_ids,entry) if k>=0}
    counts=[];retained=True;crcs=True;unique=True
    for values,keys in zip(payloads,ids):
        live=[int(k) for k in keys if k>=0];unique &= len(live)==len(set(live))
        now={int(k):v.tobytes() for k,v in zip(keys,values) if k>=0}
        retained &= all(now.get(k)==v for k,v in old.items())
        counts.append(len(now))
        for v in now.values():crcs &= zlib.crc32(v[:-4])==struct.unpack("<I",v[-4:])[0]
    return dict(all_entry_payloads_retained=bool(retained),all_payload_crcs_valid=bool(crcs),
                unique_record_keys=bool(unique),record_counts=counts,entry_records=len(old))

def validate_rows(rows,tag):
    expected={(round(1.2+i*.002,6),p,f) for i in range(51) for p in ["A","B"] for f in ["C","theta"]}
    keys=[(round(float(r["time"]),6),r["point"],r["field"]) for r in rows]
    assert len(keys)==len(set(keys))==204 and set(keys)==expected,"Missing, duplicate or mislabelled observation"
    assert all(r["run"]==tag for r in rows)
    maximum=0.
    for r in rows:
        defect=float(r["current"])-float(r["entry"])-sum(float(r[k]) for k in ["diffusion_or_conduction","source_or_heat_exchange","advection_interpolation"])
        assert abs(defect-float(r["residual"]))<2e-15,"Recorded budget residual differs"
        assert abs(float(r["change"])-(float(r["current"])-float(r["entry"])))<2e-15
        maximum=max(maximum,abs(defect))
    return maximum

def analyze():
    results=[];allrows={};sample_payloads={};input_hashes={}
    for tag in TAGS:
        p=OUT/tag
        status=json.loads((p/"status.json").read_text())
        assert status["status"]=="complete",tag+" incomplete"
        result=json.loads((p/"result.json").read_text())
        assert result["start"]==1.2 and result["end"]==1.3 and result["samples"]==51
        assert result["code_sha256"]==digest(ROOT/"work/pair25-retention/run_retention.py")
        for rel,h in result["input_hashes"].items():assert digest(ROOT/rel)==h
        rows=read_csv(p/"local-budgets.csv");max_residual=validate_rows(rows,tag);allrows[tag]=rows
        global_rows=read_csv(p/"global-accounts.csv")
        assert len(global_rows)==51
        assert [round(float(r["time"]),6) for r in global_rows]==[round(1.2+i*.002,6) for i in range(51)]
        with np.load(p/"record-payloads.npz") as z:
            pa,ids,ep,ei,times=(z[k].copy() for k in ["payloads","ids","entry_payloads","entry_ids","times"])
        assert pa.shape[0:2]==(51,4) and ids.shape==(51,4)
        assert list(ei)==[0,1,2,-1]
        payloads=payload_check(ep,ei,pa,ids)
        for item,r in zip(payloads["record_counts"],global_rows):assert item==int(r["records"])
        assert payloads["all_entry_payloads_retained"]==all(r["entry_records_retained"]=="True" for r in global_rows)
        sample_payloads[tag]=(ep,ei,pa,ids)
        with np.load(p/"entry-state.npz") as z:entry={k:z[k] for k in z.files}
        with np.load(ROOT/"outputs/fluid-finer-grid"/tag/"final-state.npz") as z:
            assert set(z.files)==set(entry)
            assert all(np.array_equal(entry[k],z[k]) for k in z.files)
        with np.load(p/"exit-state.npz") as z:exit_state={k:z[k] for k in z.files}
        with np.load(p/"pair-positions.npz") as z:positions=z["positions"]
        assert positions.shape==(51,2,3)
        np.testing.assert_array_equal(positions[0],entry["observer_X"][[825,850]])
        np.testing.assert_array_equal(positions[-1],exit_state["observer_X"][[825,850]])
        local_inventory=[]
        for t,state,pos in [(1.2,entry,positions[0]),(1.3,exit_state,positions[-1])]:
            vals=independent_sample(state["g"],pos)
            selected={(r["point"],r["field"]):r for r in rows if float(r["time"])==t}
            for i,point in enumerate(["A","B"]):
                local_inventory.append(dict(time=t,point=point,position=pos[i].tolist(),
                    values=dict(zip(['vx','vy','vz','C','theta'],map(float,vals[i])))))
                for j,field in [(3,"C"),(4,"theta")]:
                    assert abs(vals[i,j]-float(selected[point,field]["current"]))<2e-14,"Independent endpoint readout mismatch"
        inv={r["name"]:r for r in result["inventory"]}
        assert set(inv)==set(entry)==set(exit_state) and len(inv)==17
        for k in inv:
            assert inv[k]["entry_array_sha256"]==hashlib.sha256(entry[k].tobytes()).hexdigest()
            assert inv[k]["exit_array_sha256"]==hashlib.sha256(exit_state[k].tobytes()).hexdigest()
            assert inv[k]["changed"]==(not np.array_equal(entry[k],exit_state[k]))
            assert abs(inv[k]["max_absolute_change"]-float(abs(entry[k]-exit_state[k]).max()))<1e-15
        global_c=max(abs(float(r["context_increment"])-float(r["context_source_increment"])) for r in global_rows)
        global_e=max(abs(float(r["energy_increment"])-float(r["external_work_increment"])) for r in global_rows)
        assert abs(max_residual-result["metrics"]["max_local_budget_residual"])<2e-15
        assert abs(global_c-result["metrics"]["max_context_ledger_residual"])<2e-15
        assert abs(global_e-result["metrics"]["max_energy_ledger_residual"])<2e-15
        assert result["criteria"]["local_budget_target_met"]==(max_residual<=1e-6)
        assert result["criteria"]["record_payloads_retained"]==payloads["all_entry_payloads_retained"]
        final_m_increment=float((exit_state["m"]-entry["m"]).min())
        results.append(dict(run=tag,criteria=result["criteria"],metrics=result["metrics"],
            independent_max_local_residual=max_residual,independent_endpoint_min_m_increment=final_m_increment,
            record_check=payloads,unchanged_state_arrays=[k for k,v in inv.items() if not v["changed"]],
            changed_state_arrays=[k for k,v in inv.items() if v["changed"]],
            endpoint=[r for r in rows if float(r["time"])==1.3],
            endpoint_positions=positions[-1].tolist(),local_fluid_entry_exit=local_inventory))
        for name in ["result.json","local-budgets.csv","global-accounts.csv","record-payloads.npz","entry-state.npz","exit-state.npz","pair-positions.npz"]:
            input_hashes[str((p/name).relative_to(ROOT))]=digest(p/name)
    comparisons=[]
    for a,b in [(TAGS[0],TAGS[1]),(TAGS[1],TAGS[2])]:
        aa={(r["time"],r["point"],r["field"]):r for r in allrows[a]}
        bb={(r["time"],r["point"],r["field"]):r for r in allrows[b]}
        assert aa.keys()==bb.keys()
        for f in ["C","theta"]:
            vals=[(abs(float(aa[k]["current"])-float(bb[k]["current"])),k) for k in aa if k[2]==f]
            maximum,key=max(vals)
            comparisons.append(dict(coarse=a,fine=b,field=f,max_readout_difference=maximum,
                                     worst_time=float(key[0]),worst_point=key[1],
                                     scope="Differences reported; no grid-convergence threshold declared for this new readout."))
    answer=dict(
       outcome="finite entry/exit accounts and record-retention observations completed",
       scope="New continuation 1.2 after write to1.3; same passive pair ID24. No private material parcel or complete recoverability theorem.",
       runs=results,comparisons=comparisons,
       record_payload_checks=sum(51*r["record_check"]["entry_records"] for r in results),
       local_budget_rows=sum(len(v) for v in allrows.values()),
       per_run_common_times=51,all_native_state_fields_classified=17,
       complete_private_inventory_established=False,
       source_inputs_sha256=input_hashes,
       source_observations_preserved=True,
       independent_check_scope="Recount of saved payload bytes, coverage, exact input arrays, endpoint readout via separate interpolation, native-field inventory and numerical budgets. Stage extrema were inspected by the running instrument and are not independently replayed here.",
    )
    (OUT/"analysis.json").write_text(json.dumps(answer,indent=2)+"\n",encoding="utf-8")
    return answer,allrows,sample_payloads

def generate_lean(answer,allrows,sample_payloads):
    sys.set_int_max_str_digits(20000)
    numeric_cols=["entry","current","diffusion_or_conduction","source_or_heat_exchange","advection_interpolation"]
    numeric_values=[r[k] for rows in allrows.values() for r in rows for k in numeric_cols]
    all_global={tag:read_csv(OUT/tag/'global-accounts.csv') for tag in TAGS}
    for rows in all_global.values():
        numeric_values += [r[k] for r in rows for k in ['context_increment','context_source_increment','energy_increment','external_work_increment']]
    for result in answer['runs']:
        numeric_values += [str(result['metrics'][k]) for k in ['minimum_m_rate','minimum_m_increase','minimum_m_step_increment','minimum_b_read_margin']]
    places=max(-Decimal(v).as_tuple().exponent for v in numeric_values)
    places=max(places,18);scale=10**places
    def numerator(v):
        d=Decimal(v)
        # Decimal arithmetic's default precision is not used for the conversion.
        sign,digits,exp=d.as_tuple()
        integer=int("".join(map(str,digits))) if digits else 0
        return (-1 if sign else 1)*integer*10**(exp+places)
    def lean_int(x):return "("+str(x)+")" if x<0 else str(x)
    pieces=["import CarryingInventory","set_option maxRecDepth 100000","set_option maxHeartbeats 10000000",
            "namespace RecordedRetention","open CarryingInventory",
            f"def decimalScale : Nat := {scale}",
            f"def localTolerance : Nat := {scale//10**6}"]
    payload_names={}
    def payload_name(raw):
        data=bytes(raw)
        if data not in payload_names:
            name="payload"+str(len(payload_names));payload_names[data]=name
            encoded=(1 << (8*len(data)))+int.from_bytes(data,"big")
            pieces.append(f"def {name} : Nat := {encoded}")
        return payload_names[data]
    records={}
    for j,tag in enumerate(TAGS):
        ep,ei,pa,ids=sample_payloads[tag]
        record_list=lambda data,keys:"["+", ".join(
            f"⟨{int(key)}, {payload_name(value)}⟩" for key,value in zip(keys,data) if key>=0)+"]"
        entry=record_list(ep,ei)
        snapshots=[record_list(v,k) for v,k in zip(pa,ids)]
        records[tag]=(entry,snapshots)
    targets=[]
    for j,tag in enumerate(TAGS):
        prefix=f"run{j}"
        entry,snapshots=records[tag]
        pieces += [f"def {prefix}Entry : List Record := {entry}",
                   f"def {prefix}Snapshots : List (List Record) := [\n"+",\n".join(snapshots)+"\n]"]
        statements={
           f"{prefix}_sample_count":f"{prefix}Snapshots.length = 51",
           f"{prefix}_keys_unique":f"∀ s ∈ {prefix}Snapshots, UniqueKeys s",
           f"{prefix}_original_records_present":f"∀ s ∈ {prefix}Snapshots, Preserves {prefix}Entry s",
        }
        if not answer["runs"][j]["record_check"]["all_entry_payloads_retained"]:
            statements[f"{prefix}_original_records_present"]="¬ ("+statements[f"{prefix}_original_records_present"]+")"
        for name,statement in statements.items():
            pieces.append(f"theorem {name} : {statement} := by decide");targets.append("RecordedRetention."+name)
        rows=allrows[tag]
        account_terms=["⟨"+", ".join(lean_int(numerator(r[k])) for k in numeric_cols)+"⟩" for r in rows]
        pieces.append(f"def {prefix}Accounts : List Account := [\n"+",\n".join(account_terms)+"\n]")
        keys=[int(round((float(r["time"])-1.2)/.002))*4+(0 if r["point"]=="A" else 2)+(0 if r["field"]=="C" else 1) for r in rows]
        pieces.append(f"def {prefix}Keys : List Nat := ["+",".join(map(str,keys))+"]")
        pieces.append(f"theorem {prefix}_coverage : {prefix}Keys = List.range 204 := by decide")
        targets.append(f"RecordedRetention.{prefix}_coverage")
        pieces.append(f"theorem {prefix}_account_count : {prefix}Accounts.length = 204 := by decide")
        targets.append(f"RecordedRetention.{prefix}_account_count")
        passed=all(abs(numerator(r["current"])-numerator(r["entry"])-sum(numerator(r[k]) for k in numeric_cols[2:]))<=scale//10**6 for r in rows)
        assert passed==answer["runs"][j]["criteria"]["local_budget_target_met"]
        claim=f"∀ a ∈ {prefix}Accounts, Within a localTolerance"
        if not passed:claim="¬ ("+claim+")"
        pieces.append(f"theorem {prefix}_recorded_budget_verdict : {claim} := by decide")
        targets.append(f"RecordedRetention.{prefix}_recorded_budget_verdict")
        for field,changed,supplied,power in [('Context','context_increment','context_source_increment',10),('Energy','energy_increment','external_work_increment',6)]:
            terms=['⟨0, '+lean_int(numerator(r[changed]))+', 0, '+lean_int(numerator(r[supplied]))+', 0⟩' for r in all_global[tag]]
            pieces.append(f'def {prefix}{field} : List Account := [\n'+',\n'.join(terms)+'\n]')
            good=all(abs(numerator(r[changed])-numerator(r[supplied]))<=scale//10**power for r in all_global[tag])
            statement=f'∀ a ∈ {prefix}{field}, Within a {scale//10**power}'
            if not good: statement='¬ ('+statement+')'
            name=f'{prefix}_{field.lower()}_ledger_verdict'
            pieces.append(f'theorem {name} : {statement} := by decide');targets.append('RecordedRetention.'+name)
        m=answer['runs'][j]['metrics']
        checks=[f'{lean_int(numerator(str(m[k])))} ≥ {lean_int(-scale//10**14)}' for k in ['minimum_m_increase','minimum_m_step_increment']]
        checks += [f'{lean_int(numerator(str(m["minimum_m_rate"])))} ≥ (0 : Int)',f'{lean_int(numerator(str(m["minimum_b_read_margin"])))} ≥ ({scale*5//1000} : Int)',f'({m["maximum_b_sign_flips"]} : Nat) = 0']
        name=f'{prefix}_reported_memory_extrema'
        pieces.append(f'theorem {name} : '+' ∧ '.join(checks)+' := by decide');targets.append('RecordedRetention.'+name)
    pieces.append("end RecordedRetention")
    LEAN.mkdir(exist_ok=True)
    (LEAN/"RecordedRetention.lean").write_text("\n\n".join(pieces)+"\n",encoding="utf-8")
    general=["preserves_self","preserves_through","original_payload_still_present",
             "same_key_can_lose_payload","missing_record_is_not_retained",
             "balanced_zero_exchange_preserves_value","accounted_change_need_not_be_zero",
             "balanced_replacement_need_not_retain_contents",
             "missing_coverage_blocks_complete_claim","complete_claim_includes_payloads"]
    all_targets=["CarryingInventory."+x for x in general]+targets
    (LEAN/"CheckAxioms.lean").write_text("import RecordedRetention\n"+"\n".join("#print axioms "+x for x in all_targets)+"\n",encoding="utf-8")
    (LEAN/"targets.json").write_text(json.dumps(all_targets,indent=2)+"\n",encoding="utf-8")
    (LEAN/"data-generation.json").write_text(json.dumps(dict(
        decimal_places=places,exact_decimal_scale=str(scale),
        unique_complete_payloads=len(payload_names),payload_encoding="2^(8*byte_length) + big-endian payload integer",
        payload_bytes_in_dictionary=sum(map(len,payload_names)),targets=len(all_targets),
        source_sha256=digest(OUT/"analysis.json"),generator_sha256=digest(__file__),
        scope="Exact finite payload and decimal assertions from saved observations; no fluid solver verified."
    ),indent=2)+"\n",encoding="utf-8")
    return len(all_targets)

if __name__=="__main__":
    result,rows,records=analyze()
    count=generate_lean(result,rows,records)
    print(json.dumps(dict(runs=[{k:v for k,v in r.items() if k in ["run","criteria","metrics"]} for r in result["runs"]],
        payload_checks=result["record_payload_checks"],budget_rows=result["local_budget_rows"],
        comparisons=result["comparisons"],lean_targets_generated=count,lean_has_run=False),indent=2))
