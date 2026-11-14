import FrozenIntPolynomial
import FrozenTrig

namespace FrozenIntTrig
open FrozenIntPolynomial Set Complex

noncomputable def pair (c s : Poly) (x : ℝ) : ℂ :=
  (eval c x : ℂ) + (eval s x : ℂ) * I

noncomputable def scaledPair (c s : Poly) (D : ℤ) (x : ℝ) : ℂ :=
  pair c s x / (D : ℂ)

def residualCos (p c s : Poly) (D : ℤ) : Poly :=
  add (scale D (derivative c)) (mul (derivative p) s)

def residualSin (p c s : Poly) (D : ℤ) : Poly :=
  sub (scale D (derivative s)) (mul (derivative p) c)

def residualMass (p c s : Poly) (D : ℤ) : ℤ :=
  mass (residualCos p c s D) + mass (residualSin p c s D)

theorem residualMass_nonneg (p c s : Poly) (D : ℤ) : 0 ≤ residualMass p c s D :=
  add_nonneg (mass_nonneg _) (mass_nonneg _)

theorem pair_derivative (c s : Poly) (x : ℝ) :
    HasDerivAt (pair c s) (pair (derivative c) (derivative s) x) x := by
  exact (hasDerivAt_eval c x).ofReal_comp.add ((hasDerivAt_eval s x).ofReal_comp.mul_const I)

theorem pair_norm (c s : Poly) (x : ℝ) (hx : |x| ≤ 1) :
    ‖pair c s x‖ ≤ ((mass c + mass s : ℤ) : ℝ) := by
  calc
    _ ≤ ‖(eval c x : ℂ)‖ + ‖(eval s x : ℂ) * I‖ := norm_add_le _ _
    _ = |eval c x| + |eval s x| := by simp
    _ ≤ (mass c : ℝ) + (mass s : ℝ) := add_le_add (abs_eval_le_mass _ _ hx) (abs_eval_le_mass _ _ hx)
    _ = _ := by push_cast; rfl

theorem scaledPair_re (c s : Poly) (D : ℤ) (x : ℝ) :
    (scaledPair c s D x).re = eval c x / D := by
  by_cases hd : D = 0
  · simp [scaledPair, hd]
  · have hdc : (D : ℝ) ≠ 0 := by exact_mod_cast hd
    simp [scaledPair, pair, Complex.div_re, Complex.normSq_intCast]
    field_simp

theorem scaledPair_im (c s : Poly) (D : ℤ) (x : ℝ) :
    (scaledPair c s D x).im = eval s x / D := by
  by_cases hd : D = 0
  · simp [scaledPair, hd]
  · have hdc : (D : ℝ) ≠ 0 := by exact_mod_cast hd
    simp [scaledPair, pair, Complex.div_im, Complex.normSq_intCast]
    field_simp

theorem residual_identity (p c s : Poly) (D : ℤ) (hD : 0 < D) (x : ℝ) :
    scaledPair (derivative c) (derivative s) D x -
      ((eval (derivative p) x / (D : ℝ) : ℝ) : ℂ) * I * scaledPair c s D x =
      pair (residualCos p c s D) (residualSin p c s D) x / (D : ℂ)^2 := by
  have hd : (D : ℂ) ≠ 0 := by exact_mod_cast ne_of_gt hD
  simp only [scaledPair, pair, residualCos, residualSin, eval_add, eval_scale, eval_mul, eval_sub]
  push_cast
  field_simp
  ring_nf
  simp [Complex.I_sq]

theorem residual_bound (p c s : Poly) (D : ℤ) (hD : 0 < D) (x : ℝ) (hx : |x| ≤ 1) :
    ‖scaledPair (derivative c) (derivative s) D x -
      ((eval (derivative p) x / (D : ℝ) : ℝ) : ℂ) * I * scaledPair c s D x‖ ≤
      (residualMass p c s D : ℝ) / (D : ℝ)^2 := by
  rw [residual_identity p c s D hD x, norm_div, norm_pow, Complex.norm_intCast,
    abs_of_pos (by exact_mod_cast hD : (0 : ℝ) < D)]
  exact div_le_div_of_nonneg_right (pair_norm _ _ x hx) (sq_nonneg _)

