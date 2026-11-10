# Pressure, memory and opening in the squeeze model

Follow a pressure signal through a memory update and the opening latch. A connection reported within tolerance can still leave a nonzero tip gap.

[`HugChallenge.lean`](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean) · [Package configuration](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 Nous Volition. All rights reserved. The repository notice applies to material for which Nous Volition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The working equations and earlier studies identify the source models for this comparison. [NousVolition, active-guard methods](https://github.com/NousVolition/Nous-Volition/blob/b4ae2c54cd85bfef282c501ecfca83de274e2070/studies/hug-active-guard/METHODS.md) · [NousVolition, SIMS field and guard methods](https://github.com/NousVolition/My-Sources-Project-ALL/blob/7fbc7f28f685c86f824d7587aff91feedf20d3da/reports/sims-navier-stokes-guard/METHODS.md) · [Hug source provenance](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-existence-lean/source-provenance.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugAllSolution.lean) · [HugModel](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugModel.lean) · [Package account](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/README.md) · [Statement and proof inputs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/lake-manifest.json).

</details>

## Can a nonnegative displacement produce a negative pressure ratio?

`pressure_nonnegative`

**Proof request**

Prove nonnegativity of the pressure ratio under the sign assumptions.

**Reading the result**

With a positive limit the ratio is nonnegative.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem pressure_nonnegative (d limit : ℝ) (hd : 0 ≤ d) (hl : 0 < limit) :
    0 ≤ pressureRatio d limit := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L5-L6) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L5-L6)

## When does the pressure ratio reach one?

`pressure_threshold`

**Proof request**

Characterize when the pressure ratio reaches or exceeds one.

**Reading the result**

For a positive limit this is exactly when displacement reaches or exceeds that limit.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem pressure_threshold (d limit : ℝ) (hl : 0 < limit) :
    1 ≤ pressureRatio d limit ↔ limit ≤ d := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L7-L8) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L8-L10)

## Can pressure exceed one on this scale?

`pressure_above_one_allowed`

**Proof request**

Give the explicit pressure-ratio value above one.

**Reading the result**

A displacement of two and a limit of one give a ratio of two.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem pressure_above_one_allowed : pressureRatio 2 1 = 2 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L9) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L12)

## Is the selected memory time scale always positive?

`tau_positive`

**Proof request**

Show that every selected memory time scale is positive.

**Reading the result**

Both choices in the time-scale rule are positive.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem tau_positive (m p : ℝ) : 0 < memoryTau m p := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L10) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L14-L16)

## Can one memory update overshoot both its old value and the pressure?

`memory_update_bounds`

**Proof request**

Bound one memory update between the starting memory and applied pressure.

**Reading the result**

The update lies between those two endpoints under the stated time conditions.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem memory_update_bounds (m p dt tau : ℝ) (hd : 0 ≤ dt) (ht : 0 < tau) :
    min m p ≤ memoryUpdate m p dt tau ∧ memoryUpdate m p dt tau ≤ max m p := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L11-L12) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L18-L27)

## Can an imprint update turn nonnegative inputs negative?

`imprint_nonnegative`

**Proof request**

Prove nonnegativity of the imprint after an admissible update.

**Reading the result**

The interval bound keeps the new value nonnegative.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem imprint_nonnegative (m p dt : ℝ) (hm : 0 ≤ m) (hp : 0 ≤ p) (hd : 0 ≤ dt) :
    0 ≤ imprintStep m p dt := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L13-L14) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L29-L31)

## What happens if no time passes?

`no_time_no_change`

**Proof request**

Evaluate an imprint update of zero duration.

**Reading the result**

Evaluating the imprint update at duration zero returns the original memory.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem no_time_no_change (m p : ℝ) : imprintStep m p 0 = m := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L15) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L33-L34)

## Which differential equation does the constant-pressure memory path satisfy?

`constant_pressure_ode`

**Proof request**

Verify the constant-pressure differential equation for the proposed memory path.

**Reading the result**

