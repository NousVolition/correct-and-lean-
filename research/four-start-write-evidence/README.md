# Four-start state and actuator-work evidence

**Numerical evidence: PASS. Overall declared audit: PARTIAL.** The completed local study covers all four A/B trust starts, each with a journal arm and matched control at two integration steps. It records 16 trajectories through model time 1.3. The numerical checks passed; the strict all-file preservation check failed because two README files changed during concurrent work. The numerical sources, journal rules and compared run data were recorded as unchanged.

This study supplies evidence relevant to [packages 10–17 in the proof walkthrough](../../lean/README.md#plain-language-walkthrough). It uses the existing fixed-deformation writer and is separate from the [overlapping-writes chart](../overlapping-writes-chart/README.md), where the flow continues during overlapping strokes. Neither numerical study establishes a Lean theorem or full spatial/memory existence and uniqueness.

## Methods

The four initial trust pairs are (1, 1), (1, 0), (0, 1) and (0, 0). Flow integration uses steps 0.002 and 0.001; the journal cadence stays 0.002. The control retains the same quantized prefix recall in software and the original event fabric, while omitting journal cells and journal writes. It isolates the modeled journal addition, without modeling the physical cost of software memory.

Each write follows the original linear stroke with deformation and the main flow clock fixed. Generalized force is sampled at eight Gauss–Legendre nodes and integrated as force × rate over the prescribed stroke duration; a four-node integral provides a numerical cross-check. Neither integral is obtained from a stored-energy difference or the writer's work account. This is a separate numerical computation under the declared force law, not an empirical measurement. Stroke drag remains 0.05 and duration 0.02.

## Results

The completed archive records **26,256 full numerical snapshots**, **15,600 accepted flow steps** and **5,256 paired writes**. States were saved at accepted substeps and immediately before and after every journal and event write, including time zero. The original verifier reopened the arrays and force samples, checked their integrity and recomputed balances. All 16 checkpoint restarts reproduced the next interval exactly.

| Recorded check | Result |
| --- | --- |
| Maximum full-system energy residual | 1.20941 × 10⁻⁹, below the declared 10⁻⁶ criterion |
| Maximum per-write residual using force-integrated work | 1.18391 × 10⁻¹⁸ |
| Numerical evidence across all four starts, both arms and both steps | PASS |
| Strict preservation of every protected original file | FAIL: 202 of 204 unchanged; two README changes |
| Overall declared audit | PARTIAL |

At time 1.3 with integration step 0.001, extra supplied work lies between 0.0001092331 and 0.0001104815 normalized energy units across the four starts. Extra retained heat is approximately 100.07% of that work; the smaller mechanical-energy gain in the journal arm accounts for the excess over 100%. Each arm subtracts its own initial energy before any time-zero write. Exact per-start values and offsets are retained in the [evidence summary](evidence-summary.json).

## Verification and publication scope

The completed numerical receipt was recorded on **12 November 2026 at 22:36 Pacific (13 November at 06:36 UTC)**. For this publication, read-only checks matched all state, pair and flow index counts to the 16 run receipts, checked every write's pre/post references and recorded times, reconciled totals and worst residuals, rehashed all 36 copied sources, and verified all four preserved before/after README copies. The failed strict preservation criterion remains FAIL.

This publication did not rerun the solver, reopen all full-state arrays, repeat the restart tests or compile Lean. The [machine-readable summary](evidence-summary.json) distinguishes the original numerical verification from these publication checks and identifies the source receipts by SHA-256. Only this explanation and summary are published here. The approximately 33.18 GB state archive, force arrays, full source package and original receipts remain local; this page is not a complete public reproduction package.

## Limitations

These are finite computations for the specified implementation. They do not establish spatial convergence, continuous field histories between accepted steps, hardware/controller costs, robustness to stroke-parameter changes, or a write during which the fluid evolves. The overlapping-write schedule is outside this study. Full spatial and memory-system existence, uniqueness and continuation remain unproved.

The underlying intended Hug system retains its unforced interpretation. Prescribed interventions in this experiment do not redefine it. [Meaning and source correction](../comparisons/hug-navier-single-system-scope-correction.md#meaning-to-preserve-across-implementations).

**Credits:** AI-generated; dictated and directed by NousVolition. This numerical evidence and its publication review were produced by Codex (OpenAI). Prior source, model and review credits remain in force; no Lean execution is attributed to Claude. [Preserved observation-package credits](../ambiguous-observation-lean/CREDITS.md) · [Repository reuse terms](../../LICENSE).
