# Traveller questions, memory odds and recorded waits

Follow how cue odds are transported, how a witness changes an account, and what the saved observations actually measure. The finite counts below refer to the stored cases.

[`MeetingThreadChallenge.lean`](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean) · [Package configuration](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 NousVolition. All rights reserved. The repository notice applies to material for which NousVolition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The Traveller examples come from the repository’s SIMS model and study records. [Original model and studies](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/README.md).

Recorded counts, times and basin readouts come from the saved observation data. [Restaurant data](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/observations/restaurant.json) · [Basin data](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/observations/basin.json) · [Formalized observations](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingObservations.lean).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/SimsMeeting.lean) · [TwoMemoryModel](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoMemoryModel.lean) · [MeetingModel](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingModel.lean) · [MeetingObservations](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingObservations.lean) · [PagerReturnChallenge](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/PagerReturnChallenge.lean) · [CueReturnChallenge](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/CueReturnChallenge.lean) · [TwoTrembleChallenge](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoTrembleChallenge.lean) · [ReplayAuditChallenge](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditChallenge.lean) · [Package account](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/README.md) · [Statement and proof inputs](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/lake-manifest.json).

</details>

## What trajectory does a zero memory field allow?

`zeroField`

**Proof request**

Construct the unique integral solution for a zero field on the given interval.

**Reading the result**

The constant path solves the integral equation, and every other solution agrees on the stated interval.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem zeroField (a b x₀ : ℝ) (hab : a ≤ b) :
    ∃ x, Volterra.Solution (fun _ _ : ℝ => (0 : ℝ)) a b x₀ x ∧
      ∀ y, Volterra.Solution (fun _ _ : ℝ => (0 : ℝ)) a b x₀ y → EqOn y x (Icc a b) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L18-L20) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ConstantField.lean#L9-L16)

## What familiar function represents this two-memory readout?

`recall_eq_tanh`

**Proof request**

Identify the two-memory readout with tanh.

**Reading the result**

Simplifying its two weights gives tanh of the cue.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem recall_eq_tanh (s : ℝ) : memoryField s = Real.tanh s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L28) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoMemory.lean#L10-L16)

## How quickly can the readout change with the cue?

`recall_lipschitz`

**Proof request**

Prove that the memory field has Lipschitz constant one as an upper bound.

**Reading the result**

Its change in magnitude is bounded by the size of the cue change, the Lipschitz bound of one.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem recall_lipschitz : LipschitzWith 1 memoryField := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L30) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoMemory.lean#L28-L36)

## Does a starting value determine a unique memory trajectory?

`unique_memory_trajectory`

**Proof request**

Derive existence and uniqueness of the memory-driven integral solution.

**Reading the result**

Integrability and the uniform Lipschitz estimate give a solution of the integral equation and uniqueness on the interval.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem unique_memory_trajectory (a b x₀ : ℝ) (hab : a ≤ b) :
    ∃ x, Volterra.Solution (fun _ : ℝ => memoryField) a b x₀ x ∧
      ∀ y, Volterra.Solution (fun _ : ℝ => memoryField) a b x₀ y → EqOn y x (Icc a b) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L32-L34) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoMemory.lean#L39-L46)

## Can the memory readout be reconstructed from its odds?

`readout_from_odds`

**Proof request**

Express the readout as (odds − 1)/(odds + 1).

**Reading the result**

Subtracting one from the odds and dividing by odds plus one gives the readout.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem readout_from_odds (s : ℝ) :
    TwoMemory.memoryField s = (odds s - 1) / (odds s + 1) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L44-L45) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoMemoryTransport.lean#L8-L15)

## What are those odds as a function of the cue?

`odds_eq_exp`

**Proof request**

Identify cue odds with exp(2s).

**Reading the result**

The two exponential weights simplify to exp(2s).

<details>
<summary>Exact Lean statement</summary>

