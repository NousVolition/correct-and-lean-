import OriginalASIntegrated
import EnergyAccounting

/-! An exact solution of the unchanged original A/S equations.
All fields are smooth. This is a mathematical witness, not a claim about the
author's preferred physical parameters or boundary conditions.
-/
set_option autoImplicit false
noncomputable section
open scoped BigOperators
namespace OriginalAS.Energy.Witness

def params : Parameters :=
  ⟨1, 1, 1, 1, 0, 1, 1, 0, 0⟩

def scalar : Scalar 2 := fun x => x 1
def velocity (t : ℝ) : Vector 2 := fun _ i => if i = 0 then -(t+1) else 0
def state (t : ℝ) : Fields 2 := ⟨velocity t, scalar⟩

theorem parameters_admissible : Admissible params := by
  norm_num [Admissible, params]

theorem scalar_partial (j : Fin 2) (x : Point 2) :
    coordinatePartial scalar j x = if j = 1 then 1 else 0 := by
  fin_cases j <;> simp [coordinatePartial, scalar, Function.update]

theorem velocity_partial (t : ℝ) (i j : Fin 2) (x : Point 2) :
    coordinatePartial (fun y => velocity t y i) j x = 0 := by
  simp [coordinatePartial, velocity]

theorem scalar_laplacian (x : Point 2) : laplacian scalar x = 0 := by
  unfold laplacian
  apply Finset.sum_eq_zero
  intro j _
  have h : coordinatePartial scalar j = fun _ => if j = 1 then 1 else 0 :=
    funext (scalar_partial j)
  rw [h]
  simp [coordinatePartial]

theorem velocity_laplacian (t : ℝ) (i : Fin 2) (x : Point 2) :
    laplacian (fun y => velocity t y i) x = 0 := by
  unfold laplacian
  apply Finset.sum_eq_zero
  intro j _
  have h : coordinatePartial (fun y => velocity t y i) j = fun _ => 0 :=
    funext (velocity_partial t i j)
  rw [h]
  simp [coordinatePartial]

theorem scalar_advection (t : ℝ) (x : Point 2) : advect (velocity t) scalar x = 0 := by
  simp [advect, scalar_partial, velocity]

theorem velocity_advection (t : ℝ) (i : Fin 2) (x : Point 2) :
    advect (velocity t) (fun y => velocity t y i) x = 0 := by
  simp [advect, velocity_partial]

theorem incompressible (t : ℝ) (x : Point 2) : divergence (velocity t) x = 0 := by
  simp [divergence, velocity_partial]

theorem activation (x : Point 2) : excess params scalar x = 1 := by
  norm_num [excess, params, gradMagnitude, scalar_partial, Fin.sum_univ_succ]

theorem original_force (x : Point 2) (i : Fin 2) :
    force params sharp 0 scalar x i = if i = 0 then -1 else 0 := by
  rw [force, activation]
  norm_num [sharp, params]

theorem original_rates (K : Scalar 2) (x0 : Point 2) (t : ℝ) :
    rates params sharp 0 (fun _ => 0) K x0 t (state t) (fun _ => 0) =
      ⟨(fun _ i => if i = 0 then -1 else 0), (fun _ => 0)⟩ := by
  apply congrArg₂ Fields.mk
  · funext x i
    change -advect (velocity t) (fun y => velocity t y i) x -
      coordinatePartial (fun _ => 0) i x +
      (params.mu / params.rho) * laplacian (fun y => velocity t y i) x +
      force params sharp 0 scalar x i = _
    rw [velocity_advection, velocity_laplacian, original_force]
    simp [coordinatePartial]
  · funext x
    simp [state, scalar_advection, params, sourceRate, memory]

theorem exact_solution (K : Scalar 2) (x0 : Point 2) (domain : Set (Point 2)) (t : ℝ) :
    FullDifferentialAt params sharp 0 (fun _ => 0) K x0 domain state
      (fun _ _ => 0) t := by
  intro x _
  refine ⟨incompressible t x, ?_, ?_⟩
  · rw [original_rates]
    exact hasDerivAt_const t (scalar x)
  · intro i
    rw [original_rates]
    by_cases hi : i = 0
    · subst i
      change HasDerivAt (fun s : ℝ => -(s+1)) (-1) t
      exact ((hasDerivAt_id t).add_const 1).neg
    · simpa only [state, velocity, ite_eq_right hi] using hasDerivAt_const t (0 : ℝ)

