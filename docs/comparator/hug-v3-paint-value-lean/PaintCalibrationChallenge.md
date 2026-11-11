# How much paint is on the line?

Hold its footprint fixed and vary its height. Determine which totals, calibrated sensors and force readings can recover that height.

[`PaintCalibrationChallenge.lean`](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationChallenge.lean) · [Package configuration](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 NousVolition. All rights reserved. The repository notice applies to material for which NousVolition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationProofs.lean) · [PaintCalibrationDefinitions](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationDefinitions.lean) · [Statement and proof inputs](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/lake-manifest.json).

</details>

## Which fields are present before any paint signal is applied?

`declared_start`

**Proof request**

Read the three declared initial conditions directly from the initial state.

**Reading the result**

The public channel and source accumulator start at zero, while the private context starts at home.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem declared_start (G : Geometry) :
    (∀ x, (initial G).g x 3 = 0) ∧ (initial G).A = 0 ∧ (initial G).context = home := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationChallenge.lean#L8-L9) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationProofs.lean#L83-L87)

## What sets the accepted public-field rate?

`accepted_original_field_rate`

**Proof request**

Project the accepted rate onto the accumulator and public-field equations using its decoded records.

**Reading the result**

It is transported background plus the accumulator times the spatial source kernel. The same accepted calculation gives the accumulator’s utility-driven rate.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem accepted_original_field_rate (G : Geometry) (s d : State) (t : ℝ)
    (ok : rhs G t s = some d) :
    ∃ rs, readRecords s = some rs ∧ d = rhsFromRecords G t s rs ∧
      d.A = 0.08 * (socialRates G t s rs).utility ∧
      ∀ x, d.g x 3 = contextTransport (fun y => s.g y 3) (velocity s) x
        + s.A * sourceKernel G t s rs x := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationChallenge.lean#L11-L16) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationProofs.lean#L89-L102)

## Can changing one person’s context mimic changing the public field?

`private_context_comparison`

**Proof request**

Compare the physical state, observations, records and public-field rate after the private-context shift.

**Reading the result**

In the specified comparison the grid, observations, decoded records and instantaneous rate of channel three agree.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem private_context_comparison (G : Geometry) (s : State) (i : Actor)
    (h t : ℝ) (rs : List (Fin 4 × Record)) :
    (shiftPersonalContext s i h).g = s.g ∧
    observations G (shiftPersonalContext s i h) = observations G s ∧
    readRecords (shiftPersonalContext s i h) = readRecords s ∧
    ∀ x, (rhsFromRecords G t (shiftPersonalContext s i h) rs).g x 3 =
      (rhsFromRecords G t s rs).g x 3 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationChallenge.lean#L18-L24) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationProofs.lean#L104-L111)

## What exactly does the line-shaped intervention change?

`footprint_compares_full_inputs`

**Proof request**

Identify the changed coordinate of a full line intervention and prove all specified other fields agree.

**Reading the result**

Only grid channel three is replaced by background plus the footprint indicator times its height. Captures and personal context are preserved.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem footprint_compares_full_inputs (y : FullState) (B : Scalar) (L : Footprint) (h : ℝ) :
    (fullLineInput y (profile B L h)).state.context = y.state.context ∧
    (fullLineInput y (profile B L h)).starts = y.starts ∧
    {(fullLineInput y (profile B L h)).state with g := y.state.g} = y.state ∧
    (∀ x k, k ≠ 3 → (fullLineInput y (profile B L h)).state.g x k = y.state.g x k) ∧
    ∀ x, (fullLineInput y (profile B L h)).state.g x 3 = B x + h * indicator L x := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationChallenge.lean#L26-L31) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationProofs.lean#L113-L121)

## Can identical painted footprints hide different values?

`same_footprint_and_person_distinct_values`

**Proof request**

Exhibit matching footprints and personal context with different values on the marked cell.

**Reading the result**

