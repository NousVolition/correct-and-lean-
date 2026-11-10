import TwoMemoryModel

open Set MeasureTheory
open scoped NNReal

namespace TwoMemory

noncomputable section

theorem recall_eq_tanh (s : ℝ) : memoryField s = Real.tanh s := by
  unfold memoryField
  dsimp only
  rw [show -((s - 1)^2) / 2 = -(s^2 + 1) / 2 + s by ring,
      show -((s + 1)^2) / 2 = -(s^2 + 1) / 2 + -s by ring,
      Real.exp_add, Real.exp_add, Real.tanh_eq, ← mul_sub, ← mul_add]
  exact mul_div_mul_left _ _ (Real.exp_ne_zero _)

private theorem tanh_derivative (s : ℝ) :
    HasDerivAt Real.tanh (1 / Real.cosh s ^ 2) s := by
  have h := (Real.hasDerivAt_sinh s).div (Real.hasDerivAt_cosh s) (Real.cosh_pos s).ne'
  change HasDerivAt (fun t : ℝ => Real.sinh t / Real.cosh t)
    ((Real.cosh s * Real.cosh s - Real.sinh s * Real.sinh s) / Real.cosh s ^ 2) s at h
  have eqf : (fun t : ℝ => Real.sinh t / Real.cosh t) = Real.tanh :=
    funext fun t => (Real.tanh_eq_sinh_div_cosh (x := t)).symm
  rw [eqf, ← sq, ← sq, Real.cosh_sq_sub_sinh_sq] at h
  exact h

theorem recall_lipschitz : LipschitzWith 1 memoryField := by
  rw [show memoryField = Real.tanh from funext recall_eq_tanh]
  apply lipschitzWith_of_nnnorm_deriv_le (fun s => (tanh_derivative s).differentiableAt)
  intro s
  rw [(tanh_derivative s).deriv]
  change ‖1 / Real.cosh s ^ 2‖ ≤ (1 : ℝ)
  rw [Real.norm_eq_abs, abs_of_nonneg (by positivity)]
  apply (div_le_iff₀ (sq_pos_of_pos (Real.cosh_pos s))).2
  nlinarith [Real.one_le_cosh s, sq_nonneg (Real.cosh s - 1)]

/-- The current state is the cue; its recalled value is the instantaneous drift. -/
theorem unique_memory_trajectory (a b x₀ : ℝ) (hab : a ≤ b) :
    ∃ x, Volterra.Solution (fun _ : ℝ => memoryField) a b x₀ x ∧
      ∀ y, Volterra.Solution (fun _ : ℝ => memoryField) a b x₀ y → EqOn y x (Icc a b) := by
  apply Volterra.exists_unique_solution hab (fun _ : ℝ => memoryField) x₀ 1
  · intro x hx
    exact ContinuousOn.intervalIntegrable_of_Icc hab (recall_lipschitz.continuous.comp_continuousOn hx)
  · intro t ht
    exact recall_lipschitz

end

end TwoMemory
