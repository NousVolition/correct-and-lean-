# How Smoke and Clay exchange influence

Track a load from saturation through exchange, meaning, opening and registration. The final equations give explicit paths for accumulation and clearing.

[`ASChallenge.lean`](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean) · [Package configuration](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 Nous Volition. All rights reserved. The repository notice applies to material for which Nous Volition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The package preserves the source A/S register and input protocol for the returning-student model. [A/S equation register](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/source-equations.json) · [A/S source protocol](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/source-protocol.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean) · [ASModel](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASModel.lean) · [Package account](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/README.md) · [Source equations](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/source-equations.json) · [Source protocol](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/source-protocol.json) · [Statement and proof inputs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/lake-manifest.json).

</details>

## How close can saturation get to one?

`saturation_bounds`

**Proof request**

For nonnegative load and positive scale, prove saturation is at least zero and strictly less than one.

**Reading the result**

Adding a positive scale to the nonnegative load makes its ratio at least zero and strictly below one.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem saturation_bounds (L s : ℝ) (hL : 0 ≤ L) (hs : 0 < s) :
    0 ≤ saturation L s ∧ saturation L s < 1 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L9-L10) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L11-L16)

## Can the effect exceed its allowed range?

`effect_bounds`

**Proof request**

Show that the specified gain-adjusted effect lies in [0,1].

**Reading the result**

Multiplying saturation by a gain between zero and one keeps the effect in that interval.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem effect_bounds (g L s : ℝ) (hg : UnitInterval g) (hL : 0 ≤ L) (hs : 0 < s) :
    UnitInterval (effect g L s) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L11-L12) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L17-L25)

## Can exchange increase the unadjusted transfer?

`exchange_no_increase`

**Proof request**

Bound exchange above by the weighted gap.

**Reading the result**

The formula subtracts a nonnegative correction from the weighted gap.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem exchange_no_increase (w chi gap : ℝ) (hw : 0 ≤ w) (hc : 0 ≤ chi) :
    exchange w chi gap ≤ w * gap := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L13-L14) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L26-L31)

## What happens when the gap is negative or zero?

`exchange_negative_unchanged`

**Proof request**

Show that exchange equals the weighted gap when the gap is nonpositive.

**Reading the result**

Its positive part vanishes, so exchange equals the weighted gap.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem exchange_negative_unchanged (w chi gap : ℝ) (hgap : gap ≤ 0) :
    exchange w chi gap = w * gap := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L15-L16) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L32-L34)

## Can a larger gap give a smaller exchange?

`exchange_monotone`

**Proof request**

Prove that exchange is nondecreasing in the gap under the stated coefficient conditions.

**Reading the result**

On the two sides of zero the exchange formula has nonnegative slopes under the stated weight and gating bounds.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem exchange_monotone (w chi a b : ℝ) (hw : 0 ≤ w) (hc : UnitInterval chi)
    (hab : a ≤ b) : exchange w chi a ≤ exchange w chi b := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L17-L18) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L35-L55)

## What does the general drift rule give for Smoke?

`general_smoke_agrees`

**Proof request**

Recover the Smoke equation from index zero of the general drift.

**Reading the result**

Substituting index zero selects the Smoke equation.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem general_smoke_agrees (p : Parameters) (x : State) :
    generalSDrift p x 0 = smokeDrift p x := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L19-L20) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L56-L58)

## What does the same rule give for Clay?

`general_clay_agrees`

**Proof request**

Recover the Clay equation from index one of the general drift.

**Reading the result**

Substituting index one selects the Clay equation.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem general_clay_agrees (p : Parameters) (x : State) :
    generalSDrift p x 1 = clayDrift p x := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L21-L22) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L59-L61)

## What survives when you add the two influence rates?

`total_influence_balance`

**Proof request**

Expand the sum of the Smoke and Clay rates and identify the directed corrections.

**Reading the result**

Expanding the sum exposes the source, decay, unequal directional weights and the two positive-gap corrections.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem total_influence_balance (p : Parameters) (x : State)
    (hK : p.KSmoke + p.KClay = 1) :
    smokeDrift p x + clayDrift p x = source p x - p.decay * (x 1 + x 2) +
      (p.wClaySmoke - p.wSmokeClay) * (x 1 - x 2) -
      p.wClaySmoke * chiForward p x * pos (x 1 - x 2) -
      p.wSmokeClay * chiReverse p x * pos (x 2 - x 1) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L23-L28) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L62-L73)

## Can a received meaning land outside the unit interval?

`received_meaning_bounds`

**Proof request**

Show that the received meaning is a unit-interval value.

**Reading the result**

Mixing admissible meanings with an admissible weight keeps the result between zero and one.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem received_meaning_bounds (theta z imposed : ℝ)
    (ht : UnitInterval theta) (hz : UnitInterval z) (hi : UnitInterval imposed) :
    UnitInterval (receivedMeaning theta z imposed) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L29-L31) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L74-L84)

