import FrozenIntTrig
import FrozenIntModel

namespace FrozenIntTrigModel
open FrozenIntPolynomial FrozenIntTrig FrozenIntModel

theorem totalNumerator_nonneg (p c s cp sp : Poly) (D : ℤ) (hD : 0 < D) :
    0 ≤ totalNumerator p c s cp sp D := by
  unfold totalNumerator initialDifference
  exact add_nonneg
    (add_nonneg (residualMass_nonneg _ _ _ _)
      (mul_nonneg hD.le (add_nonneg (abs_nonneg _) (abs_nonneg _))))
    (mul_nonneg (by decide) (residualMass_nonneg _ _ _ _))

def errorNumerator (D : ℤ) (input : Model) (c s cp sp : Poly) : ℤ :=
  totalNumerator input.polynomial c s cp sp D / D + 1 + input.error

theorem errorNumerator_nonneg (D : ℤ) (hD : 0 < D) (input : Model) (c s cp sp : Poly) :
    0 ≤ errorNumerator D input c s cp sp :=
  add_nonneg (add_nonneg (Int.ediv_nonneg
    (totalNumerator_nonneg _ _ _ _ _ D hD) hD.le) (by decide)) input.error_nonneg

def cosineModel (D : ℤ) (hD : 0 < D) (input : Model) (c s cp sp : Poly) : Model :=
  ⟨c, errorNumerator D input c s cp sp, errorNumerator_nonneg D hD input c s cp sp⟩

def sineModel (D : ℤ) (hD : 0 < D) (input : Model) (c s cp sp : Poly) : Model :=
  ⟨s, errorNumerator D input c s cp sp, errorNumerator_nonneg D hD input c s cp sp⟩

theorem cosine_models {D : ℤ} (hD : 0 < D) {input : Model} {f : ℝ → ℝ}
    (hf : Models D input f) (c s cp sp : Poly)
    (hcp : evalInt cp 0 = D) (hsp : evalInt sp 0 = 0) :
    Models D (cosineModel D hD input c s cp sp) (fun x => Real.cos (f x)) := by
  intro x hx
  have he := cosine_bound input.polynomial c s cp sp D hD hcp hsp x hx
  have hl := le_trans (Real.abs_cos_sub_cos_le (f x) (eval input.polynomial x / D)) (hf x hx)
  have hr := round_up (totalNumerator input.polynomial c s cp sp D) D hD
  change _ ≤ (errorNumerator D input c s cp sp : ℝ) / D
  calc
    _ ≤ |Real.cos (f x) - Real.cos (eval input.polynomial x / D)| +
        |Real.cos (eval input.polynomial x / D) - eval c x / D| := abs_sub_le _ _ _
    _ ≤ (input.error : ℝ) / D +
        (totalNumerator input.polynomial c s cp sp D : ℝ) / (D : ℝ)^2 := add_le_add hl he
    _ ≤ (input.error : ℝ) / D +
        ((totalNumerator input.polynomial c s cp sp D / D + 1 : ℤ) : ℝ) / D := add_le_add_right hr _
    _ = _ := by simp only [errorNumerator, Int.cast_add]; ring

theorem sine_models {D : ℤ} (hD : 0 < D) {input : Model} {f : ℝ → ℝ}
    (hf : Models D input f) (c s cp sp : Poly)
    (hcp : evalInt cp 0 = D) (hsp : evalInt sp 0 = 0) :
    Models D (sineModel D hD input c s cp sp) (fun x => Real.sin (f x)) := by
  intro x hx
  have he := sine_bound input.polynomial c s cp sp D hD hcp hsp x hx
  have hl := le_trans (Real.abs_sin_sub_sin_le (f x) (eval input.polynomial x / D)) (hf x hx)
  have hr := round_up (totalNumerator input.polynomial c s cp sp D) D hD
  change _ ≤ (errorNumerator D input c s cp sp : ℝ) / D
  calc
    _ ≤ |Real.sin (f x) - Real.sin (eval input.polynomial x / D)| +
        |Real.sin (eval input.polynomial x / D) - eval s x / D| := abs_sub_le _ _ _
    _ ≤ (input.error : ℝ) / D +
        (totalNumerator input.polynomial c s cp sp D : ℝ) / (D : ℝ)^2 := add_le_add hl he
    _ ≤ (input.error : ℝ) / D +
        ((totalNumerator input.polynomial c s cp sp D / D + 1 : ℤ) : ℝ) / D := add_le_add_right hr _
    _ = _ := by simp only [errorNumerator, Int.cast_add]; ring

end FrozenIntTrigModel
