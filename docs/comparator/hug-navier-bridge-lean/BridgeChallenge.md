# Matching a shear field to Hug rates

Determine which coefficients and diffusion terms make the shear model reproduce the two guard directions, the four local rates and the projected power.

[`BridgeChallenge.lean`](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeChallenge.lean) · [Package configuration](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 NousVolition. All rights reserved. The repository notice applies to material for which NousVolition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The working equations and earlier studies identify the source models for this comparison. [NousVolition, active-guard methods](https://github.com/NousVolition/Nous-Volition/blob/b4ae2c54cd85bfef282c501ecfca83de274e2070/studies/hug-active-guard/METHODS.md) · [NousVolition, SIMS field and guard methods](https://github.com/NousVolition/My-Sources-Project-ALL/blob/7fbc7f28f685c86f824d7587aff91feedf20d3da/reports/sims-navier-stokes-guard/METHODS.md) · [Hug source provenance](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-existence-lean/source-provenance.json).

The collection also documents a separate historical review of OpenAI’s formal development. [OpenAI’s NavierStokesAndEuler development](https://github.com/openai/NavierStokesAndEuler/blob/f9e8bc5b38b6e212696e8a30e3e91517af887bbd/README.md) · [Comparison record](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/research/comparisons/README.md).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeSolution.lean) · [BridgeModel](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeModel.lean) · [Package account](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/README.md) · [Statement and proof inputs](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/lake-manifest.json).

</details>

## How quickly does the linear shear profile change with height?

`shear_derivative`

**Proof request**

Compute the spatial derivative of the linear shear velocity.

**Reading the result**

Its slope is the velocity scale divided by the length.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem shear_derivative (v L y : ℝ) :
    HasDerivAt (shearVelocity v L) (v/L) y := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeChallenge.lean#L5-L6) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeSolution.lean#L5-L7)

## What scalar do you get by contracting the shear tensor?

`shear_contraction`

**Proof request**

Evaluate the tensor contraction and identify the scalar shear invariant.

**Reading the result**

Expanding the matrix entries gives the specified shear invariant.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem shear_contraction (v L : ℝ) (hL : L ≠ 0) :
    contraction (shearD v L) = shearInvariant v L := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeChallenge.lean#L8-L9) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeSolution.lean#L9-L13)

## Can a nonzero linear shear match its values at the two boundary heights?

`nonzero_shear_not_periodic`

**Proof request**

Characterize agreement between the shear velocities at the two designated heights.

**Reading the result**

Under the nonzero height and length conditions, equality at the ends forces the velocity to be zero.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem nonzero_shear_not_periodic (v L H : ℝ) (hL : L ≠ 0) (hH : H ≠ 0) :
    shearVelocity v L H = shearVelocity v L 0 ↔ v = 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeChallenge.lean#L11-L12) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeSolution.lean#L15-L17)

## How should the shear coefficient be scaled to reproduce the strain signal?

`strain_matching`

**Proof request**

Rescale chi to match the original strain term.

**Reading the result**

Substituting the matching coefficient makes the field product equal the model’s original strain term.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem strain_matching (p : Parameters) (s : State)
    (hL : p.length ≠ 0) (hQ : p.scale ≠ 0) :
    matchingChi p * shearInvariant s.v p.length = p.chi*strainSignal p s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeChallenge.lean#L14-L16) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeSolution.lean#L19-L24)

## Does that choice work in both directions?

`argument_matching`

**Proof request**

Verify the matching forward and reverse arguments using that coefficient.

**Reading the result**

After the strain terms match, the forward and reverse field arguments equal their corresponding targets.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem argument_matching (p : Parameters) (s : State)
    (hL : p.length ≠ 0) (hQ : p.scale ≠ 0) :
    fieldArgumentAB p (matchingChi p) s = targetAB p s ∧
    fieldArgumentBA p (matchingChi p) s = targetBA p s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeChallenge.lean#L18-L21) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeSolution.lean#L26-L32)

## How much does diffusion contribute to the guard-rate mismatch?

`guard_diffusion_residual`

**Proof request**

Compute the diffusion residual in both guard directions.

**Reading the result**

In each direction the uncancelled term is the diffusion coefficient times its supplied Laplacian.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem guard_diffusion_residual (p : Parameters) (F : ℝ) (s : State)
    (hL : p.length ≠ 0) (hQ : p.scale ≠ 0) (kA lA kB lB : ℝ) :
    materialGuardAB p (matchingChi p) s kA lA - (rhs p F s).gAB = kA*lA ∧
    materialGuardBA p (matchingChi p) s kB lB - (rhs p F s).gBA = kB*lB := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeChallenge.lean#L23-L26) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeSolution.lean#L34-L41)

## When do all four local rates agree?

`four_rates_agree_iff`

**Proof request**

Give necessary and sufficient conditions for all four rates to agree.

**Reading the result**

Each of the four diffusion products must vanish, and those four equalities are sufficient.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem four_rates_agree_iff (p : Parameters) (F : ℝ) (s : State)
    (hL : p.length ≠ 0) (hQ : p.scale ≠ 0) (kA lA kB lB kgA lgA kgB lgB : ℝ) :
    FourRatesAgree p F s kA lA kB lB kgA lgA kgB lgB ↔
      kA*lA=0 ∧ kB*lB=0 ∧ kgA*lgA=0 ∧ kgB*lgB=0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeChallenge.lean#L28-L31) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeSolution.lean#L43-L56)

## How can projected guard power equal the original loss?

`power_matching`

**Proof request**

Show the two coefficient identities are sufficient to match guard power.

**Reading the result**

Choosing both coefficients to meet the volume–damping equations matches the two power terms.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem power_matching (p : Parameters) (aAB aBA : ℝ) (hL : p.length ≠ 0)
    (ha : p.volume*aAB=p.damping*p.length^2)
    (hb : p.volume*aBA=p.damping*p.length^2) (s : State) :
    projectedGuardPower p aAB aBA s = guardLoss p s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeChallenge.lean#L33-L36) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeSolution.lean#L58-L64)

## Are those coefficient conditions necessary?

`power_matching_necessary`

**Proof request**

Derive both coefficient identities from power matching at every state.

**Reading the result**

Demanding equal power at every state lets each directional coefficient be isolated.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem power_matching_necessary (p : Parameters) (aAB aBA : ℝ) (hL : p.length ≠ 0)
    (h : ∀ s, projectedGuardPower p aAB aBA s = guardLoss p s) :
    p.volume*aAB=p.damping*p.length^2 ∧ p.volume*aBA=p.damping*p.length^2 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeChallenge.lean#L38-L40) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeSolution.lean#L66-L73)

## What coefficient values does the reference protocol require?

`primary_required_coefficients`

**Proof request**

Evaluate the required coefficients for the named protocol.

**Reading the result**

Substitution gives 500,000 for matching chi and the stated volume–damping relation with 1,000.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem primary_required_coefficients :
    matchingChi protocol = 500000 ∧
    protocol.volume*(1000:ℝ)=protocol.damping*protocol.length^2 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeChallenge.lean#L42-L44) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeSolution.lean#L75-L78)

## Does the numerical power match hold for every protocol state?

`primary_power_matches`

**Proof request**

Show that the protocol’s two coefficients of 1,000 match guard power.

**Reading the result**

Substituting 1,000 in both directional coefficients satisfies the matching conditions.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem primary_power_matches (s : State) :
    projectedGuardPower protocol 1000 1000 s = guardLoss protocol s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeChallenge.lean#L46-L47) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeSolution.lean#L80-L85)

## Does copying the numerical chi guarantee the same field argument?

`same_number_chi_is_not_same_argument`

**Proof request**

Construct the stated mismatch that arises from copying the unscaled chi.

**Reading the result**

The stated probe gives a different forward argument when the unadjusted chi is used.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem same_number_chi_is_not_same_argument :
    fieldArgumentAB protocol protocol.chi probe ≠ targetAB protocol probe := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeChallenge.lean#L49-L50) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeSolution.lean#L87-L89)

## Can nonzero diffusion spoil the match even after scaling chi?

`nonzero_diffusion_blocks_local_match`

**Proof request**

Evaluate the nonzero forward diffusion mismatch at unit factors.

**Reading the result**

Setting both factors to one leaves a unit residual in the forward guard rate.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem nonzero_diffusion_blocks_local_match (F : ℝ) (s : State) :
    materialGuardAB protocol (matchingChi protocol) s 1 1 ≠
      (rhs protocol F s).gAB := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeChallenge.lean#L52-L54) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeSolution.lean#L91-L98)

## Can the rate and power comparisons hold together?

`simultaneous_conditional_bridge`

**Proof request**

Verify both the four-rate match and the power match for the stated settings.

**Reading the result**

At the specified protocol values, zero diffusion products give four equal rates and the chosen coefficients match power.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem simultaneous_conditional_bridge (F : ℝ) (s : State) :
    FourRatesAgree protocol F s 0 0 0 0 0 0 0 0 ∧
    projectedGuardPower protocol 1000 1000 s = guardLoss protocol s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeChallenge.lean#L56-L58) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-bridge-lean/BridgeSolution.lean#L100-L106)