Heights h and 2h have the same changed locations under the hypotheses, yet they differ at the selected marked cell.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem same_footprint_and_person_distinct_values (y : FullState) (B : Scalar)
    (L : Footprint) (x : Grid) (marked : L x = true) (h : ℝ) (pos : 0 < h) :
    (∀ z, (profile B L h z ≠ B z ↔ profile B L (2*h) z ≠ B z)) ∧
    (fullLineInput y (profile B L h)).state.context =
      (fullLineInput y (profile B L (2*h))).state.context ∧
    (fullLineInput y (profile B L h)).state.g x 3 ≠
      (fullLineInput y (profile B L (2*h))).state.g x 3 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationChallenge.lean#L33-L39) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationProofs.lean#L123-L135)

## Can any contrast be assigned when the background is free to move?

`unfixed_background_allows_any_contrast`

**Proof request**

Construct a background shift that absorbs any proposed change of contrast.

**Reading the result**

Shifting the background on the footprint offsets a change from height h to height k exactly.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem unfixed_background_allows_any_contrast (B : Scalar) (L : Footprint) (h k : ℝ) :
    profile (fun x => B x + (h-k)*indicator L x) L k = profile B L h := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationChallenge.lean#L41-L42) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationProofs.lean#L137-L141)

## How can a total-field measurement recover height?

`independent_field_total_recovers_contrast`

**Proof request**

Recover signed line height from the total-field difference and nonzero footprint volume.

**Reading the result**

Subtract the known background total and divide by the nonzero footprint total.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem independent_field_total_recovers_contrast (B : Scalar) (L : Footprint)
    (h : ℝ) (nonemptyVolume : total (indicator L) ≠ 0) :
    (total (profile B L h) - total B) / total (indicator L) = h := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationChallenge.lean#L44-L46) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationProofs.lean#L143-L148)

## When does a footprint have positive volume?

`marked_cell_has_positive_volume`

**Proof request**

Prove positive footprint volume from a marked cell.

**Reading the result**

A marked cell supplies a strictly positive contribution to its indicator total.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem marked_cell_has_positive_volume (L : Footprint) (x : Grid) (marked : L x = true) :
    0 < total (indicator L) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationChallenge.lean#L48-L49) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationProofs.lean#L150-L155)

## Can transport create net paint in this periodic grid?

`original_transport_redistributes_field`

**Proof request**

Prove that the total of the original transport term vanishes.

**Reading the result**

Summing the flux differences cancels them across the grid.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem original_transport_redistributes_field (C : Scalar) (u : Vector) :
    total (contextTransport C u) = 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationChallenge.lean#L51-L52) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationProofs.lean#L157-L160)

## Where does the total field rate come from?

`spatial_total_rate_from_original_source`

**Proof request**

Derive the total public-field rate from the accumulator and summed source kernel.

**Reading the result**

With the transport sum zero, only the accumulator times the total source kernel remains.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem spatial_total_rate_from_original_source (G : Geometry) (s d : State)
    (t : ℝ) (ok : rhs G t s = some d) :
    ∃ rs, readRecords s = some rs ∧
      total (fun x => d.g x 3) = s.A * total (sourceKernel G t s rs) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationChallenge.lean#L54-L57) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationProofs.lean#L162-L169)

## What if the kernel integrates to one?

`unit_kernel_rate`

**Proof request**

Reduce the total rate to the accumulator for a unit kernel.

**Reading the result**

The total accepted field rate equals the accumulator itself.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem unit_kernel_rate (G : Geometry) (s d : State) (t : ℝ) (ok : rhs G t s = some d)
    (unit : ∀ rs, readRecords s = some rs → total (sourceKernel G t s rs) = 1) :
    total (fun x => d.g x 3) = s.A := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationChallenge.lean#L59-L61) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationProofs.lean#L171-L175)

## When do the original attachments normalize the kernel?

`positive_attachments_normalize_original_kernel`

**Proof request**

Prove normalization of the original kernel under the positive-attachment assumptions.

**Reading the result**

The stated positivity assumptions make the weight normalization valid and give total one.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem positive_attachments_normalize_original_kernel (G : Geometry) (s : State)
    (t : ℝ) (rs : List (Fin 4 × Record)) (pos : ∀ i p, 0 < G.attach i p) :
    total (sourceKernel G t s rs) = 1 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationChallenge.lean#L63-L65) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationProofs.lean#L177-L194)

## What gives an actor positive sensitivity to the footprint?

`positive_attachments_see_a_marked_cell`

**Proof request**

Prove positive sensitivity at the marked footprint under the stated attachment hypotheses.

