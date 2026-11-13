import WindingField

set_option autoImplicit false
set_option maxHeartbeats 4000000

namespace ClosestPointExample.Winding
noncomputable section

def mu : ℝ := Real.sqrt 2
def rho : ℝ := (mu - 1) / (mu + 1)
def angle (r : ℝ) : ℝ := 2 * frequency * r
def C (r : ℝ) : ℝ := Real.cos (angle r)
def S (r : ℝ) : ℝ := Real.sin (angle r)
def denominator (r : ℝ) : ℝ := 1 + rho * C r
def numerator (r : ℝ) : ℝ := rho * S r
def ratio (r : ℝ) : ℝ := numerator r / denominator r
def squareDenominator (r : ℝ) : ℝ := denominator r ^ 2 + numerator r ^ 2
def lift (r : ℝ) : ℝ := mu * (r - Real.arctan (ratio r) / frequency)
def gain (r : ℝ) : ℝ := 4 / (3 + C r)

theorem mu_squared : mu ^ 2 = 2 := Real.sq_sqrt (by norm_num)
theorem mu_gt_one : 1 < mu := by
  have hm : 0 ≤ mu := Real.sqrt_nonneg 2
  nlinarith [mu_squared]
theorem rho_bounds : 0 < rho ∧ rho < 1 := by
  have h := mu_gt_one
  constructor
  · unfold rho
    positivity
  · unfold rho
    apply (div_lt_one (by linarith : 0 < mu + 1)).2
    linarith
theorem denominator_positive (r : ℝ) : 0 < denominator r := by
  have hb := mul_le_mul_of_nonneg_left (Real.neg_one_le_cos (angle r)) rho_bounds.1.le
  unfold denominator C
  nlinarith [rho_bounds.2]
theorem squareDenominator_positive (r : ℝ) : 0 < squareDenominator r := by
  have h := denominator_positive r
  unfold squareDenominator
  positivity
theorem cosine_denominator_positive (r : ℝ) : 0 < 3 + C r := by
  have h := Real.neg_one_le_cos (angle r)
  unfold C
  linarith
theorem frequency_positive : 0 < frequency := by unfold frequency; positivity

theorem squareDenominator_short (r : ℝ) :
    squareDenominator r = 1 + 2 * rho * C r + rho ^ 2 := by
  have h := Real.sin_sq_add_cos_sq (angle r)
  unfold squareDenominator denominator numerator C S
  linear_combination rho ^ 2 * h

theorem ratio_derivative (r : ℝ) :
    HasDerivAt ratio (2 * frequency * rho * (C r + rho) / denominator r ^ 2) r := by
  have ht : HasDerivAt angle (2 * frequency) r := by
    convert (hasDerivAt_id r).const_mul (2 * frequency) using 1 <;> first | rfl | ring
  have hn : HasDerivAt numerator (2 * frequency * rho * C r) r := by
    convert ht.sin.const_mul rho using 1 <;> first | rfl | (dsimp [numerator, S, C]; ring)
  have hd : HasDerivAt denominator (-2 * frequency * rho * S r) r := by
    convert (ht.cos.const_mul rho).const_add 1 using 1 <;> first | rfl | (dsimp [denominator, S, C]; ring)
  have hnum : (2 * frequency * rho * C r) * denominator r -
      numerator r * (-2 * frequency * rho * S r) = 2 * frequency * rho * (C r + rho) := by
    have h := Real.sin_sq_add_cos_sq (angle r)
    unfold denominator numerator C S
    linear_combination (2 * frequency * rho ^ 2) * h
  convert hn.div hd (ne_of_gt (denominator_positive r)) using 1
  · rfl
  · rfl
  · rfl
  · rw [hnum]

theorem arctan_ratio_derivative (r : ℝ) :
    HasDerivAt (fun v => Real.arctan (ratio v))
      (2 * frequency * rho * (C r + rho) / squareDenominator r) r := by
  have hn := ne_of_gt (denominator_positive r)
  have hk := ne_of_gt (squareDenominator_positive r)
  have h : 1 + ratio r ^ 2 = squareDenominator r / denominator r ^ 2 := by
    unfold ratio squareDenominator
    field_simp <;> ring
  convert (ratio_derivative r).arctan using 1 <;> first | rfl | (rw [h]; field_simp <;> ring)

