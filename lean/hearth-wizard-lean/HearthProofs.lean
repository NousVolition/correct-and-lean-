import HearthDefinitions
import WizardBracket

open scoped BigOperators Interval
noncomputable section
namespace HearthAudit
open scoped ContDiff


private theorem shear_gradient (x : Space) (i j : Fin 3) :
    gradient shear x i j = if i=0 ∧ j=1 then Real.cos (x 1) else 0 := by
  by_cases hi : i=0 <;> by_cases hj : j=1
  · subst i; subst j
    simp [gradient,partialAt,shear,Real.deriv_sin]
  · subst i
    simp [gradient,partialAt,shear,hj,Ne.symm hj,Function.update_of_ne]
  · simp [gradient,partialAt,shear,hi]
  · simp [gradient,partialAt,shear,hi]

private theorem shear_laplace (x : Space) (i : Fin 3) :
    laplace shear x i = -shear x i := by
  have term (j : Fin 3) : partialAt (fun q => gradient shear q i j) x j =
      if i=0 ∧ j=1 then -Real.sin (x 1) else 0 := by
    by_cases hi : i=0 <;> by_cases hj : j=1
    · subst i; subst j
      simp [partialAt,shear_gradient,Real.deriv_cos]
    · simp [partialAt,shear_gradient,hi,hj]
    · simp [partialAt,shear_gradient,hi]
    · simp [partialAt,shear_gradient,hi]
  unfold laplace
  simp_rw [term]
  by_cases hi : i=0 <;> simp [shear,hi]

private theorem shear_convection (x : Space) (i : Fin 3) : convection shear x i=0 := by
  unfold convection
  apply Finset.sum_eq_zero
  intro j _
  by_cases hj : j=0
  · subst j; simp [shear_gradient,show (0:Fin 3)≠1 by decide]
  · simp [shear,hj]

private theorem shear_divergence (x : Space) : divergence shear x=0 := by
  unfold divergence
  apply Finset.sum_eq_zero
  intro j _
  have hn : ¬(j=0 ∧ j=1) := by
    rintro ⟨e,h⟩; subst j; exact (by decide : (0:Fin 3)≠1) h
  simp [shear_gradient,hn]

private theorem threeSum (f : Fin 3 → ℝ) : (∑ i, f i) = f 0+f 1+f 2 := by
  simp only [Fin.sum_univ_succ]
  simp only [show (Fin.succ (0 : Fin 2)) = (1 : Fin 3) by decide,
    show (Fin.succ (Fin.succ (0 : Fin 1))) = (2 : Fin 3) by decide]
  ring

private theorem diff01 : (0:Fin 3)≠1 := by decide
private theorem diff10 : (1:Fin 3)≠0 := by decide
private theorem diff20 : (2:Fin 3)≠0 := by decide
private theorem diff21 : (2:Fin 3)≠1 := by decide

private theorem shear_stretch (x : Space) : stretching shear x=0 := by
  have curl : vorticity shear x = ![0,0,-Real.cos (x 1)] := by
    simp [vorticity,shear_gradient,diff01,diff10,diff20,diff21]
  norm_num [stretching,curl,strain,shear_gradient,threeSum,diff01,diff10,diff20,diff21,
    Matrix.cons_val_succ,Matrix.cons_val_two]

private theorem shear_heat (μ : ℝ) (x : Space) :
    dissipation μ shear x=μ*(Real.cos (x 1))^2 := by
  norm_num [dissipation,strain,shear_gradient,threeSum,diff01,diff10,diff20,diff21]
  ring

private theorem cube_of_y (g : ℝ → ℝ) :
    cubeIntegral (fun x => g (x 1)) =
      (2*Real.pi)^2 * (∫ y in (0:ℝ)..2*Real.pi, g y) := by
  unfold cubeIntegral
  have two : (fun y : ℝ => ∫ x in (0:ℝ)..2*Real.pi, ∫ z in (0:ℝ)..2*Real.pi,
      g ((![x,y,z] : Space) 1)) = fun y => (2*Real.pi)^2*g y := by
    funext y
    simp [intervalIntegral.integral_const,smul_eq_mul]
    ring
  rw [two,intervalIntegral.integral_const_mul]