**Reading the result**

The stated positive attachments and marked cell give a strictly positive weighted reading.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem positive_attachments_see_a_marked_cell (G : Geometry) (s : State)
    (i : Actor) (L : Footprint) (x : Grid) (marked : L x = true)
    (pos : ∀ p, 0 < G.attach i p) : 0 < PaintCalibration.sensitivity G s i L := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationChallenge.lean#L67-L69) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationProofs.lean#L196-L205)

## How does the raw sensor respond as line height changes?

`original_readout_affine`

**Proof request**

Derive the affine dependence of the line reading on height.

**Reading the result**

Its reading is the background reading plus height times the fixed sensitivity.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem original_readout_affine (G : Geometry) (s : State) (i : Actor)
    (B : Scalar) (L : Footprint) (h : ℝ) :
    lineRead G s i (profile B L h) = lineRead G s i B + h * PaintCalibration.sensitivity G s i L := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationChallenge.lean#L71-L73) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationProofs.lean#L207-L223)

## How does the bounded sensor report that raw value?

`bounded_channel_for_profile`

**Proof request**

Give the exact bounded-sensor formula on the supplied line profile.

**Reading the result**

It applies tanh to the affine reading divided by 0.08.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem bounded_channel_for_profile (G : Geometry) (s : State) (i : Actor)
    (B : Scalar) (L : Footprint) (h : ℝ) :
    sensor G s i (profile B L h) =
      tanh ((lineRead G s i B + h * PaintCalibration.sensitivity G s i L) / 0.08) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationChallenge.lean#L75-L78) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationProofs.lean#L225-L230)

## What if an actor has zero sensitivity there?

`zero_sensitivity_erases_contrast`

**Proof request**

Prove equality of all height readings when the sensitivity is zero.

**Reading the result**

The sensor gives the same result for any two line heights.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem zero_sensitivity_erases_contrast (G : Geometry) (s : State) (i : Actor)
    (B : Scalar) (L : Footprint) (h k : ℝ) (blind : PaintCalibration.sensitivity G s i L = 0) :
    sensor G s i (profile B L h) = sensor G s i (profile B L k) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationChallenge.lean#L80-L82) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationProofs.lean#L232-L235)

## Can a calibrated reading recover the sign and height of the contrast?

`calibrated_sensor_recovers_signed_contrast`

**Proof request**

Invert the calibrated sensor to recover the signed contrast under its hypotheses.

**Reading the result**

Inverting tanh, subtracting the known background reading and dividing by nonzero sensitivity recovers h.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem calibrated_sensor_recovers_signed_contrast (G : Geometry) (s : State) (i : Actor)
    (B : Scalar) (L : Footprint) (h o : ℝ) (sees : PaintCalibration.sensitivity G s i L ≠ 0)
    (reading : sensor G s i (profile B L h) = o) :
    (0.04 * Real.log ((1+o)/(1-o)) - lineRead G s i B) / PaintCalibration.sensitivity G s i L = h := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationChallenge.lean#L84-L87) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationProofs.lean#L237-L244)

## Can two heights give the same exact calibrated reading?

`one_exact_reading_identifies_height`

**Proof request**

Prove uniqueness of height from one exact reading at nonzero sensitivity.

**Reading the result**

With fixed background and nonzero sensitivity, equality of readings implies equal heights.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem one_exact_reading_identifies_height (G : Geometry) (s : State) (i : Actor)
    (B : Scalar) (L : Footprint) (h k : ℝ) (sees : PaintCalibration.sensitivity G s i L ≠ 0)
    (same : sensor G s i (profile B L h) = sensor G s i (profile B L k)) :
    h = k := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationChallenge.lean#L89-L92) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationProofs.lean#L246-L253)

## Can the original force distinguish a field from its negative?

`opposite_fields_have_same_original_force`

**Proof request**

Show that opposite line fields give the same original force.

**Reading the result**

Reversing the field leaves the source’s force expression equal.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem opposite_fields_have_same_original_force (s : State) (f : Scalar) :
    forcing (withLineSignal s (fun x => -f x)) = forcing (withLineSignal s f) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationChallenge.lean#L94-L95) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-paint-value-lean/PaintCalibrationProofs.lean#L255-L271)
