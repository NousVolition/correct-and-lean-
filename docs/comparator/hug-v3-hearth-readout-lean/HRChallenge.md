# What heat and work read from an ordered perturbation

Differentiate heat and kinetic energy in the specified direction. Reversing an order can reverse a signed measurement while the underlying heat remains positive or zero.

[`HRChallenge.lean`](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/HRChallenge.lean) · [Package configuration](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 Nous Volition. All rights reserved. The repository notice applies to material for which Nous Volition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project creator supplied the Seven-Wizard/Hearth details and recalls that Codex may have drafted the submitted Lean file. The surviving file has no writer byline. Credit for the submission is recorded under its filename, Submitted.lean. [Original Submitted.lean](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/original/Submitted.lean) · [Seven-wizard algebra](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/SevenWizardAlgebra.lean) · [Hearth audit proofs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthProofs.lean).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/HRAll.lean) · [HRDefinitions](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/HRDefinitions.lean) · [Statement and proof inputs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/lake-manifest.json).

</details>

## What quadratic form gives the native heat?

`native_heat_form`

**Proof request**

Express native heat as the thermal form applied twice to the supplied velocity.

**Reading the result**

Putting velocity v into the state gives the thermal form evaluated twice on v.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem native_heat_form (s : State) (v : Vector) :
    heat (atVelocity s v)=thermalForm s v v := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/HRChallenge.lean#L8-L9) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/HRQuadratic.lean#L14-L20)

## What do the two accepted ledger rates actually record?

`accepted_work_and_heat_ledgers`

**Proof request**

Identify the force-work and heat ledger components of a successful rate.

**Reading the result**

One is velocity paired with forcing. The other is heat adjusted by grid-averaged extraction and release.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem accepted_work_and_heat_ledgers (G : Geometry) (s d : State) (t : ℝ) (h : rhs G t s=some d) :
    d.ledger 1=CW.inner (velocity s) (forcing s) ∧
    d.ledger 3=heat s-(∑ x, extraction G s x)/4096+(∑ x, releaseGrid G s x)/4096 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/HRChallenge.lean#L11-L13) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/HRProofs.lean#L10-L21)

## How does heat change in the ordered direction?

`ordered_heat_derivative`

**Proof request**

Differentiate heat in the ordered velocity direction.

**Reading the result**

Differentiating heat along the indicated velocity perturbation gives the signed heat reading.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem ordered_heat_derivative (s : State) :
    HasDerivAt (fun e : ℝ => heat (atVelocity s (mix 1 e (velocity s) (ordered s)))) (heatReading s) 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/HRChallenge.lean#L15-L16) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/HRProofs.lean#L23-L26)

## How does kinetic energy change along that same direction?

`ordered_kinetic_derivative`

**Proof request**

Differentiate kinetic energy in the same ordered direction.

**Reading the result**

Differentiating its quadratic expression gives the work reading.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem ordered_kinetic_derivative (s : State) :
    HasDerivAt (fun e : ℝ => kinetic (mix 1 e (velocity s) (ordered s))) (workReading s) 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/HRChallenge.lean#L18-L19) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/HRProofs.lean#L28-L38)

## What does reversing the order change?

`changing_order`

**Proof request**

Determine the signs of both first-order readings and the value of bracket heat when order reverses.

**Reading the result**

Both signed first-order readings reverse, while heat of the bracket direction retains its value.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem changing_order (s : State) :
    2*thermalForm s (velocity s) (-ordered s)= -heatReading s ∧
    CW.inner (velocity s) (-ordered s)= -workReading s ∧
    heat (atVelocity s (-ordered s))=bracketHeat s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/HRChallenge.lean#L21-L24) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/HRProofs.lean#L43-L49)

## How large can the signed heat reading become?

`signed_heat_bound`

**Proof request**

Bound the squared signed heat response by four times the two heat values.

**Reading the result**

Its square is bounded by four times base heat times bracket heat.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem signed_heat_bound (s : State) : (heatReading s)^2≤4*heat s*bracketHeat s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/HRChallenge.lean#L26) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/HRProofs.lean#L81-L84)

## Can there be a signed heat response when base heat is zero?

`zero_heat_has_zero_signed_response`

**Proof request**

Deduce zero signed heat response at zero heat.

**Reading the result**

The squared bound forces the reading to vanish.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem zero_heat_has_zero_signed_response (s : State) (h : heat s=0) : heatReading s=0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/HRChallenge.lean#L28) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/HRProofs.lean#L86-L89)

## When is work a heat response along Courier?

`work_is_heat_response_along_courier`

**Proof request**

Under the retention hypotheses, identify the work reading with twice the thermal form along Courier.

**Reading the result**

Under the three retention assumptions the work reading equals twice the thermal form on velocity and the Courier direction.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem work_is_heat_response_along_courier (s : State) (hu : retained (velocity s))
    (hc : retained (courier (velocity s))) (hw : retained (weaver s (velocity s))) :
    workReading s=2*thermalForm s (velocity s) (courier (velocity s)) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/HRChallenge.lean#L30-L32) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/HRProofs.lean#L123-L137)

## What does velocity reversal do to the ordered experiment?

`velocity_reversal`

**Proof request**

Find the parity of the ordered direction, signed responses and heat under velocity reversal.

**Reading the result**

The ordered direction and heat stay fixed, while both signed readings reverse.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem velocity_reversal (s : State) :
    ordered (reversed s)=ordered s ∧ heatReading (reversed s)= -heatReading s ∧
    workReading (reversed s)= -workReading s ∧ heat (reversed s)=heat s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/HRChallenge.lean#L34-L36) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/HRProofs.lean#L152-L160)

## Can one heat multiplier explain two opposite nonzero readings?

`nonzero_signed_reading_excludes_shared_multiplier`

**Proof request**

Rule out one constant heat multiplier for the two nonzero opposite readings.

**Reading the result**

Reversal preserves the heat but reverses the reading, ruling out that common multiplier.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem nonzero_signed_reading_excludes_shared_multiplier (s : State) (h : heatReading s≠0) :
    ¬ ∃ k : ℝ, heatReading s=k*heat s ∧ heatReading (reversed s)=k*heat (reversed s) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/HRChallenge.lean#L38-L39) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/HRProofs.lean#L162-L167)

## How do you test for one multiplier over an encounter?

`encounter_multiplier_criterion`

**Proof request**

Characterize a shared multiplier by cross products at an anchor with nonzero heat.

**Reading the result**

Pick an anchor with nonzero heat. Cross multiplication against that anchor must hold at every time and is sufficient.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem encounter_multiplier_criterion {T : Type} (H L : T → ℝ) (a : T) (ha : H a≠0) :
    (∃ k : ℝ, ∀ t, L t=k*H t) ↔ ∀ t, L t*H a=L a*H t := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/HRChallenge.lean#L41-L42) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hearth-readout-lean/HRProofs.lean#L169-L177)
