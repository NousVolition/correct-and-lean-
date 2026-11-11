# Keeping fabric bits readable between events

Track one cell in either well. Its distance from the read threshold controls whether continuous evolution and accepted writes preserve the buffer.

[`V3ClayChallenge.lean`](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayChallenge.lean) · [Package configuration](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 NousVolition. All rights reserved. The repository notice applies to material for which NousVolition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayTrajectoryProofs.lean) · [V3ClayDefinitions](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayDefinitions.lean) · [Package account](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/README.md) · [Source audit](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/source-audit.json) · [Source map](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/source-map.json) · [Statement and proof inputs](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/lake-manifest.json).

</details>

## What is the probe actually measuring?

`probe_recovers_cell`

**Proof request**

Simplify the fabric probe estimate to the stored cell value.

**Reading the result**

The two load corrections simplify algebraically to the stored cell value.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem probe_recovers_cell (s : State) (l : Cell) :
    probeEstimate s l = s.b l := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayChallenge.lean#L9-L10) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayProofs.lean#L11-L14)

## What keeps a positive memory cell above its safety margin?

`positive_well_preserved`

**Proof request**

Preserve the positive 3/500 margin along the stipulated segment.

**Reading the result**

The initial bound and inward rate condition prevent it from crossing below 3/500 during the segment.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem positive_well_preserved (s : ℝ → State) (a b : ℝ) (l : Cell)
    (hc : ContinuousOn (fun t => (s t).b l) (Icc a b))
    (hd : ∀ t ∈ Ico a b, HasDerivWithinAt (fun τ => (s τ).b l)
      (fabricRate (fabricStrain (s t).F l) ((s t).b l)) (Ici t) t)
    (ha : (3/500:ℝ) ≤ (s a).b l) :
    ∀ t ∈ Icc a b, (3/500:ℝ) ≤ (s t).b l := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayChallenge.lean#L12-L17) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayProofs.lean#L28-L47)

## What keeps a negative cell on its own side?

`negative_well_preserved`

**Proof request**

Preserve the negative −3/500 margin along the stipulated segment.

**Reading the result**

The corresponding hypotheses prevent an upward crossing of −3/500.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem negative_well_preserved (s : ℝ → State) (a b : ℝ) (l : Cell)
    (hc : ContinuousOn (fun t => (s t).b l) (Icc a b))
    (hd : ∀ t ∈ Ico a b, HasDerivWithinAt (fun τ => (s τ).b l)
      (fabricRate (fabricStrain (s t).F l) ((s t).b l)) (Ici t) t)
    (hF : ∀ t ∈ Ico a b, (∑ i, ((s t).F (point l) i (axis l))^2) ≤ (2:ℝ))
    (ha : (s a).b l ≤ -(3/500:ℝ)) :
    ∀ t ∈ Icc a b, (s t).b l ≤ -(3/500:ℝ) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayChallenge.lean#L19-L25) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayProofs.lean#L49-L63)

## Can all the cell margins survive together?

`clay_buffer_preserved_on_segment`

**Proof request**

Prove preservation of the entire clay buffer on the segment.

**Reading the result**

Applying the positive or negative bound to each initial cell preserves the entire buffer over the segment.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem clay_buffer_preserved_on_segment (s : ℝ → State) (a b : ℝ)
    (hc : ∀ l, ContinuousOn (fun t => (s t).b l) (Icc a b))
    (hd : ∀ l, ∀ t ∈ Ico a b, HasDerivWithinAt (fun τ => (s τ).b l)
      (fabricRate (fabricStrain (s t).F l) ((s t).b l)) (Ici t) t)
    (hF : ∀ l, ∀ t ∈ Ico a b,
      (∑ i, ((s t).F (point l) i (axis l))^2) ≤ (2:ℝ))
    (ha : ClayBuffer (s a)) :
    ∀ t ∈ Icc a b, ClayBuffer (s t) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayChallenge.lean#L27-L34) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayProofs.lean#L65-L80)

## Is the buffer margin large enough for a read?

`clay_buffer_implies_read_margin`

**Proof request**

Derive a strict read margin of 1/200 in every buffered cell.

**Reading the result**

A buffered cell has probe magnitude strictly greater than the reader’s threshold of 1/200.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem clay_buffer_implies_read_margin (s : State) (h : ClayBuffer s) :
    ∀ l, (1/200:ℝ) < |probeEstimate s l| := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayChallenge.lean#L36-L37) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayProofs.lean#L82-L86)

## Does the starting fabric meet the margin everywhere?

`initial_clay_buffer`

**Proof request**

Verify the buffer condition in the initial state.

**Reading the result**

The initial cell values satisfy the buffer condition directly.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem initial_clay_buffer (G : Geometry) : ClayBuffer (initial G) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayChallenge.lean#L39) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayProofs.lean#L88-L90)

## Does a successful write retain the buffer?

`write_event_preserves_clay_buffer`

**Proof request**

Prove that a successful write preserves a valid buffer.

**Reading the result**

Cells in the chosen slot receive valid signed levels and the other cells keep their previous margins.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem write_event_preserves_clay_buffer (G : Geometry) (s w : State) (r : Record)
    (hs : ClayBuffer s) (hw : writeEvent G s r = some w) :
    ClayBuffer w := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayChallenge.lean#L41-L43) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayProofs.lean#L102-L117)

## Can completing an event lose the buffer at that instant?

`complete_event_preserves_clay_buffer`

**Proof request**

Carry the buffer through successful event completion.

**Reading the result**

Its successful write preserves the cell bounds through the completion update.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem complete_event_preserves_clay_buffer (id : Fin 3) (s w : FullState)
    (hs : ClayBuffer s.state) (hw : completeEvent id s = some w) :
    ClayBuffer w.state := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayChallenge.lean#L45-L47) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayProofs.lean#L119-L128)

## How do the scheduled boundaries affect the buffer?

`boundary_preserves_clay_buffer`

**Proof request**

Carry the buffer through any successful scheduled boundary.

**Reading the result**

Each accepted boundary reduces to a buffer-preserving capture, write or unchanged state.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem boundary_preserves_clay_buffer (k : ℕ) (s w : FullState)
    (hs : ClayBuffer s.state) (hw : boundary k s = some w) :
    ClayBuffer w.state := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayChallenge.lean#L49-L51) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayProofs.lean#L130-L152)

## Can continuous movement change the decoded records within this segment?

`decoded_records_fixed_on_segment`

**Proof request**

Prove equality of decoded records from segment entry to every later time on it.

**Reading the result**

The stated bounds preserve readable bit signs, giving the same decoder result throughout.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem decoded_records_fixed_on_segment (s : ℝ → State) (a b : ℝ)
    (hc : ∀ l, ContinuousOn (fun t => (s t).b l) (Icc a b))
    (hr : ∀ t ∈ Icc a b, ∃ records, readRecords (s t) = some records) :
    ∀ t ∈ Icc a b, readRecords (s t) = readRecords (s a) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayChallenge.lean#L53-L56) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayProofs.lean#L182-L214)
