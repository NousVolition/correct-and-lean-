# Probes, encounter updates and delayed responses

Four namespaces ask about fabric probes, A/S bounds, events in a combined state and delay. Jump from a particular question to its own assumptions and proof.

[`GeminiChallenge.lean`](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean) · [Package configuration](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 NousVolition. All rights reserved. The repository notice applies to material for which NousVolition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project creator identifies the supplied material as coming through an audit in Codex. The source receipts identify the four attached Lean modules and their preserved copies. They establish the source files and the subsequent repairs. The earlier writer of each attachment is unspecified. [Original four attachments](https://github.com/NousVolition/hug-sims-lean-proofs/tree/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/originals) · [Attachment receipt](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/source-receipt.json) · [Audit and repairs](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/Lean-review.md).

The review names these independent research sources for the interpretation of perception and bracing. [Manassi and Whitney, Science Advances (2022)](https://doi.org/10.1126/sciadv.abk2480) · [Iwamoto, Nakahira and Sugiyama, ESV paper 11-0150 (2011)](https://www-nrd.nhtsa.dot.gov/departments/esv/22nd/files/22ESV-000150.pdf).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/AllGeminiProofs.lean) · [ASModel](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASModel.lean) · [V3EventSpecification](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/V3EventSpecification.lean) · [Package account](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/README.md) · [Statement and proof inputs](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/verification-inputs.json) · [Verification record](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/lake-manifest.json).

</details>

## Can two different probe loads recover the same rest strain?

`two_load_probe_recovers_rest_strain`

**Proof request**

Recover the rest strain by averaging the two nonzero-stiffness probe readings.

**Reading the result**

With nonzero stiffness each inferred value simplifies to the stored strain, so their average does too.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem two_load_probe_recovers_rest_strain (k e q b : ℝ) (hk : k ≠ 0) :
    (inferredRestStrain k (e - q) b + inferredRestStrain k (e + q) b) / 2 = b := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L41-L42) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/HugV3InterEventProofs.lean#L39-L43)

## How close can a perturbed cell stay without losing its bit?

`sign_constant_on_margin_ball`

**Proof request**

Preserve both strict well margin and sign within the specified perturbation ball.

**Reading the result**

Inside the stated margin ball its magnitude still clears the threshold and its sign agrees with the starting cell.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem sign_constant_on_margin_ball {a margin b₀ b : ℝ}
    (h₀ : StrictWellMargin a margin b₀)
    (hball : |b - b₀| < |b₀| - margin * a) :
    StrictWellMargin a margin b ∧ (0 < b ↔ 0 < b₀) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L50-L53) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/HugV3InterEventProofs.lean#L55-L80)

## Can this fabric term produce negative heat?

`fabric_heat_nonneg`

**Proof request**

Show that mobility times the squared fabric gradient is nonnegative.

**Reading the result**

It is a square multiplied by nonnegative mobility.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem fabric_heat_nonneg {mobility k wellHeight a e b : ℝ} (hmob : 0 ≤ mobility) :
    0 ≤ mobility * (fabricGradient k wellHeight a e b) ^ 2 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L64-L65) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/HugV3InterEventProofs.lean#L94-L96)

## How is traction related to the fabric gradient?

`traction_eq_neg_elastic_gradient`

**Proof request**

Rewrite traction as the well contribution minus the full fabric gradient.

**Reading the result**

Expanding the gradient isolates the elastic traction after accounting for the displayed well term.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem traction_eq_neg_elastic_gradient (k wellHeight a e b : ℝ) :
    traction k e b =
      wellHeight * b / (a ^ 2) * ((b / a) ^ 2 - 1) - fabricGradient k wellHeight a e b := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L67-L69) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/HugV3InterEventProofs.lean#L100-L104)

## How small can the power limiter’s denominator get?

`power_limiter_den_ge_floor`

**Proof request**

Bound the power-limiter denominator below by its floor.

**Reading the result**

Its construction gives the declared floor as a lower bound.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem power_limiter_den_ge_floor {powerFloor eta available rawpower : ℝ}
    (heta : 0 ≤ eta) (havail : 0 ≤ available) (hraw : 0 ≤ rawpower) :
    powerFloor ≤ powerLimiterDen powerFloor eta available rawpower := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L79-L81) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/HugV3InterEventProofs.lean#L116-L121)

## Is that denominator safe to divide by?

`power_limiter_den_pos`

**Proof request**

Prove strict positivity of the denominator under the given sign assumptions.

**Reading the result**

A strictly positive floor and the stated signs make it positive.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem power_limiter_den_pos {powerFloor eta available rawpower : ℝ}
    (hfloor : 0 < powerFloor) (heta : 0 ≤ eta) (havail : 0 ≤ available) (hraw : 0 ≤ rawpower) :
    0 < powerLimiterDen powerFloor eta available rawpower := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L83-L85) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/HugV3InterEventProofs.lean#L123-L126)

## Can the limiter give a value outside zero to one?

`power_limiter_in_unit_interval`

**Proof request**

Prove that the limiter lies in the unit interval.

**Reading the result**

