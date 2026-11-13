import FrozenIntPolynomial

namespace FrozenIntModel
open FrozenIntPolynomial

structure Model where
  polynomial : Poly
  error : ℤ
  error_nonneg : 0 ≤ error

def Models (D : ℤ) (m : Model) (f : ℝ → ℝ) : Prop :=
  ∀ x : ℝ, |x| ≤ 1 → |f x - eval m.polynomial x / D| ≤ (m.error : ℝ) / D

def Model.exact (p : Poly) : Model := ⟨p, 0, le_refl 0⟩

theorem exact_models (D : ℤ) (p : Poly) : Models D (Model.exact p) (fun x => eval p x / D) := by
  intro x hx
  simp [Model.exact]

def Model.add (m n : Model) : Model :=
  ⟨FrozenIntPolynomial.add m.polynomial n.polynomial, m.error + n.error, add_nonneg m.error_nonneg n.error_nonneg⟩

theorem add_models {D : ℤ} {m n : Model} {f g : ℝ → ℝ}
    (hf : Models D m f) (hg : Models D n g) : Models D (m.add n) (fun x => f x + g x) := by
  intro x hx
  simp only [Model.add, eval_add, Int.cast_add, add_div]
  calc
    _ = |(f x - eval m.polynomial x / D) + (g x - eval n.polynomial x / D)| := by congr 1; ring
    _ ≤ |f x - eval m.polynomial x / D| + |g x - eval n.polynomial x / D| := abs_add_le _ _
    _ ≤ _ := add_le_add (hf x hx) (hg x hx)

def Model.neg (m : Model) : Model := ⟨scale (-1) m.polynomial, m.error, m.error_nonneg⟩

theorem neg_models {D : ℤ} {m : Model} {f : ℝ → ℝ} (hf : Models D m f) :
    Models D m.neg (fun x => -f x) := by
  intro x hx
  change |-f x - eval (scale (-1) m.polynomial) x / D| ≤ (m.error : ℝ) / D
  rw [eval_scale]
  convert hf x hx using 1
  rw [← abs_neg]
  congr 1
  push_cast
  ring

def Model.sub (m n : Model) : Model := m.add n.neg

theorem sub_models {D : ℤ} {m n : Model} {f g : ℝ → ℝ}
    (hf : Models D m f) (hg : Models D n g) : Models D (m.sub n) (fun x => f x - g x) := by
  simpa only [Model.sub, sub_eq_add_neg] using add_models hf (neg_models hg)

theorem value_bound {D : ℤ} (hD : 0 < D) {m : Model} {f : ℝ → ℝ}
    (hf : Models D m f) {x : ℝ} (hx : |x| ≤ 1) :
    |f x| ≤ ((mass m.polynomial + m.error : ℤ) : ℝ) / D := by
  have hd : (0 : ℝ) < D := by exact_mod_cast hD
  calc
    _ = |eval m.polynomial x / D + (f x - eval m.polynomial x / D)| := by congr 1; ring
    _ ≤ |eval m.polynomial x / D| + |f x - eval m.polynomial x / D| := abs_add_le _ _
    _ ≤ (mass m.polynomial : ℝ) / D + (m.error : ℝ) / D := by
      rw [abs_div, abs_of_pos hd]
      exact add_le_add (div_le_div_of_nonneg_right (abs_eval_le_mass _ _ hx) hd.le) (hf x hx)
    _ = _ := by push_cast; ring

def productError (m n : Model) : ℤ :=
  mass m.polynomial * n.error + mass n.polynomial * m.error + m.error * n.error

theorem productError_nonneg (m n : Model) : 0 ≤ productError m n := by
  exact add_nonneg (add_nonneg (mul_nonneg (mass_nonneg _) n.error_nonneg)
    (mul_nonneg (mass_nonneg _) m.error_nonneg)) (mul_nonneg m.error_nonneg n.error_nonneg)

theorem product_error {D : ℤ} (hD : 0 < D) {m n : Model} {f g : ℝ → ℝ}
    (hf : Models D m f) (hg : Models D n g) {x : ℝ} (hx : |x| ≤ 1) :
    |f x * g x - eval (mul m.polynomial n.polynomial) x / (D : ℝ)^2| ≤
      (productError m n : ℝ) / (D : ℝ)^2 := by
  have hd : (0 : ℝ) < D := by exact_mod_cast hD
  have hm : |eval m.polynomial x / D| ≤ (mass m.polynomial : ℝ) / D := by
    rw [abs_div, abs_of_pos hd]
    exact div_le_div_of_nonneg_right (abs_eval_le_mass _ _ hx) hd.le
  have hn : |eval n.polynomial x / D| ≤ (mass n.polynomial : ℝ) / D := by
    rw [abs_div, abs_of_pos hd]
    exact div_le_div_of_nonneg_right (abs_eval_le_mass _ _ hx) hd.le
  have hfe := hf x hx
  have hge := hg x hx
  have hmp : (0 : ℝ) ≤ (mass m.polynomial : ℝ) / D := div_nonneg (by exact_mod_cast mass_nonneg _) hd.le
  have hnp : (0 : ℝ) ≤ (mass n.polynomial : ℝ) / D := div_nonneg (by exact_mod_cast mass_nonneg _) hd.le
  have hme : (0 : ℝ) ≤ (m.error : ℝ) / D := div_nonneg (by exact_mod_cast m.error_nonneg) hd.le
  rw [eval_mul]
  calc
    _ = |eval m.polynomial x / D * (g x - eval n.polynomial x / D) +
        eval n.polynomial x / D * (f x - eval m.polynomial x / D) +
        (f x - eval m.polynomial x / D) * (g x - eval n.polynomial x / D)| := by congr 1; ring
    _ ≤ |eval m.polynomial x / D * (g x - eval n.polynomial x / D)| +
        |eval n.polynomial x / D * (f x - eval m.polynomial x / D)| +
        |(f x - eval m.polynomial x / D) * (g x - eval n.polynomial x / D)| := abs_add_three _ _ _
    _ ≤ (mass m.polynomial : ℝ) / D * ((n.error : ℝ) / D) +
        (mass n.polynomial : ℝ) / D * ((m.error : ℝ) / D) +
        (m.error : ℝ) / D * ((n.error : ℝ) / D) := by simp only [abs_mul]; gcongr
    _ = _ := by simp only [productError, Int.cast_add, Int.cast_mul]; ring

