import MatchingPaddleFluid

set_option autoImplicit false
set_option maxHeartbeats 3000000

namespace ClosestPointExample.MatchingPaddle
noncomputable section

/-- The parameter r follows a vortex line with fluid time fixed at tick41. -/
def cotCoordinate (r : ℝ) : ℝ := Real.sqrt 3 - 4 * Real.pi * swirlScale * r
def openY (r : ℝ) : ℝ := 1 / 3 - Real.arctan (cotCoordinate r) / Real.pi
def vortexCurve (b : Bool) (r : ℝ) : Point :=
  line 0 (if b then openY r else swirlScale * r)

theorem openY_zero : openY 0 = 0 := by
  simp only [openY, cotCoordinate, mul_zero, sub_zero, Real.arctan_sqrt_three]
  field_simp
  ring

theorem curves_start_at_A (b : Bool) : vortexCurve b 0 = markerA := by
  cases b <;> simp [vortexCurve, openY_zero, line, markerA]

theorem openY_has_derivative (r : ℝ) :
    HasDerivAt openY (4 * swirlScale / (1 + cotCoordinate r ^ 2)) r := by
  have d := (((((hasDerivAt_id r).const_mul (4 * Real.pi * swirlScale)).const_sub
    (Real.sqrt 3)).arctan).div_const Real.pi).const_sub (1 / 3)
  convert d using 1 <;> first | rfl | (dsimp [openY, cotCoordinate]; field_simp <;> ring)

theorem gain_along_open_curve (r : ℝ) :
    gain true (openY r) = 4 / (1 + cotCoordinate r ^ 2) := by
  have angle : transverseWave * openY r + phase = Real.pi - 2 * Real.arctan (cotCoordinate r) := by
    unfold transverseWave openY phase
    field_simp
    ring
  simp only [gain, ite_true]
  rw [angle, Real.cos_pi_sub, Real.cos_two_mul, Real.cos_sq_arctan]
  ring

theorem actual_curl_integral_curve (b : Bool) (r : ℝ) (i : Fin 3) :
    HasDerivAt (fun v => vortexCurve b v i) (vorticity b tick41 (vortexCurve b r) i) r := by
  cases b
  · have d := (line_has_derivative 0 (swirlScale * r) i).comp r
      ((hasDerivAt_id r).const_mul swirlScale)
    simp only [vortexCurve, Bool.false_eq_true, ite_false]
    rw [curl_on_axis]
    simp only [gain, Bool.false_eq_true, ite_false]
    convert d using 1 <;> first | rfl | ring
  · have d := (line_has_derivative 0 (openY r) i).comp r (openY_has_derivative r)
    simp only [vortexCurve, ite_true]
    rw [curl_on_axis, gain_along_open_curve]
    convert d using 1 <;> first | rfl | ring

theorem open_forward_bounds (r : ℝ) (hr : 0 < r) : 0 < openY r ∧ openY r < 5 / 6 := by
  have hw := swirlScale_positive
  have hscale : 0 < 4 * Real.pi * swirlScale := by positivity
  have harg : cotCoordinate r < Real.sqrt 3 := by
    unfold cotCoordinate
    have := mul_pos hscale hr
    linarith
  have ha : Real.arctan (cotCoordinate r) < Real.pi / 3 := by
    simpa using Real.arctan_strictMono harg
  have hb := Real.neg_pi_div_two_lt_arctan (cotCoordinate r)
  have hqa : Real.arctan (cotCoordinate r) / Real.pi < 1 / 3 :=
    (div_lt_iff₀ Real.pi_pos).2 (by linarith)
  have hqb : (-1 / 2 : ℝ) < Real.arctan (cotCoordinate r) / Real.pi :=
    (lt_div_iff₀ Real.pi_pos).2 (by linarith)
  unfold openY
  constructor <;> linarith

def ClosedAtTick (b : Bool) : Prop :=
  ∃ r : ℝ, 0 < r ∧ ∃ n : Fin 3 → ℤ, ∀ i, vortexCurve b r i = (n i : ℝ)

