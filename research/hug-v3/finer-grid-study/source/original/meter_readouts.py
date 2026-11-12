"""Extra meter readouts from saved fields, with exact time and run provenance."""
import os,sys,json,hashlib
os.environ.setdefault('OPENBLAS_NUM_THREADS','1')
sys.dont_write_bytecode=True
from pathlib import Path
import numpy as np
from analyze_extension import ROOT,OUT,OLD,ALL,NEW,COMPARISONS,folder,readjson,savecsv,load_gaps,digest,rows
from run_study import at,curl

PRIMES=[2,3,5,7,11,13,17,19,23,29,31,37,41]

def gradient(h,f,points):
    wave=np.stack(np.meshgrid(f,f,f,indexing='ij'),axis=-1)*2j*np.pi
    return np.stack([at(h*wave[...,axis,None],f,points) for axis in range(3)],axis=-1)

def check_gradient():
    f=np.arange(-1,2);h=np.zeros((3,3,3,3),complex)
    # u=(sin(2πy),0,0) in the physical coordinates used by the runner.
    # Coefficients include the runner's phase origin at x+0.5.
    h[1,2,1,0]=.5j;h[1,0,1,0]=-.5j
    pts=np.array([[.07,.13,-.2],[-.1,.21,.3],[.23,-.31,.01]])
    result=gradient(h,f,pts)
    expected=np.zeros_like(result);expected[:,0,1]=2*np.pi*np.cos(2*np.pi*pts[:,1])
    np.testing.assert_allclose(result,expected,rtol=0,atol=5e-14)
    return float(abs(result-expected).max())

