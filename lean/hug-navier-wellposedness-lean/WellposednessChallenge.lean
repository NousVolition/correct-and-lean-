import EnergyDefs
import WellposednessTargets
import GuardTransportDefs
import GuardTransportTimeDefs

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

theorem uniform_gradient_bound (g : ℝ → ScalarField) (a b : ℝ)
    (gx : ContinuousOn (fun p : ℝ × Point => partialX (g p.1) p.2) (timeCell a b))
    (gy : ContinuousOn (fun p : ℝ × Point => partialY (g p.1) p.2) (timeCell a b))
    (gp : ∀ t ∈ Icc a b, Periodic (g t)) :
    ∃ M : ℝ, 0 ≤ M ∧ ∀ t ∈ Icc a b, ∀ r,
      (partialX (g t) r)^2 + (partialY (g t) r)^2 ≤ M^2 := by sorry

theorem integrated_residual_bound_uniform (z w : ℝ → Fields)
    (g h : ℝ → ScalarField) (a b : ℝ)
    (gx : ContinuousOn (fun p : ℝ × Point => partialX (g p.1) p.2) (timeCell a b))
    (gy : ContinuousOn (fun p : ℝ × Point => partialY (g p.1) p.2) (timeCell a b))
    (gp : ∀ t ∈ Icc a b, Periodic (g t))
    (zX : ∀ t ∈ Icc a b, Continuous (z t).ux)
    (zY : ∀ t ∈ Icc a b, Continuous (z t).uy)
    (wX : ∀ t ∈ Icc a b, Continuous (w t).ux)
    (wY : ∀ t ∈ Icc a b, Continuous (w t).uy)
    (hg : ∀ t ∈ Icc a b, ContDiff ℝ 1 (g t))
    (hh : ∀ t ∈ Icc a b, Continuous (h t)) :
    ∃ M : ℝ, 0 ≤ M ∧ ∀ t ∈ Icc a b,
      |∫ r, h t r * residual (velocityAt (z t) r) (w t) (g t) r ∂cellMeasure| ≤
        ((∫ r, ((z t).ux r-(w t).ux r)^2 + ((z t).uy r-(w t).uy r)^2 ∂cellMeasure) +
          M^2 * ∫ r, (h t r)^2 ∂cellMeasure) / 2 := by sorry

theorem fieldproblem_guard_transport_bounds (input : FieldInputs) (a b : ℝ)
    (initial : Fields) (z w : ℝ → Fields) (pz pw : ℝ → ScalarField)
    (hz : FieldProblem input a b initial z pz)
    (hw : FieldProblem input a b initial w pw)
    (joint : JointGuardGradientRegularity w a b) :
    ∃ M : ℝ, 0 ≤ M ∧ ∀ t ∈ Icc a b,
      (|∫ r, ((z t).gAB r-(w t).gAB r) *
          residual (velocityAt (z t) r) (w t) (w t).gAB r ∂cellMeasure| ≤
        ((∫ r, ((z t).ux r-(w t).ux r)^2 + ((z t).uy r-(w t).uy r)^2 ∂cellMeasure) +
          M^2 * ∫ r, ((z t).gAB r-(w t).gAB r)^2 ∂cellMeasure) / 2) ∧
      (|∫ r, ((z t).gBA r-(w t).gBA r) *
          residual (velocityAt (z t) r) (w t) (w t).gBA r ∂cellMeasure| ≤
        ((∫ r, ((z t).ux r-(w t).ux r)^2 + ((z t).uy r-(w t).uy r)^2 ∂cellMeasure) +
          M^2 * ∫ r, ((z t).gBA r-(w t).gBA r)^2 ∂cellMeasure) / 2) := by sorry

end
end HugNavierSingle.GuardTransport

namespace HugNavierSingle.EnergyEstimate
noncomputable section

theorem fieldproblem_guard_transport_energy_bound (input : FieldInputs) (a b : ℝ)
    (initial : Fields) (z w : ℝ → Fields) (pz pw : ℝ → ScalarField)
    (hz : FieldProblem input a b initial z pz)
    (hw : FieldProblem input a b initial w pw)
    (joint : GuardTransport.JointGuardGradientRegularity w a b) :
    ∃ Cg : ℝ, 0 ≤ Cg ∧ ∀ t ∈ Set.Icc a b,
      guardTransportMagnitude (z t) (w t) ≤ Cg * differenceEnergy (z t) (w t) := by sorry

end
end HugNavierSingle.EnergyEstimate
