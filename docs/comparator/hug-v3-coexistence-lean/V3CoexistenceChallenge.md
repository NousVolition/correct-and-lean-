# Can alignment and association coexist?

Keep a separate floor for each quantity. A constructed state has both markers even while alignment is decreasing.

[`V3CoexistenceChallenge.lean`](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceChallenge.lean) · [Package configuration](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 Nous Volition. All rights reserved. The repository notice applies to material for which Nous Volition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceProofs.lean) · [V3CoexistenceDefinitions](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceDefinitions.lean) · [Statement and proof inputs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/lake-manifest.json).

</details>

## Which rate moves a person’s norm center in an accepted calculation?

`accepted_full_norm_rate`

**Proof request**

Extract the norm-center rate from an accepted full rate.

**Reading the result**

Projecting the full rate returns the model’s specified norm-center rate.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem accepted_full_norm_rate (G : Geometry) (t : ℝ) (s rate : State)
    (h : rhs G t s=some rate) (i : Actor) (k : Fin 2) :
    rate.normCenter i k=Transfer.normRate s i k := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceChallenge.lean#L7-L9) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceProofs.lean#L19-L24)

## Can replacing only the association field immediately change that rate?

`same_instant_norm_rate_with_any_association`

**Proof request**

Prove invariance of the instantaneous norm rate under arbitrary association replacement.

**Reading the result**

The norm-rate expression uses other state fields, so every such replacement gives the same value.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem same_instant_norm_rate_with_any_association (s : State)
    (a : Actor → Actor → Fin 3 → ℝ) (i : Actor) (k : Fin 2) :
    Transfer.normRate {s with association := a} i k=Transfer.normRate s i k := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceChallenge.lean#L11-L13) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceProofs.lean#L26-L28)

## How fast does alignment change on a solved segment?

`full_trace_alignment_derivative`

**Proof request**

Differentiate norm alignment along the specified full-trace segment.

**Reading the result**

Applying the norm-center derivative in the chosen baseline direction gives the defined alignment rate.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_trace_alignment_derivative (tr : Trace) (hsol : Solves tr)
    (q : ℕ) (hq : q<5) (baseline : State) (v : Actor → Fin 2 → ℝ)
    (i : Actor) (t : ℝ) (ht : t ∈ Icc (time q) (time (q+1))) :
    HasDerivWithinAt (fun x => normAlignment (tr.path q x).state baseline v i)
      (normAlignmentRate (tr.path q t).state v i) (Icc (time q) (time (q+1))) t := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceChallenge.lean#L15-L19) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceProofs.lean#L43-L57)

## What lets each actor retain a minimum alignment?

`full_segment_alignment_floor`

**Proof request**

Propagate the initial actor-specific alignment floors under the inward hypothesis.

**Reading the result**

An initial floor together with the stated inward condition keeps that actor above the floor for the segment.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_segment_alignment_floor (tr : Trace) (hsol : Solves tr)
    (q : ℕ) (hq : q<5) (baseline : State) (v : Actor → Fin 2 → ℝ)
    (floor : Actor → ℝ) (hflow : NormInward tr q baseline v floor)
    (hstart : ∀ i, floor i≤normAlignment (tr.after q).state baseline v i) :
    ∀ t ∈ Icc (time q) (time (q+1)), ∀ i,
      floor i≤normAlignment (tr.path q t).state baseline v i := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceChallenge.lean#L21-L26) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceProofs.lean#L59-L87)

## What keeps the selected association above rho?

`full_segment_association_floor`

**Proof request**

Propagate the association floor under its own inward hypothesis.

**Reading the result**

Its starting value and inward condition prevent it from crossing the floor.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_segment_association_floor (tr : Trace) (hsol : Solves tr)
    (q : ℕ) (hq : q<5) (rho : ℝ) (hflow : AssociationInward tr q rho)
    (hstart : rho≤(tr.after q).state.association 1 0 0) :
    ∀ t ∈ Icc (time q) (time (q+1)), rho≤(tr.path q t).state.association 1 0 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceChallenge.lean#L28-L31) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceProofs.lean#L89-L133)

## Can the alignment and association bounds both hold throughout one segment?

`full_segment_coexistence`

**Proof request**

Combine both floors to establish coexistence throughout the segment.

**Reading the result**

Applying their two separate preservation results yields coexistence at every time.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_segment_coexistence (tr : Trace) (hsol : Solves tr)
    (q : ℕ) (hq : q<5) (baseline : State) (v : Actor → Fin 2 → ℝ)
    (floor : Actor → ℝ) (rho : ℝ)
    (hn : NormInward tr q baseline v floor) (ha : AssociationInward tr q rho)
    (hs : Coexists (tr.after q).state baseline v floor rho) :
    ∀ t ∈ Icc (time q) (time (q+1)),
      Coexists (tr.path q t).state baseline v floor rho := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceChallenge.lean#L33-L39) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceProofs.lean#L135-L148)

