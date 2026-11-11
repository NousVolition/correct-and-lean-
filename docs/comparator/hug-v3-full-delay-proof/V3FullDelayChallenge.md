# Solving one delay step in full coordinates

Encode a state, solve a segment with the specified bounds, and check that recovering its coordinates gives the original delayed equation.

[`V3FullDelayChallenge.lean`](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayChallenge.lean) · [Package configuration](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 NousVolition. All rights reserved. The repository notice applies to material for which NousVolition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayProofs.lean) · [V3FullCoordinates](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullCoordinates.lean) · [Saved source digests](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/preserved-inputs.json) · [Statement and proof inputs](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/verification-inputs.json) · [Verification record](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/lake-manifest.json).

</details>

## Can a full state be encoded and decoded without losing it?

`full_state_round_trip`

**Proof request**

Prove the state round-trip identity for the full encoding.

**Reading the result**

The two maps are inverse on states.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_state_round_trip (s : State) : decode (encode s) = s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayChallenge.lean#L10) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayProofs.lean#L10)

## Does the same round trip work starting with a vector?

`full_vector_round_trip`

**Proof request**

Prove the vector round-trip identity for the full decoding.

**Reading the result**

Encoding the decoded vector recovers every coordinate.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_vector_round_trip (z : FullVector) : encode (decode z) = z := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayChallenge.lean#L12) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayProofs.lean#L12)

## When do matching encodings identify two full states?

`full_state_equality`

**Proof request**

Deduce state equality from equality of the encodings.

**Reading the result**

Applying the decoder to the equal vectors gives equal original states.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_state_equality (a b : State) (h : encode a = encode b) : a = b := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayChallenge.lean#L14) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayProofs.lean#L14-L15)

## What guarantees a unique delay segment inside the specified ball?

`full_segment_exists_unique`

**Proof request**

Construct a segment in the given ball and prove uniqueness among competing segments in that ball.

**Reading the result**

The local differential-equation bounds and compatibility give existence and agreement for other segments staying in that ball.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_segment_exists_unique
    (G : Geometry) (records : List (Fin 4 × Record)) (history : ℝ → State)
    (τ a b : ℝ) (hab : a ≤ b) (start : State) (radius L K : ℝ≥0)
    (hp : IsPicardLindelof (frozenRate G records history τ)
      ⟨a, le_rfl, hab⟩ (encode start) radius 0 L K)
    (hc : Compatible G records history τ a b (encode start) radius) :
    ∃ z : ℝ → FullVector,
      Segment G history τ a b start z ∧
      (∀ t ∈ Icc a b, z t ∈ closedBall (encode start) radius) ∧
      ∀ w : ℝ → FullVector, Segment G history τ a b start w →
        (∀ t ∈ Icc a b, w t ∈ closedBall (encode start) radius) →
        EqOn z w (Icc a b) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayChallenge.lean#L16-L27) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayProofs.lean#L36-L71)

## Does extending a history rewrite its earlier values?

`history_preserved`

**Proof request**

Show that the extended history agrees with the supplied past through the starting time.

**Reading the result**

At and before the splice time the extension returns the original history.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem history_preserved (a : ℝ) (past : ℝ → State) (z : ℝ → FullVector)
    (t : ℝ) (ht : t ≤ a) : extendHistory a past z t = past t := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayChallenge.lean#L29-L30) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayProofs.lean#L73-L75)

## Where is the delayed input taken from on the first short step?

`first_step_is_actual_delayed_rhs`

**Proof request**

Identify the actual delayed right-hand side on the compatible first short step.

**Reading the result**

Under the endpoint matches and step-length bound, the lookup is in the supplied history and the present value is decoded from the new path.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem first_step_is_actual_delayed_rhs
    (G : Geometry) (history : ℝ → State) (τ a b : ℝ) (start : State)
    (z : ℝ → FullVector) (hτ : 0 < τ) (hstep : b ≤ a+τ)
    (hpast : history a = start) (hz : z a = encode start)
    (t : ℝ) (ht : t ∈ Icc a b) :
    Delay.rhsAlong G τ (extendHistory a history z) t =
      Delay.rhsDelayed G t (decode (z t)) (history (t-τ)) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayChallenge.lean#L32-L38) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayProofs.lean#L77-L91)

## Does a constructed short segment solve the actual delayed equation?

`full_segment_is_delay_solution_on_step`

**Proof request**

Prove that the new segment has the accepted delayed derivative throughout that step.

**Reading the result**

