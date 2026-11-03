import OriginalAS

/- Frozen claims: intentionally unfinished reference declarations are allowed
   ONLY in this challenge, never in FullChecks or its imported models. -/
namespace HugNavierSingle.Verified
noncomputable section
open Set

theorem full_material_energy_balance (i : FieldInputs) (t : ℝ)
    (z : ℝ → Fields) (p : ℝ → ScalarField) (r : Point)
    (h : FieldDifferentialAt i z p t)
    (hs : FirstSpatialRegularity (z t)) :
    deriv (fun s => energy (z s) r) t + advection (z t) (energy (z t)) r =
      energyProduction i t (z t) (p t) r := by sorry

theorem source_initial_incompressible : Incompressible sourceInitial := by sorry

theorem full_pressure_gauge (i : FieldInputs) (a b : ℝ) (initial : Fields)
    (z : ℝ → Fields) (p : ℝ → ScalarField) (c : ℝ → ℝ)
    (h : FieldProblem i a b initial z p) :
    FieldProblem i a b initial z (fun t r => p t r+c t) := by sorry

theorem full_pressure_not_unique (i : FieldInputs) (a b : ℝ) (initial : Fields)
    (z : ℝ → Fields) (p : ℝ → ScalarField)
    (h : FieldProblem i a b initial z p) :
    ∃ q, FieldProblem i a b initial z q ∧ q ≠ p := by sorry

-- These are local PDE boundary-direction tests, not a substituted ODE and
-- not a claim that a global parabolic maximum principle has been proved.
theorem guards_inward_at_spatial_boundaries (i : FieldInputs) (t : ℝ)
    (z : Fields) (p : ScalarField) (r : Point)
    (hxAB : partialX z.gAB r=0) (hyAB : partialY z.gAB r=0)
    (hxBA : partialX z.gBA r=0) (hyBA : partialY z.gBA r=0) :
    (z.gAB r=0 → 0 ≤ laplacian z.gAB r → 0 < (fieldRates i t z p).gAB r) ∧
    (z.gAB r=1 → laplacian z.gAB r ≤ 0 → (fieldRates i t z p).gAB r < 0) ∧
    (z.gBA r=0 → 0 ≤ laplacian z.gBA r → 0 < (fieldRates i t z p).gBA r) ∧
    (z.gBA r=1 → laplacian z.gBA r ≤ 0 → (fieldRates i t z p).gBA r < 0) := by sorry

theorem viscosity_and_stress_dissipation (z : Fields) (r : Point)
    (ha : z.gAB r ∈ Icc (0:ℝ) 1) (hb : z.gBA r ∈ Icc (0:ℝ) 1) :
    viscosity z r ∈ Icc (1/50:ℝ) (1/10) ∧
    stressXX z r*partialX z.ux r+stressYY z r*partialY z.uy r+
      stressXY z r*(partialY z.ux r+partialX z.uy r)=2*viscosity z r*strainSquared z r ∧
    0 ≤ 2*viscosity z r*strainSquared z r := by sorry

-- Full product-rule expansion. The guard-gradient terms remain present.
theorem full_variable_stress_divergence (z : Fields) (r : Point)
    (hnu : Differentiable ℝ (viscosity z))
    (ha : Differentiable ℝ (partialX z.ux))
    (hb : Differentiable ℝ (partialY z.ux))
    (hc : Differentiable ℝ (partialX z.uy)) :
    partialX (stressXX z) r+partialY (stressXY z) r =
      2*(partialX (viscosity z) r)*(partialX z.ux r)+
      2*viscosity z r*partialX (partialX z.ux) r+
      partialY (viscosity z) r*(partialY z.ux r+partialX z.uy r)+
      viscosity z r*(partialY (partialY z.ux) r+partialY (partialX z.uy) r) := by sorry

end
end HugNavierSingle.Verified

namespace OriginalAS.Verified
noncomputable section

theorem original_memory_derivative (p : Parameters) (U : ℝ → ℝ)
    (hU : Continuous U) (t : ℝ) :
    HasDerivAt (memory p U) (p.gamma*(U t-p.baseline)) t := by sorry

theorem original_pressure_gauge {n : ℕ} (p : Parameters) (response : ℝ → ℝ)
    (direction : Fin n) (U : ℝ → ℝ) (K : Scalar n) (x0 : Point n)
    (domain : Set (Point n)) (z : ℝ → Fields n) (pressure : ℝ → Scalar n)
    (c : ℝ → ℝ) (t : ℝ)
    (h : FullDifferentialAt p response direction U K x0 domain z pressure t) :
    FullDifferentialAt p response direction U K x0 domain z
      (fun s x => pressure s x+c s) t := by sorry

theorem normalized_momentum_equivalent (rho mu sigma dt conv gradP lap a ek : ℝ)
    (hr : rho ≠ 0) :
    (dt+conv=-(gradP/rho)+(mu/rho)*lap-(sigma/rho)*a*ek) ↔
    (rho*(dt+conv)=-gradP+mu*lap-sigma*a*ek) := by sorry

end
end OriginalAS.Verified
