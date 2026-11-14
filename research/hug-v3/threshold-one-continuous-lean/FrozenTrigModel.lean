import FrozenTrig
import FrozenRational

namespace FrozenTrigModel
open FrozenPolynomial FrozenTrig FrozenRational Set Complex

def initialError (p c s cp sp : Poly) : ℚ :=
  2 * residualMass [0, evalRat p (-1)] cp sp +
    |evalRat c (-1) - evalRat cp 1| + |evalRat s (-1) - evalRat sp 1|

def totalError (p c s cp sp : Poly) : ℚ :=
  initialError p c s cp sp + 2 * residualMass p c s

theorem initialError_nonneg (p c s cp sp : Poly) : 0 ≤ initialError p c s cp sp := by
  unfold initialError
  have h := residualMass_nonneg [0, evalRat p (-1)] cp sp
  positivity

theorem totalError_nonneg (p c s cp sp : Poly) : 0 ≤ totalError p c s cp sp := by
  exact add_nonneg (initialError_nonneg _ _ _ _ _) (mul_nonneg (by norm_num) (residualMass_nonneg _ _ _))

theorem pair_error_le (a b θ : ℝ) :
    ‖((a : ℂ) + (b : ℂ) * I) - Complex.exp ((θ : ℂ) * I)‖ ≤
      |a - Real.cos θ| + |b - Real.sin θ| := by
  have heq : ((a : ℂ) + (b : ℂ) * I) - Complex.exp ((θ : ℂ) * I) =
      ((a - Real.cos θ : ℝ) : ℂ) + ((b - Real.sin θ : ℝ) : ℂ) * I := by
    rw [Complex.exp_ofReal_mul_I]
    push_cast
    ring
  rw [heq]
  calc
    _ ≤ ‖((a - Real.cos θ : ℝ) : ℂ)‖ + ‖((b - Real.sin θ : ℝ) : ℂ) * I‖ := norm_add_le _ _
    _ = _ := by rw [norm_mul, Complex.norm_real, Complex.norm_real, Complex.norm_I, mul_one, Real.norm_eq_abs, Real.norm_eq_abs]

/-- The starting enclosure is itself supplied by a checked polynomial residual
certificate anchored at sin(0)=0 and cos(0)=1. -/
theorem initial_error_bound (p c s cp sp : Poly)
    (hcp : eval cp 0 = 1) (hsp : eval sp 0 = 0) :
    ‖polynomialPair c s (-1) - Complex.exp ((eval p (-1) : ℂ) * I)‖ ≤
      (initialError p c s cp sp : ℝ) := by
  let q : ℚ := evalRat p (-1)
  have hpoint := point_certificate q cp sp hcp hsp
  have hq : eval p (-1) = (q : ℝ) := by simpa only [Rat.cast_neg, Rat.cast_one] using eval_cast p (-1)
  have hc : |eval c (-1) - Real.cos q| ≤
      |eval c (-1) - eval cp 1| + (residualMass [0,q] cp sp : ℝ) := by
    exact le_trans (abs_sub_le _ (eval cp 1) _) (add_le_add (le_refl _) (by simpa only [abs_sub_comm] using hpoint.1))
  have hs : |eval s (-1) - Real.sin q| ≤
      |eval s (-1) - eval sp 1| + (residualMass [0,q] cp sp : ℝ) := by
    exact le_trans (abs_sub_le _ (eval sp 1) _) (add_le_add (le_refl _) (by simpa only [abs_sub_comm] using hpoint.2))
  change ‖((eval c (-1) : ℝ) : ℂ) + ((eval s (-1) : ℝ) : ℂ) * I -
    Complex.exp ((eval p (-1) : ℂ) * I)‖ ≤ _
  rw [hq]
  apply le_trans (pair_error_le _ _ q)
  have hsum := add_le_add hc hs
  convert hsum using 1
  simp only [initialError, Rat.cast_add, Rat.cast_mul, Rat.cast_ofNat, Rat.cast_abs, Rat.cast_sub]
  rw [show eval c (-1) = (evalRat c (-1) : ℝ) by simpa only [Rat.cast_neg, Rat.cast_one] using eval_cast c (-1),
      show eval s (-1) = (evalRat s (-1) : ℝ) by simpa only [Rat.cast_neg, Rat.cast_one] using eval_cast s (-1),
      show eval cp 1 = (evalRat cp 1 : ℝ) by simpa only [Rat.cast_one] using eval_cast cp 1,
      show eval sp 1 = (evalRat sp 1 : ℝ) by simpa only [Rat.cast_one] using eval_cast sp 1]
  dsimp [q]
  ring

