# Energy, pressure and stress in a single field model

Read the field equation through its transported energy, pressure gradients and viscous stress. Track the assumptions each identity uses.

[`FullChallenge.lean`](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/FullChallenge.lean) · [Package configuration](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 NousVolition. All rights reserved. The repository notice applies to material for which NousVolition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The working equations and earlier studies identify the source models for this comparison. [NousVolition, active-guard methods](https://github.com/NousVolition/Nous-Volition/blob/b4ae2c54cd85bfef282c501ecfca83de274e2070/studies/hug-active-guard/METHODS.md) · [NousVolition, SIMS field and guard methods](https://github.com/NousVolition/My-Sources-Project-ALL/blob/7fbc7f28f685c86f824d7587aff91feedf20d3da/reports/sims-navier-stokes-guard/METHODS.md) · [Hug source provenance](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-existence-lean/source-provenance.json).

The collection also documents a separate historical review of OpenAI’s formal development. [OpenAI’s NavierStokesAndEuler development](https://github.com/openai/NavierStokesAndEuler/blob/f9e8bc5b38b6e212696e8a30e3e91517af887bbd/README.md) · [Comparison record](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/research/comparisons/README.md).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/FullChecks.lean) · [OriginalAS](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/OriginalAS.lean) · [Package account](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/README.md) · [Source audit](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/source-audit.json) · [Statement and proof inputs](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/lake-manifest.json).

</details>

## What balances the material rate of change of energy?

`full_material_energy_balance`

**Proof request**

Derive the material energy balance along the stipulated field solution.

**Reading the result**

For a field obeying the stated equations, the local time derivative plus transport equals the specified production term.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_material_energy_balance (i : FieldInputs) (t : ℝ)
    (z : ℝ → Fields) (p : ℝ → ScalarField) (r : Point)
    (h : FieldDifferentialAt i z p t)
    (hs : FirstSpatialRegularity (z t)) :
    deriv (fun s => energy (z s) r) t + advection (z t) (energy (z t)) r =
      energyProduction i t (z t) (p t) r := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/FullChallenge.lean#L9-L14) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/FullChecks.lean#L54-L71)

## Does the supplied initial velocity obey incompressibility?

`source_initial_incompressible`

**Proof request**

Verify that the given initial field has zero divergence.

**Reading the result**

Evaluating its divergence gives zero.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem source_initial_incompressible : Incompressible sourceInitial := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/FullChallenge.lean#L16) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/FullChecks.lean#L73-L92)

## Can pressure be shifted by a time-dependent offset?

`full_pressure_gauge`

**Proof request**

Show that a spatially constant, time-dependent pressure shift preserves the field problem.

**Reading the result**

Spatial derivatives remove a spatially constant offset, so the shifted pressure solves the same field problem.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_pressure_gauge (i : FieldInputs) (a b : ℝ) (initial : Fields)
    (z : ℝ → Fields) (p : ℝ → ScalarField) (c : ℝ → ℝ)
    (h : FieldProblem i a b initial z p) :
    FieldProblem i a b initial z (fun t r => p t r+c t) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/FullChallenge.lean#L18-L21) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/FullChecks.lean#L99-L115)

## Can the same field have two distinct pressures?

`full_pressure_not_unique`

**Proof request**

Construct a second pressure for the same field solution.

**Reading the result**

Adding a suitable constant constructs another pressure for the same solution.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_pressure_not_unique (i : FieldInputs) (a b : ℝ) (initial : Fields)
    (z : ℝ → Fields) (p : ℝ → ScalarField)
    (h : FieldProblem i a b initial z p) :
    ∃ q, FieldProblem i a b initial z q ∧ q ≠ p := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/FullChallenge.lean#L23-L26) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/FullChecks.lean#L117-L124)

## Which way do guards move at zero and one?

`guards_inward_at_spatial_boundaries`

**Proof request**

Prove the stated inward inequalities for both guards at their spatial endpoints.

**Reading the result**

With the listed Laplacian signs and input conditions, the forward and reverse guard rates point strictly inward at the respective endpoints.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem guards_inward_at_spatial_boundaries (i : FieldInputs) (t : ℝ)
    (z : Fields) (p : ScalarField) (r : Point)
    (hxAB : partialX z.gAB r=0) (hyAB : partialY z.gAB r=0)
    (hxBA : partialX z.gBA r=0) (hyBA : partialY z.gBA r=0) :
    (z.gAB r=0 → 0 ≤ laplacian z.gAB r → 0 < (fieldRates i t z p).gAB r) ∧
    (z.gAB r=1 → laplacian z.gAB r ≤ 0 → (fieldRates i t z p).gAB r < 0) ∧
    (z.gBA r=0 → 0 ≤ laplacian z.gBA r → 0 < (fieldRates i t z p).gBA r) ∧
    (z.gBA r=1 → laplacian z.gBA r ≤ 0 → (fieldRates i t z p).gBA r < 0) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/FullChallenge.lean#L30-L37) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/FullChecks.lean#L133-L151)

## What do the viscosity and stress formulas imply for dissipation?

`viscosity_and_stress_dissipation`

**Proof request**

Bound viscosity, identify the stress contraction and prove its nonnegativity.

**Reading the result**

Admissible guards bound viscosity between 1/50 and 1/10. The stress contraction is twice viscosity times squared strain and is nonnegative.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem viscosity_and_stress_dissipation (z : Fields) (r : Point)
    (ha : z.gAB r ∈ Icc (0:ℝ) 1) (hb : z.gBA r ∈ Icc (0:ℝ) 1) :
    viscosity z r ∈ Icc (1/50:ℝ) (1/10) ∧
    stressXX z r*partialX z.ux r+stressYY z r*partialY z.uy r+
      stressXY z r*(partialY z.ux r+partialX z.uy r)=2*viscosity z r*strainSquared z r ∧
    0 ≤ 2*viscosity z r*strainSquared z r := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/FullChallenge.lean#L39-L44) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/FullChecks.lean#L153-L165)

## How does spatially varying viscosity enter the stress derivative?

`full_variable_stress_divergence`

**Proof request**

Expand the designated component of the divergence of the variable-viscosity stress.

**Reading the result**

Applying the product rule to the displayed component produces both viscosity-gradient terms and second velocity derivatives.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_variable_stress_divergence (z : Fields) (r : Point)
    (hnu : Differentiable ℝ (viscosity z))
    (ha : Differentiable ℝ (partialX z.ux))
    (hb : Differentiable ℝ (partialY z.ux))
    (hc : Differentiable ℝ (partialX z.uy)) :
    partialX (stressXX z) r+partialY (stressXY z) r =
      2*(partialX (viscosity z) r)*(partialX z.ux r)+
      2*viscosity z r*partialX (partialX z.ux) r+
      partialY (viscosity z) r*(partialY z.ux r+partialX z.uy r)+
      viscosity z r*(partialY (partialY z.ux) r+partialY (partialX z.uy) r) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/FullChallenge.lean#L47-L56) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/FullChecks.lean#L176-L194)

## How does the original accumulated memory change?

`original_memory_derivative`

**Proof request**

Differentiate the original accumulated memory at the specified time.

**Reading the result**

Under the stated regularity, differentiating its integral gives gamma times the current utility excess over baseline.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem original_memory_derivative (p : Parameters) (U : ℝ → ℝ)
    (hU : Continuous U) (t : ℝ) :
    HasDerivAt (memory p U) (p.gamma*(U t-p.baseline)) t := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/FullChallenge.lean#L64-L66) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/FullChecks.lean#L202-L208)

## Does the original differential equation allow the same pressure shift?

`original_pressure_gauge`

**Proof request**

Verify that the time-only pressure shift preserves the original differential law.

**Reading the result**

A time-only offset has zero spatial gradient, preserving the pointwise equation.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem original_pressure_gauge {n : ℕ} (p : Parameters) (response : ℝ → ℝ)
    (direction : Fin n) (U : ℝ → ℝ) (K : Scalar n) (x0 : Point n)
    (domain : Set (Point n)) (z : ℝ → Fields n) (pressure : ℝ → Scalar n)
    (c : ℝ → ℝ) (t : ℝ)
    (h : FullDifferentialAt p response direction U K x0 domain z pressure t) :
    FullDifferentialAt p response direction U K x0 domain z
      (fun s x => pressure s x+c s) t := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/FullChallenge.lean#L68-L74) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/FullChecks.lean#L210-L217)

## Do the normalized and density-weighted momentum equations say the same thing?

`normalized_momentum_equivalent`

**Proof request**

Prove equivalence of the two momentum equations under the density assumption.

**Reading the result**

With nonzero density, multiplying or dividing by density takes one equality to the other.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem normalized_momentum_equivalent (rho mu sigma dt conv gradP lap a ek : ℝ)
    (hr : rho ≠ 0) :
    (dt+conv=-(gradP/rho)+(mu/rho)*lap-(sigma/rho)*a*ek) ↔
    (rho*(dt+conv)=-gradP+mu*lap-sigma*a*ek) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/FullChallenge.lean#L76-L79) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-single-system-lean/FullChecks.lean#L219-L223)
