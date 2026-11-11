# Fabric sign changes across the full model

Follow a fixed per-particle choice of sign through stress, events, delayed rates and whole trajectories. A separate quarter-turn example probes the preferred force direction.

[`V3CovarianceChallenge.lean`](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean) · [Package configuration](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 NousVolition. All rights reserved. The repository notice applies to material for which NousVolition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean) · [V3CovarianceDefinitions](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceDefinitions.lean) · [Statement and proof inputs](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/lake-manifest.json).

</details>

## What if each selected fabric sign is flipped twice?

`state_involution`

**Proof request**

Prove that applying the same particle sign transformation twice is the identity.

**Reading the result**

Applying the same sign choice twice returns every particle’s original deformation and hence the original state.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem state_involution (ε : Particle → Bool) (s : State) :
    signState ε (signState ε s)=s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean#L8-L9) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean#L118-L124)

## Does the sign choice change any social field?

`same_social_state`

**Proof request**

Prove equality of all social state fields after the sign transformation.

**Reading the result**

The transformation acts on the fabric and preserves the entire social block.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem same_social_state (ε : Particle → Bool) (s : State) :
    SameSocial (signState ε s) s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean#L10-L11) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean#L126-L127)

## Can the sign choice change material stress?

`material_stress_invariant`

**Proof request**

Prove invariance of material stress.

**Reading the result**

Each sign-sensitive occurrence is paired so the two signs cancel in the stress formula.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem material_stress_invariant (ε : Particle → Bool) (G : Geometry) (s : State) :
    materialStress G (signState ε s)=materialStress G s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean#L12-L13) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean#L129-L133)

## What happens to the fabric stress under that reversal?

`fabric_stress_invariant`

**Proof request**

Prove invariance of fabric stress.

**Reading the result**

Each relevant deformation product has two factors from the same particle, preserving the stress.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem fabric_stress_invariant (ε : Particle → Bool) (s : State) :
    fabricStress (signState ε s)=fabricStress s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean#L14-L15) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean#L135-L139)

## Can this change affect the extra conductivity?

`extra_conductivity_invariant`

**Proof request**

Prove invariance of extra conductivity.

**Reading the result**

The deformation enters through sign-invariant combinations, giving equal conductivity.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem extra_conductivity_invariant (ε : Particle → Bool) (G : Geometry) (s : State) :
    extraConductivity G (signState ε s)=extraConductivity G s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean#L16-L17) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean#L141-L145)

## Does reversing a fiber change its rate reading?

`fiber_rate_invariant`

**Proof request**

Prove invariance of each fiber rate.

**Reading the result**

Both fiber factors acquire the same sign and their product retains its value.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem fiber_rate_invariant (ε : Particle → Bool) (G : Geometry) (s : State) :
    fiberRate G (signState ε s)=fiberRate G s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean#L18-L19) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean#L147-L151)

## Does computing all rates from records respect this sign choice?

`full_rhs_equivariant`

**Proof request**

Prove equivariance of the full rate computed with the supplied record list.

**Reading the result**

Component by component, the transformed input gives the sign-transformed full rate.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_rhs_equivariant (ε : Particle → Bool) (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) :
    rhsFromRecords G t (signState ε s) rs=signState ε (rhsFromRecords G t s rs) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean#L20-L22) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean#L214-L222)

## Do rejection and acceptance also respect the sign change?

`accepted_rhs_equivariant`

**Proof request**

Prove equivariance of the optional full rate, covering success and rejection.

**Reading the result**

The checks agree, and a successful result is the corresponding signed rate.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem accepted_rhs_equivariant (ε : Particle → Bool) (G : Geometry) (t : ℝ) (s : State) :
    rhs G t (signState ε s)=(rhs G t s).map (signState ε) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean#L23-L24) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean#L224-L233)

## Does an event contain a trace of this orientation sign?

`event_record_invariant`

**Proof request**

Prove equality of event records when both fabric snapshots receive the sign transformation.

**Reading the result**