## How large can the meaning rate be?

`meaning_rate_bounds`

**Proof request**

Bound the meaning rate between zero and its weight.

**Reading the result**

The bounded factors in the rate restrict it to the interval from zero to its weight.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem meaning_rate_bounds (w chi S s : ℝ) (hw : 0 ≤ w)
    (hc : UnitInterval chi) (hs : 0 < s) :
    0 ≤ meaningRate w chi S s ∧ meaningRate w chi S s ≤ w := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L32-L34) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L85-L96)

## Which way can meaning move when it starts at zero?

`meaning_lower_boundary`

**Proof request**

Show that the meaning rate of change at the lower endpoint is nonnegative.

**Reading the result**

At the lower boundary its rate is nonnegative under the stated sign and range conditions.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem meaning_lower_boundary (k received clear ref : ℝ)
    (hk : 0 ≤ k) (hr : 0 ≤ received) (hc : 0 ≤ clear) (hf : 0 ≤ ref) :
    0 ≤ meaningDrift k received 0 clear ref := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L35-L37) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L97-L101)

## Which way can meaning move when it starts at one?

`meaning_upper_boundary`

**Proof request**

Show that the meaning rate of change at the upper endpoint is nonpositive.

**Reading the result**

At the upper boundary the permitted inputs give a nonpositive drift.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem meaning_upper_boundary (k received clear ref : ℝ)
    (hk : 0 ≤ k) (hr : received ≤ 1) (hc : 0 ≤ clear) (hf : ref ≤ 1) :
    meaningDrift k received 1 clear ref ≤ 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L38-L40) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L102-L107)

## Can the load start decreasing at zero?

`load_lower_boundary`

**Proof request**

Show that load drift is nonnegative at zero load.

**Reading the result**

Clearing contributes nothing there, and the admitted exposure contribution is nonnegative.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem load_lower_boundary (alpha exposure clear : ℝ) (h : Bool)
    (ha : 0 ≤ alpha) (he : 0 ≤ exposure) :
    0 ≤ loadDrift alpha h exposure clear 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L41-L43) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L108-L113)

## Can activation be negative?

`activation_nonnegative`

**Proof request**

Prove nonnegativity of the activation function.

**Reading the result**

Taking the positive part of the threshold excess sets a floor at zero.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem activation_nonnegative (clay threshold : ℝ) :
    0 ≤ activation clay threshold := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L44-L45) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L114-L116)

## Can opening exceed its gain?

`opening_bounds`

**Proof request**

Bound the opening by zero and the gain g.

**Reading the result**

Its bounded factors put opening between zero and the gain.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem opening_bounds (g p0 r s : ℝ) (hg : UnitInterval g)
    (hp : UnitInterval p0) (hr : 0 ≤ r) (hs : 0 < s) :
    0 ≤ opening g p0 r s ∧ opening g p0 r s ≤ g := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L46-L48) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L117-L133)

## How much registration can survive a challenge?

`registration_bounds`

**Proof request**

Bound registration by zero and the parameter eta.

**Reading the result**

With the stated unit-interval inputs, registration lies between zero and eta.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem registration_bounds (eta z v : ℝ) (he : UnitInterval eta)
    (hz : UnitInterval z) (hv : UnitInterval v) :
    0 ≤ registration eta z v ∧ registration eta z v ≤ eta := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L49-L51) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L134-L145)

## What gets registered if the opening is closed?

`no_opening_no_registration`

**Proof request**

Evaluate conditional registration when the opening flag is false.

**Reading the result**

The false branch returns zero.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem no_opening_no_registration (eta z v : ℝ) :
    conditionalRegistration eta z v false = 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L52-L53) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L146-L148)

## What happens when qualification and challenge are both complete?

`fully_qualified_blocks_challenge`

**Proof request**

Evaluate registration at full qualification and full challenge.

**Reading the result**

Substituting one for both makes the registration factor vanish.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem fully_qualified_blocks_challenge (eta : ℝ) :
    registration eta 1 1 = 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L54-L55) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L149-L151)

## What happens to registration when challenge is zero?

`confirmation_unchanged`

**Proof request**

Evaluate registration with zero challenge.

**Reading the result**

The reduction vanishes, leaving the original eta.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem confirmation_unchanged (eta z : ℝ) :
    registration eta z 0 = eta := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L56-L57) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L152-L154)

## Do the encounter branches form a distribution?

`branch_distribution`

**Proof request**

Prove that the three branch values are nonnegative and sum to one.

**Reading the result**

Each weight is nonnegative for admissible probabilities, and the weights add to one.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem branch_distribution (p q : ℝ) (hp : UnitInterval p) (hq : UnitInterval q) :
    (∀ j, 0 ≤ branches p q j) ∧ (∑ j, branches p q j) = 1 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L58-L59) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L155-L164)

