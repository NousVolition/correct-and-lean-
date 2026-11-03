import FullAssembly

open Set MeasureTheory
namespace SocialAS.Invariance
open SocialAS.Existence
noncomputable section

-- Auxiliary projection used only to construct a bounded solution. Below we
-- prove it is the identity along that solution and recover the original RHS.
def clip (z : ℝ) : ℝ := min (max z 0) 1

theorem clip_bounds (z : ℝ) : UnitInterval (clip z) := by
  exact ⟨le_min (le_max_right _ _) zero_le_one, min_le_right _ _⟩

theorem clip_eq {z : ℝ} (hz : UnitInterval z) : clip z = z := by
  simp [clip, max_eq_left hz.1, min_eq_left hz.2]

theorem clip_lipschitz : LipschitzWith 1 clip :=
  (LipschitzWith.id.max_const (0 : ℝ)).min_const 1

@[fun_prop] theorem continuous_clip : Continuous clip := clip_lipschitz.continuous

theorem one_sub_solution {F : ℝ → ℝ → ℝ} {a b x₀ : ℝ} {x : ℝ → ℝ}
    (hx : Volterra.Solution F a b x₀ x) :
    Volterra.Solution (fun t y => -F t (1-y)) a b (1-x₀) (fun t => 1-x t) := by
  refine ⟨continuousOn_const.sub hx.1, by change 1-x a = 1-x₀; rw [hx.2.1], ?_, ?_⟩
  · apply hx.2.2.1.neg.congr
    intro t ht
    change -F t (x t) = -F t (1-(1-x t))
    rw [sub_sub_cancel]
  · intro t ht
    simp only [sub_sub_cancel, intervalIntegral.integral_neg]
    rw [hx.2.2.2 t ht]
    ring

theorem scalar_meaning_bounds {a b x₀ : ℝ} {k r c : ℝ → ℝ} {ref : ℝ}
    {x : ℝ → ℝ} (hab : a ≤ b)
    (hx : Volterra.Solution (fun t y => meaningDrift (k t) (r t) y (c t) ref) a b x₀ x)
    (h₀ : UnitInterval x₀) (hk : ∀ t ∈ Icc a b, 0 ≤ k t)
    (hr : ∀ t ∈ Icc a b, UnitInterval (r t))
    (hc : ∀ t ∈ Icc a b, 0 ≤ c t) (href : UnitInterval ref) :
    ∀ t ∈ Icc a b, UnitInterval (x t) := by
  have hlo : ∀ t ∈ Icc a b, 0 ≤ x t := by
    apply Volterra.solution_nonnegative hab hx h₀.1
    intro t ht y hy
    exact add_nonneg
      (mul_nonneg (hk t ht) (sub_nonneg.mpr (hy.trans (hr t ht).1)))
      (mul_nonneg (hc t ht) (sub_nonneg.mpr (hy.trans href.1)))
  have hhi : ∀ t ∈ Icc a b, 0 ≤ 1-x t := by
    apply Volterra.solution_nonnegative hab (one_sub_solution hx) (sub_nonneg.mpr h₀.2)
    intro t ht y hy
    apply neg_nonneg.mpr
    exact add_nonpos
      (mul_nonpos_of_nonneg_of_nonpos (hk t ht) (by linarith [(hr t ht).2]))
      (mul_nonpos_of_nonneg_of_nonpos (hc t ht) (by linarith [href.2]))
  exact fun t ht => ⟨hlo t ht, by linarith [hhi t ht]⟩

theorem pair_scalar_solution {F : ℝ → Pair → Pair} {a b : ℝ} {x₀ : Pair}
    {x : ℝ → Pair} (hab : a ≤ b) (hx : Volterra.Solution F a b x₀ x)
    (j : Fin 2) (G : ℝ → ℝ → ℝ)
    (hmatch : ∀ t, G t (x t j) = F t (x t) j) :
    Volterra.Solution G a b (x₀ j) (fun t => x t j) := by
  have hc := hx.1
  refine ⟨by fun_prop, congrArg (fun v : Pair => v j) hx.2.1, ?_, ?_⟩
  · simpa only [hmatch] using intervalIntegrable_fin_iff.mp hx.2.2.1 j
  · intro t ht
    simpa only [hmatch] using coord_equation hab hx t ht j

end
end SocialAS.Invariance
