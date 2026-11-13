import WindingFluid
import WindingCurve

set_option autoImplicit false
set_option maxHeartbeats 4000000

namespace ClosestPointExample.Winding
noncomputable section
open scoped BigOperators

theorem lift_surjective : Function.Surjective lift := by
  intro v
  have hm : 0 < mu := lt_trans (by norm_num) mu_gt_one
  have hn : mu ≠ 0 := ne_of_gt hm
  let a := v / mu - 1
  let b := v / mu + 1
  have ha := (abs_lt.1 (lift_linear_error a)).2
  have hb := (abs_lt.1 (lift_linear_error b)).1
  have hma : mu * a = v - mu := by dsimp [a]; field_simp <;> ring
  have hmb : mu * b = v + mu := by dsimp [b]; field_simp <;> ring
  have hva : lift a < v := by rw [hma] at ha; linarith
  have hvb : v < lift b := by rw [hmb] at hb; linarith
  have hab : a ≤ b := by dsimp [a, b]; linarith
  have hc : Continuous lift := continuous_iff_continuousAt.2 fun r => (lift_derivative r).continuousAt
  obtain ⟨r, _, hr⟩ := intermediate_value_Icc hab hc.continuousOn ⟨hva.le, hvb.le⟩
  exact ⟨r, hr⟩

/-- Converts the global geometric parameter to the actual curl parameter at T. -/
def clock (b : Bool) (r : ℝ) : ℝ := (if b then lift r else r) / targetSwirl

theorem clock_derivative (b : Bool) (r : ℝ) :
    HasDerivAt (clock b) (tangentScale b r / targetSwirl) r := by
  cases b
  · convert (hasDerivAt_id r).div_const targetSwirl using 1 <;> rfl
  · exact (lift_derivative r).div_const targetSwirl

theorem clock_strictly_increases (b : Bool) : StrictMono (clock b) := by
  apply strictMono_of_deriv_pos
  intro r
  rw [(clock_derivative b r).deriv]
  exact div_pos (curve_scale_positive b r) targetSwirl_positive

theorem clock_surjective (b : Bool) : Function.Surjective (clock b) := by
  intro v
  have hn := ne_of_gt targetSwirl_positive
  cases b
  · refine ⟨v * targetSwirl, ?_⟩
    simp [clock, hn]
  · obtain ⟨r, hr⟩ := lift_surjective (v * targetSwirl)
    exact ⟨r, by simp [clock, hr, hn]⟩

theorem global_clock_bijective (b : Bool) : Function.Bijective (clock b) :=
  ⟨(clock_strictly_increases b).injective, clock_surjective b⟩

theorem clock_starts_at_zero (b : Bool) : clock b 0 = 0 := by
  cases b <;> simp [clock, lift_at_zero]

theorem complete_vortex_curve_at_tick (b : Bool) (r : ℝ) (i : Fin 3) :
    HasDerivAt (fun v => curve b v i)
      ((tangentScale b r / targetSwirl) * vorticity (beta b) tick41 (curve b r) i) r := by
  rw [curl_at_tick]
  have hn := ne_of_gt targetSwirl_positive
  convert curve_tangent b r i using 1 <;> first | rfl | (field_simp <;> ring)

theorem curves_persist_at_every_finite_time (b : Bool) (t r : ℝ) (i : Fin 3) :
    HasDerivAt (fun v => curve b v i)
      ((tangentScale b r / (eigenvalue * amplitude t)) * vorticity (beta b) t (curve b r) i) r := by
  rw [flow_curl]
  unfold flow
  have hn1 := ne_of_gt eigenvalue_positive
  have hn2 := ne_of_gt (amplitude_positive t)
  convert curve_tangent b r i using 1 <;> first | rfl | (field_simp <;> ring)

theorem all_curves_stay_in_plane (b : Bool) (r : ℝ) :
    curve b r = ![curve b r 0, curve b r 1, 0] := by
  cases b <;> funext i <;> fin_cases i <;> simp [curve, openCurve, line]