## Does a missing contribution change the old meaning?

`update_no_contribution`

**Proof request**

Evaluate the update when there is no contribution.

**Reading the result**

The update takes its false branch and returns the old distribution.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem update_no_contribution (beta : ℝ) (H M : Meaning) :
    update beta false H M = H := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L60-L61) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L165-L168)

## Does repeating the same meaning move it?

`update_same_meaning`

**Proof request**

Prove that updating a meaning with itself fixes it.

**Reading the result**

Both inputs agree, so either update branch returns that meaning.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem update_same_meaning (beta : ℝ) (C : Bool) (H : Meaning) :
    update beta C H H = H := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L62-L63) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L169-L172)

## How are old and incoming meanings mixed?

`update_is_convex`

**Proof request**

Write the contributing update as a componentwise weighted average.

**Reading the result**

On a contributing encounter, the weights are one minus beta and beta.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem update_is_convex (beta : ℝ) (H M : Meaning) :
    update beta true H M = fun j => (1-beta) * H j + beta * M j := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L64-L65) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L173-L177)

## Does a valid meaning distribution survive an update?

`update_preserves_simplex`

**Proof request**

Show that the update takes valid distributions to valid distributions.

**Reading the result**

The inactive branch preserves it directly. The active branch blends two distributions with admissible weights.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem update_preserves_simplex (beta : ℝ) (C : Bool) (H M : Meaning)
    (hb : UnitInterval beta) (hH : Simplex H) (hM : Simplex M) :
    Simplex (update beta C H M) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L66-L68) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L178-L191)

## What path gives the stated constant accumulation rate?

`constant_accumulation_solves`

**Proof request**

Differentiate the proposed constant-utility accumulation path.

**Reading the result**

A straight line starting at A₀ has slope gamma times the utility excess.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem constant_accumulation_solves (A0 gamma utility baseline t : ℝ) :
    HasDerivAt (fun s : ℝ => A0 + gamma * (utility-baseline) * s)
      (accumulatedDrift gamma utility baseline) t := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L69-L71) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L192-L196)

## What does steady exposure do with clearing set to zero?

`constant_exposure_solves`

**Proof request**

Verify the linear load solution for constant exposure and zero clearing.

**Reading the result**

Differentiating the proposed straight line gives the load rate specified by the model.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem constant_exposure_solves (L0 alpha exposure t : ℝ) (h : Bool) :
    HasDerivAt (fun s : ℝ => L0 + alpha * indicator h * exposure * s)
      (loadDrift alpha h exposure 0 (L0 + alpha * indicator h * exposure * t)) t := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L72-L74) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L197-L201)

## Can that exposure path take a nonnegative load below zero?

`constant_exposure_nonnegative`

**Proof request**

Prove that this linear load is nonnegative at admissible times.

**Reading the result**

Its initial value and its added exposure term are nonnegative under the listed conditions.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem constant_exposure_nonnegative (L0 alpha exposure t : ℝ) (h : Bool)
    (hL : 0 ≤ L0) (ha : 0 ≤ alpha) (he : 0 ≤ exposure) (ht : 0 ≤ t) :
    0 ≤ L0 + alpha * indicator h * exposure * t := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L75-L77) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L202-L206)

## What path describes clearing by itself?

`clearing_solves`

**Proof request**

Differentiate the proposed exponential clearing path.

**Reading the result**

Differentiating the exponential decay curve gives minus the clearing coefficient times its current value.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem clearing_solves (L0 clear t : ℝ) :
    HasDerivAt (fun s : ℝ => L0 * Real.exp (-clear*s))
      (-clear * (L0 * Real.exp (-clear*t))) t := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L78-L80) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L207-L211)

## Can exponential clearing reverse a nonnegative load’s sign?

`clearing_preserves_nonnegative`

**Proof request**

Show that clearing preserves the sign bound on a nonnegative initial load.

**Reading the result**

The exponential factor is positive, so multiplying by it preserves nonnegativity.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem clearing_preserves_nonnegative (L0 clear t : ℝ) (hL : 0 ≤ L0) :
    0 ≤ L0 * Real.exp (-clear*t) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L81-L82) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L212-L214)

## What happens when the received and current meanings match and clearing is off?

`cleared_equal_meaning_has_zero_drift`

**Proof request**

Evaluate meaning drift when the received and current values coincide under the stated settings.

**Reading the result**

Substitution makes the difference driving the drift vanish.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem cleared_equal_meaning_has_zero_drift (k z : ℝ) :
    meaningDrift k (receivedMeaning 0 z 1) z 0 0 = 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASChallenge.lean#L83-L84) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/as-lean/ASProofs.lean#L215-L217)
