import FrozenPolynomial
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Analysis.Calculus.Deriv.Mul

namespace FrozenIntPolynomial

abbrev Poly := List ℤ

def eval : Poly → ℝ → ℝ
  | [], _ => 0
  | a :: p, x => (a : ℝ) + x * eval p x

def evalInt : Poly → ℤ → ℤ
  | [], _ => 0
  | a :: p, x => a + x * evalInt p x

def mass : Poly → ℤ
  | [] => 0
  | a :: p => |a| + mass p

def add : Poly → Poly → Poly
  | [], q => q
  | p, [] => p
  | a :: p, b :: q => (a + b) :: add p q

def scale (a : ℤ) : Poly → Poly
  | [] => []
  | b :: p => (a * b) :: scale a p

def sub (p q : Poly) : Poly := add p (scale (-1) q)

def mul : Poly → Poly → Poly
  | [], _ => []
  | a :: p, q => add (scale a q) (0 :: mul p q)

def derivative : Poly → Poly
  | [] => []
  | _ :: p => add p (0 :: derivative p)

theorem eval_add (p q : Poly) (x : ℝ) : eval (add p q) x = eval p x + eval q x := by
  induction p generalizing q with
  | nil => simp [add, eval]
  | cons a p ih =>
    cases q with
    | nil => simp [add, eval]
    | cons b q => simp only [add, eval, Int.cast_add, ih]; ring

theorem eval_scale (a : ℤ) (p : Poly) (x : ℝ) :
    eval (scale a p) x = (a : ℝ) * eval p x := by
  induction p with
  | nil => simp [scale, eval]
  | cons b p ih => simp only [scale, eval, Int.cast_mul, ih]; ring

theorem eval_sub (p q : Poly) (x : ℝ) : eval (sub p q) x = eval p x - eval q x := by
  simp [sub, eval_add, eval_scale, sub_eq_add_neg]

theorem eval_mul (p q : Poly) (x : ℝ) : eval (mul p q) x = eval p x * eval q x := by
  induction p with
  | nil => simp [mul, eval]
  | cons a p ih => simp only [mul, eval_add, eval_scale, eval, Int.cast_zero, ih]; ring

theorem eval_cast (p : Poly) (x : ℤ) : eval p (x : ℝ) = (evalInt p x : ℝ) := by
  induction p with
  | nil => simp [eval, evalInt]
  | cons a p ih => simp [eval, evalInt, ih]

theorem mass_nonneg (p : Poly) : 0 ≤ mass p := by
  induction p with
  | nil => exact le_refl 0
  | cons a p ih => exact add_nonneg (abs_nonneg _) ih

theorem abs_eval_le_mass (p : Poly) (x : ℝ) (hx : |x| ≤ 1) :
    |eval p x| ≤ (mass p : ℝ) := by
  induction p with
  | nil => simp [eval, mass]
  | cons a p ih =>
    simp only [eval, mass, Int.cast_add, Int.cast_abs]
    calc
      _ ≤ |(a : ℝ)| + |x * eval p x| := abs_add_le _ _
      _ = |(a : ℝ)| + |x| * |eval p x| := by rw [abs_mul]
      _ ≤ |(a : ℝ)| + 1 * (mass p : ℝ) := by gcongr
      _ = _ := by ring

theorem hasDerivAt_eval (p : Poly) (x : ℝ) :
    HasDerivAt (eval p) (eval (derivative p) x) x := by
  induction p with
  | nil => simpa only [eval, derivative] using hasDerivAt_const x (0 : ℝ)
  | cons a p ih =>
    have h := ((hasDerivAt_id x).mul ih).const_add (a : ℝ)
    convert! h using 1
    simp only [derivative, eval_add, eval, Int.cast_zero, zero_add, id_eq, one_mul]

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
    _ ≤ 1 * (mass (p.drop n) : ℝ) := by
      gcongr
      exact pow_le_one₀ (abs_nonneg x) hx
      exact abs_eval_le_mass _ _ hx
    _ = _ := one_mul _

end FrozenIntPolynomial
