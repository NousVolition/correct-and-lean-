# What changes when a line is painted in the street?

Compare painting the public field with changing one person’s context. At the edge of a painted band the force depends on a gradient and an activation threshold.

[`StreetWholeChallenge.lean`](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeChallenge.lean) · [Package configuration](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 NousVolition. All rights reserved. The repository notice applies to material for which NousVolition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeProofs.lean) · [StreetWholeDefinitions](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeDefinitions.lean) · [Statement and proof inputs](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/lake-manifest.json).

</details>

## What else changes when the street line is supplied to the whole model?

`full_input_keeps_all_other_coordinates`

**Proof request**

Identify the preserved fields and captures of a full-state line replacement.

**Reading the result**

The intervention replaces grid channel three. Restoring the original grid recovers the original state, and the saved captures agree.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_input_keeps_all_other_coordinates (y : FullState) (signal : Scalar) :
    (fullLineInput y signal).starts=y.starts ∧
    {(fullLineInput y signal).state with g := y.state.g}=y.state ∧
    (∀ x k, k≠3 → (fullLineInput y signal).state.g x k=y.state.g x k) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeChallenge.lean#L9-L12) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeProofs.lean#L53-L59)

## How does the line appear in a person’s observation?

`line_enters_original_observation`

**Proof request**

Recover the original observation of the substituted line field.

**Reading the result**

The first observation applies tanh to the weighted line reading divided by 0.08.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem line_enters_original_observation (G : Geometry) (s : State)
    (i : Actor) (signal : Scalar) :
    observations G (withLineSignal s signal) i 0=tanh (lineRead G s i signal/0.08) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeChallenge.lean#L14-L16) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeProofs.lean#L61-L64)

## Does repainting the line immediately change body or heat readings?

`line_keeps_body_and_heat_readings`

**Proof request**

Show that the other two observation channels agree.

**Reading the result**

Those two observation channels use other inputs, so their current values agree.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem line_keeps_body_and_heat_readings (G : Geometry) (s : State)
    (i : Actor) (signal : Scalar) :
    observations G (withLineSignal s signal) i 1=observations G s i 1 ∧
    observations G (withLineSignal s signal) i 2=observations G s i 2 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeChallenge.lean#L18-L21) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeProofs.lean#L66-L70)

## Can the paint alone rewrite or reweight an existing record?

`line_keeps_records_and_current_relevance`

**Proof request**

Show that both decoded records and current record weight agree for this line intervention.

**Reading the result**

Under this intervention the decoder and the current record-weight calculation give the original results.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem line_keeps_records_and_current_relevance (G : Geometry) (s : State)
    (signal : Scalar) (r : Record) :
    readRecords (withLineSignal s signal)=readRecords s ∧
    recordWeight G (withLineSignal s signal) r=recordWeight G s r := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeChallenge.lean#L23-L26) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeProofs.lean#L72-L76)

## Can repainting alone move the current guard margin?

`line_keeps_current_guard`

**Proof request**

Show that the current person-to-person guard margin agrees.

**Reading the result**

The fields determining the margin are preserved.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem line_keeps_current_guard (s : State) (signal : Scalar) (i j : Actor) :
    margin (withLineSignal s signal) i j=margin s i j := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeChallenge.lean#L28-L29) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeProofs.lean#L78-L80)

## What if the person’s context is shifted instead?

`personal_context_keeps_physical_state_and_records`

**Proof request**

Show that the personal-context shift preserves the listed physical observations and records.

**Reading the result**

Restoring context recovers the original state. The physical observations and decoded records already agree before restoration.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem personal_context_keeps_physical_state_and_records (G : Geometry)
    (s : State) (i : Actor) (h : ℝ) :
    {shiftPersonalContext s i h with context := s.context}=s ∧
    readRecords (shiftPersonalContext s i h)=readRecords s ∧
    observations G (shiftPersonalContext s i h)=observations G s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeChallenge.lean#L31-L35) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeProofs.lean#L82-L87)

## Does that shift change the person’s total context weight?

`personal_context_total_preserved`

**Proof request**

Preserve the sum of the selected person’s context coordinates.

**Reading the result**

Adding to one coordinate and subtracting from the other preserves the sum.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem personal_context_total_preserved (s : State) (i : Actor) (h : ℝ) :
    (∑ k, (shiftPersonalContext s i h).context i k)=∑ k, s.context i k := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeChallenge.lean#L37-L38) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeProofs.lean#L89-L92)

## How far can those weights be shifted safely?

`personal_context_stays_in_unit_interval`

**Proof request**

Bound both shifted coordinates in [0,1] under the supplied admissibility inequalities.

**Reading the result**

