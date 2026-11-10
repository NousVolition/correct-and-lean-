import TwoTrembleReadings

/-! Frozen targets for identification of two unlabelled trembles. -/

namespace MeetingThread.TwoTrembles

theorem direct_sound_open (actions sounds : OrderedMarks) (clue : Mark) :
    resolve (directView actions sounds) (.sound clue) = none := by sorry

theorem replay_selects_distinct_sound (actions : OrderedMarks) (x y : Mark)
    (distinct : x ≠ y) (target : Moment) :
    let sounds : OrderedMarks := ⟨x, y⟩
    resolve (replayView actions sounds) (.sound (sounds.atMoment target)) = some target := by sorry

theorem retained_landmark_selects_in_both_views (sounds : OrderedMarks) (x y : Mark)
    (distinct : x ≠ y) (target : Moment) :
    let actions : OrderedMarks := ⟨x, y⟩
    let witness := WitnessClue.landmark (actions.atMoment target)
    resolve (directView actions sounds) witness = some target ∧
      resolve (replayView actions sounds) witness = some target := by sorry

theorem generic_witness_open (v : View) : resolve v .generic = none := by sorry

theorem shared_sound_still_open_on_replay (actions : OrderedMarks) (heard : Mark) :
    resolve (replayView actions ⟨heard, heard⟩) (.sound heard) = none := by sorry

theorem no_direct_rule_can_identify_both_twins
    (choose : View → WitnessClue → Option Moment) (actions : OrderedMarks) :
    let first := directView actions ⟨.a, .b⟩
    let swapped := directView actions ⟨.b, .a⟩
    first = swapped ∧ ¬ (choose first (.sound .a) = some .earlier ∧
                        choose swapped (.sound .a) = some .later) := by sorry

theorem all_registered_pairs_recorded :
    cells.tail.length = 18 ∧ readings.length = 18 ∧
    ["K4", "N7", "Q2", "F8", "C9", "V3"].all completeWorld = true := by sorry

theorem recorded_sound_counts :
    counts .sound .direct = ⟨0, 0, 6, 0⟩ ∧
    counts .sound .replay = ⟨6, 0, 0, 0⟩ := by sorry

theorem recorded_landmark_counts :
    counts .landmark .direct = ⟨6, 0, 0, 0⟩ ∧
    counts .landmark .replay = ⟨6, 0, 0, 0⟩ := by sorry

theorem recorded_generic_counts :
    counts .generic .direct = ⟨0, 0, 6, 0⟩ ∧
    counts .generic .replay = ⟨0, 0, 6, 0⟩ := by sorry

theorem recorded_answers_agree_with_resolver :
    readings.all (fun r => decide (predicted r .direct = r.direct) &&
      decide (predicted r .replay = r.replay)) = true := by sorry

end MeetingThread.TwoTrembles
