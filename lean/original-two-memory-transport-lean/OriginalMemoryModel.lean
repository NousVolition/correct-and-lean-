import OriginalVolterraChallenge
import Mathlib.Analysis.SpecialFunctions.Trigonometric.DerivHyp
import Mathlib.Analysis.Calculus.MeanValue

namespace TwoMemory

noncomputable section

/-- A normalized readout of two unit-duration records at +1 and -1, with width 1. -/
def memoryField (s : ℝ) : ℝ :=
  let p := Real.exp (-((s - 1)^2) / 2)
  let n := Real.exp (-((s + 1)^2) / 2)
  (p - n) / (p + n)

end

end TwoMemory
