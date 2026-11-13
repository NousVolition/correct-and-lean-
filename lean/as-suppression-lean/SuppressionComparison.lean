import FullAssembly

/-! Integral comparison for the original A/S influence equations.
The argument uses no numerical approximation or new model hypothesis. -/

open Set MeasureTheory
namespace SocialAS.Suppression
open SocialAS.Existence
noncomputable section

theorem solution_congr_rhs {F G : ℝ → ℝ → ℝ} {a b x₀ : ℝ} {x : ℝ → ℝ}
    (hab : a ≤ b) (hx : Volterra.Solution F a b x₀ x)
    (heq : ∀ t ∈ Icc a b, F t (x t) = G t (x t)) :
    Volterra.Solution G a b x₀ x := by
  refine ⟨hx.1, hx.2.1, ?_, ?_⟩
  · apply hx.2.2.1.congr
    intro t ht
    exact heq t ((uIoc_subset_uIcc.trans (by rw [uIcc_of_le hab])) ht)
  · intro t ht
    rw [hx.2.2.2 t ht]
    congr 1
    apply intervalIntegral.integral_congr
    intro s hs
    exact heq s (uIcc_subset_Icc ⟨le_rfl, hab⟩ ht hs)

theorem solution_linear_combination
    {F G H : ℝ → ℝ → ℝ} {a b x₀ y₀ : ℝ} {x y : ℝ → ℝ}
    (hab : a ≤ b) (hx : Volterra.Solution F a b x₀ x)
    (hy : Volterra.Solution G a b y₀ y) (c d : ℝ)
    (heq : ∀ t ∈ Icc a b,
      c * F t (x t) + d * G t (y t) = H t (c * x t + d * y t)) :
    Volterra.Solution H a b (c * x₀ + d * y₀) (fun t => c * x t + d * y t) := by
  refine ⟨(continuousOn_const.mul hx.1).add (continuousOn_const.mul hy.1), ?_, ?_, ?_⟩
  · change c * x a + d * y a = _
    rw [hx.2.1, hy.2.1]
  · apply ((hx.2.2.1.const_mul c).add (hy.2.2.1.const_mul d)).congr
    intro t ht
    exact heq t ((uIoc_subset_uIcc.trans (by rw [uIcc_of_le hab])) ht)
  · intro t ht
    have hix := sol_integrable_to hab hx ht
    have hiy := sol_integrable_to hab hy ht
    have hint : (∫ s in a..t, H s (c * x s + d * y s)) =
        c * (∫ s in a..t, F s (x s)) + d * (∫ s in a..t, G s (y s)) := by
      calc
        _ = ∫ s in a..t, c * F s (x s) + d * G s (y s) := by
          apply intervalIntegral.integral_congr
          intro s hs
          exact (heq s (uIcc_subset_Icc ⟨le_rfl, hab⟩ ht hs)).symm
        _ = _ := by
          rw [intervalIntegral.integral_add (hix.const_mul c) (hiy.const_mul d),
            intervalIntegral.integral_const_mul, intervalIntegral.integral_const_mul]
    change c * x t + d * y t = _
    rw [hint, hx.2.2.2 t ht, hy.2.2.2 t ht]
    ring

-- The weighted sum v*x + u*y cancels both exchange terms. No division by
-- either weight is used, so zero and unequal exchange weights are included.
theorem cooperative_nonnegative {a b u v decay x₀ y₀ : ℝ} {f g x y : ℝ → ℝ}
    (hab : a ≤ b) (hu : 0 ≤ u) (hv : 0 ≤ v) (hd : 0 ≤ decay)
    (hx : Volterra.Solution (fun t r => u * (y t - r) - decay * r + f t) a b x₀ x)
    (hy : Volterra.Solution (fun t r => v * (x t - r) - decay * r + g t) a b y₀ y)
    (hx₀ : 0 ≤ x₀) (hy₀ : 0 ≤ y₀)
    (hf : ∀ t ∈ Icc a b, 0 ≤ f t) (hg : ∀ t ∈ Icc a b, 0 ≤ g t) :
    ∀ t ∈ Icc a b, 0 ≤ x t ∧ 0 ≤ y t := by
  let total := fun t => v * x t + u * y t
  have htSol : Volterra.Solution
      (fun t r => (v * f t + u * g t) - decay * r)
      a b (v * x₀ + u * y₀) total := by
    apply solution_linear_combination hab hx hy v u
    intro t ht
    ring
  have htPos : ∀ t ∈ Icc a b, 0 ≤ total t :=
    linear_solution_nonnegative hab htSol
      (add_nonneg (mul_nonneg hv hx₀) (mul_nonneg hu hy₀))
      (fun t ht => add_nonneg (mul_nonneg hv (hf t ht)) (mul_nonneg hu (hg t ht)))
      (fun _ _ => hd)
  have hxSol : Volterra.Solution
      (fun t r => (total t + f t) - (u + v + decay) * r) a b x₀ x := by
    apply solution_congr_rhs hab hx
    intro t ht
    dsimp [total]
    ring
  have hySol : Volterra.Solution
      (fun t r => (total t + g t) - (u + v + decay) * r) a b y₀ y := by
    apply solution_congr_rhs hab hy
    intro t ht
    dsimp [total]
    ring
  have hxPos := linear_solution_nonnegative hab hxSol hx₀
    (fun t ht => add_nonneg (htPos t ht) (hf t ht))
    (fun _ _ => add_nonneg (add_nonneg hu hv) hd)
  have hyPos := linear_solution_nonnegative hab hySol hy₀
    (fun t ht => add_nonneg (htPos t ht) (hg t ht))
    (fun _ _ => add_nonneg (add_nonneg hu hv) hd)
  exact fun t ht => ⟨hxPos t ht, hyPos t ht⟩

end
end SocialAS.Suppression
