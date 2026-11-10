# What turns with the driving direction?

Rotate grid positions, vectors and the driving direction together. Identify exact transformations and the extra conditions required by the thermal write, gradient and social-rate results.

[`V3JointFrameChallenge.lean`](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean) · [Package configuration](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 Nous Volition. All rights reserved. The repository notice applies to material for which Nous Volition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean) · [V3JointFrameDefinitions](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameDefinitions.lean) · [Statement and proof inputs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/lake-manifest.json).

</details>

## Does scaling a vector commute with a quarter turn?

`quarter_scale`

**Proof request**

Commute a scalar multiplication with the quarter turn.

**Reading the result**

Applying the coordinate permutation and sign changes before or after scaling gives equal coordinates.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem quarter_scale (a : ℝ) (v : Vec) :
  quarterVector (fun i => a*v i)=fun i => a*quarterVector v i := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L6-L7) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L9-L12)

## Does the quarter turn preserve a dot product?

`quarter_dot`

**Proof request**

Prove that the quarter turn preserves dot products.

**Reading the result**

Its signed permutation preserves each paired product in the sum.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem quarter_dot (u v : Vec) : dot (quarterVector u) (quarterVector v)=dot u v := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L8) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L14-L16)

## Does it preserve squared length?

`quarter_norm`

**Proof request**

Prove that it preserves squared vector length.

**Reading the result**

Taking the same vector in both slots of the dot product gives the result.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem quarter_norm (v : Vec) : sqnorm (quarterVector v)=sqnorm v := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L9) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L18-L20)

## Can the rotated grid index always be recovered?

`grid_inverse`

**Proof request**

Prove both inverse identities for the grid quarter turn.

**Reading the result**

The forward and inverse quarter-grid maps undo each other in both orders.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem grid_inverse (x : Grid) :
  forwardQuarterGrid (inverseQuarterGrid x)=x ∧ inverseQuarterGrid (forwardQuarterGrid x)=x := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L10-L11) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L22-L25)

## Does rotating the grid change a scalar total?

`grid_sum`

**Proof request**

Show invariance of the full scalar grid sum.

**Reading the result**

The transformation permutes the finite grid points, preserving their sum.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem grid_sum (f : Scalar) : (∑ x, scalarPull f x)=∑ x, f x := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L12) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L30-L31)

## How does the centered gradient transform?

`centered_gradient_covariant`

**Proof request**

Derive the rotated centered-gradient formula at matched grid points.

**Reading the result**

The signed coordinate permutation carries the gradient at the inverse grid point to the gradient of the turned state.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem centered_gradient_covariant (s : State) (x : Grid) :
  centeredGradient (quarterState s) x=quarterVector (centeredGradient s (inverseQuarterGrid x)) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L13-L14) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L39-L42)

## Does the force magnitude change under this turn?

`force_amplitude_invariant`

**Proof request**

Prove invariance of force amplitude at corresponding points.

**Reading the result**

The amplitude at the turned grid point equals the original amplitude at the matching inverse point.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem force_amplitude_invariant (s : State) (x : Grid) :
  forceAmplitude (quarterState s) x=forceAmplitude s (inverseQuarterGrid x) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L15-L16) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L44-L46)

## How does the directed-force version recover the original force?

`original_force_recovered`

**Proof request**

Recover the original force from the directed force at the reference direction.

**Reading the result**

Choosing the reference direction gives the original forcing formula exactly.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem original_force_recovered (s : State) : directedForce referenceDirection s=forcing s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L17) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L48-L50)

## Where does the reference drive point after a quarter turn?

`driving_direction_rotates`

**Proof request**

Evaluate the reference direction after the quarter turn.

**Reading the result**

The first-axis direction becomes the second-axis unit vector.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem driving_direction_rotates : quarterVector referenceDirection=![0,1,0] := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L18) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L52-L58)

## What if the drive direction turns with the state?

`joint_force_covariant`

**Proof request**

Prove covariance of the force when both its direction and state turn.

**Reading the result**

The directed force then equals the rotated and reindexed original vector field.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem joint_force_covariant (d : Vec) (s : State) :
  directedForce (quarterVector d) (quarterState s)=vectorPull (directedForce d s) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L19-L20) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L60-L65)

## Does the pointwise work density agree in those two frames?

`force_work_density_invariant`

**Proof request**

Prove equality of the pointwise work densities at matching points.

**Reading the result**

Both velocity and force rotate together, preserving their dot product at corresponding points.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem force_work_density_invariant (d : Vec) (s : State) (x : Grid) :
  dot (velocity (quarterState s) x) (directedForce (quarterVector d) (quarterState s) x)=
  dot (velocity s (inverseQuarterGrid x)) (directedForce d s (inverseQuarterGrid x)) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L21-L23) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L71-L75)

