# When is a city enough information?

Hold the city fixed and change the person or surroundings. Decide when one city-only rule can reproduce all the answers.

[`ContextChallenge.lean`](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/clay-problems-lean-audit/ContextChallenge.lean) · [Package configuration](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/clay-problems-lean-audit/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 Nous Volition. All rights reserved. The repository notice applies to material for which Nous Volition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/clay-problems-lean-audit/ContextProofs.lean) · [ContextDefinitions](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/clay-problems-lean-audit/ContextDefinitions.lean) · [Statement and proof inputs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/clay-problems-lean-audit/verification-inputs.json) · [Verification record](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/clay-problems-lean-audit/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/clay-problems-lean-audit/lake-manifest.json).

</details>

## When is knowing the city enough to predict the result?

`city_only_iff_same_result`

**Proof request**

Prove equivalence between a city-only rule and agreement within each city, given a representative person and surroundings.

**Reading the result**

Exactly when changing the person and surroundings within a city leaves the result fixed. A representative pair supplies a city-only rule under the stated assumptions.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
universe u v w z
variable {Person : Type u} {Surroundings : Type v} {City : Type w} {Result : Type z}
```

```lean
theorem city_only_iff_same_result
    (f : Person → Surroundings → City → Result)
    (p₀ : Person) (e₀ : Surroundings) :
    CityOnly f ↔ SameCityResult f := by
  sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/clay-problems-lean-audit/ContextChallenge.lean#L7-L11) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/clay-problems-lean-audit/ContextProofs.lean#L7-L17)

## Can two different reports in one city defeat a city-only rule?

`differing_people_prevent_city_only`

**Proof request**

Use the unequal outcomes for two people in the same setting to rule out a city-only rule.

**Reading the result**

Such a rule would have to give both reports the same value, contradicting the stated difference.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
universe u v w z
variable {Person : Type u} {Surroundings : Type v} {City : Type w} {Result : Type z}
```

```lean
theorem differing_people_prevent_city_only
    (f : Person → Surroundings → City → Result)
    (p q : Person) (e : Surroundings) (c : City)
    (different : f p e c ≠ f q e c) : ¬ CityOnly f := by
  sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/clay-problems-lean-audit/ContextChallenge.lean#L13-L17) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/clay-problems-lean-audit/ContextProofs.lean#L19-L26)

## Can a model that reports the person’s Boolean value forget the person?

`example_cannot_forget_person`

**Proof request**

Show that the Boolean reporting example cannot be represented by the city alone.

**Reading the result**

In the example the city is fixed while the two possible people return different answers.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
universe u v w z
variable {Person : Type u} {Surroundings : Type v} {City : Type w} {Result : Type z}
```

```lean
theorem example_cannot_forget_person : ¬ CityOnly differentReports := by
  sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/clay-problems-lean-audit/ContextChallenge.lean#L19-L20) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/clay-problems-lean-audit/ContextProofs.lean#L28-L29)
