import FrozenPolynomial
import Mathlib.Analysis.Calculus.MeanValue
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Analysis.SpecialFunctions.Complex.Arg
import Mathlib.Analysis.Complex.RealDeriv

/- A residual certificate for trigonometric polynomial approximations.
   It uses exact norm preservation under complex rotation, not an external
   Taylor remainder estimate or a floating-point trigonometric evaluation. -/
namespace FrozenTrig

open Set Complex FrozenPolynomial

theorem rotation_error (z : ℂ) (θ : ℝ) :
    ‖z * Complex.exp ((-θ : ℝ) * Complex.I) - 1‖ =
      ‖z - Complex.exp ((θ : ℂ) * Complex.I)‖ := by
  have he : Complex.exp ((θ : ℂ) * Complex.I) *
      Complex.exp ((-θ : ℝ) * Complex.I) = 1 := by
    rw [← Complex.exp_add]
    simp only [ofReal_neg, neg_mul, add_neg_cancel, Complex.exp_zero]
  calc
    _ = ‖(z - Complex.exp ((θ : ℂ) * Complex.I)) *
        Complex.exp ((-θ : ℝ) * Complex.I)‖ := by rw [sub_mul, he]
    _ = _ := by rw [norm_mul, Complex.norm_exp_ofReal_mul_I, mul_one]

