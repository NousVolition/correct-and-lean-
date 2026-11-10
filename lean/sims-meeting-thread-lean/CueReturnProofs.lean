import CueReturnModel
import TwoMemoryTransport

namespace MeetingThread.PagerReturn

open scoped NNReal

theorem two_samples_return_iff (first : ℝ) (radius : ℝ≥0) (a b : Focus) :
    ReturnedWithin first radius [a, b] ↔
      (radius : ℝ) < |a.cue - first| ∧ |b.cue - first| ≤ (radius : ℝ) := by
  simp [ReturnedWithin]

/-- Looking at the starting cue twice satisfies the published exact-visit
    predicate. The recorded samples never leave the interval. -/
theorem staying_is_not_returning (first : ℝ) (radius : ℝ≥0) :
    ReturnsTo first [.look first, .look first] ∧
      ¬ ReturnedWithin first radius [.look first, .look first] := by
  simp [ReturnsTo, two_samples_return_iff, Focus.cue, radius.coe_nonneg]

/-- The radius is 1/10 in these controls. The second sample can land inside,
    on the boundary, or beyond it. Reversing the sample order changes the result. -/
theorem sampled_return_controls :
    ReturnedWithin 0 (1/10) [.look 1, .look (1/20)] ∧
    ¬ ReturnsTo 0 [.look 1, .look (1/20)] ∧
    ¬ ReturnedWithin 0 (1/10) [.look (1/20), .look 1] ∧
    ReturnedWithin 0 (1/10) [.look 1, .look (1/10)] ∧
    ¬ ReturnedWithin 0 (1/10) [.look 1, .look (11/100)] := by
  norm_num [two_samples_return_iff, ReturnsTo, Focus.cue]

/-- The Gaussian model gives the cue radius a scale in log odds. -/
theorem log_odds_distance (a b : ℝ) :
    |Real.log (TwoMemoryTransport.odds b) - Real.log (TwoMemoryTransport.odds a)| =
      2 * |b - a| := by
  simp only [TwoMemoryTransport.odds_eq_exp, Real.log_exp]
  rw [← mul_sub, abs_mul, abs_of_nonneg (by norm_num : (0 : ℝ) ≤ 2)]

/-- With the retained episode reference and testimony fixed, the report field
    has the same value for every attention trace. The sensory marker may vary. -/
theorem report_ignores_attention (ref : EpisodeRef) (a b : List Focus)
    (w : WitnessReply) (accepted : Bool) (now : ℚ) :
    (receive ref a w accepted now).report = (receive ref b w accepted now).report := rfl

/-- The same event can be identified with every recorded later cue beyond an
    arbitrary specified radius. The witness arrives strictly after the tremble. -/
theorem recognition_beyond_any_radius (radius : ℝ≥0) :
    let later := [Focus.look ((radius : ℝ) + 1), Focus.look ((radius : ℝ) + 2)]
    (∀ step ∈ later, (radius : ℝ) < |step.cue - 0|) ∧
    ¬ ReturnedWithin 0 radius later ∧
    (receive ⟨7, 0⟩ later ⟨7, 1, some .pager⟩ true 0).report.answer = none ∧
    (receive ⟨7, 0⟩ later ⟨7, 1, some .pager⟩ true 2).report = ⟨7, some .pager⟩ := by
  have h₁ : 0 ≤ (radius : ℝ) + 1 := by positivity
  have h₂ : 0 ≤ (radius : ℝ) + 2 := by positivity
  norm_num [two_samples_return_iff, Focus.cue, receive, abs_of_nonneg h₁, abs_of_nonneg h₂]

/-- The same cue return and the same witness leave event 7 open and answer
    event 8. The witness identifies the pager in event 8. -/
theorem returning_does_not_match_the_episode :
    let later := [Focus.look 1, Focus.look (1/20)]
    let witness : WitnessReply := ⟨8, 1, some .pager⟩
    ReturnedWithin 0 (1/10) later ∧
    (receive ⟨7, 0⟩ later witness true 2).report = ⟨7, none⟩ ∧
    (receive ⟨8, 0⟩ later witness true 2).report = ⟨8, some .pager⟩ := by
  norm_num [two_samples_return_iff, Focus.cue, receive]

end MeetingThread.PagerReturn