theorem segment_bound (p c s : Poly) (D : ℤ) (hD : 0 < D) {a b δ : ℝ}
    (hdomain : ∀ t ∈ Icc a b, |t| ≤ 1)
    (hstart : ‖scaledPair c s D a - Complex.exp (((eval p a / D : ℝ) : ℂ) * I)‖ ≤ δ) :
    ∀ t ∈ Icc a b,
      ‖scaledPair c s D t - Complex.exp (((eval p t / D : ℝ) : ℂ) * I)‖ ≤
        δ + ((residualMass p c s D : ℝ) / (D : ℝ)^2) * (t-a) := by
  apply FrozenTrig.phase_residual_bound
    (fun t _ => (hasDerivAt_eval p t).div_const (D : ℝ))
    (fun t _ => (pair_derivative c s t).div_const (D : ℂ)) hstart
  intro t ht
  exact residual_bound p c s D hD t (hdomain t (Ico_subset_Icc_self ht))

theorem point_bound (a : ℤ) (c s : Poly) (D : ℤ) (hD : 0 < D)
    (hc : evalInt c 0 = D) (hs : evalInt s 0 = 0) :
    ‖scaledPair c s D 1 - Complex.exp ((((a : ℝ) / D : ℝ) : ℂ) * I)‖ ≤
      (residualMass [0,a] c s D : ℝ) / (D : ℝ)^2 := by
  have hd : (D : ℂ) ≠ 0 := by exact_mod_cast ne_of_gt hD
  have hc' : eval c 0 = (D : ℝ) := by simpa only [Int.cast_zero, hc] using eval_cast c 0
  have hs' : eval s 0 = 0 := by simpa only [Int.cast_zero, hs] using eval_cast s 0
  have h := segment_bound [0,a] c s D hD (a := 0) (b := 1) (δ := 0)
    (fun t ht => by rw [abs_of_nonneg ht.1]; exact ht.2)
    (by simp [scaledPair, pair, hc', hs', eval, hd]) 1 (by simp)
  simpa [eval] using h

def initialDifference (c s cp sp : Poly) : ℤ :=
  |evalInt c (-1) - evalInt cp 1| + |evalInt s (-1) - evalInt sp 1|

def totalNumerator (p c s cp sp : Poly) (D : ℤ) : ℤ :=
  residualMass [0,evalInt p (-1)] cp sp D + D * initialDifference c s cp sp +
    2 * residualMass p c s D

theorem pair_difference_bound (c s cp sp : Poly) (D : ℤ) (hD : 0 < D) :
    ‖scaledPair c s D (-1) - scaledPair cp sp D 1‖ ≤
      (initialDifference c s cp sp : ℝ) / D := by
  have hd : (0 : ℝ) < D := by exact_mod_cast hD
  rw [scaledPair, scaledPair, ← sub_div, norm_div, Complex.norm_intCast, abs_of_pos hd]
  apply div_le_div_of_nonneg_right _ hd.le
  have heq : pair c s (-1) - pair cp sp 1 =
      ((eval c (-1) - eval cp 1 : ℝ) : ℂ) + ((eval s (-1) - eval sp 1 : ℝ) : ℂ) * I := by
    simp only [pair]; push_cast; ring
  rw [heq]
  calc
    _ ≤ ‖((eval c (-1) - eval cp 1 : ℝ) : ℂ)‖ +
      ‖((eval s (-1) - eval sp 1 : ℝ) : ℂ) * I‖ := norm_add_le _ _
    _ = _ := by
      simp only [norm_mul, Complex.norm_I, mul_one, Complex.norm_real, Real.norm_eq_abs,
        initialDifference, Int.cast_add, Int.cast_abs, Int.cast_sub]
      rw [show eval c (-1) = (evalInt c (-1) : ℝ) by simpa using eval_cast c (-1),
        show eval s (-1) = (evalInt s (-1) : ℝ) by simpa using eval_cast s (-1),
        show eval cp 1 = (evalInt cp 1 : ℝ) by simpa using eval_cast cp 1,
        show eval sp 1 = (evalInt sp 1 : ℝ) by simpa using eval_cast sp 1]