## Does an accepted write disturb coexistence?

`write_preserves_coexistence`

**Proof request**

Show that an accepted write preserves coexistence.

**Reading the result**

It preserves the fields used to measure both markers.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem write_preserves_coexistence (G : Geometry) (s w baseline : State)
    (r : Record) (v : Actor → Fin 2 → ℝ) (floor : Actor → ℝ) (rho : ℝ)
    (hw : writeEvent G s r=some w) (hs : Coexists s baseline v floor rho) :
    Coexists w baseline v floor rho := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceChallenge.lean#L41-L44) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceProofs.lean#L150-L161)

## Can an accepted scheduled boundary disturb those markers?

`boundary_preserves_coexistence`

**Proof request**

Show that an accepted boundary preserves coexistence.

**Reading the result**

The individual boundary operations preserve them whenever coexistence holds at entry.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem boundary_preserves_coexistence (q : ℕ) (s w : FullState) (baseline : State)
    (v : Actor → Fin 2 → ℝ) (floor : Actor → ℝ) (rho : ℝ)
    (hw : boundary q s=some w) (hs : Coexists s.state baseline v floor rho) :
    Coexists w.state baseline v floor rho := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceChallenge.lean#L46-L49) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceProofs.lean#L174-L188)

## How far can coexistence be carried across an entire schedule?

`full_hybrid_conditional_coexistence`

**Proof request**

Propagate coexistence through all remaining checkpoints and segments under both inward hypotheses.

**Reading the result**

From the specified starting checkpoint, the inward conditions on each remaining segment and the boundary results carry it through checkpoint five.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_hybrid_conditional_coexistence (tr : Trace) (hsol : Solves tr)
    (start : ℕ) (hstart : start<5) (baseline : State) (v : Actor → Fin 2 → ℝ)
    (floor : Actor → ℝ) (rho : ℝ)
    (hn : ∀ q<5, start≤q → NormInward tr q baseline v floor)
    (ha : ∀ q<5, start≤q → AssociationInward tr q rho)
    (hs : Coexists (tr.after start).state baseline v floor rho) :
    (∀ q, start≤q → q≤5 → Coexists (tr.after q).state baseline v floor rho) ∧
    (∀ q, start≤q → q<5 → ∀ t ∈ Icc (time q) (time (q+1)),
      Coexists (tr.path q t).state baseline v floor rho) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceChallenge.lean#L51-L59) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceProofs.lean#L190-L222)

## Can one state satisfy both markers explicitly?

`erosion_witness_has_coexisting_markers`

**Proof request**

Verify coexistence at the two specified floors for the erosion witness.

**Reading the result**

The erosion witness reaches both stated floors of one half.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem erosion_witness_has_coexisting_markers (G : Geometry) :
    Coexists (erosionWitness G) (initial G) (fun _ _ => 1) (fun _ => 1/2) (1/2) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceChallenge.lean#L61-L62) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceProofs.lean#L224-L228)

## Can alignment already be eroding while association is high?

`active_association_allows_alignment_erosion`

**Proof request**

Compute the witness’s association, alignment rate and selected norm-center rate.

**Reading the result**

At the witness, association is one, alignment rate is −7/5 and the selected norm-center rate is −7/10.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem active_association_allows_alignment_erosion (G : Geometry) (t : ℝ)
    (rs : List (Fin 4 × Record)) :
    (erosionWitness G).association 1 0 0=1 ∧
    normAlignmentRate (erosionWitness G) (fun _ _ => 1) 1=-(7/5:ℝ) ∧
    (rhsFromRecords G t (erosionWitness G) rs).normCenter 1 0=-(7/10:ℝ) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceChallenge.lean#L64-L68) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceProofs.lean#L230-L238)

## Which state supplies the norm-center rate in an accepted delayed calculation?

`delayed_full_norm_rate`

**Proof request**

Extract the past-state norm rate from a successful delayed rate.

**Reading the result**

Projecting its social block gives the rate evaluated on the past state.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem delayed_full_norm_rate (G : Geometry) (t : ℝ) (present past rate : State)
    (h : Delay.rhsDelayed G t present past=some rate) (i : Actor) (k : Fin 2) :
    rate.normCenter i k=Transfer.normRate past i k := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceChallenge.lean#L70-L72) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-coexistence-lean/V3CoexistenceProofs.lean#L240-L247)
