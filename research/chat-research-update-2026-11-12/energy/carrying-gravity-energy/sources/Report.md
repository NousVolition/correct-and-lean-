# Tick 41: coupled influence test

The native SIMS run shows influence both along and across the local current while model time advances forward. Applying the third write changes the clay and heat at the same instant. The resulting changes in stress, viscosity and record readout change flow acceleration and actor rates; the whole states then separate during continued evolution.

## Test performed

- Original threshold-one Hug v3 solver, grid 16³, 384 material points and six actors.
- The preserved breathing-on input stays active in both branches: peak 0.5, period 0.6. No feedback is disabled.
- Reconstructed time 1.2, frame 600, tick 41 from the saved frame 599 plus its original 0.002 step. The third native event uses the held deformation from time 0.8.
- **Written branch:** applies the native third write. **Withheld branch:** omits that write as a controlled intervention.
- Both start with exactly the same velocity, carried field, material positions, deformation, A and actor values. Only the native write's clay, heat and write-work updates differ.
- Both complete states then evolve to time 1.3 with steps 0.002, 0.001 and 0.0005. These are local continuations from one shared checkpoint, not fresh full-history refinements.

## What changed

| Measurement | Result |
| --- | ---: |
| Reconstructed written state versus saved frame 600, maximum absolute error | **0** across all 17 state arrays |
| Velocity difference at the write | **0** |
| Acceleration difference along the local current, RMS | 1.7711158e-05 |
| Acceleration difference across the local current, RMS | 1.8487278e-05 |
| A-rate relative change immediately at the write | **1.4003%** |
| Velocity difference along the current at time 1.3, RMS | 1.5510029e-06 |
| Velocity difference across the current at time 1.3, RMS | 1.2263395e-06 |
| A-value difference at time 1.3 | 1.1573892e-05 |
| Carried-field difference at time 1.3, RMS | 2.8125467e-06 |
| Temperature difference at time 1.3, RMS | 6.2577081e-05 |
| Deformation difference at time 1.3, component RMS | 2.4034443e-06 |

All quantities are in this synthetic model's units. Vector RMS is the root mean squared vector length over grid points; actor and deformation RMS average individual components.

The across-current component accounts for 52.14% of the squared acceleration difference at the write. This is a direction decomposition, not a fraction of heat or total system energy. The reference is the local shared velocity, rather than an imposed global forward axis. All 4,096 grid points have a nonzero reference velocity. At time 1.3 the reference is the withheld branch's local velocity.

![Paired flow and actor differences](results/tick41-coupled-response.png)

## Which actors changed

Actor IDs are the original zero-based indices. An actor row uses that actor as the array's first index. A difference counts here only if its largest component exceeds 10⁻¹².

| State block | Actor rows whose rates change immediately | Actor rows whose values differ at time 1.3 |
| --- | --- | --- |
| association | 0 | 0, 1 |
| relation | 0 | 0, 1, 2, 3, 4, 5 |
| responses | 0, 1, 2, 3, 4, 5 | 0, 1, 2, 3, 4, 5 |
| expression | None | 0, 1, 2, 3, 4, 5 |
| context | None | 0, 1, 2, 3, 4, 5 |
| norm | None | 0, 1, 2, 3, 4, 5 |
| logradius | 0 | 0, 1, 2, 3, 4, 5 |

All six actors' response rates change at the write. Immediate association and relation rate changes are concentrated in actor 0's row, which reads the newly written event from actor 1. By time 1.3 all six actors have different relations and responses. Associations differ for actors 0 and 1; the other association rows remain equal in this test. All actor values are equal at the instant of writing; a changed rate affects later values.

## Coupling and numerical checks

The acceleration jump matches the unchanged solver's projected divergence of the changed constitutive stress plus changed viscous stress, with maximum component error 5.22e-17. The pressure identity error is 8.3e-19. The common prescribed breathing force cancels in this instantaneous difference.

The 0.001 versus 0.0005 velocity-difference error is **0.000963%** of the finest velocity difference. The second step halving reduces the refinement discrepancy by a factor of 4.0452. For every listed field, the refinement discrepancy gets smaller while the write-versus-withheld difference remains nonzero. The largest relative half-to-quarter discrepancy among the 12 listed fields is 0.001430%. See `results/validation.json` for the separate velocity, carried-field, heat and actor checks.

Every sampled state remained finite; the native material record read and checksum passed throughout. The written branch retained event IDs [0, 1, 2], the withheld branch [0, 1], and their record payloads stayed unchanged. Endpoint velocity divergence was below 10⁻¹¹ on every run. Original source and input hashes were checked before execution.

## What this establishes

The flow acts as a surrounding influence on a local actor or mark, while remaining part of the same coupled system. Changing the retained material and heat changes that surrounding flow in return. A forward-running clock is compatible with influence along a current, across it and through later feedback.

This experiment does not isolate the semantic record from its physical write: clay, heat and work change together. It does not test backward causation, a lateral direction of time, or a mathematical linear-response law. The grid remains fixed; the convergence check concerns the short forward continuation, not the continuum limit. The prescribed breathing input belongs to this numerical branch; this test makes no new claim about an unforced continuum model.

## Reproduction

Use Python 3.12 with NumPy 2.3.5, SciPy 1.18.1 and Matplotlib 3.10.8:

```text
python -B run_coupling_test.py
python -B summarize_results.py
```

The preserved source, declarations and checkpoints are in `inputs/`. `original-input-manifest.json` retains their original paths and SHA-256 values. No original solver file was edited. `results/paired-timeseries.csv` contains the common 0.002-spaced readouts for all three integrations; endpoint NPZ files retain every state block.

Generated 2026-11-12T01:10:20.031302+00:00.
