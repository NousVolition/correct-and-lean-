# Can people’s occupied regions overlap?

Test membership using guard margins. The common zero action gives concrete overlap at initialization, and a separate derivative describes later region motion.

[`V3OccupiedSpaceChallenge.lean`](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceChallenge.lean) · [Package configuration](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 NousVolition. All rights reserved. The repository notice applies to material for which NousVolition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceProofs.lean) · [V3OccupiedSpaceDefinitions](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceDefinitions.lean) · [Statement and proof inputs](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/lake-manifest.json).

</details>

## How is the original guard margin recovered?

`margin_is_original`

**Proof request**

Recover the native guard margin at the visitor’s actual expression.

**Reading the result**

Evaluate the position-dependent margin at the visitor’s actual expression.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem margin_is_original (s : State) (owner visitor : Actor) :
    guardMarginAt s owner visitor (s.expression visitor) = margin s owner visitor := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceChallenge.lean#L10-L11) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceProofs.lean#L11-L13)

## What does being inside a guard region mean for the soft permission score?

`region_matches_half_permission`

**Proof request**

Characterize guard membership by the strict one-half soft-permission threshold.

**Reading the result**

Membership is equivalent to the sigmoid score being strictly greater than one half.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem region_matches_half_permission (s : State) (owner visitor : Actor) (z : Action) :
    z ∈ guardRegion s owner visitor ↔ (1/2 : ℝ) < sigmoid (guardMarginAt s owner visitor z/0.18) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceChallenge.lean#L13-L14) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceProofs.lean#L27-L31)

## Can the soft permission score be exactly zero?

`soft_permission_positive`

**Proof request**

Prove strict positivity of the soft permission for every supplied argument.

**Reading the result**

The sigmoid of a finite real argument is strictly positive.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem soft_permission_positive (s : State) (owner visitor : Actor) (z : Action) :
    0 < sigmoid (guardMarginAt s owner visitor z/0.18) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceChallenge.lean#L16-L17) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceProofs.lean#L33-L36)

## Does a guard region contain its owner’s center?

`region_contains_owners_center`

**Proof request**

Prove that each owner’s center lies in its guard region.

**Reading the result**

At the center the displacement vanishes and the radius gives a positive margin.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem region_contains_owners_center (s : State) (owner visitor : Actor) :
    s.normCenter owner ∈ guardRegion s owner visitor := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceChallenge.lean#L19-L20) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceProofs.lean#L38-L40)

## Can two visitor regions for the same owner overlap?

`same_audience_regions_overlap`

**Proof request**

Exhibit an intersection point for the two guard regions with the same owner.

**Reading the result**

The owner’s center supplies a point in both.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem same_audience_regions_overlap (s : State) (owner i j : Actor) :
    (guardRegion s owner i ∩ guardRegion s owner j).Nonempty := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceChallenge.lean#L22-L23) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceProofs.lean#L42-L45)

## Which action lies in every initial guard region?

`initial_zero_in_every_guard`

**Proof request**

Show that zero action belongs to every initial guard region.

**Reading the result**

Direct evaluation puts the zero action inside each one.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem initial_zero_in_every_guard (G : Geometry) (owner visitor : Actor) :
    zeroAction ∈ guardRegion (initial G) owner visitor := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceChallenge.lean#L25-L26) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceProofs.lean#L47-L58)

## Does that action survive the combined audience conditions?

`initial_zero_in_every_whole_region`

**Proof request**

Show that zero action belongs to the initial combined occupied regions.

**Reading the result**

At initialization the zero action satisfies every required guard.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem initial_zero_in_every_whole_region (G : Geometry) (audience : Audience) (i : Actor) :
    zeroAction ∈ occupiedRegion (initial G) audience i := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceChallenge.lean#L28-L29) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceProofs.lean#L60-L63)

## Can the initial occupied regions be mutually exclusive as proposed?

`initial_exclusion_refuted`

**Proof request**

Disprove the specified exclusion condition at initialization.

**Reading the result**

Their common zero action supplies a counterexample under the stated audience hypotheses.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem initial_exclusion_refuted (G : Geometry) (audience : Audience) :
    ¬ Exclusion (initial G) audience := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceChallenge.lean#L31-L32) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceProofs.lean#L65-L70)

