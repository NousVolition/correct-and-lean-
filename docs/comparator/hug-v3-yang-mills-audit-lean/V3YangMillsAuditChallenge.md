# Does turning stretched rubber change its strain?

Let F describe the deformation. A matrix Q with QᵀQ = I preserves length, including under rotation or reflection. In the fabric comparison, only F at each particle is replaced by QF. Follow which measurements survive that change and where the rate equation detects it.

[`V3YangMillsAuditChallenge.lean`](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditChallenge.lean) · [Package configuration](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 NousVolition. All rights reserved. The repository notice applies to material for which NousVolition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditProofs.lean) · [V3YangMillsAuditDefinitions](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditDefinitions.lean) · [Package account](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/README.md) · [Saved source digests](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/preserved-inputs.json) · [Statement and proof inputs](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/lake-manifest.json).

</details>

## If I turn a piece of rubber after stretching it, will it register another stretch?

`green_objective`

**Proof request**

Show that an orthogonal transformation after a deformation preserves Green strain.

**Reading the result**

Green strain uses FᵀF. For an orthogonal turn or reflection Q, (QF)ᵀ(QF) = Fᵀ(QᵀQ)F = FᵀF. Every entry of Green strain therefore agrees.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem green_objective (Q F : Mat) (hQ : Orthogonal Q) :
    green (mm Q F)=green F := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditChallenge.lean#L9-L10) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditProofs.lean#L26-L33)

## What if the instrument reports just one number for the strain?

`strain_norm_objective`

**Proof request**

Prove equality of the strain norms before and after the orthogonal transformation.

**Reading the result**

It takes the square root of the sum of squares of the Green-strain entries. Equal entries give an equal reading.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem strain_norm_objective (Q F : Mat) (hQ : Orthogonal Q) :
    strainNorm (mm Q F)=strainNorm F := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditChallenge.lean#L12-L13) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditProofs.lean#L35-L37)

## What if I follow just one fiber?

`fiber_strain_objective`

**Proof request**

Preserve the strain in a selected fiber under particle-wise orthogonal changes.

**Reading the result**

At the chosen particle and direction, its vector becomes Q times the old vector. An orthogonal matrix preserves squared length, which is what the fiber-strain formula reads.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem fiber_strain_objective (G : Geometry) (s : State) (Q : Particle → Mat)
    (hQ : ∀ p, Orthogonal (Q p)) (p : Particle) (k : Direction) :
    fiberStrain G (rotateFabric Q s) p k=fiberStrain G s p k := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditChallenge.lean#L15-L17) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditProofs.lean#L45-L53)

## What if I read just one cell of the fabric?

`fabric_strain_objective`

**Proof request**

Preserve the strain measured by any selected fabric cell.

**Reading the result**

Each cell selects one particle and one column of its deformation matrix. An orthogonal change there preserves that column’s squared length and hence the cell’s strain.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem fabric_strain_objective (s : State) (Q : Particle → Mat)
    (hQ : ∀ p, Orthogonal (Q p)) (l : Cell) :
    fabricStrain (rotateFabric Q s).F l=fabricStrain s.F l := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditChallenge.lean#L19-L21) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditProofs.lean#L55-L64)

## Could changing the fabric matrix change which event the decoder finds?

`decoded_records_frame_invariant`

**Proof request**

Show that decoding gives the same optional record list for any particle-wise matrix change of this form.

**Reading the result**

The probe algebra reduces to the stored cell value b. Even an arbitrary matrix change leaves those b values alone, so decoding gives identical records or the same failure.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem decoded_records_frame_invariant (s : State) (Q : Particle → Mat) :
    readRecords (rotateFabric Q s)=readRecords s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditChallenge.lean#L23-L24) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditProofs.lean#L70-L72)

## Would a modeled observer sense a different state after this turn?

`observations_frame_invariant`

**Proof request**

Show that all observation channels agree under orthogonal fabric changes.

**Reading the result**

Of the three observation channels, the one that reads the deformation uses its strain norm. The other two read fields held fixed. All three agree for orthogonal changes at every particle.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem observations_frame_invariant (G : Geometry) (s : State) (Q : Particle → Mat)
    (hQ : ∀ p, Orthogonal (Q p)) :
    observations G (rotateFabric Q s)=observations G s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditChallenge.lean#L26-L28) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditProofs.lean#L83-L90)

## Could the same memories acquire different retrieval weights after a turn?

`retrieval_frame_invariant`

**Proof request**

Prove equality of retrieved memory at the same supplied record list.