theorem stored_state_constant (t : ℝ) :
    memory params (fun _ => 0) t = 0 ∧ (state t).S = scalar := by
  simp [memory, params, state]

theorem viscous_loss_zero (t : ℝ) (x : Point 2) :
    params.mu * velocityGradSquared (state t).u x = 0 := by
  simp [velocityGradSquared, gradSquared, state, velocity_partial]

theorem kinetic_value (t : ℝ) (x : Point 2) :
    kinetic params.rho (state t).u x = (t+1)^2/2 := by
  simp [kinetic, halfSquare, params, state, velocity, Fin.sum_univ_succ]
  ring

theorem coupling_power (t : ℝ) (x : Point 2) :
    hugPower params sharp 0 (state t).u (state t).S x = t+1 := by
  change -params.sigma * sharp (excess params scalar x) * velocity t x 0 = _
  rw [activation]
  simp [sharp, params, velocity]

theorem kinetic_flux_zero (t : ℝ) (x : Point 2) :
    kineticNetFlux params (state t).u (fun _ => 0) x = 0 := by
  simp [kineticNetFlux, state, kinetic, halfSquare, params, velocity,
    divergence, coordinatePartial]

/- This allows an arbitrary functional of the entire instantaneous S field,
   including gradient or nonlocal constructions, and of the stored A value. -/
theorem any_AS_energy_constant (F : ℝ → Scalar 2 → ℝ) (t : ℝ) :
    F (memory params (fun _ => 0) t) (state t).S = F 0 scalar := by
  simp [memory, params, state]

theorem state_energy_cannot_cancel (F : ℝ → Scalar 2 → ℝ) (heat0 : ℝ) (x : Point 2) :
    (kinetic params.rho (state 1).u x + F (memory params (fun _ => 0) 1) (state 1).S + heat0) -
    (kinetic params.rho (state 0).u x + F (memory params (fun _ => 0) 0) (state 0).S + heat0)
      = 3/2 := by
  rw [kinetic_value, kinetic_value, any_AS_energy_constant F 1, any_AS_energy_constant F 0]
  ring

/- Exact spatial integration over a unit-area channel. Velocity and S are
   periodic in the first coordinate. The second velocity component is zero;
   stress and scalar diffusive flux vanish. This is an admissible test setting,
   not a newly imposed boundary condition on the author's intended system. -/
def channelKinetic (t : ℝ) : ℝ :=
  ∫ y in (0 : ℝ)..1, ∫ x in (0 : ℝ)..1,
    kinetic params.rho (state t).u ![x,y]

theorem channel_kinetic_value (t : ℝ) : channelKinetic t = (t+1)^2/2 := by
  simp [channelKinetic, kinetic_value]

theorem no_wall_flow (t : ℝ) (x : Point 2) : (state t).u x 1 = 0 := by
  norm_num [state, velocity]

theorem source_stress_zero (t : ℝ) (x : Point 2) (i j : Fin 2) :
    stress params (state t).u x i j = 0 := by
  simp [stress, state, velocity_partial]

theorem scalar_diffusive_flux_zero (x : Point 2) (j : Fin 2) :
    params.diffusion * coordinatePartial scalar j x = 0 := by
  simp [params]

theorem channel_energy_growth (F : ℝ → Scalar 2 → ℝ) (H : ℝ → ℝ)
    (hH : ∀ t, HasDerivAt H 0 t) :
    (channelKinetic 1 + F (memory params (fun _ => 0) 1) (state 1).S + H 1) -
    (channelKinetic 0 + F (memory params (fun _ => 0) 0) (state 0).S + H 0) = 3/2 := by
  have hheat := is_const_of_deriv_eq_zero (fun t => (hH t).differentiableAt)
    (fun t => (hH t).deriv) (1 : ℝ) 0
  rw [channel_kinetic_value, channel_kinetic_value,
    any_AS_energy_constant F 1, any_AS_energy_constant F 0, hheat]
  ring

theorem no_conserved_state_energy (F : ℝ → Scalar 2 → ℝ) (H : ℝ → ℝ)
    (hH : ∀ t, HasDerivAt H 0 t) :
    ¬ ∀ t, channelKinetic t + F (memory params (fun _ => 0) t) (state t).S + H t =
      channelKinetic 0 + F (memory params (fun _ => 0) 0) (state 0).S + H 0 := by
  intro h
  have hg := channel_energy_growth F H hH
  rw [h 1] at hg
  norm_num at hg

end OriginalAS.Energy.Witness