Differentiating the exponential path gives the remaining pressure gap divided by the time scale.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem constant_pressure_ode (m p tau t : ℝ) (ht : 0 < tau) :
    HasDerivAt (memoryPath m p tau) ((p-memoryPath m p tau t)/tau) t := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L16-L17) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L36-L45)

## Can memory itself exceed one?

`memory_above_one_reachable`

**Proof request**

Compute an explicit reachable imprint of 3/2.

**Reading the result**

The displayed input of pressure two reaches memory 3/2 after the stated duration.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem memory_above_one_reachable : imprintStep 0 2 ((4/5)*Real.log 4) = 3/2 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L18) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L47-L51)

## What survives a finite interval of zero pressure?

`zero_pressure_retains_imprint`

**Proof request**

Show that finite nonnegative time at zero pressure preserves a positive imprint below or at its old value.

**Reading the result**

A positive starting imprint decays to a positive value no larger than its start.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem zero_pressure_retains_imprint (m dt : ℝ) (hm : 0 < m) (hd : 0 ≤ dt) :
    0 < imprintStep m 0 dt ∧ imprintStep m 0 dt ≤ m := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L19-L20) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L53-L57)

## How wide is the breathing coefficient’s range?

`breathing_bounds`

**Proof request**

Prove the two uniform bounds on the breathing coefficient.

**Reading the result**

Bounding its oscillating term puts it between 1/50 and 3/50.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem breathing_bounds (t : ℝ) :
    1/50 ≤ breathingCoefficient t ∧ breathingCoefficient t ≤ 3/50 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L21-L22) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L59-L64)

## How much can breathing change the pressure scale?

`pressure_scale_bounds`

**Proof request**

Propagate the coefficient bounds to the pressure scale for nonnegative memory.

**Reading the result**

For nonnegative memory, the coefficient bounds give the two displayed endpoints.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem pressure_scale_bounds (m t : ℝ) (hm : 0 ≤ m) :
    1+m/50 ≤ pressureScale m t ∧ pressureScale m t ≤ 1+3*m/50 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L23-L24) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L66-L72)

## Can reciprocal squeeze be zero or exceed one?

`reciprocal_squeeze_bounds`

**Proof request**

Prove that the corresponding squeeze is positive and at most one.

**Reading the result**

Under the stated scale conditions it stays positive and at most one.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem reciprocal_squeeze_bounds (m t : ℝ) (hm : 0 ≤ m) :
    0 < squeeze (pressureScale m t) ∧ squeeze (pressureScale m t) ≤ 1 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L25-L26) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L74-L78)

## How do stretch and reciprocal squeeze combine?

`reciprocal_area_factor`

**Proof request**

Show that the stretch and squeeze area factors multiply to one.

**Reading the result**

Their product equals one for the allowed scale.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem reciprocal_area_factor (s : ℝ) (hs : 0 < s) : s*squeeze s = 1 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L27) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L80-L81)

## Can stretching both coordinates be undone?

`inverse_stretch`

**Proof request**

Prove that applying the reciprocal stretch recovers the starting coordinates.

**Reading the result**

Applying the reciprocal scale recovers the starting point.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem inverse_stretch (s x y : ℝ) (hs : 0 < s) :
    stretchPoint (1/s) (stretchPoint s x y).1 (stretchPoint s x y).2 = (x,y) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L28-L29) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L83-L85)

## How are the left and right arm shapes related?

`mirror_arms`

**Proof request**

Derive the reflection relation between the two arms.

**Reading the result**

Corresponding points have opposite horizontal coordinates and equal heights.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem mirror_arms (b sx sy c v : ℝ) :
    rightArm b sx sy c v = (-(leftArm b sx sy c v).1,(leftArm b sx sy c v).2) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L30-L31) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L87-L89)

## When do the two tips meet exactly?

`exact_tip_closure`

**Proof request**

Characterize exact endpoint closure at positive horizontal scale.

**Reading the result**

Under the scale condition, their gap vanishes exactly at bend value one.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem exact_tip_closure (b sx : ℝ) (hs : 0 < sx) : endpointGap b sx = 0 ↔ b = 1 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L32) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L91-L100)