Its numerator is nonnegative and bounded by its positive denominator.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem power_limiter_in_unit_interval {powerFloor eta available rawpower : ℝ}
    (hfloor : 0 < powerFloor) (heta : 0 ≤ eta) (havail : 0 ≤ available) (hraw : 0 ≤ rawpower) :
    0 ≤ powerLimiter powerFloor eta available rawpower ∧
    powerLimiter powerFloor eta available rawpower ≤ 1 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L87-L90) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/HugV3InterEventProofs.lean#L130-L151)

## Why does the three-image sum agree for opposite offsets?

`three_image_shifted_squares_even`

**Proof request**

Prove evenness of the sum over the three squared image offsets.

**Reading the result**

Changing the sign swaps the two outer squared arguments and leaves the middle one fixed.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem three_image_shifted_squares_even (f : ℝ → ℝ) (delta : ℝ) :
    f ((delta - 1) ^ 2) + f (delta ^ 2) + f ((delta + 1) ^ 2) =
    f (((-delta) - 1) ^ 2) + f ((-delta) ^ 2) + f (((-delta) + 1) ^ 2) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L92-L94) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/HugV3InterEventProofs.lean#L158-L165)

## Can the positive part of a number be negative?

`pos_nonneg`

**Proof request**

Show that the positive part is nonnegative.

**Reading the result**

Taking the maximum with zero guarantees a nonnegative result.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem pos_nonneg (x : ℝ) : 0 ≤ pos x := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L132) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L36-L37)

## Can taking a positive part make a number smaller?

`self_le_pos`

**Proof request**

Show that the positive part dominates the original input.

**Reading the result**

The maximum of the number and zero is at least the original number.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem self_le_pos (x : ℝ) : x ≤ pos x := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L134) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L39-L40)

## What happens to an already nonnegative number?

`pos_of_nonneg`

**Proof request**

Evaluate the positive part on nonnegative inputs.

**Reading the result**

Its positive part equals that number.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem pos_of_nonneg {x : ℝ} (hx : 0 ≤ x) : pos x = x := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L136) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L42-L43)

## What if the number is zero or negative?

`pos_of_nonpos`

**Proof request**

Evaluate the positive part on nonpositive inputs.

**Reading the result**

Its positive part is zero.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem pos_of_nonpos {x : ℝ} (hx : x ≤ 0) : pos x = 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L138) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L45-L46)

## Which value does the positive-part helper return throughout the nonpositive range?

`pos_eq_zero_of_nonpos`

**Proof request**

Show that every input at or below zero has positive part zero.

**Reading the result**

The zero branch applies even at the endpoint.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem pos_eq_zero_of_nonpos {x : ℝ} (hx : x ≤ 0) : pos x = 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L140) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L48-L49)

## Can taking positive parts increase the distance between two numbers?

`abs_pos_sub_pos_le`

**Proof request**

Bound the absolute difference of positive parts by the original distance.

**Reading the result**

Clipping both at zero can only shrink or preserve their absolute difference.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem abs_pos_sub_pos_le (x y : ℝ) : |pos x - pos y| ≤ |x - y| := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L142) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L51-L59)

## Which number represents a false indicator?

`indicator_false`

**Proof request**

Evaluate the indicator at false.

**Reading the result**

The definition selects zero.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem indicator_false : indicator false = 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L144) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L61)

## Which number represents a true indicator?

`indicator_true`

**Proof request**

Evaluate the indicator at true.

**Reading the result**

The definition selects one.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem indicator_true : indicator true = 1 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L146) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L63)

## Can the indicator escape the unit interval?

`indicator_unit`

**Proof request**

Prove the unit-interval bound for the Boolean indicator.

**Reading the result**

Its two possible values are exactly the endpoints.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem indicator_unit (b : Bool) : UnitInterval (indicator b) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L148) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L65-L66)

## Why is saturation nonnegative?

`saturation_nonneg`

**Proof request**

Prove nonnegativity of saturation for the stated load and scale.

**Reading the result**

With nonnegative load and positive scale its numerator and denominator have the required signs.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem saturation_nonneg {L scale : ℝ} (hL : 0 ≤ L) (hs : 0 < scale) :
    0 ≤ saturation L scale := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L150-L151) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L70-L73)

## How much room remains below saturation one?

`one_sub_saturation`

**Proof request**

Compute the exact complement of saturation under the nonzero-denominator hypothesis.

**Reading the result**

Putting the fractions over the same nonzero denominator leaves scale divided by load plus scale.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem one_sub_saturation {L scale : ℝ} (hne : L + scale ≠ 0) :
    1 - saturation L scale = scale / (L + scale) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L153-L154) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L75-L79)

## Could saturation exceed one?

`saturation_le_one`

**Proof request**

Bound saturation above by one.

**Reading the result**

The positive scale keeps a nonnegative load no larger than the denominator.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem saturation_le_one {L scale : ℝ} (hL : 0 ≤ L) (hs : 0 < scale) :
    saturation L scale ≤ 1 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L156-L157) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L81-L88)

## Where can the saturation value lie?

`saturation_unit`

**Proof request**

Combine the saturation bounds into unit-interval membership.

**Reading the result**

Combining the lower and upper bounds places it in the unit interval.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem saturation_unit {L scale : ℝ} (hL : 0 ≤ L) (hs : 0 < scale) :
    UnitInterval (saturation L scale) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L159-L160) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L90-L92)

## Does applying a bounded gain preserve that range?

`effect_unit`

**Proof request**