**Reading the result**

The current strain cue and the other weight inputs agree. With the same record list, each weighted contribution and the exposure denominator agree.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem retrieval_frame_invariant (G : Geometry) (s : State) (Q : Particle → Mat)
    (hQ : ∀ p, Orthogonal (Q p)) (rs : List (Fin 4 × Record)) :
    memory G (rotateFabric Q s) rs=memory G s rs := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditChallenge.lean#L30-L32) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditProofs.lean#L104-L108)

## Would the instantaneous social response rates change?

`social_rates_frame_invariant`

**Proof request**

Prove equality of the social-rate calculation at fixed geometry, time and records.

**Reading the result**

At fixed geometry, time and records, the orthogonal changes preserve observation, retrieval and utility, which supply the social-rate calculation.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem social_rates_frame_invariant (G : Geometry) (t : ℝ) (s : State)
    (Q : Particle → Mat) (hQ : ∀ p, Orthogonal (Q p)) (rs : List (Fin 4 × Record)) :
    socialRates G t (rotateFabric Q s) rs=socialRates G t s rs := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditChallenge.lean#L34-L36) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditProofs.lean#L117-L123)

## What if we run the full rate calculation twice?

`accepted_rhs_social_frame_invariant`

**Proof request**

Given two successful full evaluations, prove agreement of their seven social rate fields.

**Reading the result**

Assume both runs return a rate. They decoded the same records, so the seven social fields of their rates agree, including expression, context and responses.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem accepted_rhs_social_frame_invariant (G : Geometry) (t : ℝ) (s d e : State)
    (Q : Particle → Mat) (hQ : ∀ p, Orthogonal (Q p))
    (hd : rhs G t s=some d) (he : rhs G t (rotateFabric Q s)=some e) :
    SameSocial e d := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditChallenge.lean#L38-L41) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditProofs.lean#L134-L143)

## Can different orientations at the start and end change the event record?

`event_record_frame_invariant`

**Proof request**

Prove that independently changing the two endpoint frames preserves the optional event record.

**Reading the result**

Each endpoint contributes Green strain, so each can undergo its own orthogonal change. The strain difference and other record fields agree, including the decoder’s failure outcome where applicable.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem event_record_frame_invariant (s : State) (startF : Particle → Mat)
    (Q R : Particle → Mat) (hQ : ∀ p, Orthogonal (Q p))
    (hR : ∀ p, Orthogonal (R p)) (id : Fin 3) :
    makeEvent (rotateFabric Q s) (fun p => mm (R p) (startF p)) id=
    makeEvent s startF id := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditChallenge.lean#L43-L47) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditProofs.lean#L145-L155)

## Could turning the fabric change the bill for writing the same target?

`write_account_frame_invariant`

**Proof request**

Prove equality of the entire write account for a fixed target.

**Reading the result**

Cell strain, old storage and target agree. Substitution gives the same heat by particle, work and required budget.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem write_account_frame_invariant (G : Geometry) (s : State) (Q : Particle → Mat)
    (hQ : ∀ p, Orthogonal (Q p)) (target : Cell → ℝ) :
    writeAccount G (rotateFabric Q s) target=writeAccount G s target := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditChallenge.lean#L49-L51) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditProofs.lean#L162-L167)

## Does it matter whether we turn the fabric before or after writing?

`memory_write_frame_equivariant`

**Proof request**

Show that rotating fabric and writing a fixed record commute, including rejected writes.

**Reading the result**

The decoder, duplicate test, slot selection, payload and budget checks give the same decisions. A rejected write rejects in both orders, and successful states differ by exactly that fabric turn.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem memory_write_frame_equivariant (G : Geometry) (s : State) (Q : Particle → Mat)
    (hQ : ∀ p, Orthogonal (Q p)) (r : Record) :
    writeEvent G (rotateFabric Q s) r=(writeEvent G s r).map (rotateFabric Q) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditChallenge.lean#L53-L55) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditProofs.lean#L169-L193)

## If I shuffle a stack of records, does retrieval change?

`retrieval_ignores_list_order`

**Proof request**

Prove that permuting the same slot–record pairs preserves retrieval.

**Reading the result**

A permutation keeps every slot–record pair with its multiplicity. Both the weighted sum and the exposure sum are independent of their order.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem retrieval_ignores_list_order (G : Geometry) (s : State)
    (rs zs : List (Fin 4 × Record)) (h : rs.Perm zs) :
    memory G s rs=memory G s zs := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditChallenge.lean#L57-L59) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditProofs.lean#L201-L208)

