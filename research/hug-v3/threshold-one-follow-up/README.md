# Threshold 1 with the same water particles

The force threshold was changed from **0.015 to 1** from the original time-zero state, following the same water particle A and its original partner B. With the added breathing force kept on, the closest point on the traced line still switches in the late comparison window. The three resolved exchanges occur before prime tick 41, at model time 1.2.

| Exchange | Approximate model time | Position along the traced line, before → after |
| --- | ---: | ---: |
| 1 | 1.180910 | 0.068715 → 0.538077 |
| 2 | 1.182077 | 0.448370 → 0.047506 |
| 3 | 1.199281 | 0.000000 → 0.367992 |

These exchanges change which part of the traced line is closest to B. The identities of water particles A and B stay fixed. The old event near 1.178285 does not recur at that time in the threshold-1 run. At that instant, the closest candidate is separated from the next candidate by a distance margin of about 0.020806 cube lengths. [Resolved exchanges](resolved-switches.json) · [Full closest-point readings](closest-point-readings.csv)

## What changed and what stayed the same

The only physical parameter changed from the breathing-on baseline was the force threshold. The run kept the original time-zero arrays, 16³ periodic grid, viscosity, material and fabric, heat, actors, memory rules and three-write schedule. Its actual main integration step was 0.002 through time 1.2. The added breathing force retained peak component 0.5 and period 0.6, with no fade. The writes were recomputed from each run's evolving state. [Configuration](configuration.json)

A and B are the original pair selected in the earlier 10% neck study, seed 12. Their starting positions were recovered from the original particle maps and reused. A comparison replay reproduced sixteen saved checkpoint sides within 9.99 × 10⁻¹⁶ and returned the particles to their tagged positions within 9.64 × 10⁻¹⁵ cube lengths. The records contain 601 particle readings. Vorticity is zero at time zero, where a vortex-line direction is undefined, followed by line searches at all 600 subsequent native times. [Particle trajectories](particle-trajectories.csv) · [Recorded checks](run-checks.json)

The measurement traces forward from A for 0.75 cube lengths and selects the nearest resolved candidate to B using periodic three-dimensional distance. All three memory writes were accepted and decoded. Each write preserved water positions, velocity and context across the write instant.

## What the numerical checks establish

The local refinement used 32 and 64 substeps per original step in the late intervals, with tighter line tracing. Both levels produced the same three brackets, each about 1.91 × 10⁻⁹ wide. This describes the local event resolution. The earlier integration history still uses the 0.002 step and the same fixed grid. Spatial and full-history convergence have not been established for these event times.

Breathing remained on throughout this rerun. At time 1.2, the signed accumulated work is approximately 0.0000244243 for the threshold force and 0.0001058562 for breathing. Both contributions coexist with the material and fluid dynamics. A matched threshold-1 run with breathing off is still needed to establish how the switches depend on breathing. The earlier breathing-off experiment used threshold 0.015.

## Connection beyond the visible trace

The open interpretation motivating a further measurement is

> If we can’t see where it comes from or continues, we can mistake the edge of our view for an edge in the connection. The first visible space then gets treated as the important gap before we’ve followed the whole path.

A change in the nearest point can occur between different portions of a connected curve. This question distinguishes the limit of the observed segment from a break in the path itself.

The recorded measurement traces only 0.75 cube lengths forward from A. It includes an eligible trace endpoint among its candidates, and the third late exchange starts at arclength zero. Establishing how the observed exchanges depend on the start and finite window requires additional measurements, such as extending the trace in both directions while retaining the same A and B. The current records do not establish a closed circulation loop or settle which apparent gap carries the proposed significance.

## What Lean has checked

**No Lean theorem checks this threshold-1 trajectory or its closest-point exchanges.** This directory publishes numerical observations, their configuration and saved verification records. The configuration differences, source fingerprints, CSV counts and agreement of the recorded refinement brackets were checked before publication. No new simulation was run for this documentation update. [File provenance and hashes](provenance.json)

[PR #14](https://github.com/NousVolition/hug-sims-lean-proofs/pull/14) contains separate proof work. Its nine Hug meter statements check finite energy-account calculations and displayed rounding from the **threshold-0.015** three- and four-write measurements. Its sixteen original-transport statements concern a specified two-memory mathematical model and supporting lemmas. Those checks do not cover the threshold-1 switches recorded here. [PR #14 proof run](https://github.com/NousVolition/hug-sims-lean-proofs/actions/runs/42852357760)

The numerical values in the linked data records are preserved from the local study. Text line endings are normalized to LF, with original and published file hashes retained separately. The configuration replaces personal source paths with descriptive artifact names and keeps their hashes. Raw simulation states and the complete executable replay environment are outside this record. This publication preserves the earlier threshold-0.015 results as a separate experiment.
