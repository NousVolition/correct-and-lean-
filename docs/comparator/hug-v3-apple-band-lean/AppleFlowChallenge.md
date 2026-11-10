# Carrying the apple band through the material flow

Start with a trace that solves the model. Bound the velocity, match it at event boundaries and construct the continuous carrier for the band.

[`AppleFlowChallenge.lean`](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleFlowChallenge.lean) · [Package configuration](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 Nous Volition. All rights reserved. The repository notice applies to material for which Nous Volition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleRealFlow.lean) · [AppleBandChallenge](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleBandChallenge.lean) · [AppleFlowDefinitions](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleFlowDefinitions.lean) · [Statement and proof inputs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/lake-manifest.json).

</details>

## Can one bound the material velocity everywhere throughout a time interval?

`continuous_grid_history_has_global_space_bounds`

**Proof request**

Find uniform global spatial speed and Lipschitz bounds over the time interval.

**Reading the result**

A continuous grid history on the closed interval yields uniform bounds on both speed and spatial Lipschitz variation.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem continuous_grid_history_has_global_space_bounds {a b : ℝ} (u : ℝ → Vector)
    (hc : ContinuousOn u (Set.Icc a b)) :
    ∃ L K : ℝ≥0, ∀ t∈Set.Icc a b,
      (∀ z, ‖gridVelocity (u t) z‖≤(L:ℝ)) ∧ LipschitzWith K (gridVelocity (u t)) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleFlowChallenge.lean#L8-L11) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleFlowBounds.lean#L97-L139)

## Do accepted event boundaries change the velocity used for transport?

`accepted_boundary_keeps_velocity`

**Proof request**

Show that a successful boundary preserves the velocity field.

**Reading the result**

The boundary updates preserve the velocity field.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem accepted_boundary_keeps_velocity (n : ℕ) (x y : FullState) (ok : boundary n x=some y) :
    velocity y.state=velocity x.state := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleFlowChallenge.lean#L13-L14) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleTraceVelocity.lean#L34-L48)

## Does a solving trace carry a band across the whole schedule?

`full_trace_material_flow_carries_band`

**Proof request**

Construct a material flow and moving contraction across the stipulated solving trace.

**Reading the result**

With the stated radius, the constructed material flow spans the trace and transports the band contraction.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_trace_material_flow_carries_band (tr : Trace) (solves : Solves tr) (R : ℝ≥0) (big : 1≤R) :
    ∃ φ : Vec × ℝ → Vec, MaterialFlowAcross tr R φ ∧
      MovingContraction (fun r z => φ (z,(r:ℝ)*time 5)) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleFlowChallenge.lean#L16-L18) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleRealFlow.lean#L134-L170)
