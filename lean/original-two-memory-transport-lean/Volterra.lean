import Mathlib.Analysis.ODE.PicardLindelof
import Mathlib.Tactic

/- General integral-equation machinery. This does not alter the A/S equations. -/
open Function intervalIntegral MeasureTheory Metric Set
open scoped Nat NNReal Topology
namespace Volterra
noncomputable section
section Extension

variable {E : Type*} [TopologicalSpace E] {a b : ℝ} (hab : a ≤ b)

abbrev Curve (a b : ℝ) (E : Type*) [TopologicalSpace E] := C(Icc a b, E)

def extend (x : Curve a b E) : ℝ → E := IccExtend hab x

lemma extend_continuous (x : Curve a b E) : Continuous (extend hab x) :=
  x.continuous.Icc_extend'

@[simp] lemma extend_val (x : Curve a b E) (t : Icc a b) : extend hab x t = x t :=
  IccExtend_val hab x t

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
    step hab F x₀ hint x t = x₀ + ∫ s in a..t, F s (extend hab x s) := rfl

omit [NormedSpace ℝ E] in
include hint in
lemma path_integrable (x : Curve a b E) (t : Icc a b) :
    IntervalIntegrable (fun s => F s (extend hab x s)) volume a t := by
  apply (hint _ (extend_continuous hab x).continuousOn).mono_set
  rw [uIcc_of_le hab]
  exact uIcc_subset_Icc ⟨le_rfl, hab⟩ t.2

variable {K : ℝ≥0} (hlip : ∀ t ∈ Icc a b, LipschitzWith K (F t))
include hlip

