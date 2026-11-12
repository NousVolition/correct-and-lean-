"""Decode completed writes to explain differing CRCs without rerunning the fluid."""
import os,sys,json,struct
os.environ.setdefault('OPENBLAS_NUM_THREADS','1')
sys.dont_write_bytecode=True
from pathlib import Path
import numpy as np
from analyze_extension import ROOT,OUT,folder,digest,readjson,savecsv
from run_study import make_solver

TAGS=['n32_dt0p0005','n40_dt0p0005','n48_dt0p0005','n48_dt0p00025']

def main():
    decoded={};receipts=[];inputs={};quanta={}
    for tag in TAGS:
        p=folder(tag);summary=readjson(p/'summary.json')
        solver,_,_=make_solver(summary['n'])
        with np.load(p/'final-state.npz') as z:
            F=z['F'];b=z['b']
        records=solver.fabric.read(F,b)
        assert len(records)==3
        expected={r['event_id']:r for r in readjson(p/'events.json')}
        decoded[tag]={}
        quanta[tag]=solver.c.strain_quantum
        for slot,r in records:
            payload=solver.fabric.payload(r)
            crc=struct.unpack('<I',payload[-4:])[0]
            assert crc==expected[r['event_id']]['crc']
            assert r['end']==expected[r['event_id']]['time']
            decoded[tag][r['event_id']]=r
            receipts.append(dict(run=tag,slot=slot,event_id=r['event_id'],time=r['end'],
                receipt_crc=crc,repacked_crc_matches=True))
        for name in ['final-state.npz','events.json','summary.json']:
            inputs[str((p/name).relative_to(ROOT))]=digest(p/name)
        del solver,F,b
    comparisons=[]
    for left,right in zip(TAGS,TAGS[1:]):
        assert quanta[left]==quanta[right]
        for event in range(3):
            a,c=decoded[left][event],decoded[right][event]
            changed=[k for k in a if not np.array_equal(a[k],c[k])]
            d=np.asarray(c['delta_E'])-np.asarray(a['delta_E'])
            comparisons.append(dict(coarse=left,fine=right,event_id=event,time=a['end'],
                changed_fields='|'.join(changed),non_strain_fields_match=all(k=='delta_E' for k in changed),
                changed_strain_entries=int(np.count_nonzero(d)),total_strain_entries=int(d.size),
                max_recorded_strain_change=float(abs(d).max()),strain_quantum=quanta[left],
                max_quantization_steps=int(np.rint(abs(d).max()/quanta[left])),
                changed_action_entries=int(np.count_nonzero(np.asarray(c['actions'])-np.asarray(a['actions']))),
                max_recorded_action_change=float(abs(np.asarray(c['actions'])-np.asarray(a['actions'])).max()),
                records_identical=not changed))
    savecsv(OUT/'write-code-comparisons.csv',comparisons)
    inputs[str(Path(__file__).resolve().relative_to(ROOT))]=digest(Path(__file__))
    source=ROOT/'work/fluid-convergence/sealed-source/upstream/structural_hug.py'
    inputs[str(source.relative_to(ROOT))]=digest(source)
    result=dict(scope='Read-only decoding of completed material records; no new integration or Lean check.',
        all_repacked_crcs_match_receipts=True,decoded_records=len(receipts),receipts=receipts,
        comparisons=comparisons,input_hashes=inputs,
        crc_payload_scope='Event header, quantized context/recognition/authority/actions, and quantized material strain change; no fluid-grid metadata.',
        no_causal_attribution=True,
        endpoint_write_note='The third write at time 1.2 follows the sampled gap field and cannot cause the earlier gap difference at 1.182.')
    (OUT/'write-code-audit.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:v for k,v in result.items() if k not in ['input_hashes','receipts']},indent=2),flush=True)

if __name__=='__main__':main()
