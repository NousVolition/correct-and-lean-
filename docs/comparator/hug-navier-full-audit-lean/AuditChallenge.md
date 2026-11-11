# Which observations identify a force?

Compare two forces at the same state. At rest, equal power can conceal a difference in acceleration.

[`AuditChallenge.lean`](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-full-audit-lean/AuditChallenge.lean) · [Package configuration](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-full-audit-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 NousVolition. All rights reserved. The repository notice applies to material for which NousVolition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The working equations and earlier studies identify the source models for this comparison. [NousVolition, active-guard methods](https://github.com/NousVolition/Nous-Volition/blob/b4ae2c54cd85bfef282c501ecfca83de274e2070/studies/hug-active-guard/METHODS.md) · [NousVolition, SIMS field and guard methods](https://github.com/NousVolition/My-Sources-Project-ALL/blob/7fbc7f28f685c86f824d7587aff91feedf20d3da/reports/sims-navier-stokes-guard/METHODS.md) · [Hug source provenance](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-existence-lean/source-provenance.json).

The collection also documents a separate historical review of OpenAI’s formal development. [OpenAI’s NavierStokesAndEuler development](https://github.com/openai/NavierStokesAndEuler/blob/f9e8bc5b38b6e212696e8a30e3e91517af887bbd/README.md) · [Comparison record](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/research/comparisons/README.md).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-full-audit-lean/AuditSolution.lean) · [FullEquationSpecification](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-full-audit-lean/FullEquationSpecification.lean) · [Package account](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-full-audit-lean/README.md) · [Source audit](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-full-audit-lean/source-audit.json) · [Statement and proof inputs](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-full-audit-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-full-audit-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-full-audit-lean/lake-manifest.json).

</details>

## How does a force change affect acceleration at one state?

`acceleration_force_difference`

**Proof request**

Subtract the two acceleration equations at fixed state.

**Reading the result**

Subtracting the two equations cancels the common state terms, leaving force difference divided by mass.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem acceleration_force_difference (p : Parameters) (F G : ℝ) (s : State) :
    (rhs p F s).v-(rhs p G s).v=(F-G)/p.mass := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-full-audit-lean/AuditChallenge.lean#L5-L6) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-full-audit-lean/AuditSolution.lean#L5-L8)

## Can acceleration determine the required force?

`force_recovered_from_acceleration`

**Proof request**

Recover the unique required force from a specified acceleration and nonzero mass.

**Reading the result**

With nonzero mass, rearranging the acceleration equation gives exactly the specified force.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem force_recovered_from_acceleration (p : Parameters) (hm : p.mass ≠ 0)
    (F acceleration : ℝ) (s : State) :
    (rhs p F s).v=acceleration ↔ F=forceRequired p s acceleration := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-full-audit-lean/AuditChallenge.lean#L8-L10) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-full-audit-lean/AuditSolution.lean#L10-L16)

## Can distinct forces give equal acceleration at the same state?

`same_acceleration_iff_same_force`

**Proof request**

Prove that equal accelerations here are equivalent to equal forces.

**Reading the result**

Under the mass condition, equality of the accelerations is equivalent to equality of the forces.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem same_acceleration_iff_same_force (p : Parameters) (hm : p.mass ≠ 0)
    (F G : ℝ) (s : State) : (rhs p F s).v=(rhs p G s).v ↔ F=G := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-full-audit-lean/AuditChallenge.lean#L12-L13) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-full-audit-lean/AuditSolution.lean#L18-L26)

## Can the same specified motion solve both forced problems?

`same_motion_requires_same_force`

**Proof request**

Use the common motion hypotheses to conclude that the forcing functions agree on the interval.

**Reading the result**

Its velocity has the same derivative along the interval, which forces the two inputs to agree there under the stated hypotheses.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem same_motion_requires_same_force (p : Parameters) (hm : p.mass ≠ 0)
    (I : Set ℝ) (F G : ℝ → ℝ) (h : ℝ → State)
    (hF : ∀ t ∈ I, HugDifferentialAt p F h t)
    (hG : ∀ t ∈ I, HugDifferentialAt p G h t) : EqOn F G I := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-full-audit-lean/AuditChallenge.lean#L15-L18) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-full-audit-lean/AuditSolution.lean#L28-L34)

## How much does the energy balance respond to a change of force?

`energy_input_difference`

**Proof request**

Compute the difference of the two energy-input rates.

**Reading the result**

The difference is the force difference multiplied by the current speed coordinate.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem energy_input_difference (p : Parameters) (F G : ℝ) (s : State) :
    energyBalance p F s-energyBalance p G s=(F-G)*s.v := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-full-audit-lean/AuditChallenge.lean#L20-L21) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-full-audit-lean/AuditSolution.lean#L36-L39)

## Can power hide a force difference at rest?

`zero_speed_energy_not_force`

**Proof request**

Exhibit equal energy balances and unequal accelerations at the rest probe.

**Reading the result**

In the given rest state the two energy balances agree while the accelerations differ by five.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem zero_speed_energy_not_force :
    energyBalance protocol 1 restProbe=energyBalance protocol 0 restProbe ∧
    (rhs protocol 1 restProbe).v-(rhs protocol 0 restProbe).v=5 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-full-audit-lean/AuditChallenge.lean#L23-L25) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-full-audit-lean/AuditSolution.lean#L41-L47)

## Can one scalar describe the initial spatial profile everywhere?

`nonuniform_initial_requires_spatial_map`

**Proof request**

Rule out a single constant value for the initial spatial profile.

**Reading the result**

Two spatial positions have different initial values, ruling out a single constant.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem nonuniform_initial_requires_spatial_map :
    ¬∃ a : ℝ, ∀ r : Point, sourceInitialXA r=a := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-full-audit-lean/AuditChallenge.lean#L27-L28) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-navier-full-audit-lean/AuditSolution.lean#L49-L55)
