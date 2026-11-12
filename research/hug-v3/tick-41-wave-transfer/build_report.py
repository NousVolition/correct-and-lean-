"""Standalone figures and report, generated from completed measurements."""
import sys
from pathlib import Path
import json,csv,base64
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.ticker import MaxNLocator

HERE=Path(__file__).resolve().parent;OUT=HERE/'report'
R=json.loads((OUT/'RESULTS.json').read_text());D=json.loads((HERE/'EXPERIMENT.json').read_text())
def history(dt):
    with (HERE/'outputs'/('dt'+str(dt).replace('.','p'))/'history.csv').open() as f:
        rows=list(csv.DictReader(f))
    return {k:np.array([float(r[k]) for r in rows]) for k in rows[0]}
H={dt:history(dt) for dt in D['time_steps']};h=H[.000125]
plt.rcParams.update({'font.family':'DejaVu Sans','font.size':10,'axes.spines.top':False,'axes.spines.right':False,
                     'figure.facecolor':'#fafaf7','axes.facecolor':'#fafaf7','axes.labelcolor':'#172d38',
                     'text.color':'#172d38','axes.titleweight':'bold','grid.alpha':.22})
fig,ax=plt.subplots(1,2,figsize=(11.8,4.8),layout='constrained')
fig.suptitle('Tick 41: fine error falls while a broad difference develops',fontsize=16,fontweight='bold')
ax[0].plot(h['elapsed_time'],h['fine_error_fine_rms']/1e-7,color='#bf652b',lw=2.6)
ax[0].scatter([0,.02],[h['fine_error_fine_rms'][0]/1e-7,h['fine_error_fine_rms'][-1]/1e-7],color='#bf652b',s=28)
ax[0].set(title='Fine band: largest wave number 8–10',ylabel='Velocity difference RMS (× 10⁻⁷)',ylim=(0,6.1))
ax[0].text(.001,.65,f"{R['fine_difference_percent_reduction']:.2f}% smaller at time 1.22",fontsize=11,color='#88451a')
styles=[(.0005,'#72a7a9','--'),(.00025,'#327b88',':'),(.000125,'#173d57','-')]
for dt,color,style in styles:
    d=H[dt];ax[1].plot(d['elapsed_time'],d['fine_error_broad_rms']/1e-12,color=color,ls=style,lw=2,label=f'Δt = {dt:g}')
mid=H[.00025]
ax[1].plot(mid['elapsed_time'][::8],2*mid['half_error_broad_rms'][::8]/1e-12,'o',mfc='none',mec='#965eaa',ms=5,label='Half perturbation, doubled')
ax[1].set(title='Broad band: largest wave number 1–2',ylabel='Velocity difference RMS (× 10⁻¹²)',ylim=(0,4.6))
ax[1].legend(loc='upper left',fontsize=8.5,frameon=False)
for a in ax:
    a.set(xlabel='Elapsed model time after tick 41 (t − 1.2)',xlim=(0,.02))
    a.xaxis.set_major_locator(MaxNLocator(5));a.grid()
fig.savefig(OUT/'fine-and-broad-differences.png',dpi=180)
fig.savefig(OUT/'fine-and-broad-differences.svg')
plt.close(fig)
with (OUT/'vector-control-comparisons.csv').open() as f:controls=list(csv.DictReader(f))
c={k:np.array([float(r[k]) for r in controls])[1:] for k in controls[0]}
fig,ax=plt.subplots(1,2,figsize=(11.8,4.5),layout='constrained')
fig.suptitle('Checks compare the complete broad-mode difference, including phase',fontsize=14,fontweight='bold')
ax[0].plot(c['elapsed_time'],100*c['coarse_to_medium_vector_difference']/c['finest_broad_difference'],color='#72a7a9',lw=2,label='0.0005 versus 0.00025')
ax[0].plot(c['elapsed_time'],100*c['medium_to_fine_vector_difference']/c['finest_broad_difference'],color='#173d57',lw=2,label='0.00025 versus 0.000125')
ax[0].set(title='Time-step refinement',ylabel='Vector discrepancy / finest response (%)')
ax[0].legend(frameon=False,fontsize=9)
ax[1].plot(c['elapsed_time'],100*c['half_amplitude_scaled_vector_difference']/c['finest_broad_difference'],color='#965eaa',lw=2)
ax[1].set(title='Full perturbation versus doubled half',ylabel='Vector discrepancy / finest response (%)')
for a in ax:
    a.set(xlabel='Elapsed model time after tick 41',xlim=(0,.02),ylim=(0,None));a.xaxis.set_major_locator(MaxNLocator(5));a.grid()
