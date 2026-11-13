import Mathlib.Data.Rat.Cast.Order
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Bounds
import Mathlib.Tactic

/- Computable coefficient lists with real-valued soundness theorems.
   No recorded-field enclosure is assumed or certified by this module alone. -/
namespace FrozenPolynomial

abbrev Poly := List ℚ

def eval : Poly → ℝ → ℝ
  | [], _ => 0
  | a :: p, x => (a : ℝ) + x * eval p x

def mass : Poly → ℚ
  | [] => 0
  | a :: p => |a| + mass p

theorem mass_nonneg (p : Poly) : 0 ≤ mass p := by
  induction p with
  | nil => simp [mass]
  | cons a p ih => exact add_nonneg (abs_nonneg a) ih

theorem abs_eval_le_mass (p : Poly) (x : ℝ) (hx : |x| ≤ 1) :
    |eval p x| ≤ (mass p : ℝ) := by
  induction p with
  | nil => simp [eval, mass]
  | cons a p ih =>
    simp only [eval, mass, Rat.cast_add, Rat.cast_abs]
    calc
      |(a : ℝ) + x * eval p x| ≤ |(a : ℝ)| + |x * eval p x| := abs_add_le _ _
      _ = |(a : ℝ)| + |x| * |eval p x| := by rw [abs_mul]
      _ ≤ |(a : ℝ)| + 1 * (mass p : ℝ) := by
        gcongr
      _ = |(a : ℝ)| + (mass p : ℝ) := by ring

def add : Poly → Poly → Poly
  | [], q => q
  | p, [] => p
  | a :: p, b :: q => (a + b) :: add p q

def scale (a : ℚ) : Poly → Poly
  | [] => []
  | b :: p => (a * b) :: scale a p

def neg (p : Poly) : Poly := scale (-1) p
def sub (p q : Poly) : Poly := add p (neg q)

theorem eval_add (p q : Poly) (x : ℝ) : eval (add p q) x = eval p x + eval q x := by
  induction p generalizing q with
  | nil => simp [add, eval]
  | cons a p ih =>
    cases q with
    | nil => simp [add, eval]
    | cons b q => simp only [add, eval, Rat.cast_add, ih]; ring

theorem eval_scale (a : ℚ) (p : Poly) (x : ℝ) :
    eval (scale a p) x = (a : ℝ) * eval p x := by
  induction p with
  | nil => simp [scale, eval]
  | cons b p ih => simp only [scale, eval, Rat.cast_mul, ih]; ring

theorem eval_neg (p : Poly) (x : ℝ) : eval (neg p) x = -eval p x := by
  simp [neg, eval_scale]

theorem eval_sub (p q : Poly) (x : ℝ) : eval (sub p q) x = eval p x - eval q x := by
  simp [sub, eval_add, eval_neg, sub_eq_add_neg]

def mul : Poly → Poly → Poly
  | [], _ => []
  | a :: p, q => add (scale a q) (0 :: mul p q)

theorem eval_mul (p q : Poly) (x : ℝ) : eval (mul p q) x = eval p x * eval q x := by
  induction p with
  | nil => simp [mul, eval]
  | cons a p ih => simp only [mul, eval_add, eval_scale, eval, Rat.cast_zero, ih]; ring

theorem eval_take_drop (p : Poly) (n : ℕ) (x : ℝ) :
    eval p x = eval (p.take n) x + x ^ n * eval (p.drop n) x := by
  induction n generalizing p with
  | zero => simp [eval]
  | succ n ih =>
    cases p with
    | nil => simp [eval]
    | cons a p => simp only [List.take_succ_cons, List.drop_succ_cons, eval, ih p, pow_succ]; ring

theorem truncate_error (p : Poly) (n : ℕ) (x : ℝ) (hx : |x| ≤ 1) :
    |eval p x - eval (p.take n) x| ≤ (mass (p.drop n) : ℝ) := by
  rw [eval_take_drop p n x]
  simp only [add_sub_cancel_left, abs_mul, abs_pow]
  calc
    |x| ^ n * |eval (p.drop n) x| ≤ 1 * (mass (p.drop n) : ℝ) := by
      gcongr
      exact pow_le_one₀ (abs_nonneg x) hx
      exact abs_eval_le_mass _ _ hx
    _ = (mass (p.drop n) : ℝ) := one_mul _

structure Model where
  polynomial : Poly
  error : ℚ
  error_nonneg : 0 ≤ error

def Models (m : Model) (f : ℝ → ℝ) : Prop :=
  ∀ x : ℝ, |x| ≤ 1 → |f x - eval m.polynomial x| ≤ (m.error : ℝ)

theorem model_value_bound {m : Model} {f : ℝ → ℝ} (hf : Models m f)
    {x : ℝ} (hx : |x| ≤ 1) : |f x| ≤ (mass m.polynomial + m.error : ℚ) := by
  push_cast
  calc
    |f x| = |eval m.polynomial x + (f x - eval m.polynomial x)| := by congr 1; ring
    _ ≤ |eval m.polynomial x| + |f x - eval m.polynomial x| := abs_add_le _ _
    _ ≤ (mass m.polynomial : ℝ) + (m.error : ℝ) := add_le_add (abs_eval_le_mass _ _ hx) (hf x hx)

def Model.exact (p : Poly) : Model := ⟨p, 0, le_refl 0⟩

theorem exact_models (p : Poly) : Models (Model.exact p) (eval p) := by
  intro x hx
  simp [Model.exact]

