# Courier and Weaver after filtering

Under the stated retention and projection conditions, compare the work of the resolved terms with the raw work and heat identities.

[`CWEnergyChallenge.lean`](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWEnergyChallenge.lean) · [Package configuration](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 Nous Volition. All rights reserved. The repository notice applies to material for which Nous Volition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project creator supplied the Seven-Wizard/Hearth details and recalls that Codex may have drafted the submitted Lean file. The surviving file has no writer byline. Credit for the submission is recorded under its filename, Submitted.lean. [Original Submitted.lean](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/original/Submitted.lean) · [Seven-wizard algebra](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/SevenWizardAlgebra.lean) · [Hearth audit proofs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hearth-wizard-lean/HearthProofs.lean).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWAll.lean) · [CWChallenge](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWChallenge.lean) · [Statement and proof inputs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/lake-manifest.json).

</details>

## Do the resolved Courier and Weaver terms keep their work identities?

`retained_velocity_work`

**Proof request**

Recover the resolved Weaver and Courier work identities for a filter-retained, solenoidal velocity.

**Reading the result**

When velocity is preserved by filtering and projection, the resolved terms give zero Courier work and Weaver work equal to minus heat.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem retained_velocity_work (s : State)
    (retained : ∀ i x, filt (fun y => velocity s y i) x=velocity s x i)
    (solenoidal : project (velocity s)=velocity s) :
    inner (velocity s) (weaver s (velocity s))= -heat s ∧
    inner (velocity s) (courier (velocity s))=0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWEnergyChallenge.lean#L6-L10) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-courier-weaver-lean/CWBalance.lean#L95-L122)
