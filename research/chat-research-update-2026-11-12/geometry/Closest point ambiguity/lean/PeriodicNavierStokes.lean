import ClosestPointGeometry

/-!
Both witnesses come from one smooth family of solutions of unforced,
incompressible Navier–Stokes on the unit three-torus, with the same viscosity.
The derivatives below are ordinary coordinate derivatives, not supplied data.
-/
set_option autoImplicit false
set_option maxHeartbeats 2000000

namespace ClosestPointExample
noncomputable section
open scoped BigOperators

def viscosity : ℝ := 3 / 200
def wave : ℝ := 4 * Real.pi
def tick41 : ℝ := 6 / 5
def decay (t : ℝ) : ℝ := Real.exp (-viscosity * wave ^ 2 * t)
def shape (t z : ℝ) : ℝ := decay t * Real.sin (wave * z)
def shapeZ (t z : ℝ) : ℝ := decay t * (wave * Real.cos (wave * z))
def coefficient (a : ℝ) : Point := ![1, -a, 0]
def velocity (a t : ℝ) (p : Point) (i : Fin 3) : ℝ :=
  coefficient a i * shape t (p 2)
def pressure (_t : ℝ) (_p : Point) : ℝ := 0
def force (_t : ℝ) (_p : Point) (_i : Fin 3) : ℝ := 0

def coordinateDerivative (j : Fin 3) (f : Point → ℝ) (p : Point) : ℝ :=
  deriv (fun r => f (Function.update p j r)) (p j)
def divergence (a t : ℝ) (p : Point) : ℝ :=
  ∑ i : Fin 3, coordinateDerivative i (fun q => velocity a t q i) p
def advection (a t : ℝ) (p : Point) (i : Fin 3) : ℝ :=
  ∑ j : Fin 3, velocity a t p j * coordinateDerivative j (fun q => velocity a t q i) p
def laplacian (a t : ℝ) (p : Point) (i : Fin 3) : ℝ :=
  ∑ j : Fin 3, coordinateDerivative j (fun q => coordinateDerivative j (fun r => velocity a t r i) q) p

def curl (a t : ℝ) (p : Point) : Point :=
  ![coordinateDerivative 1 (fun q => velocity a t q 2) p - coordinateDerivative 2 (fun q => velocity a t q 1) p,
    coordinateDerivative 2 (fun q => velocity a t q 0) p - coordinateDerivative 0 (fun q => velocity a t q 2) p,
    coordinateDerivative 0 (fun q => velocity a t q 1) p - coordinateDerivative 1 (fun q => velocity a t q 0) p]

theorem viscosity_positive : 0 < viscosity := by norm_num [viscosity]
theorem wave_positive : 0 < wave := by unfold wave; positivity
theorem decay_positive (t : ℝ) : 0 < decay t := Real.exp_pos _

theorem shape_has_z_derivative (t z : ℝ) :
    HasDerivAt (shape t) (shapeZ t z) z := by
  have h := (((hasDerivAt_id z).const_mul wave).sin).const_mul (decay t)
  convert h using 1 <;> first | rfl | (dsimp [shape, shapeZ]; ring)

theorem shapeZ_has_z_derivative (t z : ℝ) :
    HasDerivAt (shapeZ t) (-wave ^ 2 * shape t z) z := by
  have h := ((((hasDerivAt_id z).const_mul wave).cos).const_mul wave).const_mul (decay t)
  convert h using 1 <;> first | rfl | (dsimp [shape, shapeZ]; ring)

theorem shape_has_time_derivative (t z : ℝ) :
    HasDerivAt (fun v => shape v z) (-viscosity * wave ^ 2 * shape t z) t := by
  have h := (((hasDerivAt_id t).const_mul (-viscosity * wave ^ 2)).exp).mul_const
    (Real.sin (wave * z))
  convert h using 1 <;> first | rfl | (dsimp [shape, decay]; ring)

theorem partial_vertical (f : ℝ → ℝ) (p : Point) (j : Fin 3) :
    coordinateDerivative j (fun q => f (q 2)) p = if j = 2 then deriv f (p 2) else 0 := by
  by_cases hj : j = 2
  · subst j
    simp [coordinateDerivative]
  · simp [coordinateDerivative, hj, Ne.symm hj]

theorem space_partial (a t : ℝ) (p : Point) (i j : Fin 3) :
    coordinateDerivative j (fun q => velocity a t q i) p =
      if j = 2 then coefficient a i * shapeZ t (p 2) else 0 := by
  change coordinateDerivative j (fun q => (fun z => coefficient a i * shape t z) (q 2)) p = _
  rw [partial_vertical (fun z => coefficient a i * shape t z) p j]
  rw [((shape_has_z_derivative t (p 2)).const_mul (coefficient a i)).deriv]

theorem space_partial_twice (a t : ℝ) (p : Point) (i j : Fin 3) :
    coordinateDerivative j (fun q => coordinateDerivative j (fun r => velocity a t r i) q) p =
      if j = 2 then -wave ^ 2 * velocity a t p i else 0 := by
  simp_rw [space_partial]
  by_cases hj : j = 2
  · subst j
    simp only [ite_true]
    rw [partial_vertical (fun z => coefficient a i * shapeZ t z) p 2]
    rw [((shapeZ_has_z_derivative t (p 2)).const_mul (coefficient a i)).deriv]
    simp only [ite_true, velocity]
    ring
  · simp [hj, coordinateDerivative]

theorem time_derivative (a t : ℝ) (p : Point) (i : Fin 3) :
    deriv (fun v => velocity a v p i) t = -viscosity * wave ^ 2 * velocity a t p i := by
  change deriv (fun v => coefficient a i * shape v (p 2)) t = _
  rw [((shape_has_time_derivative t (p 2)).const_mul (coefficient a i)).deriv]
  unfold velocity
  ring

