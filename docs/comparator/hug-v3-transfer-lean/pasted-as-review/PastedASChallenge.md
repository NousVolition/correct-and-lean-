# The separate A/S review in the transfer folder

This review has its own Comparator configuration. Its 44 statements revisit clipping, saturation, encounter weights and coordinate-wise agreement of integral solutions.

[`PastedASChallenge.lean`](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean) · [Package configuration](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/comparator.json) · [Sources and credits](../../CREDITS.md) · [All challenge files](../../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 Nous Volition. All rights reserved. The repository notice applies to material for which Nous Volition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The audit cites a pasted A/S source file, records its digest, and identifies the later repair. The earlier attachment writer is unspecified. [Supplied file](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASProofs.lean) · [Source receipt](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/source-receipt.json) · [Repair record](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/repair-receipt.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean) · [ASModel](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/ASModel.lean) · [Statement and proof inputs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/verification-inputs.json) · [Pinned libraries](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/lake-manifest.json).

</details>

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L8) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L36-L37)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L10) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L39-L40)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L12) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L42-L43)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L14) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L45-L46)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L16) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L48-L49)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L18) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L51-L59)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L20) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L61)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L22) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L63)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L24) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L65-L66)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L26-L27) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L70-L73)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L29-L30) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L75-L79)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L32-L33) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L81-L88)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L35-L36) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L90-L92)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L38-L40) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L94-L102)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L42-L44) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L104-L109)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L46-L48) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L111-L116)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L50-L52) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L118-L123)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L54-L56) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L125-L130)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L58-L61) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L132-L138)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L63-L65) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L140-L160)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L67-L68) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L164-L166)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L70-L71) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L168-L170)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L73-L78) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L172-L179)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L80-L82) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L181-L204)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L84-L86) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L208-L212)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L88-L90) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L214-L218)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L92-L94) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L220-L227)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L96-L98) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L229-L236)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L100-L103) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L238-L245)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L105-L108) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L247-L254)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L110-L112) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L256-L269)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L114-L116) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L271-L284)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L118-L120) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L286-L299)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L122-L124) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L301-L314)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L126-L128) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L318-L335)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L130-L132) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L337-L350)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L134-L136) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L352-L358)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L138-L139) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L360-L365)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L141-L142) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L367-L370)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L144-L145) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L372-L375)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L147-L149) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L377-L396)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L151-L156) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L403-L410)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L158-L164) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L414-L427)

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

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/PastedASChallenge.lean#L166-L173) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-transfer-lean/pasted-as-review/RepairedASProofs.lean#L430-L442)