lemma iterate_apply_bound (x y : Curve a b E) (n : ℕ) (t : Icc a b) :
    dist ((step hab F x₀ hint)^[n] x t) ((step hab F x₀ hint)^[n] y t) ≤
      (K * |t.1-a|)^n / n ! * dist x y := by
  induction n generalizing t with
  | zero => simpa using ContinuousMap.dist_apply_le_dist (f := x) (g := y) t
  | succ n hn =>
    rw [iterate_succ_apply', iterate_succ_apply', dist_eq_norm, step_apply,
      step_apply, add_sub_add_left_eq_sub,
      ← intervalIntegral.integral_sub (path_integrable hab F hint _ t)
        (path_integrable hab F hint _ t)]
    calc
      _ ≤ ∫ s in uIoc a t.1, K^(n+1) * |s-a|^n / n ! * dist x y := by
        rw [intervalIntegral.norm_intervalIntegral_eq]
        apply MeasureTheory.norm_integral_le_of_norm_le (Continuous.integrableOn_uIoc (by fun_prop))
        apply (ae_restrict_mem measurableSet_Ioc).mono
        intro s hs
        have hs' : s ∈ Icc a b :=
          (uIoc_subset_uIcc.trans (uIcc_subset_Icc ⟨le_rfl,hab⟩ t.2)) hs
        rw [← dist_eq_norm, show extend hab ((step hab F x₀ hint)^[n] x) s =
          (step hab F x₀ hint)^[n] x ⟨s,hs'⟩ from IccExtend_of_mem hab _ hs',
          show extend hab ((step hab F x₀ hint)^[n] y) s =
          (step hab F x₀ hint)^[n] y ⟨s,hs'⟩ from IccExtend_of_mem hab _ hs']
        calc
          _ ≤ K * dist ((step hab F x₀ hint)^[n] x ⟨s,hs'⟩)
              ((step hab F x₀ hint)^[n] y ⟨s,hs'⟩) := (hlip s hs').dist_le_mul _ _
          _ ≤ K^(n+1)*|s-a|^n/n !*dist x y := by
            rw [pow_succ', mul_assoc, mul_div_assoc, mul_assoc]
            gcongr
            simpa only [← mul_pow] using hn ⟨s,hs'⟩
      _ ≤ (K*|t.1-a|)^(n+1)/(n+1) !*dist x y := by
        apply le_of_abs_le
        rw [← intervalIntegral.abs_intervalIntegral_eq, intervalIntegral.integral_mul_const,
          intervalIntegral.integral_div, intervalIntegral.integral_const_mul, abs_mul, abs_div,
          abs_mul, intervalIntegral.abs_intervalIntegral_eq, integral_pow_abs_sub_uIoc, abs_div,
          abs_pow, abs_pow, abs_dist, NNReal.abs_eq, abs_abs, mul_div, div_div, ← abs_mul,
          ← Nat.cast_succ, ← Nat.cast_mul, ← Nat.factorial_succ, Nat.abs_cast, ← mul_pow]

lemma iterate_bound (x y : Curve a b E) (n : ℕ) :
    dist ((step hab F x₀ hint)^[n] x) ((step hab F x₀ hint)^[n] y) ≤
      (K*(b-a))^n/n !*dist x y := by
  apply (ContinuousMap.dist_le (by positivity)).mpr
  intro t
  apply (iterate_apply_bound hab F x₀ hint hlip x y n t).trans
  gcongr
  rw [abs_of_nonneg (sub_nonneg.mpr t.2.1)]
  exact sub_le_sub_right t.2.2 a

variable [CompleteSpace E]

theorem exists_unique_fixed_point :
    ∃ x : Curve a b E, IsFixedPt (step hab F x₀ hint) x ∧
      ∀ y, IsFixedPt (step hab F x₀ hint) y → y = x := by
  obtain ⟨n, hn⟩ := FloorSemiring.tendsto_pow_div_factorial_atTop (K*(b-a))
    |>.eventually (gt_mem_nhds zero_lt_one) |>.exists
  have hnon : 0 ≤ (K*(b-a))^n / (n ! : ℝ) := by positivity
  have hc : ContractingWith ⟨_,hnon⟩ (step hab F x₀ hint)^[n] :=
    ⟨hn, LipschitzWith.of_dist_le_mul (iterate_bound hab F x₀ hint hlip · · n)⟩
  refine ⟨_, hc.isFixedPt_fixedPoint_iterate, ?_⟩
  intro y hy
  exact hc.fixedPoint_unique (hy.iterate n)

end

noncomputable section
variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E] [CompleteSpace E]

def Solution (F : ℝ → E → E) (a b : ℝ) (x₀ : E) (x : ℝ → E) : Prop :=
  ContinuousOn x (Icc a b) ∧ x a = x₀ ∧
  IntervalIntegrable (fun t => F t (x t)) volume a b ∧
  ∀ t ∈ Icc a b, x t = x₀ + ∫ s in a..t, F s (x s)

theorem exists_unique_solution {a b : ℝ} (hab : a ≤ b)
    (F : ℝ → E → E) (x₀ : E) (K : ℝ≥0)
    (hint : ∀ x : ℝ → E, ContinuousOn x (Icc a b) →
      IntervalIntegrable (fun t => F t (x t)) volume a b)
    (hlip : ∀ t ∈ Icc a b, LipschitzWith K (F t)) :
    ∃ x, Solution F a b x₀ x ∧ ∀ y, Solution F a b x₀ y → EqOn y x (Icc a b) := by
  obtain ⟨x,hx,hunique⟩ := exists_unique_fixed_point hab F x₀ hint hlip
  have hxval (t : Icc a b) : x t = x₀ + ∫ s in a..t, F s (extend hab x s) :=
    (congrArg (fun q : Curve a b E => q t) hx).symm
  refine ⟨extend hab x, ⟨(extend_continuous hab x).continuousOn, ?_,
    hint _ (extend_continuous hab x).continuousOn, ?_⟩, ?_⟩
  · simpa [extend, IccExtend_left] using hxval ⟨a,le_rfl,hab⟩
  · intro t ht
    simpa [extend, IccExtend_of_mem hab _ ht] using hxval ⟨t,ht⟩
  · intro y hy
    let ycurve : Curve a b E := ⟨(Icc a b).domRestrict y,
      continuousOn_iff_continuous_domRestrict.mp hy.1⟩
    have hext (t : ℝ) (ht : t ∈ Icc a b) : extend hab ycurve t = y t :=
      IccExtend_of_mem hab ycurve ht
    have hfix : IsFixedPt (step hab F x₀ hint) ycurve := by
      ext t
      change x₀ + ∫ s in a..t.1, F s (extend hab ycurve s) = y t.1
      rw [hy.2.2.2 t.1 t.2]
      congr 1
      apply intervalIntegral.integral_congr
      intro s hs
      change F s (extend hab ycurve s) = F s (y s)
      rw [hext s (uIcc_subset_Icc ⟨le_rfl,hab⟩ t.2 hs)]
    have hxy := hunique ycurve hfix
    intro t ht
    have h := congrArg (fun q : Curve a b E => q ⟨t,ht⟩) hxy
    change y t = x ⟨t,ht⟩ at h
    change y t = extend hab x t
    rw [extend, IccExtend_of_mem hab _ ht]
    exact h

end
end Volterra