## Can the original momentum equation be recovered exactly?

`original_momentum_recovered`

**Proof request**

Recover original momentum at the reference direction.

**Reading the result**

Choosing the reference direction in the frame-dependent version reproduces the original momentum rate.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem original_momentum_recovered (G : Geometry) (s : State) :
  momentumInFrame referenceDirection G s=momentumRate G s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L24-L25) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L77-L80)

## What about all the rate fields calculated from records?

`original_full_rates_recovered`

**Proof request**

Recover all original record-based rates at that direction.

**Reading the result**

At the reference direction the constructed rate equals the original full rate field by field.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem original_full_rates_recovered (G : Geometry) (t : ℝ) (s : State) (rs) :
  ratesInFrame referenceDirection G t s rs=rhsFromRecords G t s rs := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L26-L27) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L82-L85)

## Do the original acceptance decisions also agree?

`original_accepted_rates_recovered`

**Proof request**

Recover the full original optional rate there.

**Reading the result**

With the reference direction the optional rate calculation reproduces the original result, including rejection.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem original_accepted_rates_recovered (G : Geometry) (t : ℝ) (s : State) :
  acceptedInFrame referenceDirection G t s=rhs G t s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L28-L29) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L87-L90)

## Which parts of the rate agree for any drive direction?

`non_driving_rates_unchanged`

**Proof request**

Identify the non-driving rates shared with the original system for arbitrary drive direction.

**Reading the result**

The fields listed in the non-driving comparison agree with their original values.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem non_driving_rates_unchanged (d : Vec) (G : Geometry) (t : ℝ) (s : State) (rs) :
  SameNonDrivingRates (ratesInFrame d G t s rs) (rhsFromRecords G t s rs) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L30-L31) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L92-L94)

## Does total force work in the ledger change under the joint turn?

`force_work_ledger_invariant`

**Proof request**

Prove invariance of the force-work ledger under the joint turn.

**Reading the result**

Pointwise work agrees at corresponding points and the sum over the rotated grid is equal.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem force_work_ledger_invariant (d : Vec) (G : Geometry) (t : ℝ) (s : State) (rs) :
  (ratesInFrame (quarterVector d) G t (quarterState s) rs).ledger 1=
  (ratesInFrame d G t s rs).ledger 1 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L32-L34) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L96-L106)

## How does the quarter turn affect particle Green strain?

`green_spatially_invariant`

**Proof request**

Prove spatial quarter-turn invariance of Green strain at each particle.

**Reading the result**

Its matrix preserves the Gram product at each particle.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem green_spatially_invariant (F : Particle → Mat) (p : Particle) :
  green (quarterFabric F p)=green (F p) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L35-L36) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L108-L112)

## Can the spatial turn change which records decode?

`records_spatially_invariant`

**Proof request**

Prove invariance of the decoded records under the whole-state quarter turn.

**Reading the result**

The fabric probe recovers the same cell values, so the decoder gives the same result.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem records_spatially_invariant (s : State) : readRecords (quarterState s)=readRecords s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L37) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L118-L119)

## Does the cue used to weight a memory turn into a different cue?

`memory_feature_invariant`

**Proof request**

Prove equality of memory features after the spatial turn.

**Reading the result**

The relevant context and strain readings agree, giving identical memory features.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem memory_feature_invariant (G : Geometry) (s : State) :
  memoryFeature G (quarterState s)=memoryFeature G s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L38-L39) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L126-L130)

## What happens to retrieval for the same list of records?

`retrieval_invariant`

**Proof request**

Prove equality of retrieval at the same supplied records.

**Reading the result**

The weights and exposure denominator agree in both states, giving identical retrieved channels.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem retrieval_invariant (G : Geometry) (s : State) (rs) :
  memory G (quarterState s) rs=memory G s rs := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L40-L41) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L142-L145)

## Can the same event acquire a different record when both fabric snapshots turn?

`event_record_invariant`

**Proof request**

Show that transformed current and starting fabric produce the same event record.

**Reading the result**

Endpoint strain and decoded records agree, giving the same optional event.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem event_record_invariant (s : State) (startF : Particle → Mat) (id : Fin 3) :
  makeEvent (quarterState s) (quarterFabric startF) id=makeEvent s startF id := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L42-L43) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L147-L151)

## Does the write account change for the same target fabric?

`write_account_invariant`

**Proof request**

Prove equality of the write accounts for a fixed target.

**Reading the result**

The cell strain and storage inputs give equal target, heat, work and budget values.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem write_account_invariant (G : Geometry) (s : State) (target : Cell → ℝ) :
  writeAccount G (quarterState s) target=writeAccount G s target := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L44-L45) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L162-L165)