```lean
theorem odds_eq_exp (s : ℝ) : odds s = Real.exp (2 * s) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L47) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoMemoryTransport.lean#L17-L21)

## How do odds move between two cue values?

`update_odds`

**Proof request**

Prove that endpoint transport takes the initial odds to the final odds.

**Reading the result**

Multiplying the old odds by the transport factor gives the new odds.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem update_odds (a b : ℝ) : transport a b * odds a = odds b := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L49) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoMemoryTransport.lean#L23-L26)

## What happens to transport over two successive moves?

`compose_transport`

**Proof request**

Compose transport along two consecutive cue segments.

**Reading the result**

The intermediate odds cancel, leaving the direct transport between the endpoints.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem compose_transport (a b c : ℝ) :
    transport b c * transport a b = transport a c := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L51-L52) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoMemoryTransport.lean#L28-L33)

## Can intermediate stops change the net transport?

`endpoints_determine_transport`

**Proof request**

Prove that intermediate stops leave net transport determined by the endpoints.

**Reading the result**

Repeated composition cancels every intermediate stop and leaves only the endpoints.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem endpoints_determine_transport (a b : ℝ) (stops : List ℝ) :
    along a stops b = transport a b := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L54-L55) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoMemoryTransport.lean#L35-L39)

## What does a closed cue route do to odds?

`closed_route`

**Proof request**

Evaluate the net multiplier of a closed cue route.

**Reading the result**

Its total multiplier is one because the two endpoints agree.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem closed_route (a : ℝ) (stops : List ℝ) : along a stops a = 1 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L57) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoMemoryTransport.lean#L41-L43)

## Which differential rule transports the odds?

`odds_parallel`

**Proof request**

Derive the displayed first-order differential identity for the odds.

**Reading the result**

Differentiating their exponential form makes the derivative plus the specified coefficient times odds equal zero.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem odds_parallel (s : ℝ) : deriv odds s + cueCoefficient * odds s = 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L59) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoMemoryTransport.lean#L45-L52)

## How much curvature does the particular potential have?

`flat_curvature`

**Proof request**

Compute the curvature of the specified potential.

**Reading the result**

Evaluating the defined curvature for its components gives zero.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem flat_curvature (i j : Fin 4) (p : Point) :
    curvature potential i j p = 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L61-L62) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoMemoryTransport.lean#L54-L56)

## What residual does that potential leave in the source-free equation?

`source_free`

**Proof request**

Compute its source-free residual.

**Reading the result**

Its vanishing curvature makes the specified Yang–Mills residual zero.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem source_free (j : Fin 4) (p : Point) : yangMillsResidual potential j p = 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L64) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoMemoryTransport.lean#L58-L59)

## Is a path through the same point necessarily a solution?

`unit_speed_fails_memory_at_zero`

**Proof request**

Show the unit-speed path fails the memory differential equation at zero.

**Reading the result**

The unit-speed path passes zero with derivative one, whereas the prescribed memory field there is zero.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem unit_speed_fails_memory_at_zero :
    deriv (fun t : ℝ => t) 0 ≠ TwoMemory.memoryField 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L66-L67) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoMemoryTransport.lean#L63-L65)

## Which clock advances while waiting for a reply?

`room_paused_while_wall_advances`

**Proof request**

Prove that a positive wait advances wall time and fixes room time.

**Reading the result**

For positive wait duration, wall time advances and room time stays fixed.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem room_paused_while_wall_advances (c : Clocks) (duration : ℚ) (hd : 0 < duration) :
    (awaitReply c duration).room = c.room ∧ c.wall < (awaitReply c duration).wall := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L75-L76) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L7-L11)

## How do the two elapsed pieces relate to the whole wait?

`elapsed_interval_is_accounted_for`

**Proof request**

Derive the elapsed-time partition identity.

**Reading the result**

Adding the two intervals cancels their shared last-unsure endpoint.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem elapsed_interval_is_accounted_for (first lastUnsure firstSure : ℚ) :
    (lastUnsure - first) + (firstSure - lastUnsure) = firstSure - first := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L78-L79) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L13-L14)

## Can observations before and after a switch date its exact instant?

`samples_leave_the_instant_open`

**Proof request**

Construct two distinct switch times indistinguishable outside the observed gap.

**Reading the result**

Two distinct rational switch times fit all samples outside the gap and disagree at a time inside it.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem samples_leave_the_instant_open (l u : ℚ) (h : l < u) :
    ∃ c d : ℚ, l < c ∧ c < d ∧ d < u ∧
      (∀ t : ℚ, t ≤ l ∨ u ≤ t → (sureAt c t ↔ sureAt d t)) ∧
      sureAt c ((c+d)/2) ∧ ¬sureAt d ((c+d)/2) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L81-L84) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L18-L35)

## What changes after a matching accepted witness reply?

`same_question_before_and_after`

**Proof request**

Compare the same episode’s answer before and after an accepted matching reply.

**Reading the result**

The same episode identifier is open before arrival and has its actual cause after the reply is available.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem same_question_before_and_after (e : Tremble) (w : WitnessReply)
    (early late : ℚ) (ordered : e.occurred ≤ w.arrives)
    (before : early < w.arrives) (afterwards : w.arrives ≤ late)
    (same : w.about = e.id) (accurate : w.identifies = some e.actualCause) :
    accountAt e w true early = ⟨e.id, none⟩ ∧
    accountAt e w true late = ⟨e.id, some e.actualCause⟩ := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L86-L91) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L37-L43)

## Can different future replies give the same open past?

`different_future_replies_same_open_past`

**Proof request**

Show that the two future replies agree on the account before their arrival.

**Reading the result**

Until either witness arrives, their accounts for that episode agree.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem different_future_replies_same_open_past (e : Tremble) (a b : WitnessReply)
    (t : ℚ) (ha : t < a.arrives) (hb : t < b.arrives) :
    accountAt e a true t = accountAt e b true t := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L93-L95) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L45-L48)

## What if the witness names a different episode?

`different_episode_still_open`

**Proof request**

Show that a reply about a different episode leaves the requested answer open.

**Reading the result**

The account keeps the current episode’s answer open.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem different_episode_still_open (e : Tremble) (w : WitnessReply)
    (h : w.about ≠ e.id) (t : ℚ) :
    (accountAt e w true t).answer = none := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L97-L99) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L50-L52)

## Does hearing a reply guarantee accepting its answer?

`hearing_can_leave_the_question_open`

**Proof request**

Evaluate the answer when the witness reply is unaccepted.

**Reading the result**

With acceptance set to false, the answer remains open.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem hearing_can_leave_the_question_open (e : Tremble) (w : WitnessReply) (t : ℚ) :
    (accountAt e w false t).answer = none := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L101-L102) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L54-L55)

## Can one revisit the same cue and episode yet have a new answer?

`same_cue_same_episode_new_answer`

**Proof request**

Combine unchanged odds on the closed cue route with a changed answer about the same episode.

**Reading the result**

A closed cue route restores the odds while an arriving accepted witness changes the answer to the same question.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem same_cue_same_episode_new_answer (cue : ℝ) (stops : List ℝ)
    (e : Tremble) (w : WitnessReply) (early late : ℚ)
    (ordered : e.occurred ≤ w.arrives) (before : early < w.arrives)
    (afterwards : w.arrives ≤ late) (same : w.about = e.id)
    (accurate : w.identifies = some e.actualCause) :
    TwoMemoryTransport.along cue stops cue * TwoMemoryTransport.odds cue = TwoMemoryTransport.odds cue ∧
    (accountAt e w true early).questionAbout = (accountAt e w true late).questionAbout ∧
    (accountAt e w true early).answer ≠ (accountAt e w true late).answer := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L104-L111) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L59-L68)

## Does the time someone mentioned a test tell you when it took place?

`before_mention_does_not_date_the_test`

**Proof request**

Construct two possible test times consistent with the stated mention time.

**Reading the result**

Both the time of the feeling and a later time before mention satisfy the displayed timing information.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem before_mention_does_not_date_the_test (felt mentioned : ℚ) (h : felt < mentioned) :
    ∃ a b : ℚ, a = felt ∧ a < mentioned ∧ felt < b ∧ b < mentioned := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L113-L114) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L72-L74)

## What returns after one circuit?

`one_circuit_same_station_and_volume`

**Proof request**

Verify return of station and volume and nonnegativity of the retained and exchanged portions.

**Reading the result**

The indexed station and total volume return under the stated bounds, with both retained and incoming portions nonnegative.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem one_circuit_same_station_and_volume (p n : Nat) (hp : p < n)
    (V r : ℚ) (hV : 0 < V) (hr : 0 ≤ r) (hr' : r ≤ 1) :
    (p+n) % n = p ∧ 0 ≤ remainingVolume V r ∧
    0 ≤ r*V ∧ returnedVolume V r = V := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L116-L119) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L76-L84)

## How much marker has a circuit added or removed?

`net_marker_exchange`

**Proof request**

Compute the exact marker difference over one volume exchange.

**Reading the result**

Subtract the old amount and the difference is exchanged volume times incoming minus old concentration.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem net_marker_exchange (V r old incoming : ℚ) :
    returnedMarker V r old incoming - V*old = r*V*(incoming-old) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L121-L122) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L86-L89)

## Does equal returning volume guarantee equal contents?

`equal_volume_different_contents`

**Proof request**

Exhibit equal total volume and different returned marker content.

**Reading the result**

The example returns equal volumes with different amounts of marker.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem equal_volume_different_contents :
    returnedVolume 1 0 = returnedVolume 1 1 ∧
      returnedMarker 1 0 0 1 ≠ returnedMarker 1 1 0 1 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L124-L126) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L93-L96)

## When does marker content grow or shrink in one circuit?

`growth_or_decay_after_one_circuit`

**Proof request**

Characterize marker growth and decay by the ordering of incoming and old concentrations.

**Reading the result**

For positive exchange and volume, the sign of the change is set by incoming concentration relative to old concentration.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem growth_or_decay_after_one_circuit (V r old incoming : ℚ)
    (hV : 0 < V) (hr : 0 < r) :
    (V*old < returnedMarker V r old incoming ↔ old < incoming) ∧
    (returnedMarker V r old incoming < V*old ↔ incoming < old) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L128-L131) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L98-L113)

## What happens just across the sharp-push threshold?

`onset_at_threshold`

**Proof request**

Evaluate sharp push immediately below and above the unit threshold at the stated inputs.

**Reading the result**

Input 0.99 gives zero push, while 1.01 gives 0.01.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem onset_at_threshold : sharpPush (99/100) = 0 ∧ sharpPush (101/100) = 1/100 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L133) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L115-L116)

## Can two kinds of slowing look alike and have different physical implications?

`halved_playback_or_halved_flow`

**Proof request**

Compare half-speed playback with half-speed flow and compute the energy factor.

**Reading the result**

Half-speed playback gives the same displayed speed as halving the flow. Halving the actual velocity quarters the kinetic energy at fixed mass.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem halved_playback_or_halved_flow (m v : ℚ) :
    (1/2 : ℚ)*v = 1*(v/2) ∧ m*(v/2)^2/2 = (m*v^2/2)/4 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L135-L136) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L118-L120)

## Can a single snapshot determine the parcel path?

`same_snapshot_different_parcel_paths`

**Proof request**

Verify the two explicit path derivatives, initial agreement and later separation.

**Reading the result**

The straight and curved paths have the same position and velocity at zero, then reach different positions at time one.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem same_snapshot_different_parcel_paths :
    (∀ t : ℝ, HasDerivAt (fun s : ℝ => (s,(0:ℝ))) (1,0) t ∧
              HasDerivAt (fun s : ℝ => (s,s^2)) (1,2*t) t) ∧
    ((1,(0:ℝ)) : ℝ × ℝ) = (1,2*0) ∧
    ((0,(0:ℝ)) : ℝ × ℝ) = (0,0^2) ∧
    ((1,(0:ℝ)) : ℝ × ℝ) ≠ (1,1^2) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L138-L143) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L125-L138)

## Can there be motion both ways when net flow is zero?

`positive_gross_flow_at_zero_net`

**Proof request**

Show zero net and positive gross flow from equal positive opposed flows.

**Reading the result**

Equal positive flows in opposite directions cancel in the net sum and add in the gross sum.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem positive_gross_flow_at_zero_net (q : ℚ) (hq : 0 < q) :
    q-q = 0 ∧ 0 < q+q := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L145-L146) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L140-L141)

## Does the given upper bound on a small signal guarantee a positive energy floor?

`global_excess_allows_small_energy`

**Proof request**

Construct a positive amplitude for which the quadratic energy upper bound lies below the proposed floor.

**Reading the result**

Choose a sufficiently small positive amplitude. Every energy below its quadratic bound is then below the proposed floor.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem global_excess_allows_small_energy (C floor : ℚ) (hC : 0 < C) (hf : 0 < floor) :
    ∃ ε : ℚ, 0 < ε ∧ ∀ K : ℚ, K ≤ C*ε^2 → K < floor := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L148-L149) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L146-L157)

## What does replacing an evolved tag with a saved one change?

`scalar_refill_balance`

**Proof request**

Derive the change in total when replacing the evolved tag by the saved tag.

**Reading the result**

Subtracting the old total leaves precisely saved tag minus evolved tag.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem scalar_refill_balance (total evolvedTag savedTag : ℚ) :
    (total - evolvedTag + savedTag) - total = savedTag - evolvedTag := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L151-L152) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L161-L162)

## Can one readout reconstruct two different states with the same reading?

`same_readout_cannot_recover_both`

**Proof request**

Use two states with equal readings to rule out universal exact recovery.

**Reading the result**

A single-valued recovery function would have to return both states on the same input.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem same_readout_cannot_recover_both {S O : Type*} (readout : S → O)
    {s t : S} (different : s ≠ t) (same : readout s = readout t) :
    ¬∃ recover : O → S, ∀ x, recover (readout x) = x := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L154-L156) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L167-L171)

## Does kinetic energy reveal the heading?

`energy_alone_cannot_recover_heading`

**Proof request**

Rule out recovering both velocity components solely from the energy scalar.

**Reading the result**

Distinct velocity vectors have the same energy, preventing a recovery function from inverting every reading.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem energy_alone_cannot_recover_heading :
    ¬∃ recover : ℚ → ℚ × ℚ, ∀ v, recover (energy2 v) = v := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L158-L159) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L173-L177)

## Can the circuit count be restarted at a return?

`restart_at_return`

**Proof request**

Decompose n+m circuits into two successive runs from the intermediate state.

**Reading the result**

Running n circuits and then m more gives the same state as running n+m together.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem restart_at_return {S D : Type*} (readDir : S → D) (advance : D → S → S)
    (n m : Nat) (s : S) :
    circuits readDir advance (n+m) s =
      circuits readDir advance m (circuits readDir advance n s) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L161-L164) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L179-L185)

## Which recorded Traveller B runs first identified a pager?

`recorded_B_endpoints`

**Proof request**

Compute all ten recorded first-pager endpoints.

**Reading the result**

Evaluating the ten stored quiet/anxious profiles gives the listed first timestamps or an open result for each one.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem recorded_B_endpoints :
    [pair1Quiet, pair1Anxious, pair2Quiet, pair2Anxious, pair3Quiet, pair3Anxious, pair4Quiet, pair4Anxious, pair5Quiet, pair5Anxious].map firstPager =
      [none, none, some 24278956, none, some 24378956, none, none, none, some 24078956, some 24078956] := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L166-L168) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L187-L189)

## How was Traveller A’s recorded wait divided?

`recorded_A_time_partition`

**Proof request**

Verify the two recorded time subtotals and their combined total.

**Reading the result**

Summing the recorded millisecond intervals gives 6,460 to the last unsure reading and 1,250 more to the first sure reading, totaling 7,710.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem recorded_A_time_partition :
    (aTimesMs.map (fun p => p.2.1 - p.1)).sum = 6460 ∧
    (aTimesMs.map (fun p => p.2.2 - p.2.1)).sum = 1250 ∧
    (aTimesMs.map (fun p => p.2.2 - p.1)).sum = 7710 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L170-L173) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L191-L194)

## How many Traveller B profiles reach a pager answer?

`recorded_B_completion_counts`

**Proof request**

Compute the quiet and anxious completion counts.

**Reading the result**

The saved profiles give three completions in the quiet group and one in the anxious group.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem recorded_B_completion_counts :
    (quietReports.filterMap firstPager).length = 3 ∧
    (anxiousReports.filterMap firstPager).length = 1 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L175-L177) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L196-L198)

## Can missing endpoints change the ordering of the two means?

`missing_endpoints_allow_opposite_mean_orders`

**Proof request**

Verify the observed cutoff and exhibit opposite group-sum orders for different endpoint fillings.

**Reading the result**

All observed times fall below the stated cutoff, yet two explicit fillings of the missing endpoints yield opposite orderings of the group sums.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem missing_endpoints_allow_opposite_mean_orders :
    (quietReports ++ anxiousReports).all (fun r => r.all (fun p => p.1 < 40000000)) = true ∧
    filledSum 40000000 quietReports < filledSum 40000000 anxiousReports ∧
    filledSum 40000000 anxiousReports < filledSum 100000000 quietReports := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L179-L182) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L201-L204)

## Did the six stored second-reply follow-ups settle the pager question?

`six_followups_remained_open`

**Proof request**

Check that all six stored follow-ups remained open.

**Reading the result**

Checking their recorded flags gives six false values.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem six_followups_remained_open : pagerAfterSecondReply = List.replicate 6 false := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L184) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L206)

## What did the initial mentor and organic control flags show?

`first_mentor_controls`

**Proof request**

Evaluate the first mentor-arm and organic-profile control flags.

**Reading the result**

The first three mentor flags were false and the fourth true. All four organic flags were true.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem first_mentor_controls : initialMentorArms = [false,false,false,true] ∧
    organicProfiles = List.replicate 4 true := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L186-L187) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L208-L209)

## Could apparent trembles appear with no physical pulse at B?

`room_alert_and_false_notice_controls`

**Proof request**

Check the recorded cue schedule, alert deliveries, apparent trembles and physical pulse list.

**Reading the result**

The stored cue and delivery schedules give the listed times and an empty physical-pulse list for B.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem room_alert_and_false_notice_controls : fiveMinuteCues = [0,120,240] ∧
    finalAlertDeliveries = [[0,5],[0,5]] ∧ apparentTrembles = [0,120,240] ∧ physicalPulsesAtB = [] := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L189-L190) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L211-L212)

## How are the saved native control cases classified?

`recorded_native_controls`

**Proof request**

Check all saved control flags and the counts of the three labeled case types.

**Reading the result**

Every stored case passes its expected check, with four accepted, eight rejected and two labeled no application.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem recorded_native_controls : (strictSuiteCases.all (·.2)) = true ∧
    (strictSuiteCases.filter (fun c => c.1 == "accepted")).length = 4 ∧
    (strictSuiteCases.filter (fun c => c.1 == "rejected")).length = 8 ∧
    (strictSuiteCases.filter (fun c => c.1 == "no_application")).length = 2 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L192-L195) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L214-L217)

## Do the sampled image turns have the same orientation?

`sampled_image_turns`

**Proof request**

Verify the signs of the two sets of sampled circulations.

**Reading the result**

The stored upper circulation values are positive and the lower values are negative.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem sampled_image_turns : (∀ x ∈ upperCirculations, 0 < x) ∧ (∀ x ∈ lowerCirculations, x < 0) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L197) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L220-L227)

## What did the recorded basin startup show?

`basin_startup_readings`

**Proof request**

Check startup energy ordering and the force, speed and near-balanced flow readings.

**Reading the result**

The four energies rise from zero. The moving-H record has zero force, positive speed and positive two-way flows differing by less than 10⁻¹⁶.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem basin_startup_readings : let (a,b,c,d) := recordedStartupEnergy
    let (force,speed,into,outOf) := recordedMovingH
    a = 0 ∧ a < b ∧ b < c ∧ c < d ∧ force = 0 ∧ 0 < speed ∧
      0 < into ∧ 0 < outOf ∧ |into-outOf| < (1/10^16 : ℚ) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L199-L202) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L230-L234)

## Do successive refills use their own preceding endpoints?

`eight_refills_use_their_own_endpoints`

**Proof request**

Verify fourteen branches with eight linked refills each.

**Reading the result**

The stored fourteen branches each contain eight refills and satisfy the linked-checkpoint test.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem eight_refills_use_their_own_endpoints : basinBranches.length = 14 ∧
    basinBranches.all (fun branch => branch.length == 8 && linkedCheckpoints branch) = true := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L204-L205) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThread.lean#L236-L237)

## When can the Volterra theorem be applied to field F?

`all_premises`

**Proof request**

Apply the integral existence-and-uniqueness theorem using the stated hypotheses for F.

**Reading the result**

The ordered interval, integrability along continuous paths and uniform spatial Lipschitz estimate supply existence and uniqueness from the given start.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem all_premises (a b c x₀ : ℝ) (F G : ℝ → ℝ → ℝ) (K J : ℝ≥0)
    (e0 : a ≤ b)
    (e1 : ∀ x : ℝ → ℝ, ContinuousOn x (Icc a b) → IntervalIntegrable (fun t => F t (x t)) volume a b)
    (e2 : ∀ t ∈ Icc a b, LipschitzWith K (F t)) :
    ∃ x, Volterra.Solution F a b x₀ x ∧
      ∀ y, Volterra.Solution F a b x₀ y → EqOn y x (Icc a b) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L211-L216) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ApplicationControls.lean#L10-L16)

## What changes when the field in the conclusion is G?

`new_field_repaired`

**Proof request**

Apply it to the new field G using G’s own integrability and Lipschitz conditions.

**Reading the result**

The integrability and Lipschitz premises must cover G itself. With those hypotheses the same existence-and-uniqueness argument applies.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem new_field_repaired (a b c x₀ : ℝ) (F G : ℝ → ℝ → ℝ) (K J : ℝ≥0)
    (e0 : a ≤ b)
    (e1 : ∀ x : ℝ → ℝ, ContinuousOn x (Icc a b) → IntervalIntegrable (fun t => G t (x t)) volume a b)
    (e2 : ∀ t ∈ Icc a b, LipschitzWith K (G t)) :
    ∃ x, Volterra.Solution G a b x₀ x ∧
      ∀ y, Volterra.Solution G a b x₀ y → EqOn y x (Icc a b) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/MeetingThreadChallenge.lean#L218-L223) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ApplicationControls.lean#L18-L24)
