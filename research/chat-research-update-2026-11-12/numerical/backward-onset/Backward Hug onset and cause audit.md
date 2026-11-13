# Backward Hug: where the damage started

**PARTIAL: the onset and amplification mechanism are identified; a cause-level repair has not been demonstrated under the unchanged-history constraint.** No new inverse step was attempted. The last accepted state remains **0.494**, write 11 remains unreached, traveler **23** remains fixed, mentor **47** retains all nine carried frame entries, and the native acceptance tolerance remains **5 × 10⁻¹⁵**.

## Where it starts

The actual path descends from the original **exact endpoint** at prime 47, t=1.400. The complete starting arrays match that archived endpoint exactly; this is not either deliberately perturbed test case. The first saved nonzero velocity error appears one step later at **1.398**, at approximately 1.378 × 10⁻¹⁷ RMS. Small floating-point/solve differences subsequently grow.

The first negative temperature is precisely bracketed by consecutive original saved steps: **0.548 → 0.546**. The minimum normalized temperature changes from **0.003362001209** to **-0.2759803519**, and 1624 of 4096 cells are negative at 0.546. Matched forward references stay positive throughout the audited lineage.

| Backward-path milestone | First saved time | Measured value |
|---|---:|---:|
| First nonzero velocity difference | 1.398 | RMS 1.378 × 10⁻¹⁷ |
| Error exceeds 1% of reference RMS | 0.744 | 0.010307097× |
| Error exceeds 10% | 0.694 | 0.10328501× |
| Error exceeds reference motion | 0.650 | 1.0738845× |
| Error exceeds 10× reference motion | 0.616 | 10.692976× |
| Error exceeds 100× reference motion | 0.566 | 103.83798× |
| Error exceeds 1000× reference motion | 0.514 | 1058.4248× |
| First negative normalized temperature | 0.546 | -0.275980352 |


The percentage and ratio bands above are explanatory milestones, not newly invented accuracy acceptance criteria. “Huge” has no single declared threshold. The growth in velocity precedes the temperature failure. Both occur before promotion to extended precision at 0.524, the marker recovery at 0.504, and the coupled-solver blockage at 0.492.

The archived residual at the first negative-temperature step is **2.9976021664879227 × 10⁻¹⁵**, below the unchanged native tolerance. That is historical receipt evidence, not a new full-state replay of 0.546: the dense histories save g, X and F, not every state array. Passing a local inverse equation did not prevent the physical history from drifting.

![Error onset](<$USER_HOME/Documents/Codex/2026-11-12/can/outputs/Backward Hug error onset.png>)

## Cause supported by the controls

The velocity error concentrates in the finest retained Fourier mode, approximately **(5, −5, −5)**. At t=0.800, over **99.9989%** of its spectral power is in the upper retained band with squared wave index at least 50. This is inside the native retained band, not an accidental new high-frequency mode outside the filter.

In fresh isolated native controls at 0.700, that mode's velocity amplitude contracts to **0.91695122** after one forward step. A frozen-viscosity control using the same spatial operators gives **0.91695147**, corresponding to a reciprocal gain of **1.09057025**. The historical reconstruction actually grows its velocity error by a geometric mean factor of **1.09077677 per backward step** over 0.800 → 0.650. Halving the control perturbation amplitude leaves the measured gain unchanged to about 10⁻¹⁵.

