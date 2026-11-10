# The band on the embedded apple skin

At a time in the given flow, show both that the transported skin is embedded and that the loop can shrink while staying on it.

[`AppleSkinChallenge.lean`](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleSkinChallenge.lean) · [Package configuration](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 Nous Volition. All rights reserved. The repository notice applies to material for which Nous Volition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleRealFlow.lean) · [AppleFlowChallenge](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleFlowChallenge.lean) · [Statement and proof inputs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/lake-manifest.json).

</details>

## Can the band shrink on the actual transported skin at each time?

`band_on_the_embedded_skin_at_each_time`

**Proof request**

Prove embedding of the transported reference skin and contraction of its equator at the given time.

**Reading the result**

Given the material flow and radius bound, its restriction embeds the reference skin and the loop contracts within that embedded image.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem band_on_the_embedded_skin_at_each_time {tr : Trace} {R : ℝ≥0} {φ : Vec × ℝ → Vec}
    (flow : MaterialFlowAcross tr R φ) (big : 1≤R) (t : ℝ) (ht : t∈Set.Icc (time 0) (time 5)) :
    Topology.IsEmbedding (fun z : referenceSkin => φ ((z:Vec),t)) ∧
    ContractsOn ((fun z : Vec => φ (z,t)) '' referenceSkin)
      (fun b => φ (equator b,t)) (φ (north,t)) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleSkinChallenge.lean#L7-L11) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleRealFlow.lean#L186-L204)
