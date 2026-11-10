import Volterra

open Set MeasureTheory
open scoped NNReal

set_option linter.unusedVariables false

namespace ApplicationControls

theorem all_premises (a b c x₀ : ℝ) (F G : ℝ → ℝ → ℝ) (K J : ℝ≥0)
    (e0 : a ≤ b)
    (e1 : ∀ x : ℝ → ℝ, ContinuousOn x (Icc a b) → IntervalIntegrable (fun t => F t (x t)) volume a b)
    (e2 : ∀ t ∈ Icc a b, LipschitzWith K (F t)) :
    ∃ x, Volterra.Solution F a b x₀ x ∧
      ∀ y, Volterra.Solution F a b x₀ y → EqOn y x (Icc a b) := by
  exact Volterra.exists_unique_solution (a := a) (b := b) (by assumption) F x₀ K (by assumption) (by assumption)

theorem new_field_repaired (a b c x₀ : ℝ) (F G : ℝ → ℝ → ℝ) (K J : ℝ≥0)
    (e0 : a ≤ b)
    (e1 : ∀ x : ℝ → ℝ, ContinuousOn x (Icc a b) → IntervalIntegrable (fun t => G t (x t)) volume a b)
    (e2 : ∀ t ∈ Icc a b, LipschitzWith K (G t)) :
    ∃ x, Volterra.Solution G a b x₀ x ∧
      ∀ y, Volterra.Solution G a b x₀ y → EqOn y x (Icc a b) := by
  exact Volterra.exists_unique_solution (a := a) (b := b) (by assumption) G x₀ K (by assumption) (by assumption)

end ApplicationControls