Within the stated room at the endpoints both resulting coordinates stay between zero and one.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem personal_context_stays_in_unit_interval (s : State) (i : Actor) (h : ℝ)
    (hzero : 0≤s.context i 0+h ∧ s.context i 0+h≤1)
    (hone : 0≤s.context i 1-h ∧ s.context i 1-h≤1) :
    ∀ k, 0≤(shiftPersonalContext s i h).context i k ∧
      (shiftPersonalContext s i h).context i k≤1 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeChallenge.lean#L40-L44) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeProofs.lean#L94-L102)

## How does shifting the recipient’s context move the retrieval cue?

`shifted_record_cue_coordinates`

**Proof request**

Compute the change of each cue coordinate for a shifted recipient.

**Reading the result**

The first cue difference falls by h/2, the second rises by h/2 and the third agrees under the listed participant condition.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem shifted_record_cue_coordinates (G : Geometry) (s : State) (r : Record)
    (hne : r.recipient≠r.origin) (h : ℝ) (k : Axis) :
    cueDifference G (shiftPersonalContext s r.recipient h) r k=
      cueDifference G s r k-(if k=0 then h/2 else if k=1 then -h/2 else 0) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeChallenge.lean#L46-L49) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeProofs.lean#L104-L109)

## What determines the original record weight?

`original_weight_uses_current_cue`

**Proof request**

Express record weight in terms of duration and squared current cue distance.

**Reading the result**

Its duration multiplies an exponential penalty for the squared distance between its features and the current cue.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem original_weight_uses_current_cue (G : Geometry) (s : State) (r : Record) :
    recordWeight G s r=(r.endTime-r.startTime)*
      Real.exp (-sqnorm (cueDifference G s r)/(2*0.32^2)) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeChallenge.lean#L51-L53) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeProofs.lean#L111-L114)

## What happens to a perfectly matched record after the specified shift?

`matched_record_weight_after_context_shift`

**Proof request**

Evaluate the matched record’s weight after the specified context shift.

**Reading the result**

The two half-shifts give squared distance h²/2, which determines the new exponential weight.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem matched_record_weight_after_context_shift (G : Geometry) (s : State) (r : Record)
    (hne : r.recipient≠r.origin) (matched : ∀ k, cueDifference G s r k=0) (h : ℝ) :
    recordWeight G (shiftPersonalContext s r.recipient h) r=
      (r.endTime-r.startTime)*Real.exp (-(h^2/2)/(2*0.32^2)) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeChallenge.lean#L55-L58) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeProofs.lean#L116-L124)

## Can a nonzero shift reduce relevance without erasing it?

`nonzero_context_shift_reduces_matched_weight`

**Proof request**

Prove a strict positive reweighting below the original matched weight.

**Reading the result**

For the matched positive-duration record the weight remains positive and becomes strictly smaller.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem nonzero_context_shift_reduces_matched_weight (G : Geometry) (s : State) (r : Record)
    (hne : r.recipient≠r.origin) (matched : ∀ k, cueDifference G s r k=0)
    (duration : r.startTime<r.endTime) (h : ℝ) (nonzero : h≠0) :
    0<recordWeight G (shiftPersonalContext s r.recipient h) r ∧
    recordWeight G (shiftPersonalContext s r.recipient h) r<recordWeight G s r := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeChallenge.lean#L60-L64) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeProofs.lean#L126-L143)

## How large can any record weight be relative to duration?

`record_weight_bounded_by_duration`

**Proof request**

Bound record weight between zero and its nonnegative duration.

**Reading the result**

For an ordered time interval the nonnegative exponential factor is at most one.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem record_weight_bounded_by_duration (G : Geometry) (s : State) (r : Record)
    (duration : r.startTime≤r.endTime) :
    0≤recordWeight G s r ∧ recordWeight G s r≤r.endTime-r.startTime := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeChallenge.lean#L66-L68) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeProofs.lean#L145-L155)

## Which couplings survive the full acceptance check?

`accepted_full_rhs_keeps_the_coupling`

**Proof request**

Extract the accumulator, field, expression and context couplings from an accepted full rate.

**Reading the result**

The decoded records supply the social rates, which drive A, while the public field combines transport with A times the source kernel.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem accepted_full_rhs_keeps_the_coupling (G : Geometry) (t : ℝ) (s d : State)
    (accepted : rhs G t s=some d) :
    ∃ records, readRecords s=some records ∧ d=rhsFromRecords G t s records ∧
      d.A=0.08*(socialRates G t s records).utility ∧
      (∀ x, d.g x 3=contextTransport (fun y => s.g y 3) (velocity s) x+
        s.A*sourceKernel G t s records x) ∧
      d.expression=(socialRates G t s records).expression ∧
      d.context=(socialRates G t s records).context := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeChallenge.lean#L70-L77) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeProofs.lean#L157-L174)

