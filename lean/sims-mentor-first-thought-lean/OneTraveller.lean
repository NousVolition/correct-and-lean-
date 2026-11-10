import MentorThoughtModel

namespace MentorThought.Continuing

theorem all_thirteen_ticks_in_order :
    trackCells.tail.length = 13 ∧ track.length = 13 ∧
    track.map (·.prime) = schedule.map (fun t => toString t.label) ∧
    track.map (·.offsetUs) = schedule.map (fun t => toString t.offsetUs) := by decide

theorem one_session_twenty_six_distinct_turns :
    (track.map (·.session)).eraseDups.length = 1 ∧
    turnIds.length = 26 ∧ turnIds.eraseDups.length = 26 := by decide

/-- These are self-reports about one continuing episode, including the last rating. -/
theorem no_reported_switch_to_settled :
    track.all (fun r => r.source == "PAGER" && r.judgment == "POSSIBLE" && r.grounded == "yes") = true ∧
    (track.filter (fun r => r.freeCertainty == "probable")).length = 9 ∧
    (track.filter (fun r => r.freeCertainty == "open")).length = 4 ∧
    (track.filter (fun r => r.freeCertainty == "explicit" || r.freeCertainty == "bare")).length = 0 := by decide

theorem first_personal_reference_in_each_probe :
    (track.find? (fun r => own r.statusFeeling)).map (·.prime) = some "2" ∧
    (track.find? (fun r => own r.freeFeeling)).map (·.prime) = some "3" ∧
    (track.filter (fun r => own r.freeFeeling)).map (·.prime) = ["3","7","11","13","19"] ∧
    track.all (fun r => own r.statusFeeling) = true := by decide

theorem references_without_a_report_of_reliving :
    (track.filter (fun r => r.freeFeeling == "reported_motion")).map (·.prime) = ["17","31","41"] ∧
    track.all (fun r => r.freeFeeling != "recollection" && r.statusFeeling != "recollection") = true := by decide

/-- Two persistent latent histories can agree on every observation through a finite
cutoff, even if one becomes settled afterwards and the other stays open. -/
theorem an_unsettled_window_leaves_the_future_open (cutoff : Nat) :
    ∃ later never : Nat → Prop,
      (∀ i j, i ≤ j → later i → later j) ∧
      (∀ t, t ≤ cutoff → ¬ later t ∧ ¬ never t) ∧
      later (cutoff + 1) ∧ (∀ t, ¬ never t) := by
  refine ⟨fun n => cutoff < n, fun _ => False, ?_, ?_, Nat.lt_succ_self _, ?_⟩
  · intro i j hij hi
    exact Nat.lt_of_lt_of_le hi hij
  · intro t ht
    exact ⟨Nat.not_lt_of_ge ht, id⟩
  · intro t
    exact id

end MentorThought.Continuing
