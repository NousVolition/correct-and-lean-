import MentorThoughtModel
import PrimeSweep
import OneTraveller

namespace MentorThought

/-- Within the original 1.2-unit window these and only these step pairs coincide. -/
theorem shared_iff_same_interval (listener mentor : Nat) (within : listener ≤ 384) :
    shared listener mentor ↔
      ∃ n : Nat, n ≤ 12 ∧ listener = 32*n ∧ mentor = 25*n := by
  unfold shared
  constructor
  · intro same
    refine ⟨9*mentor - 7*listener, ?_, ?_, ?_⟩ <;> omega
  · rintro ⟨n, _, rfl, rfl⟩
    omega

theorem prime_clock_schedule :
    labels = [2,3,5,7,11,13,17,19,23,29,31,37,41] ∧ schedule.length = 13 ∧
    schedule.head? = some ⟨2,0,0,0⟩ ∧ schedule.getLast? = some ⟨41,384,300,1200000⟩ ∧
    schedule.all (fun t => 250*t.listener == 320*t.mentor) = true := by decide

theorem free_words_precede_source :
    cells.tail.length = 10 ∧ reports.length = 10 ∧
    (reports.filter (fun r => r.wording == "original")).map (·.episode) = ["K27","M14","D62","R35","V81"] ∧
    (reports.filter (fun r => r.wording == "paraphrase")).map (·.episode) = ["K27","M14","D62","R35","V81"] ∧
    reports.all (fun r => r.firstTick == "2" && r.sourceTick == "41") = true := by decide

theorem personal_mentions_by_wording :
    countIn "original" personallyMentioned = 2 ∧ countIn "paraphrase" personallyMentioned = 0 ∧
    reports.all (fun r => r.grade != "recollection") = true := by decide

theorem motion_and_no_mention_counts :
    countIn "original" (fun r => r.grade == "reported_motion") = 1 ∧
    countIn "original" (fun r => r.grade == "no_mention") = 2 ∧
    countIn "paraphrase" (fun r => r.grade == "reported_motion") = 1 ∧
    countIn "paraphrase" (fun r => r.grade == "no_mention") = 4 := by decide

theorem later_source_judgments :
    countIn "original" pagerIdentified = 5 ∧ countIn "paraphrase" pagerIdentified = 3 ∧
    countIn "paraphrase" (fun r => r.source == "PAGER" && r.judgment == "POSSIBLE") = 2 := by decide

theorem identified_without_mentioning_feeling :
    countIn "original" (fun r => !personallyMentioned r && pagerIdentified r) = 3 ∧
    countIn "paraphrase" (fun r => !personallyMentioned r && pagerIdentified r) = 3 := by decide

end MentorThought