Prove unit-interval membership of the gain-adjusted effect.

**Reading the result**

Multiplying the unit-interval saturation by a unit-interval gain produces another value in the interval.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem effect_unit {gain L scale : ℝ} (hg : UnitInterval gain)
    (hL : 0 ≤ L) (hs : 0 < scale) :
    UnitInterval (effect gain L scale) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L162-L164) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L94-L102)

## How is forward chi bounded?

`chiForward_unit`

**Proof request**

Bound forward chi in the unit interval.

**Reading the result**

Substituting its forward inputs into the effect bound puts it in [0,1].

<details>
<summary>Exact Lean statement</summary>

```lean
theorem chiForward_unit {p : Parameters} {x : State}
    (hp : ParametersOK p) (hx : StateOK x) :
    UnitInterval (chiForward p x) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L166-L168) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L104-L109)

## How is reverse chi bounded?

`chiReverse_unit`

**Proof request**

Bound reverse chi in the unit interval.

**Reading the result**

Its reverse inputs satisfy the same effect bound under the stated conditions.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem chiReverse_unit {p : Parameters} {x : State}
    (hp : ParametersOK p) (hx : StateOK x) :
    UnitInterval (chiReverse p x) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L170-L172) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L111-L116)

## Can forward theta exceed its permitted range?

`thetaForward_unit`

**Proof request**

Bound forward theta in the unit interval.

**Reading the result**

Its defining gain and saturation obey the unit-interval conditions.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem thetaForward_unit {p : Parameters} {x : State}
    (hp : ParametersOK p) (hx : StateOK x) :
    UnitInterval (thetaForward p x) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L174-L176) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L118-L123)

## What range does reverse theta occupy?

`thetaReverse_unit`

**Proof request**

Bound reverse theta in the unit interval.

**Reading the result**

Applying the same unit-interval estimate to the reverse inputs bounds it too.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem thetaReverse_unit {p : Parameters} {x : State}
    (hp : ParametersOK p) (hx : StateOK x) :
    UnitInterval (thetaReverse p x) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L178-L180) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L125-L130)

## How does saturation respond to two different loads?

`saturation_sub_identity`

**Proof request**

Derive the exact difference of saturation values for two loads.

**Reading the result**

Subtracting the fractions leaves the scale times their difference over the product of their denominators.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem saturation_sub_identity {L₁ L₂ scale : ℝ}
    (h₁ : L₁ + scale ≠ 0) (h₂ : L₂ + scale ≠ 0) :
    saturation L₁ scale - saturation L₂ scale =
      scale * (L₁ - L₂) / ((L₁ + scale) * (L₂ + scale)) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L182-L185) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L132-L138)

## How sensitive is saturation to a change of load?

`saturation_lipschitz`

**Proof request**

Bound the change of saturation by the input difference divided by scale.

**Reading the result**

For the stated nonnegative loads the denominator bounds limit the change to the load difference divided by the scale.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem saturation_lipschitz {L₁ L₂ scale : ℝ}
    (hL₁ : 0 ≤ L₁) (hL₂ : 0 ≤ L₂) (hs : 0 < scale) :
    |saturation L₁ scale - saturation L₂ scale| ≤ |L₁ - L₂| / scale := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L187-L189) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L140-L160)

## Which drift does index zero select?

`generalSDrift_zero`

**Proof request**

Identify the Smoke drift at index zero.

**Reading the result**

Evaluating the general equation at zero gives the Smoke drift.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem generalSDrift_zero (p : Parameters) (x : State) :
    generalSDrift p x 0 = smokeDrift p x := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L191-L192) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L164-L166)

## Which drift does index one select?

`generalSDrift_one`

**Proof request**

Identify the Clay drift at index one.

**Reading the result**

Evaluating it at one gives the Clay drift.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem generalSDrift_one (p : Parameters) (x : State) :
    generalSDrift p x 1 = clayDrift p x := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L194-L195) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L168-L170)

## What accounts for the combined Smoke and Clay drift?

`total_S_drift_balance`

**Proof request**

Derive the total two-coordinate drift balance.

**Reading the result**

Adding their equations leaves both directed exchange terms, the source and decay of their combined level.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem total_S_drift_balance (p : Parameters) (x : State)
    (hK : p.KSmoke + p.KClay = 1) :
    smokeDrift p x + clayDrift p x =
      exchange p.wSmokeClay (chiReverse p x) (x 2 - x 1) +
      exchange p.wClaySmoke (chiForward p x) (x 1 - x 2) +
      source p x - p.decay * (x 1 + x 2) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L197-L202) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L172-L179)

## How much can exchange change when only the gap varies?

`exchange_lipschitz_in_gap`

**Proof request**

Bound exchange variation by w times the change in the gap.

**Reading the result**

Under the given gating and weight bounds, the output difference is at most w times the gap difference.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem exchange_lipschitz_in_gap {w chi : ℝ} (hw : 0 ≤ w) (hchi : UnitInterval chi)
    (g₁ g₂ : ℝ) :
    |exchange w chi g₁ - exchange w chi g₂| ≤ w * |g₁ - g₂| := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L204-L206) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L181-L204)

## Can a zero load decrease?

`loadDrift_nonneg_at_zero`

**Proof request**

Prove nonnegativity of load drift at zero.

**Reading the result**

At zero the clearing term disappears and the admitted exposure contributes a nonnegative amount.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem loadDrift_nonneg_at_zero {alpha exposure clear : ℝ} (h : Bool)
    (halpha : 0 ≤ alpha) (hexp : 0 ≤ exposure) :
    0 ≤ loadDrift alpha h exposure clear 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L208-L210) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L208-L212)

## What is the exact drift difference for two load levels?

`loadDrift_lipschitz_in_L`

**Proof request**

Compute the drift difference at two loads with the same exposure.

**Reading the result**

The shared exposure cancels, leaving minus the clearing coefficient times the load difference.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem loadDrift_lipschitz_in_L (alpha : ℝ) (h : Bool) (exposure clear L₁ L₂ : ℝ) :
    loadDrift alpha h exposure clear L₁ - loadDrift alpha h exposure clear L₂ =
      -clear * (L₁ - L₂) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L212-L214) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L214-L218)

## Can blended meaning fall outside the range of admissible meanings?

`receivedMeaning_unit`

**Proof request**

Prove that the received meaning is in the unit interval.

**Reading the result**

Its bounded mixing weight gives a value between zero and one.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem receivedMeaning_unit {theta z imposed : ℝ}
    (htheta : UnitInterval theta) (hz : UnitInterval z) (himp : UnitInterval imposed) :
    UnitInterval (receivedMeaning theta z imposed) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L216-L218) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L220-L227)

## Can the meaning rate have a negative sign?

`meaningRate_nonneg`

**Proof request**

Prove nonnegativity of the meaning rate.

**Reading the result**

The specified nonnegative inputs give nonnegative factors in the rate.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem meaningRate_nonneg {w chi S scale : ℝ}
    (hw : 0 ≤ w) (hchi : UnitInterval chi) (hs : 0 < scale) :
    0 ≤ meaningRate w chi S scale := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L220-L222) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L229-L236)

## Which way does the meaning drift point at zero?

`meaningDrift_nonneg_at_zero`

**Proof request**

Prove the lower-endpoint sign bound on meaning drift.

**Reading the result**

With admissible received and reference values the drift there is nonnegative.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem meaningDrift_nonneg_at_zero {rate received clarify reference : ℝ}
    (hrate : 0 ≤ rate) (hrec : UnitInterval received)
    (hclar : 0 ≤ clarify) (href : UnitInterval reference) :
    0 ≤ meaningDrift rate received 0 clarify reference := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L224-L227) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L238-L245)

## Which way does it point at one?

`meaningDrift_nonpos_at_one`

**Proof request**

Prove the upper-endpoint sign bound on meaning drift.

**Reading the result**

The endpoint differences and sign conditions give a nonpositive drift there.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem meaningDrift_nonpos_at_one {rate received clarify reference : ℝ}
    (hrate : 0 ≤ rate) (hrec : UnitInterval received)
    (hclar : 0 ≤ clarify) (href : UnitInterval reference) :
    meaningDrift rate received 1 clarify reference ≤ 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L229-L232) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L247-L254)

## Can the Smoke meaning drift point below the lower boundary?

`smokeMeaningDrift_nonneg_at_zero`

**Proof request**

Verify the lower-endpoint drift condition for Smoke.

**Reading the result**

At Smoke meaning zero the general lower-bound argument applies to its actual inputs.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem smokeMeaningDrift_nonneg_at_zero {p : Parameters} {i : Inputs} {x : State}
    (hp : ParametersOK p) (hi : InputsOK i) (hx : StateOK x) (hx5 : x 5 = 0) :
    0 ≤ smokeMeaningDrift p i x := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L234-L236) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L256-L269)

## Can Smoke’s drift point above the upper boundary?

`smokeMeaningDrift_nonpos_at_one`

**Proof request**

Verify the upper-endpoint drift condition for Smoke.

**Reading the result**

At Smoke meaning one the upper-bound argument gives a nonpositive rate.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem smokeMeaningDrift_nonpos_at_one {p : Parameters} {i : Inputs} {x : State}
    (hp : ParametersOK p) (hi : InputsOK i) (hx : StateOK x) (hx5 : x 5 = 1) :
    smokeMeaningDrift p i x ≤ 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L238-L240) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L271-L284)

## Can Clay’s meaning drift point down from zero?

`clayMeaningDrift_nonneg_at_zero`

**Proof request**

Verify the lower-endpoint drift condition for Clay.

**Reading the result**

Its own admissible inputs meet the lower-bound conditions.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem clayMeaningDrift_nonneg_at_zero {p : Parameters} {i : Inputs} {x : State}
    (hp : ParametersOK p) (hi : InputsOK i) (hx : StateOK x) (hx6 : x 6 = 0) :
    0 ≤ clayMeaningDrift p i x := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L242-L244) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L286-L299)

## Can Clay’s meaning drift point up from one?

`clayMeaningDrift_nonpos_at_one`

**Proof request**

Verify the upper-endpoint drift condition for Clay.

**Reading the result**

Its own inputs meet the upper-bound conditions.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem clayMeaningDrift_nonpos_at_one {p : Parameters} {i : Inputs} {x : State}
    (hp : ParametersOK p) (hi : InputsOK i) (hx : StateOK x) (hx6 : x 6 = 1) :
    clayMeaningDrift p i x ≤ 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L246-L248) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L301-L314)

## What range does the opening weight occupy?

`opening_unit`

**Proof request**

Show that opening is in [0,1] for the given inputs.

**Reading the result**

The given gain and probability bounds place it in [0,1].

<details>
<summary>Exact Lean statement</summary>

```lean
theorem opening_unit {g p0 r rStar : ℝ}
    (hg : UnitInterval g) (hp0 : UnitInterval p0) (hr : 0 ≤ r) (hrStar : 0 < rStar) :
    UnitInterval (opening g p0 r rStar) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L250-L252) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L318-L335)

