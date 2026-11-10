import Volterra

open Set MeasureTheory
open scoped NNReal

namespace MemoryProof

/-- A usable positive control: both analytic premises follow from the zero field. -/
theorem zeroField (a b x₀ : ℝ) (hab : a ≤ b) :
    ∃ x, Volterra.Solution (fun _ _ : ℝ => (0 : ℝ)) a b x₀ x ∧
      ∀ y, Volterra.Solution (fun _ _ : ℝ => (0 : ℝ)) a b x₀ y → EqOn y x (Icc a b) := by
  apply Volterra.exists_unique_solution hab (fun _ _ : ℝ => (0 : ℝ)) x₀ 0
  · intro x hx
    exact intervalIntegrable_const
  · intro t ht
    exact LipschitzWith.const (0 : ℝ)

#print axioms zeroField
end MemoryProof
