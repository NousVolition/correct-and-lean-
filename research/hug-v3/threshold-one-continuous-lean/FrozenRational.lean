import FrozenPolynomial

namespace FrozenRational
open FrozenPolynomial

def evalRat : Poly → ℚ → ℚ
  | [], _ => 0
  | a :: p, x => a + x * evalRat p x

theorem eval_cast (p : Poly) (q : ℚ) :
    eval p (q : ℝ) = (evalRat p q : ℝ) := by
  induction p with
  | nil => simp [eval, evalRat]
  | cons a p ih => simp [eval, evalRat, ih]

theorem eval_zero (p : Poly) : eval p 0 = (p.headD 0 : ℝ) := by
  cases p <;> simp [eval]

end FrozenRational