## When does the full write commute with the spatial turn?

`write_equivariant_under_thermal_compatibility`

**Proof request**

Prove that a complete write commutes with the turn under the thermal compatibility hypothesis.

**Reading the result**

Under the stated thermal compatibility, rejected writes match and successful states transform into each other.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem write_equivariant_under_thermal_compatibility (h : ThermalFrameCompatibility)
  (G : Geometry) (s : State) (r : Record) :
  writeEvent G (quarterState s) r=(writeEvent G s r).map quarterState := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L46-L48) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L189-L214)

## Does capturing an event commute with rotating the full state?

`capture_equivariant`

**Proof request**

Prove that the full-state turn commutes with capture.

**Reading the result**

Both orders store the correspondingly turned starting fabric.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem capture_equivariant (id : Fin 3) (y : FullState) :
  capture id (quarterFull y)=quarterFull (capture id y) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L49-L50) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L216-L224)

## Does rotating a mixed present-and-past state work field by field?

`buffer_commutes`

**Proof request**

Commute the quarter turn through the present–past block selection.

**Reading the result**

Taking the selected blocks and applying the spatial turn commute.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem buffer_commutes (present past : State) :
  socialFrom (quarterState present) (quarterState past)=quarterState (socialFrom present past) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L51-L52) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L226-L227)

## What does the delayed rate give in the reference direction?

`original_delay_recovered`

**Proof request**

Recover the original delayed full rate at the reference direction.

**Reading the result**

The frame-dependent construction reduces to the original delayed equation.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem original_delay_recovered (G : Geometry) (t : ℝ) (present past : State) :
  delayedInFrame referenceDirection G t present past=rhsDelayed G t present past := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L53-L54) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L229-L232)

## Can a derivative be rotated along with the whole state?

`derivative_covariant`

**Proof request**

Carry the full within-set state derivative through the quarter turn.

**Reading the result**

The fixed coordinate rearrangements and signs carry the within-set derivative to the transformed derivative.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem derivative_covariant (s : ℝ → State) (d : State) (I : Set ℝ) (t : ℝ)
  (h : StateHasDerivWithinAt s d I t) :
  StateHasDerivWithinAt (fun r => quarterState (s r)) (quarterState d) I t := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L55-L57) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L234-L257)

## Does continuity survive the same spatial turn?

`continuity_covariant`

**Proof request**

Prove continuity of the transformed state path on the same time set.

**Reading the result**

The coordinate transformations preserve continuity on the specified set.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem continuity_covariant (s : ℝ → State) (I : Set ℝ) (h : ContinuousStateOn s I) :
  ContinuousStateOn (fun r => quarterState (s r)) I := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L58-L59) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L259-L279)

## What algebra makes the deformation rate rotate correctly?

`kinematic_matrix_covariance`

**Proof request**

Prove the matrix identity for the conjugated gradient and rotated fabric.

**Reading the result**

Conjugating the gradient matrix and turning the fabric columns gives the original matrix product turned column by column.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem kinematic_matrix_covariance (L F : Mat) :
  mm (conjugateQuarter L) (fun i j => quarterVector (fun k => F k j) i)=
  fun i j => quarterVector (fun k => mm L F k j) i := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L60-L62) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L281-L286)

## What extra condition lets the full deformation rate obey that identity?

`full_deformation_covariant_if_gradient_transforms`

**Proof request**

Derive covariance of the full deformation rate from the particle-gradient transformation.

**Reading the result**

The actual particle gradient must transform as stated. Substitution then gives equality of the transformed deformation-rate fields.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_deformation_covariant_if_gradient_transforms (d : Vec) (G : Geometry)
  (t : ℝ) (s : State) (rs)
  (h : ∀ p, particleGradient (quarterState s) p=conjugateQuarter (particleGradient s p)) :
  (ratesInFrame (quarterVector d) G t (quarterState s) rs).F=
  (quarterState (ratesInFrame d G t s rs)).F := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L63-L67) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L288-L297)

## What extra information makes the social rates agree?

`social_rates_invariant_if_observations_match`

**Proof request**

Derive equality of the social rates when the observation fields agree.

**Reading the result**

Assuming the observations match, the invariant retrieval inputs yield equal social rates.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem social_rates_invariant_if_observations_match (G : Geometry) (t : ℝ) (s : State) (rs)
  (h : observations G (quarterState s)=observations G s) :
  socialRates G t (quarterState s) rs=socialRates G t s rs := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameChallenge.lean#L68-L70) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-joint-frame-lean/V3JointFrameProofs.lean#L299-L306)