theorem phase_residual_bound
    {a b δ R : ℝ} {θ θ' : ℝ → ℝ} {z z' : ℝ → ℂ}
    (hθ : ∀ t ∈ Icc a b, HasDerivAt θ (θ' t) t)
    (hz : ∀ t ∈ Icc a b, HasDerivAt z (z' t) t)
    (hstart : ‖z a - Complex.exp ((θ a : ℂ) * Complex.I)‖ ≤ δ)
    (hres : ∀ t ∈ Ico a b, ‖z' t - (θ' t : ℂ) * Complex.I * z t‖ ≤ R) :
    ∀ t ∈ Icc a b, ‖z t - Complex.exp ((θ t : ℂ) * Complex.I)‖ ≤ δ + R * (t-a) := by
  let v : ℝ → ℂ := fun t => z t * Complex.exp ((-θ t : ℝ) * Complex.I)
  let v' : ℝ → ℂ := fun t =>
    (z' t - (θ' t : ℂ) * Complex.I * z t) * Complex.exp ((-θ t : ℝ) * Complex.I)
  have hv : ∀ t ∈ Icc a b, HasDerivWithinAt v (v' t) (Icc a b) t := by
    intro t ht
    have hrot := (((hθ t ht).neg.ofReal_comp).mul_const Complex.I).cexp
    have h := (hz t ht).mul hrot
    convert! h.hasDerivWithinAt using 1
    simp only [v', Pi.neg_apply, Complex.ofReal_neg]
    ring
  have hvb : ∀ t ∈ Ico a b, ‖v' t‖ ≤ R := by
    intro t ht
    dsimp [v']
    rw [norm_mul, Complex.norm_exp_ofReal_mul_I, mul_one]
    exact hres t ht
  intro t ht
  have hdiff := norm_image_sub_le_of_norm_deriv_le_segment' hv hvb t ht
  have hstart' : ‖v a - 1‖ ≤ δ := by
    dsimp [v]
    rw [rotation_error]
    exact hstart
  rw [← rotation_error]
  change ‖v t - 1‖ ≤ δ + R * (t-a)
  calc
    _ ≤ ‖v t - v a‖ + ‖v a - 1‖ := norm_sub_le_norm_sub_add_norm_sub _ _ _
    _ ≤ R * (t-a) + δ := add_le_add hdiff hstart'
    _ = _ := add_comm _ _

def derivative : Poly → Poly
  | [] => []
  | _ :: p => add p (0 :: derivative p)

theorem hasDerivAt_eval (p : Poly) (x : ℝ) :
    HasDerivAt (eval p) (eval (derivative p) x) x := by
  induction p with
  | nil => simpa only [eval, derivative] using hasDerivAt_const x (0 : ℝ)
  | cons a p ih =>
    have h := ((hasDerivAt_id x).mul ih).const_add (a : ℝ)
    convert! h using 1
    simp only [derivative, eval_add, eval, Rat.cast_zero, zero_add, id_eq, one_mul]

noncomputable def polynomialPair (c s : Poly) (x : ℝ) : ℂ :=
  (eval c x : ℂ) + (eval s x : ℂ) * Complex.I

def cosineResidual (p c s : Poly) : Poly :=
  add (derivative c) (mul (derivative p) s)

def sineResidual (p c s : Poly) : Poly :=
  sub (derivative s) (mul (derivative p) c)

def residualMass (p c s : Poly) : ℚ := mass (cosineResidual p c s) + mass (sineResidual p c s)

theorem residualMass_nonneg (p c s : Poly) : 0 ≤ residualMass p c s :=
  add_nonneg (mass_nonneg _) (mass_nonneg _)

theorem polynomialPair_derivative (c s : Poly) (x : ℝ) :
    HasDerivAt (polynomialPair c s) (polynomialPair (derivative c) (derivative s) x) x := by
  exact (hasDerivAt_eval c x).ofReal_comp.add ((hasDerivAt_eval s x).ofReal_comp.mul_const Complex.I)

theorem polynomial_residual_identity (p c s : Poly) (x : ℝ) :
    polynomialPair (derivative c) (derivative s) x -
        (eval (derivative p) x : ℂ) * Complex.I * polynomialPair c s x =
      polynomialPair (cosineResidual p c s) (sineResidual p c s) x := by
  simp only [polynomialPair, cosineResidual, sineResidual, eval_add, eval_mul, eval_sub]
  push_cast
  ring_nf
  simp [Complex.I_sq]

theorem polynomialPair_norm (c s : Poly) (x : ℝ) (hx : |x| ≤ 1) :
    ‖polynomialPair c s x‖ ≤ (mass c + mass s : ℚ) := by
  calc
    _ ≤ ‖(eval c x : ℂ)‖ + ‖(eval s x : ℂ) * Complex.I‖ := norm_add_le _ _
    _ = |eval c x| + |eval s x| := by simp
    _ ≤ (mass c : ℝ) + (mass s : ℝ) := add_le_add (abs_eval_le_mass _ _ hx) (abs_eval_le_mass _ _ hx)
    _ = _ := by push_cast; rfl

/-- The only trigonometric error hypothesis is the starting-point enclosure.
All subsequent error is bounded by an explicitly computable polynomial residual. -/
theorem polynomial_phase_segment_bound (p c s : Poly) {a b δ : ℝ}
    (hdomain : ∀ t ∈ Icc a b, |t| ≤ 1)
    (hstart : ‖polynomialPair c s a - Complex.exp ((eval p a : ℂ) * Complex.I)‖ ≤ δ) :
    ∀ t ∈ Icc a b, ‖polynomialPair c s t - Complex.exp ((eval p t : ℂ) * Complex.I)‖ ≤
      δ + (residualMass p c s : ℝ) * (t-a) := by
  apply phase_residual_bound (fun t _ => hasDerivAt_eval p t)
    (fun t _ => polynomialPair_derivative c s t) hstart
  intro t ht
  rw [polynomial_residual_identity]
  exact polynomialPair_norm _ _ t (hdomain t (Ico_subset_Icc_self ht))

theorem cosine_error_le_pair (p c s : Poly) (x : ℝ) :
    |Real.cos (eval p x) - eval c x| ≤
      ‖polynomialPair c s x - Complex.exp ((eval p x : ℂ) * Complex.I)‖ := by
  have h := Complex.abs_re_le_norm (polynomialPair c s x - Complex.exp ((eval p x : ℂ) * Complex.I))
  rw [abs_sub_comm]
  simpa [polynomialPair] using h

theorem sine_error_le_pair (p c s : Poly) (x : ℝ) :
    |Real.sin (eval p x) - eval s x| ≤
      ‖polynomialPair c s x - Complex.exp ((eval p x : ℂ) * Complex.I)‖ := by
  have h := Complex.abs_im_le_norm (polynomialPair c s x - Complex.exp ((eval p x : ℂ) * Complex.I))
  rw [abs_sub_comm]
  simpa [polynomialPair] using h

/-- A point certificate starts at zero, where sine and cosine are exact.
Any rational candidate coefficient lists are accepted only through their checked
residual and exact constant coefficients; no Taylor formula is trusted. -/
theorem point_certificate (q : ℚ) (c s : Poly)
    (hc : eval c 0 = 1) (hs : eval s 0 = 0) :
    |Real.cos (q : ℝ) - eval c 1| ≤ (residualMass [0,q] c s : ℝ) ∧
    |Real.sin (q : ℝ) - eval s 1| ≤ (residualMass [0,q] c s : ℝ) := by
  have h := polynomial_phase_segment_bound [0,q] c s
    (a := 0) (b := 1) (δ := 0)
    (fun t ht => by rw [abs_of_nonneg ht.1]; exact ht.2)
    (by simp [polynomialPair, hc, hs, eval]) 1 (by simp)
  simp only [zero_add, mul_one, sub_zero] at h
  constructor
  · simpa [eval] using le_trans (cosine_error_le_pair [0,q] c s 1) h
  · simpa [eval] using le_trans (sine_error_le_pair [0,q] c s 1) h

end FrozenTrig
