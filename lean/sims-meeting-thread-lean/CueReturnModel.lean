import PagerReturnModel

namespace MeetingThread.PagerReturn

open scoped NNReal

/-- In the recorded order of later cues, a sample outside the closed cue
    interval is followed by a sample inside it. Both positions use the same
    starting cue and the same nonnegative radius. -/
def ReturnedWithin (first : ℝ) (radius : ℝ≥0) : List Focus → Prop
  | [] => False
  | step :: rest =>
    ((radius : ℝ) < |step.cue - first| ∧
      ∃ next ∈ rest, |next.cue - first| ≤ (radius : ℝ)) ∨
    ReturnedWithin first radius rest

end MeetingThread.PagerReturn