Transforming both start and current fabric preserves the strain-based record and its decoding outcome.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem event_record_invariant (ε : Particle → Bool) (s : State)
    (startF : Particle → Mat) (id : Fin 3) :
    makeEvent (signState ε s) (signedFabric ε startF) id=makeEvent s startF id := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean#L25-L27) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean#L235-L240)

## Can the fabric sign affect a write outcome?

`write_equivariant`

**Proof request**

Show that signing the fabric commutes with the complete optional event write.

**Reading the result**

Both orders reject together or return states related by that same sign change.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem write_equivariant (ε : Particle → Bool) (G : Geometry) (s : State) (r : Record) :
    writeEvent G (signState ε s) r=(writeEvent G s r).map (signState ε) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean#L28-L29) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean#L242-L245)

## Can the sign change be made before or after capturing an event?

`capture_equivariant`

**Proof request**

Show that signing a full state commutes with capturing an event.

**Reading the result**

The saved starting fabric receives the same sign in either order.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem capture_equivariant (ε : Particle → Bool) (id : Fin 3) (y : FullState) :
    capture id (signFull ε y)=signFull ε (capture id y) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean#L30-L31) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean#L247-L252)

## Does completing an event commute with the sign change?

`complete_event_equivariant`

**Proof request**

Prove equivariance of successful or rejected event completion.

**Reading the result**

Building the event and writing it preserve corresponding optional results.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem complete_event_equivariant (ε : Particle → Bool) (id : Fin 3) (y : FullState) :
    completeEvent id (signFull ε y)=(completeEvent id y).map (signFull ε) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean#L32-L33) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean#L302-L304)

## Does this extend to every scheduled boundary?

`all_boundaries_equivariant`

**Proof request**

Prove equivariance for all scheduled boundary operations.

**Reading the result**

Each branch of the boundary rule respects the same transformation.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem all_boundaries_equivariant (ε : Particle → Bool) (k : ℕ) (y : FullState) :
    boundary k (signFull ε y)=(boundary k y).map (signFull ε) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean#L34-L35) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean#L306-L315)

## Does it matter whether signs are changed before or after combining present and past?

`buffer_commutes`

**Proof request**

Commute the sign transformation through the present–past block selection.

**Reading the result**

Selecting physical and social blocks commutes with applying the common sign choice.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem buffer_commutes (ε : Particle → Bool) (present past : State) :
    socialFrom (signState ε present) (signState ε past)=signState ε (socialFrom present past) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean#L36-L37) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean#L317-L318)

## Does the delayed rate respect that sign choice?

`delayed_rhs_equivariant`

**Proof request**

Prove equivariance of the delayed optional rate.

**Reading the result**

Both internal rate calls and the block combination respect it, including rejection.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem delayed_rhs_equivariant (ε : Particle → Bool) (G : Geometry) (t : ℝ)
    (present past : State) :
    rhsDelayed G t (signState ε present) (signState ε past)=
      (rhsDelayed G t present past).map (signState ε) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean#L38-L41) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean#L320-L328)

## Can the whole delayed history be transformed at once?

`delayed_history_equivariant`

**Proof request**

Transport the entire delayed rate lookup through the signed history.

**Reading the result**

Signing each lookup in the history gives the correspondingly signed optional rate at time t.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem delayed_history_equivariant (ε : Particle → Bool) (G : Geometry) (τ t : ℝ)
    (history : ℝ → State) :
    rhsAlong G τ (fun r => signState ε (history r)) t=
      (rhsAlong G τ history t).map (signState ε) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean#L42-L45) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean#L330-L334)

## How does a derivative on a time set transform?

`derivative_covariant`

**Proof request**

Transform a within-set state derivative under a fixed particle sign choice.

**Reading the result**

A fixed per-particle sign passes through differentiation, giving the signed derivative.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem derivative_covariant (ε : Particle → Bool) (s : ℝ → State) (d : State)
    (I : Set ℝ) (t : ℝ) (h : StateHasDerivWithinAt s d I t) :
    StateHasDerivWithinAt (fun r => signState ε (s r)) (signState ε d) I t := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean#L46-L48) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean#L336-L345)

## Can the sign change introduce a discontinuity?

`continuity_covariant`

**Proof request**

