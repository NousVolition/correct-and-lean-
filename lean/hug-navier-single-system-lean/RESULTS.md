# Full-equation Lean check: one shared Hug–Navier flow

**PARTIAL verification. The complete six-field shared-flow formulation recovered from the corpus is now represented in Lean. Seven theorems about that formulation and three checks of the earlier original A/S formulation passed native Lean, Linux Comparator, Lean's kernel and the independent nanoda kernel. Full PDE existence and uniqueness remain unproved.**

The equations were not changed to obtain these results. The source files and frozen mathematical statements have the same hashes before and after the independent checks. The reduced eight-state mechanical Hug model is not imported into this package.

## Which full equations were checked

The main source is `sources/ns_fields_methods.md`, with its matching implementation and protocol. Its six evolving fields are the two components of one velocity field, two internal participant-state fields, and the two directional relationship guards. Pressure enforces incompressibility. The guard is inside this evolution; no separately invented body/interface is required.

Writing (D=(\nabla u+\nabla u^T)/2), (L=\partial_t+u\cdot\nabla), and (\operatorname{sigmoid}(s)=1/(1+e^{-s})), the retained equations are:

\[
\partial_tu+u\cdot\nabla u=-\nabla p+\nabla\cdot(2\nu_gD),
\quad \nabla\cdot u=0,
\quad \nu_g=0.02+0.04(g_{AB}+g_{BA}),
\]
\[
Lx_A=0.02\Delta x_A+(-0.55-x_A)+k_{AB}g_{AB}(x_B-x_A)+s_A,
\]
\[
Lx_B=0.02\Delta x_B+(0.35-x_B)+k_{BA}g_{BA}(x_A-x_B)+s_B,
\]
\[
Lg_{AB}=0.015\Delta g_{AB}+
\frac{\operatorname{sigmoid}[-0.4+2(x_B-x_A)+0.5D:D]-g_{AB}}{0.6},
\]
\[
Lg_{BA}=0.015\Delta g_{BA}+
\frac{\operatorname{sigmoid}[-0.4+2(x_A-x_B)+0.5D:D]-g_{BA}}{0.6}.
\]

All spatial derivatives, transport, diffusion, directional interactions, strain feedback and the **full divergence of variable stress** remain present. The source's periodic square, nonuniform trigonometric initial fields, initial guards of 0.5 and specified optional pulse are encoded. Source decimals are represented as exact rational real numbers. These checks do not certify the source's floating-point solver.

The source itself describes this particular closure and its coefficients as provisional. This is the full equation set of that recorded realization; a passing proof does not establish that this realization exhausts the author's intended framework. Its participant labels remain fixed within an encounter; Lean does not establish that a numerical field measures the returning student's experience or the idea “giving someone space to speak can change what I understand.” Fluid names are not made into permanent person identities.

The original corpus's A/S–Navier branch is separately retained in `OriginalAS.lean`, in arbitrary finite spatial dimension. It includes the original accumulated integral from time zero, (J=\kappa A), transport and diffusion of S, localized input, gradient-threshold forcing, incompressibility and stress. Sharp, signed-tanh and exact-off responses remain distinct alternatives. No optional gradient smoothing was substituted. This earlier branch and the later guard realization have not been silently combined. An additional Monoxide state is not present in the six-field source above, so this result does not certify all earlier Monoxide variants.

## What passed

| Check | What Lean actually established |
|---|---|
| All six evolution equations together | A material-derivative identity for the sum of the six squared fields, using every evolution equation. It holds for trajectories satisfying those equations with the stated first spatial differentiability. This is a conditional mathematical bookkeeping identity, not a construction of a trajectory or a physical interpretation of internal-state energy. |
| Original starting flow | The exact source velocity field has zero divergence everywhere, without using a grid. |
| Variable stress | The product-rule expansion retains the guard-dependent viscosity-gradient terms. Replacing this divergence with just viscosity times a velocity Laplacian would generally omit terms. |
| Guard boundaries | At a spatial extremum with the specified zero-gradient and Laplacian signs, each guard's full PDE rate points inward at 0 and 1. This includes transport and diffusion. A global maximum-principle proof is still needed to conclude that guards never leave this interval. |
| Viscosity and stress work | **If** both guards lie in [0,1], viscosity lies in [0.02,0.10], and the local viscous stress contraction is nonnegative. This is not a proof that the entire six-field quadratic quantity decreases. |
| Pressure freedom — two theorems | Adding any spatially uniform function of time to pressure preserves a complete solution and its initial state. Thus every such solution has another pressure representative. This does not show nonuniqueness of the velocity, participant states or guards. |
| Original A/S — three theorems | Continuous input gives the original memory derivative; spatially uniform pressure shifts preserve the coupled differential equations; dimensional and normalized momentum equations agree when density is nonzero. |

The main balance theorem assumes all six evolution equations at the time being examined. It does **not** assume the energy conclusion, assume that a solution exists, or use a placeholder proof. Its proof differentiates all six squares and cancels the common transport terms.

## What still needs proof

1. Construct a solution of the complete spatial initial-value problem, and establish how long it exists. A finite-dimensional ODE theorem does not discharge this obligation.
2. Prove uniqueness of the full evolving state in a stated solution class. Pressure additionally requires a normalization if its absolute value is included in uniqueness.
3. Establish global guard bounds from the initial values using a parabolic maximum principle; the verified inward-direction checks are an ingredient, not that theorem.
4. Derive the spatial and time estimates needed for continuation and global regularity. Local stress positivity and the material balance alone do not provide them.

`FullExistenceStatement` and `FullUniquenessStatement` are explicit **unproved propositions**, not asserted axioms or passed theorems. The current solution predicate requires spatial C² fields, C¹ pressure, pointwise temporal derivatives, periodicity and initial values. Joint continuity or uniform bounds of the derivative fields are not supplied by that predicate; an analytic proof must state and justify its solution class. The original A/S branch also still needs its domain, initial/boundary data, kernel assumptions and chosen response law for a particular well-posedness theorem.

These are proof obligations for the shared evolution. They do not revive the earlier mistaken requirement to attach a separate mechanical Hug object to another fluid.

## Verification record

- Lean 4.34.0-rc2; mathlib commit `85e3a25e006c35636f0e53b0e9296caca2685bc0`.
- Comparator commit `19e111e2141cf333c7daff0f64c5f24acc91dd2e`; independent nanoda verification enabled.
- Fresh Linux project build, non-root Landrun isolation, clean pinned dependency sources, and source hashes checked before and after execution.
- Native proof build, Linux build, Comparator and both kernels passed. The ten reference statements matched the ten submitted theorems.
- Only `propext`, `Quot.sound` and `Classical.choice` were permitted. There are no unfinished proofs or added axioms in the solution/model files. Intentional placeholders occur only in the separate Comparator challenge file, which the solution does not import.
- Development failures are retained in the logs. One reference-hash preparation attempt failed on Windows text decoding; hashing was completed after the first solution file was written. The mathematical reference had already been compiled and was not altered. This timing exception is recorded; the run is not claimed to be a blind preregistration.

Source provenance here reuses the pinned files recovered in the preceding corpus audit. This run freshly checks their preservation and the mathematical proofs; it does not claim another exhaustive corpus search or that no newer remote revision exists.

See `verification-report.json` for the machine-readable result and `evidence-linux/comparator.log` for the independent check. The original source documents and earlier proof packages were preserved.