theorem whole_interval_bound (p c s cp sp : Poly) (D : ℤ) (hD : 0 < D)
    (hcp : evalInt cp 0 = D) (hsp : evalInt sp 0 = 0) (x : ℝ) (hx : |x| ≤ 1) :
    ‖scaledPair c s D x - Complex.exp (((eval p x / D : ℝ) : ℂ) * I)‖ ≤
      (totalNumerator p c s cp sp D : ℝ) / (D : ℝ)^2 := by
  have hd : (0 : ℝ) < D := by exact_mod_cast hD
  have ha : eval p (-1) = (evalInt p (-1) : ℝ) := by simpa using eval_cast p (-1)
  have hpoint := point_bound (evalInt p (-1)) cp sp D hD hcp hsp
  have hstart : ‖scaledPair c s D (-1) - Complex.exp (((eval p (-1) / D : ℝ) : ℂ) * I)‖ ≤
      (initialDifference c s cp sp : ℝ) / D +
        (residualMass [0,evalInt p (-1)] cp sp D : ℝ) / (D : ℝ)^2 := by
    rw [ha]
    exact le_trans (norm_sub_le_norm_sub_add_norm_sub _ (scaledPair cp sp D 1) _)
      (add_le_add (pair_difference_bound c s cp sp D hD) hpoint)
  have h := segment_bound p c s D hD (a := -1) (b := 1)
    (fun _ ht => abs_le.mpr ht) hstart x (abs_le.mp hx)
  apply le_trans h
  have hr : (0 : ℝ) ≤ (residualMass p c s D : ℝ) / (D : ℝ)^2 := by
    exact div_nonneg (by exact_mod_cast residualMass_nonneg p c s D) (sq_nonneg _)
  have hu := (abs_le.mp hx).2
  have hmul := mul_le_mul_of_nonneg_left (show x - -1 ≤ 2 by linarith) hr
  simp only [totalNumerator, Int.cast_add, Int.cast_mul, Int.cast_ofNat]
  calc
    _ ≤ (initialDifference c s cp sp : ℝ) / D +
        (residualMass [0,evalInt p (-1)] cp sp D : ℝ) / (D : ℝ)^2 +
        (residualMass p c s D : ℝ) / (D : ℝ)^2 * 2 := add_le_add_right hmul _
    _ = _ := by field_simp; ring

theorem cosine_bound (p c s cp sp : Poly) (D : ℤ) (hD : 0 < D)
    (hcp : evalInt cp 0 = D) (hsp : evalInt sp 0 = 0) (x : ℝ) (hx : |x| ≤ 1) :
    |Real.cos (eval p x / D) - eval c x / D| ≤
      (totalNumerator p c s cp sp D : ℝ) / (D : ℝ)^2 := by
  have h := Complex.abs_re_le_norm (scaledPair c s D x - Complex.exp (((eval p x / D : ℝ) : ℂ) * I))
  simp only [sub_re, scaledPair_re, Complex.exp_ofReal_mul_I_re] at h
  rw [abs_sub_comm] at h
  exact le_trans h (whole_interval_bound p c s cp sp D hD hcp hsp x hx)

theorem sine_bound (p c s cp sp : Poly) (D : ℤ) (hD : 0 < D)
    (hcp : evalInt cp 0 = D) (hsp : evalInt sp 0 = 0) (x : ℝ) (hx : |x| ≤ 1) :
    |Real.sin (eval p x / D) - eval s x / D| ≤
      (totalNumerator p c s cp sp D : ℝ) / (D : ℝ)^2 := by
  have h := Complex.abs_im_le_norm (scaledPair c s D x - Complex.exp (((eval p x / D : ℝ) : ℂ) * I))
  simp only [sub_im, scaledPair_im, Complex.exp_ofReal_mul_I_im] at h
  rw [abs_sub_comm] at h
  exact le_trans h (whole_interval_bound p c s cp sp D hD hcp hsp x hx)

end FrozenIntTrig
