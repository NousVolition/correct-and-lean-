# Which meter readings belong to this comparison?

The request to use helpful new meter ticks was applied as additional readouts of the saved finer-grid fields. It does not change the integration, material labels, tick-41 endpoint or declared gap tolerances.

- The current experiment uses 801 native markers, threshold 0.015, and the same 25 initial A/B pairs. Its original prime labels run from 2 to 41 at model times 0 to 1.2. The intermediate saved readings from 1.1 to 1.2 are labelled by model time; no new prime labels are invented.
- The prime meter records energy and work, including both sides of the writes. The same-pair meter evaluates local spin, strain and vorticity from each run's saved Fourier velocity field at that run's carried A/B positions. No older measurement is substituted for a finer-grid value.
- PR 14's prime-59 and prime-157 records belong to a separate 401-marker experiment. Its nine Hug statements check supplied meter records and arithmetic. They do not check the present fluid-grid refinement. PR 14 was observed open at revision `877b2b7bcc52cc9fbf1bc83f15c610b7aa3d92cb` during this review. [Package at that revision](https://github.com/NousVolition/hug-sims-lean-proofs/blob/877b2b7bcc52cc9fbf1bc83f15c610b7aa3d92cb/lean/hug-prime-meter-lean/README.md)
- The older two-memory Yang–Mills residual is defined from a spatially constant abelian potential. The source's `flat_curvature` and `source_free` statements therefore establish zero for that specified potential, independently of the present evolving fluid. That zero is not used as evidence of fluid convergence. [The specified potential and its two proofs](https://github.com/NousVolition/hug-sims-lean-proofs/blob/877b2b7bcc52cc9fbf1bc83f15c610b7aa3d92cb/lean/original-two-memory-transport-lean/TwoMemoryTransport.lean) were inspected directly.
- The earlier carried tangent-map and scalar-slope observations are separate measurements. They have not been reconstructed by the new local-spin meter. The threshold-1 experiment remains separate as well.

The numerical report states whether the gap targets pass. Meter agreement, a small energy defect or a green historical Lean receipt cannot substitute for that comparison.

AI-generated; dictated and directed by NousVolition.