def Model.add (m n : Model) : Model :=
  ⟨FrozenPolynomial.add m.polynomial n.polynomial, m.error + n.error, add_nonneg m.error_nonneg n.error_nonneg⟩

theorem add_models {m n : Model} {f g : ℝ → ℝ} (hf : Models m f) (hg : Models n g) :
    Models (m.add n) (fun x => f x + g x) := by
  intro x hx
  simp only [Model.add, eval_add, Rat.cast_add]
  calc
    |f x + g x - (eval m.polynomial x + eval n.polynomial x)| =
        |(f x - eval m.polynomial x) + (g x - eval n.polynomial x)| := by congr 1; ring
    _ ≤ |f x - eval m.polynomial x| + |g x - eval n.polynomial x| := abs_add_le _ _
    _ ≤ (m.error : ℝ) + (n.error : ℝ) := add_le_add (hf x hx) (hg x hx)

def Model.neg (m : Model) : Model := ⟨FrozenPolynomial.neg m.polynomial, m.error, m.error_nonneg⟩

theorem neg_models {m : Model} {f : ℝ → ℝ} (hf : Models m f) :
    Models m.neg (fun x => -f x) := by
  intro x hx
  change |-f x - eval (FrozenPolynomial.neg m.polynomial) x| ≤ (m.error : ℝ)
  rw [eval_neg]
  convert hf x hx using 1
  rw [← abs_neg]
  congr 1
  ring

def Model.mul (m n : Model) : Model :=
  ⟨FrozenPolynomial.mul m.polynomial n.polynomial,
   mass m.polynomial * n.error + mass n.polynomial * m.error + m.error * n.error,
   add_nonneg (add_nonneg (mul_nonneg (mass_nonneg _) n.error_nonneg)
     (mul_nonneg (mass_nonneg _) m.error_nonneg)) (mul_nonneg m.error_nonneg n.error_nonneg)⟩

theorem mul_models {m n : Model} {f g : ℝ → ℝ} (hf : Models m f) (hg : Models n g) :
    Models (m.mul n) (fun x => f x * g x) := by
  intro x hx
  have hm := abs_eval_le_mass m.polynomial x hx
  have hn := abs_eval_le_mass n.polynomial x hx
  have hfe := hf x hx
  have hge := hg x hx
  have hmp : (0 : ℝ) ≤ (mass m.polynomial : ℝ) := Rat.cast_nonneg.mpr (mass_nonneg _)
  have hnp : (0 : ℝ) ≤ (mass n.polynomial : ℝ) := Rat.cast_nonneg.mpr (mass_nonneg _)
  have hme : (0 : ℝ) ≤ (m.error : ℝ) := Rat.cast_nonneg.mpr m.error_nonneg
  simp only [Model.mul, eval_mul, Rat.cast_add, Rat.cast_mul]
  calc
    |f x * g x - eval m.polynomial x * eval n.polynomial x| =
      |eval m.polynomial x * (g x - eval n.polynomial x) +
        eval n.polynomial x * (f x - eval m.polynomial x) +
        (f x - eval m.polynomial x) * (g x - eval n.polynomial x)| := by congr 1; ring
    _ ≤ |eval m.polynomial x * (g x - eval n.polynomial x)| +
        |eval n.polynomial x * (f x - eval m.polynomial x)| +
        |(f x - eval m.polynomial x) * (g x - eval n.polynomial x)| := abs_add_three _ _ _
    _ ≤ (mass m.polynomial : ℝ) * n.error + (mass n.polynomial : ℝ) * m.error +
        (m.error : ℝ) * n.error := by
      simp only [abs_mul]
      gcongr

def Model.round (m : Model) (q : Poly) : Model :=
  ⟨q, m.error + mass (sub m.polynomial q), add_nonneg m.error_nonneg (mass_nonneg _)⟩

theorem round_models {m : Model} {f : ℝ → ℝ} (hf : Models m f) (q : Poly) :
    Models (m.round q) f := by
  intro x hx
  simp only [Model.round, Rat.cast_add]
  calc
    |f x - eval q x| = |(f x - eval m.polynomial x) + eval (sub m.polynomial q) x| := by
      rw [eval_sub]; congr 1; ring
    _ ≤ |f x - eval m.polynomial x| + |eval (sub m.polynomial q) x| := abs_add_le _ _
    _ ≤ (m.error : ℝ) + (mass (sub m.polynomial q) : ℝ) :=
      add_le_add (hf x hx) (abs_eval_le_mass _ _ hx)

def Model.truncate (m : Model) (n : ℕ) : Model :=
  ⟨m.polynomial.take n, m.error + mass (m.polynomial.drop n),
    add_nonneg m.error_nonneg (mass_nonneg _)⟩

theorem truncate_models {m : Model} {f : ℝ → ℝ} (hf : Models m f) (n : ℕ) :
    Models (m.truncate n) f := by
  intro x hx
  simp only [Model.truncate, Rat.cast_add]
  calc
    |f x - eval (m.polynomial.take n) x| =
      |(f x - eval m.polynomial x) + (eval m.polynomial x - eval (m.polynomial.take n) x)| := by
      congr 1; ring
    _ ≤ |f x - eval m.polynomial x| + |eval m.polynomial x - eval (m.polynomial.take n) x| := abs_add_le _ _
    _ ≤ (m.error : ℝ) + (mass (m.polynomial.drop n) : ℝ) :=
      add_le_add (hf x hx) (truncate_error _ _ _ hx)

end FrozenPolynomial
