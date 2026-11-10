# When a replay puts two sounds in the wrong order

Use an action linked to the sound to test the replay. Compare the model’s two conflict policies with the recorded faithful and reversed trials.

[`ReplayAuditChallenge.lean`](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditChallenge.lean) · [Package configuration](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 Nous Volition. All rights reserved. The repository notice applies to material for which Nous Volition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The Traveller examples come from the repository’s SIMS model and study records. [Original model and studies](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/README.md).

The trial counts use the saved simulated reports and their project coding. [Study protocol](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/observations/reversed-replay/protocol.json) · [Trial readings](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/observations/reversed-replay/readings.tsv) · [Full reports](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/observations/reversed-replay/reports.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/SimsMeeting.lean) · [ReplayAuditReadings](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditReadings.lean) · [Package account](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/README.md) · [Statement and proof inputs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/lake-manifest.json).

</details>

## Where does a sound clue point if the two distinct replay sounds are reversed?

`reversed_sound_points_to_opposite`

**Proof request**

Show that reversing distinct sounds directs the resolver to the opposite moment.

**Reading the result**

It now matches the opposite moment from the one that produced the actual sound.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem reversed_sound_points_to_opposite (actions : OrderedMarks) (x y : Mark)
    (distinct : x ≠ y) (target : Moment) :
    let actual : OrderedMarks := ⟨x, y⟩
    resolve (replayView actions (swap actual)) (.sound (actual.atMoment target)) =
      some (opposite target) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditChallenge.lean#L8-L12) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditProofs.lean#L8-L13)

## What does an explicitly linked action tell the resolver to use?

`linked_detail_uses_the_named_action`

**Proof request**

Reduce the linked-action choice to the lookup for the named action.

**Reading the result**

When the sound matches the link, it looks up the named action as a landmark.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem linked_detail_uses_the_named_action (v : View) (sound action : Mark) :
    actionChoice v sound (.linked sound action) = resolve v (.landmark action) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditChallenge.lean#L14-L15) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditProofs.lean#L15-L17)

## What if the action and sound are merely mentioned together?

`unlinked_detail_keeps_the_sound_choice`

**Proof request**

Prove that an unlinked detail creates no conflict and preserves the sound choice under both policies.

**Reading the result**

The unlinked detail creates no conflict and both policies retain the sound-based choice.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem unlinked_detail_keeps_the_sound_choice (v : View) (w s action : Mark) :
    let e := assess v w (.unlinked s action)
    e.conflict = false ∧ e.withholdOnConflict = resolve v (.sound w) ∧
      e.trustAction = resolve v (.sound w) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditChallenge.lean#L17-L20) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditProofs.lean#L19-L27)

## Does an action linked to some other sound help here?

`unrelated_sound_supplies_no_action_match`

**Proof request**

Show that a link to a different sound produces no action choice.

**Reading the result**

The sound mismatch yields no action choice.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem unrelated_sound_supplies_no_action_match (v : View) (w s action : Mark) (diff : s ≠ w) :
    actionChoice v w (.linked s action) = none := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditChallenge.lean#L22-L23) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditProofs.lean#L29-L31)

## When do sound and action agree on the moment?

`faithful_replay_and_accurate_action_agree`

**Proof request**

Verify agreement and the correct target under faithful replay with an accurate linked action.

**Reading the result**

A faithful replay with distinct marks and an accurate link gives the target by both routes, with no conflict.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem faithful_replay_and_accurate_action_agree (ax ay sx sy : Mark)
    (ha : ax ≠ ay) (hs : sx ≠ sy) (target : Moment) :
    let actions : OrderedMarks := ⟨ax, ay⟩
    let sounds : OrderedMarks := ⟨sx, sy⟩
    let w := sounds.atMoment target
    let e := assess (replayView actions sounds) w (.linked w (actions.atMoment target))
    e = ⟨some target, some target⟩ ∧ e.conflict = false ∧
      e.withholdOnConflict = some target ∧ e.trustAction = some target := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditChallenge.lean#L25-L32) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditProofs.lean#L33-L47)

## What happens when the replay reverses the sounds but the action link is accurate?

`reversal_and_accurate_action_conflict`

**Proof request**

Compute both choices and both policy outcomes under reversed replay with an accurate linked action.

**Reading the result**

The sound chooses the opposite moment and the action chooses the target. Withholding gives an open answer, while trusting the action selects the target.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem reversal_and_accurate_action_conflict (ax ay sx sy : Mark)
    (ha : ax ≠ ay) (hs : sx ≠ sy) (target : Moment) :
    let actions : OrderedMarks := ⟨ax, ay⟩
    let sounds : OrderedMarks := ⟨sx, sy⟩
    let w := sounds.atMoment target
    let e := assess (replayView actions (swap sounds)) w (.linked w (actions.atMoment target))
    e = ⟨some (opposite target), some target⟩ ∧ e.conflict = true ∧
      e.withholdOnConflict = none ∧ e.trustAction = some target := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditChallenge.lean#L34-L41) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditProofs.lean#L49-L63)

## Can seeing a conflict tell you which source is reliable?

`conflict_alone_cannot_choose_the_reliable_source`

**Proof request**

Construct indistinguishable conflicting presentations whose correct answers differ.

**Reading the result**

Two worlds give exactly the same presented evidence but require opposite correct answers, so one decision rule cannot identify both.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem conflict_alone_cannot_choose_the_reliable_source
    (choose : View → Mark → ActionDetail → Option Moment) :
    let actions : OrderedMarks := ⟨.a, .b⟩
    let actual₁ : OrderedMarks := ⟨.a, .b⟩
    let actual₂ : OrderedMarks := ⟨.b, .a⟩
    let shown₁ := replayView actions (swap actual₁)
    let shown₂ := replayView actions actual₂
    let detail := ActionDetail.linked .a .a
    actual₁.atMoment .earlier = .a ∧ actual₂.atMoment .later = .a ∧
      actions.atMoment .earlier = .a ∧ actions.atMoment .later ≠ .a ∧
      shown₁ = shown₂ ∧
      ¬ (choose shown₁ .a detail = some .earlier ∧
         choose shown₂ .a detail = some .later) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditChallenge.lean#L43-L55) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditProofs.lean#L68-L85)

## How many recorded reversal trials are paired?

`recorded_reversal_schedule`

**Proof request**

Verify the recorded trial count, the two orders per world and the original targets.

**Reading the result**

The table has 12 trials covering both orders for six named worlds and preserves each original target.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem recorded_reversal_schedule :
    tableCells.tail.length = 12 ∧ trials.length = 12 ∧
    ["K4", "N7", "Q2", "F8", "C9", "V3"].all bothOrdersPresent = true ∧
    trials.all originalTargetPreserved = true := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditChallenge.lean#L57-L60) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditProofs.lean#L90-L93)

## What did the first choices show?

`recorded_initial_order_counts`

**Proof request**

Compute first-answer counts by order and the matches to the original resolver.

**Reading the result**

Faithful order gave five right and one open. Reversed order gave four wrong and two open. The original model fits five and four of the respective first answers.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem recorded_initial_order_counts :
    firstCounts .faithful = ⟨5, 0, 1, 0⟩ ∧ firstCounts .reversed = ⟨0, 4, 2, 0⟩ ∧
    ((orderedTrials .faithful).filter firstFitsOriginalModel).length = 5 ∧
    ((orderedTrials .reversed).filter firstFitsOriginalModel).length = 4 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditChallenge.lean#L62-L65) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditProofs.lean#L95-L98)

## How did extra detail affect faithful replays?

`recorded_faithful_followups`

**Proof request**

Compute both faithful follow-up counts and the explicit conflict counts.

**Reading the result**

Linked details gave six right answers. Unlinked details gave four right and two open, with no explicit conflicts in either set.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem recorded_faithful_followups :
    let rows := orderedTrials .faithful
    followingCounts rows .linked = ⟨6, 0, 0, 0⟩ ∧
      followingCounts rows .unlinked = ⟨4, 0, 2, 0⟩ ∧
      explicitCount rows .linked = 0 ∧ explicitCount rows .unlinked = 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditChallenge.lean#L67-L71) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditProofs.lean#L100-L104)

## What happened after reversed replays?

`recorded_reversed_followups`

**Proof request**

Compute the corresponding follow-up counts under reversed order.

**Reading the result**

Linked details gave five right and one open with one explicit conflict. Unlinked details gave four wrong and two open.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem recorded_reversed_followups :
    let rows := orderedTrials .reversed
    followingCounts rows .linked = ⟨5, 0, 1, 0⟩ ∧
      followingCounts rows .unlinked = ⟨0, 4, 2, 0⟩ ∧
      explicitCount rows .linked = 1 ∧ explicitCount rows .unlinked = 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditChallenge.lean#L73-L77) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditProofs.lean#L106-L110)

## Which initially wrong answers changed?

`recorded_transitions_from_wrong_answers`

**Proof request**

Trace the four initially wrong choices through the linked and unlinked follow-ups.

**Reading the result**

Among the four, the linked follow-up corrected three and left one open. The unlinked follow-up retained all four wrong choices.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem recorded_transitions_from_wrong_answers :
    let errors := initiallyWrong (orderedTrials .reversed)
    errors.length = 4 ∧ followingCounts errors .linked = ⟨3, 0, 1, 0⟩ ∧
      followingCounts errors .unlinked = ⟨0, 4, 0, 0⟩ := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditChallenge.lean#L79-L82) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditProofs.lean#L112-L115)

## Who explicitly noticed a conflict in those four cases?

`recorded_notice_and_correction`

**Proof request**

Identify which of the corrected or withdrawn reports explicitly mentions the conflict.

**Reading the result**

The withdrawn answer named it. The three corrected answers and the unlinked follow-ups recorded none.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem recorded_notice_and_correction :
    let errors := initiallyWrong (orderedTrials .reversed)
    let corrected := errors.filter fun r => decide (r.linked.answer = .picked r.target)
    let withdrawn := errors.filter fun r => decide (r.linked.answer = .undecided)
    explicitCount corrected .linked = 0 ∧ explicitCount withdrawn .linked = 1 ∧
      explicitCount errors .unlinked = 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditChallenge.lean#L84-L89) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditProofs.lean#L117-L122)

## Which policy agrees with the linked follow-ups?

`recorded_linked_policy_comparisons`

**Proof request**

Count agreement with each linked-evidence policy for faithful and reversed trials.

**Reading the result**

On reversed trials trusting the action fits five and withholding fits one. On faithful trials both policies fit all six.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem recorded_linked_policy_comparisons :
    let reversed := orderedTrials .reversed
    let faithful := orderedTrials .faithful
    (reversed.filter (policyFitsLinkedAnswer Evidence.trustAction)).length = 5 ∧
      (reversed.filter (policyFitsLinkedAnswer Evidence.withholdOnConflict)).length = 1 ∧
      (faithful.filter (policyFitsLinkedAnswer Evidence.trustAction)).length = 6 ∧
      (faithful.filter (policyFitsLinkedAnswer Evidence.withholdOnConflict)).length = 6 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditChallenge.lean#L91-L97) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/ReplayAuditProofs.lean#L124-L130)
