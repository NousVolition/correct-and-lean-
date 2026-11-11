# What would establish a complete apple trajectory?

Connect the apple construction to the original full-trace existence question. Trace the role of a supplied certificate and the failure of a single readable ball across opposite bit signs.

[`AppleExistenceChallenge.lean`](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleExistenceChallenge.lean) · [Package configuration](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 NousVolition. All rights reserved. The repository notice applies to material for which NousVolition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleExistenceProofs.lean) · [AppleExistenceDefinitions](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleExistenceDefinitions.lean) · [Statement and proof inputs](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/lake-manifest.json).

</details>

## What does the model read before any records have been written?

`initial_read_is_empty`

**Proof request**

Evaluate the initial decoder and obtain a successful empty list.

**Reading the result**

Initial memory decodes successfully to an empty list.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem initial_read_is_empty (G : Geometry) : readRecords (initial G)=some [] := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleExistenceChallenge.lean#L8) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleInitialProofs.lean#L12-L29)

## How close to zero can the source power denominator get?

`source_power_floor`

**Proof request**

Prove the source power denominator is at least 1/100,000.

**Reading the result**

Its floor gives a lower bound of 1/100,000 at every particle and state.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem source_power_floor (s : State) (p : Particle) : (1/100000:ℝ) ≤ powerDenominator sourceGeometry s p := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleExistenceChallenge.lean#L10) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleInitialProofs.lean#L51-L71)

## Can the full initial rate be evaluated?

`initial_full_rate_defined`

**Proof request**

Show that the full initial rate is defined and equals its empty-record value.

**Reading the result**

The empty initial read and the power bound yield the rate calculated from an empty record list.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem initial_full_rate_defined (t : ℝ) :
    rhs sourceGeometry t initialFull.state = some (rhsFromRecords sourceGeometry t initialFull.state []) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleExistenceChallenge.lean#L12-L13) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleInitialProofs.lean#L85-L100)

## Can the entire state travel into coordinates and back?

`full_coordinate_round_trip`

**Proof request**

Prove both inverse identities for full state coordinates.

**Reading the result**

Packing and unpacking undo each other in both directions.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_coordinate_round_trip (s : State) (x : Coordinates) : unpack (pack s)=s ∧ pack (unpack x)=x := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleExistenceChallenge.lean#L15) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/ApplePackedProofs.lean#L7-L10)

## Do the coordinates preserve what it means to have a derivative?

`packed_derivative_iff`

**Proof request**

Prove equivalence of packed and coordinate-wise derivatives on the time set.

**Reading the result**

A packed path has the packed derivative exactly when each original state coordinate has its prescribed derivative on the set.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem packed_derivative_iff (x : ℝ → State) (d : State) (I : Set ℝ) (t : ℝ) :
    HasDerivWithinAt (fun s => pack (x s)) (pack d) I t ↔ StateHasDerivWithinAt x d I t := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleExistenceChallenge.lean#L17-L18) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/ApplePackedProofs.lean#L12-L48)

## What does a verified tube give for one segment?

`tube_supplies_unique_full_segment`

**Proof request**

Construct the segment inside the certified tube and prove uniqueness for the same entry coordinates.

**Reading the result**

Its bounds and entry condition produce a solution inside the error tube and agreement on the segment for every other solution with that start.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem tube_supplies_unique_full_segment {k : ℕ} (B : Tube k) (hB : Bounds B) (z : Coordinates)
    (hz : dist z (B.center (time k)) ≤ B.entryError) :
    ∃ x : ℝ → Coordinates, x (time k)=z ∧ PackedSegment k x ∧
      (∀ t ∈ Icc (time k) (time (k+1)), dist (x t) (B.center t) ≤ B.error t) ∧
      ∀ y : ℝ → Coordinates, y (time k)=z → PackedSegment k y →
        EqOn x y (Icc (time k) (time (k+1))) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleExistenceChallenge.lean#L20-L25) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleTubeProofs.lean#L118-L187)

## Can two material flows carry the same solved trace differently?

`material_carrier_unique_on_trace`

**Proof request**

Show agreement of two admissible material carriers on the same solved trace.

**Reading the result**

On the domain specified by carrier agreement, uniqueness makes their positions coincide.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem material_carrier_unique_on_trace (tr : Trace) (h : Solves tr) (R : ℝ≥0) (φ ψ : Vec × ℝ → Vec)
    (f : AppleBand.MaterialFlowAcross tr R φ) (g : AppleBand.MaterialFlowAcross tr R ψ) :
    CarrierAgreement R φ ψ := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleExistenceChallenge.lean#L27-L29) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleCarrierUniqueness.lean#L13-L55)