theorem incompressible (a t : ℝ) (p : Point) : divergence a t p = 0 := by
  simp [divergence, Fin.sum_univ_succ, space_partial, coefficient]

theorem advection_zero (a t : ℝ) (p : Point) (i : Fin 3) : advection a t p i = 0 := by
  unfold advection
  simp_rw [space_partial]
  simp [Fin.sum_univ_succ, velocity, coefficient]

theorem laplacian_eq (a t : ℝ) (p : Point) (i : Fin 3) :
    laplacian a t p i = -wave ^ 2 * velocity a t p i := by
  simp [laplacian, Fin.sum_univ_succ, space_partial_twice]

/-- The same full PDE, with the same viscosity, zero pressure and zero force. -/
theorem navier_stokes (a t : ℝ) (p : Point) (i : Fin 3) :
    deriv (fun v => velocity a v p i) t + advection a t p i =
    viscosity * laplacian a t p i - coordinateDerivative i (pressure t) p + force t p i := by
  rw [time_derivative, advection_zero, laplacian_eq]
  simp [pressure, coordinateDerivative, force]
  ring

theorem smooth_velocity (a : ℝ) (i : Fin 3) :
    ContDiff ℝ ⊤ (fun tx : ℝ × Point => velocity a tx.1 tx.2 i) := by
  dsimp [velocity, shape, decay]
  fun_prop

theorem shape_periodic (t z : ℝ) (n : ℤ) : shape t (z + n) = shape t z := by
  unfold shape
  congr 1
  convert Real.sin_add_int_mul_two_pi (wave * z) (2 * n) using 1 <;>
    push_cast <;> unfold wave <;> congr 1 <;> ring

theorem spatially_periodic (a t : ℝ) (p : Point) (n : Fin 3 → ℤ) :
    velocity a t (fun i => p i + n i) = velocity a t p := by
  funext i
  exact congrArg (fun z => coefficient a i * z) (shape_periodic t (p 2) (n 2))

theorem markers_stationary (a t : ℝ) :
    velocity a t markerA = (fun _ => 0) ∧ velocity a t markerB = (fun _ => 0) := by
  constructor <;> funext i
  · change coefficient a i * (decay t * Real.sin (wave * 0)) = 0
    simp
  · change coefficient a i * (decay t * Real.sin (wave * (1 / 4))) = 0
    have hw : wave * (1 / 4 : ℝ) = Real.pi := by unfold wave; ring
    rw [hw, Real.sin_pi]
    ring

theorem curl_on_line (a t r : ℝ) (i : Fin 3) :
    curl a t (line a r) i = (wave * decay t) * direction a i := by
  fin_cases i <;> simp [curl, space_partial, coefficient, shapeZ, line, direction] <;> ring

theorem line_has_derivative (a r : ℝ) (i : Fin 3) :
    HasDerivAt (fun v => line a v i) (direction a i) r := by
  fin_cases i
  · simpa [line, direction] using (hasDerivAt_id r).const_mul a
  · convert hasDerivAt_id' r using 1 <;> rfl
  · simpa [line, direction] using hasDerivAt_const r (0 : ℝ)

/-- Positive reparameterization makes the geometric line an exact integral
curve of the actual curl at every fixed time, including tick 41. -/
theorem vortex_line_ODE (a t r : ℝ) (i : Fin 3) :
    HasDerivAt (fun v => line a ((wave * decay t) * v) i)
      (curl a t (line a ((wave * decay t) * r)) i) r := by
  have h := (line_has_derivative a ((wave * decay t) * r) i).comp r
    ((hasDerivAt_id r).const_mul (wave * decay t))
  rw [curl_on_line]
  convert h using 1 <;> first | rfl | ring

theorem vortex_parameter_scale_positive (t : ℝ) : 0 < wave * decay t :=
  mul_pos wave_positive (decay_positive t)

/-- Packages all same-equation checks independently of which slope is chosen. -/
def Admissible (a : ℝ) : Prop :=
  (∀ i, ContDiff ℝ ⊤ (fun tx : ℝ × Point => velocity a tx.1 tx.2 i)) ∧
  (∀ (t : ℝ) (p : Point) (n : Fin 3 → ℤ), velocity a t (fun i => p i + n i) = velocity a t p) ∧
  (∀ t p, divergence a t p = 0) ∧
  (∀ t p i, deriv (fun v => velocity a v p i) t + advection a t p i =
    viscosity * laplacian a t p i - coordinateDerivative i (pressure t) p + force t p i)

theorem every_family_member_admissible (a : ℝ) : Admissible a := by
  exact ⟨smooth_velocity a, spatially_periodic a, incompressible a, navier_stokes a⟩

theorem exact_same_equation_witnesses :
    Admissible 0 ∧ Admissible (Real.sqrt 2) ∧
    ValidReading 0 (observe 0) ∧ ValidReading (Real.sqrt 2) (observe (Real.sqrt 2)) ∧
    observe 0 = observe (Real.sqrt 2) ∧ Closed 0 ∧ ¬ Closed (Real.sqrt 2) :=
  ⟨every_family_member_admissible 0, every_family_member_admissible (Real.sqrt 2),
   observation_is_valid 0, observation_is_valid (Real.sqrt 2),
   same_closest_point_reading, zero_line_is_closed, sqrt_two_line_is_open⟩

#print axioms incompressible
#print axioms navier_stokes
#print axioms smooth_velocity
#print axioms spatially_periodic
#print axioms markers_stationary
#print axioms curl_on_line
#print axioms vortex_line_ODE
#print axioms exact_same_equation_witnesses

end
end ClosestPointExample