theorem closed_witness_returns : ClosedAtTick false := by
  have hw := swirlScale_positive
  refine ⟨1 / swirlScale, by positivity, ![0, 1, 0], ?_⟩
  intro i
  have hn := ne_of_gt swirlScale_positive
  fin_cases i <;> simp [vortexCurve, line, hn]

theorem open_witness_never_returns : ¬ ClosedAtTick true := by
  rintro ⟨r, hr, n, hn⟩
  have hy : openY r = (n 1 : ℝ) := by simpa [vortexCurve, line] using hn 1
  have bounds := open_forward_bounds r hr
  have npos : 0 < n 1 := by exact_mod_cast (show (0 : ℝ) < (n 1 : ℝ) by linarith)
  have nsmall : n 1 < 1 := by exact_mod_cast (show (n 1 : ℝ) < 1 by linarith)
  omega

theorem nonzero_on_full_curves (b : Bool) (r : ℝ) :
    0 < vorticity b tick41 (vortexCurve b r) 1 := by
  cases b
  · simp [vortexCurve, curl_on_axis, gain, direction, swirlScale_positive]
  · simp only [vortexCurve, ite_true]
    rw [curl_on_axis, gain_along_open_curve]
    have hw := swirlScale_positive
    norm_num [direction]
    positivity

theorem gain_positive_on_saved_trace (b : Bool) (s : ℝ) (hs : 0 ≤ s) (hL : s ≤ traceLength) :
    0 < gain b s := by
  cases b
  · norm_num [gain]
  · have hp := Real.pi_pos
    have hps : 0 ≤ Real.pi * s := mul_nonneg hp.le hs
    have hpsL : Real.pi * s ≤ Real.pi * (3 / 4) :=
      mul_le_mul_of_nonneg_left hL hp.le
    have ha : 0 < transverseWave * s + phase := by unfold transverseWave phase; nlinarith
    have hb : transverseWave * s + phase < 2 * Real.pi := by unfold transverseWave phase; nlinarith
    have hn : Real.cos (transverseWave * s + phase) ≠ 1 := by
      intro he
      have hz := (Real.cos_eq_one_iff_of_lt_of_lt (by linarith : -(2 * Real.pi) < transverseWave * s + phase) hb).1 he
      linarith
    have hc : Real.cos (transverseWave * s + phase) < 1 :=
      lt_of_le_of_ne (Real.cos_le_one _) hn
    simp only [gain, ite_true]
    linarith

/-- Both use the identical unit-speed trace s ↦ (0,s,0), of the old length 3/4.
The positive factor is exactly the magnitude of curl on that trace. -/
theorem common_normalized_vortex_trace (b : Bool) (s : ℝ) (hs : 0 ≤ s)
    (hL : s ≤ traceLength) (i : Fin 3) :
    HasDerivAt (fun v => line 0 v i)
      (vorticity b tick41 (line 0 s) i / (swirlScale * gain b s)) s := by
  have hn : swirlScale * gain b s ≠ 0 :=
    ne_of_gt (mul_pos swirlScale_positive (gain_positive_on_saved_trace b s hs hL))
  rw [curl_on_axis]
  have hc : (swirlScale * gain b s * direction 0 i) / (swirlScale * gain b s) = direction 0 i :=
    (div_eq_iff hn).2 (by ring)
  rw [hc]
  exact line_has_derivative 0 s i

theorem trace_tangent_is_unit : (∑ i : Fin 3, (direction 0 i) ^ 2) = 1 := by
  norm_num [Fin.sum_univ_succ, direction]

theorem prior_trace_is_same (s : ℝ) : arc 0 s = line 0 s := by
  simp [arc, speed]

theorem unchanged_closest_reading : ValidReading 0 (observe 0) := observation_is_valid 0

#print axioms curves_start_at_A
#print axioms actual_curl_integral_curve
#print axioms open_forward_bounds
#print axioms closed_witness_returns
#print axioms open_witness_never_returns
#print axioms nonzero_on_full_curves
#print axioms common_normalized_vortex_trace
#print axioms unchanged_closest_reading

end
end ClosestPointExample.MatchingPaddle
