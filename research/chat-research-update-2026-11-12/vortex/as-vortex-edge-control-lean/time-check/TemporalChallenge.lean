import TemporalStatements

noncomputable section
namespace SignedVortex.Rescaled.TimeControl
open NavierStokes NavierStokes.ProblemStatement

theorem early_loop_zero (a : ℕ → ℕ) {ν l t : ℝ} (hl : 1 < l) (ht : t < startTime l)
    (i j : Fin 3) (d : ℝ) : lineIntegral ν l (torusVelocity ν l a) t i j d = 0 := by sorry

theorem same_loop_before_after {a : ℕ → ℕ} (ha : LocalScheduleWitness.Selected a)
    {ν l : ℝ} (hν : 0 < ν) (hl : 1 < l) (hfit : width ν l < 2) :
    SameLoopBeforeAfter ν l a := by sorry

end SignedVortex.Rescaled.TimeControl
