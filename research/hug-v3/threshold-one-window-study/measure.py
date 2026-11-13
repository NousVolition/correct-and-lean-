"""Signed vorticity-line windows, preserving the saved Fourier/periodic metric."""
import argparse, csv, json, time
from pathlib import Path
import numpy as np
from scipy.integrate import solve_ivp
from scipy.optimize import brentq

HERE=Path(__file__).resolve().parent
FREQ=np.arange(-5,6)
WINDOWS={'forward_075':(0,.75),'forward_150':(0,1.5),'forward_300':(0,3),
         'both_075':(-.75,.75),'both_150':(-1.5,1.5),'both_300':(-3,3)}
def field_at(hat,points):
    p=np.asarray(points).reshape(-1,3)
    exp=np.exp(2j*np.pi*((p+.5)%1.)[:,:,None]*FREQ)
    xsum=np.tensordot(exp[:,0],hat,axes=(1,0))
    xysum=np.einsum('pj,pjkc->pkc',exp[:,1],xsum)
    return np.einsum('pk,pkc->pc',exp[:,2],xysum).real.reshape(np.asarray(points).shape)
def periodic(x): return x-np.rint(x)

def measure(omega,pair,tighter=False):
    A,B=pair
    rtol,atol,max_step,spacing=(2e-13,3e-15,.002,1/8192) if tighter else (2e-12,3e-14,.004,1/4096)
    low_rhs=np.inf
    def rhs(s,p):
        nonlocal low_rhs
        w=field_at(omega,p);norm=np.linalg.norm(w)
        low_rhs=min(low_rhs,norm)
        if norm<1e-10:raise RuntimeError('Unresolved near-zero vorticity direction')
        return w/norm
    pieces=[]
    for direction in (1,-1):
        p=A.copy();start=0.
        for length in (.75,1.5,3.):
            end=direction*length
            sol=solve_ivp(rhs,(start,end),p,method='DOP853',rtol=rtol,atol=atol,
                          dense_output=True,max_step=max_step)
            assert sol.success,sol.message
            pieces.append((min(start,end),max(start,end),sol))
            p=sol.y[:,-1];start=end
    # The common signed curve is integrated in pieces. Window restrictions use
    # identical curve values; adding a window cannot change an earlier trace.
    def curve(s):
        for lo,hi,sol in pieces:
            if lo-1e-15<=s<=hi+1e-15:return sol.sol(s)
        raise ValueError(s)
    def slope(s):
        p=curve(s)
        return float(np.dot(periodic(p-B),rhs(s,p)))
    def at(s,kind):
        p=curve(s)
        return {'s':float(s),'d':float(np.linalg.norm(periodic(p-B))),
                'p':p.tolist(),'kind':kind}
    roots=[];sample_min=[];min_sampled_omega=np.inf;line_s=[];line_p=[]
    for lo,hi,sol in pieces:
        grid=np.unique(np.r_[np.arange(lo,hi,spacing),lo,hi,sol.t])
        xyz=sol.sol(grid).T
        w=np.concatenate([field_at(omega,a) for a in np.array_split(xyz,32)])
        norms=np.linalg.norm(w,axis=1)
        min_sampled_omega=min(min_sampled_omega,float(norms.min()))
        proj=np.einsum('ij,ij->i',periodic(xyz-B),w)/norms
        for i in np.flatnonzero((proj[:-1]<0)&(proj[1:]>=0)):
            s=brentq(slope,grid[i],grid[i+1],xtol=1e-14)
            if abs(slope(s))<2e-9:roots.append(at(s,'interior'))
        sample_min.append((lo,hi,float(np.linalg.norm(periodic(xyz-B),axis=1).min())))
        display=np.linspace(lo,hi,round((hi-lo)*512)+1)
        line_s.extend(display);line_p.extend(sol.sol(display).T)
    roots.sort(key=lambda r:r['s'])
    dedup=[]
    for r in roots:
        if not dedup or abs(r['s']-dedup[-1]['s'])>1e-9:dedup.append(r)
    roots=dedup
    windows={}
    for name,(lo,hi) in WINDOWS.items():
        candidates=[r for r in roots if lo<r['s']<hi]+[at(lo,'left endpoint'),at(hi,'right endpoint')]
        candidates.sort(key=lambda r:r['d'])
        winner=candidates[0]
        sampled=min(v for a,b,v in sample_min if lo<=a and b<=hi)
        assert winner['d']<=sampled+2e-10,(name,winner['d'],sampled)
        # Arclength parametrization gives a one-Lipschitz distance. This checks
        # the discovered minimum against the dense search, not an exact proof.
        assert sampled-winner['d']<=spacing+2e-10
        windows[name]={'bounds':[lo,hi],'winner':winner,'candidates':candidates,
                       'sampled_minimum':sampled}
    for a,(alo,ahi) in WINDOWS.items():
        for b,(blo,bhi) in WINDOWS.items():
            if blo<=alo and ahi<=bhi:
                assert windows[b]['winner']['d']<=windows[a]['winner']['d']+2e-12
    order=np.argsort(line_s)
    return {'windows':windows,'min_rhs_omega':float(low_rhs),
            'min_sampled_omega':min_sampled_omega,'join_error':float(np.linalg.norm(curve(0)-A)),
            'settings':{'rtol':rtol,'atol':atol,'max_step':max_step,'search_spacing':spacing},
            'line_s':np.array(line_s)[order].tolist(),'line_p':np.array(line_p)[order].tolist()}

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--tighter',action='store_true')
    parser.add_argument('--events-only',action='store_true')
    parser.add_argument('--reuse-events',action='store_true',help='Reuse the completed same-setting event pilot')
    args=parser.parse_args()
    meta=json.loads((HERE/'snapshots.json').read_text())
    with np.load(HERE/'snapshots.npz') as z: omega,pairs=z['omega'],z['pairs']
    name='measurements-tight' if args.tighter else 'measurements'
    if args.events_only and not args.tighter:name+='-events'
    cache={}
    if args.reuse_events:
        assert not args.tighter
        cache={r['label']:r for r in json.loads((HERE/'measurements-events.json').read_text())}
    rows=[];flat=[];begin=time.perf_counter()
    for sample in meta:
        if args.events_only and not sample['label'].startswith('event-'):continue
        k=sample['index']
        if sample['label'] in cache:
            row=cache[sample['label']]
            assert row['time']==sample['time'] and np.array_equal(np.array([row['A'],row['B']]),pairs[k])
        else:
            row=dict(sample,**measure(omega[k],pairs[k],args.tighter))
        row['A'],row['B']=pairs[k].tolist()
        if 'saved_winner' in row:
            old,new=row['saved_winner'],row['windows']['forward_075']['winner']
            row['saved_distance_error']=abs(old['d']-new['d'])
            row['saved_arc_error']=abs(old['s']-new['s'])
            assert row['saved_distance_error']<2e-9,(sample['label'],row['saved_distance_error'])
            assert row['saved_arc_error']<2e-7,(sample['label'],row['saved_arc_error'])
        rows.append(row)
        for window,r in row['windows'].items():
            flat.append(dict(label=row['label'],time=row['time'],window=window,**{q:r['winner'][q] for q in ('s','d','kind')}))
        (HERE/(name+'.json')).write_text(json.dumps(rows,separators=(',',':'))+'\n')
        print(json.dumps({'label':sample['label'],'time':sample['time'],
              'winners':{n:[r['winner']['s'],r['winner']['d']] for n,r in row['windows'].items()},
              'elapsed':time.perf_counter()-begin}),flush=True)
    with (HERE/(name+'.csv')).open('w',newline='') as f:
        writer=csv.DictWriter(f,fieldnames=list(flat[0]));writer.writeheader();writer.writerows(flat)
if __name__=='__main__':main()
