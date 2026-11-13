import Mathlib.Analysis.ODE.PicardLindelof
import Mathlib.Tactic

open Function intervalIntegral MeasureTheory Metric Set
open scoped Nat NNReal Topology
namespace Volterra
noncomputable section
section Extension

variable {E : Type*} [TopologicalSpace E] {a b : ℝ} (hab : a ≤ b)

abbrev Curve (a b : ℝ) (E : Type*) [TopologicalSpace E] := C(Icc a b, E)

def extend (x : Curve a b E) : ℝ → E := IccExtend hab x

lemma extend_continuous (x : Curve a b E) : Continuous (extend hab x) := by sorry

@[simp] lemma extend_val (x : Curve a b E) (t : Icc a b) : extend hab x t = x t := by sorry

end Extension

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
variable {a b : ℝ} (hab : a ≤ b) (F : ℝ → E → E) (x₀ : E)
variable (hint : ∀ x : ℝ → E, ContinuousOn x (Icc a b) →
  IntervalIntegrable (fun t => F t (x t)) volume a b)

def step (x : Curve a b E) : Curve a b E where
  toFun t := x₀ + ∫ s in a..t, F s (extend hab x s)
  continuous_toFun := by
    have h := continuousOn_primitive_interval' (hint _ (extend_continuous hab x).continuousOn)
      (show a ∈ uIcc a b by exact left_mem_uIcc)
    have hc : ContinuousOn (fun t : ℝ => x₀ + ∫ s in a..t, F s (extend hab x s)) (Icc a b) := by
      rw [uIcc_of_le hab] at h
      exact continuousOn_const.add h
    exact continuousOn_iff_continuous_domRestrict.mp hc

@[simp] lemma step_apply (x : Curve a b E) (t : Icc a b) :
    step hab F x₀ hint x t = x₀ + ∫ s in a..t, F s (extend hab x s) := by sorry

omit [NormedSpace ℝ E] in
include hint in
lemma path_integrable (x : Curve a b E) (t : Icc a b) :
    IntervalIntegrable (fun s => F s (extend hab x s)) volume a t := by sorry

variable {K : ℝ≥0} (hlip : ∀ t ∈ Icc a b, LipschitzWith K (F t))
include hlip

lemma iterate_apply_bound (x y : Curve a b E) (n : ℕ) (t : Icc a b) :
    dist ((step hab F x₀ hint)^[n] x t) ((step hab F x₀ hint)^[n] y t) ≤
      (K * |t.1-a|)^n / n ! * dist x y := by sorry

lemma iterate_bound (x y : Curve a b E) (n : ℕ) :
    dist ((step hab F x₀ hint)^[n] x) ((step hab F x₀ hint)^[n] y) ≤
      (K*(b-a))^n/n !*dist x y := by sorry

end
end Volterra
