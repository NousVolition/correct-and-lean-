# What the active Hug model does to guards and energy

Follow the guard bounds and the energy terms. The passive inequality and the explicit active example concern different parameter choices.

[`ActiveHugChallenge.lean`](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugChallenge.lean) · [Package configuration](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 Nous Volition. All rights reserved. The repository notice applies to material for which Nous Volition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The working equations and earlier studies identify the source models for this comparison. [NousVolition, active-guard methods](https://github.com/NousVolition/Nous-Volition/blob/b4ae2c54cd85bfef282c501ecfca83de274e2070/studies/hug-active-guard/METHODS.md) · [NousVolition, SIMS field and guard methods](https://github.com/NousVolition/My-Sources-Project-ALL/blob/7fbc7f28f685c86f824d7587aff91feedf20d3da/reports/sims-navier-stokes-guard/METHODS.md) · [Hug source provenance](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-existence-lean/source-provenance.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugAllSolution.lean) · [ActiveHugModel](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugModel.lean) · [Package account](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/README.md) · [Statement and proof inputs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/lake-manifest.json).

</details>

## Do the chosen protocol constants meet the physical parameter conditions?

`protocol_physical`

**Proof request**

Verify the physical parameter conditions for the named protocol.

**Reading the result**

Substitution checks the required signs and bounds.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem protocol_physical : Physical protocol := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugChallenge.lean#L5) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugSolution.lean#L5)

## Can the sigmoid hit either endpoint?

`sigmoid_bounds`

**Proof request**

Prove the strict upper and lower sigmoid bounds.

**Reading the result**

For finite real input, the exponential formula places it strictly between zero and one.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem sigmoid_bounds (z : ℝ) : 0 < sigmoid z ∧ sigmoid z < 1 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugChallenge.lean#L6) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugSolution.lean#L7-L10)

## Can the strain signal be negative?

`strain_nonnegative`

**Proof request**

Prove nonnegativity of the strain signal for all parameters and states.

**Reading the result**

Its formula is one half of a real square, so the bound holds for all parameters and states.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem strain_nonnegative (p : Parameters) (s : State) : 0 ≤ strainSignal p s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugChallenge.lean#L7) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugSolution.lean#L12-L14)

## Which way does the guard point at its endpoints?

`guard_points_inward`

**Proof request**

Show that the guard rate points strictly inward at both endpoints.

**Reading the result**

With positive relaxation time, the rate is positive at zero and negative at one.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem guard_points_inward (tau z : ℝ) (ht : 0 < tau) :
    0 < guardRate tau z 0 ∧ guardRate tau z 1 < 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugChallenge.lean#L8-L9) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugSolution.lean#L16-L21)

## Can an admissible guard trajectory leave the unit interval?

`guard_interval_invariant`

**Proof request**

Prove interval invariance for the given integral guard solution.

**Reading the result**

The endpoint directions keep a solution that starts inside within the interval under the stated trajectory conditions.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem guard_interval_invariant {a b g0 tau : ℝ} {z g : ℝ → ℝ}
    (hab : a ≤ b) (ht : 0 < tau) (h0 : Hug.UnitInterval g0)
    (hsol : IntegralSolution (fun t y => guardRate tau (z t) y) a b g0 g) :
    ∀ t ∈ Icc a b, Hug.UnitInterval (g t) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugChallenge.lean#L10-L13) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugSolution.lean#L36-L49)

## Can the stored energy fall below zero?

`energy_nonnegative`

**Proof request**

Prove nonnegativity of the energy for physical parameters.

**Reading the result**

The energy terms are nonnegative under the physical parameter assumptions.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem energy_nonnegative (p : Parameters) (s : State) (hp : Physical p) :
    0 ≤ energy p s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugChallenge.lean#L14-L15) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugSolution.lean#L51-L55)

## Does the energy chain rule reproduce the stated balance?

`energy_chain_identity`

**Proof request**

Substitute the full rate in the energy chain and recover the balance.

**Reading the result**

Substituting the model rates into the energy derivative cancels the internal exchanges.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem energy_chain_identity (p : Parameters) (F : ℝ) (s : State) (hp : Physical p) :
    energyChain p s (rhs p F s) = energyBalance p F s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugChallenge.lean#L16-L17) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugSolution.lean#L57-L62)

## What is the derivative of energy along the specified motion?

`energy_derivative`

**Proof request**

Differentiate energy along the stated coordinate paths.

**Reading the result**

Applying the component derivative assumptions to the energy expression yields the balance at that time.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem energy_derivative (p : Parameters) (F : ℝ) (q v u w : ℝ → ℝ)
    (xA xB gAB gBA t : ℝ) (hp : Physical p) :
    let s : State := ⟨q t,v t,u t,w t,xA,xB,gAB,gBA⟩
    HasDerivAt q (rhs p F s).q t → HasDerivAt v (rhs p F s).v t →
    HasDerivAt u (rhs p F s).u t → HasDerivAt w (rhs p F s).w t →
    HasDerivAt (fun r => energy p ⟨q r,v r,u r,w r,xA,xB,gAB,gBA⟩)
      (energyBalance p F s) t := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugChallenge.lean#L18-L24) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugSolution.lean#L64-L83)

## Can the material loss term be negative?

`material_loss_nonnegative`

**Proof request**

Prove that material loss is nonnegative under the physical assumptions.

**Reading the result**

Its physical coefficients and squared terms give a nonnegative loss.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem material_loss_nonnegative (p : Parameters) (s : State) (hp : Physical p) :
    0 ≤ materialLoss p s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugChallenge.lean#L25-L26) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugSolution.lean#L85-L89)

## Can the guard loss term be negative?

`guard_loss_nonnegative`

**Proof request**

Prove that guard loss is nonnegative under the damping and guard assumptions.

**Reading the result**

Under the listed admissibility conditions its factors give a nonnegative loss.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem guard_loss_nonnegative (p : Parameters) (s : State) (hc : 0 ≤ p.damping)
    (ha : 0 ≤ s.gAB) (hb : 0 ≤ s.gBA) : 0 ≤ guardLoss p s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugChallenge.lean#L27-L28) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugSolution.lean#L91-L94)

## Can the passive unforced model gain energy?

`passive_unforced_energy_rate`

**Proof request**

Prove that the passive unforced balance is nonpositive.

**Reading the result**

With the stated passive conditions the balance consists of losses and is at most zero.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem passive_unforced_energy_rate (p : Parameters) (s : State) (hp : Physical p)
    (ha : p.gain = 0) (hb : p.saturation = 0) (hgA : 0 ≤ s.gAB) (hgB : 0 ≤ s.gBA) :
    energyBalance p 0 s ≤ 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugChallenge.lean#L29-L31) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugSolution.lean#L96-L102)

## Can an active model gain energy even at zero external force?

`active_energy_can_increase`

**Proof request**

Compute the strictly positive energy rate in the explicit active state.

**Reading the result**

In the displayed protocol state its energy rate is exactly 1/5,000,000,000.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem active_energy_can_increase :
    energyBalance protocol 0 ⟨0,1/10000,0,0,-11/20,7/20,1/2,1/2⟩ = 1/5000000000 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugChallenge.lean#L32-L33) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugSolution.lean#L104-L106)

## What governs the difference between the two participants?

`participant_difference_closes`

**Proof request**

Derive the closed equation for the participants’ difference.

**Reading the result**

Subtracting their rates yields the specified rule in the participant gap and the sum of the two guards.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem participant_difference_closes (p : Parameters) (F : ℝ) (s : State)
    (ha : p.weightAB = 1) (hb : p.weightBA = 1) :
    (rhs p F s).xB-(rhs p F s).xA = differenceRate p (s.xB-s.xA) (s.gAB+s.gBA) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugChallenge.lean#L34-L36) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugSolution.lean#L108-L112)

## How do the two directional guard rates add up?

`directional_guard_sum`

**Proof request**

Derive the sum of the two directional guard rates.

**Reading the result**

Their total relaxes toward the sum of the two sigmoid targets on the common time scale.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem directional_guard_sum (p : Parameters) (F : ℝ) (s : State) :
    (rhs p F s).gAB+(rhs p F s).gBA =
    (sigmoid (targetAB p s)+sigmoid (targetBA p s)-(s.gAB+s.gBA))/p.tau := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugChallenge.lean#L37-L39) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugSolution.lean#L114-L118)

## Can a shared guard rule reproduce that sum?

`shared_directional_sum_equal`

**Proof request**

Compare the sum under the shared rule with the original directional sum.

**Reading the result**

Adding its two rates gives exactly the same total as the directional equations.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem shared_directional_sum_equal (p : Parameters) (F : ℝ) (s : State) :
    sharedGuardRate p s s.gAB+sharedGuardRate p s s.gBA =
    (rhs p F s).gAB+(rhs p F s).gBA := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugChallenge.lean#L40-L42) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugSolution.lean#L120-L124)

## What acceleration remains when damping is set to zero?

`zero_damper_recovers_old_acceleration`

**Proof request**

Recover the earlier acceleration by setting damping to zero.

**Reading the result**

Substitution drops the damper term and gives the earlier acceleration formula.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem zero_damper_recovers_old_acceleration (p : Parameters) (F : ℝ) (s : State) :
    (rhs {p with damping := 0} F s).v =
    (F+(p.gain-p.saturation*s.q^2)*s.v-p.stiffness*s.q-p.volume/p.length*stress p s)/p.mass := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugChallenge.lean#L43-L45) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugSolution.lean#L126-L129)

## Can the displayed shear be undone?

`display_shear_reversible`

**Proof request**

Prove that applying the opposite displayed shear inverts the first one.

**Reading the result**

Applying the equal and opposite shear returns both original coordinates.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem display_shear_reversible (q length x y : ℝ) :
    displayShear (-q) length (displayShear q length x y).1 (displayShear q length x y).2 = (x,y) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugChallenge.lean#L46-L47) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugSolution.lean#L131-L133)

## Does the shear move a point vertically?

`display_preserves_height`

**Proof request**

Show that the displayed shear fixes the height coordinate.

**Reading the result**

The second coordinate of the displayed map is exactly its original height.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem display_preserves_height (q length x y : ℝ) : (displayShear q length x y).2 = y := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugChallenge.lean#L48) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugSolution.lean#L135)

## How large can the capped source become?

`capped_source_bound`

**Proof request**

Bound the absolute value of the capped source.

**Reading the result**

Its absolute value stays below or at the stated cap.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem capped_source_bound (cap k A : ℝ) (hc : 0 ≤ cap) :
    |cappedSource cap k A| ≤ cap := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugChallenge.lean#L51-L52) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugSolution.lean#L137-L140)

## What happens to the capped source if the input changes sign?

`capped_source_sign_reverse`

**Proof request**

Show that negating the input negates the capped source.

**Reading the result**

The output changes sign with it.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem capped_source_sign_reverse (cap k A : ℝ) :
    cappedSource cap k (-A) = -cappedSource cap k A := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugChallenge.lean#L53-L54) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugSolution.lean#L142-L146)

## When does pair exchange switch off below the center?

`pair_off_below_centre`

**Proof request**

Prove that pair exchange vanishes at the specified heights.

**Reading the result**

Under the stated height condition the rule selects zero.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem pair_off_below_centre (k sign height amplitude own partner : ℝ) (hh : height ≤ 0) :
    pairExchange k sign height amplitude own partner = 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugChallenge.lean#L55-L56) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugSolution.lean#L148-L150)

## Does a pair exchange create a net contribution across both partners?

`paired_exchange_cancels`

**Proof request**

Prove cancellation after summing a pair exchange in both directions.

**Reading the result**

Swapping the two partners reverses the exchange, so the sum vanishes.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem paired_exchange_cancels (k sign height amplitude x y : ℝ) :
    pairExchange k sign height amplitude x y + pairExchange k sign height amplitude y x = 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugChallenge.lean#L57-L58) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugSolution.lean#L152-L156)

## When is the response exactly off?

`response_exactly_off`

**Proof request**

Evaluate the response for nonpositive excess.

**Reading the result**

The stated condition puts the excess in the zero branch.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem response_exactly_off (excess epsilon : ℝ) (hq : excess ≤ 0) : exactOff excess epsilon = 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugChallenge.lean#L59) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugSolution.lean#L158-L159)

## Can reversing the gradient alone change this force?

`sign_reversal_same_force`

**Proof request**

Show that the force is even in its gradient argument.

**Reading the result**

The formula gives the same force for a gradient and its negative.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem sign_reversal_same_force (coefficient gradient threshold epsilon : ℝ) :
    gradientForce coefficient (-gradient) threshold epsilon = gradientForce coefficient gradient threshold epsilon := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugChallenge.lean#L60-L61) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/ActiveHugSolution.lean#L161-L163)