def cosineModel (p c s cp sp : Poly) : Model :=
  ⟨c, totalError p c s cp sp, totalError_nonneg _ _ _ _ _⟩

def sineModel (p c s cp sp : Poly) : Model :=
  ⟨s, totalError p c s cp sp, totalError_nonneg _ _ _ _ _⟩

theorem polynomial_pair_bound (p c s cp sp : Poly)
    (hcp : eval cp 0 = 1) (hsp : eval sp 0 = 0) (x : ℝ) (hx : |x| ≤ 1) :
    ‖polynomialPair c s x - Complex.exp ((eval p x : ℂ) * I)‖ ≤
      (totalError p c s cp sp : ℝ) := by
  have h := polynomial_phase_segment_bound p c s (a := -1) (b := 1)
    (fun _ h => abs_le.mpr h) (initial_error_bound p c s cp sp hcp hsp) x (abs_le.mp hx)
  apply le_trans h
  have hr : (0 : ℝ) ≤ (residualMass p c s : ℝ) := by exact_mod_cast residualMass_nonneg p c s
  have hx' := (abs_le.mp hx).2
  simp only [totalError, Rat.cast_add, Rat.cast_mul, Rat.cast_ofNat]
  nlinarith

theorem cosineModel_sound (p c s cp sp : Poly)
    (hcp : eval cp 0 = 1) (hsp : eval sp 0 = 0) :
    Models (cosineModel p c s cp sp) (fun x => Real.cos (eval p x)) := by
  intro x hx
  exact le_trans (cosine_error_le_pair p c s x) (polynomial_pair_bound p c s cp sp hcp hsp x hx)

theorem sineModel_sound (p c s cp sp : Poly)
    (hcp : eval cp 0 = 1) (hsp : eval sp 0 = 0) :
    Models (sineModel p c s cp sp) (fun x => Real.sin (eval p x)) := by
  intro x hx
  exact le_trans (sine_error_le_pair p c s x) (polynomial_pair_bound p c s cp sp hcp hsp x hx)

def withInputError (m input : Model) : Model :=
  ⟨m.polynomial, m.error + input.error, add_nonneg m.error_nonneg input.error_nonneg⟩

theorem cosine_input_sound {m input : Model} {f : ℝ → ℝ}
    (hf : Models input f) (hm : Models m (fun x => Real.cos (eval input.polynomial x))) :
    Models (withInputError m input) (fun x => Real.cos (f x)) := by
  intro x hx
  have h := abs_sub_le (Real.cos (f x)) (Real.cos (eval input.polynomial x)) (eval m.polynomial x)
  have hl := le_trans (Real.abs_cos_sub_cos_le _ _) (hf x hx)
  have he := add_le_add hl (hm x hx)
  change _ ≤ ((m.error + input.error : ℚ) : ℝ)
  exact le_trans h (by simpa only [Rat.cast_add, add_comm] using he)

theorem sine_input_sound {m input : Model} {f : ℝ → ℝ}
    (hf : Models input f) (hm : Models m (fun x => Real.sin (eval input.polynomial x))) :
    Models (withInputError m input) (fun x => Real.sin (f x)) := by
  intro x hx
  have h := abs_sub_le (Real.sin (f x)) (Real.sin (eval input.polynomial x)) (eval m.polynomial x)
  have hl := le_trans (Real.abs_sin_sub_sin_le _ _) (hf x hx)
  have he := add_le_add hl (hm x hx)
  change _ ≤ ((m.error + input.error : ℚ) : ℝ)
  exact le_trans h (by simpa only [Rat.cast_add, add_comm] using he)

end FrozenTrigModel
