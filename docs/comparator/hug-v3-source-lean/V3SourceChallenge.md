# The native fabric rate and the read threshold

Project the accepted rate onto fabric and accumulator coordinates. Evaluate the two read boundaries, a strong-deformation counterexample and the reference checksum.

[`V3SourceChallenge.lean`](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/V3SourceChallenge.lean) · [Package configuration](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 Nous Volition. All rights reserved. The repository notice applies to material for which Nous Volition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/V3SourceProofs.lean) · [V3SourceSystem](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/V3SourceSystem.lean) · [Package account](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/README.md) · [Source audit](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/source-audit.json) · [Source map](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/source-map.json) · [Statement and proof inputs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/lake-manifest.json).

</details>

## What rule governs a cell in an accepted rate?

`rhs_fabric_equation`

**Proof request**

Extract the exact cell rate from a successful full evaluation.

**Reading the result**

Its derivative is the fabric rate evaluated at that cell’s strain and stored value.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem rhs_fabric_equation (G : Geometry) (t : ℝ) (s d : State)
    (h : rhs G t s=some d) (l : Cell) :
    d.b l=fabricRate (fabricStrain s.F l) (s.b l) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/V3SourceChallenge.lean#L6-L8) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/V3SourceProofs.lean#L20-L25)

## Where does the accepted accumulator rate come from?

`rhs_accumulator_equation`

**Proof request**

Recover the read records and accumulator rate from that successful evaluation.

**Reading the result**

The successful read supplies records, and its rate equals 0.08 times their social utility.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem rhs_accumulator_equation (G : Geometry) (t : ℝ) (s d : State)
    (h : rhs G t s=some d) :
    ∃ records, readRecords s=some records ∧
      d.A=0.08*(socialRates G t s records).utility := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/V3SourceChallenge.lean#L10-L13) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/V3SourceProofs.lean#L27-L32)

## How negative can a cell’s fabric strain be?

`fabric_strain_lower_bound`

**Proof request**

Prove the universal lower bound −1/2 for fabric strain.

**Reading the result**

Squared column length is nonnegative, so subtracting one and halving gives a floor of −1/2.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem fabric_strain_lower_bound (F : Particle → Mat) (l : Cell) :
    -(1/2:ℝ)≤fabricStrain F l := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/V3SourceChallenge.lean#L15-L16) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/V3SourceProofs.lean#L34-L39)

## Which way does the positive read boundary move?

`positive_read_boundary_inward`

**Proof request**

Bound the fabric rate from below at the positive read boundary.

**Reading the result**

At +1/200 the fabric rate is at least 259/1,600,000.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem positive_read_boundary_inward (F : Particle → Mat) (l : Cell) :
    (259/1600000:ℝ)≤fabricRate (fabricStrain F l) (1/200) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/V3SourceChallenge.lean#L18-L19) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/V3SourceProofs.lean#L46-L51)

## Exactly when does the negative read boundary move inward?

`negative_read_boundary_inward_iff`

**Proof request**

Give the necessary and sufficient column-norm condition for inward motion at the negative boundary.

**Reading the result**

At −1/200 the rate is negative precisely when the squared column length is below 3459/1600.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem negative_read_boundary_inward_iff (F : Particle → Mat) (l : Cell) :
    fabricRate (fabricStrain F l) (-1/200)<0 ↔
      (∑ i, (F (point l) i (axis l))^2)<(3459/1600:ℝ) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/V3SourceChallenge.lean#L21-L23) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/V3SourceProofs.lean#L60-L64)

## What bound do you get if the squared column length is at most two?

`negative_read_boundary_under_two`

**Proof request**

Derive the negative rate bound from squared column length at most two.

**Reading the result**

At −1/200 the rate is at most −259/1,600,000.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem negative_read_boundary_under_two (F : Particle → Mat) (l : Cell)
    (h : (∑ i, (F (point l) i (axis l))^2)≤(2:ℝ)) :
    fabricRate (fabricStrain F l) (-1/200)≤-(259/1600000:ℝ) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/V3SourceChallenge.lean#L25-L27) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/V3SourceProofs.lean#L66-L70)

## Can a stronger deformation reverse that sign?

`large_deformation_not_automatic`

**Proof request**

Exhibit an outward rate at the negative boundary for the doubled identity.

**Reading the result**

The explicit doubled identity makes the rate positive at the negative read boundary.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem large_deformation_not_automatic :
    0<fabricRate (fabricStrain (fun _ i j => if i=j then 2 else 0) 0) (-1/200) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/V3SourceChallenge.lean#L29-L30) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/V3SourceProofs.lean#L72-L74)

## Does writing a cell restore a strict reading margin?

`written_cell_restores_margin`

**Proof request**

Show that the written target cell has magnitude 1/50 and clears the 1/200 threshold.

**Reading the result**

In the selected slot the target magnitude is 1/50, strictly above 1/200.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem written_cell_restores_margin (s : State) (slot : Fin 4) (bytes : List ℕ) (l : Cell)
    (h : l.val/37264=slot.val) :
    |targetFabric s slot bytes l|=(1/50:ℝ) ∧
      (1/200:ℝ) < |targetFabric s slot bytes l| := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/V3SourceChallenge.lean#L32-L35) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/V3SourceProofs.lean#L76-L85)

## Which checksum does the test sequence produce?

`crc_reference_vector`

**Proof request**

Evaluate CRC-32 for the nine supplied reference bytes.

**Reading the result**

The listed byte sequence for the digits one through nine gives CRC-32 value 3,421,780,262.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem crc_reference_vector :
    crc32 [49,50,51,52,53,54,55,56,57]=3421780262 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/V3SourceChallenge.lean#L37-L38) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-source-lean/V3SourceProofs.lean#L88-L89)