theorem lift_factor (r : ℝ) : mu * (1 - rho ^ 2) / squareDenominator r = gain r := by
  have hm := mu_gt_one
  have hn : mu + 1 ≠ 0 := by linarith
  have hc := ne_of_gt (cosine_denominator_positive r)
  have ha : mu * (1 - rho ^ 2) = 8 / (mu + 1) ^ 2 := by
    unfold rho
    field_simp
    nlinarith [mu_squared]
  have hb : squareDenominator r = 2 * (3 + C r) / (mu + 1) ^ 2 := by
    rw [squareDenominator_short]
    unfold rho
    field_simp
    linear_combination (2 + 2 * C r) * mu_squared
  rw [ha, hb]
  unfold gain
  field_simp
  ring

theorem lift_derivative (r : ℝ) : HasDerivAt lift (gain r) r := by
  have d := ((hasDerivAt_id r).sub ((arctan_ratio_derivative r).div_const frequency)).const_mul mu
  rw [← lift_factor]
  have hn := ne_of_gt frequency_positive
  have hk := ne_of_gt (squareDenominator_positive r)
  convert d using 1 <;> first | rfl | (field_simp [hn, hk]; rw [squareDenominator_short]; ring)

theorem gain_bounds (r : ℝ) : 1 ≤ gain r ∧ gain r ≤ 2 := by
  have hc := cosine_denominator_positive r
  have hi := Real.neg_one_le_cos (angle r)
  have hj := Real.cos_le_one (angle r)
  change -1 ≤ C r at hi
  change C r ≤ 1 at hj
  unfold gain
  constructor
  · apply (le_div_iff₀ hc).2
    linarith
  · apply (div_le_iff₀ hc).2
    linarith

theorem lift_at_zero : lift 0 = 0 := by
  simp [lift, ratio, numerator, S, angle]

theorem lift_at_integer (n : ℤ) : lift (n : ℝ) = mu * n := by
  have hs : S (n : ℝ) = 0 := by
    unfold S angle frequency
    convert Real.sin_int_mul_pi (4 * n) using 1 <;> push_cast <;> congr 1 <;> ring
  simp [lift, ratio, numerator, hs]

theorem lift_linear_error (r : ℝ) : |lift r - mu * r| < mu / 4 := by
  have ha := Real.arctan_lt_pi_div_two (ratio r)
  have hb := Real.neg_pi_div_two_lt_arctan (ratio r)
  have hm : 0 < mu := lt_trans (by norm_num) mu_gt_one
  have hfreq := frequency_positive
  have hd1 : Real.arctan (ratio r) / frequency < (1 / 4 : ℝ) :=
    (div_lt_iff₀ hfreq).2 (by unfold frequency; linarith)
  have hd2 : (-1 / 4 : ℝ) < Real.arctan (ratio r) / frequency :=
    (lt_div_iff₀ hfreq).2 (by unfold frequency; linarith)
  rw [abs_lt]
  unfold lift
  constructor <;> nlinarith

def openCurve (r : ℝ) : Point := ![(r - lift r) / 2, (r + lift r) / 2, 0]
def curve (b : Bool) (r : ℝ) : Point := if b then openCurve r else line 0 r
def beta (b : Bool) : ℝ := if b then 1 / 8 else 0
def tangentScale (b : Bool) (r : ℝ) : ℝ := if b then gain r else 1

theorem curve_starts_at_A (b : Bool) : curve b 0 = markerA := by
  cases b <;> simp [curve, openCurve, lift_at_zero, line, markerA]

theorem open_curve_sum (r : ℝ) : openCurve r 0 + openCurve r 1 = r := by
  simp [openCurve]
  ring

theorem open_curve_difference (r : ℝ) : openCurve r 1 - openCurve r 0 = lift r := by
  simp [openCurve]
  ring