## Could that shuffle change some other part of the full rate?

`full_rate_ignores_list_order`

**Proof request**

Prove that every component of the full rate from records is invariant under that permutation.

**Reading the result**

The supplied list enters through the social calculation. Its sums agree after permutation, so every component of the rate calculated from the list agrees.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_rate_ignores_list_order (G : Geometry) (t : ℝ) (s : State)
    (rs zs : List (Fin 4 × Record)) (h : rs.Perm zs) :
    rhsFromRecords G t s rs=rhsFromRecords G t s zs := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditChallenge.lean#L61-L63) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditProofs.lean#L221-L224)

## What motion does the model actually assign to the deformation?

`actual_deformation_component`

**Proof request**

Identify the deformation-rate component at a particle as its local velocity gradient times its fabric.

**Reading the result**

Reading the deformation field of the calculated rate at particle p gives LₚFₚ, where Lₚ is its local velocity gradient.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem actual_deformation_component (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (p : Particle) :
    (rhsFromRecords G t s rs).F p=mm (particleGradient s p) (s.F p) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditChallenge.lean#L65-L67) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditProofs.lean#L226-L229)

## What if both the frame and the fabric move in time?

`deformation_product_rule`

**Proof request**

Prove the matrix product rule for within-set derivatives of Q and F at the specified time.

**Reading the result**

Differentiate each entry of their matrix product on the stated time set. The two contributions are Q′F and QF′, in that order.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem deformation_product_rule (Q F : ℝ → Mat) (dQ dF : Mat) (I : Set ℝ) (t : ℝ)
    (hQ : MatrixDerivWithin Q dQ I t) (hF : MatrixDerivWithin F dF I t) :
    MatrixDerivWithin (fun τ => mm (Q τ) (F τ))
      (mm dQ (F t)+mm (Q t) dF) I t := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditChallenge.lean#L69-L72) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditProofs.lean#L231-L238)

## Does turning the current fabric automatically turn its rate correctly?

`actual_full_rhs_frame_defect`

**Proof request**

Compute the exact rate discrepancy as (dQ + QL − LQ)F at the selected particle.

**Reading the result**

Holding the velocity gradient L fixed leaves an exact difference (dQ + QL − LQ)F. The identity is algebraic for the supplied matrices. With dQ interpreted as frame velocity, it compares the two rate calculations.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem actual_full_rhs_frame_defect (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (Q : Particle → Mat) (dQ : Mat) (p : Particle) :
    mm dQ (s.F p)+mm (Q p) ((rhsFromRecords G t s rs).F p)-
      (rhsFromRecords G t (rotateFabric Q s) rs).F p=
    mm (dQ+mm (Q p) (particleGradient s p)-mm (particleGradient s p) (Q p))
      (s.F p) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditChallenge.lean#L74-L79) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditProofs.lean#L240-L250)

## Does the chosen 90-degree turn really preserve lengths?

`quarter_turn_is_orthogonal`

**Proof request**

Verify orthogonality of the explicit quarter-turn matrix.

**Reading the result**

Its matrix exchanges the first two axes with one sign change and fixes the third. Multiplying its transpose by itself gives the identity.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem quarter_turn_is_orthogonal : Orthogonal quarterTurn := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditChallenge.lean#L81) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditProofs.lean#L252-L256)

## Can the rate difference actually be nonzero?

`explicit_nonzero_frame_defect`

**Proof request**

Evaluate the specified defect entry at the quarter turn, zero frame rate, diagonal rate and identity fabric.

**Reading the result**

Set F to the identity, dQ to zero, and use the specified quarter turn and diagonal rate. The first-row, second-column entry of QL − LQ equals two.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem explicit_nonzero_frame_defect :
    frameDefect quarterTurn 0 diagonalRate eye 0 1=2 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditChallenge.lean#L83-L84) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditProofs.lean#L258-L260)

## Can an orthogonal turn always be moved past the rate matrix?

`naive_rotation_covariance_fails`

**Proof request**

Disprove universal commutation of the two rate calculations for orthogonal Q.

**Reading the result**

In the same example that entry is +1 in QL and −1 in LQ. One such mismatch disproves the proposed equality for all Q, L and F.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem naive_rotation_covariance_fails :
    ¬(∀ Q L F : Mat, Orthogonal Q → mm Q (mm L F)=mm L (mm Q F)) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditChallenge.lean#L86-L87) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditProofs.lean#L262-L266)
