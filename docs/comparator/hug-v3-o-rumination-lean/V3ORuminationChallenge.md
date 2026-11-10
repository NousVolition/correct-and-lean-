# When association fades and what can still move

Track association drive, signed retrieval channels and the accumulator separately. Zero drive can leave a decaying association and other changing coordinates.

[`V3ORuminationChallenge.lean`](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationChallenge.lean) · [Package configuration](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 Nous Volition. All rights reserved. The repository notice applies to material for which Nous Volition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationProofs.lean) · [V3ORuminationDefinitions](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationDefinitions.lean) · [Statement and proof inputs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/lake-manifest.json).

</details>

## What sets the association rate in an accepted full calculation?

`full_rhs_association_equation`

**Proof request**

Extract the association-drive relaxation equation from an accepted rate.

**Reading the result**

It is 3/2 times the difference between the association drive and the current association.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_rhs_association_equation (G : Geometry) (t : ℝ) (s rate : State)
    (rs : List (Fin 4 × Record)) (hr : readRecords s=some rs)
    (hd : rhs G t s=some rate) (i j : Actor) (k : Fin 3) :
    rate.association i j k=(3/2:ℝ)*(associationDrive G s rs i j k-s.association i j k) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationChallenge.lean#L7-L10) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationProofs.lean#L21-L30)

## What drives the source accumulator?

`full_rhs_source_equation`

**Proof request**

Extract the pulse and internal-drive equation for the source accumulator.

**Reading the result**

Add the pulse and the internal drive, then multiply the sum by 2/25 to get the accepted accumulator rate.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_rhs_source_equation (G : Geometry) (t : ℝ) (s rate : State)
    (rs : List (Fin 4 × Record)) (hr : readRecords s=some rs)
    (hd : rhs G t s=some rate) :
    rate.A=(2/25:ℝ)*(pulse t+internalSourceDrive G s rs) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationChallenge.lean#L12-L15) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationProofs.lean#L32-L41)

## Can an association restart after reaching zero?

`association_restarts_from_zero`

**Proof request**

Deduce strictly positive association rate at zero from the stipulated positive drive.

**Reading the result**

Under a positive drive and successful rate calculation its derivative at zero is positive.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem association_restarts_from_zero (G : Geometry) (t : ℝ) (s rate : State)
    (rs : List (Fin 4 × Record)) (hr : readRecords s=some rs)
    (hd : rhs G t s=some rate) (i j : Actor) (k : Fin 3)
    (ha : s.association i j k=0) (hdrive : 0<associationDrive G s rs i j k) :
    0<rate.association i j k := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationChallenge.lean#L17-L21) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationProofs.lean#L43-L49)

## Can positive and negative memory channels balance without disappearing?

`balanced_channels_positive_equal`

**Proof request**

Prove equal positive retrieval in the two signed channels for the balanced record pair.

**Reading the result**

The paired records give equal channels with a strictly positive value.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem balanced_channels_positive_equal (G : Geometry) (s : State) (r : Record)
    (ht : r.startTime<r.endTime) :
    0<memory G s (balancedRecords r) r.recipient r.origin 0 ∧
    memory G s (balancedRecords r) r.recipient r.origin 0=
      memory G s (balancedRecords r) r.recipient r.origin 1 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationChallenge.lean#L23-L27) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationProofs.lean#L62-L70)

## What does that balance do to the association drive?

`balanced_channels_zero_association_drive`

**Proof request**

Show that the balanced pair gives zero association drive.

**Reading the result**

The drive uses their difference, which is zero.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem balanced_channels_zero_association_drive (G : Geometry) (s : State)
    (r : Record) (k : Fin 3) (ht : r.startTime<r.endTime) :
    associationDrive G s (balancedRecords r) r.recipient r.origin k=0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationChallenge.lean#L29-L31) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationProofs.lean#L72-L76)

## How does association evolve on a segment with zero drive?

`full_trace_association_relaxation`

**Proof request**

Solve the zero-drive association equation along the stipulated trace segment.

**Reading the result**

The resulting decay equation gives its starting value times exp(−3Δt/2).

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_trace_association_relaxation (tr : Trace) (hsol : Solves tr)
    (q : ℕ) (hq : q<5) (i j : Actor) (k : Fin 3)
    (hoff : ∀ t ∈ Icc (time q) (time (q+1)), ∀ rs,
      readRecords (tr.path q t).state=some rs →
      associationDrive sourceGeometry (tr.path q t).state rs i j k=0) :
    ∀ t ∈ Icc (time q) (time (q+1)),
      (tr.path q t).state.association i j k=
      (tr.after q).state.association i j k*Real.exp (-(3/2:ℝ)*(t-time q)) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationChallenge.lean#L33-L40) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationProofs.lean#L127-L155)

## Can that finite-time decay erase a nonzero starting association exactly?

`finite_relaxation_retains_nonzero_association`

**Proof request**

