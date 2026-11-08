import HearthDefinitions

open scoped BigOperators Interval
noncomputable section

namespace Wizard

theorem fromFin_toFin (w : Wizard) : fromFin (toFin w) = w := by sorry

theorem toFin_fromFin (i : Fin 7) : toFin (fromFin i) = i := by sorry

end Wizard

namespace CommutatorMatrix

variable (C : CommutatorMatrix)

theorem diag_zero (i : Fin 7) : C.κ i i = 0 := by sorry

theorem bracket_antisymm (w₁ w₂ : Wizard) (Φ : ℝ) :
    C.bracket w₁ w₂ Φ = - C.bracket w₂ w₁ Φ := by sorry

theorem sum_all_vanishes :
    (∑ i : Fin 7, ∑ j : Fin 7, C.κ i j) = 0 := by sorry

theorem quadratic_form_zero (v : Fin 7 → ℝ) :
    (∑ i : Fin 7, ∑ j : Fin 7, v i * C.κ i j * v j) = 0 := by sorry

theorem bracket_self (w : Wizard) (Φ : ℝ) : C.bracket w w Φ=0 := by sorry

theorem sum_all_brackets (Φ : ℝ) :
    (∑ i : Fin 7, ∑ j : Fin 7, C.bracket (Wizard.fromFin i) (Wizard.fromFin j) Φ)=0 := by sorry

theorem form_basis_pair (Φ : ℝ) (a b : Fin 7) :
    C.form Φ (basis a) (basis b)=C.κ a b*Φ := by sorry

theorem form_antisymm (Φ : ℝ) (v w : WizardVector) :
    C.form Φ v w= -C.form Φ w v := by sorry

theorem form_bilinear (Φ a b : ℝ) (u v w : WizardVector) :
    C.form Φ (a • u+b • v) w=a*C.form Φ u w+b*C.form Φ v w ∧
    C.form Φ w (a • u+b • v)=a*C.form Φ w u+b*C.form Φ w v := by sorry

theorem form_alternating (Φ : ℝ) (v : WizardVector) : C.form Φ v v=0 := by sorry

theorem centrality_criterion (Φ : ℝ) (nonzero : Φ≠0) :
    (∀ w, C.bracket Wizard.hearth w Φ=0) ↔ C.CentralHearth := by sorry

theorem central_lift_satisfies_jacobi (Φ : ℝ) (central : C.CentralHearth) (u v w : WizardVector) :
    C.jacobiSum Φ u v w=0 := by sorry

theorem arbitrary_skew_lift_can_fail_jacobi :
    twoPairs.jacobiSum 1 (basis 1) (basis 2) (basis 3) 0 = -1 := by sorry

theorem finite_kinetic_energy_rate (Φ : ℝ) (v : ℝ → WizardVector) (t : ℝ)
    (law : ∀ i, HasDerivAt (fun τ => v τ i) (Φ * ∑ j, C.κ i j*v t j) t) :
    HasDerivAt (fun τ => (1/2:ℝ)*∑ i, (v τ i)^2) 0 t := by sorry

end CommutatorMatrix

namespace HearthAudit
open scoped ContDiff

theorem shear_smooth_and_periodic :
    ContDiff ℝ ∞ shear ∧ ∀ x : Space, ∀ j : Fin 3,
      shear (Function.update x j (x j+2*Real.pi))=shear x := by sorry

theorem shear_solves_stationary_forced_momentum (ρ μ t : ℝ) (x : Space) :
    divergence shear x=0 ∧ ∀ i, ρ*(deriv (fun _ : ℝ => shear x i) t+convection shear x i) =
      -partialAt (fun _ => 0) x i + μ*laplace shear x i + μ*shear x i := by sorry

theorem shear_companion_integrals (μ : ℝ) :
    cubeIntegral (convLap shear)=0 ∧ cubeIntegral (stretching shear)=0 ∧
      cubeIntegral (dissipation μ shear)=4*μ*Real.pi^3 := by sorry

theorem companion_identity_fails (μ : ℝ) (positive : 0<μ) :
    ¬ companionIdentity μ shear := by sorry

theorem hug_viscous_heat_nonnegative (s : HugV3.Source.State) (x : HugV3.Source.Grid) :
    0≤HugV3.Source.viscousHeat s x := by sorry

theorem hug_temperature_contains_hearth_source (G : HugV3.Source.Geometry) (s d : HugV3.Source.State)
    (t : ℝ) (accepted : HugV3.Source.rhs G t s=some d) (x : HugV3.Source.Grid) :
    d.g x 4 = HugV3.Source.filt (fun y =>
      -HugV3.Source.divergence (fun z j => HugV3.Source.velocity s z j*s.g z 4+HugV3.Source.heatFlux G s z j) y+
      HugV3.Source.viscousHeat s y-HugV3.Source.extraction G s y+HugV3.Source.releaseGrid G s y) x := by sorry

end HearthAudit
end
