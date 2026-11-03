import HugFullClaim
import ActiveHugSolution
import Mathlib.MeasureTheory.SpecificCodomains.Pi
import Mathlib.Analysis.ODE.ExistUnique

namespace ActiveHug.Full
open Set MeasureTheory intervalIntegral Metric
open scoped NNReal
noncomputable section

@[simp] theorem decode_encode (s : State) : decode (encode s) = s := by cases s; rfl
@[simp] theorem encode_decode (x : Vec) : encode (decode x) = x := by ext j; fin_cases j <;> rfl

@[fun_prop] theorem contDiff_sigmoid : ContDiff ℝ 1 sigmoid := by
  exact contDiff_const.div (contDiff_const.add contDiff_id.neg.exp)
    (fun x => ne_of_gt (by linarith [Real.exp_pos (-x)]))

theorem smooth_field (f : ℝ) : ContDiff ℝ 1 (field (fun _ => f) 0) := by
  apply contDiff_pi.mpr
  intro j
  fin_cases j <;> dsimp [field, encode, rhs, decode, protocol, stress,
    guardRate, targetAB, targetBA, strainSignal] <;> fun_prop

theorem continuous_path {a b : ℝ} {F : ℝ → ℝ} {x : ℝ → Vec}
    (hF : ContinuousOn F (Icc a b)) (hx : ContinuousOn x (Icc a b)) :
    ContinuousOn (fun t => field F t (x t)) (Icc a b) := by
  apply continuousOn_pi.mpr
  intro j
  have hs : Continuous sigmoid := contDiff_sigmoid.continuous
  fin_cases j <;> dsimp [field, encode, rhs, decode, protocol, stress,
    guardRate, targetAB, targetBA, strainSignal] <;> fun_prop

theorem force_translation (F : ℝ → ℝ) (t : ℝ) (x : Vec) :
    field F t x = field (fun _ => 0) 0 x + ![0,5*F t,0,0,0,0,0,0] := by
  ext j
  fin_cases j <;> norm_num [field, encode, rhs, decode, protocol] <;> ring

theorem field_lipschitz_ball (R : ℝ) : ∃ K : ℝ≥0, ∀ F t,
    LipschitzOnWith K (field F t) (closedBall (0 : Vec) R) := by
  obtain ⟨K,hK⟩ := (smooth_field 0).contDiffOn.exists_lipschitzOnWith (by norm_num)
    (convex_closedBall (0 : Vec) R) (isCompact_closedBall (0 : Vec) R)
  refine ⟨K, fun F t => ?_⟩
  apply LipschitzOnWith.of_dist_le_mul
  intro x hx y hy
  rw [force_translation F t x, force_translation F t y, dist_add_right]
  exact hK.dist_le_mul x hx y hy

theorem integral_coord {f : ℝ → Vec} {a b : ℝ}
    (hf : IntervalIntegrable f volume a b) (j : Fin 8) :
    (∫ t in a..b, f t) j = ∫ t in a..b, f t j :=
  ((ContinuousLinearMap.proj (R := ℝ) j).intervalIntegral_comp_comm hf).symm

theorem coord_solution {F : ℝ → Vec → Vec} {a b : ℝ} {x0 : Vec} {x : ℝ → Vec}
    (hab : a ≤ b) (hx : Volterra.Solution F a b x0 x) (j : Fin 8)
    (G : ℝ → ℝ → ℝ) (hG : ∀ t, G t (x t j) = F t (x t) j) :
    IntegralSolution G a b (x0 j) (fun t => x t j) := by
  refine ⟨by have := hx.1; fun_prop, congrArg (fun y : Vec => y j) hx.2.1, ?_, ?_⟩
  · simpa only [hG] using (show IntervalIntegrable (fun t => F t (x t) j) volume a b from ⟨hx.2.2.1.1.eval j,hx.2.2.1.2.eval j⟩)
  · intro t ht
    have hint := hx.2.2.1.mono_set (show uIcc a t ⊆ uIcc a b by
      rw [uIcc_of_le hab]; exact uIcc_subset_Icc ⟨le_rfl,hab⟩ ht)
    have he := congrArg (fun y : Vec => y j) (hx.2.2.2 t ht)
    change x t j = x0 j + (∫ s in a..t, F s (x s)) j at he
    simpa only [hG,integral_coord hint j] using he

-- A moving upper barrier for any scalar continuous integral solution.
theorem upper_barrier {F : ℝ → ℝ → ℝ} {a b x0 : ℝ} {x U dU : ℝ → ℝ}
    (hab : a ≤ b) (hx : IntegralSolution F a b x0 x)
    (hU : IntegralSolution (fun t _ => dU t) a b (U a) U)
    (h0 : x0 ≤ U a)
    (hF : ∀ t ∈ Icc a b, ∀ y, U t ≤ y → F t y ≤ dU t) :
    ∀ t ∈ Icc a b, x t ≤ U t := by
  have hsol : IntegralSolution (fun t y => dU t-F t (U t-y)) a b (U a-x0) (fun t => U t-x t) := by
    refine ⟨hU.1.sub hx.1, by change U a-x a = U a-x0; rw [hx.2.1], ?_, ?_⟩
    · simpa only [sub_sub_cancel] using hU.2.2.1.sub hx.2.2.1
    · intro t ht
      simp only [sub_sub_cancel]
      have hiU := hU.2.2.1.mono_set (show uIcc a t ⊆ uIcc a b by
        rw [uIcc_of_le hab]; exact uIcc_subset_Icc ⟨le_rfl,hab⟩ ht)
      have hix := hx.2.2.1.mono_set (show uIcc a t ⊆ uIcc a b by
        rw [uIcc_of_le hab]; exact uIcc_subset_Icc ⟨le_rfl,hab⟩ ht)
      rw [intervalIntegral.integral_sub hiU hix, hU.2.2.2 t ht, hx.2.2.2 t ht]
      ring
  have h := Barrier.solution_nonnegative hab hsol (sub_nonneg.mpr h0)
    (fun t ht y hy => sub_nonneg.mpr (hF t ht (U t-y) (by linarith)))
  exact fun t ht => sub_nonneg.mp (h t ht)

theorem lower_barrier {F : ℝ → ℝ → ℝ} {a b x0 : ℝ} {x L dL : ℝ → ℝ}
    (hab : a ≤ b) (hx : IntegralSolution F a b x0 x)
    (hL : IntegralSolution (fun t _ => dL t) a b (L a) L)
    (h0 : L a ≤ x0)
    (hF : ∀ t ∈ Icc a b, ∀ y, y ≤ L t → dL t ≤ F t y) :
    ∀ t ∈ Icc a b, L t ≤ x t := by
  have hn {G : ℝ → ℝ → ℝ} {z0 : ℝ} {z : ℝ → ℝ}
      (hz : IntegralSolution G a b z0 z) :
      IntegralSolution (fun t y => -G t (-y)) a b (-z0) (fun t => -z t) := by
    refine ⟨hz.1.neg, by change -z a = -z0; rw [hz.2.1], ?_, ?_⟩
    · apply hz.2.2.1.neg.congr
      intro t ht
      change -G t (z t) = -G t (-(-z t))
      rw [neg_neg]
    · intro t ht
      simp only [neg_neg, intervalIntegral.integral_neg]
      rw [hz.2.2.2 t ht]
      ring
  have h := upper_barrier hab (hn hx) (hn hL) (neg_le_neg h0)
    (fun t ht y hy => neg_le_neg (hF t ht (-y) (by linarith)))
  exact fun t ht => neg_le_neg_iff.mp (h t ht)
end
end ActiveHug.Full
