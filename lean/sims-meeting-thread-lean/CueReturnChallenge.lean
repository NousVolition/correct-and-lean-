import CueReturnModel
import TwoMemoryModel

/-! Frozen questions about sampled departures, re-entry and identification. -/

namespace MeetingThread.PagerReturn

open scoped NNReal

theorem two_samples_return_iff (first : ℝ) (radius : ℝ≥0) (a b : Focus) :
    ReturnedWithin first radius [a, b] ↔
      (radius : ℝ) < |a.cue - first| ∧ |b.cue - first| ≤ (radius : ℝ) := by sorry

theorem staying_is_not_returning (first : ℝ) (radius : ℝ≥0) :
    ReturnsTo first [.look first, .look first] ∧
      ¬ ReturnedWithin first radius [.look first, .look first] := by sorry

theorem sampled_return_controls :
    ReturnedWithin 0 (1/10) [.look 1, .look (1/20)] ∧
    ¬ ReturnsTo 0 [.look 1, .look (1/20)] ∧
    ¬ ReturnedWithin 0 (1/10) [.look (1/20), .look 1] ∧
    ReturnedWithin 0 (1/10) [.look 1, .look (1/10)] ∧
    ¬ ReturnedWithin 0 (1/10) [.look 1, .look (11/100)] := by sorry

theorem log_odds_distance (a b : ℝ) :
    |Real.log (TwoMemoryTransport.odds b) - Real.log (TwoMemoryTransport.odds a)| =
      2 * |b - a| := by sorry

theorem report_ignores_attention (ref : EpisodeRef) (a b : List Focus)
    (w : WitnessReply) (accepted : Bool) (now : ℚ) :
    (receive ref a w accepted now).report = (receive ref b w accepted now).report := by sorry

theorem recognition_beyond_any_radius (radius : ℝ≥0) :
    let later := [Focus.look ((radius : ℝ) + 1), Focus.look ((radius : ℝ) + 2)]
    (∀ step ∈ later, (radius : ℝ) < |step.cue - 0|) ∧
    ¬ ReturnedWithin 0 radius later ∧
    (receive ⟨7, 0⟩ later ⟨7, 1, some .pager⟩ true 0).report.answer = none ∧
    (receive ⟨7, 0⟩ later ⟨7, 1, some .pager⟩ true 2).report = ⟨7, some .pager⟩ := by sorry

theorem returning_does_not_match_the_episode :
    let later := [Focus.look 1, Focus.look (1/20)]
    let witness : WitnessReply := ⟨8, 1, some .pager⟩
    ReturnedWithin 0 (1/10) later ∧
    (receive ⟨7, 0⟩ later witness true 2).report = ⟨7, none⟩ ∧
    (receive ⟨8, 0⟩ later witness true 2).report = ⟨8, some .pager⟩ := by sorry

end MeetingThread.PagerReturn
