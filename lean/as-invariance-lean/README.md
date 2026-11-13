# Meaning bounds for the unchanged A/S equation

**A/S update:** The [suppression comparison](../as-suppression-lean/README.md) is now proved for both S coordinates throughout each finite interval, with matched starting data and inputs. **The repeated-encounter process remains open.**

This package proves `SocialAS.Verified.full_state_invariance`, with exactly
the previously recorded type `SocialAS.Open.FullStateInvariance`. See
`verification-report.json` for the completed checking result and evidence.

The model retains **one agent and one idea: “Giving someone space to speak
can change what I understand.”** Smoke and Clay remain that agent's inward
positions. Monoxide is the corpus's adverse social interaction mechanism.
No equation, parameter domain, or final theorem assumption is changed.

## What the theorem establishes

Fix any finite interval [a,b] with a≤b, parameters satisfying `ParametersOK`,
inputs satisfying `InputsOK` and the original `RegularInputs`, and an initial
state satisfying `StateOK`. Every `IntegralSolution` of the original seven-state
equation then satisfies, at every time t in [a,b]:

- 0 ≤ z_Smoke(t) ≤ 1;
- 0 ≤ z_Clay(t) ≤ 1;
- L_forward(t) ≥ 0 and L_reverse(t) ≥ 0.

This closes the entire original `FullStateInvariance` obligation, including
the requested meaning bounds. It applies to nonzero initial states, zero rates,
states on either boundary, a=b, and the allowed input switches. A and S remain
signed. Values outside the specified time interval are not constrained by this
theorem. It does not require the numerical fixture's particular parameter values.

`RegularInputs` retains its original boundedness and continuity outside a finite
set for the specified input quantities. The sign and interval restrictions on
parameters, inputs, and initial states are the original premises, not conclusions
inferred from the social interpretation.

## Proof argument

1. **Load and rates.** The previously proved integral barrier keeps each adverse
   history nonnegative. Positive scale parameters then ensure the suppression and
   distortion coefficients lie in [0,1]. Interaction rates and clarification rates
   are nonnegative. This applies even when influence S is signed.
2. **Scalar bounds.** For an equation z′ = k(r−z)+c(v−z), with k,c≥0 and r,v in
   [0,1], the drift cannot move a nonpositive value farther below zero. The same
   argument for 1−z rules out crossing above one. The formal proof uses the
   integral solution and the last-zero argument, so no derivative at a switching
   instant is needed.
3. **Both states together.** It would be circular to assume one meaning state is
   bounded in order to prove the other's bound. Instead, an auxiliary construction
   projects only the incoming partner value into [0,1]. This projection is
   Lipschitz, so the existing integral existence theorem constructs a solution.
   Both scalar boundary arguments then apply independently to that solution.
4. **Eliminate the auxiliary construction.** The bounds prove that the projection
   equals the identity everywhere along the constructed solution.
   `original_of_clipped` formally proves that it satisfies the exact original
   meaning equation. Uniqueness of that original equation identifies it with the
   original stage solution. Finally, `assemble_unique` transfers the bounds to
   every full integral solution. No projection is added to `ASModel.lean` or to
   the candidate equation register; no trajectory is clipped after computation.

The auxiliary field is a proof device, not a revised candidate model. Its removal
is a required checked step before the original theorem is obtained.

## Proof and verification files

| File | Purpose |
| --- | --- |
| `ASModel.lean` | Unchanged original equation definitions |
| `ASOpenClaims.lean` | Unchanged original quantified target and assumptions |
| `MeaningBounds.lean` | Projection facts and scalar integral bounds |
| `ClippedConstruction.lean` | Existence of the auxiliary coupled path |
| `CoupledMeaningBounds.lean` | Bounds, elimination of the projection, and stage invariance |
| `ASInvarianceSolution.lean` | Proof of the exact full-state target |
| `ASInvarianceChallenge.lean` | Protected Comparator reference |
| `invariance-reference-freeze.json` | Original model, statement and equation hashes |
| `verification-inputs.json` | Exact source/configuration hashes supplied to the check |
| `full-theorem-build.log` | Complete native Lean build and axiom report |
| `evidence-linux/comparator.log` | Comparator and both proof-kernel results |
| `evidence-linux/lake-build.log` | Fresh Linux ordinary build |
| `evidence-linux/postflight.json` | Source and dependency preservation checks |
| `verification-report.json` | Final outcome and evidence hashes |

The build uses Lean 4.34.0-rc2, mathlib commit
`85e3a25e006c35636f0e53b0e9296caca2685bc0`, and Comparator commit
`19e111e2141cf333c7daff0f64c5f24acc91dd2e`. Comparator checks the protected target,
allows only `propext`, `Classical.choice`, and `Quot.sound`, and replays the proof
with both the Lean kernel and nanoda. Linux verification starts with no compiled
A/S solution and uses the same nonprivileged Landrun isolation route as before.

The intentional reference placeholders in the separate challenge files are not
imported by the solution. The inherited proof files and both earlier packages
are preserved. This package adds proofs rather than rewriting previous evidence.

To reproduce, run `build-native.ps1` for this workspace's native toolchain, or
`run-linux-check.sh` as the configured nonprivileged Linux user with a fresh
destination. The latter runs Comparator and the ordinary Linux build. A standard
`lake build` also builds the new proof with the pinned dependencies.

## What remains outside this result

- The [whole-trajectory suppression comparison](../as-suppression-lean/README.md) is now proved.
- A repeated-encounter stochastic process and its event ordering/coupling remain
  to be specified and verified.
- Numerical approximation error bounds remain uncertified.
- Measuring and empirically validating the social variables remains separate.

The theorem guarantees the mathematical meaning states remain within their
declared interval under the stated premises. It does not establish that a larger
meaning value is socially better, that Monoxide always worsens an outcome, or
that observed human experience follows the equations.

## Comparator references

The current question is `ASInvarianceChallenge.lean`. Its solution is
`ASInvarianceSolution.lean`. The sibling `ASExistenceChallenge.lean` is an
archived copy of the preceding A/S existence question, retained at its original
path for the recorded package hashes. The invariance solution imports the
proved existence modules. Its default build checks the invariance solution.
[Current Comparator targets](comparator.json)
