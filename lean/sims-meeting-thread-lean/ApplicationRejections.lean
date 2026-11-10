import Volterra

open Set MeasureTheory
open scoped NNReal

set_option linter.unusedVariables false

set_option pp.unicode.fun true

/-! Eight attempts from the original SIMS application suite. Each guard checks the exact error reported by the pinned Lean release. -/

-- missing_bound
/--
error: Tactic `assumption` failed

a b c x₀ : ℝ
F G : ℝ → ℝ → ℝ
K J : ℝ≥0
e0 : a ≤ b
e1 : ∀ (x : ℝ → ℝ), ContinuousOn x (Icc a b) → IntervalIntegrable (fun t ↦ F t (x t)) volume a b
⊢ ∀ t ∈ Icc a b, LipschitzWith K (F t)
-/
#guard_msgs in
example (a b c x₀ : ℝ) (F G : ℝ → ℝ → ℝ) (K J : ℝ≥0)
    (e0 : a ≤ b)
    (e1 : ∀ x : ℝ → ℝ, ContinuousOn x (Icc a b) → IntervalIntegrable (fun t => F t (x t)) volume a b) :
    ∃ x, Volterra.Solution F a b x₀ x ∧
      ∀ y, Volterra.Solution F a b x₀ y → EqOn y x (Icc a b) := by
  exact Volterra.exists_unique_solution (a := a) (b := b) (by assumption) F x₀ K (by assumption) (by assumption)

-- wrong_field_bound
/--
error: Tactic `assumption` failed

a b c x₀ : ℝ
F G : ℝ → ℝ → ℝ
K J : ℝ≥0
e0 : a ≤ b
e1 : ∀ (x : ℝ → ℝ), ContinuousOn x (Icc a b) → IntervalIntegrable (fun t ↦ F t (x t)) volume a b
e2 : ∀ t ∈ Icc a b, LipschitzWith K (G t)
⊢ ∀ t ∈ Icc a b, LipschitzWith K (F t)
-/
#guard_msgs in
example (a b c x₀ : ℝ) (F G : ℝ → ℝ → ℝ) (K J : ℝ≥0)
    (e0 : a ≤ b)
    (e1 : ∀ x : ℝ → ℝ, ContinuousOn x (Icc a b) → IntervalIntegrable (fun t => F t (x t)) volume a b)
    (e2 : ∀ t ∈ Icc a b, LipschitzWith K (G t)) :
    ∃ x, Volterra.Solution F a b x₀ x ∧
      ∀ y, Volterra.Solution F a b x₀ y → EqOn y x (Icc a b) := by
  exact Volterra.exists_unique_solution (a := a) (b := b) (by assumption) F x₀ K (by assumption) (by assumption)

-- wrong_interval
/--
error: Tactic `assumption` failed

a b c x₀ : ℝ
F G : ℝ → ℝ → ℝ
K J : ℝ≥0
e0 : a ≤ b
e1 : ∀ (x : ℝ → ℝ), ContinuousOn x (Icc a b) → IntervalIntegrable (fun t ↦ F t (x t)) volume a b
e2 : ∀ t ∈ Icc a c, LipschitzWith K (F t)
⊢ ∀ t ∈ Icc a b, LipschitzWith K (F t)
-/
#guard_msgs in
example (a b c x₀ : ℝ) (F G : ℝ → ℝ → ℝ) (K J : ℝ≥0)
    (e0 : a ≤ b)
    (e1 : ∀ x : ℝ → ℝ, ContinuousOn x (Icc a b) → IntervalIntegrable (fun t => F t (x t)) volume a b)
    (e2 : ∀ t ∈ Icc a c, LipschitzWith K (F t)) :
    ∃ x, Volterra.Solution F a b x₀ x ∧
      ∀ y, Volterra.Solution F a b x₀ y → EqOn y x (Icc a b) := by
  exact Volterra.exists_unique_solution (a := a) (b := b) (by assumption) F x₀ K (by assumption) (by assumption)

-- wrong_constant
/--
error: Tactic `assumption` failed

a b c x₀ : ℝ
F G : ℝ → ℝ → ℝ
K J : ℝ≥0
e0 : a ≤ b
e1 : ∀ (x : ℝ → ℝ), ContinuousOn x (Icc a b) → IntervalIntegrable (fun t ↦ F t (x t)) volume a b
e2 : ∀ t ∈ Icc a b, LipschitzWith J (F t)
⊢ ∀ t ∈ Icc a b, LipschitzWith K (F t)
-/
#guard_msgs in
example (a b c x₀ : ℝ) (F G : ℝ → ℝ → ℝ) (K J : ℝ≥0)
    (e0 : a ≤ b)
    (e1 : ∀ x : ℝ → ℝ, ContinuousOn x (Icc a b) → IntervalIntegrable (fun t => F t (x t)) volume a b)
    (e2 : ∀ t ∈ Icc a b, LipschitzWith J (F t)) :
    ∃ x, Volterra.Solution F a b x₀ x ∧
      ∀ y, Volterra.Solution F a b x₀ y → EqOn y x (Icc a b) := by
  exact Volterra.exists_unique_solution (a := a) (b := b) (by assumption) F x₀ K (by assumption) (by assumption)

-- missing_integrability
/--
error: Tactic `assumption` failed