## What extra existence claim does the full apple require?

`full_apple_iff_source`

**Proof request**

Prove equivalence of the full apple and source existence-and-uniqueness claims for R ≥ 1.

**Reading the result**

For radius at least one, adding the material carrier gives an equivalent existence-and-uniqueness claim to the source trace.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_apple_iff_source (R : ℝ≥0) (hR : 1≤R) : FullApple R ↔ FullExistenceUniqueness := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleExistenceChallenge.lean#L31) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleCarrierUniqueness.lean#L57-L63)

## What would a full schedule certificate establish?

`certificate_gives_full_apple`

**Proof request**

Derive the full apple conclusion from a supplied schedule certificate.

**Reading the result**

The certificate supplies the segment and boundary controls needed for the full apple result at radius at least one.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem certificate_gives_full_apple (cert : ScheduleCertificate) (R : ℝ≥0) (hR : 1≤R) : FullApple R := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleExistenceChallenge.lean#L33) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleScheduleProofs.lean#L114-L116)

## How far from the initial state can this rate check still succeed?

`initial_ball_full_rate_defined`

**Proof request**

Show that the rate is defined with empty records on the specified initial ball.

**Reading the result**

Within the stated packed distance of 1/100 the empty-record computation still gives the full rate.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem initial_ball_full_rate_defined (t : ℝ) (s : State)
    (near : dist (pack s) (pack initialFull.state) ≤ (1/100:ℝ)) :
    rhs sourceGeometry t s=some (rhsFromRecords sourceGeometry t s []) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleExistenceChallenge.lean#L35-L37) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleInitialProofs.lean#L159-L181)

## Can a tiny perturbation at a rounding boundary flip a fabric bit?

`rounding_seam_switches_fabric_bit`

**Proof request**

Compute the two quantized values and the change in the lowest fabric bit across the rounding seam.

**Reading the result**

The exact tie rounds to zero. The admitted positive offset rounds to one, changing the encoded bit by 1/25.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem rounding_seam_switches_fabric_bit (ε : ℝ) (hε : 0<ε) (small : ε<(1/10000:ℝ)) :
    quant (1/10000) (1/20000)=some 0 ∧ quant (1/10000) (1/20000+ε)=some 1 ∧
    bitsOfPayload (intBytes 1) 0-bitsOfPayload (intBytes 0) 0=(1/25:ℝ) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleExistenceChallenge.lean#L39-L41) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleInitialProofs.lean#L192-L202)

## Can a whole coordinate ball be readable if one cell takes opposite signs inside it?

`opposite_codes_preclude_one_domain_ball`

**Proof request**

Construct an unreadable point inside a ball containing opposite signs in one cell.

**Reading the result**

A point between those codes has a zero cell, where the rate rejects for every time.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem opposite_codes_preclude_one_domain_ball (c x y : Coordinates) (r : ℝ≥0) (l : Cell)
    (hx : x∈closedBall c (r:ℝ)) (hy : y∈closedBall c (r:ℝ))
    (negative : x (.cell l)<0) (positive : 0<y (.cell l)) :
    ∃ z∈closedBall c (r:ℝ), ∀ t, rhs sourceGeometry t (unpack z)=none := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleExistenceChallenge.lean#L43-L46) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleInitialProofs.lean#L210-L241)

## Do the two recorded values of cell 42320 trigger that obstruction?

`recorded_cell_precludes_one_domain_ball`

**Proof request**

Use the two recorded values at cell 42320 to exhibit an unreadable point in their containing ball.

**Reading the result**

Their opposite signs supply the preceding argument inside any ball containing both.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem recorded_cell_precludes_one_domain_ball (c x y : Coordinates) (r : ℝ≥0)
    (hx : x∈closedBall c (r:ℝ)) (hy : y∈closedBall c (r:ℝ))
    (main : x (.cell 42320)=(-5756669002346905/288230376151711744:ℝ))
    (half : y (.cell 42320)=(5757349591092827/288230376151711744:ℝ)) :
    ∃ z∈closedBall c (r:ℝ), ∀ t, rhs sourceGeometry t (unpack z)=none := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleExistenceChallenge.lean#L48-L52) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-existence-lean/AppleInitialProofs.lean#L243-L252)
