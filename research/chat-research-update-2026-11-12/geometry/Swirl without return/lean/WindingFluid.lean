import WindingField

set_option autoImplicit false
set_option maxHeartbeats 4000000

namespace ClosestPointExample.Winding
noncomputable section
open scoped BigOperators

theorem phase_shift (m : Fin 3) (p : Point) (n : Fin 3 → ℤ) :
    ∃ k : ℤ, phase m (fun i => p i + n i) = phase m p + k * frequency := by
  fin_cases m
  · refine ⟨3 * n 2, ?_⟩
    norm_num [phase, waveVector]
    ring
  · refine ⟨2 * n 0 + 2 * n 1 + n 2, ?_⟩
    norm_num [phase, waveVector]
    ring
  · refine ⟨2 * n 0 + 2 * n 1 - n 2, ?_⟩
    norm_num [phase, waveVector]
    ring

theorem term_periodic (b : ℝ) (m : Fin 3) (p : Point) (n : Fin 3 → ℤ) (i : Fin 3) :
    term b m (fun j => p j + n j) i = term b m p i := by
  obtain ⟨k, hk⟩ := phase_shift m p n
  simp [term, hk, frequency, Real.sin_add_int_mul_two_pi, Real.cos_add_int_mul_two_pi]

theorem field_periodic (b : ℝ) (p : Point) (n : Fin 3 → ℤ) :
    field b (fun i => p i + n i) = field b p := by
  funext i
  simp [field, term_periodic]

def targetSwirl : ℝ := wave * decay tick41
def amplitude (t : ℝ) : ℝ :=
  targetSwirl / eigenvalue * Real.exp (-viscosity * eigenvalue ^ 2 * (t - tick41))
def flow (b t : ℝ) (p : Point) (i : Fin 3) : ℝ := amplitude t * field b p i
def flowD (b t : ℝ) (p : Point) (i j : Fin 3) : ℝ := amplitude t * fieldD b p i j
def flowDD (b t : ℝ) (p : Point) (i j : Fin 3) : ℝ := amplitude t * fieldDD b p i j
def vorticity (b t : ℝ) (p : Point) : Point := curlOf (flowD b t p)
def pressure (b t : ℝ) (p : Point) : ℝ :=
  -((flow b t p 0)^2 + (flow b t p 1)^2 + (flow b t p 2)^2) / 2

theorem eigenvalue_positive : 0 < eigenvalue := by unfold eigenvalue frequency; positivity
theorem targetSwirl_positive : 0 < targetSwirl := vortex_parameter_scale_positive tick41
theorem amplitude_positive (t : ℝ) : 0 < amplitude t := by
  have h1 := targetSwirl_positive
  have h2 := eigenvalue_positive
  unfold amplitude
  positivity

theorem flow_has_derivative (b t : ℝ) (p : Point) (i j : Fin 3) :
    HasDerivAt (fun r => flow b t (Function.update p j r) i) (flowD b t p i j) (p j) :=
  (field_has_derivative b p i j).const_mul (amplitude t)

theorem flow_has_second (b t : ℝ) (p : Point) (i j : Fin 3) :
    HasDerivAt (fun r => flowD b t (Function.update p j r) i j) (flowDD b t p i j) (p j) :=
  (field_has_second b p i j).const_mul (amplitude t)

theorem flow_partial (b t : ℝ) (p : Point) (i j : Fin 3) :
    coordinateDerivative j (fun q => flow b t q i) p = flowD b t p i j :=
  (flow_has_derivative b t p i j).deriv

theorem flow_second (b t : ℝ) (p : Point) (i j : Fin 3) :
    coordinateDerivative j (fun q => coordinateDerivative j (fun r => flow b t r i) q) p = flowDD b t p i j := by
  simp_rw [flow_partial]
  exact (flow_has_second b t p i j).deriv

theorem flow_curl (b t : ℝ) (p : Point) (i : Fin 3) :
    vorticity b t p i = eigenvalue * flow b t p i := by
  have h := field_beltrami b p i
  fin_cases i <;> simp [vorticity, curlOf, flowD, flow] at * <;>
    linear_combination amplitude t * h

theorem flow_divergence (b t : ℝ) (p : Point) :
    (∑ i : Fin 3, coordinateDerivative i (fun q => flow b t q i) p) = 0 := by
  simp_rw [flow_partial, flowD]
  rw [← Finset.mul_sum, field_divergence]
  ring

theorem flow_laplacian (b t : ℝ) (p : Point) (i : Fin 3) :
    (∑ j : Fin 3, coordinateDerivative j (fun q => coordinateDerivative j (fun r => flow b t r i) q) p) =
      -eigenvalue ^ 2 * flow b t p i := by
  simp_rw [flow_second, flowDD]
  rw [← Finset.mul_sum, field_laplacian]
  unfold flow
  ring

