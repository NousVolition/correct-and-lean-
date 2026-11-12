import ViscousTimeReversalDefinitions
import Mathlib.Tactic.Ring

namespace ViscousTimeReversal

theorem reverseTime_twice (T t : ℝ) (f : ℝ → ℝ) :
    reverseTime T (reverseTime T f) t = f t := by
  simp [reverseTime]

theorem timeReverse_derivative (f : ℝ → ℝ) (T t d : ℝ)
    (h : HasDerivAt f d (T - t)) :
    HasDerivAt (reverseTime T f) (-d) t := by
  unfold reverseTime
  simpa [Function.comp_def] using h.comp t (HasDerivAt.const_sub T (hasDerivAt_id t))

theorem viscosity_reversal (f lap : ℝ → ℝ) (T t ν : ℝ)
    (h : HasDerivAt f (ν * lap (T - t)) (T - t)) :
    HasDerivAt (reverseTime T f) ((-ν) * lap (T - t)) t := by
  simpa only [neg_mul] using timeReverse_derivative f T t (ν * lap (T - t)) h

theorem whole_rhs_reversal (f transport lap coupling : ℝ → ℝ) (T t ν : ℝ)
    (h : HasDerivAt f (transport (T - t) + ν * lap (T - t) + coupling (T - t))
      (T - t)) :
    HasDerivAt (reverseTime T f)
      (-transport (T - t) - ν * lap (T - t) - coupling (T - t)) t := by
  simpa only [neg_add, sub_eq_add_neg] using
    timeReverse_derivative f T t
      (transport (T - t) + ν * lap (T - t) + coupling (T - t)) h

theorem forwardFactor_derivative (ν q t : ℝ) :
    HasDerivAt (forwardFactor ν q) (-(ν * q) * forwardFactor ν q t) t := by
  unfold forwardFactor
  simpa [mul_comm] using
    ((hasDerivAt_id t).const_mul (-(ν * q))).exp

theorem backwardFactor_derivative (ν q t : ℝ) :
    HasDerivAt (backwardFactor ν q) ((ν * q) * backwardFactor ν q t) t := by
  unfold backwardFactor
  simpa [mul_comm] using
    ((hasDerivAt_id t).const_mul (ν * q)).exp

theorem forward_damping (ν q t : ℝ) (hν : 0 ≤ ν) (hq : 0 ≤ q) (ht : 0 ≤ t) :
    forwardFactor ν q t ≤ 1 := by
  calc
    forwardFactor ν q t ≤ Real.exp 0 := Real.exp_le_exp.mpr
      (mul_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr (mul_nonneg hν hq)) ht)
    _ = 1 := Real.exp_zero

theorem backward_amplification (ν q t : ℝ) (hν : 0 ≤ ν) (hq : 0 ≤ q) (ht : 0 ≤ t) :
    1 ≤ backwardFactor ν q t := by
  calc
    (1 : ℝ) = Real.exp 0 := Real.exp_zero.symm
    _ ≤ backwardFactor ν q t := Real.exp_le_exp.mpr (mul_nonneg (mul_nonneg hν hq) ht)

theorem forward_strict_damping (ν q t : ℝ) (hν : 0 < ν) (hq : 0 < q) (ht : 0 < t) :
    forwardFactor ν q t < 1 := by
  calc
    forwardFactor ν q t < Real.exp 0 := Real.exp_lt_exp.mpr
      (mul_neg_of_neg_of_pos (neg_neg_of_pos (mul_pos hν hq)) ht)
    _ = 1 := Real.exp_zero

theorem backward_strict_amplification (ν q t : ℝ) (hν : 0 < ν) (hq : 0 < q) (ht : 0 < t) :
    1 < backwardFactor ν q t := by
  calc
    (1 : ℝ) = Real.exp 0 := Real.exp_zero.symm
    _ < backwardFactor ν q t := Real.exp_lt_exp.mpr (mul_pos (mul_pos hν hq) ht)

theorem higher_frequency_amplification (ν q₁ q₂ t : ℝ) (hν : 0 ≤ ν) (ht : 0 ≤ t) (hq : q₁ ≤ q₂) :
    backwardFactor ν q₁ t ≤ backwardFactor ν q₂ t := by
  exact Real.exp_le_exp.mpr
    (mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_left hq hν) ht)

theorem factor_cancellation (ν q t : ℝ) :
    forwardFactor ν q t * backwardFactor ν q t = 1 := by
  unfold forwardFactor backwardFactor
  rw [← Real.exp_add]
  have h : -(ν * q) * t + (ν * q) * t = 0 := by ring
  rw [h, Real.exp_zero]

theorem negative_step_reverses_rate (h ν q a : ℝ) :
    eulerIncrement (-h) (viscousRate ν q a) = h * ((ν * q) * a) := by
  unfold eulerIncrement viscousRate
  ring

theorem double_sign_flip_restores_forward (h ν q a : ℝ) :
    eulerIncrement (-h) (viscousRate (-ν) q a) = eulerIncrement h (viscousRate ν q a) := by
  unfold eulerIncrement viscousRate
  ring

end ViscousTimeReversal
