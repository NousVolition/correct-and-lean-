# Did the cue really leave and come back?

Distinguish an exact revisit from a sampled return inside a radius after leaving it. A matching witness can settle the episode while the cue stays far away.

[`CueReturnChallenge.lean`](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/CueReturnChallenge.lean) · [Package configuration](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 NousVolition. All rights reserved. The repository notice applies to material for which NousVolition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The Traveller examples come from the repository’s SIMS model and study records. [Original model and studies](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/README.md).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/SimsMeeting.lean) · [CueReturnModel](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/CueReturnModel.lean) · [TwoMemoryModel](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoMemoryModel.lean) · [Package account](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/README.md) · [Statement and proof inputs](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/lake-manifest.json).

</details>

## With only two cue samples, what counts as a return?

`two_samples_return_iff`

**Proof request**

Characterize a two-sample return by a strict excursion followed by a sample within radius.

**Reading the result**

The first must be strictly outside the radius and the second within it, including the boundary.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem two_samples_return_iff (first : ℝ) (radius : ℝ≥0) (a b : Focus) :
    ReturnedWithin first radius [a, b] ↔
      (radius : ℝ) < |a.cue - first| ∧ |b.cue - first| ≤ (radius : ℝ) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/CueReturnChallenge.lean#L10-L12) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/CueReturnProofs.lean#L8-L11)

## Does repeatedly looking at the starting cue count as leaving and returning?

`staying_is_not_returning`

**Proof request**

Give two exact revisits that fail the excursion-and-reentry test.

**Reading the result**

It meets the exact-visit rule but supplies no preceding excursion outside the radius.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem staying_is_not_returning (first : ℝ) (radius : ℝ≥0) :
    ReturnsTo first [.look first, .look first] ∧
      ¬ ReturnedWithin first radius [.look first, .look first] := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/CueReturnChallenge.lean#L14-L16) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/CueReturnProofs.lean#L15-L18)

## Which side of the radius counts as re-entry?

`sampled_return_controls`

**Proof request**

Evaluate the order, exact-return and radius-boundary controls.

**Reading the result**

The five controls check order, exact equality and distance. With radius 0.1, a return to 0.1 is included while 0.11 is outside.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem sampled_return_controls :
    ReturnedWithin 0 (1/10) [.look 1, .look (1/20)] ∧
    ¬ ReturnsTo 0 [.look 1, .look (1/20)] ∧
    ¬ ReturnedWithin 0 (1/10) [.look (1/20), .look 1] ∧
    ReturnedWithin 0 (1/10) [.look 1, .look (1/10)] ∧
    ¬ ReturnedWithin 0 (1/10) [.look 1, .look (11/100)] := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/CueReturnChallenge.lean#L18-L23) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/CueReturnProofs.lean#L22-L28)

## How do cue distances translate into log-odds distances?

`log_odds_distance`

**Proof request**

Derive the absolute log-odds distance for two cues.

**Reading the result**

The odds are exponential in twice the cue, so the absolute log-odds difference equals twice the absolute cue difference.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem log_odds_distance (a b : ℝ) :
    |Real.log (TwoMemoryTransport.odds b) - Real.log (TwoMemoryTransport.odds a)| =
      2 * |b - a| := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/CueReturnChallenge.lean#L25-L27) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/CueReturnProofs.lean#L31-L35)

## Can changing only the later attention route change the witness report?

`report_ignores_attention`

**Proof request**

Prove equality of reports when only the attention list changes.

**Reading the result**

The report uses the episode, witness, acceptance and time. Varying the attention list leaves it equal.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem report_ignores_attention (ref : EpisodeRef) (a b : List Focus)
    (w : WitnessReply) (accepted : Bool) (now : ℚ) :
    (receive ref a w accepted now).report = (receive ref b w accepted now).report := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/CueReturnChallenge.lean#L29-L31) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/CueReturnProofs.lean#L39-L41)

## Can the right episode be recognized far from the original cue?

`recognition_beyond_any_radius`

**Proof request**

Construct a matching pager report after a route that stays outside any given return radius.

**Reading the result**

The example stays outside any chosen radius. Before the witness arrives the report is open and afterward it identifies the pager.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem recognition_beyond_any_radius (radius : ℝ≥0) :
    let later := [Focus.look ((radius : ℝ) + 1), Focus.look ((radius : ℝ) + 2)]
    (∀ step ∈ later, (radius : ℝ) < |step.cue - 0|) ∧
    ¬ ReturnedWithin 0 radius later ∧
    (receive ⟨7, 0⟩ later ⟨7, 1, some .pager⟩ true 0).report.answer = none ∧
    (receive ⟨7, 0⟩ later ⟨7, 1, some .pager⟩ true 2).report = ⟨7, some .pager⟩ := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/CueReturnChallenge.lean#L33-L38) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/CueReturnProofs.lean#L45-L53)

## Does coming back close guarantee the witness is talking about the right episode?

`returning_does_not_match_the_episode`

**Proof request**

Exhibit a cue return that fails or succeeds according to the witness’s episode identifier.

**Reading the result**

The same return stays open for episode seven and resolves episode eight when the witness names eight.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem returning_does_not_match_the_episode :
    let later := [Focus.look 1, Focus.look (1/20)]
    let witness : WitnessReply := ⟨8, 1, some .pager⟩
    ReturnedWithin 0 (1/10) later ∧
    (receive ⟨7, 0⟩ later witness true 2).report = ⟨7, none⟩ ∧
    (receive ⟨8, 0⟩ later witness true 2).report = ⟨8, some .pager⟩ := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/CueReturnChallenge.lean#L40-L45) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/CueReturnProofs.lean#L57-L63)
