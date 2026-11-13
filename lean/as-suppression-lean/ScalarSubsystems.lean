import IntegralBarrier
import InputRegularity

open Set MeasureTheory
open scoped NNReal
namespace SocialAS.Existence

theorem linear_exists_unique {a b : ℝ} (hab : a ≤ b) (f c : ℝ → ℝ) (initial : ℝ)
    (hf : IntervalIntegrable f volume a b) (hc : IntervalIntegrable c volume a b)
    (M : ℝ≥0) (hM : ∀ t ∈ Icc a b, |c t| ≤ M) :
    ∃ x, Volterra.Solution (fun t v => f t - c t * v) a b initial x ∧
      ∀ y, Volterra.Solution (fun t v => f t - c t * v) a b initial y →
        EqOn y x (Icc a b) := by
  apply Volterra.exists_unique_solution hab _ initial M
  · intro x hx
    have hx' : ContinuousOn x (uIcc a b) := by rwa [uIcc_of_le hab]
    exact hf.sub (hc.mul_continuousOn hx')
  · intro t ht
    apply LipschitzWith.of_dist_le_mul
    intro x y
    change |(f t - c t*x)-(f t-c t*y)| ≤ (M : ℝ)*|x-y|
    have heq : (f t-c t*x)-(f t-c t*y) = -c t*(x-y) := by ring
    rw [heq,abs_mul,abs_neg]
    exact mul_le_mul_of_nonneg_right (hM t ht) (abs_nonneg _)

theorem linear_solution_nonnegative {a b initial : ℝ} {f c x : ℝ → ℝ}
    (hab : a ≤ b) (hx : Volterra.Solution (fun t v => f t-c t*v) a b initial x)
    (hinit : 0 ≤ initial) (hf : ∀ t ∈ Icc a b, 0 ≤ f t)
    (hc : ∀ t ∈ Icc a b, 0 ≤ c t) :
    ∀ t ∈ Icc a b, 0 ≤ x t := by
  apply Volterra.solution_nonnegative hab hx hinit
  intro t ht y hy
  exact sub_nonneg.mpr ((mul_nonpos_of_nonneg_of_nonpos (hc t ht) hy).trans (hf t ht))

end SocialAS.Existence
