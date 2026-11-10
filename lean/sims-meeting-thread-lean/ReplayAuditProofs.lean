import ReplayAuditModel
import ReplayAuditReadings
import TwoTrembleProofs

namespace MeetingThread.ReplayAudit
open TwoTrembles

theorem reversed_sound_points_to_opposite (actions : OrderedMarks) (x y : Mark)
    (distinct : x ≠ y) (target : Moment) :
    let actual : OrderedMarks := ⟨x, y⟩
    resolve (replayView actions (swap actual)) (.sound (actual.atMoment target)) =
      some (opposite target) := by
  cases x <;> cases y <;> cases target <;> first | rfl | exact False.elim (distinct rfl)

theorem linked_detail_uses_the_named_action (v : View) (sound action : Mark) :
    actionChoice v sound (.linked sound action) = resolve v (.landmark action) := by
  cases sound <;> rfl

theorem unlinked_detail_keeps_the_sound_choice (v : View) (w s action : Mark) :
    let e := assess v w (.unlinked s action)
    e.conflict = false ∧ e.withholdOnConflict = resolve v (.sound w) ∧
      e.trustAction = resolve v (.sound w) := by
  have onlySound (candidate : Option Moment) :
      let e : Evidence := ⟨candidate, none⟩
      e.conflict = false ∧ e.withholdOnConflict = candidate ∧ e.trustAction = candidate := by
    cases candidate <;> exact ⟨rfl, rfl, rfl⟩
  exact onlySound (resolve v (.sound w))

theorem unrelated_sound_supplies_no_action_match (v : View) (w s action : Mark) (diff : s ≠ w) :
    actionChoice v w (.linked s action) = none := by
  cases s <;> cases w <;> first | rfl | exact False.elim (diff rfl)

theorem faithful_replay_and_accurate_action_agree (ax ay sx sy : Mark)
    (ha : ax ≠ ay) (hs : sx ≠ sy) (target : Moment) :
    let actions : OrderedMarks := ⟨ax, ay⟩
    let sounds : OrderedMarks := ⟨sx, sy⟩
    let w := sounds.atMoment target
    let e := assess (replayView actions sounds) w (.linked w (actions.atMoment target))
    e = ⟨some target, some target⟩ ∧ e.conflict = false ∧
      e.withholdOnConflict = some target ∧ e.trustAction = some target := by
  let actions : OrderedMarks := ⟨ax, ay⟩
  let sounds : OrderedMarks := ⟨sx, sy⟩
  have sound := replay_selects_distinct_sound actions sx sy hs target
  have act := (retained_landmark_selects_in_both_views sounds ax ay ha target).2
  dsimp only
  rw [assess, linked_detail_uses_the_named_action, sound, act]
  cases target <;> exact ⟨rfl, rfl, rfl, rfl⟩

theorem reversal_and_accurate_action_conflict (ax ay sx sy : Mark)
    (ha : ax ≠ ay) (hs : sx ≠ sy) (target : Moment) :
    let actions : OrderedMarks := ⟨ax, ay⟩
    let sounds : OrderedMarks := ⟨sx, sy⟩
    let w := sounds.atMoment target
    let e := assess (replayView actions (swap sounds)) w (.linked w (actions.atMoment target))
    e = ⟨some (opposite target), some target⟩ ∧ e.conflict = true ∧
      e.withholdOnConflict = none ∧ e.trustAction = some target := by
  let actions : OrderedMarks := ⟨ax, ay⟩
  let sounds : OrderedMarks := ⟨sx, sy⟩
  have sound := reversed_sound_points_to_opposite actions sx sy hs target
  have act := (retained_landmark_selects_in_both_views (swap sounds) ax ay ha target).2
  dsimp only
  rw [assess, linked_detail_uses_the_named_action, sound, act]
  cases target <;> exact ⟨rfl, rfl, rfl, rfl⟩

/-- The same supplied replay and action detail fit two source-error histories.
    In one the order was reversed and the action link is accurate. In the
    other the order was faithful and the supplied action link is mistaken. -/
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
         choose shown₂ .a detail = some .later) := by
  refine ⟨rfl, rfl, rfl, by decide, rfl, ?_⟩
  intro h
  have different : (some Moment.earlier : Option Moment) = some Moment.later :=
    h.1.symm.trans h.2
  cases different

/-- One initial state per order and world. Each row contains that initial
    answer and its two follow-up readings. The record checker separately
    verifies the parent session and the entire input for each continuation. -/
theorem recorded_reversal_schedule :
    tableCells.tail.length = 12 ∧ trials.length = 12 ∧
    ["K4", "N7", "Q2", "F8", "C9", "V3"].all bothOrdersPresent = true ∧
    trials.all originalTargetPreserved = true := by decide

theorem recorded_initial_order_counts :
    firstCounts .faithful = ⟨5, 0, 1, 0⟩ ∧ firstCounts .reversed = ⟨0, 4, 2, 0⟩ ∧
    ((orderedTrials .faithful).filter firstFitsOriginalModel).length = 5 ∧
    ((orderedTrials .reversed).filter firstFitsOriginalModel).length = 4 := by decide

theorem recorded_faithful_followups :
    let rows := orderedTrials .faithful
    followingCounts rows .linked = ⟨6, 0, 0, 0⟩ ∧
      followingCounts rows .unlinked = ⟨4, 0, 2, 0⟩ ∧
      explicitCount rows .linked = 0 ∧ explicitCount rows .unlinked = 0 := by decide

theorem recorded_reversed_followups :
    let rows := orderedTrials .reversed
    followingCounts rows .linked = ⟨5, 0, 1, 0⟩ ∧
      followingCounts rows .unlinked = ⟨0, 4, 2, 0⟩ ∧
      explicitCount rows .linked = 1 ∧ explicitCount rows .unlinked = 0 := by decide

theorem recorded_transitions_from_wrong_answers :
    let errors := initiallyWrong (orderedTrials .reversed)
    errors.length = 4 ∧ followingCounts errors .linked = ⟨3, 0, 1, 0⟩ ∧
      followingCounts errors .unlinked = ⟨0, 4, 0, 0⟩ := by decide

theorem recorded_notice_and_correction :
    let errors := initiallyWrong (orderedTrials .reversed)
    let corrected := errors.filter fun r => decide (r.linked.answer = .picked r.target)
    let withdrawn := errors.filter fun r => decide (r.linked.answer = .undecided)
    explicitCount corrected .linked = 0 ∧ explicitCount withdrawn .linked = 1 ∧
      explicitCount errors .unlinked = 0 := by decide

theorem recorded_linked_policy_comparisons :
    let reversed := orderedTrials .reversed
    let faithful := orderedTrials .faithful
    (reversed.filter (policyFitsLinkedAnswer Evidence.trustAction)).length = 5 ∧
      (reversed.filter (policyFitsLinkedAnswer Evidence.withholdOnConflict)).length = 1 ∧
      (faithful.filter (policyFitsLinkedAnswer Evidence.trustAction)).length = 6 ∧
      (faithful.filter (policyFitsLinkedAnswer Evidence.withholdOnConflict)).length = 6 := by decide

end MeetingThread.ReplayAudit