This close agreement strongly supports amplification caused by undoing viscous damping as the dominant growth mechanism in that interval. It is a directional measurement, not a complete condition-number calculation or a proof about all Hug inverse branches. The general high-frequency instability of backward diffusion is explained in [Paul Houston's Oxford note](https://people.maths.ox.ac.uk/trefethen/pdectb/backward2.pdf); the Hug-specific numerical evidence is in this audit.

## What the supplied energy chart helps check

Your image illustrates an accounting identity for another model. Its numerical values and angular-frequency parameters were not applied to Hug. Here the native accounting is:

`E = kinetic + material stored energy + mean excess heat`

`W = threshold-force work + breathing work + write work`

Viscous dissipation transfers kinetic energy into heat inside this total. Subtracting a separate dissipated-energy term as well as retaining that heat would double-count the transfer. Backward amplification reverses that conversion: growing motion is largely paired with a heat deficit.

At **0.600**, the excess kinetic energy versus the reference is **0.00235517909**, the mean-heat difference is **−0.00235554240**, and the external-work difference is only **9.55 × 10⁻¹⁰**. The problem is not explained by a missing large driving-work term. A total-energy check alone can conceal a wrong state because large positive and negative terms cancel. The work-balance defect also grows later; there is no claim of exact discrete energy conservation.

| Time | Kinetic energy | Mean excess heat | Material energy | External work | Drift in E − W from prime 47 |
|---|---:|---:|---:|---:|---:|
| 0.800 | 5.442292e-05 | 0.0020778 | 7.256375e-07 | 0.0001449496 | -5.774703e-10 |
| 0.700 | 6.512993e-05 | 0.002059795 | 2.835038e-07 | 0.0001372098 | -7.801578e-10 |
| 0.600 | 0.002356097 | -0.0003028069 | 6.856342e-07 | 6.621202e-05 | -2.362161e-07 |
| 0.532 | 5.487229 | -5.486822 | 0.0001204598 | 9.525718e-05 | -0.001556283 |
| 0.524 | 14.97737 | -14.97981 | 0.0002851466 | 0.0001026609 | -0.004247476 |
| 0.500 | 304.9737 | -304.9913 | -0.06458238 | 0.0001655858 | -0.08439057 |
| 0.494 | 650.6314 | -648.3239 | -2.104215 | 0.0002341525 | 0.2010377 |


At 0.494 the kinetic energy is about 650.63, mean excess heat is −648.32 and material energy is −2.104. These large cancelling terms are not evidence of a healthy recovered state. The drift in total E − W is about 0.201, compared with its initial value about 0.001988. No uniform heat correction, clipping or ledger adjustment was applied.

## A smaller clock defect and its limited fix

The old 47-to-41 inverse computed `1.4 − i*h`, whereas its forward history used `1.2 + j*h`. They differ by one floating-point unit at **32 of 100 steps**, with maximum time difference 2.22 × 10⁻¹⁶. A native map comparison at 1.300 measures a maximum state difference of about **2.02 × 10⁻¹⁸** from this clock discrepancy.

The supplied **clock-aligned inverse-step wrapper** uses the exact archived forward timestamp, passes through the same complete carried state, and retains the original h and inverse function. Its clock regression has **zero mismatches across all 100 steps**, compared with 32 for the old expression. Historical source files and results remain intact. This wrapper has not been used to replay or replace the carried trajectory.

This is a real consistency defect, but its first occurrence is 1.342, after the first measured error at 1.398. The later segments already use matching integer-frame clocks. Its share of the subsequent error is not established; fixing it alone is not a demonstrated solution to the backward amplification.

## Why continuation remains pending

The negative temperatures and large velocity errors already belong to accepted saved states. Improving the 0.492 nonlinear solve cannot retroactively make those states accurate. More precision introduced at 0.524 was too late to prevent the first negative temperature at 0.546.

No repair has been shown that removes the existing damage while leaving the carried trajectory unchanged. A separately labelled reconstruction from the original boundary, with independently checked clock/precision and error control, would recompute that history; regularization would require explicitly specified additional assumptions. Neither is silently substituted for the current path, and neither is guaranteed to recover the original forward history from the rounded endpoint. The exact split of the initial seed among floating-point roundoff, allowed inverse residuals and clock differences remains unresolved.

The requested cause-first condition therefore remains unsatisfied: **write 11 is not attempted**. This is not a proof that the 0.492 algebraic inverse has no solution.

## Verification scope

Verified on November 12, 2026 at 08:04:55 PM PST. Newly performed: read-only measurements across 461 archived history rows, spectral analysis, energy extraction checked against the native statistics, eight isolated forward-map evaluations, clock regression, historical source-hash validation, and preservation checks. The read-only energy-statistics path needed an explicit 3×3 determinant because NumPy does not support the longdouble determinant; that temporary diagnostic substitution was removed before every native step.

All audited source hashes still match. The accepted 0.494 checkpoint SHA-256 remains `17ad632d555ba8667781ca5d92a6b5fa9418c3d7daa437bfdbb615099a5c7eed`. Its complete mentor frame and decoded record match the preceding verified result. The original native map, timestep, grid, constants and tolerance were not modified. Earlier native-step passes are retained as historical verification, not relabelled as freshly rerun tests. Some older extended-precision display histories are rounded views; the temperature onset comes from the original double-precision archive, and current full checkpoints were read at their native stored precision.