theorem flow_time (b t : ℝ) (p : Point) (i : Fin 3) :
    deriv (fun r => flow b r p i) t = -viscosity * eigenvalue ^ 2 * flow b t p i := by
  have d := ((((((hasDerivAt_id t).sub_const tick41).const_mul
    (-viscosity * eigenvalue ^ 2)).exp).const_mul (targetSwirl / eigenvalue)).mul_const (field b p i))
  have h : HasDerivAt (fun r => flow b r p i) (-viscosity * eigenvalue ^ 2 * flow b t p i) t := by
    convert d using 1 <;> first | rfl | (dsimp [flow, amplitude]; ring)
  exact h.deriv

theorem pressure_partial (b t : ℝ) (p : Point) (i : Fin 3) :
    coordinateDerivative i (pressure b t) p = -(∑ j : Fin 3, flow b t p j * flowD b t p j i) := by
  have d := (((((flow_has_derivative b t p 0 i).pow 2).add
    ((flow_has_derivative b t p 1 i).pow 2)).add ((flow_has_derivative b t p 2 i).pow 2)).neg).div_const 2
  have h : HasDerivAt (fun r => pressure b t (Function.update p i r))
      (-(∑ j : Fin 3, flow b t p j * flowD b t p j i)) (p i) := by
    convert d using 1 <;> first | rfl | (simp [Fin.sum_univ_succ]; ring)
  exact h.deriv

theorem beltrami_advection_identity (u : Point) (J : Fin 3 → Fin 3 → ℝ) (l : ℝ)
    (hc : ∀ i, curlOf J i = l * u i) (i : Fin 3) :
    (∑ j : Fin 3, u j * J i j) = (∑ j : Fin 3, u j * J j i) := by
  have h0 := hc 0
  have h1 := hc 1
  have h2 := hc 2
  change J 2 1 - J 1 2 = l * u 0 at h0
  change J 0 2 - J 2 0 = l * u 1 at h1
  change J 1 0 - J 0 1 = l * u 2 at h2
  fin_cases i <;> simp [Fin.sum_univ_succ]
  · linear_combination -u 1 * h2 + u 2 * h1
  · linear_combination u 0 * h2 - u 2 * h0
  · linear_combination -u 0 * h1 + u 1 * h0

theorem solves_navier_stokes (b t : ℝ) (p : Point) (i : Fin 3) :
    deriv (fun r => flow b r p i) t +
      (∑ j : Fin 3, flow b t p j * coordinateDerivative j (fun q => flow b t q i) p) =
    viscosity * (∑ j : Fin 3,
      coordinateDerivative j (fun q => coordinateDerivative j (fun r => flow b t r i) q) p)
      - coordinateDerivative i (pressure b t) p := by
  rw [flow_time, flow_laplacian, pressure_partial]
  simp_rw [flow_partial]
  rw [beltrami_advection_identity (flow b t p) (flowD b t p) eigenvalue (flow_curl b t p)]
  ring

theorem smooth_flow (b : ℝ) (i : Fin 3) :
    ContDiff ℝ ⊤ (fun tx : ℝ × Point => flow b tx.1 tx.2 i) := by
  dsimp [flow, amplitude, field, term, phase]
  fun_prop

theorem smooth_pressure (b : ℝ) : ContDiff ℝ ⊤ (fun tx : ℝ × Point => pressure b tx.1 tx.2) := by
  dsimp [pressure, flow, amplitude, field, term, phase]
  fun_prop

theorem periodic_flow (b t : ℝ) (p : Point) (n : Fin 3 → ℤ) :
    flow b t (fun i => p i + n i) = flow b t p := by
  funext i
  simp only [flow, field_periodic]

theorem periodic_pressure (b t : ℝ) (p : Point) (n : Fin 3 → ℤ) :
    pressure b t (fun i => p i + n i) = pressure b t p := by
  simp only [pressure, periodic_flow]

theorem curl_at_tick (b : ℝ) (p : Point) (i : Fin 3) :
    vorticity b tick41 p i = targetSwirl * field b p i := by
  rw [flow_curl]
  have hn := ne_of_gt eigenvalue_positive
  simp only [flow, amplitude, sub_self, mul_zero, Real.exp_zero, mul_one]
  field_simp

theorem paddle_at_A (b : ℝ) : vorticity b tick41 markerA = ![0,targetSwirl,0] := by
  funext i
  rw [curl_at_tick, field_at_A]
  fin_cases i <;> simp

theorem positive_swirl_on_plane (b x y : ℝ) :
    targetSwirl ^ 2 / 2 ≤
      (vorticity b tick41 ![x,y,0] 0)^2 + (vorticity b tick41 ![x,y,0] 1)^2 := by
  rw [curl_at_tick, curl_at_tick]
  have h := mul_le_mul_of_nonneg_left (plane_nonzero b x y) (sq_nonneg targetSwirl)
  nlinarith

#print axioms solves_navier_stokes
#print axioms flow_divergence
#print axioms smooth_flow
#print axioms smooth_pressure
#print axioms periodic_flow
#print axioms periodic_pressure
#print axioms paddle_at_A
#print axioms positive_swirl_on_plane

end
end ClosestPointExample.Winding
