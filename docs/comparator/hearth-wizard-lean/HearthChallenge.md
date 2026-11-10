# Hearth and the seven wizard couplings

Use opposite signs in a pair of couplings to trace cancellations. Then test the stronger Jacobi and fluid identities on explicit examples.

[`HearthChallenge.lean`](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthChallenge.lean) · [Package configuration](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 Nous Volition. All rights reserved. The repository notice applies to material for which Nous Volition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project creator supplied the Seven-Wizard/Hearth details and recalls that Codex may have drafted the submitted Lean file. The surviving file has no writer byline. Credit for the submission is recorded under its filename, Submitted.lean. [Original Submitted.lean](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/original/Submitted.lean) · [Seven-wizard algebra](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/SevenWizardAlgebra.lean) · [Hearth audit proofs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthProofs.lean).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthProofs.lean) · [HearthDefinitions](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthDefinitions.lean) · [Statement and proof inputs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/lake-manifest.json).

</details>

## Can a wizard be numbered and recovered?

`fromFin_toFin`

**Proof request**

Prove the wizard-to-index-to-wizard identity.

**Reading the result**

Looking the assigned number up again returns the same wizard.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem fromFin_toFin (w : Wizard) : fromFin (toFin w) = w := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthChallenge.lean#L8) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/SevenWizardAlgebra.lean#L9-L10)

## Can every allowed number make the reverse trip?

`toFin_fromFin`

**Proof request**

Prove the index-to-wizard-to-index identity.

**Reading the result**

Naming its wizard and numbering that wizard gives the original index.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem toFin_fromFin (i : Fin 7) : toFin (fromFin i) = i := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthChallenge.lean#L10) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/SevenWizardAlgebra.lean#L13-L15)

## What does the coupling give on the diagonal?

`diag_zero`

**Proof request**

Show that every diagonal coupling vanishes.

**Reading the result**

Skew symmetry makes a diagonal entry equal to its own negative, so it is zero.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable (C : CommutatorMatrix)
```

```lean
theorem diag_zero (i : Fin 7) : C.κ i i = 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthChallenge.lean#L18) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/SevenWizardAlgebra.lean#L23-L25)

## What changes if the two wizards exchange positions in the bracket?

`bracket_antisymm`

**Proof request**

Prove antisymmetry of the two-wizard bracket.

**Reading the result**

Reversing them reverses the sign.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable (C : CommutatorMatrix)
```

```lean
theorem bracket_antisymm (w₁ w₂ : Wizard) (Φ : ℝ) :
    C.bracket w₁ w₂ Φ = - C.bracket w₂ w₁ Φ := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthChallenge.lean#L20-L21) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/SevenWizardAlgebra.lean#L27-L31)

## What is the sum of all the pair couplings?

`sum_all_vanishes`

**Proof request**

Sum all ordered couplings and obtain zero.

**Reading the result**

Each ordered pair cancels its reverse and the diagonal contributes zero.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable (C : CommutatorMatrix)
```

```lean
theorem sum_all_vanishes :
    (∑ i : Fin 7, ∑ j : Fin 7, C.κ i j) = 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthChallenge.lean#L23-L24) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/SevenWizardAlgebra.lean#L33-L49)

## Can one vector produce a nonzero quadratic value from this coupling?

`quadratic_form_zero`

**Proof request**

Show that the skew quadratic form vanishes for every vector.

**Reading the result**

Swapping the two indices leaves the vector weights intact and reverses the coupling, giving a total of zero.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable (C : CommutatorMatrix)
```

```lean
theorem quadratic_form_zero (v : Fin 7 → ℝ) :
    (∑ i : Fin 7, ∑ j : Fin 7, v i * C.κ i j * v j) = 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthChallenge.lean#L26-L27) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/SevenWizardAlgebra.lean#L51-L69)

## How does a wizard bracket with itself?

`bracket_self`

**Proof request**

Evaluate the bracket of a wizard with itself.

**Reading the result**

The diagonal coupling vanishes, so the bracket is zero.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable (C : CommutatorMatrix)
```

```lean
theorem bracket_self (w : Wizard) (Φ : ℝ) : C.bracket w w Φ=0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthChallenge.lean#L29) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/WizardBracket.lean#L8-L9)

## What happens when all ordered wizard brackets are added?

`sum_all_brackets`

**Proof request**

Prove that the sum of all ordered brackets vanishes.

