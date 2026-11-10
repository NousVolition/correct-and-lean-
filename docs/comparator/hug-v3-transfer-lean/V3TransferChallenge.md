# How one partner’s influence can reach another guard

Track a positive record into cooperation and norm drift. The sign and size of the alignment determine the instantaneous effect at a second partner’s guard.

[`V3TransferChallenge.lean`](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferChallenge.lean) · [Package configuration](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 Nous Volition. All rights reserved. The repository notice applies to material for which Nous Volition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferProofs.lean) · [V3TransferDefinitions](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferDefinitions.lean) · [Source audit](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/source-audit.json) · [Source map](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/source-map.json) · [Statement and proof inputs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/lake-manifest.json).

</details>

## Can a memory assigned to one pair directly contribute to another pair?

`memory_stays_with_original_pair`

**Proof request**

Prove that a mismatched record does not contribute to the selected partner channel.

**Reading the result**

The recipient and origin filter skips the mismatched entry in that retrieval channel.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem memory_stays_with_original_pair (G : Geometry) (s : State)
    (rs : List (Fin 4 × Record)) (slot : Fin 4) (r : Record) (i j : Actor)
    (hne : r.origin≠j) (k : Fin 4) :
    memory G s ((slot,r)::rs) i j k = memory G s rs i j k := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferChallenge.lean#L9-L12) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferProofs.lean#L8-L12)

## Does a positively scored event register as evidence?

`positive_record_has_positive_evidence`

**Proof request**

Derive positive retrieval from the given positively scored record.

**Reading the result**

With the stated positive duration its weight is positive, giving positive retrieval in the specified channel.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem positive_record_has_positive_evidence (G : Geometry) (s : State)
    (slot : Fin 4) (r : Record) (y : ℝ) (hy : 0<y)
    (hscore : score r=some y) (htime : r.startTime<r.endTime) :
    0<memory G s [(slot,r)] r.recipient r.origin 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferChallenge.lean#L14-L17) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferProofs.lean#L19-L25)

## Can one such record move the pair’s cooperation rate?

`positive_record_increases_cooperation_rate`

**Proof request**

Prove the stated strict increase in the recipient’s cooperation rate.

**Reading the result**

Under the stated hypotheses the original response equation gives a higher rate with the record than with an empty list.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem positive_record_increases_cooperation_rate (G : Geometry) (t : ℝ) (s : State)
    (slot : Fin 4) (r : Record) (y : ℝ) (hy : 0<y)
    (hscore : score r=some y) (htime : r.startTime<r.endTime)
    (ha : 0<attention s r.recipient r.origin) :
    (rhsFromRecords G t s []).responses r.recipient r.origin 1 <
      (rhsFromRecords G t s [(slot,r)]).responses r.recipient r.origin 1 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferChallenge.lean#L19-L24) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferProofs.lean#L51-L67)

## How can cooperation with the first partner shift the student’s norm-center rate?

`cooperation_changes_shared_norm_rate`

**Proof request**

Compute the exact norm-rate difference for the cooperation perturbation.

**Reading the result**