## What range does the registration weight occupy?

`registration_unit`

**Proof request**

Show that registration is in [0,1] for the given inputs.

**Reading the result**

Its factors preserve the unit interval under the stated conditions.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem registration_unit {eta z challenge : ℝ}
    (heta : UnitInterval eta) (hz : UnitInterval z) (hch : UnitInterval challenge) :
    UnitInterval (registration eta z challenge) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L254-L256) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L337-L350)

## Does switching registration on or off preserve that bound?

`conditionalRegistration_unit`

**Proof request**

Show that conditional registration stays in [0,1] in both branches.

**Reading the result**

The closed branch returns zero and the open branch uses the bounded registration.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem conditionalRegistration_unit {eta z challenge : ℝ} (B : Bool)
    (heta : UnitInterval eta) (hz : UnitInterval z) (hch : UnitInterval challenge) :
    UnitInterval (conditionalRegistration eta z challenge B) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L258-L260) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L352-L358)

## Can any of the three branch weights be negative?

`branches_nonneg`

**Proof request**

Prove nonnegativity of each encounter branch weight.

**Reading the result**

Each is assembled from admissible probabilities and their complements.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem branches_nonneg {p q : ℝ} (hp : UnitInterval p) (hq : UnitInterval q) :
    ∀ k : Fin 3, 0 ≤ branches p q k := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L262-L263) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L360-L365)

