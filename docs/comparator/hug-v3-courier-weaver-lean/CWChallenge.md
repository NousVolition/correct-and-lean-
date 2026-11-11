# What Courier and Weaver contribute to the motion

Compare their work, heat and responses to velocity reversal. The same accepted native rate can accompany different wizard coupling coefficients.

[`CWChallenge.lean`](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWChallenge.lean) · [Package configuration](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 NousVolition. All rights reserved. The repository notice applies to material for which NousVolition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project creator supplied the Seven-Wizard/Hearth details and recalls that Codex may have drafted the submitted Lean file. The surviving file has no writer byline. Credit for the submission is recorded under its filename, Submitted.lean. [Original Submitted.lean](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/original/Submitted.lean) · [Seven-wizard algebra](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/SevenWizardAlgebra.lean) · [Hearth audit proofs](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthProofs.lean).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWAll.lean) · [CWDefinitions](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWDefinitions.lean) · [Statement and proof inputs](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/lake-manifest.json).

</details>

## Can a spatial derivative move to the other side of a grid sum?

`spectral_integration_by_parts`

**Proof request**

Prove the grid integration-by-parts identity for the spectral derivative.

**Reading the result**

Spectral integration by parts moves it from one factor to the other and reverses the sign.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem spectral_integration_by_parts (f g : Scalar) (j : Axis) :
    (∑ x, f x*grad g x j) = -(∑ x, g x*grad f x j) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWChallenge.lean#L7-L8) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWWork.lean#L29-L49)

## What work does the raw Weaver term do?

`raw_weaver_work_is_minus_heat`

**Proof request**

Identify the raw Weaver work with minus total heat.

**Reading the result**

Pairing it with velocity gives the negative of the defined heat.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem raw_weaver_work_is_minus_heat (s : State) :
    inner (velocity s) (rawWeaver s (velocity s)) = -heat s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWChallenge.lean#L10-L11) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWWork.lean#L67-L91)

## Does the raw Courier term do work against its own velocity?

`raw_courier_work_is_zero`

**Proof request**

Prove zero pointwise work for raw self-advection by Courier.

**Reading the result**

At each point its dot product with that velocity vanishes.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem raw_courier_work_is_zero (u : Vector) (x : Grid) :
    dot (u x) (rawCourier u u x)=0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWChallenge.lean#L13-L14) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWWork.lean#L93-L96)

## Where do Courier and Weaver enter an accepted velocity rate?

`accepted_velocity_decomposes`

**Proof request**

Decompose the accepted velocity rate into Courier, Weaver and the resolved other forces.

**Reading the result**

Expanding the accepted rate gives their sum plus the resolved remaining forces.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem accepted_velocity_decomposes (G : Geometry) (s d : State) (t : ℝ)
    (accepted : rhs G t s=some d) (x : Grid) (i : Axis) :
    velocity d x i = courier (velocity s) x i+weaver s (velocity s) x i+
      resolve (otherForces G s) x i := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWChallenge.lean#L16-L19) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWProofs.lean#L17-L39)

## How can the directional bracket be measured with a derivative?

`bracket_as_velocity_derivative`

**Proof request**

Represent the directional bracket as the derivative of the stated perturbed difference.

**Reading the result**

Vary each operator’s velocity in the other operator’s direction and differentiate their displayed difference at zero.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem bracket_as_velocity_derivative (s : State) (u : Vector) (x : Grid) (i : Axis) :
    HasDerivAt (fun e : ℝ => courier (mix 1 e u (weaver s u)) x i -
      weaver s (mix 1 e u (courier u)) x i) (directionalBracket s u x i) 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWChallenge.lean#L21-L23) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWProofs.lean#L63-L66)

## What changes if the velocity is reversed?

`reversed_native_roles`

**Proof request**

Determine the parity of Courier, Weaver and local viscous heat under velocity reversal.

**Reading the result**

The Courier term keeps its sign, Weaver changes sign, and viscous heat at every point retains its value.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem reversed_native_roles (s : State) :
    courier (velocity (reversed s))=courier (velocity s) ∧
    weaver (reversed s) (velocity (reversed s))= -weaver s (velocity s) ∧
    (∀ x, viscousHeat (reversed s) x=viscousHeat s x) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWChallenge.lean#L25-L28) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWProofs.lean#L89-L97)

## What happens to their pairing and total heat under reversal?

`pairing_reverses_and_heat_agrees`

**Proof request**

Prove that reversing velocity negates their pairing and preserves total heat.

**Reading the result**

The pairing reverses sign while the heat sum stays fixed.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem pairing_reverses_and_heat_agrees (s : State) :
    pairing (reversed s)= -pairing s ∧ heat (reversed s)=heat s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWChallenge.lean#L30-L31) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWProofs.lean#L99-L104)

## Could one coefficient relate the pairing to heat before and after reversal?

`no_common_coefficient_at_nonzero_pair`

**Proof request**

Exclude a common proportionality coefficient for both states when the pairing is nonzero.

**Reading the result**

A nonzero pairing changes sign against the same heat, contradicting either common coefficient.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem no_common_coefficient_at_nonzero_pair (s : State) (nonzero : pairing s≠0) :
    ¬ ∃ k : ℝ, pairing s=k*heat s ∧ pairing (reversed s)=k*heat (reversed s) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWChallenge.lean#L33-L34) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWProofs.lean#L106-L111)

## Does the order of two fields matter in their inner product?

`dot_pair_is_symmetric`

**Proof request**

Prove symmetry of the finite velocity inner product.

**Reading the result**

Interchanging the real factors in the sum gives the same scalar.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem dot_pair_is_symmetric (u v : Vector) : inner u v=inner v u := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWChallenge.lean#L36) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWProofs.lean#L113-L114)

## What coefficient fits just one state with nonzero heat?

`coefficient_at_single_state`

**Proof request**

Identify the coefficient that fits one state when its heat is nonzero.

**Reading the result**

Dividing the pairing by that heat fixes the coefficient uniquely.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem coefficient_at_single_state (s : State) (positive : 0<heat s) (k : ℝ) :
    pairing s=k*heat s ↔ k=pairing s/heat s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWChallenge.lean#L38-L39) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWProofs.lean#L116-L119)

## Can the initial state identify the coefficient?

`initial_state_does_not_identify_coefficient`

**Proof request**

Show that every coefficient fits the two zero readings in the initial state.

**Reading the result**

Both quantities vanish there, so every coefficient fits that single equality.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem initial_state_does_not_identify_coefficient (G : Geometry) :
    pairing (initial G)=0 ∧ heat (initial G)=0 ∧
    ∀ k : ℝ, pairing (initial G)=k*heat (initial G) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWChallenge.lean#L41-L43) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWProofs.lean#L121-L139)

## Does an accepted native rate determine a wizard coupling entry?

`same_accepted_rate_allows_any_wizard_entry`

**Proof request**

Construct a central-Hearth coupling matrix with any prescribed Courier–Weaver entry beside the same accepted rate.

**Reading the result**

For any chosen k the construction supplies a central-Hearth matrix with entries k and −k alongside the same accepted rate.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem same_accepted_rate_allows_any_wizard_entry (G : Geometry) (s d : State) (t k : ℝ)
    (accepted : rhs G t s=some d) :
    ∃ M : CommutatorMatrix, M.CentralHearth ∧
    M.κ Wizard.courier.toFin Wizard.weaver.toFin=k ∧
    M.κ Wizard.weaver.toFin Wizard.courier.toFin= -k ∧ rhs G t s=some d := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWChallenge.lean#L45-L49) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWProofs.lean#L141-L150)
