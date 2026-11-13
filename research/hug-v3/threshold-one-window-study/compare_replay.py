"""Compare a disposable replay with the untouched, sealed published evidence."""
import argparse,hashlib,json
from pathlib import Path
import numpy as np

HERE=Path(__file__).resolve().parent
def load(p):return json.loads(p.read_text(encoding='utf-8'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('replayed',type=Path)
    parser.add_argument('--output',type=Path)
    args=parser.parse_args()
    other=args.replayed.resolve()
    assert other!=HERE,'Use a disposable replay copy'
    seal=load(HERE/'bundle-sha256.json')
    regenerated={'snapshots.npz','snapshots.json','replay-checks.json','measurements.json',
                 'measurements.csv','measurements-tight.json','measurements-tight.csv'}
    for name,expected in seal.items():
        assert sha(HERE/name)==expected,'Published evidence changed: '+name
        if name not in regenerated:
            assert sha(other/name)==expected,'Replay code/input changed: '+name
    with np.load(HERE/'snapshots.npz') as a,np.load(other/'snapshots.npz') as b:
        errors={k:float(np.max(abs(a[k]-b[k]))) for k in a.files}
        assert errors['pairs']<2e-14
        assert errors['omega']<3e-12
    maximum_d=maximum_s=0.
    for name,count in [('measurements.json',40),('measurements-tight.json',6)]:
        before=load(HERE/name);after=load(other/name)
        assert len(before)==len(after)==count
        for a,b in zip(before,after,strict=True):
            assert (a['label'],a['time'])==(b['label'],b['time'])
            for window in a['windows']:
                x,y=a['windows'][window]['winner'],b['windows'][window]['winner']
                maximum_d=max(maximum_d,abs(x['d']-y['d']))
                maximum_s=max(maximum_s,abs(x['s']-y['s']))
    assert maximum_d<2e-9 and maximum_s<2e-7
    result={'status':'PASS','kind':'Numerical replay comparison; no Lean proof',
            'replayed_states':40,'replayed_window_readings':240,'replayed_tighter_readings':36,
            'snapshot_max_abs_errors':errors,'max_distance_difference':maximum_d,
            'max_arclength_difference':maximum_s,'published_bundle_unchanged':True,
            'replayed_code_and_inputs_match':True}
    if args.output:args.output.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(result,indent=2))
if __name__=='__main__':main()
