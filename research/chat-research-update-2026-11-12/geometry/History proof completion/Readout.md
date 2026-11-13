# Same A history: checked progress, incomplete proof

**PARTIAL. The complete fluid pair has not been proved in Lean.** Four new modules compile and their 23 principal theorem reports use only Lean's standard logical axioms. Those checks establish the specific results below; they do not establish the existence of the two requested fluid states.

The intended claim remains two smooth solutions of the same unforced periodic Navier–Stokes equations, with viscosity 3/200, the same material path A and actual vorticity history from 1.178 to 1.2, the same closest-point reading at 1.2, and a closed versus nonreturning vortex line with a positive swirl bound. This is the constructed mathematical example, not a replay of the saved Hug trajectory.

## What Lean checked

| File | Checked result | Limit of that result |
|---|---|---|
| `lean/HistoryPlanarBase.lean` | The explicit common planar velocity and pressure satisfy the actual, unforced Navier–Stokes equations. The file also proves their derivatives, curl, divergence, periodicity and analytic regularity. | This is the common component of the proposed flows. It does not construct their additional scalar fields. |
| `lean/HistoryParameterSelection.lean` | From the stated continuity and positive-derivative hypotheses, there are small positive parameters for which the displacement is exactly `sqrt 2 / N`, with positive natural `N`, hence irrational. The selection can preserve every condition proved on the supplied parameter rectangle. | The hypotheses have not been proved for the displacement of the proposed fluid's actual vortex line. No decimal approximation is used as an exact irrational witness. |
| `lean/HistoryScalarLift.lean` | Given an actual smooth periodic scalar solution of the stated advection–diffusion equation, adding it as the third velocity component yields a full unforced fluid with the displayed pressure and actual curl. | A `ScalarEvolution` is a structure containing the needed function and proofs. Defining this structure does not construct an inhabitant. `SmallParameterThreeScalarExistence` is still an unproved proposition. |
| `lean/HistoryCompletionTarget.lean` | A precise final target `FullPairExists`, the attainment of the closest reading for a supplied certified state, and the ambiguity-theorem consequence **if** the complete pair is supplied. | There is no proof of `FullPairExists`. The conditional reader theorem consumes the desired pair as a hypothesis. |

The 23 reports comprise 9 for the common planar fluid, 5 for abstract parameter selection, 6 for the conditional scalar-to-fluid construction, and 3 for target-related consequences. The earlier `HistoryMatchCore` and `SIMSLatentReadout` were reused after checking their source and object hashes against the earlier verification record; their earlier checks are not counted as new checks.

## Correction to my draft

In the installed Mathlib version, `ContDiff ... ⊤` asks for analytic regularity, usually written Cω. Ordinary smoothness, C∞, is written `ContDiff ... ∞` with the `ContDiff` notation scope open. I had used the stronger notation in the draft scalar interface and final target.

The scalar interface, its smoothness consequence, and the final fluid target now use C∞. Both affected modules were checked again successfully. The explicit trigonometric base flow still has the stronger analytic proof, which implies smoothness. The correction changes the unintended regularity demand in my draft; it does not change the viscosity, forcing, pressure formula, particle history, or required line geometry.

The source confirming this distinction is the installed pinned Mathlib file `Mathlib/Analysis/Calculus/ContDiff/Defs.lean`, especially its notation explanation and definitions. Smoothness is required on forward time t ≥ 0, and the momentum equation on t > 0; no backward heat solution is being assumed.

## What is still needed

1. Construct the three smooth periodic scalar solutions S, F and G for sufficiently small parameter ε, with the specified initial conditions.
2. Prove uniqueness, preservation of their symmetries, and sufficiently strong dependence on ε. These justify equality of A's history and the uniform positivity and strip bounds.
3. Construct the actual implicit level curve and displacement function. Prove the continuity and positive derivative needed by the checked parameter-selection theorem, including differentiation under the integral.
4. Construct complete curl trajectories with the correct tracing clock. Prove their integer-turn displacement, closed/nonreturning behavior, nonzero swirl bound and closest-point reading.
5. Verify the rotation and constant-velocity change of frame, and assemble the two actual fluid states with the shared moving A and pressure.

The exact acceptance criterion is a **closed proof** of `HistoryCompletionTarget.FullPairExists`, with no assumed fluid witnesses or additional existence axioms. Compiling the target definition is not that proof. The detailed obligations are in `Remaining obligations.md`.

## Verification limits

The checks used Lean 4.34.0-rc2 and Mathlib commit `85e3a25e006c35636f0e53b0e9296caca2685bc0` in the existing verification environment. Each new module's latest verification record is PASS. The principal axiom reports contain only `propext`, `Classical.choice`, and `Quot.sound`; no `sorry`, `admit`, added axiom, or `native_decide` was used in the new sources. The checks also pinned the Lean executable and verified that the installed Mathlib tracked files were clean.

The aggregate `Verification.json` records the precise scope and hashes. Earlier failed compiler logs are retained as diagnostics and are not PASS evidence. No fresh-environment build, new numerical simulation, or end-to-end fluid-pair proof was completed. Earlier analytical and numerical evidence remains historical evidence, with its original limitations.

My earlier description of the remaining task as just “existence and parameter selection” understated the formal work. Abstract parameter selection is now checked; constructing the fluid-specific objects and proving the geometric and historical conclusions remain substantial obligations.
