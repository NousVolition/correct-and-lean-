"""Measure finite-window gaps separately from the fluid integration."""
import argparse,csv,json,time
from pathlib import Path
import numpy as np
from run_study import OUT,ARCHIVE,curl,cubic,at,trace,nearest,dump,readcsv

def measure(tag,ds=1/512,grid=128,endpoints=False,direct=False,window_name='window.npz',suffix=''):
    folder=OUT/tag
    label=('direct' if direct else 'grid'+str(grid))+'_ds'+str(round(1/ds))+suffix
    file=folder/('gaps_'+label+('_endpoints' if endpoints else '')+'.csv')
    if file.exists():raise FileExistsError(file)
    with np.load(folder/window_name) as z:
        vel=z['velocity'];f=z['freq'];obs=z['observers'];times=z['times']
    rows=[];start=time.monotonic();minimum=np.inf
    for j in ([0,50] if endpoints else range(51)):
        w=curl(vel[j],f)
        evaluator=(lambda p:at(w,f,p)) if direct else cubic(w,f,grid)
        a=np.vstack([obs[j,:25],obs[j,75:100]])
        b=np.vstack([obs[j,25:50],obs[j,100:125]])
        path,low=trace(evaluator,a,ds,.75);minimum=min(minimum,low)
        local,s_local=nearest(path[:round(.375/ds)+1],b)
        extended,s_ext=nearest(path,b)
        assert np.max(extended-local)<1e-13
        for k in range(50):
            rows.append(dict(run=tag,time=times[j],convention='fixed' if k<25 else 'reselected',
                seed=k%25,local_gap=local[k],extended_gap=extended[k],window_benefit=local[k]-extended[k],
                local_closest_arclength=s_local[k]*ds,extended_closest_arclength=s_ext[k]*ds,
                minimum_direction=low))
        if j%10==0 or endpoints:
            print(tag,label,'frame',j,'elapsed',round(time.monotonic()-start,1),
                  'fixed medians',np.median(local[:25]),np.median(extended[:25]),flush=True)
    with file.open('w',encoding='utf-8',newline='') as out:
        writer=csv.DictWriter(out,list(rows[0]));writer.writeheader();writer.writerows(rows)
    result=dict(run=tag,ds=ds,grid=None if direct else grid,direct=direct,minimum_direction=minimum,
                elapsed_seconds=time.monotonic()-start,rows=len(rows))
    if tag=='n16_dt0p002' and window_name=='window.npz':
        if direct:
            ref=readcsv(ARCHIVE/'10-direct-partners.csv')
            expected={(float(r['time']),int(r['seed'])):float(r['nearest_distance']) for r in ref}
            result['archived_direct_max_gap_error']=max(abs(r['extended_gap']-expected[r['time'],r['seed']]) for r in rows if r['convention']=='fixed')
        else:
            ref=readcsv(ARCHIVE/'10-prime37-to-41.csv')
            expected={(float(r['time']),int(r['seed'])):r for r in ref}
            result['archived_96grid_max_gap_error']=max(abs(r[our]-float(expected[r['time'],r['seed']][old])) for r in rows if r['convention']=='fixed' for our,old in [('local_gap','local_nearest_distance'),('extended_gap','extended_nearest_distance')])
    dump(file.with_suffix('.json'),result)
    print('MEASURE COMPLETE',tag,label,flush=True)

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('tag');p.add_argument('--ds',type=int,default=512)
    p.add_argument('--grid',type=int,default=128);p.add_argument('--endpoints',action='store_true');p.add_argument('--direct',action='store_true')
    p.add_argument('--window',default='window.npz');p.add_argument('--suffix',default='')
    a=p.parse_args();measure(a.tag,1/a.ds,a.grid,a.endpoints,a.direct,a.window,a.suffix)