Show that sign transformation preserves continuity on the time set.

**Reading the result**

Each affected coordinate is multiplied by a fixed sign, preserving continuity on the set.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem continuity_covariant (ε : Particle → Bool) (s : ℝ → State) (I : Set ℝ)
    (h : ContinuousStateOn s I) :
    ContinuousStateOn (fun r => signState ε (s r)) I := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean#L49-L51) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean#L347-L356)

## Will the signed history still satisfy the delayed segment law?

`delayed_segment_covariant`

**Proof request**

Transport the delayed segment solution predicate to the signed history.

**Reading the result**

The transformed rates, derivatives and continuity give a solution of the corresponding signed segment.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem delayed_segment_covariant (ε : Particle → Bool) (G : Geometry) (τ : ℝ)
    (history : ℝ → State) (I : Set ℝ) (h : DelayedSegment G τ history I) :
    DelayedSegment G τ (fun t => signState ε (history t)) I := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean#L52-L54) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean#L358-L366)

## How does the generalized initial-value formulation relate to the original one?

`original_solution_predicate`

**Proof request**

Recover the original solution predicate at the designated initial state.

**Reading the result**

Substituting the original full initial state makes the two solution predicates equivalent.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem original_solution_predicate (tr : Trace) :
    SolvesFrom initialFull tr ↔ Solves tr := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean#L55-L56) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean#L368-L369)

## What happens to a whole trace started from a transformed state?

`full_trace_covariant`

**Proof request**

Carry a solving trace to a trace from the correspondingly signed initial state.

**Reading the result**

Applying the same sign choice to the states, captures and path produces a trace solving the transformed initial-value problem.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_trace_covariant (ε : Particle → Bool) (y₀ : FullState) (tr : Trace)
    (h : SolvesFrom y₀ tr) :
    SolvesFrom (signFull ε y₀) (signTrace ε tr) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean#L57-L59) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean#L371-L390)

## Is the prescribed initial state itself fixed under universal reversal?

`initial_reversal_is_not_fixed`

**Proof request**

Distinguish the fully reversed initial state from the prescribed initial state.

**Reading the result**

Reversing every fabric sign changes a nonzero initial fabric entry.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem initial_reversal_is_not_fixed :
    signFull (fun _ => true) initialFull ≠ initialFull := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean#L60-L61) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean#L392-L396)

## In which coordinates can the built-in force act?

`forcing_has_fixed_direction`

**Proof request**

Show that the original force has zero second and third components.

**Reading the result**

Its second and third components are identically zero by definition.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem forcing_has_fixed_direction (s : State) (x : Grid) :
    forcing s x 1=0 ∧ forcing s x 2=0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean#L62-L63) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean#L398-L399)

## How strong is the centered gradient in the explicit example?

`gradient_witness_norm`

**Proof request**

Compute the squared centered-gradient norm of the selected witness.

**Reading the result**

At the selected grid point its squared norm is exactly one.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem gradient_witness_norm (G : Geometry) :
    sqnorm (centeredGradient (gradientWitness G) zeroGrid)=1 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean#L64-L65) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean#L401-L404)

## Does that example actually have a nonzero force?

`witness_force_nonzero`

**Proof request**

Prove strict negativity of its first force component.

**Reading the result**

Its first force component at the chosen grid point is strictly negative.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem witness_force_nonzero (G : Geometry) :
    forcing (gradientWitness G) zeroGrid 0<0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean#L66-L67) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean#L406-L417)

## Does a spatial quarter turn carry the full force to its rotated value?

`quarter_turn_force_not_covariant`

**Proof request**

Exhibit the failure of quarter-turn covariance for the original force.

**Reading the result**

The witness leaves a nonzero force in a preferred direction, giving different vectors in the two calculations.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem quarter_turn_force_not_covariant (G : Geometry) :
    forcing (quarterState (gradientWitness G)) zeroGrid ≠
      quarterVector (forcing (gradientWitness G) (inverseQuarterGrid zeroGrid)) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceChallenge.lean#L68-L70) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-covariance-lean/V3CovarianceProofs.lean#L419-L429)