## Do the three branch weights exhaust the total?

`branches_sum_eq_one`

**Proof request**

Prove that all three branch weights sum to one.

**Reading the result**

Expanding the three expressions gives a sum of one.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem branches_sum_eq_one (p q : ℝ) :
    (∑ k : Fin 3, branches p q k) = 1 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L265-L266) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L367-L370)

## What does the update do when its condition is false?

`update_false_eq_self`

**Proof request**

Show that a skipped update returns the previous meaning.

**Reading the result**

The false branch returns the previous meaning.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem update_false_eq_self (beta : ℝ) (H M : Meaning) :
    update beta false H M = H := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L268-L269) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L372-L375)

## Do meaning probabilities still form a distribution after an update?

`update_preserves_simplex`

**Proof request**

Show that the update preserves the simplex of distributions.

**Reading the result**

Skipping the update preserves the distribution, while an admissible blend preserves its total and nonnegativity.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem update_preserves_simplex {beta : ℝ} (C : Bool) {H M : Meaning}
    (hbeta : UnitInterval beta) (hH : Simplex H) (hM : Simplex M) :
    Simplex (update beta C H M) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L271-L273) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L377-L396)

## Can two integral solutions disagree on the accumulator at the chosen time?

`integralSolution_unique_A`

**Proof request**

Prove equality of the accumulator coordinate for the two given integral solutions.

**Reading the result**

They start together and the accumulator integrates the same input, so that coordinate agrees.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem integralSolution_unique_A {p : Parameters} {i : ℝ → Inputs} {t0 T : ℝ}
    {initial : State} {x y : ℝ → State}
    (hx : IntegralSolution p i t0 T initial x)
    (hy : IntegralSolution p i t0 T initial y)
    {t : ℝ} (ht : t ∈ Icc t0 T) :
    x t 0 = y t 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L275-L280) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L403-L410)

## How can you compute the difference between two solution coordinates?

`integralSolution_sub_eq`

**Proof request**

Express the difference of two solution coordinates as the integral of their drift difference.

**Reading the result**

Subtract their integral equations. The common initial value cancels, leaving the integral of the drift difference.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem integralSolution_sub_eq {p : Parameters} {i : ℝ → Inputs} {t0 T : ℝ}
    {initial : State} {x y : ℝ → State}
    (hx : IntegralSolution p i t0 T initial x)
    (hy : IntegralSolution p i t0 T initial y)
    (j : Fin 7) {t : ℝ} (ht : t ∈ Icc t0 T) :
    x t j - y t j =
      ∫ s in t0..t, (evolution p (i s) (x s) j - evolution p (i s) (y s) j) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L282-L288) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L414-L427)

## When does equality of the drifts force a coordinate match?

`integralSolution_coord_unique_of_drift_eq`

**Proof request**

Deduce coordinate agreement when the drifts agree over the stipulated interval.

**Reading the result**

With common initial data the integral of their zero difference is zero.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem integralSolution_coord_unique_of_drift_eq {p : Parameters} {i : ℝ → Inputs} {t0 T : ℝ}
    {initial : State} {x y : ℝ → State}
    (hx : IntegralSolution p i t0 T initial x)
    (hy : IntegralSolution p i t0 T initial y)
    (j : Fin 7)
    (hdrift : ∀ s, evolution p (i s) (x s) j = evolution p (i s) (y s) j)
    {t : ℝ} (ht : t ∈ Icc t0 T) :
    x t j = y t j := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L290-L297) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/ASProofs.lean#L430-L442)

