# Carrying the fabric buffer across a full trace

Apply the single-segment and event bounds successively to a stipulated hybrid trace. Ask when the list of decoded records can change.

[`V3ClayTrajectoryChallenge.lean`](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayTrajectoryChallenge.lean) · [Package configuration](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 Nous Volition. All rights reserved. The repository notice applies to material for which Nous Volition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayTrajectoryProofs.lean) · [V3ClayChallenge](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayChallenge.lean) · [Package account](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/README.md) · [Source audit](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/source-audit.json) · [Source map](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/source-map.json) · [Statement and proof inputs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/lake-manifest.json).

</details>

## Can the buffer survive a complete hybrid schedule?

`clay_buffer_through_full_hybrid`

**Proof request**

Propagate the clay buffer to every listed checkpoint and inter-event segment under the stated hypotheses.

**Reading the result**

Given the solving trace and its stated controls, segment preservation and boundary preservation propagate the buffer through checkpoint five.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem clay_buffer_through_full_hybrid (tr : Trace) (hsol : Solves tr)
    (hF : ∀ k<5, ∀ t ∈ Ico (time k) (time (k+1)), ∀ l : Cell,
      (∑ i, ((tr.path k t).state.F (point l) i (axis l))^2) ≤ (2:ℝ)) :
    (∀ k≤5, ClayBuffer (tr.after k).state) ∧
    ∀ k<5, ∀ t ∈ Icc (time k) (time (k+1)), ClayBuffer (tr.path k t).state := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayTrajectoryChallenge.lean#L10-L14) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayTrajectoryProofs.lean#L13-L49)

## Where can the record list change on such a trace?

`decoded_records_fixed_along_full_hybrid`

**Proof request**

Prove that each full-trace segment decodes its starting checkpoint’s list throughout.

**Reading the result**

Under the stated conditions every point of each segment reads the same list as its starting checkpoint.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem decoded_records_fixed_along_full_hybrid (tr : Trace) (hsol : Solves tr) :
    ∀ k<5, ∀ t ∈ Icc (time k) (time (k+1)),
      readRecords (tr.path k t).state = readRecords (tr.after k).state := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayTrajectoryChallenge.lean#L16-L18) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-clay-boundary-lean/V3ClayTrajectoryProofs.lean#L51-L66)