theorem swirl_never_approaches_zero_on_the_line (b : Bool) (r : ℝ) :
    targetSwirl ^ 2 / 2 ≤
      (vorticity (beta b) tick41 (curve b r) 0)^2 + (vorticity (beta b) tick41 (curve b r) 1)^2 := by
  rw [all_curves_stay_in_plane b r]
  exact positive_swirl_on_plane (beta b) (curve b r 0) (curve b r 1)

/-- The complete curve has its periodic distance minimum at the starting point.
Consequently every finite forward arclength prefix has the same reading. -/
def GlobalClosestAtStart (b : Bool) : Prop :=
  curve b 0 = markerA ∧ imageDistanceSq (curve b 0) (fun _ => 0) = (1/4 : ℝ)^2 ∧
  ∀ r : ℝ, ∀ n : Fin 3 → ℤ, (1/4 : ℝ)^2 ≤ imageDistanceSq (curve b r) n

theorem exact_closest_reading (b : Bool) : GlobalClosestAtStart b := by
  refine ⟨curve_starts_at_A b, ?_, global_closest_bound b⟩
  rw [curve_starts_at_A]
  exact A_attains_bound

def Allowed (b : Bool) : Prop :=
  (∀ i, ContDiff ℝ ⊤ (fun tx : ℝ × Point => flow (beta b) tx.1 tx.2 i)) ∧
  ContDiff ℝ ⊤ (fun tx : ℝ × Point => pressure (beta b) tx.1 tx.2) ∧
  (∀ (t : ℝ) (p : Point) (n : Fin 3 → ℤ), flow (beta b) t (fun i => p i + n i) = flow (beta b) t p) ∧
  (∀ (t : ℝ) (p : Point) (n : Fin 3 → ℤ), pressure (beta b) t (fun i => p i + n i) = pressure (beta b) t p) ∧
  (∀ t p, (∑ i : Fin 3, coordinateDerivative i (fun q => flow (beta b) t q i) p) = 0) ∧
  (∀ t p i, deriv (fun r => flow (beta b) r p i) t +
    (∑ j : Fin 3, flow (beta b) t p j * coordinateDerivative j (fun q => flow (beta b) t q i) p) =
    viscosity * (∑ j : Fin 3,
      coordinateDerivative j (fun q => coordinateDerivative j (fun r => flow (beta b) t r i) q) p)
      - coordinateDerivative i (pressure (beta b) t) p)

theorem both_solve_same_fluid_equations (b : Bool) : Allowed b :=
  ⟨smooth_flow (beta b), smooth_pressure (beta b), periodic_flow (beta b),
   periodic_pressure (beta b), flow_divergence (beta b), solves_navier_stokes (beta b)⟩

abbrev State := {b : Bool // Allowed b}
abbrev Observation := ℝ × Reading × Point
def closedState : State := ⟨false, both_solve_same_fluid_equations false⟩
def openState : State := ⟨true, both_solve_same_fluid_equations true⟩
def observation (s : State) : Observation := (tick41, observe 0, vorticity (beta s.val) tick41 markerA)
def property (s : State) : Bool := by
  classical
  exact decide (Closed s.val)

theorem same_observation : observation closedState = observation openState := by
  simp only [observation, paddle_at_A]

theorem opposite_closure : property closedState ≠ property openState := by
  simp [property, closedState, openState, closed_returns, open_never_returns]

theorem no_exact_reader_with_closest_point_and_paddle :
    ¬ ∃ reader : Observation → Bool, ∀ s : State, reader (observation s) = property s := by
  exact SIMSLatentReadout.no_exact_reader_of_ambiguous_observation
    observation property closedState openState same_observation opposite_closure

#print axioms lift_surjective
#print axioms global_clock_bijective
#print axioms complete_vortex_curve_at_tick
#print axioms curves_persist_at_every_finite_time
#print axioms swirl_never_approaches_zero_on_the_line
#print axioms exact_closest_reading
#print axioms both_solve_same_fluid_equations
#print axioms same_observation
#print axioms opposite_closure
#print axioms no_exact_reader_with_closest_point_and_paddle

end
end ClosestPointExample.Winding