## Is the combined state’s product representation continuous?

`continuous_toProd`

**Proof request**

Prove continuity of the combined-to-product map.

**Reading the result**

The topology on the combined state is built from that representation.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem continuous_toProd : Continuous CombinedState.toProd := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L375) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/CombinedASHugProofs.lean#L77-L78)

## Can one read the A/S component continuously from the combined state?

`continuous_asState`

**Proof request**

Prove continuity of the A/S state projection.

**Reading the result**

The corresponding product projection is continuous.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem continuous_asState : Continuous CombinedState.asState := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L377) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/CombinedASHugProofs.lean#L80-L81)

## What about reading the meaning distribution?

`continuous_meaningDist`

**Proof request**

Prove continuity of the meaning-distribution projection.

**Reading the result**

It too is a continuous projection of the combined state coordinates.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem continuous_meaningDist : Continuous CombinedState.meaningDist := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L379) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/CombinedASHugProofs.lean#L83-L84)

## Can one read the fabric coordinate continuously?

`continuous_fabricCoord`

**Proof request**

Prove continuity of the fabric-coordinate projection.

**Reading the result**

The product-coordinate projection gives continuity of this readout.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem continuous_fabricCoord : Continuous CombinedState.fabricCoord := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L381) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/CombinedASHugProofs.lean#L86-L87)

## What does a nonzero-stiffness probe recover?

`combined_probe_recovers_rest_strain`

**Proof request**

Prove exact recovery of rest strain by the combined probe.

**Reading the result**

Cancelling the stiffness in the inference formula returns the stored rest strain.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem combined_probe_recovers_rest_strain (k load b : ℝ) (hk : k ≠ 0) :
    inferredRestStrain k load b = b := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L400-L401) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/CombinedASHugProofs.lean#L108-L112)

## Does probing an encoded bit recover its written level?

`combined_probe_recovers_written_bit`

**Proof request**

Prove exact recovery of a freshly encoded bit level by the probe.

**Reading the result**

Applying the rest-strain identity to the written coordinate returns that exact value.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem combined_probe_recovers_written_bit (k load a : ℝ) (bit : Bool) (hk : k ≠ 0) :
    inferredRestStrain k load (writtenBit a bit) = writtenBit a bit := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L403-L404) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/CombinedASHugProofs.lean#L114-L116)

## What is the magnitude of a written bit?

`abs_writtenBit_eq`

**Proof request**

Compute the absolute value of either signed written level.

**Reading the result**

The two signs both have magnitude a when a is positive.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem abs_writtenBit_eq {a : ℝ} (ha : 0 < a) (bit : Bool) :
    |writtenBit a bit| = a := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L406-L407) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/CombinedASHugProofs.lean#L118-L124)

## Does a newly written bit clear the specified well margin?

`written_bit_satisfies_well_margin`

**Proof request**

Check the well-margin bound for a newly written bit.

**Reading the result**

Its magnitude is a, which meets the stated fractional margin bound.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem written_bit_satisfies_well_margin {a margin : ℝ}
    (ha : 0 < a) (hmargin : margin ≤ 1) (bit : Bool) :
    margin * a ≤ |writtenBit a bit| := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L409-L411) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/CombinedASHugProofs.lean#L126-L130)

## How low can the combined model’s positive-part input go?

`pos_nonneg`

**Proof request**

Prove nonnegativity of the positive part in the combined module.

**Reading the result**

Taking its positive part bounds it below by zero.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem pos_nonneg (x : ℝ) : 0 ≤ pos x := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L413) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/CombinedASHugProofs.lean#L134-L135)

## Can a combined-model Boolean indicator exceed one?

`indicator_unit`

**Proof request**

Verify that its Boolean indicators lie in [0,1].

**Reading the result**

Its two branches give zero and one.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem indicator_unit (b : Bool) : UnitInterval (indicator b) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L415) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/CombinedASHugProofs.lean#L137-L138)

## Can Clay’s opportunity activation become negative?

`clay_opportunity_nonneg`

**Proof request**

Show that the actual Clay opportunity activation is nonnegative.

**Reading the result**

The activation and permitted gain give a nonnegative opportunity value.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem clay_opportunity_nonneg {p : Parameters} (hp : ParametersOK p) (x : SocialAS.State) :
    0 ≤ opportunityActivation p.g (activation (x 2) p.threshold) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L417-L418) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/CombinedASHugProofs.lean#L140-L144)

## How large is the opening in a valid Clay encounter?

`clay_opening_unit`

**Proof request**

Show that the actual Clay opening probability is admissible.

**Reading the result**

Substituting its admissible opportunity and parameter values gives a unit-interval opening.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem clay_opening_unit {p : Parameters} (hp : ParametersOK p) (x : SocialAS.State) :
    UnitInterval (opening p.g p.p0
      (opportunityActivation p.g (activation (x 2) p.threshold)) p.rStar) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L420-L422) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/CombinedASHugProofs.lean#L146-L173)

## Where does Smoke’s conditional registration land?

`smoke_conditionalRegistration_unit`

**Proof request**

Check the unit-interval bound for Smoke’s conditional registration.

**Reading the result**

