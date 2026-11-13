# Following unwrapped carrying history through tick 41

**The full carrying-work history reproduces the A/S work in this saved run without changing its equations.** Integrating force along a volume sample of unwrapped fluid paths gives 2.4424319015e-5, compared with the solver's 2.4424321688e-5 receipt: an error of **0.1094 parts per million of A/S work**. This establishes a history-dependent work account. Its identification with independently specified gravitational stored energy remains open.

## Result and verification

The case is the same saved threshold-1, 16³, breathing-on experiment at time 1.2, after the third write. Its later material/social additions remain distinct from the original source A/S equations. All quantities below use the experiment's dimensionless units.

| Check | Result |
|---|---:|
| Saved A/S work | 2.442432168805689e-5 |
| Unwrapped path work, 12³ volume labels | 2.442447373168288e-5 |
| Unwrapped path work, 16³ volume labels | 2.442431901518852e-5 |
| Work discrepancy, 12³ → 16³ sampling | 6.2251 → 0.1094 ppm |
| Largest absolute work discrepancy across all 601 times, 16³ | 2.6729e-12 |
| Largest error reproducing original 803 water-label paths at saved checkpoints | 2.7756e-17 |

The full history was followed using the saved native velocity stages. To recover missing force samples, the unchanged sealed solver was replayed for 600 steps with its original three writes. All 1,200 saved velocity stages agreed within 1.7376e-18. The initial full checkpoint was loaded; all 61 subsequent saved full checkpoints agreed within 7.7716e-16 across their 17 state blocks. The replayed A/S ledger agreed with the 601 saved readings within 1.6941e-21. Inspected source files and saved inputs retained their hashes.

The 801 original strand labels and two tagged particles were carried throughout. They are not a whole-volume quadrature: averaging their work would over-weight their particular part of the flow. Separate fixed, uniform initial volume samples of 1,728 and 4,096 passive labels supplied the volume integral. They exert no force and never enter the solver's state or feedback. The material's original 384 coordinates were also retained and checked as part of the full checkpoint comparisons; their immersed interpolation differs from the unsmoothed water-label interpolation.

These tests refine the passive volume sampling only. They do not refine the physical solver grid or its time step, or prove continuum convergence. Neither of the sampled volume clouds nor the original labels has a **net winding change at the final time**. The account does not rely on inventing an unseen extra lap.

## Where the work went

Directly integrating the mean and fluctuating parts of power gives:

| Contribution | Work | Share of A/S work |
|---|---:|---:|
| Mean force × mean velocity | 2.2039706551e-6 | 9.02367% |
| Local force/velocity variations about those means | 2.2220351033e-5 | 90.97633% |

This is now an actual power decomposition over the full run. The earlier numerical ratio of drift kinetic energy to work is consistent with it. The mean momentum-rate identity was checked at all 1,200 stages: the mean A/S force accounts for mean acceleration within 1e-13. Mean unwrapped displacement in the force direction is -7.3586827232e-4 box lengths.

## What history adds to an endpoint height

Write ξ(t) for unwrapped displacement from a parcel's initial position in the force direction, and a(t) for the activation experienced along that path. The force used in the diagnostic is f = −σa. Consider the explicit endpoint candidate U = σaξ. The product rule gives

\[
W_{\chi}=-\sigma\int_0^t a(s)\dot\xi(s)\,ds
=-\Delta U_{\chi}+J_{\chi},\qquad
J_{\chi}=\sigma\int_0^t\xi(s)\dot a(s)\,ds.
\]

For the fine volume sample, the endpoint expression supplies a release of approximately **1.3768911e-5 (56.37%)**; the activation-history correction is **1.0654748e-5 (43.62%)**. These are a decomposition of the chosen work expression, not independently measured physical reservoirs.

The discrete product rule is exact for endpoint trapezoidal path work: its mean algebraic residual is 1.1e-21. That endpoint quadrature differs from the native Heun-stage path work by 6.6033e-10, about 27.0 ppm of coupling work. This small quadrature difference is retained explicitly; the 0.1094 ppm comparison above uses the native stage rule throughout.

Define the history account R = U − J. Then R′ = −P_AS after averaging over volume. Thus

\[
\Delta E-W_{\rm breathing}-W_{\rm write}+\Delta R\approx0.
\]

Using the native-stage path account gives ΔR = −2.4424319015e-5 and a total-energy residual of 1.1417601e-9, **6.6338 ppm of the energy change**. This retains both added drives in this particular run. It does not classify the user's underlying unforced formulation as externally driven.

The history law records force acting through the carried displacement. It requires the force/activation history as well as positions. Lean proves that this constructed account equals the negative accumulated work receipt. It consequently provides an exact accounting identity under its hypotheses; an independently defined energy law is still needed to identify it as a physical gravitational reservoir.

## Why unwrapping alone does not produce a gravitational potential

At the frozen final field, a diagnostic rectangle in **unwrapped space** has vertices

(-0.5, 0.25, -0.125) → (0.5, 0.25, -0.125) → (0.5, 0, -0.125) → (-0.5, 0, -0.125) → start.

Its signed force-work integral is **0.02349209221**. Independent 32- and 64-point edge quadratures agree with the Fourier integral within 2e-17. This is a chosen force-field probe, not a recorded parcel orbit. It returns to the same unwrapped location, so the nonzero work is more than a periodic-coordinate identification problem. The resolved force's curl RMS is 0.1608328.

This rules out a position-only scalar potential for that resolved force at that time, even on the unwrapped space. It does not exclude a larger configuration/history energy or establish a self-gravity law. A conservative force derived from a position potential has zero closed-path work; see the [force–potential relation](https://openstax.org/books/university-physics-volume-1/pages/8-2-conservative-and-non-conservative-forces).

The diagnostic samples the Fourier-resolved, unprojected A/S force, using the same retained modes as the velocity. This removes unresolved force modes that do zero global work against the retained velocity. It preserves the native grid work. Fourier interpolation can overshoot the raw nonnegative activation, so individual interpolated values are not claimed to retain the raw activation's sign. The force extension and pressure convention matter for individual path allocations; the global comparison is the stated test.

## Lean results and files

[UnwrappedWork.lean](UnwrappedWork.lean) establishes six results: the one-step work/product identity; its telescoping history balance; the history term remaining when endpoints return; the continuous history-account derivative; conditional conservation after adding that account; and its equality to the opposite cumulative work receipt. The general PDE change of variables, floating-point solver and sampled force field are not formalized by those six statements.

- [summary.json](summary.json): principal measurements and the closed-rectangle probe.
- [path-history-12-16.csv](path-history-12-16.csv): every saved-time work/position summary for both volume samples and the original labels.
- [stage-work.csv](stage-work.csv): all 1,200 force/velocity power measurements.
- [replay-verification.json](replay-verification.json): input hashes and checkpoint comparisons.
- [verification.json](verification.json): Lean compilation, axiom audit and scope.

Reproduction scripts are `replay.py`, `follow_paths.py` and `summarize.py`; they refer to the original local inputs by absolute path and write intermediates to this chat's `work/unwrapped-history/`. NumPy 2.3.5 and the existing compatible SciPy 1.16.3 were used. Run replay, then `follow_paths.py 12 16`, then summarize. The original archived run reported another SciPy version; the explicit stage/checkpoint comparisons above are the compatibility evidence.

`build-native.ps1` rebuilds the Lean source using the existing Lean 4.34.0-rc2 and pinned Mathlib cache recorded in verification. New theorems were freshly checked; unchanged imported files use prior successful receipts with source and compiled-object hashes rechecked. No independent external kernel or new solver-resolution study was run.