def roundedProductError (D : ℤ) (m n : Model) (q : Poly) : ℤ :=
  productError m n + mass (sub (mul m.polynomial n.polynomial) (scale D q))

theorem roundedProductError_nonneg (D : ℤ) (m n : Model) (q : Poly) :
    0 ≤ roundedProductError D m n q := add_nonneg (productError_nonneg _ _) (mass_nonneg _)

def Model.mulCandidate (D : ℤ) (hD : 0 < D) (m n : Model) (q : Poly) : Model :=
  ⟨q, roundedProductError D m n q / D + 1,
    add_nonneg (Int.ediv_nonneg (roundedProductError_nonneg _ _ _ _) hD.le) (by decide)⟩

theorem round_up (s D : ℤ) (hD : 0 < D) :
    (s : ℝ) / (D : ℝ)^2 ≤ ((s / D + 1 : ℤ) : ℝ) / D := by
  have hd : (0 : ℝ) < D := by exact_mod_cast hD
  have h : (s : ℝ) ≤ ((s / D + 1 : ℤ) : ℝ) * (D : ℝ) := by
    exact_mod_cast (Int.lt_ediv_add_one_mul_self s hD).le
  calc
    _ ≤ (((s / D + 1 : ℤ) : ℝ) * D) / (D : ℝ)^2 := div_le_div_of_nonneg_right h (sq_nonneg _)
    _ = _ := by field_simp

theorem mulCandidate_models {D : ℤ} (hD : 0 < D) {m n : Model} {f g : ℝ → ℝ}
    (hf : Models D m f) (hg : Models D n g) (q : Poly) :
    Models D (Model.mulCandidate D hD m n q) (fun x => f x * g x) := by
  intro x hx
  have hd : (0 : ℝ) < D := by exact_mod_cast hD
  have he : |eval (mul m.polynomial n.polynomial) x / (D : ℝ)^2 - eval q x / D| ≤
      (mass (sub (mul m.polynomial n.polynomial) (scale D q)) : ℝ) / (D : ℝ)^2 := by
    have heq : eval (mul m.polynomial n.polynomial) x / (D : ℝ)^2 - eval q x / D =
        eval (sub (mul m.polynomial n.polynomial) (scale D q)) x / (D : ℝ)^2 := by
      rw [eval_sub, eval_scale]
      field_simp
    rw [heq, abs_div, abs_of_nonneg (sq_nonneg (D : ℝ))]
    exact div_le_div_of_nonneg_right (abs_eval_le_mass _ _ hx) (sq_nonneg _)
  change _ ≤ ((roundedProductError D m n q / D + 1 : ℤ) : ℝ) / D
  apply le_trans _ (round_up (roundedProductError D m n q) D hD)
  calc
    _ ≤ |f x * g x - eval (mul m.polynomial n.polynomial) x / (D : ℝ)^2| +
        |eval (mul m.polynomial n.polynomial) x / (D : ℝ)^2 - eval q x / D| := abs_sub_le _ _ _
    _ ≤ (productError m n : ℝ) / (D : ℝ)^2 +
        (mass (sub (mul m.polynomial n.polynomial) (scale D q)) : ℝ) / (D : ℝ)^2 :=
      add_le_add (product_error hD hf hg hx) he
    _ = _ := by simp only [roundedProductError, Int.cast_add]; ring

def roundedProduct (D : ℤ) (degree : ℕ) (p q : Poly) : Poly :=
  ((mul p q).take (degree + 1)).map (fun a => a / D)

def Model.mul (D : ℤ) (hD : 0 < D) (degree : ℕ) (m n : Model) : Model :=
  Model.mulCandidate D hD m n (roundedProduct D degree m.polynomial n.polynomial)

theorem mul_models {D : ℤ} (hD : 0 < D) (degree : ℕ) {m n : Model} {f g : ℝ → ℝ}
    (hf : Models D m f) (hg : Models D n g) :
    Models D (Model.mul D hD degree m n) (fun x => f x * g x) :=
  mulCandidate_models hD hf hg _

end FrozenIntModel