The bounds on Smoke’s meaning, the challenge and the parameters apply in either branch.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem smoke_conditionalRegistration_unit {p : Parameters} {x : SocialAS.State}
    {challenge : ℝ} (B : Bool)
    (hp : ParametersOK p) (hx : StateOK x) (hch : UnitInterval challenge) :
    UnitInterval (conditionalRegistration p.eta (x 5) challenge B) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L424-L427) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/CombinedASHugProofs.lean#L175-L194)

## Are the actual three Clay-encounter weights a distribution?

`clay_encounter_branches_simplex`

**Proof request**

Use those bounds to prove the three encounter weights form a distribution.

**Reading the result**

Its opening and registration meet the branch bounds, giving nonnegative weights summing to one.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem clay_encounter_branches_simplex {p : Parameters} {x : SocialAS.State}
    {challenge : ℝ} (B : Bool)
    (hp : ParametersOK p) (hx : StateOK x) (hch : UnitInterval challenge) :
    let p_open := opening p.g p.p0
      (opportunityActivation p.g (activation (x 2) p.threshold)) p.rStar
    let q_reg := conditionalRegistration p.eta (x 5) challenge B
    (∀ k : Fin 3, 0 ≤ branches p_open q_reg k) ∧
    (∑ k : Fin 3, branches p_open q_reg k) = 1 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L429-L436) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/CombinedASHugProofs.lean#L196-L211)

## Can the combined update preserve the meaning simplex?

`update_preserves_simplex`

**Proof request**

Prove simplex preservation for the combined encounter update.

**Reading the result**

With admissible mixing and two valid input distributions its selected branch produces another distribution.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem update_preserves_simplex {beta : ℝ} (C : Bool) {H M : SocialAS.Meaning}
    (hbeta : UnitInterval beta) (hH : Simplex H) (hM : Simplex M) :
    Simplex (update beta C H M) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L438-L440) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/CombinedASHugProofs.lean#L215-L233)

## Can an encounter preserve validity and still cause a jump?

`combined_event_preserves_valid_and_jumps`

**Proof request**

Verify post-event validity and a strict fabric-coordinate jump from the admissible empty state.

**Reading the result**

The admitted event writes a positive bit into a valid empty coordinate, giving a different fabric value while meeting the post-event bounds.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem combined_event_preserves_valid_and_jumps
    {p : Parameters} {s : CombinedState} {M : SocialAS.Meaning}
    {a margin : ℝ} (C : Bool)
    (hp : ParametersOK p)
    (hstate : StateOK s.asState)
    (hH : Simplex s.meaningDist)
    (hM : Simplex M)
    (hempty : ValidEmptyCoordinate a margin s.fabricCoord)
    (hmargin_le : margin ≤ 1) :
    let s_post := applyEncounterEvent p.beta C M a true s
    CombinedValid a margin s_post ∧ s_post.fabricCoord ≠ s.fabricCoord := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L442-L452) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/CombinedASHugProofs.lean#L235-L256)

## Can the social path be continuous when the whole path jumps?

`combined_trajectory_continuous_AS_but_discontinuous_full`

**Proof request**

Prove continuity of the social projection on the interval and discontinuity of the full path at the witnessed event.

**Reading the result**

The integral solution gives continuity of its A/S projection. The witnessed fabric jump prevents continuity of the full state at that event.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem combined_trajectory_continuous_AS_but_discontinuous_full
    (p : Parameters) (i : ℝ → Inputs) (t0 T : ℝ) (initial : SocialAS.State)
    (path : ℝ → CombinedState)
    (hint : IntegralSolution p i t0 T initial (CombinedState.asState ∘ path))
    (eventTime before a : ℝ)
    (hwitness : EventWitness (CombinedState.fabricCoord ∘ path) eventTime before a) :
    ContinuousOn (CombinedState.asState ∘ path) (Icc t0 T) ∧
    ¬ ContinuousAt path eventTime := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L454-L461) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/CombinedASHugProofs.lean#L264-L284)

## When do two paths give the same event output and bit reading?

`combined_hybrid_uniqueness_transfer`

**Proof request**

Use the matching pre-event states to compare the updates and recover their written bit reading.

**Reading the result**

With the assumed equality of their pre-event states the deterministic update agrees, and the nonzero-stiffness probe reads the written bit.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem combined_hybrid_uniqueness_transfer
    {p : Parameters} {i : ℝ → Inputs} {t0 T : ℝ} {initial : SocialAS.State}
    {path₁ path₂ : ℝ → CombinedState}
    (h₁ : IntegralSolution p i t0 T initial (CombinedState.asState ∘ path₁))
    (h₂ : IntegralSolution p i t0 T initial (CombinedState.asState ∘ path₂))
    {eventTime : ℝ} (ht : eventTime ∈ Icc t0 T)
    (hpre_eq : path₁ eventTime = path₂ eventTime)
    (C : Bool) (M : SocialAS.Meaning) (a k load : ℝ) (bit : Bool) (hk : k ≠ 0) :
    (path₁ eventTime).asState 0 = (path₂ eventTime).asState 0 ∧
    applyEncounterEvent p.beta C M a bit (path₁ eventTime) =
      applyEncounterEvent p.beta C M a bit (path₂ eventTime) ∧
    inferredRestStrain k load
      (applyEncounterEvent p.beta C M a bit (path₁ eventTime)).fabricCoord =
      writtenBit a bit := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L463-L476) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/CombinedASHugProofs.lean#L292-L312)