Combining the segment derivative with the first-step history identity gives an accepted rate at every time in the interval.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_segment_is_delay_solution_on_step
    (G : Geometry) (history : ℝ → State) (τ a b : ℝ) (start : State)
    (z : ℝ → FullVector) (hτ : 0 < τ) (hstep : b ≤ a+τ)
    (hpast : history a = start) (hz : Segment G history τ a b start z) :
    ∀ t ∈ Icc a b, ∃ d : State,
      Delay.rhsAlong G τ (extendHistory a history z) t = some d ∧
      HasDerivWithinAt z (encode d) (Icc a b) t := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayChallenge.lean#L40-L46) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayProofs.lean#L93-L102)

## Does an accepted write change the stored social block right away?

`accepted_write_keeps_social`

**Proof request**

Prove equality of the social fields across an accepted write.

**Reading the result**

Its fields are copied from the pre-write state.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem accepted_write_keeps_social (G : Geometry) (s w : State) (r : Record)
    (hw : writeEvent G s r = some w) : Delay.SameSocial w s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayChallenge.lean#L48-L49) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayProofs.lean#L105-L119)

## What about an entire completed event?

`completed_event_keeps_social`

**Proof request**

Prove equality of the social fields across successful event completion.

**Reading the result**

The write and capture bookkeeping preserve the same social coordinates.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem completed_event_keeps_social (id : Fin 3) (s w : FullState)
    (hw : completeEvent id s = some w) : Delay.SameSocial w.state s.state := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayChallenge.lean#L51-L52) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayProofs.lean#L121-L129)

## Is the same true at each accepted scheduled boundary?

`accepted_boundary_keeps_social`

**Proof request**

Prove equality of the social fields across an accepted boundary.

**Reading the result**

Examining the boundary branches gives agreement of the social blocks.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem accepted_boundary_keeps_social (k : ℕ) (s w : FullState)
    (hw : Delay.eventBoundary k s = some w) :
    Delay.SameSocial w.state s.state := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayChallenge.lean#L54-L56) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayProofs.lean#L131-L151)

## Can the same boundary call return two different successful values?

`boundary_deterministic`

**Proof request**

Prove that two successful outputs of the same boundary call agree.

**Reading the result**

Equality to the same optional result forces the outputs to be equal.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem boundary_deterministic (k : ℕ) (s a b : FullState)
    (ha : Delay.eventBoundary k s = some a) (hb : Delay.eventBoundary k s = some b) :
    a = b := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayChallenge.lean#L58-L60) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayProofs.lean#L153-L155)

## Could a past write be detected by reading only its buffered social fields?

`buffered_social_unchanged_by_write`

**Proof request**

Show that an accepted past write gives the same buffered social input.

**Reading the result**

Those fields survived the write, so combining them with the same present state gives the same combination.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem buffered_social_unchanged_by_write (G : Geometry) (present s w : State)
    (r : Record) (hw : writeEvent G s r = some w) :
    Delay.socialFrom present w = Delay.socialFrom present s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayChallenge.lean#L62-L64) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayProofs.lean#L157-L161)

## What does assuming a full delayed solution imply about its scheduled writes?

`full_delayed_trace_has_accepted_writes`

**Proof request**

Deduce successful scheduled boundaries from the full delayed trace assumptions.

**Reading the result**

Its boundary equations already supply successful results at the indicated checkpoints.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_delayed_trace_has_accepted_writes (τ : ℝ) (past : ℝ → State)
    (tr : Trace) (ht : DelayedSolves τ past tr) (k : ℕ) (hk : k < 5) :
    Delay.eventBoundary (k+1) (tr.path k (time (k+1))) ≠ none := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayChallenge.lean#L66-L68) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayProofs.lean#L163-L167)

## Does the packed delay segment solve the original state coordinates?

`full_segment_satisfies_original_coordinates`

**Proof request**

Recover the accepted delayed rate and the original-coordinate derivatives along the segment.

**Reading the result**

Decoding its derivative gives the accepted delayed rate and the required within-interval derivative in every coordinate.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_segment_satisfies_original_coordinates
    (G : Geometry) (history : ℝ → State) (τ a b : ℝ) (start : State)
    (z : ℝ → FullVector) (hz : Segment G history τ a b start z) :
    ∀ t ∈ Icc a b, ∃ d : State,
      Delay.rhsDelayed G t (decode (z t)) (history (t-τ)) = some d ∧
      StateHasDerivWithinAt (fun s => decode (z s)) d (Icc a b) t := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayChallenge.lean#L70-L75) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/V3FullDelayProofs.lean#L169-L177)
