"""Fresh full-interval replay; separate, phase-sensitive comparison of its outputs.

The sealed solver and published input arrays remain unchanged. Run data are
written outside the published outputs. This is independent execution and
analysis of the same numerical method, not an independent time integrator.
"""
import os
for name in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','MKL_NUM_THREADS'):os.environ[name]='1'
import sys,json,csv,hashlib,platform,argparse,shutil,subprocess
from pathlib import Path
from datetime import datetime,timezone

STUDY=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(STUDY))
import run_transfer as native
import numpy as np
import scipy

REPLAY_ATOL=1e-17
REPLAY_RTOL=1e-4
CONTROL_RTOL=.01
PHASE_COEFFICIENT_FLOOR=1e-18
STEPS=(.0005,.00025,.000125)

def digest(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def read(p):return json.loads(Path(p).read_text(encoding='utf-8'))
def save(p,x):Path(p).write_text(json.dumps(x,indent=2,allow_nan=False)+'\n',encoding='utf-8')
def folder(dt):return 'dt'+str(dt).replace('.','p')
def vector_norm(v):return float(np.sqrt(np.sum(np.abs(v)**2)))

def sources():
    expected=read(STUDY/'SOURCE-MANIFEST.json')
    for p,h in expected.items():
        if digest(STUDY/p)!=h:raise ValueError('Published source/evidence changed: '+p)
    declaration=read(STUDY/'EXPERIMENT.json')
    assert digest(native.STATE)==declaration['source_state_sha256']
    assert digest(STUDY/'inputs/unit-fine-perturbation.npy')==declaration['perturbation_sha256']
    return expected,declaration

def run(output):
    manifest,declaration=sources()
    if output.exists():raise FileExistsError('Choose a fresh output directory; existing runs are never overwritten')
    output.mkdir(parents=True)
    shutil.copyfile(STUDY/'EXPERIMENT.json',output/'EXPERIMENT.json')
    protocol=dict(created_utc=datetime.now(timezone.utc).isoformat(),source_pr=23,
        published_head='71951eb6ebd338e0bd07e5d59e6206207974fa07',
        input_sha256=declaration['source_state_sha256'],perturbation_sha256=declaration['perturbation_sha256'],
        source_manifest_sha256=digest(STUDY/'SOURCE-MANIFEST.json'),runner_sha256=digest(Path(__file__)),
        interval=[1.2,1.22],start_side='after write at prime 41',grid=32,threshold=1,breathing='off',
        steps=list(STEPS),arms={'0.0005':['baseline','fine_error'],'0.00025':['baseline','fine_error','half_error'],'0.000125':['baseline','fine_error']},
        original_method_retained=True,earlier_history_rerun=False,earlier_history_used='Published full after-write-41 state and its recorded provenance',
        independent_execution=True,independent_analysis=True,independent_integrator=False,
        output_policy='Fresh directory; same input bytes, sealed model, clock arithmetic, integrator, amplitudes and full coupling. No saved endpoint or trajectory is an integration input.',
        tolerance_source='verify_package.py first-step envelope, now declared for every full-run saved complex-mode snapshot; analyze.py 1% step-size and amplitude criteria retained.',
        replay_absolute_floor=REPLAY_ATOL,replay_relative_tolerance=REPLAY_RTOL,control_relative_tolerance=CONTROL_RTOL,
        primary_phase_check='Unaligned complete complex-coefficient vector difference: no phase rotation, sign flip or amplitude fitting is removed.',
        supplemental_phase_measure='Reference-power-weighted wrapped phase-angle RMS on coefficients for which both amplitudes exceed the declared floor; excluded power is reported.',
        phase_coefficient_floor=PHASE_COEFFICIENT_FLOOR,
        original_runtime=declaration['runtime'],replay_runtime=dict(python=sys.version,numpy=np.__version__,scipy=scipy.__version__,platform=platform.platform(),threads=1),
        original_file_hashes=manifest)
    save(output/'PROTOCOL.json',protocol)
    # Only the published runner's destination and declaration location change.
    # INPUT, STATE, MODEL and new_solver still refer to the checked published sources.
    native.HERE=output
    for dt in STEPS:native.run(dt,dt==.00025)
    assert all(digest(STUDY/p)==h for p,h in manifest.items())
    outputs={str(p.relative_to(output)).replace('\\','/'):digest(p) for p in sorted((output/'outputs').rglob('*')) if p.is_file()}
    save(output/'RUN-COMPLETE.json',dict(completed_utc=datetime.now(timezone.utc).isoformat(),full_interval=True,
        source_preserved=True,step_sizes=3,arms=7,arm_steps=640,output_hashes=outputs))
    print('FULL_REPLAY_COMPLETE',flush=True)

def read_modes(path):
    with np.load(path,allow_pickle=False) as z:return z['times'].copy(),{str(name):z['values'][:,i].copy() for i,name in enumerate(z['arms'])}

def complex_compare(actual,expected):
    scale=vector_norm(expected);delta=vector_norm(actual-expected);bound=max(REPLAY_ATOL,REPLAY_RTOL*scale)
    mask=(abs(expected)>PHASE_COEFFICIENT_FLOOR)&(abs(actual)>PHASE_COEFFICIENT_FLOOR)
    weight=abs(expected[mask])**2;total=float(np.sum(abs(expected)**2));retained=float(weight.sum())
    phase=np.angle(actual[mask]*expected[mask].conjugate())
    angle=float(np.sqrt(np.sum(weight*phase**2)/retained)*180/np.pi) if retained else None
    return dict(reference_rms=scale,replay_rms=vector_norm(actual),complex_difference_rms=delta,
        relative_complex_difference=delta/scale if scale else None,absolute_tolerance=bound,within_tolerance=bool(delta<=bound),
        weighted_phase_rms_degrees=angle,phase_retained_reference_power=retained/total if total else None)

def analyze(output):
    manifest,declaration=sources();protocol=read(output/'PROTOCOL.json');done=read(output/'RUN-COMPLETE.json')
    assert protocol['input_sha256']==declaration['source_state_sha256'] and protocol['perturbation_sha256']==declaration['perturbation_sha256']
    assert protocol['replay_absolute_floor']==REPLAY_ATOL and protocol['replay_relative_tolerance']==REPLAY_RTOL
    assert protocol['control_relative_tolerance']==CONTROL_RTOL and protocol['phase_coefficient_floor']==PHASE_COEFFICIENT_FLOOR
    assert protocol['runner_sha256']==digest(Path(__file__))
    assert all(digest(output/p)==h for p,h in done['output_hashes'].items())
    replay={};published={};snapshots=[];histories=[];endpoint=[];summaries={};rowcount=0
    for dt in STEPS:
        sub=folder(dt);fresh=output/'outputs'/sub;old=STUDY/'outputs'/sub
        ft,fm=read_modes(fresh/'broad-difference-modes.npz');ot,om=read_modes(old/'broad-difference-modes.npz')
        assert np.array_equal(ft,ot) and fm.keys()==om.keys()
        replay[dt]=(ft,fm);published[dt]=(ot,om);summaries[dt]=read(fresh/'summary.json')
        for name in fm:
            for i,t in enumerate(ft):snapshots.append(dict(dt=dt,arm=name,time=float(t),**complex_compare(fm[name][i],om[name][i])))
        with (fresh/'history.csv').open() as stream:fr=list(csv.DictReader(stream))
        with (old/'history.csv').open() as stream:orr=list(csv.DictReader(stream))
        assert len(fr)==len(orr)==round(.02/dt)+1;rowcount+=len(fr)
        for a,b in zip(fr,orr):
            assert float(a['time'])==float(b['time'])
            for arm in fm:
                actual=float(a[arm+'_broad_rms']);expected=float(b[arm+'_broad_rms']);bound=max(REPLAY_ATOL,REPLAY_RTOL*expected)
                histories.append(dict(dt=dt,arm=arm,time=float(a['time']),reference_broad_rms=expected,replay_broad_rms=actual,
                    absolute_difference=abs(actual-expected),absolute_tolerance=bound,within_tolerance=abs(actual-expected)<=bound))
        for p in sorted(fresh.glob('*-final.npz')):
            with np.load(p,allow_pickle=False) as a,np.load(old/p.name,allow_pickle=False) as b:
                assert a.files==b.files
                for k in a.files:
                    assert a[k].shape==b[k].shape and np.isfinite(a[k]).all()
                    endpoint.append(dict(dt=dt,arm=p.stem[:-6],array=k,max_absolute_difference=float(np.max(abs(a[k]-b[k]))),
                        l2_difference=vector_norm(a[k]-b[k]),reference_l2=vector_norm(b[k])))
            assert summaries[dt]['readable_record_ids'][p.stem[:-6]]==[0,1,2]
    controls=[]
    def control(label,times,a,b):
        for i,t in enumerate(times):
            scale=vector_norm(b[i]);delta=vector_norm(a[i]-b[i]);relative=delta/scale if scale else None
            controls.append(dict(comparison=label,time=float(t),after_start=bool(i>0),complex_difference_rms=delta,
                reference_rms=scale,relative_difference=relative,relative_tolerance=CONTROL_RTOL,
                within_tolerance=bool(i==0 or relative<CONTROL_RTOL)))
    for a,b in zip(STEPS[:-1],STEPS[1:]):
        assert np.array_equal(replay[a][0],replay[b][0])
        control(f'dt {a} versus {b}',replay[b][0],replay[a][1]['fine_error'],replay[b][1]['fine_error'])
    control('full versus twice half amplitude',replay[.00025][0],2*replay[.00025][1]['half_error'],replay[.00025][1]['fine_error'])
    # A pure phase error must fail even though its RMS magnitude is unchanged.
    probe=published[.000125][1]['fine_error'][-1]
    synthetic=complex_compare(probe*np.exp(.1j),probe)
    assert abs(vector_norm(probe*np.exp(.1j))/vector_norm(probe)-1)<1e-14
    assert not synthetic['within_tolerance']
    final=summaries[.000125]['final'];initial=summaries[.000125]['initial']
    acceptance=dict(all_saved_complex_modes_within_replay_tolerance=all(r['within_tolerance'] for r in snapshots),
        all_history_broad_norms_within_replay_tolerance=all(r['within_tolerance'] for r in histories),
        original_step_and_amplitude_controls_pass=all(r['within_tolerance'] for r in controls),
        initial_broad_below_1e_minus16=initial['fine_error_broad_rms']<1e-16,
        final_broad_over_100_times_initial_roundoff=final['fine_error_broad_rms']>100*initial['fine_error_broad_rms'],
        repeated_first_steps_bit_identical=all(x['repeat_first_step_bit_identical'] for x in summaries.values()),
        inputs_preserved=all(x['source_state_unchanged'] for x in summaries.values()),
        phase_only_negative_control_rejected=not synthetic['within_tolerance'])
    dest=output/'comparison';dest.mkdir(exist_ok=True)
    for name,rows in [('complex-mode-comparisons.csv',snapshots),('history-norm-comparisons.csv',histories),('fresh-controls.csv',controls),('endpoint-array-differences.csv',endpoint)]:
        with (dest/name).open('w',newline='',encoding='utf-8') as stream:
            w=csv.DictWriter(stream,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
    result=dict(status='PASS' if all(acceptance.values()) else 'FAIL',acceptance=acceptance,
        history_rows=rowcount,history_arm_readings=len(histories),complex_mode_snapshots=len(snapshots),controls=len(controls),
        final_broad_rms=final['fine_error_broad_rms'],published_final_broad_rms=declaration.get('unused',read(STUDY/'report/RESULTS.json')['final']['fine_error_broad_rms']),
        fine_difference_percent_reduction=100*(1-final['fine_error_fine_rms']/initial['fine_error_fine_rms']),
        worst_replay_relative_complex=max(snapshots,key=lambda x:x['relative_complex_difference']),
        worst_replay_tolerance_fraction=max(x['complex_difference_rms']/x['absolute_tolerance'] for x in snapshots),
        finest_endpoint=next(x for x in snapshots if x['dt']==.000125 and x['time']==1.22 and x['arm']=='fine_error'),
        control_summary={name:dict(endpoint=next(x for x in controls if x['comparison']==name and x['time']==1.22),
            maximum_after_start=max((x for x in controls if x['comparison']==name and x['after_start']),key=lambda x:x['relative_difference'])) for name in dict.fromkeys(x['comparison'] for x in controls)},
        source_preserved=all(digest(STUDY/p)==h for p,h in manifest.items()),phase_only_negative_control=synthetic,
        scope=dict(fresh_linux_execution=True,same_sealed_solver=True,independent_comparison_code=True,independent_integrator=False,
            earlier_history_reconstructed=False,spatial_convergence=False,return_miss_connection_established=False),
        protocol_sha256=digest(output/'PROTOCOL.json'),run_receipt_sha256=digest(output/'RUN-COMPLETE.json'))
    save(dest/'RESULTS.json',result)
    print(json.dumps(result,indent=2),flush=True)
    if not all(acceptance.values()):raise SystemExit('Full-interval comparison failed; tolerances were not changed')

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('action',choices=['run','analyze']);parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();{'run':run,'analyze':analyze}[args.action](args.output.resolve())