## Where does a delay look during the first step?

`sub_tau_mem_history_window`

**Proof request**

Place the lagged time inside the supplied initial-history interval.

**Reading the result**

With the stated time bounds, subtracting tau places the lookup inside the supplied history window.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem sub_tau_mem_history_window {t0 tau t s : ℝ}
    (ht : t ∈ Icc t0 (t0 + tau)) (hs : s ∈ uIcc t0 t) :
    s - tau ∈ Icc (t0 - tau) t0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L563-L565) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/DelayedReflexASProofs.lean#L86-L92)

## What gives coordinate agreement on the delay step?

`delayedSolution_unique_on_step`

**Proof request**

Prove the specified coordinate agreement on the delayed step.

**Reading the result**

For the two stipulated solutions the matching history and inputs make the delayed-coordinate integrals agree.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem delayedSolution_unique_on_step
    {p : Parameters} {i : ℝ → Inputs} {t0 tau : ℝ}
    {history : ℝ → State} {x y : ℝ → State}
    (hx : DelayedIntegralSolution p i t0 tau history x)
    (hy : DelayedIntegralSolution p i t0 tau history y)
    (j : Fin 7) {t : ℝ} (ht : t ∈ Icc t0 (t0 + tau)) :
    x t j = y t j := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L567-L573) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/DelayedReflexASProofs.lean#L99-L114)

## Is there a time when the reflex has acted but the registration lookup still predates the hazard?

`reflex_acts_before_conscious_registration`

**Proof request**

Derive the ordering of hazard time, spinal response, current time and lagged sample.

**Reading the result**

The stated inequalities place t after the spinal response and its lagged sample before the hazard.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem reflex_acts_before_conscious_registration
    {t_haz tau_spinal tau_lag t : ℝ}
    (h_spinal_pos : 0 < tau_spinal)
    (h_faster : tau_spinal < tau_lag)
    (ht : t ∈ Ico (t_haz + tau_spinal) (t_haz + tau_lag)) :
    t_haz < t_haz + tau_spinal ∧
    t_haz + tau_spinal ≤ t ∧
    t - tau_lag < t_haz := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L575-L582) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/DelayedReflexASProofs.lean#L126-L135)

## Can the faster modeled reflex beat the cut distance?

`faster_reflex_prevents_cut`

**Proof request**

Show that traveled distance under the new delay is below both the cut threshold and the old distance.

**Reading the result**

Under the speed, delay and threshold assumptions, its travel distance is below the cut threshold and below the old distance.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem faster_reflex_prevents_cut
    {v_hazard tau_new tau_old d_cut : ℝ}
    (hv : 0 < v_hazard)
    (h_speedup : tau_new < tau_old)
    (h_safe : v_hazard * tau_new < d_cut)
    (h_old_cut : d_cut ≤ v_hazard * tau_old) :
    v_hazard * tau_new < d_cut ∧ v_hazard * tau_new < v_hazard * tau_old := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L584-L590) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/DelayedReflexASProofs.lean#L142-L149)

## How does the brace change peak traction in this model?

`unbraced_peak_stress_lt_braced`

**Proof request**

Compare the two traction values for positive brace effect and load above rest.

**Reading the result**

Under the specified positive stiffness and load-gap conditions the braced case has greater traction.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem unbraced_peak_stress_lt_braced
    {k0 kBrace brace load b : ℝ}
    (hkBrace : 0 < kBrace) (hbrace : 0 < brace) (hstrain : b < load) :
    impactTraction k0 kBrace 0 load b < impactTraction k0 kBrace brace load b := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L592-L595) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/DelayedReflexASProofs.lean#L157-L167)

## When do the two cases fall on opposite sides of the critical stress?

`unbraced_survives_crash_window`

**Proof request**

Verify that the stated critical stress separates the braced and unbraced model values.

**Reading the result**

The displayed threshold window places unbraced traction below it and braced traction at or above it.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem unbraced_survives_crash_window
    {k0 kBrace brace load b stress_crit : ℝ}
    (h_unbraced : k0 * (load - b) < stress_crit)
    (h_braced : stress_crit ≤ (k0 + kBrace * brace) * (load - b)) :
    impactTraction k0 kBrace 0 load b < stress_crit ∧
    stress_crit ≤ impactTraction k0 kBrace brace load b := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L597-L602) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/DelayedReflexASProofs.lean#L174-L181)

## Can two distinct empty coordinates lead to the same written bit?

`mirror_write_is_many_to_one`

**Proof request**

Construct two different valid empty coordinates with the common positive write level.

**Reading the result**

The two negative starting levels satisfy the empty-coordinate rules and writing true selects the common level a.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem mirror_write_is_many_to_one {a margin : ℝ} (ha : 0 < a) (hm : 0 < margin) :
    let b₁ := -(margin * a)
    let b₂ := -(2 * margin * a)
    ValidEmptyCoordinate a margin b₁ ∧
    ValidEmptyCoordinate a margin b₂ ∧
    b₁ ≠ b₂ ∧
    writtenBit a true = a := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/GeminiChallenge.lean#L604-L610) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-gemini-review/DelayedReflexASProofs.lean#L191-L202)
