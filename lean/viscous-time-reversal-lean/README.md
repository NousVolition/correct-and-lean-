# Viscosity under time reversal

The user's question is whether forward viscosity stabilizes a mode while reversing its sign gives anti-diffusion. This package checks the corresponding real-scalar statements with the repository's pinned Lean, mathlib, Comparator, Lean kernel and nanoda workflow.

For a differentiable trace `f`, set `v(t) = f(T - t)`. The chain rule gives `v'(t) = -f'(T - t)`. Therefore an assumed equation `f' = ν lap` becomes `v' = -ν lap` at the reversed time. The supplied `lap` trace stands for the Laplacian evaluated along a field; the package does not construct that field or prove its regularity. The complete scalar right-hand side changes sign, including its transport and coupling contributions.

For a Laplacian eigenmode with eigenvalue `-q` (`q = |k|² ≥ 0`), the exact amplitude factors over a nonnegative duration are:

- forward: `exp(-(ν*q)*t) ≤ 1`;
- backward: `exp((ν*q)*t) ≥ 1`.

Both inequalities are strict when `ν`, `q` and `t` are positive. Larger `q` gives at least as much backward amplification. Exact forward and backward factors multiply to one; that algebraic identity does not make reconstruction from perturbed data stable.

At the Euler-increment level, a negative step already reverses the rate. Negating viscosity as well restores the original increment. This does not assert that reversing a finite-step integrator exactly undoes its earlier steps.

## Checks

There are 14 declarations in `comparator.json`. The challenge freezes their statements and is excluded from the solution's imports. The proof file contains the completed arguments. Definitions, statements, solution and dependency pins are hashed in `verification-inputs.json`.

From this directory, `lake build` builds the proofs. The repository's **Lean verification** workflow also compares the frozen statements, runs both kernels and checks all 14 theorem dependency lists. Its `proof-viscous-time-reversal-lean-1` artifact contains the actual run evidence. The checked-in report starts at NOT_RUN because no local Linux evidence is bundled; use the workflow result for this branch's fresh verification.

## Scope

These statements concern the time change and a scalar eigenmode. They do not certify the full coupled Hug evolution, its numerical solver, threshold-1 histories, energy residuals, or Yang–Mills/readJet claims. The physical Hug interpretation and source implementation remain those recorded in the repository's scope correction and proof-status documents.
