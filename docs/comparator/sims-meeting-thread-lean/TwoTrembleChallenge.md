# Which of two trembles was the pager?

Compare a sound clue, a remembered action and a generic witness. One clue can distinguish the moments only when the view retains the corresponding difference.

[`TwoTrembleChallenge.lean`](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoTrembleChallenge.lean) · [Package configuration](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 NousVolition. All rights reserved. The repository notice applies to material for which NousVolition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The Traveller examples come from the repository’s SIMS model and study records. [Original model and studies](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/README.md).

The trial counts use the saved simulated reports and their project coding. [Study protocol](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/observations/two-trembles/protocol.json) · [Trial readings](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/observations/two-trembles/readings.tsv) · [Full reports](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/observations/two-trembles/reports.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/SimsMeeting.lean) · [TwoTrembleReadings](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoTrembleReadings.lean) · [Package account](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/README.md) · [Statement and proof inputs](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/lake-manifest.json).

</details>

## Can a sound clue select a moment if the direct view does not retain which sound came when?

`direct_sound_open`

**Proof request**

Prove that the direct sound clue gives no resolved moment.

**Reading the result**

The direct resolver returns an open answer.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem direct_sound_open (actions sounds : OrderedMarks) (clue : Mark) :
    resolve (directView actions sounds) (.sound clue) = none := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoTrembleChallenge.lean#L7-L8) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoTrembleProofs.lean#L6-L9)

## What does replay add when the two sounds differ?

`replay_selects_distinct_sound`

**Proof request**

Use distinct replay sounds to select the target moment.

**Reading the result**

Their order lets the sound clue select its matching target moment.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem replay_selects_distinct_sound (actions : OrderedMarks) (x y : Mark)
    (distinct : x ≠ y) (target : Moment) :
    let sounds : OrderedMarks := ⟨x, y⟩
    resolve (replayView actions sounds) (.sound (sounds.atMoment target)) = some target := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoTrembleChallenge.lean#L10-L13) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoTrembleProofs.lean#L11-L15)

## Can an action already remembered identify the moment without replay?

`retained_landmark_selects_in_both_views`

**Proof request**

Prove that a distinct retained action identifies the target in either view.

**Reading the result**

With distinct landmarks, the same action clue selects the target in both views.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem retained_landmark_selects_in_both_views (sounds : OrderedMarks) (x y : Mark)
    (distinct : x ≠ y) (target : Moment) :
    let actions : OrderedMarks := ⟨x, y⟩
    let witness := WitnessClue.landmark (actions.atMoment target)
    resolve (directView actions sounds) witness = some target ∧
      resolve (replayView actions sounds) witness = some target := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoTrembleChallenge.lean#L15-L20) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoTrembleProofs.lean#L17-L23)

## How much does a generic witness distinguish?

`generic_witness_open`

**Proof request**

Evaluate the resolver on a generic clue.

**Reading the result**

Without a distinguishing sound or action, the resolver leaves the moment open.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem generic_witness_open (v : View) : resolve v .generic = none := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoTrembleChallenge.lean#L22) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoTrembleProofs.lean#L25)

## What if both moments had the same sound?

`shared_sound_still_open_on_replay`

**Proof request**

Show that replay of a shared sound still leaves the target open.

**Reading the result**

Even with replay, the matching sound fails to pick between them.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem shared_sound_still_open_on_replay (actions : OrderedMarks) (heard : Mark) :
    resolve (replayView actions ⟨heard, heard⟩) (.sound heard) = none := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoTrembleChallenge.lean#L24-L25) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoTrembleProofs.lean#L27-L29)

## Could some better rule identify both hidden orders from the direct view alone?

`no_direct_rule_can_identify_both_twins`

**Proof request**

Construct identical direct views requiring opposite choices under two sound orders.

**Reading the result**

Swapping the sound order gives identical direct evidence and opposite targets, so a rule seeing just that evidence cannot be correct in both worlds.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem no_direct_rule_can_identify_both_twins
    (choose : View → WitnessClue → Option Moment) (actions : OrderedMarks) :
    let first := directView actions ⟨.a, .b⟩
    let swapped := directView actions ⟨.b, .a⟩
    first = swapped ∧ ¬ (choose first (.sound .a) = some .earlier ∧
                        choose swapped (.sound .a) = some .later) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoTrembleChallenge.lean#L27-L32) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoTrembleProofs.lean#L34-L44)

## Were all the registered comparisons recorded?

`all_registered_pairs_recorded`

**Proof request**

Verify completeness for the six worlds and eighteen listed comparisons.

**Reading the result**

The two lists have eighteen entries and each of the six named worlds has its complete set of conditions.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem all_registered_pairs_recorded :
    cells.tail.length = 18 ∧ readings.length = 18 ∧
    ["K4", "N7", "Q2", "F8", "C9", "V3"].all completeWorld = true := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoTrembleChallenge.lean#L34-L36) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoTrembleProofs.lean#L48-L50)

## What did the sound-only clue do in the recorded comparisons?

`recorded_sound_counts`

**Proof request**

Compute the direct and replay outcome counts for sound clues.

**Reading the result**

All six direct answers stayed open and all six replay answers were correct.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem recorded_sound_counts :
    counts .sound .direct = ⟨0, 0, 6, 0⟩ ∧
    counts .sound .replay = ⟨6, 0, 0, 0⟩ := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoTrembleChallenge.lean#L38-L40) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoTrembleProofs.lean#L52-L54)

## What happened with a remembered landmark?

`recorded_landmark_counts`

**Proof request**

Compute the corresponding counts for landmark clues.

**Reading the result**

All six answers were correct in each viewing condition.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem recorded_landmark_counts :
    counts .landmark .direct = ⟨6, 0, 0, 0⟩ ∧
    counts .landmark .replay = ⟨6, 0, 0, 0⟩ := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoTrembleChallenge.lean#L42-L44) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoTrembleProofs.lean#L56-L58)

## What happened with a generic clue?

`recorded_generic_counts`

**Proof request**

Compute the corresponding counts for generic clues.

**Reading the result**

All six answers in each condition stayed open.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem recorded_generic_counts :
    counts .generic .direct = ⟨0, 0, 6, 0⟩ ∧
    counts .generic .replay = ⟨0, 0, 6, 0⟩ := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoTrembleChallenge.lean#L46-L48) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoTrembleProofs.lean#L60-L62)

## Do the specified resolver and the saved answers agree case by case?

`recorded_answers_agree_with_resolver`

**Proof request**

Compare every stored direct and replay answer to its predicted resolution.

**Reading the result**

Checking both viewing conditions for every row gives agreement throughout the registered table.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem recorded_answers_agree_with_resolver :
    readings.all (fun r => decide (predicted r .direct = r.direct) &&
      decide (predicted r .replay = r.replay)) = true := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoTrembleChallenge.lean#L50-L52) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/sims-meeting-thread-lean/TwoTrembleProofs.lean#L66-L68)
