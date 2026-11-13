import WellposednessTargets
import GuardTransportDefs

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

namespace HugNavierSingle.GuardTransport
noncomputable section
open Set MeasureTheory

theorem transport_of_blend (a : ℝ) (left right : Fields) (g : ScalarField) (r : Point) :
    transportAt (sampleBlend a left right r) g r =
      (1 - a) * advection left g r + a * advection right g r := by sorry

theorem directional_guard_rates (i : FieldInputs) (t : ℝ) (z : Fields)
    (p : ScalarField) (r uRead : Point) :
    (fieldRates i t z p).gAB r + transportAt uRead z.gAB r =
      (3/200) * laplacian z.gAB r + reactionAB z r + residual uRead z z.gAB r ∧
    (fieldRates i t z p).gBA r + transportAt uRead z.gBA r =
      (3/200) * laplacian z.gBA r + reactionBA z r + residual uRead z z.gBA r := by sorry

theorem advection_difference (z w : Fields) (f g : ScalarField) (r : Point) :
    advection z f r - advection w g r =
      z.ux r * (partialX f r - partialX g r) +
      z.uy r * (partialY f r - partialY g r) +
      residual (velocityAt z r) w g r := by sorry

theorem residual_energy_bound (uRead : Point) (z : Fields) (g : ScalarField)
    (r : Point) (h : ℝ) :
    |h * residual uRead z g r| ≤
      (((uRead.1 - z.ux r)^2 + (uRead.2 - z.uy r)^2) +
        h^2 * ((partialX g r)^2 + (partialY g r)^2)) / 2 := by sorry

theorem integrated_residual_bound (z w : Fields) (g h : ScalarField) (M : ℝ)
    (zX : Continuous z.ux) (zY : Continuous z.uy)
    (wX : Continuous w.ux) (wY : Continuous w.uy) (hg : ContDiff ℝ 1 g) (hh : Continuous h)
    (gradient : ∀ r, (partialX g r)^2 + (partialY g r)^2 ≤ M^2) :
    |∫ r, h r * residual (velocityAt z r) w g r ∂cellMeasure| ≤
      ((∫ r, (z.ux r-w.ux r)^2 + (z.uy r-w.uy r)^2 ∂cellMeasure) +
        M^2 * ∫ r, (h r)^2 ∂cellMeasure) / 2 := by sorry

theorem common_transport_cancels (z : Fields) (h : ScalarField)
    (hx : ContDiff ℝ 1 z.ux) (hy : ContDiff ℝ 1 z.uy) (hh : ContDiff ℝ 1 h)
    (px : Periodic z.ux) (py : Periodic z.uy) (ph : Periodic h) (div : Incompressible z) :
    (∫ r, h r * advection z h r ∂cellMeasure) = 0 := by sorry

end
end HugNavierSingle.GuardTransport