fig.savefig(OUT/'numerical-controls.png',dpi=180);plt.close(fig)

f=R['final'];i=R['initial'];tc=R['time_step_comparisons'][-1];ac=R['amplitude_check'];route=R['initial_route'];rr=route['rows'][0]
def image(name):return 'data:image/png;base64,'+base64.b64encode((OUT/name).read_bytes()).decode()
time_rows=''.join(f'<tr><td>{dt:g}</td><td>{H[dt]["fine_error_fine_rms"][-1]:.10e}</td><td>{H[dt]["fine_error_broad_rms"][-1]:.10e}</td></tr>' for dt in D['time_steps'])
route_rows=''.join(f'<tr><td>{label}</td><td>{rr[key+"_rate_rms"]:.8e}</td><td>{100*rr[key+"_signed_fraction_along_total"]:.6f}%</td></tr>' for key,label in [('advection_linear','Advection: interaction with existing velocity'),('advection_quadratic','Advection: perturbation interacting with itself'),('viscosity','Temperature-dependent viscosity')])
html=f'''<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Tick 41: fine-to-broad perturbation test</title>
<style>body{{font:17px/1.6 system-ui,sans-serif;color:#172d38;background:#fafaf7;margin:0}}main{{max-width:1050px;margin:auto;padding:36px 24px 64px}}h1{{font-size:36px;line-height:1.2}}h2{{margin-top:36px;font-size:24px}}p{{max-width:950px}}.eyebrow{{font-size:14px;letter-spacing:.06em;color:#476b76}}.result{{border-left:5px solid #327b88;background:#eaf2ef;padding:15px 22px;margin:26px 0}}img{{width:100%;height:auto;margin:10px 0}}table{{border-collapse:collapse;width:100%;font-size:15px}}td,th{{padding:10px 12px;text-align:left;border-bottom:1px solid #ccd6d4}}th{{background:#eaf2ef}}.scroll{{overflow-x:auto}}.caption,footer{{font-size:14px;color:#47616b}}code,pre{{font-size:14px}}pre{{background:#edf0ed;padding:18px;overflow:auto}}a{{color:#1e657d}}li{{margin-bottom:8px}}</style></head><body><main>
<p class="eyebrow">TICK 41 · MODEL TIME 1.2 → 1.22 · BREATHING OFF · 32³</p>
<h1>Can a fine-wave discrepancy reach broad waves?</h1>
<p>This experiment asks whether a difference confined to fine velocity modes at tick 41 can produce a broad-mode difference as the coupled system evolves. It contains the measured histories, numerical controls, source code and exact starting state. The user proposed and directed the hypothesis; Codex generated and ran this analysis.</p>
<div class="result"><strong>Yes, in this tested state and interval.</strong> The fine-wave difference shrank by {R['fine_difference_percent_reduction']:.2f}%, while a small broad-wave difference developed. The full fluid, material, thermal, clay and actor feedback remained active.</div>
<img src="{image('fine-and-broad-differences.png')}" alt="Fine-mode velocity difference decays from 5.58e-7 to 1.34e-7 while broad-mode difference grows from roundoff to 4.12e-12. Three time steps and rescaled half amplitude overlap.">
<p class="caption">The panels use different vertical scales, stated on each axis. These are RMS differences between two evolving fields. The horizontal axis is elapsed model time, not curve arclength. Bands use the largest absolute wave-number component.</p>
<div class="scroll"><table><tr><th>Measured velocity difference</th><th>At tick 41, t = 1.2</th><th>At t = 1.22, finest step</th></tr>
<tr><td>Fine band, 8–10</td><td>{i['fine_error_fine_rms']:.9e}</td><td>{f['fine_error_fine_rms']:.9e}</td></tr>
<tr><td>Broad band, 1–2</td><td>{i['fine_error_broad_rms']:.3e} (roundoff)</td><td>{f['fine_error_broad_rms']:.9e}</td></tr></table></div>
<p>The final broad difference is {R['broad_difference_fraction_of_baseline_broad']:.4e} times the baseline broad-wave RMS, and {R['final_broad_difference_fraction_of_initial_fine']:.4e} times the initial fine difference. Its absolute size is small. The baseline broad-wave RMS itself falls by {R['baseline_broad_percent_reduction']:.5f}% during this interval.</p>
<h2>What changed at the start</h2>
<p>The two copies begin from the same saved post-write state at time 1.2, with three readable records. One copy receives a divergence-free velocity perturbation confined to <code>8 ≤ max(|kₓ|,|kᵧ|,|k_z|) ≤ 10</code>. Its vector RMS is 0.01% of the initial velocity RMS: {D['perturbation_absolute_rms']:.10e}. The broad band is <code>1 ≤ max(|kₓ|,|kᵧ|,|k_z|) ≤ 2</code>; the spatial mean is excluded.</p>
<p>Shape, position, material state, clay, warmth, context and actor state are identical initially. The perturbation is an initial-state difference; no new external input is added during evolution. Breathing remains off, the full original coupling stays active, and no new writes are scheduled in the interval.</p>
<h2>Numerical controls</h2>
<div class="scroll"><table><tr><th>Time step</th><th>Fine difference at 1.22</th><th>Broad difference at 1.22</th></tr>{time_rows}</table></div>
<p>The two finest time steps differ by {100*tc['final_relative_vector_difference']:.5f}% in the complete final broad-mode difference, including phase. Their largest relative discrepancy over the 40 common times after the start is {100*tc['max_relative_vector_difference_after_start']:.5f}%. Halving the step reduces the final vector discrepancy by a factor of {R['final_refinement_difference_ratio']:.3f}.</p>
<p>Halving the imposed perturbation gives a final response {ac['final_full_to_half_norm_ratio']:.6f} times smaller. After doubling that response for comparison, the final vector discrepancy is {100*ac['final_relative_scaled_vector_difference']:.5f}%; its maximum over the common times is {100*ac['max_relative_scaled_vector_difference_after_start']:.5f}%. The first baseline step was repeated with identical input at each step size and was bit-identical.</p>
<img src="{image('numerical-controls.png')}" alt="Time-step and amplitude control discrepancies stay below 0.2 percent of the broad response.">
<p class="caption">For a common visual scale, these plots divide all discrepancies by the finest-step full-amplitude response. The numeric amplitude comparison in the preceding paragraph uses its matching step size.</p>
<h2>Where the first broad change enters</h2>
<p>At the initial instant, the full velocity-rate subtraction has broad RMS {D['initial_broad_rate_difference']:.8e}. With the other state variables still equal, its components can be evaluated directly:</p>
<div class="scroll"><table><tr><th>Initial term</th><th>Broad rate-difference RMS</th><th>Signed share along the total difference</th></tr>{route_rows}</table></div>
<p class="caption">Signed shares are projections onto the total rate-difference vector, so they sum to 100%. They are not energy-flux shares; the component RMS values do not add. This decomposition identifies the initial route only. Other coupled paths can contribute after their states diverge.</p>
<p>The direct component sum matches the full coupled rate subtraction to {100*route['checks']['native_reconstruction_relative_difference']:.6g}%. Evaluating the same retained input fields on 48³, 64³ and 96³ work grids checks these initial products. The native 32³ result differs from the 96³ evaluation by {100*route['checks']['native_vs_96_relative_difference']:.6g}%; 64³ and 96³ agree to relative {route['checks']['padded64_vs_96_relative_difference']:.3g}. This supports the initial route beyond native-grid product aliasing. It is not a full spatial-refinement test of the evolving model.</p>
<h2>What this establishes</h2>
<p>An imposed fine-band velocity discrepancy can reach broad velocity modes in this coupled 32³ state while the fine discrepancy is being damped. The result survives the tested time-step and amplitude controls.</p>
<p>This experiment uses one perturbation direction, two amplitudes and a short interval. All time refinements start from the same saved state. It does not identify where the earlier simulation error originated, quantify an energy cascade, or show that this small broad difference causes the large return-miss changes in the frozen-field scan. That connection requires a matched geometric test using the evolving perturbed fields.</p>
<h2>Files and reproduction</h2>
<p><a href="all-time-histories.csv">All 283 native-step history rows</a> · <a href="vector-control-comparisons.csv">41 common-time vector comparisons</a> · <a href="RESULTS.json">Complete numerical results</a></p>
<p>The package includes the exact starting state, perturbation, final states, complex broad-mode difference coefficients and sealed model sources. Requires Python, NumPy and SciPy; figure generation also requires Matplotlib. Run from the extracted package folder:</p>
<pre>python run_transfer.py prepare
python run_transfer.py run --dt 0.0005
python run_transfer.py run --dt 0.00025 --half-amplitude
python run_transfer.py run --dt 0.000125
python initial_route.py
python analyze.py
python build_report.py</pre>
<p>Each run compares an unperturbed copy against a perturbed copy at its own time step. The medium step also carries the half-amplitude copy. Source seals and the packaged SHA-256 manifest allow inspection of the inputs and unchanged model code.</p>
<footer>Generated from measured outputs on 2026-11-12. Analysis tolerances were 1% for the vector time-step and amplitude checks; this experiment was not preregistered.</footer>
</main></body></html>'''
(OUT/'Tick-41-fine-to-broad-test.html').write_text(html,encoding='utf-8')
readout=f'''# Tick 41: fine-to-broad perturbation test

The user proposed and directed the hypothesis; Codex generated and ran this analysis.

Result: in the saved breathing-off 32^3 state, a fine-only initial velocity discrepancy generates a small broad velocity discrepancy under full coupling. From time 1.2 to 1.22, the fine difference falls {R['fine_difference_percent_reduction']:.4f}%.

| Quantity | Initial RMS | Final RMS (dt=0.000125) |
|---|---:|---:|
| Fine velocity difference | {i['fine_error_fine_rms']:.12e} | {f['fine_error_fine_rms']:.12e} |
| Broad velocity difference | {i['fine_error_broad_rms']:.12e} | {f['fine_error_broad_rms']:.12e} |

Broad excludes the mean: 1 <= max(abs(k)) <= 2. Fine: 8 <= max(abs(k)) <= 10. Integer components count cycles across the unit cube. Vector RMS is sqrt(mean(sum(delta_u^2, components))). Differences are between paired evolving states, not distances along frozen curves.

Time-step refinement: final vector discrepancy between 0.00025 and 0.000125 is {100*tc['final_relative_vector_difference']:.8f}%; maximum at the 40 common times after the start is {100*tc['max_relative_vector_difference_after_start']:.8f}%. The two successive refinement differences have a ratio of {R['final_refinement_difference_ratio']:.6f}.

Amplitude check: halving the initial discrepancy nearly halves the response (ratio {ac['final_full_to_half_norm_ratio']:.9f}). The rescaled complete vector differs by {100*ac['final_relative_scaled_vector_difference']:.8f}% at the end and at most {100*ac['max_relative_scaled_vector_difference_after_start']:.8f}% over common times.

The initial broad rate is transmitted mainly by advection, with a temperature-dependent viscosity contribution. Full details, signed projections and product-padding checks are in RESULTS.json and outputs/initial-route. The full model coupling remained active for every evolution.

Scope: one saved grid, one perturbation direction, two amplitudes, three Heun time steps, 0.02 model time. No new writes or external input. No full spatial or independent-integrator convergence claim. The experiment does not identify the origin of prior numerical errors or explain the frozen return-miss spike. Final broad difference is {R['broad_difference_fraction_of_baseline_broad']:.8e} times the baseline broad RMS.

Open Tick-41-fine-to-broad-test.html for figures, controls and reproduction commands. Raw results: all-time-histories.csv, vector-control-comparisons.csv, RESULTS.json. See the package README.md for the exact starting-state provenance and source-hash manifest.
'''
(OUT/'READOUT.md').write_text(readout,encoding='utf-8')
assert len(list(csv.DictReader((OUT/'all-time-histories.csv').open())))==283
print(json.dumps(dict(report=str(OUT/'Tick-41-fine-to-broad-test.html'),figures=3,history_rows=283),indent=2))