**Reading the result**

Pairing each bracket with its reverse cancels the entire sum.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable (C : CommutatorMatrix)
```

```lean
theorem sum_all_brackets (Φ : ℝ) :
    (∑ i : Fin 7, ∑ j : Fin 7, C.bracket (Wizard.fromFin i) (Wizard.fromFin j) Φ)=0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthChallenge.lean#L31-L32) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/WizardBracket.lean#L11-L15)

## What does the form read on two basis vectors?

`form_basis_pair`

**Proof request**

Evaluate the form on two coordinate basis vectors.

**Reading the result**

The two coordinates select a single coupling coefficient multiplied by the field value.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable (C : CommutatorMatrix)
```

```lean
theorem form_basis_pair (Φ : ℝ) (a b : Fin 7) :
    C.form Φ (basis a) (basis b)=C.κ a b*Φ := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthChallenge.lean#L34-L35) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/WizardBracket.lean#L17-L21)

## What if the two input vectors of the form trade places?

`form_antisymm`

**Proof request**

Prove antisymmetry of the two-vector form.

**Reading the result**

Swapping the summation indices shows that the value changes sign.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable (C : CommutatorMatrix)
```

```lean
theorem form_antisymm (Φ : ℝ) (v w : WizardVector) :
    C.form Φ v w= -C.form Φ w v := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthChallenge.lean#L37-L38) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/WizardBracket.lean#L23-L38)

## Can a sum or a scalar pass through either input of the form?

`form_bilinear`

**Proof request**

Prove linearity in each argument of the form.

**Reading the result**

Distributing the finite sums proves linearity in each input separately.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable (C : CommutatorMatrix)
```

```lean
theorem form_bilinear (Φ a b : ℝ) (u v w : WizardVector) :
    C.form Φ (a • u+b • v) w=a*C.form Φ u w+b*C.form Φ v w ∧
    C.form Φ w (a • u+b • v)=a*C.form Φ w u+b*C.form Φ w v := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthChallenge.lean#L40-L42) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/WizardBracket.lean#L40-L52)

## What happens if both inputs of the form are the same vector?

`form_alternating`

**Proof request**

Show that the form vanishes on a repeated argument.

**Reading the result**

The alternating form evaluates to zero.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable (C : CommutatorMatrix)
```

```lean
theorem form_alternating (Φ : ℝ) (v : WizardVector) : C.form Φ v v=0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthChallenge.lean#L44) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/WizardBracket.lean#L54-L55)

## When does Hearth bracket to zero with every wizard?

`centrality_criterion`

**Proof request**

Characterize central Hearth by its brackets at nonzero field strength.

**Reading the result**

At nonzero field strength this happens exactly when Hearth’s coupling row vanishes.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable (C : CommutatorMatrix)
```

```lean
theorem centrality_criterion (Φ : ℝ) (nonzero : Φ≠0) :
    (∀ w, C.bracket Wizard.hearth w Φ=0) ↔ C.CentralHearth := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthChallenge.lean#L46-L47) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/WizardBracket.lean#L57-L65)

## Does the central construction satisfy the Jacobi identity?

`central_lift_satisfies_jacobi`

**Proof request**

Derive the Jacobi identity under the central-Hearth condition.

**Reading the result**

With the stated centrality condition, the nested bracket terms have zero cyclic sum.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable (C : CommutatorMatrix)
```

```lean
theorem central_lift_satisfies_jacobi (Φ : ℝ) (central : C.CentralHearth) (u v w : WizardVector) :
    C.jacobiSum Φ u v w=0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthChallenge.lean#L49-L50) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/WizardBracket.lean#L67-L81)

## Is skew symmetry alone sufficient for Jacobi?

`arbitrary_skew_lift_can_fail_jacobi`

**Proof request**

Exhibit a skew coupling that fails the Jacobi identity.

**Reading the result**

The two-pair example gives a Jacobi component of −1.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable (C : CommutatorMatrix)
```

```lean
theorem arbitrary_skew_lift_can_fail_jacobi :
    twoPairs.jacobiSum 1 (basis 1) (basis 2) (basis 3) 0 = -1 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthChallenge.lean#L52-L53) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/WizardBracket.lean#L83-L115)

## Can the finite skew-coupling law change kinetic energy at that instant?

`finite_kinetic_energy_rate`

**Proof request**

