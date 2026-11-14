import FrozenIntModel

namespace FrozenIntEnclosure
open FrozenIntPolynomial FrozenIntModel

theorem enclose {D : ℤ} (hD : 0 < D) {m : Model} {f : ℝ → ℝ}
    (hm : Models D m f) (p : Poly) (e : ℤ) (he : 0 ≤ e)
    (hp : m.polynomial = p) (herror : m.error ≤ e) :
    Models D ⟨p, e, he⟩ f := by
  intro x hx
  have hd : (0 : ℝ) ≤ D := by exact_mod_cast hD.le
  have h := hm x hx
  rw [hp] at h
  exact le_trans h (div_le_div_of_nonneg_right (by exact_mod_cast herror) hd)

theorem center_bound {D : ℤ} (hD : 0 < D) {m : Model} {f : ℝ → ℝ}
    (hm : Models D m f) {x : ℝ} (hx : |x| ≤ 1) :
    |f x - (m.polynomial.headD 0 : ℝ) / D| ≤
      ((mass m.polynomial.tail + m.error : ℤ) : ℝ) / D := by
  have hd : (0 : ℝ) < D := by exact_mod_cast hD
  have hp : |eval m.polynomial x - (m.polynomial.headD 0 : ℝ)| ≤
      (mass m.polynomial.tail : ℝ) := by
    cases he : m.polynomial with
    | nil => simp [eval, mass]
    | cons a p =>
      simp only [eval, List.headD_cons, List.tail_cons, add_sub_cancel_left, abs_mul]
      calc
        _ ≤ 1 * (mass p : ℝ) := by gcongr; exact abs_eval_le_mass _ _ hx
        _ = _ := one_mul _
  calc
    _ ≤ |f x - eval m.polynomial x / D| +
        |eval m.polynomial x / D - (m.polynomial.headD 0 : ℝ) / D| := abs_sub_le _ _ _
    _ = |f x - eval m.polynomial x / D| +
        |eval m.polynomial x - (m.polynomial.headD 0 : ℝ)| / D := by
      rw [← sub_div, abs_div, abs_of_pos hd]
    _ ≤ (m.error : ℝ) / D + (mass m.polynomial.tail : ℝ) / D :=
      add_le_add (hm x hx) (div_le_div_of_nonneg_right hp hd.le)
    _ = _ := by push_cast; ring

theorem lower_bound {D : ℤ} (hD : 0 < D) {m : Model} {f : ℝ → ℝ}
    (hm : Models D m f) {x : ℝ} (hx : |x| ≤ 1) :
    ((m.polynomial.headD 0 - mass m.polynomial.tail - m.error : ℤ) : ℝ) / D ≤ f x := by
  have h := (abs_le.mp (center_bound hD hm hx)).1
  simp only [Int.cast_add, Int.cast_sub, add_div, sub_div] at *
  linarith

theorem upper_bound {D : ℤ} (hD : 0 < D) {m : Model} {f : ℝ → ℝ}
    (hm : Models D m f) {x : ℝ} (hx : |x| ≤ 1) :
    f x ≤ ((m.polynomial.headD 0 + mass m.polynomial.tail + m.error : ℤ) : ℝ) / D := by
  have h := (abs_le.mp (center_bound hD hm hx)).2
  simp only [Int.cast_add, add_div] at *
  linarith

end FrozenIntEnclosure
