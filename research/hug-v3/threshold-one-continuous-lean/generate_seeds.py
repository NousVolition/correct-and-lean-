"""Transcribe the six exact binary seed/target pairs; this is provenance code."""
import argparse,hashlib,json
from pathlib import Path
import numpy as np

def generate(study,output):
    labels=[f'event-{event}-{side}' for event in (1,2,3) for side in ('left','right')]
    records={row['label']:row for row in json.loads((study/'snapshots.json').read_text())}
    with np.load(study/'snapshots.npz',allow_pickle=False) as data:
        pairs=[data['pairs'][records[label]['index']].copy() for label in labels]
    denominator=2**80
    def numerator(value):
        p,q=float(value).as_integer_ratio()
        if denominator%q:raise ValueError('Coordinate is not representable at the fixed denominator')
        return p*(denominator//q)
    arrays=[[[numerator(value) for value in pair[which]] for pair in pairs] for which in (0,1)]
    def lean_array(rows):return '!['+',\n'.join('!['+', '.join(map(str,row))+']' for row in rows)+']'
    source='\n'.join([
        'import FrozenField','namespace FrozenSeeds','open FrozenField',
        f'def denominator : ℤ := {denominator}',
        'theorem denominator_positive : 0 < denominator := by decide',
        'def seedNumerator : Fin 6 → Fin 3 → ℤ := '+lean_array(arrays[0]),
        'def targetNumerator : Fin 6 → Fin 3 → ℤ := '+lean_array(arrays[1]),
        'noncomputable def seed (snapshot : Fin 6) : Point :=',
        '  fun i => (seedNumerator snapshot i : ℝ) / denominator',
        'noncomputable def target (snapshot : Fin 6) : Point :=',
        '  fun i => (targetNumerator snapshot i : ℝ) / denominator',
        'end FrozenSeeds',''])
    output.mkdir(parents=True,exist_ok=True)
    target=output/'FrozenSeeds.lean'
    target.write_text(source,encoding='utf-8',newline='\n')
    digest=lambda path:hashlib.sha256(path.read_bytes()).hexdigest()
    record={'status':'INPUT_TRANSCRIPTION_ONLY','denominator':str(denominator),
        'source_files':{name:digest(study/name) for name in ('snapshots.npz','snapshots.json')},
        'labels':labels,'indices':[records[label]['index'] for label in labels],
        'seed_and_target_hex':[[[float(x).hex() for x in row] for row in pair] for pair in pairs],
        'generated_lean_sha256':digest(target)}
    (output/'seed-inputs.json').write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8',newline='\n')
    return record

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--study-dir',type=Path,required=True)
    parser.add_argument('--out-dir',type=Path,required=True);args=parser.parse_args()
    print(json.dumps(generate(args.study_dir,args.out_dir)),flush=True)