def main():
    analytic_error=check_gradient()
    prime_rows=[];local_rows=[];comparisons=[];readouts={};inputs={}
    curl_error=0.0;ledger_error=0.0
    for tag in ALL:
        p=folder(tag);summary=readjson(p/'summary.json');diagnostics=readjson(p/'diagnostics.json')
        energy0=diagnostics[0]['energy']
        sides=set()
        for r in diagnostics:
            i=round(r['time']/.1);assert abs(r['time']-i*.1)<1e-12 and 0<=i<=12
            key=(i,r['side']);assert key not in sides;sides.add(key)
            expected_side={'before_write','after_write'} if i in [4,8,12] else {'at'}
            assert r['side'] in expected_side
            residual=r['energy']-energy0-r['source_work']-r['breathing_work']-r['write_work']
            ledger_error=max(ledger_error,abs(residual-r['energy_balance']))
            prime_rows.append(dict(run=tag,n=summary['n'],dt=summary['dt'],prime=PRIMES[i],
                model_time=r['time'],integration_step=round(r['time']/summary['dt']),side=r['side'],
                kinetic=r['kinetic'],elastic=r['elastic'],thermal=r['thermal'],energy=r['energy'],
                source_work=r['source_work'],breathing_work=r['breathing_work'],write_work=r['write_work'],
                signed_energy_balance=r['energy_balance'],recomputed_energy_balance=residual,
                divergence=r['div_error'],context_balance=r['C_balance'],memory=r['memory'],
                model_scalar_A_not_particle_A=r['A'],speed_rms=r['speed_rms'],max_speed=r['max_speed']))
        assert len(sides)==16
        times,gaps=load_gaps(tag)
        with np.load(p/'window.npz') as z:
            f=z['freq'];fields=z['velocity'];positions=z['observers'][:,:50]
        series=[]
        for j,t in enumerate(times):
            G=gradient(fields[j],f,positions[j])
            w=at(curl(fields[j],f),f,positions[j])
            w_from_G=np.stack([G[:,2,1]-G[:,1,2],G[:,0,2]-G[:,2,0],G[:,1,0]-G[:,0,1]],axis=-1)
            curl_error=max(curl_error,float(abs(w-w_from_G).max()))
            np.testing.assert_allclose(w,w_from_G,rtol=1e-12,atol=3e-13)
            S=.5*(G+G.swapaxes(-1,-2));R=.5*(G-G.swapaxes(-1,-2))
            sn=np.linalg.norm(S,axis=(-1,-2));rn=np.linalg.norm(R,axis=(-1,-2))
            wn=np.linalg.norm(w,axis=1);q=.5*(rn*rn-sn*sn)
            series.append(dict(w=w,spin=wn/2,strain=sn,q=q,positions=positions[j]))
            for seed in range(25):
                a,b=seed,25+seed
                local_rows.append(dict(run=tag,n=summary['n'],dt=summary['dt'],model_time=float(t),
                    original_0p002_step=550+j,prime=37 if j==0 else 41 if j==50 else '',
                    sample_kind='prime' if j in [0,50] else 'intermediate saved sample',
                    side='before_write' if j==50 else 'at',pair=seed,
                    local_gap=float(gaps[j,seed,0]),extended_gap=float(gaps[j,seed,1]),
                    local_closest_arclength=float(gaps[j,seed,3]),extended_closest_arclength=float(gaps[j,seed,4]),
                    A_vorticity=float(wn[a]),B_vorticity=float(wn[b]),
                    A_local_spin=float(wn[a]/2),B_local_spin=float(wn[b]/2),
                    A_strain_norm=float(sn[a]),B_strain_norm=float(sn[b]),
                    A_rotation_norm=float(rn[a]),B_rotation_norm=float(rn[b]),
                    A_Q=float(q[a]),B_Q=float(q[b]),
                    A_divergence=float(np.trace(G[a])),B_divergence=float(np.trace(G[b]))))
        readouts[tag]=series
        for name in ['summary.json','diagnostics.json','window.npz','gaps_grid192_ds1024.csv']:
            inputs[str((p/name).relative_to(ROOT))]=digest(p/name)
        print('METERS',tag,'16 prime rows and 1275 same-pair late readings',flush=True)
    for name,left,right in COMPARISONS:
        spin=[];strain=[];angles=[];transport=[];minimum=[]
        for a,b in zip(readouts[left],readouts[right]):
            spin.append(abs(a['spin']-b['spin']))
            strain.append(abs(a['strain']-b['strain']))
            wa,wb=a['w'],b['w'];na=np.linalg.norm(wa,axis=1);nb=np.linalg.norm(wb,axis=1)
            valid=(na>1e-8)&(nb>1e-8)
            angle=np.full(len(na),np.nan)
            angle[valid]=np.degrees(np.arctan2(np.linalg.norm(np.cross(wa[valid],wb[valid]),axis=1),np.sum(wa[valid]*wb[valid],axis=1)))
            angles.append(angle)
            d=b['positions']-a['positions'];d-=np.rint(d)
            transport.append(np.linalg.norm(d,axis=1));minimum.extend([na.min(),nb.min()])
        sp=np.asarray(spin);st=np.asarray(strain);an=np.asarray(angles);tr=np.asarray(transport)
        comparisons.append(dict(comparison=name,max_local_spin_change=float(sp.max()),
            max_strain_norm_change=float(st.max()),max_vorticity_direction_change_degrees=float(np.nanmax(an)),
            near_null_direction_count=int(np.isnan(an).sum()),minimum_vorticity_magnitude=float(min(minimum)),
            max_same_particle_position_difference=float(tr.max()),
            final_max_position_difference=float(tr[-1].max()),
            final_max_local_spin_change=float(sp[-1].max()),final_max_strain_change=float(st[-1].max())))
    assert ledger_error<1e-14
    savecsv(OUT/'prime-meter.csv',prime_rows)
    savecsv(OUT/'same-pair-local-meter.csv',local_rows)
    savecsv(OUT/'meter-grid-comparisons.csv',comparisons)
    lookup={(r['run'],round(r['model_time'],6),r['pair']):r for r in local_rows}
    focused=[]
    for r in rows(OUT/'gap-comparisons.csv'):
        t=round(1.1+.002*int(r['worst_frame_index']),6);seed=int(r['worst_seed'])
        for tag in [r['coarse'],r['fine']]:
            record=lookup[tag,t,seed]
            focused.append(dict(comparison=r['comparison'],focus='largest same-pair gap change',
                **record))
    savecsv(OUT/'gap-change-focus-meter.csv',focused)
    result=dict(scope='Numerical readouts of saved fields and diagnostics; no new solver steps or Lean run.',
        prime_labels=PRIMES,prime_rows=len(prime_rows),same_pair_readings=len(local_rows),
        analytical_gradient_check_error=analytic_error,max_curl_gradient_discrepancy=curl_error,
        max_energy_recount_discrepancy=ledger_error,
        local_spin_definition='one half of the vorticity magnitude',
        strain_definition='Frobenius norm of (gradient(u)+transpose(gradient(u)))/2',
        Q_definition='(rotation Frobenius norm squared minus strain Frobenius norm squared)/2',
        position_difference_definition='Shortest periodic displacement in the unit cube between the same material labels at the same model time.',
        comparisons=comparisons,
        no_carried_tangent_map_claim=True,threshold_one_result=False,lean_run=False,
        meter_extension_59_157='Separate 401-marker study; outside this through-tick-41 result.',
        fixed_yang_mills_zero='Not used: independent of this evolving fluid state.',
        input_hashes=inputs)
    (OUT/'meter-checks.json').write_text(json.dumps(result,indent=2,allow_nan=False)+'\n',encoding='utf-8')
    print(json.dumps({k:v for k,v in result.items() if k!='input_hashes'},indent=2),flush=True)

if __name__=='__main__':main()
