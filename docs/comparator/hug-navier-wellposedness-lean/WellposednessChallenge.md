# Small field changes with a persistent rate difference

Construct smooth, nearly identical fields and calculate their rate differences. Use the example to test the proposed uniform local estimate.

[`WellposednessChallenge.lean`](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-wellposedness-lean/WellposednessChallenge.lean) · [Package configuration](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-wellposedness-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 Nous Volition. All rights reserved. The repository notice applies to material for which Nous Volition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The working equations and earlier studies identify the source models for this comparison. [NousVolition, active-guard methods](https://github.com/NousVolition/Nous-Volition/blob/b4ae2c54cd85bfef282c501ecfca83de274e2070/studies/hug-active-guard/METHODS.md) · [NousVolition, SIMS field and guard methods](https://github.com/NousVolition/My-Sources-Project-ALL/blob/7fbc7f28f685c86f824d7587aff91feedf20d3da/reports/sims-navier-stokes-guard/METHODS.md) · [Hug source provenance](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-existence-lean/source-provenance.json).

The collection also documents a separate historical review of OpenAI’s formal development. [OpenAI’s NavierStokesAndEuler development](https://github.com/openai/NavierStokesAndEuler/blob/f9e8bc5b38b6e212696e8a30e3e91517af887bbd/README.md) · [Comparison record](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/research/comparisons/README.md).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-wellposedness-lean/WellposednessProofs.lean) · [WellposednessTargets](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-wellposedness-lean/WellposednessTargets.lean) · [Package account](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-wellposedness-lean/README.md) · [Source audit](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-wellposedness-lean/source-audit.json) · [Statement and proof inputs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-wellposedness-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-wellposedness-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-wellposedness-lean/lake-manifest.json).

</details>

## Are the high-frequency perturbations admissible in the stated senses?

`perturbation_regular`

**Proof request**

Prove smoothness and periodicity of the perturbation and incompressibility of the nearby field.

**Reading the result**

Their trigonometric formulas give smooth periodic perturbations and a divergence-free perturbed initial velocity.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem perturbation_regular (n : ℕ) :
    ContDiff ℝ ⊤ (perturbation n) ∧ Periodic (perturbation n) ∧
      Incompressible (nearby n) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-wellposedness-lean/WellposednessChallenge.lean#L8-L10) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-wellposedness-lean/WellposednessProofs.lean#L7-L18)

## How close is the perturbed field to the original one?

`nearby_uniform_bound`

**Proof request**

Bound the uniform distance from the initial field by 1/n².

**Reading the result**

The specified uniform difference is bounded by 1/n² for the admitted indices.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem nearby_uniform_bound (n : ℕ) :
    UniformlyClose (nearby n) sourceInitial (1/(n:ℝ)^2) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-wellposedness-lean/WellposednessChallenge.lean#L12-L13) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-wellposedness-lean/WellposednessProofs.lean#L20-L31)

## How much does the selected rate change despite that closeness?

`exact_rate_difference`

**Proof request**

Compute the exact rate difference for a positive perturbation index.

**Reading the result**

The exact difference is −1/50 minus 3/(2n²).

<details>
<summary>Exact Lean statement</summary>

```lean
theorem exact_rate_difference (n : ℕ) (hn : 0 < n) :
    rateDifference n = -(1/50:ℝ)-(3/2)*(1/(n:ℝ)^2) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-wellposedness-lean/WellposednessChallenge.lean#L15-L16) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-wellposedness-lean/WellposednessProofs.lean#L74-L81)

## Does uniform closeness here guarantee the proposed local rate bound?

`no_uniform_local_rate_bound`

**Proof request**

Disprove the proposed uniform local rate bound using this family.

**Reading the result**

This family gets arbitrarily close while the rate difference retains a nonzero term, contradicting the proposed bound.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem no_uniform_local_rate_bound : ¬ UniformLocalRateBound := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-wellposedness-lean/WellposednessChallenge.lean#L18) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-wellposedness-lean/WellposednessProofs.lean#L83-L111)
