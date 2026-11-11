# What a single event jump does to continuity

Start with a decoded bit. A witnessed jump in its fabric coordinate rules out both continuity and a derivative there.

[`V3EventChallenge.lean`](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-proof-attempt/V3EventChallenge.lean) · [Package configuration](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-proof-attempt/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 NousVolition. All rights reserved. The repository notice applies to material for which NousVolition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-proof-attempt/V3EventProofs.lean) · [V3EventSpecification](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-proof-attempt/V3EventSpecification.lean) · [Source audit](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-proof-attempt/source-audit.json) · [Statement and proof inputs](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-proof-attempt/verification-inputs.json) · [Verification record](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-proof-attempt/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-proof-attempt/lake-manifest.json).

</details>

## What does the load-based probe recover?

`probe_recovers_rest_strain`

**Proof request**

Recover the stored rest strain with the specified probe.

**Reading the result**

With nonzero stiffness the load correction cancels and leaves the rest strain.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem probe_recovers_rest_strain (k load b : ℝ) (hk : k ≠ 0) :
    inferredRestStrain k load b = b := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-proof-attempt/V3EventChallenge.lean#L7-L8) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-proof-attempt/V3EventProofs.lean#L7-L11)

## What is the first bit of the fixed header?

`header_first_bit_is_one`

**Proof request**

Compute the least significant bit of the header magic.

**Reading the result**

Computing its remainder modulo two gives one.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem header_first_bit_is_one : headerMagic % 2 = 1 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-proof-attempt/V3EventChallenge.lean#L10) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-proof-attempt/V3EventProofs.lean#L13-L14)

## Will writing a true bit change a valid empty coordinate?

`valid_empty_coordinate_changes`

**Proof request**

Show that writing true changes the valid empty coordinate.

**Reading the result**

Its new signed level differs from the admitted empty value.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem valid_empty_coordinate_changes (a margin b : ℝ)
    (h : ValidEmptyCoordinate a margin b) : writtenBit a true ≠ b := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-proof-attempt/V3EventChallenge.lean#L12-L13) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-proof-attempt/V3EventProofs.lean#L16-L21)

## Can a witnessed event jump be continuous at its event time?

`event_prevents_continuity`

**Proof request**

Use the event witness to disprove continuity at the event time.

**Reading the result**

The specified pre-event behavior and different event value contradict continuity.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem event_prevents_continuity (f : ℝ → ℝ) (eventTime before a : ℝ)
    (h : EventWitness f eventTime before a) : ¬ ContinuousAt f eventTime := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-proof-attempt/V3EventChallenge.lean#L15-L16) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-proof-attempt/V3EventProofs.lean#L23-L31)

## Can the coordinate have a derivative at that jump?

`event_prevents_derivative`

**Proof request**

Use the witnessed discontinuity to exclude a derivative at that time.

**Reading the result**

A derivative would imply continuity, which the event witness excludes.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem event_prevents_derivative (f : ℝ → ℝ) (eventTime before a rate : ℝ)
    (h : EventWitness f eventTime before a) : ¬ HasDerivAt f rate eventTime := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-proof-attempt/V3EventChallenge.lean#L18-L19) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-proof-attempt/V3EventProofs.lean#L33-L36)

## Does one jumping coordinate spoil continuity of the full path?

`full_state_prevents_continuity`

**Proof request**

Use a jumping continuous coordinate projection to disprove full-path continuity.

**Reading the result**

A continuous projection of a continuous path would be continuous there, contradicting the witnessed coordinate jump.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_state_prevents_continuity {E : Type*} [TopologicalSpace E]
    (read : E → ℝ) (hread : Continuous read) (path : ℝ → E)
    (eventTime before a : ℝ) (h : EventWitness (read ∘ path) eventTime before a) :
    ¬ ContinuousAt path eventTime := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-proof-attempt/V3EventChallenge.lean#L21-L24) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-proof-attempt/V3EventProofs.lean#L38-L44)
