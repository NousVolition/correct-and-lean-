import RescaleFields

noncomputable section
namespace SignedVortex.Rescaled.TimeControl
open Set NavierStokes NavierStokes.ProblemStatement

def startTime (l : ℝ) := 1-1/l^2

/-- A loop selected at a late time is held fixed while we inspect its earlier
readings. The offset may vary between different choices of the late time. -/
def SameLoopBeforeAfter (ν l : ℝ) (a : ℕ → ℕ) : Prop :=
  0 < startTime l ∧ startTime l < 1 ∧
  ∃ η : ℝ, 0 < η ∧ ∀ σ : ℝ, 0 < σ → σ < η → startTime l < 1-σ ∧
    ∃ d ∈ Ico (0:ℝ) (1/8),
      (∀ t ∈ Ioo (0:ℝ) (startTime l),
        lineIntegral ν l (torusVelocity ν l a) t 0 1 d = 0 ∧
        lineIntegral ν l (torusVelocity ν l a) t 1 0 d = 0) ∧
      lineIntegral ν l (torusVelocity ν l a) (1-σ) 0 1 d ≠ 0 ∧
      lineIntegral ν l (torusVelocity ν l a) (1-σ) 1 0 d =
        -lineIntegral ν l (torusVelocity ν l a) (1-σ) 0 1 d

end SignedVortex.Rescaled.TimeControl