## How do street and experience enter guard relaxation?

`original_guard_rate_uses_line_observation_and_experience`

**Proof request**

Recover the exact guard-radius rate including the line and memory inputs.

**Reading the result**

The radius target combines the line observation with relationship, signed retrieval and responses, then relaxes toward its logarithm.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem original_guard_rate_uses_line_observation_and_experience
    (G : Geometry) (t : ℝ) (s : State) (records : List (Fin 4 × Record)) (i j : Actor) :
    (rhsFromRecords G t s records).logRadius i j=
      1.8*(Real.log (0.55+0.45*sigmoid
        (1.4*s.relation i j 2+memory G s records i j 0-memory G s records i j 1+
          s.responses i j 6-s.responses i j 4-0.3*observations G s i 0))-s.logRadius i j) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeChallenge.lean#L79-L84) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeProofs.lean#L176-L182)

## Can a uniform offset to paint change the gradient-driven force?

`constant_signal_shift_keeps_gradient_and_force`

**Proof request**

Prove invariance of the centered gradient and force under a constant line offset.

**Reading the result**

Centered differences cancel a constant offset, preserving both gradient and force.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem constant_signal_shift_keeps_gradient_and_force (s : State) (signal : Scalar)
    (h : ℝ) :
    centeredGradient (withLineSignal s (fun x => signal x+h))=
      centeredGradient (withLineSignal s signal) ∧
    forcing (withLineSignal s (fun x => signal x+h))=
      forcing (withLineSignal s signal) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeChallenge.lean#L86-L91) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeProofs.lean#L184-L197)

## What gradient does the example band have at its edge?

`band_edge_gradient`

**Proof request**

Compute the edge gradient in the explicit band.

**Reading the result**

Evaluating the neighboring cells gives eight times its height along the first axis and zero along the other two.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem band_edge_gradient (s : State) (height : ℝ) :
    centeredGradient (withLineSignal s (bandSignal height)) (testCell 7)=![8*height,0,0] := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeChallenge.lean#L93-L94) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeProofs.lean#L199-L202)

## Can a flat band center activate the force?

`band_center_does_not_activate`

**Proof request**

Evaluate the center force of the explicit band.

**Reading the result**

At the specified center the computed force vector is zero.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem band_center_does_not_activate (s : State) (height : ℝ) :
    forcing (withLineSignal s (bandSignal height)) (testCell 8)=![0,0,0] := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeChallenge.lean#L96-L97) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeProofs.lean#L204-L211)

## Is a band of height 1/1000 enough to activate the example edge?

`small_band_edge_is_off`

**Proof request**

Evaluate the edge force for height 1/1000.

**Reading the result**

Its gradient stays in the off branch and yields zero force.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem small_band_edge_is_off (s : State) :
    forcing (withLineSignal s (bandSignal (1/1000))) (testCell 7)=![0,0,0] := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeChallenge.lean#L99-L100) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeProofs.lean#L213-L217)

## What about a band of height 1/100?

`larger_band_edge_is_on`

**Proof request**

Prove a strictly negative first edge-force component for height 1/100.

**Reading the result**

At the same edge the first force coordinate is strictly negative.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem larger_band_edge_is_on (s : State) :
    forcing (withLineSignal s (bandSignal (1/100))) (testCell 7) 0<0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeChallenge.lean#L102-L103) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeProofs.lean#L219-L223)

## What can the person and street retain across an accepted record write?

`successful_write_preserves_person_and_line`

**Proof request**

Prove the listed state and line equalities and the write-work inequality across a successful write.

**Reading the result**

The listed personal fields, positions, fabric, accumulator and public line agree while accumulated write work can only increase or stay equal.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem successful_write_preserves_person_and_line (G : Geometry) (s w : State) (r : Record)
    (accepted : writeEvent G s r=some w) :
    w.expression=s.expression ∧ w.context=s.context ∧ w.normCenter=s.normCenter ∧
    w.logRadius=s.logRadius ∧ w.relation=s.relation ∧ w.responses=s.responses ∧
    w.association=s.association ∧ w.X=s.X ∧ w.F=s.F ∧ w.A=s.A ∧
    (∀ x, w.g x 3=s.g x 3) ∧ s.writeWork≤w.writeWork := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeChallenge.lean#L105-L110) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeProofs.lean#L225-L236)

## Can an episode be encoded as addressed to its own origin?

`self_addressed_episode_is_rejected`

**Proof request**

Prove rejection of an episode whose origin equals its recipient.

**Reading the result**

That payload fails the record validation rule.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem self_addressed_episode_is_rejected (r : Record) (self : r.origin=r.recipient) :
    payload r=none := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeChallenge.lean#L112-L113) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-street-whole-lean/StreetWholeProofs.lean#L238-L241)