a b c x₀ : ℝ
F G : ℝ → ℝ → ℝ
K J : ℝ≥0
e0 : a ≤ b
e1 : ∀ t ∈ Icc a b, LipschitzWith K (F t)
⊢ ∀ (x : ℝ → ℝ), ContinuousOn x (Icc a b) → IntervalIntegrable (fun t ↦ F t (x t)) volume a b
-/
#guard_msgs in
example (a b c x₀ : ℝ) (F G : ℝ → ℝ → ℝ) (K J : ℝ≥0)
    (e0 : a ≤ b)
    (e1 : ∀ t ∈ Icc a b, LipschitzWith K (F t)) :
    ∃ x, Volterra.Solution F a b x₀ x ∧
      ∀ y, Volterra.Solution F a b x₀ y → EqOn y x (Icc a b) := by
  exact Volterra.exists_unique_solution (a := a) (b := b) (by assumption) F x₀ K (by assumption) (by assumption)

-- reversed_interval_fact
/--
error: Tactic `assumption` failed

a b c x₀ : ℝ
F G : ℝ → ℝ → ℝ
K J : ℝ≥0
e0 : b ≤ a
e1 : ∀ (x : ℝ → ℝ), ContinuousOn x (Icc a b) → IntervalIntegrable (fun t ↦ F t (x t)) volume a b
e2 : ∀ t ∈ Icc a b, LipschitzWith K (F t)
⊢ a ≤ b
-/
#guard_msgs in
example (a b c x₀ : ℝ) (F G : ℝ → ℝ → ℝ) (K J : ℝ≥0)
    (e0 : b ≤ a)
    (e1 : ∀ x : ℝ → ℝ, ContinuousOn x (Icc a b) → IntervalIntegrable (fun t => F t (x t)) volume a b)
    (e2 : ∀ t ∈ Icc a b, LipschitzWith K (F t)) :
    ∃ x, Volterra.Solution F a b x₀ x ∧
      ∀ y, Volterra.Solution F a b x₀ y → EqOn y x (Icc a b) := by
  exact Volterra.exists_unique_solution (a := a) (b := b) (by assumption) F x₀ K (by assumption) (by assumption)

-- several_open
/--
error: Tactic `assumption` failed

a b c x₀ : ℝ
F G : ℝ → ℝ → ℝ
K J : ℝ≥0
e0 : ∀ (x : ℝ → ℝ), ContinuousOn x (Icc a b) → IntervalIntegrable (fun t ↦ F t (x t)) volume a b
e1 : ∀ t ∈ Icc a b, LipschitzWith K (F t)
⊢ a ≤ b
---
error: Tactic `assumption` failed

a b c x₀ : ℝ
F G : ℝ → ℝ → ℝ
K J : ℝ≥0
e0 : ∀ (x : ℝ → ℝ), ContinuousOn x (Icc a b) → IntervalIntegrable (fun t ↦ F t (x t)) volume a b
e1 : ∀ t ∈ Icc a b, LipschitzWith K (F t)
⊢ ∀ (x : ℝ → ℝ), ContinuousOn x (Icc a b) → IntervalIntegrable (fun t ↦ G t (x t)) volume a b
---
error: Tactic `assumption` failed

a b c x₀ : ℝ
F G : ℝ → ℝ → ℝ
K J : ℝ≥0
e0 : ∀ (x : ℝ → ℝ), ContinuousOn x (Icc a b) → IntervalIntegrable (fun t ↦ F t (x t)) volume a b
e1 : ∀ t ∈ Icc a b, LipschitzWith K (F t)
⊢ ∀ t ∈ Icc a b, LipschitzWith K (G t)
-/
#guard_msgs in
example (a b c x₀ : ℝ) (F G : ℝ → ℝ → ℝ) (K J : ℝ≥0)
    (e0 : ∀ x : ℝ → ℝ, ContinuousOn x (Icc a b) → IntervalIntegrable (fun t => F t (x t)) volume a b)
    (e1 : ∀ t ∈ Icc a b, LipschitzWith K (F t)) :
    ∃ x, Volterra.Solution G a b x₀ x ∧
      ∀ y, Volterra.Solution G a b x₀ y → EqOn y x (Icc a b) := by
  exact Volterra.exists_unique_solution (a := a) (b := b) (by assumption) G x₀ K (by assumption) (by assumption)

-- topic_matches_wrong_conclusion
/--
error: Type mismatch
  Volterra.exists_unique_fixed_point e0 F x₀ e1 e2
has type
  ∃ (x : Volterra.Curve a b ℝ),
    Function.IsFixedPt (Volterra.step e0 F x₀ e1) x ∧
      ∀ (y : Volterra.Curve a b ℝ), Function.IsFixedPt (Volterra.step e0 F x₀ e1) y → y = x
but is expected to have type
  ∃ (x : ℝ → ℝ), Volterra.Solution F a b x₀ x ∧ ∀ (y : ℝ → ℝ), Volterra.Solution F a b x₀ y → EqOn y x (Icc a b)
-/
#guard_msgs in
example (a b c x₀ : ℝ) (F G : ℝ → ℝ → ℝ) (K J : ℝ≥0)
    (e0 : a ≤ b)
    (e1 : ∀ x : ℝ → ℝ, ContinuousOn x (Icc a b) → IntervalIntegrable (fun t => F t (x t)) volume a b)
    (e2 : ∀ t ∈ Icc a b, LipschitzWith K (F t)) :
    ∃ x, Volterra.Solution F a b x₀ x ∧
      ∀ y, Volterra.Solution F a b x₀ y → EqOn y x (Icc a b) := by
  exact Volterra.exists_unique_fixed_point (a := a) (b := b) (by assumption) F x₀ (by assumption) (K := K) (by assumption)
