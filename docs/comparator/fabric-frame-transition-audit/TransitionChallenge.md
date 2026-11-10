# Turning a measurement and turning its rate

Compare a piece of fabric seen in a moving frame with the same fabric evolving under a rate law. Two paths can agree initially and already have opposite strain derivatives.

[`TransitionChallenge.lean`](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/fabric-frame-transition-audit/TransitionChallenge.lean) · [Package configuration](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/fabric-frame-transition-audit/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 Nous Volition. All rights reserved. The repository notice applies to material for which Nous Volition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The transition audit retains its earlier covariance and joint-frame references. [Source reference files](https://github.com/NousVolition/correct-and-lean-/tree/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/fabric-frame-transition-audit/references).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/fabric-frame-transition-audit/TransitionProofs.lean) · [TransitionDefinitions](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/fabric-frame-transition-audit/TransitionDefinitions.lean) · [Statement and proof inputs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/fabric-frame-transition-audit/verification-inputs.json) · [Verification record](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/fabric-frame-transition-audit/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/fabric-frame-transition-audit/lake-manifest.json).

</details>

## What fabric rate does an accepted calculation actually return?

`actual_accepted_fabric_rate`

**Proof request**

Extract the position-specific deformation rate from a successful full rate evaluation.

**Reading the result**

Reading its deformation field gives the particle velocity gradient multiplied by the current deformation.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem actual_accepted_fabric_rate (G : Geometry) (s d : State) (t : ℝ) (p : Particle)
    (accepted : rhs G t s=some d) : d.F p=mm (particleGradient s p) (s.F p) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/fabric-frame-transition-audit/TransitionChallenge.lean#L7-L8) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/fabric-frame-transition-audit/TransitionProofs.lean#L10-L17)

## Does changing orientation disturb the Green-strain reading?

`state_readout_transfers`

**Proof request**

Prove invariance of Green strain under orthogonal left multiplication.

**Reading the result**

Orthogonality cancels the frame matrix with its transpose in the strain formula.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem state_readout_transfers (Q F : Mat) (h : Orthogonal Q) :
    green (mm Q F)=green F := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/fabric-frame-transition-audit/TransitionChallenge.lean#L10-L11) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/fabric-frame-transition-audit/TransitionProofs.lean#L19-L20)

## Which transformed rate works for every fabric matrix?

`rate_law_all_fabrics_iff`

**Proof request**

Characterize the transformed rate matrix that makes the moving-frame equation hold for every fabric.

**Reading the result**

The equation holds for every fabric exactly when the new rate matrix equals the specified frame rate.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem rate_law_all_fabrics_iff (Q dQ L K : Mat) (h : Orthogonal Q) :
    (∀ F : Mat, mm dQ F+mm Q (mm L F)=mm K (mm Q F)) ↔ K=frameRate Q dQ L := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/fabric-frame-transition-audit/TransitionChallenge.lean#L13-L14) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/fabric-frame-transition-audit/TransitionProofs.lean#L36-L50)

## How does an error in the fabric rate look in moving coordinates?

`moving_frame_residual`

**Proof request**

Factor the moving-frame residual into Q times the original residual.

**Reading the result**

Expanding the transformed rate leaves the original residual multiplied on the left by the frame matrix.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem moving_frame_residual (Q dQ L F V : Mat) (h : Orthogonal Q) :
    mm dQ F+mm Q V-mm (frameRate Q dQ L) (mm Q F)=mm Q (V-mm L F) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/fabric-frame-transition-audit/TransitionChallenge.lean#L16-L17) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/fabric-frame-transition-audit/TransitionProofs.lean#L52-L59)

## Can a fabric path be read in a moving frame?

`fabric_segment_transfers`

**Proof request**

Transport the entire fabric-path equation under the stated differentiable frame change.

**Reading the result**

Differentiating the transformed path and using the frame-rate identity gives the required path equation under the stated frame assumptions.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem fabric_segment_transfers (I : Set ℝ) (F L Q dQ : ℝ → Mat)
    (hq : ∀ t ∈ I, Orthogonal (Q t)) (hdq : ∀ t ∈ I, MatrixDerivWithin Q (dQ t) I t)
    (source : fabricPath L F I) :
    fabricPath (fun t => frameRate (Q t) (dQ t) (L t)) (fun t => mm (Q t) (F t)) I := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/fabric-frame-transition-audit/TransitionChallenge.lean#L19-L22) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/fabric-frame-transition-audit/TransitionProofs.lean#L61-L69)

## Which rates do the three quarter-turn paths follow?

`quarter_paths_follow_their_rates`

**Proof request**

Verify the designated rate equation for each of the three explicit paths.

**Reading the result**

The diagonal stretch follows the diagonal rate. Left multiplication takes it to the transformed rate, while the given right-multiplied path follows the original rate.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem quarter_paths_follow_their_rates :
    fabricPath (fun _ => diagonalRate) stretch Set.univ ∧
    fabricPath (fun _ => frameRate quarterTurn 0 diagonalRate)
      (fun t => mm quarterTurn (stretch t)) Set.univ ∧
    fabricPath (fun _ => diagonalRate) (fun t => mm (stretch t) quarterTurn) Set.univ := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/fabric-frame-transition-audit/TransitionChallenge.lean#L24-L28) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/fabric-frame-transition-audit/TransitionProofs.lean#L85-L98)

## Can two paths start at the same fabric and immediately stretch in opposite ways?

`quarter_initial_agreement_and_opposite_strain_rates`

**Proof request**

Compute initial agreement, the defect entry and the two opposite strain derivatives.

**Reading the result**

At time zero the example gives equal matrices, a defect entry of two and strain-component derivatives of +1 and −1.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem quarter_initial_agreement_and_opposite_strain_rates :
    mm quarterTurn (stretch 0)=mm (stretch 0) quarterTurn ∧
    frameDefect quarterTurn 0 diagonalRate eye 0 1=2 ∧
    HasDerivAt (fun t : ℝ => green (mm quarterTurn (stretch t)) 0 0) 1 0 ∧
    HasDerivAt (fun t : ℝ => green (mm (stretch t) quarterTurn) 0 0) (-1) 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/fabric-frame-transition-audit/TransitionChallenge.lean#L30-L34) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/fabric-frame-transition-audit/TransitionProofs.lean#L111-L124)
