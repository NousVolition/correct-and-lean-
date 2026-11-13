import RescaleFields

noncomputable section
namespace SignedVortex.Rescaled.EdgeControl
open Set NavierStokes NavierStokes.ProblemStatement

/-- Actual integrals in the final periodic box, at time 1 - σ. -/
def yLoop (ν l : ℝ) (a : ℕ → ℕ) (σ d : ℝ) :=
  lineIntegral ν l (torusVelocity ν l a) (1-σ) 0 1 d
def xLoop (ν l : ℝ) (a : ℕ → ℕ) (σ d : ℝ) :=
  lineIntegral ν l (torusVelocity ν l a) (1-σ) 1 0 d

/-- b is a distance in the final box. ε is a tolerance on the absolute
loop integral. The inward offset may depend on time, distance and tolerance. -/
def SilentAndFaint (ν l : ℝ) (a : ℕ → ℕ) : Prop :=
  ∃ η : ℝ, 0 < η ∧ ∀ σ : ℝ, 0 < σ → σ < η →
    (∀ d ∈ Ioc (-(1/16):ℝ) 0, yLoop ν l a σ d = 0 ∧ xLoop ν l a σ d = 0) ∧
    ∀ b : ℝ, 0 < b → ∀ ε : ℝ, 0 < ε →
      ∃ d ∈ Ioo (0:ℝ) (1/8), width ν l*d < b ∧
        0 < |yLoop ν l a σ d| ∧ |yLoop ν l a σ d| < ε ∧
        xLoop ν l a σ d = -yLoop ν l a σ d

end SignedVortex.Rescaled.EdgeControl