## Can a tolerance test report contact while a gap remains?

`tolerance_is_not_exact_closure`

**Proof request**

Construct a bend that meets the reporting tolerance with a nonzero gap.

**Reading the result**

The explicit bend just below one passes the test with a nonzero gap.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem tolerance_is_not_exact_closure :
    let b : ℝ := 1-1/(4*10^12)
    UnitInterval b ∧ reportedConnected b 1 ∧ endpointGap b 1 ≠ 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L33-L35) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L102-L105)

## How far can the timed stretch run?

`timed_stretch_bounds`

**Proof request**

Bound the timed scale over the unit interval.

**Reading the result**

Across the specified input range the scale stays between one and 27/25.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem timed_stretch_bounds (u : ℝ) (hu : UnitInterval u) :
    1 ≤ timedScale u ∧ timedScale u ≤ 27/25 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L36-L37) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L107-L116)

## At which displayed time does the stretch reach its upper value?

`timed_maximum`

**Proof request**

Evaluate the timed scale at its midpoint.

**Reading the result**

Substituting one half gives 27/25.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem timed_maximum : timedScale (1/2) = 27/25 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L38) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L118)

## Can any real input push smoothstep outside the unit interval?

`smoothstep_bounds`

**Proof request**

Show that smoothstep maps every real input into [0,1].

**Reading the result**

The rule first clips the input to [0,1]. Its quintic then stays between zero and one.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem smoothstep_bounds (x : ℝ) : UnitInterval (smoothstep x) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L39) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L120-L129)

## What starts an opening from the closed state?

`opening_threshold`

**Proof request**

Characterize the pressure that starts an opening from the closed state.

**Reading the result**

The first opening occurs exactly when pressure reaches the threshold of one.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem opening_threshold (p dt : ℝ) :
    nextOpeningAge none p dt ≠ none ↔ 1 ≤ p := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L40-L41) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L131-L134)

## What happens to an opening already in progress?

`opening_latched`

**Proof request**

Derive the age update for an existing opening.

**Reading the result**

The update adds the time step to its recorded age.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem opening_latched (age p dt : ℝ) :
    nextOpeningAge (some age) p dt = some (age+dt) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L42-L43) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L136-L137)

## Will dropping pressure to zero close an already latched opening?

`lower_pressure_does_not_reclose`

**Proof request**

Show that zero pressure preserves an existing opening.

**Reading the result**

The recorded age still advances.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem lower_pressure_does_not_reclose (age dt : ℝ) :
    nextOpeningAge (some age) 0 dt ≠ none := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L44-L45) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L139-L140)

## When is the opening bend fully released?

`full_open_after_duration`

**Proof request**

Compute the bend at an age of at least 4/5.

**Reading the result**

At any recorded age of at least 4/5, its bend is zero.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_open_after_duration (age : ℝ) (ha : 4/5 ≤ age) :
    openingBend (some age) = 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L46-L47) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L142-L146)

## Does one admissible time step preserve a valid state?

`step_preserves_state`

**Proof request**

Prove that one admissible step preserves state validity.

**Reading the result**

Applying the update bounds to its components gives a valid next state.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem step_preserves_state (x : State) (p dt : ℝ) (hx : StateOK x)
    (hp : 0 ≤ p) (hd : 0 ≤ dt) : StateOK (step x p dt) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L48-L49) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L148-L162)

## Will the same hold over a sequence of steps?

`repeated_steps_nonnegative`

**Proof request**

Prove that every finite number of admissible steps from the initial state preserves validity.

**Reading the result**

Induction applies the one-step result at every index with the stated pressure and time bounds.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem repeated_steps_nonnegative (ps ds : ℕ → ℝ)
    (hp : ∀ n, 0 ≤ ps n) (hd : ∀ n, 0 ≤ ds n) :
    ∀ n, StateOK (Nat.rec initial (fun n x => step x (ps n) (ds n)) n) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugChallenge.lean#L50-L52) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-squeeze-lean/HugSolution.lean#L164-L170)