Prove persistence of a nonzero association through finite relaxation.

**Reading the result**

The exponential stays positive, so the value stays nonzero.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem finite_relaxation_retains_nonzero_association (tr : Trace) (hsol : Solves tr)
    (q : ℕ) (hq : q<5) (i j : Actor) (k : Fin 3)
    (hoff : ∀ t ∈ Icc (time q) (time (q+1)), ∀ rs,
      readRecords (tr.path q t).state=some rs →
      associationDrive sourceGeometry (tr.path q t).state rs i j k=0)
    (hn : (tr.after q).state.association i j k≠0) :
    ∀ t ∈ Icc (time q) (time (q+1)),
      (tr.path q t).state.association i j k≠0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationChallenge.lean#L42-L49) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationProofs.lean#L157-L167)

## Can stored records persist while the association relaxes?

`full_trace_relaxation_with_retained_records`

**Proof request**

Establish the constant decoded list together with the exact association decay under the stated premises.

**Reading the result**

The stated read conditions keep the list fixed as the zero-drive equation gives exponential decay.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_trace_relaxation_with_retained_records (tr : Trace) (hsol : Solves tr)
    (q : ℕ) (hq : q<5) (i j : Actor) (k : Fin 3)
    (hoff : ∀ t ∈ Icc (time q) (time (q+1)), ∀ rs,
      readRecords (tr.path q t).state=some rs →
      associationDrive sourceGeometry (tr.path q t).state rs i j k=0) :
    ∀ t ∈ Icc (time q) (time (q+1)),
      readRecords (tr.path q t).state=readRecords (tr.after q).state ∧
      (tr.path q t).state.association i j k=
      (tr.after q).state.association i j k*Real.exp (-(3/2:ℝ)*(t-time q)) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationChallenge.lean#L51-L59) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationProofs.lean#L169-L180)

## Does zero total source erase what was accumulated?

`full_trace_zero_total_source_retains_accumulator`

**Proof request**

Show constancy of the source accumulator on a segment with zero total drive.

**Reading the result**

A zero derivative keeps A at its segment-entry value.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_trace_zero_total_source_retains_accumulator (tr : Trace) (hsol : Solves tr)
    (q : ℕ) (hq : q<5)
    (hoff : ∀ t ∈ Icc (time q) (time (q+1)), ∀ rs,
      readRecords (tr.path q t).state=some rs →
      pulse t+internalSourceDrive sourceGeometry (tr.path q t).state rs=0) :
    ∀ t ∈ Icc (time q) (time (q+1)), (tr.path q t).state.A=(tr.after q).state.A := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationChallenge.lean#L61-L66) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationProofs.lean#L182-L203)

## Does zero association freeze all aspects of the student model?

`zero_association_does_not_freeze_student`

**Proof request**

Evaluate the initial example’s drive, association and norm-center rate.

**Reading the result**

The specified initial state has zero drive and association while its first norm-center rate is −49/400.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem zero_association_does_not_freeze_student (G : Geometry) (t : ℝ) :
    associationDrive G (initial G) [] 1 0 0=0 ∧
    (initial G).association 1 0 0=0 ∧
    (rhsFromRecords G t (initial G) []).normCenter 1 0=-(49/400:ℝ) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationChallenge.lean#L68-L71) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationProofs.lean#L205-L215)

## Which association enters a successful delayed rate?

`delayed_association_reads_buffered_value`

**Proof request**

Extract the buffered drive and past association from the delayed rate.

**Reading the result**

The drive uses the mixed state and the subtracted association is the past value.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem delayed_association_reads_buffered_value (G : Geometry) (t : ℝ)
    (present past rate : State) (rs : List (Fin 4 × Record))
    (hr : readRecords present=some rs)
    (hd : Delay.rhsDelayed G t present past=some rate) (i j : Actor) (k : Fin 3) :
    rate.association i j k=(3/2:ℝ)*
      (associationDrive G (Delay.socialFrom present past) rs i j k-past.association i j k) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationChallenge.lean#L73-L78) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationProofs.lean#L217-L227)

## Can a delayed rate move at a currently zero association?

`delayed_rate_can_move_at_present_zero`

**Proof request**

Prove that the stipulated delayed association rate is nonzero.

**Reading the result**

The given past value and buffered drive still differ, making the rate nonzero.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem delayed_rate_can_move_at_present_zero (G : Geometry) (t : ℝ)
    (present past rate : State) (rs : List (Fin 4 × Record))
    (hr : readRecords present=some rs)
    (hd : Delay.rhsDelayed G t present past=some rate) (i j : Actor) (k : Fin 3)
    (hnow : present.association i j k=0) (hpast : past.association i j k≠0)
    (hoff : associationDrive G (Delay.socialFrom present past) rs i j k=0) :
    rate.association i j k≠0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationChallenge.lean#L80-L86) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-o-rumination-lean/V3ORuminationProofs.lean#L229-L237)