theorem open_curve_tangent (r : ℝ) (i : Fin 3) :
    HasDerivAt (fun v => openCurve v i) (gain r * field (1 / 8) (openCurve r) i) r := by
  have hx := ((hasDerivAt_id r).sub (lift_derivative r)).div_const 2
  have hy := ((hasDerivAt_id r).add (lift_derivative r)).div_const 2
  have hs : (r - lift r) / 2 + (r + lift r) / 2 = r := by ring
  have hn := ne_of_gt (cosine_denominator_positive r)
  dsimp [C, angle] at hn
  unfold openCurve
  rw [field_on_plane, hs]
  fin_cases i
  · convert hx using 1 <;> first | rfl | (dsimp [gain, C, angle]; field_simp [hn]; ring)
  · convert hy using 1 <;> first | rfl | (dsimp [gain, C, angle]; field_simp [hn]; ring)
  · simp
    exact hasDerivAt_const r 0

theorem curve_tangent (b : Bool) (r : ℝ) (i : Fin 3) :
    HasDerivAt (fun v => curve b v i) (tangentScale b r * field (beta b) (curve b r) i) r := by
  cases b
  · simp only [curve, beta, tangentScale, Bool.false_eq_true, ite_false, one_mul]
    have hl : line 0 r = ![0,r,0] := by simp [line]
    rw [hl, field_on_plane]
    simpa [direction] using line_has_derivative 0 r i
  · exact open_curve_tangent r i

theorem curve_scale_positive (b : Bool) (r : ℝ) : 0 < tangentScale b r := by
  cases b
  · norm_num [tangentScale]
  · exact lt_of_lt_of_le (by norm_num) (gain_bounds r).1

def Closed (b : Bool) : Prop :=
  ∃ r : ℝ, 0 < r ∧ ∃ n : Fin 3 → ℤ, ∀ i, curve b r i = (n i : ℝ)

theorem closed_returns : Closed false := by
  refine ⟨1, by norm_num, ![0,1,0], ?_⟩
  intro i
  fin_cases i <;> norm_num [curve, line]

theorem open_never_returns : ¬ Closed true := by
  rintro ⟨r, hr, n, hn⟩
  have hx := hn 0
  have hy := hn 1
  change openCurve r 0 = (n 0 : ℝ) at hx
  change openCurve r 1 = (n 1 : ℝ) at hy
  have hs := open_curve_sum r
  have hd := open_curve_difference r
  have hsum : r = ((n 0 + n 1 : ℤ) : ℝ) := by push_cast; linarith
  have hdiff : lift r = ((n 1 - n 0 : ℤ) : ℝ) := by push_cast; linarith
  rw [hsum, lift_at_integer] at hdiff
  have hnzero : ((n 0 + n 1 : ℤ) : ℝ) ≠ 0 := by linarith
  have heq : mu = ((n 1 - n 0 : ℤ) : ℝ) / ((n 0 + n 1 : ℤ) : ℝ) :=
    (eq_div_iff hnzero).2 hdiff
  exact irrational_sqrt_two.ne_rational (n 1 - n 0) (n 0 + n 1) heq

theorem global_closest_bound (b : Bool) (r : ℝ) (n : Fin 3 → ℤ) :
    (1 / 4 : ℝ) ^ 2 ≤ imageDistanceSq (curve b r) n := by
  have hz := vertical_image_bound (n 2)
  cases b
  · exact all_images_all_line_points 0 r n
  · change (1 / 4 : ℝ) ^ 2 ≤
      ((r - lift r) / 2 - 0 - (n 0 : ℝ)) ^ 2 +
      ((r + lift r) / 2 - 0 - (n 1 : ℝ)) ^ 2 + (0 - 1 / 4 - (n 2 : ℝ)) ^ 2
    nlinarith [sq_nonneg ((r-lift r)/2 - (n 0 : ℝ)), sq_nonneg ((r+lift r)/2 - (n 1 : ℝ))]

#print axioms lift_derivative
#print axioms gain_bounds
#print axioms lift_at_integer
#print axioms lift_linear_error
#print axioms curve_tangent
#print axioms curve_scale_positive
#print axioms closed_returns
#print axioms open_never_returns
#print axioms global_closest_bound

end
end ClosestPointExample.Winding
