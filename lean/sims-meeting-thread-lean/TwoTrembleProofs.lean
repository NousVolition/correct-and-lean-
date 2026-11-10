import TwoTrembleModel
import TwoTrembleReadings

namespace MeetingThread.TwoTrembles

theorem direct_sound_open (actions sounds : OrderedMarks) (clue : Mark) :
    resolve (directView actions sounds) (.sound clue) = none := by
  cases sounds with
  | mk x y => cases x <;> cases y <;> cases clue <;> rfl

theorem replay_selects_distinct_sound (actions : OrderedMarks) (x y : Mark)
    (distinct : x ≠ y) (target : Moment) :
    let sounds : OrderedMarks := ⟨x, y⟩
    resolve (replayView actions sounds) (.sound (sounds.atMoment target)) = some target := by
  cases x <;> cases y <;> cases target <;> first | rfl | exact False.elim (distinct rfl)

theorem retained_landmark_selects_in_both_views (sounds : OrderedMarks) (x y : Mark)
    (distinct : x ≠ y) (target : Moment) :
    let actions : OrderedMarks := ⟨x, y⟩
    let witness := WitnessClue.landmark (actions.atMoment target)
    resolve (directView actions sounds) witness = some target ∧
      resolve (replayView actions sounds) witness = some target := by
  cases x <;> cases y <;> cases target <;> first | exact ⟨rfl, rfl⟩ | exact False.elim (distinct rfl)

theorem generic_witness_open (v : View) : resolve v .generic = none := rfl

theorem shared_sound_still_open_on_replay (actions : OrderedMarks) (heard : Mark) :
    resolve (replayView actions ⟨heard, heard⟩) (.sound heard) = none := by
  cases heard <;> rfl

/-- In the first world sound a accompanies the earlier event. In its twin
    it accompanies the later one. Every deterministic rule sees exactly the
    same direct view and witness clue in the two worlds. -/
theorem no_direct_rule_can_identify_both_twins
    (choose : View → WitnessClue → Option Moment) (actions : OrderedMarks) :
    let first := directView actions ⟨.a, .b⟩
    let swapped := directView actions ⟨.b, .a⟩
    first = swapped ∧ ¬ (choose first (.sound .a) = some .earlier ∧
                        choose swapped (.sound .a) = some .later) := by
  refine ⟨rfl, ?_⟩
  intro both
  have impossible : (some Moment.earlier : Option Moment) = some Moment.later :=
    both.1.symm.trans both.2
  cases impossible

/-- Each row is a pair of independent answers. Every registered world has
    one row for each witness condition and every input row parses. -/
theorem all_registered_pairs_recorded :
    cells.tail.length = 18 ∧ readings.length = 18 ∧
    ["K4", "N7", "Q2", "F8", "C9", "V3"].all completeWorld = true := by decide

theorem recorded_sound_counts :
    counts .sound .direct = ⟨0, 0, 6, 0⟩ ∧
    counts .sound .replay = ⟨6, 0, 0, 0⟩ := by decide

theorem recorded_landmark_counts :
    counts .landmark .direct = ⟨6, 0, 0, 0⟩ ∧
    counts .landmark .replay = ⟨6, 0, 0, 0⟩ := by decide

theorem recorded_generic_counts :
    counts .generic .direct = ⟨0, 0, 6, 0⟩ ∧
    counts .generic .replay = ⟨0, 0, 6, 0⟩ := by decide

/-- The resolver reads only B's view and the witness clue. The two report
    fields come separately from the registered private interviews. -/
theorem recorded_answers_agree_with_resolver :
    readings.all (fun r => decide (predicted r .direct = r.direct) &&
      decide (predicted r .replay = r.replay)) = true := by decide

end MeetingThread.TwoTrembles
