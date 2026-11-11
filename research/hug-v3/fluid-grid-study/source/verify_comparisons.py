"""Independent checks of consequential cross-resolution gap and field results."""
import numpy as np
import json,hashlib
from run_study import OUT,coeff,curl,at,trace,nearest,dump,readcsv
from compare_results import TAGS,PAIRS,gaps,CONVENTIONS,savecsv

fieldrows=readcsv(OUT/'field-comparisons.csv');checks=[];gapchecks=[]
cache_path=OUT/'independent-check-inputs.json'
cache=json.loads(cache_path.read_text(encoding='utf-8')) if cache_path.exists() else {}
prior_fields=readcsv(OUT/'independent-field-checks.csv') if (OUT/'independent-field-checks.csv').exists() else []
prior_gaps=readcsv(OUT/'independent-spatial-gap-checks.csv') if (OUT/'independent-spatial-gap-checks.csv').exists() else []
new_cache={}
for name,left,right in PAIRS:
    if not (OUT/left/'summary.json').exists() or not (OUT/right/'summary.json').exists():continue
    inputs={}
    for tag in [left,right]:
        for filename in ['prime-fields.npz','window.npz',('gaps_grid192_ds1024_consistent.csv' if tag==TAGS[0] else 'gaps_grid192_ds1024.csv')]:
            path=OUT/tag/filename;inputs[f'{tag}/{filename}']=hashlib.sha256(path.read_bytes()).hexdigest()
    new_cache[name]=inputs
    if cache.get(name)==inputs:
        for row in prior_fields:
            if row['comparison']==name:
                checks.append({k:(float(v) if k not in ['comparison','quantity'] else v) for k,v in row.items()})
        for row in prior_gaps:
            if row['comparison']==name:
                gapchecks.append({k:(v if k in ['comparison','convention','window'] else int(v) if k=='seed' else float(v)) for k,v in row.items()})
        print('Reused unchanged independent checks',name,flush=True)
        continue
    # Parseval computes the L2 norm without the shared comparison lattice.
    states=[]
    for tag in [left,right]:
        with np.load(OUT/tag/'prime-fields.npz') as z:g=z['g'][-1]
        f,h=coeff(g[...,:3],g.shape[0]);states.append((f,h,curl(h,f)))
    lo=min(s[0].min() for s in states);hi=max(s[0].max() for s in states)
    for k,quantity in [(1,'velocity'),(2,'vorticity')]:
        padded=[]
        for state in states:
            p=np.zeros((hi-lo+1,)*3+(3,),complex);ix=state[0]-lo
            p[np.ix_(ix,ix,ix)]=state[k];padded.append(p)
        error=float(np.sqrt(np.sum(abs(padded[1]-padded[0])**2)))
        reference=float(np.sqrt(np.sum(abs(padded[1])**2)))
        row=next(r for r in fieldrows if r['comparison']==name and r['quantity']==quantity and abs(float(r['time'])-1.2)<1e-12)
        discrepancy=abs(error-float(row['absolute_l2']))
        assert discrepancy<1e-13
        checks.append(dict(comparison=name,quantity=quantity,parseval_absolute_l2=error,
                           parseval_relative_l2=error/reference,common_grid_absolute_l2_difference=discrepancy))
    if not name.startswith('space'):continue
    times,a=gaps(left);_,b=gaps(right)
    for c,convention in enumerate(CONVENTIONS):
        j,seed,window=np.unravel_index(np.argmax(abs(b[:,c,:,:2]-a[:,c,:,:2])),a[:,c,:,:2].shape)
        values=[];low=[]
        for tag in [left,right]:
            with np.load(OUT/tag/'window.npz') as z:
                f=z['freq'];h=curl(z['velocity'][j],f);obs=z['observers'][j]
            first=obs[seed+(0 if c==0 else 75)][None]
            second=obs[seed+(25 if c==0 else 100)][None]
            path,m=trace(lambda p:at(h,f,p),first,1/2048,.75)
            distance,s=nearest(path[:769] if window==0 else path,second)
            values.append(float(distance[0]));low.append(m)
        primary=float(b[j,c,seed,window]-a[j,c,seed,window]);direct=values[1]-values[0]
        gapchecks.append(dict(comparison=name,convention=convention,time=float(times[j]),seed=int(seed),
            window='local' if window==0 else 'extended',primary_difference=primary,direct_ds2048_difference=direct,
            discrepancy=abs(primary-direct),coarse_direct_gap=values[0],fine_direct_gap=values[1],minimum_direction=min(low)))
        print('DIRECT SPATIAL CHECK',gapchecks[-1],flush=True)
savecsv(OUT/'independent-field-checks.csv',checks)
savecsv(OUT/'independent-spatial-gap-checks.csv',gapchecks)
dump(cache_path,new_cache)
dump(OUT/'independent-check-summary.json',dict(
    parseval_field_checks=len(checks),max_common_grid_parseval_discrepancy=max(r['common_grid_absolute_l2_difference'] for r in checks),
    direct_spatial_worst_case_checks=len(gapchecks),max_primary_direct_spatial_discrepancy=max(r['discrepancy'] for r in gapchecks)))