theorem shear_smooth_and_periodic :
    ContDiff ℝ ∞ shear ∧ ∀ x : Space, ∀ j : Fin 3,
      shear (Function.update x j (x j+2*Real.pi))=shear x := by
  constructor
  · apply contDiff_pi.mpr
    intro i
    by_cases hi : i=0
    · simp [shear,hi]; fun_prop
    · simp [shear,hi]; fun_prop
  · intro x j
    funext i
    by_cases hi : i=0 <;> by_cases hj : j=1
    · subst i; subst j; simp [shear,Real.sin_add_two_pi]
    · subst i; simp [shear,Ne.symm hj,Function.update_of_ne]
    · simp [shear,hi]
    · simp [shear,hi]

theorem shear_solves_stationary_forced_momentum (ρ μ t : ℝ) (x : Space) :
    divergence shear x=0 ∧ ∀ i, ρ*(deriv (fun _ : ℝ => shear x i) t+convection shear x i) =
      -partialAt (fun _ => 0) x i + μ*laplace shear x i + μ*shear x i := by
  refine ⟨shear_divergence x,?_⟩
  intro i
  simp [partialAt,shear_convection,shear_laplace]

theorem shear_companion_integrals (μ : ℝ) :
    cubeIntegral (convLap shear)=0 ∧ cubeIntegral (stretching shear)=0 ∧
      cubeIntegral (dissipation μ shear)=4*μ*Real.pi^3 := by
  refine ⟨?_,?_,?_⟩
  · simp [cubeIntegral,convLap,shear_convection]
  · simp [cubeIntegral,shear_stretch]
  · have h : dissipation μ shear = fun x => μ*(Real.cos (x 1))^2 := funext (shear_heat μ)
    rw [h,cube_of_y (fun y => μ*(Real.cos y)^2),intervalIntegral.integral_const_mul]
    rw [integral_cos_sq]
    simp [Real.sin_two_pi]
    ring

theorem companion_identity_fails (μ : ℝ) (positive : 0<μ) :
    ¬ companionIdentity μ shear := by
  obtain ⟨convectionZero,stretchZero,heat⟩ := shear_companion_integrals μ
  unfold companionIdentity
  rw [convectionZero,stretchZero,heat]
  have strictlyPositive : 0<4*μ*Real.pi^3 := by positivity
  linarith

theorem hug_viscous_heat_nonnegative (s : HugV3.Source.State) (x : HugV3.Source.Grid) :
    0≤HugV3.Source.viscousHeat s x := by
  unfold HugV3.Source.viscousHeat
  have viscosityPositive : 0<HugV3.Source.viscosity s x := by
    unfold HugV3.Source.viscosity
    positivity
  exact mul_nonneg (by positivity) (Finset.sum_nonneg (fun i _ =>
    Finset.sum_nonneg (fun j _ => sq_nonneg _)))

theorem hug_temperature_contains_hearth_source (G : HugV3.Source.Geometry) (s d : HugV3.Source.State)
    (t : ℝ) (accepted : HugV3.Source.rhs G t s=some d) (x : HugV3.Source.Grid) :
    d.g x 4 = HugV3.Source.filt (fun y =>
      -HugV3.Source.divergence (fun z j => HugV3.Source.velocity s z j*s.g z 4+HugV3.Source.heatFlux G s z j) y+
      HugV3.Source.viscousHeat s y-HugV3.Source.extraction G s y+HugV3.Source.releaseGrid G s y) x := by
  unfold HugV3.Source.rhs at accepted
  obtain ⟨records,_,eqn⟩ := Option.bind_eq_some_iff.mp accepted
  split at eqn
  · rw [← Option.some.inj eqn]
    rfl
  · cases eqn

end HearthAudit
end