The exact difference is delta times the first partner’s expression gap from the student’s norm center, divided by five.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem cooperation_changes_shared_norm_rate (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (student first : Actor) (δ : ℝ) (k : Fin 2) :
    (rhsFromRecords G t (bumpCooperation s student first δ) rs).normCenter student k-
      (rhsFromRecords G t s rs).normCenter student k =
      δ*(s.expression first k-s.normCenter student k)/5 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferChallenge.lean#L26-L30) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferProofs.lean#L75-L101)

## Does that change move the second person’s expression rate immediately?

`other_person_expression_rate_unchanged`

**Proof request**

Show equality of the distinct person’s expression rate.

**Reading the result**

For the distinct person in this comparison the rate is equal.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem other_person_expression_rate_unchanged (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (student first second : Actor) (δ : ℝ)
    (hne : second≠student) :
    (rhsFromRecords G t (bumpCooperation s student first δ) rs).expression second =
      (rhsFromRecords G t s rs).expression second := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferChallenge.lean#L32-L36) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferProofs.lean#L103-L110)

## Does it immediately change the log-radius rates?

`radius_rate_unchanged_at_comparison`

**Proof request**

Show that the immediate log-radius rate field is invariant in the comparison.

**Reading the result**

Evaluating both state variants with the same records gives equal whole log-radius rate fields.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem radius_rate_unchanged_at_comparison (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (student first : Actor) (δ : ℝ) :
    (rhsFromRecords G t (bumpCooperation s student first δ) rs).logRadius =
      (rhsFromRecords G t s rs).logRadius := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferChallenge.lean#L38-L41) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferProofs.lean#L112-L123)

## Can the squared guard test be used for the usual positive margin?

`squared_guard_has_same_positive_side`

**Proof request**

Prove equivalence between positive squared guard and positive native margin.

**Reading the result**

Their positive regions coincide under the stated definition.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem squared_guard_has_same_positive_side (s : State) (i j : Actor) :
    0<guardSquared s i j ↔ 0<margin s i j := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferChallenge.lean#L43-L44) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferProofs.lean#L125-L137)

## How does the squared guard change along a differentiable full-state path?

`squared_guard_derivative_on_full_state`

**Proof request**

Differentiate the squared guard along the full state path on the time set.

**Reading the result**

Differentiating its expression using the given state derivative gives the defined squared-guard rate.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem squared_guard_derivative_on_full_state (s : ℝ → State) (d : State)
    (I : Set ℝ) (t : ℝ) (hd : StateHasDerivWithinAt s d I t) (i j : Actor) :
    HasDerivWithinAt (fun τ => guardSquared (s τ) i j)
      (guardSquaredRate (s t) d i j) I t := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferChallenge.lean#L46-L49) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferProofs.lean#L139-L148)

## How can a change with one partner reach another partner’s guard rate?

`transfer_to_distinct_partner_guard_rate`

**Proof request**

Derive the alignment formula for the change of guard rate toward the second partner.

**Reading the result**

The difference is 2δ/5 times the alignment between the specified directions.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem transfer_to_distinct_partner_guard_rate (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (student first second : Actor) (δ : ℝ)
    (hsecond : second≠student) (hpartners : first≠second) :
    guardSquaredRate (bumpCooperation s student first δ)
        (rhsFromRecords G t (bumpCooperation s student first δ) rs) student second-
      guardSquaredRate s (rhsFromRecords G t s rs) student second =
      (2*δ/5)*alignment s student first second := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferChallenge.lean#L51-L57) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferProofs.lean#L150-L169)

## Does that calculation still hold for rates accepted by the full model?

`domain_checked_transfer`

**Proof request**

Prove that the alignment formula holds for the two accepted full rates.

**Reading the result**

The two successful evaluations produce the same alignment formula for their rate difference.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem domain_checked_transfer (G : Geometry) (t : ℝ) (s d e : State)
    (student first second : Actor) (δ : ℝ) (hsecond : second≠student)
    (hpartners : first≠second) (hd : rhs G t s=some d)
    (he : rhs G t (bumpCooperation s student first δ)=some e) :
    guardSquaredRate (bumpCooperation s student first δ) e student second-
      guardSquaredRate s d student second =
      (2*δ/5)*alignment s student first second := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferChallenge.lean#L59-L65) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferProofs.lean#L180-L194)

## Which direction does positive alignment favor?

`positive_alignment_opens_guard_instantaneously`

**Proof request**

Deduce strictly increased guard rate from the positive alignment and increment.

**Reading the result**

With a positive cooperation increment, it makes the instantaneous squared-guard rate for the second partner larger.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem positive_alignment_opens_guard_instantaneously (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (student first second : Actor) (δ : ℝ)
    (hsecond : second≠student) (hpartners : first≠second)
    (hδ : 0<δ) (ha : 0<alignment s student first second) :
    guardSquaredRate s (rhsFromRecords G t s rs) student second <
      guardSquaredRate (bumpCooperation s student first δ)
        (rhsFromRecords G t (bumpCooperation s student first δ) rs) student second := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferChallenge.lean#L67-L73) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferProofs.lean#L196-L205)

## What if the relevant directions are perpendicular?

`orthogonal_alignment_has_zero_instantaneous_transfer`

**Proof request**

Deduce equal guard rates at zero alignment.

**Reading the result**

Zero alignment sets the entire instantaneous transfer term to zero.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem orthogonal_alignment_has_zero_instantaneous_transfer (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (student first second : Actor) (δ : ℝ)
    (hsecond : second≠student) (hpartners : first≠second)
    (ha : alignment s student first second=0) :
    guardSquaredRate (bumpCooperation s student first δ)
        (rhsFromRecords G t (bumpCooperation s student first δ) rs) student second =
      guardSquaredRate s (rhsFromRecords G t s rs) student second := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferChallenge.lean#L75-L81) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferProofs.lean#L207-L216)

## How large is the transfer at the declared initial example?

`initial_coordinate_example`

**Proof request**

Evaluate the exact transfer in the declared initial-coordinate example.

**Reading the result**

Substitution of the specified actors and a cooperation increment of 1/10 gives 76,341/4,000,000.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem initial_coordinate_example :
    guardSquaredRate (bumpCooperation (initial sourceGeometry) 1 0 (1/10))
        (rhsFromRecords sourceGeometry 0 (bumpCooperation (initial sourceGeometry) 1 0 (1/10)) []) 1 2-
      guardSquaredRate (initial sourceGeometry) (rhsFromRecords sourceGeometry 0 (initial sourceGeometry) []) 1 2
      = (76341/4000000:ℝ) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferChallenge.lean#L83-L87) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferProofs.lean#L218-L225)

## Is this guard rate observable along an actual solving trace?

`full_trace_guard_observable`

**Proof request**

Identify the guard derivative and an accepted full rate at every specified trace point.

**Reading the result**

On each specified segment an accepted rate supplies the within-interval derivative of the squared guard.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_trace_guard_observable (tr : Trace) (hsol : Solves tr) (k : ℕ) (hk : k<5)
    (t : ℝ) (ht : t∈Icc (time k) (time (k+1))) (i j : Actor) :
    ∃ d, rhs sourceGeometry t (tr.path k t).state=some d ∧
      HasDerivWithinAt (fun τ => guardSquared (tr.path k τ).state i j)
        (guardSquaredRate (tr.path k t).state d i j) (Icc (time k) (time (k+1))) t := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferChallenge.lean#L89-L93) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/V3TransferProofs.lean#L227-L234)
