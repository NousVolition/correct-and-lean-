"""Compare vector responses, time steps, and perturbation amplitudes."""
from run_transfer import *

def read_run(dt):
    folder=HERE/'outputs'/('dt'+str(dt).replace('.','p'))
    summary=json.loads((folder/'summary.json').read_text())
    with (folder/'history.csv').open() as f:
        rows=[{k:float(v) for k,v in row.items()} for row in csv.DictReader(f)]
    with np.load(folder/'broad-difference-modes.npz') as z:
        times=z['times'].copy();values=z['values'].copy();arms=list(z['arms'])
    return summary,rows,times,{a:values[:,i] for i,a in enumerate(arms)}

def vnorm(v):return np.sqrt(np.sum(abs(v.reshape(len(v),-1))**2,axis=1))

def main():
    decl=json.loads((HERE/'EXPERIMENT.json').read_text())
    runs={dt:read_run(dt) for dt in decl['time_steps']}
    finest=runs[.000125];ref=finest[3]['fine_error'];rn=vnorm(ref)
    comparisons=[];deltas=[]
    for coarse,fine in [(.0005,.00025),(.00025,.000125)]:
        a,b=runs[coarse],runs[fine]
        assert np.allclose(a[2],b[2],atol=1e-14,rtol=0)
        d=vnorm(a[3]['fine_error']-b[3]['fine_error']);bn=vnorm(b[3]['fine_error'])
        comparisons.append(dict(coarser_dt=coarse,finer_dt=fine,
            final_vector_difference=float(d[-1]),final_relative_vector_difference=float(d[-1]/bn[-1]),
            max_relative_vector_difference_after_start=float(np.max(d[1:]/bn[1:])),
            final_relative_norm_difference=abs(a[0]['final']['fine_error_broad_rms']/b[0]['final']['fine_error_broad_rms']-1)))
        deltas.append(d)
    mid=runs[.00025];a=mid[3]['fine_error'];b=2*mid[3]['half_error']
    amp_delta=vnorm(a-b);amp_ref=vnorm(a)
    amp=dict(final_full_to_half_norm_ratio=float(vnorm(a)[-1]/vnorm(mid[3]['half_error'])[-1]),
             final_relative_scaled_vector_difference=float(amp_delta[-1]/amp_ref[-1]),
             max_relative_scaled_vector_difference_after_start=float(np.max(amp_delta[1:]/amp_ref[1:])))
    validation={
        'initial_broad_below_1e_minus16':decl['initial_broad_roundoff']<1e-16,
        'final_broad_over_100_times_initial_roundoff':rn[-1]>100*decl['initial_broad_roundoff'],
        'finest_two_vector_responses_within_one_percent_at_all_common_times_after_start':comparisons[-1]['max_relative_vector_difference_after_start']<.01,
        'halved_amplitude_vector_response_within_one_percent_after_rescaling':amp['max_relative_scaled_vector_difference_after_start']<.01,
        'identical_first_steps_bit_identical':all(x[0]['repeat_first_step_bit_identical'] for x in runs.values()),
        'input_unchanged':all(x[0]['source_state_unchanged'] for x in runs.values())}
    validation={k:bool(v) for k,v in validation.items()}
    first,final=finest[1][0],finest[1][-1]
    result=dict(experiment='Tick 41 fine-to-broad perturbation test',
        comparison='Differences between perturbed and unperturbed full coupled evolutions; all start from the same saved 32^3 state.',
        measured_quantity='Velocity vector RMS, sqrt(volume average of |delta u|^2); not energy flux or return-curve miss.',
        criteria_note='These are analysis acceptance tolerances; this experiment was not preregistered.',
        initial=first,final=final,
        fine_difference_percent_reduction=100*(1-final['fine_error_fine_rms']/first['fine_error_fine_rms']),
        broad_difference_fraction_of_baseline_broad=final['fine_error_broad_rms']/final['baseline_broad_rms'],
        baseline_broad_percent_reduction=100*(1-final['baseline_broad_rms']/first['baseline_broad_rms']),
        final_broad_difference_fraction_of_initial_fine=final['fine_error_broad_per_initial_error'],
        time_step_comparisons=comparisons,
        final_refinement_difference_ratio=float(deltas[0][-1]/deltas[1][-1]),
        amplitude_check=amp,validation=validation,
        initial_route=json.loads((HERE/'outputs/initial-route/initial-route.json').read_text()),
        energy_balance_residuals={str(dt):run[0]['energy_balance_residuals'] for dt,run in runs.items()},
        interpretation='This imposed fine-band velocity discrepancy produces a small broad-band velocity discrepancy while its fine-band size decreases in the tested interval. The original source of numerical error and the earlier frozen-curve sensitivity are not identified by this test.',
        scope=dict(grid=32,breathing='off',interval=[START,END],perturbation_seeds=1,amplitudes=2,full_coupling=True,
                   new_external_input=False,spatial_trajectory_refinement=False,independent_time_integrator=False))
    assert all(validation.values()),validation
    DEST=HERE/'report';DEST.mkdir(parents=True,exist_ok=True)
    write_json(DEST/'RESULTS.json',result)
    combined=[]
    for dt,run in runs.items():combined.extend(run[1])
    keys=list(dict.fromkeys(k for row in combined for k in row))
    with (DEST/'all-time-histories.csv').open('w',newline='') as out:
        w=csv.DictWriter(out,fieldnames=keys);w.writeheader();w.writerows(combined)
    control=[]
    for i,t in enumerate(finest[2]):
        control.append(dict(time=t,elapsed_time=t-START,
            coarse_to_medium_vector_difference=deltas[0][i],medium_to_fine_vector_difference=deltas[1][i],
            half_amplitude_scaled_vector_difference=amp_delta[i],finest_broad_difference=rn[i]))
    with (DEST/'vector-control-comparisons.csv').open('w',newline='') as out:
        w=csv.DictWriter(out,fieldnames=list(control[0]));w.writeheader();w.writerows(control)
    print(json.dumps({k:result[k] for k in ['fine_difference_percent_reduction','broad_difference_fraction_of_baseline_broad','baseline_broad_percent_reduction','final_broad_difference_fraction_of_initial_fine','time_step_comparisons','final_refinement_difference_ratio','amplitude_check','validation']},indent=2))

if __name__=='__main__':main()