Differentiate kinetic energy under the stated finite coupling law.

**Reading the result**

Differentiating the sum of squared velocities produces the skew quadratic form, which vanishes.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable (C : CommutatorMatrix)
```

```lean
theorem finite_kinetic_energy_rate (Φ : ℝ) (v : ℝ → WizardVector) (t : ℝ)
    (law : ∀ i, HasDerivAt (fun τ => v τ i) (Φ * ∑ j, C.κ i j*v t j) t) :
    HasDerivAt (fun τ => (1/2:ℝ)*∑ i, (v τ i)^2) 0 t := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthChallenge.lean#L55-L57) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/WizardBracket.lean#L117-L136)

## Is the example shear smooth and periodic?

`shear_smooth_and_periodic`

**Proof request**

Prove smoothness and coordinate-wise 2π periodicity of the shear.

**Reading the result**

Its coordinate formula is smooth and repeats after adding 2π to any coordinate.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem shear_smooth_and_periodic :
    ContDiff ℝ ∞ shear ∧ ∀ x : Space, ∀ j : Fin 3,
      shear (Function.update x j (x j+2*Real.pi))=shear x := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthChallenge.lean#L64-L66) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthProofs.lean#L83-L98)

## What force balances this stationary shear?

`shear_solves_stationary_forced_momentum`

**Proof request**

Verify incompressibility and the stationary forced momentum equation for the shear.

**Reading the result**

The specified forcing balances the viscous term, and the example also has zero divergence.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem shear_solves_stationary_forced_momentum (ρ μ t : ℝ) (x : Space) :
    divergence shear x=0 ∧ ∀ i, ρ*(deriv (fun _ : ℝ => shear x i) t+convection shear x i) =
      -partialAt (fun _ => 0) x i + μ*laplace shear x i + μ*shear x i := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthChallenge.lean#L68-L70) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthProofs.lean#L100-L105)

## Which three integrals survive in the shear example?

`shear_companion_integrals`

**Proof request**

Evaluate all three companion integrals for the given shear.

**Reading the result**

The convection–Laplacian and stretching integrals vanish. Dissipation integrates to 4μπ³.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem shear_companion_integrals (μ : ℝ) :
    cubeIntegral (convLap shear)=0 ∧ cubeIntegral (stretching shear)=0 ∧
      cubeIntegral (dissipation μ shear)=4*μ*Real.pi^3 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthChallenge.lean#L72-L74) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthProofs.lean#L107-L117)

## Can the proposed companion identity hold for this example?

`companion_identity_fails`

**Proof request**

Disprove the companion identity for that shear at positive viscosity.

**Reading the result**

Its two sides disagree when the stated viscosity condition is applied to those integrals.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem companion_identity_fails (μ : ℝ) (positive : 0<μ) :
    ¬ companionIdentity μ shear := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthChallenge.lean#L76-L77) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthProofs.lean#L119-L125)

## Can viscous heating be negative in the Hug model?

`hug_viscous_heat_nonnegative`

**Proof request**

Show that the native model’s viscous heat is nonnegative.

**Reading the result**

The heat expression is a sum of nonnegative contributions.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem hug_viscous_heat_nonnegative (s : HugV3.Source.State) (x : HugV3.Source.Grid) :
    0≤HugV3.Source.viscousHeat s x := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthChallenge.lean#L79-L80) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthProofs.lean#L127-L134)

## Where does the heat source enter temperature change?

`hug_temperature_contains_hearth_source`

**Proof request**

Recover the displayed heat balance from the temperature coordinate of an accepted rate.

**Reading the result**

Projecting an accepted rate onto grid channel four gives the filtered balance of transport, viscous heating, extraction and release.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem hug_temperature_contains_hearth_source (G : HugV3.Source.Geometry) (s d : HugV3.Source.State)
    (t : ℝ) (accepted : HugV3.Source.rhs G t s=some d) (x : HugV3.Source.Grid) :
    d.g x 4 = HugV3.Source.filt (fun y =>
      -HugV3.Source.divergence (fun z j => HugV3.Source.velocity s z j*s.g z 4+HugV3.Source.heatFlux G s z j) y+
      HugV3.Source.viscousHeat s y-HugV3.Source.extraction G s y+HugV3.Source.releaseGrid G s y) x := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthChallenge.lean#L82-L86) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthProofs.lean#L136-L146)
