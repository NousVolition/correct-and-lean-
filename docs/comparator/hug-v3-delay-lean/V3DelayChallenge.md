# Which parts of a delayed state come from the past?

Build a state with present physical fields and past social fields. Identify the decoder result and the two rate blocks it supplies.

[`V3DelayChallenge.lean`](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-delay-lean/V3DelayChallenge.lean) · [Package configuration](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-delay-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 NousVolition. All rights reserved. The repository notice applies to material for which NousVolition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-delay-lean/V3DelayProofs.lean) · [V3DelayDefinitions](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-delay-lean/V3DelayDefinitions.lean) · [Statement and proof inputs](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-delay-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-delay-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-delay-lean/lake-manifest.json).

</details>

## What happens when present and buffered states are identical?

`socialFrom_self`

**Proof request**

Reconstruct a state by using it as both present and past.

**Reading the result**

Taking the physical and social pieces from the same state reconstructs it.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem socialFrom_self (s : State) : socialFrom s s=s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-delay-lean/V3DelayChallenge.lean#L7) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-delay-lean/V3DelayProofs.lean#L7-L9)

## Which physical fields enter a buffered state?

`present_physical_blocks`

**Proof request**

Identify the combined state’s physical blocks with the present blocks.

**Reading the result**

The combined state takes them from the present.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem present_physical_blocks (present past : State) : SamePhysical (socialFrom present past) present := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-delay-lean/V3DelayChallenge.lean#L9) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-delay-lean/V3DelayProofs.lean#L11-L12)

## Where do its social fields come from?

`buffered_social_blocks`

**Proof request**

Identify the combined state’s social blocks with the past blocks.

**Reading the result**

The combined state copies the past social block.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem buffered_social_blocks (present past : State) : SameSocial (socialFrom present past) past := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-delay-lean/V3DelayChallenge.lean#L11) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-delay-lean/V3DelayProofs.lean#L14-L15)

## Which memory records does the combined state decode?

`material_records_remain_present`

**Proof request**

Prove that the combined state reads the present material records.

**Reading the result**

Its material storage comes from the present, giving the present decoder result.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem material_records_remain_present (present past : State) : readRecords (socialFrom present past)=readRecords present := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-delay-lean/V3DelayChallenge.lean#L13) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-delay-lean/V3DelayProofs.lean#L17-L18)

## Does zero delay recover the original rate?

`zero_delay_recovers_original`

**Proof request**

Recover the original optional rate when present and past coincide.

**Reading the result**

With identical present and buffered inputs the two required calls coincide, including their success or failure.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem zero_delay_recovers_original (G : Geometry) (t : ℝ) (s : State) : rhsDelayed G t s s=rhs G t s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-delay-lean/V3DelayChallenge.lean#L15) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-delay-lean/V3DelayProofs.lean#L20-L22)

## Which physical rates survive a successful delayed calculation?

`delay_preserves_current_physical_rate`

**Proof request**

Construct the delayed rate and identify its present physical component given the successful evaluations.

**Reading the result**

Given the required successful calls, the combined rate uses the present physical block.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem delay_preserves_current_physical_rate (G : Geometry) (t : ℝ) (present past d e : State)
    (hd : rhs G t present=some d) (he : rhs G t (socialFrom present past)=some e) :
    ∃ rate, rhsDelayed G t present past=some rate ∧ SamePhysical rate d := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-delay-lean/V3DelayChallenge.lean#L17-L19) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-delay-lean/V3DelayProofs.lean#L24-L28)

## Which social rates survive that same combination?

`delay_uses_buffered_social_rate`

**Proof request**

Construct the delayed rate and identify its buffered social component given the successful evaluations.

**Reading the result**

Under the specified successes it uses the rates calculated with the buffered social input.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem delay_uses_buffered_social_rate (G : Geometry) (t : ℝ) (present past d e : State)
    (hd : rhs G t present=some d) (he : rhs G t (socialFrom present past)=some e) :
    ∃ rate, rhsDelayed G t present past=some rate ∧ SameSocial rate e := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-delay-lean/V3DelayChallenge.lean#L21-L23) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-delay-lean/V3DelayProofs.lean#L30-L34)

## How far back does positive delay look?

`buffer_reads_strictly_past`

**Proof request**

Show that a positive delay samples a strictly earlier time.

**Reading the result**

Subtracting a strictly positive delay makes the lookup time strictly earlier than the current time.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem buffer_reads_strictly_past {τ t : ℝ} (hτ : 0<τ) : t-τ<t := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-delay-lean/V3DelayChallenge.lean#L25) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-delay-lean/V3DelayProofs.lean#L36-L37)

## How does the history-based calculation behave at zero delay?

`history_zero_delay`

**Proof request**

Recover the original history-based rate at zero delay.

**Reading the result**

Both lookups select the same history value and the rate reduces to the original one.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem history_zero_delay (G : Geometry) (history : ℝ → State) (t : ℝ) : rhsAlong G 0 history t=rhs G t (history t) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-delay-lean/V3DelayChallenge.lean#L27) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-delay-lean/V3DelayProofs.lean#L39-L40)
