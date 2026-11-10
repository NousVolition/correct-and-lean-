# Can a band shrink on a moving apple skin?

Start with the band contracting on the reference skin. Carry the contraction through continuous maps, accepted numerical steps and a moving material segment.

[`AppleBandChallenge.lean`](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleBandChallenge.lean) · [Package configuration](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 Nous Volition. All rights reserved. The repository notice applies to material for which Nous Volition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleRealFlow.lean) · [AppleBandDefinitions](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleBandDefinitions.lean) · [Statement and proof inputs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/lake-manifest.json).

</details>

## Can a band around the reference apple shrink to a point while staying on its skin?

`reference_band_contracts`

**Proof request**

Contract the equator to the north point on the reference skin.

**Reading the result**

The contraction carries the equator to the north point through loops on that skin.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem reference_band_contracts : ContractsOn referenceSkin equator north := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleBandChallenge.lean#L6) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleBandTopology.lean#L34-L38)

## What happens to a contraction under a continuous map?

`continuous_map_carries_contraction`

**Proof request**

Carry a specified contraction through a continuous map.

**Reading the result**

Applying the map throughout the original contraction produces a contraction inside the image.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem continuous_map_carries_contraction (f : Vec → Vec) (hf : Continuous f)
    {S : Set Vec} {loop : Band → Vec} {p : Vec} (h : ContractsOn S loop p) :
    ContractsOn (f '' S) (fun b => f (loop b)) (f p) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleBandChallenge.lean#L8-L10) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleBandTopology.lean#L40-L45)

## Can the band shrink while the skin itself moves?

`moving_skin_carries_contraction`

**Proof request**

Build a moving contraction under the stipulated jointly continuous carrier.

**Reading the result**

The moving map carries each stage of the reference contraction along with the skin.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem moving_skin_carries_contraction (f : Slide → Vec → Vec)
    (hf : Continuous (fun y : Slide × Vec => f y.1 y.2)) : MovingContraction f := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleBandChallenge.lean#L12-L13) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleBandTopology.lean#L47-L52)

## Can a reversible change of coordinates change whether the band contracts?

`homeomorphic_transport_iff`

**Proof request**

Prove both directions of contraction transport under a homeomorphism.

**Reading the result**

The homeomorphism carries the contraction forward, and its inverse carries one back.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem homeomorphic_transport_iff (e : Vec ≃ₜ Vec) (S : Set Vec) (loop : Band → Vec) (p : Vec) :
    ContractsOn (e '' S) (fun b => e (loop b)) (e p) ↔ ContractsOn S loop p := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleBandChallenge.lean#L15-L16) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleBandTopology.lean#L54-L60)

## How do a particle’s position and fabric move in an accepted rate?

`accepted_position_and_fabric_rates`

**Proof request**

Extract the position and deformation components of an accepted rate.

**Reading the result**

The position follows the material velocity and the fabric follows the local gradient times its deformation.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem accepted_position_and_fabric_rates (G : Geometry) (t : ℝ) (s d : State) (p : Particle)
    (ok : rhs G t s=some d) : d.X p=materialVelocity s (s.X p) ∧
    d.F p=mm (particleGradient s p) (s.F p) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleBandChallenge.lean#L18-L20) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleBandProofs.lean#L10-L19)

## What position does a single accepted step give each particle?

`accepted_step_moves_every_particle`

**Proof request**

Express every particle’s accepted step by the same spatial step map.

**Reading the result**

Substituting the stages yields the same spatial step map applied to each starting position.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem accepted_step_moves_every_particle {G : Geometry} {t h : ℝ} {s d pr k e : State}
    (ok : ChildAccount.FullStep G t h s d pr k e) (p : Particle) :
    e.X p=stepMap ⟨s,pr,h⟩ (s.X p) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleBandChallenge.lean#L22-L24) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleBandProofs.lean#L21-L29)

## Can an accepted scheduled boundary move particles or change their deformation?

`accepted_boundary_keeps_material`

**Proof request**

Show that accepted boundaries preserve both particle positions and fabric.

**Reading the result**

Inspecting its updates shows that both material fields retain their input values.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem accepted_boundary_keeps_material (n : ℕ) (x y : FullState) (ok : boundary n x=some y) :
    y.state.X=x.state.X ∧ y.state.F=x.state.F := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleBandChallenge.lean#L26-L27) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleBandProofs.lean#L45-L60)

## Can several accepted steps carry the whole band?

`accepted_chain_carries_band`

**Proof request**

Transport all particle positions and the contracting band along the accepted chain.

**Reading the result**

Composing the step maps moves the particles and carries the reference contraction to the transported skin.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem accepted_chain_carries_band {stages : List Stages} {s e : State}
    (ok : AcceptedChain stages s e) :
    (∀ p, e.X p=transport stages (s.X p)) ∧
    ContractsOn (transport stages '' referenceSkin) (fun b => transport stages (equator b))
      (transport stages north) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleBandChallenge.lean#L29-L33) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleBandProofs.lean#L105-L111)

## Does a segment of a solving trace carry a local band?

`full_segment_local_band`

**Proof request**

Construct the moving contraction for a particle’s carrier on a solved segment.

**Reading the result**

Its particle-based carrier supplies a moving contraction along the segment.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_segment_local_band (tr : Trace) (solves : Solves tr) (k : ℕ) (hk : k<5) (p : Particle) :
    MovingContraction (segmentCarrier tr k p) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleBandChallenge.lean#L35-L36) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleBandProofs.lean#L120-L140)

## Can opposite tips move farther apart while the band still contracts?

`stretch_expands_tips_and_preserves_contraction`

**Proof request**

Prove the strict tip-separation bound and the transported contraction together.

**Reading the result**

For positive stretch time their horizontal separation exceeds 11/25, and the transported contraction stays on the image skin.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem stretch_expands_tips_and_preserves_contraction (t : ℝ) (ht : 0<t) :
    let f := fabricMap 0 (FrameTransition.stretch t)
    (11/25:ℝ)<f (equator east) 0-f (equator west) 0 ∧
    ContractsOn (f '' referenceSkin) (fun b => f (equator b)) (f north) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleBandChallenge.lean#L38-L41) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleBandTopology.lean#L62-L78)

## When can a step keep distinct points distinct?

`small_step_preserves_distinct_points`

**Proof request**

Prove injectivity of the step map from the stated bounds and step-size condition.

**Reading the result**

The given velocity bounds and small-step inequality keep its perturbation of the identity too small to merge two points.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem small_step_preserves_distinct_points (a : Stages) (A B : ℝ)
    (hA : 0≤A) (hB : 0≤B)
    (first : ∀ x y, ‖materialVelocity a.present x-materialVelocity a.present y‖≤A*‖x-y‖)
    (second : ∀ x y, ‖materialVelocity a.predictor x-materialVelocity a.predictor y‖≤B*‖x-y‖)
    (small : |a.h| / 2*(A+B*(1+|a.h| * A))<1) : Function.Injective (stepMap a) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleBandChallenge.lean#L43-L47) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-apple-band-lean/AppleBandProofs.lean#L142-L180)