## Can exclusion hold throughout a full solving trace?

`full_hybrid_exclusion_refuted`

**Proof request**

Use the initial state to disprove exclusion throughout a solving trace.

**Reading the result**

The trace starts at the prescribed initial state, which already violates it.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_hybrid_exclusion_refuted (tr : Trace) (hsol : Solves tr) (audience : Audience) :
    ¬ ExclusionThroughout tr audience := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceChallenge.lean#L34-L35) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceProofs.lean#L72-L77)

## What happens to an individual’s pulley readout across a successful write?

`write_preserves_personal_pulley`

**Proof request**

Prove preservation of the individual pulley view by an accepted write.

**Reading the result**

The write preserves the personal fields used by that readout.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem write_preserves_personal_pulley (G : Geometry) (s w : State) (record : Record)
    (hw : writeEvent G s record = some w) (i : Actor) : pulleyView w i = pulleyView s i := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceChallenge.lean#L37-L38) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceProofs.lean#L79-L82)

## Can the whole occupied region change solely because of an accepted write?

`write_preserves_whole_regions`

**Proof request**

Prove preservation of each complete occupied region by an accepted write.

**Reading the result**

The fields defining every constituent guard have the same values afterward.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem write_preserves_whole_regions (G : Geometry) (s w : State) (record : Record)
    (hw : writeEvent G s record = some w) (audience : Audience) (i : Actor) :
    occupiedRegion w audience i = occupiedRegion s audience i := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceChallenge.lean#L40-L42) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceProofs.lean#L84-L90)

## What about an accepted scheduled boundary?

`boundary_preserves_whole_regions`

**Proof request**

Prove preservation of the occupied regions across a successful boundary.

**Reading the result**

Each boundary operation preserves the whole occupied regions at the jump.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem boundary_preserves_whole_regions (q : ℕ) (s w : FullState)
    (hw : boundary q s = some w) (audience : Audience) (i : Actor) :
    occupiedRegion w.state audience i = occupiedRegion s.state audience i := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceChallenge.lean#L44-L46) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceProofs.lean#L102-L115)

## Can a checkpoint switch exclusion on or off by itself?

`boundary_preserves_exclusion_status`

**Proof request**

Show that both sides of an accepted boundary have equivalent exclusion status.

**Reading the result**

Before and after the accepted boundary the defining sets agree, giving equivalent exclusion statements.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem boundary_preserves_exclusion_status (q : ℕ) (s w : FullState)
    (hw : boundary q s = some w) (audience : Audience) :
    Exclusion w.state audience ↔ Exclusion s.state audience := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceChallenge.lean#L48-L50) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceProofs.lean#L117-L120)

## Which occupied regions enter a delayed social readout?

`delay_uses_buffered_regions`

**Proof request**

Recover the past occupied regions from the mixed delayed state.

**Reading the result**

Their personal fields come from the past social block.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem delay_uses_buffered_regions (present past : State) (audience : Audience) (i : Actor) :
    occupiedRegion (Delay.socialFrom present past) audience i = occupiedRegion past audience i := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceChallenge.lean#L52-L53) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceProofs.lean#L122-L124)

## How does a region score move between events?

`full_region_motion`

**Proof request**

Identify the region-score derivative on a solving segment from an accepted state rate.

**Reading the result**

On a solving trace, differentiating the score at a fixed test action gives the stated rate from an accepted full velocity.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_region_motion (tr : Trace) (hsol : Solves tr) (q : ℕ) (hq : q < 5)
    (t : ℝ) (ht : t ∈ Icc (time q) (time (q+1))) (owner visitor : Actor) (z : Action) :
    ∃ rate, rhs sourceGeometry t (tr.path q t).state = some rate ∧
      HasDerivWithinAt (fun τ => regionScore (tr.path q τ).state owner visitor z)
        (regionScoreRate (tr.path q t).state rate owner visitor z)
        (Icc (time q) (time (q+1))) t := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceChallenge.lean#L55-L60) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-occupied-space-lean/V3OccupiedSpaceProofs.lean#L138-L146)
