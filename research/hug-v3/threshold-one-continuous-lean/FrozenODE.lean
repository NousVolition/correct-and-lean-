import Mathlib.Analysis.ODE.ExistUnique
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Topology.Order.Compact
import Mathlib.Tactic.Abel
import Mathlib.Tactic.Convert
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.FunProp
import Mathlib.Tactic.GCongr
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Push
import Mathlib.Tactic.Ring

/-! A posteriori existence and whole-window minimum bounds.

These are general mathematical lemmas. Applying them to an archived field requires
proofs of ALL hypotheses, including the residual and Lipschitz bounds. -/

open Set Metric
open scoped NNReal

namespace FrozenODE

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E] [CompleteSpace E]

/-- Picard--Lindelof with the closed-ball conclusion retained. -/
theorem exists_solution_in_ball
    {f : ℝ → E → E} {a b : ℝ} {t₀ : Icc a b} {c x : E} {R r L K : ℝ≥0}
    (hf : IsPicardLindelof f t₀ c R r L K) (hx : x ∈ closedBall c r) :
    ∃ α : ℝ → E, α t₀ = x ∧ Continuous α ∧
      (∀ t, α t ∈ closedBall c R) ∧
      ∀ t ∈ Icc a b, HasDerivWithinAt α (f t (α t)) (Icc a b) t := by
  obtain ⟨α, hα⟩ := ODE.FunSpace.exists_isFixedPt_next hf hx
  refine ⟨α.compProj, ?_, α.continuous_compProj,
    (fun _ ↦ α.compProj_mem_closedBall hf.mul_max_le), ?_⟩
  · rw [ODE.FunSpace.compProj_val, ← hα, ODE.FunSpace.next_apply₀]
  · intro t ht
    apply ODE.hasDerivWithinAt_picard_Icc t₀.2 hf.continuousOn_uncurry
      α.continuous_compProj.continuousOn
      (fun _ _ ↦ α.compProj_mem_closedBall hf.mul_max_le) x ht |>.congr_of_mem _ ht
    intro t' ht'
    nth_rw 1 [← hα]
    rw [ODE.FunSpace.compProj_of_mem ht', ODE.FunSpace.next_apply]

/-- A polynomial or other differentiable candidate plus a certified residual tube
produces an actual solution. This does not assume that a solution already exists
or remains in the tube. Time is oriented from `a` to `b`; a backward field can be
supplied by negating the original vector field. -/
theorem exists_near_candidate
    {a b : ℝ} (hab : a ≤ b) (f : ℝ → E → E) (q q' : ℝ → E)
    (R r ε K : ℝ≥0) (x : E)
    (hq : ContinuousOn q (Icc a b))
    (hq' : ∀ t ∈ Icc a b, HasDerivWithinAt q (q' t) (Icc a b) t)
    (hx : dist x (q a) ≤ r)
    (hres : ∀ t ∈ Icc a b, ‖f t (q t) - q' t‖ ≤ ε)
    (hlip : ∀ t ∈ Icc a b, LipschitzOnWith K (f t) (closedBall (q t) R))
    (hcont : ∀ e ∈ closedBall (0 : E) R,
      ContinuousOn (fun t => f t (q t + e) - q' t) (Icc a b))
    (hstep : (ε + K * R : ℝ≥0) * (b - a) ≤ R - r) :
    ∃ y : ℝ → E, y a = x ∧ ContinuousOn y (Icc a b) ∧
      (∀ t ∈ Icc a b, dist (y t) (q t) ≤ R) ∧
      ∀ t ∈ Icc a b, HasDerivWithinAt y (f t (y t)) (Icc a b) t := by
  let g : ℝ → E → E := fun t e => f t (q t + e) - q' t
  have hg : IsPicardLindelof g ⟨a, left_mem_Icc.mpr hab⟩ 0 R r (ε + K * R) K := by
    constructor
    · intro t ht
      apply LipschitzOnWith.of_dist_le_mul
      intro u hu v hv
      change dist (f t (q t + u) - q' t) (f t (q t + v) - q' t) ≤ K * dist u v
      rw [dist_sub_right]
      have hu' : q t + u ∈ closedBall (q t) R := by
        simpa only [mem_closedBall, dist_eq_norm, add_sub_cancel_left, sub_zero] using hu
      have hv' : q t + v ∈ closedBall (q t) R := by
        simpa only [mem_closedBall, dist_eq_norm, add_sub_cancel_left, sub_zero] using hv
      simpa only [dist_add_left] using (hlip t ht).dist_le_mul _ hu' _ hv'
    · exact hcont
    · intro t ht e he
      have he' : q t + e ∈ closedBall (q t) R := by
        simpa only [mem_closedBall, dist_eq_norm, add_sub_cancel_left, sub_zero] using he
      have hzero : q t ∈ closedBall (q t) R := mem_closedBall_self R.coe_nonneg
      have hnorm : ‖e‖ ≤ (R : ℝ) := by simpa only [mem_closedBall, dist_zero_right] using he
      have hd := (hlip t ht).dist_le_mul _ he' _ hzero
      simp only [dist_eq_norm, add_sub_cancel_left] at hd
      change ‖f t (q t + e) - q' t‖ ≤ (ε + K * R : ℝ≥0)
      calc
        _ ≤ ‖f t (q t + e) - f t (q t)‖ + ‖f t (q t) - q' t‖ := norm_sub_le_norm_sub_add_norm_sub _ _ _
        _ ≤ K * ‖e‖ + ε := add_le_add hd (hres t ht)
        _ ≤ (ε + K * R : ℝ≥0) := by push_cast; nlinarith [K.coe_nonneg]
    · simpa only [Subtype.coe_mk, sub_self, max_eq_left (sub_nonneg.mpr hab)] using hstep
  have hxe : x - q a ∈ closedBall (0 : E) r := by
    simpa only [mem_closedBall, dist_eq_norm, sub_zero] using hx
  obtain ⟨e, he0, hec, heb, he'⟩ := exists_solution_in_ball hg hxe
  refine ⟨fun t => q t + e t, ?_, hq.add hec.continuousOn, ?_, ?_⟩
  · change q a + e a = x
    rw [he0]
    abel
  · intro t ht
    simpa only [mem_closedBall, dist_eq_norm, add_sub_cancel_left, sub_zero] using heb t
  · intro t ht
    convert (hq' t ht).add (he' t ht) using 1
    · rfl
    · dsimp [g]
      abel

/-- A minimum enclosure uses a lower bound at EVERY point and an upper witness.
It does not treat a list of optimizer candidates as exhaustive. -/
theorem attained_minimum_enclosure {a b L U : ℝ} {d : ℝ → ℝ}
    (hab : a ≤ b) (hd : ContinuousOn d (Icc a b))
    (hlower : ∀ t ∈ Icc a b, L ≤ d t)
    (hwitness : ∃ t ∈ Icc a b, d t ≤ U) :
    ∃ t ∈ Icc a b, (∀ s ∈ Icc a b, d t ≤ d s) ∧ L ≤ d t ∧ d t ≤ U := by
  obtain ⟨t, ht, hmin⟩ := isCompact_Icc.exists_isMinOn (nonempty_Icc.mpr hab) hd
  obtain ⟨w, hw, hwU⟩ := hwitness
  exact ⟨t, ht, hmin, hlower t ht, le_trans (hmin hw) hwU⟩

end FrozenODE
