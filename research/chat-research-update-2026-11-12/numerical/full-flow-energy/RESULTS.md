# Full-flow energy result

**PASS** for the declared A=1, B=0 comparison through time 1.3.

The control has no material-journal cells or writes, but retains the same quantized feature-prefix information in software. This isolates the physical journal addition; it is not a claim that software memory has no real-world cost.

All values below are dimensionless model units. Initial energies are measured before any time-zero write.

| Quantity at time 1.3, refined step 0.001 | Journal minus control |
|---|---:|
| Extra total supplied work | 0.000110046165491 |
| Extra continuous driving work | -2.36835169553e-07 |
| Journal write work | 0.000109753586878 |
| Change in event-write work | 5.29413781606e-07 |
| Extra net heat retained | 0.000110123108518 |
| Extra mechanical stored-energy gain | -7.69430444828e-08 |
| Extra kinetic-energy gain | -1.334223728e-07 |
| Extra continuum-elastic gain | -3.38923507795e-07 |
| Extra event-fabric gain | -1.42462753239e-08 |
| Extra journal-fabric gain | 4.09649111437e-07 |
| Initial total-energy difference | 6.75794733149e-07 |
| Final absolute total-energy difference | 0.000110721960206 |
| Differential allocation residual | 1.7259034913e-14 |

The absolute final energy difference equals the initial difference plus the difference in energy gains. The work allocation uses gains, so the initial stored energy is not counted as new work.

| Arm | Step | Maximum absolute total-energy residual | Original criterion |
|---|---:|---:|---:|
| journal | 0.002 | 1.20939316493e-09 | 1e-06 |
| journal | 0.001 | 1.45823011327e-10 | 1e-06 |
| control | 0.002 | 1.20909615463e-09 | 1e-06 |
| control | 0.001 | 1.45840269386e-10 | 1e-06 |

Time halving reduced maximum residuals by factors 0.120575355935 (journal) and 0.120619248376 (control). The maximum refined differential allocation residual is 4.8891243159e-14, or 4.44279e-08% of peak extra work.

Endpoint sensitivity to time refinement is reported separately from balance closure:

| Extra quantity | Step 0.002 | Step 0.001 | Signed change |
|---|---:|---:|---:|
| work | 0.000109997448742 | 0.000110046165491 | 4.87167486251e-08 |
| net_heat | 0.000110074245298 | 0.000110123108518 | 4.88632194219e-08 |
| mechanical_change | -7.67962594168e-08 | -7.69430444828e-08 | -1.46785065954e-10 |

Discrete quantized sample/CRC changes can change write costs between refined trajectories. A tiny energy residual does not establish that every allocation value is equally insensitive to integration step.

The standard-step journal trajectory matched every array of the previously published final state: **True**. Instrumentation did not substitute new dynamics.

The largest sampled instantaneous energy-rate defect across all runs was 4.33680868994e-19. The largest write-jump energy error was 9.45235829577e-19.

This is a numerical energy-accounting verification for the declared finite comparison, not a universal continuation theorem. Refinement keeps journal sampling/writing at 0.002 and changes only integration substeps.

[Extra-work plot](extra-work.png) · [Energy verification plot](energy-verification.png) · [Equations and source review](README.md) · [Machine-readable verification](verification.json)
