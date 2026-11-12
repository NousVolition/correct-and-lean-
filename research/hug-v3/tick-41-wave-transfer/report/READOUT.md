# Tick 41: fine-to-broad perturbation test

The user proposed and directed the hypothesis; Codex generated and ran this analysis.

Result: in the saved breathing-off 32^3 state, a fine-only initial velocity discrepancy generates a small broad velocity discrepancy under full coupling. From time 1.2 to 1.22, the fine difference falls 75.9678%.

| Quantity | Initial RMS | Final RMS (dt=0.000125) |
|---|---:|---:|
| Fine velocity difference | 5.582697714178e-07 | 1.341646253529e-07 |
| Broad velocity difference | 1.829898405051e-20 | 4.124655000768e-12 |

Broad excludes the mean: 1 <= max(abs(k)) <= 2. Fine: 8 <= max(abs(k)) <= 10. Integer components count cycles across the unit cube. Vector RMS is sqrt(mean(sum(delta_u^2, components))). Differences are between paired evolving states, not distances along frozen curves.

Time-step refinement: final vector discrepancy between 0.00025 and 0.000125 is 0.00193264%; maximum at the 40 common times after the start is 0.01847410%. The two successive refinement differences have a ratio of 4.044290.

Amplitude check: halving the initial discrepancy nearly halves the response (ratio 1.999887671). The rescaled complete vector differs by 0.08332600% at the end and at most 0.19400965% over common times.

The initial broad rate is transmitted mainly by advection, with a temperature-dependent viscosity contribution. Full details, signed projections and product-padding checks are in RESULTS.json and outputs/initial-route. The full model coupling remained active for every evolution.

Scope: one saved grid, one perturbation direction, two amplitudes, three Heun time steps, 0.02 model time. No new writes or external input. No full spatial or independent-integrator convergence claim. The experiment does not identify the origin of prior numerical errors or explain the frozen return-miss spike. Final broad difference is 8.31287357e-10 times the baseline broad RMS.

Open Tick-41-fine-to-broad-test.html for figures, controls and reproduction commands. Raw results: all-time-histories.csv, vector-control-comparisons.csv, RESULTS.json. See the package README.md for the exact starting-state provenance and source-hash manifest.
