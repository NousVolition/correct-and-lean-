import WellposednessTargets

namespace HugNavierWellposedness.Verified
noncomputable section
open HugNavierSingle Set

-- These four diagnostic claims are NOT the requested existence theorem.
theorem perturbation_regular (n : ℕ) :
    ContDiff ℝ ⊤ (perturbation n) ∧ Periodic (perturbation n) ∧
      Incompressible (nearby n) := by sorry

theorem nearby_uniform_bound (n : ℕ) :
    UniformlyClose (nearby n) sourceInitial (1/(n:ℝ)^2) := by sorry

theorem exact_rate_difference (n : ℕ) (hn : 0 < n) :
    rateDifference n = -(1/50:ℝ)-(3/2)*(1/(n:ℝ)^2) := by sorry

theorem no_uniform_local_rate_bound : ¬ UniformLocalRateBound := by sorry

end
end HugNavierWellposedness.Verified
