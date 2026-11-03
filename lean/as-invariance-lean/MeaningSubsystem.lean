import PairTools
import InputRegularity

open Set MeasureTheory
open scoped NNReal
namespace SocialAS.Existence
noncomputable section

def zField (p : Parameters) (i : ℝ → Inputs)
    (kf kr tf tr : ℝ → ℝ) (t : ℝ) (z : Pair) : Pair :=
  ![meaningDrift (kr t) (receivedMeaning (tr t) (z 1) p.imposedReverse)
      (z 0) (i t).clarifySmoke p.refSmoke,
    meaningDrift (kf t) (receivedMeaning (tf t) (z 0) p.imposedForward)
      (z 1) (i t).clarifyClay p.refClay]

theorem meaning_component_bound (k theta imposed c ref W M : ℝ)
    (hk : 0 ≤ k) (hkW : k ≤ W) (ht : UnitInterval theta) (hc : |c| ≤ M)
    (x y : Pair) (i j : Fin 2) :
    |meaningDrift k (receivedMeaning theta (x j) imposed) (x i) c ref -
      meaningDrift k (receivedMeaning theta (y j) imposed) (y i) c ref| ≤
      (2*W+M)*dist x y := by
  have heq : meaningDrift k (receivedMeaning theta (x j) imposed) (x i) c ref -
      meaningDrift k (receivedMeaning theta (y j) imposed) (y i) c ref =
      k*((1-theta)*(x j-y j)-(x i-y i))-c*(x i-y i) := by
    unfold meaningDrift receivedMeaning
    ring
  rw [heq]
  have hi : |x i-y i| ≤ dist x y := dist_le_pi_dist x y i
  have hj : |x j-y j| ≤ dist x y := dist_le_pi_dist x y j
  have ht0 : 0 ≤ 1-theta := sub_nonneg.mpr ht.2
  have hinner := abs_sub ((1-theta)*(x j-y j)) (x i-y i)
  rw [abs_mul,abs_of_nonneg ht0] at hinner
  have hmul := mul_le_mul_of_nonneg_left hj ht0
  have hsmall := mul_nonneg ht.1 (dist_nonneg (x := x) (y := y))
  have hin : |(1-theta)*(x j-y j)-(x i-y i)| ≤ 2*dist x y := by nlinarith
  have hout := abs_sub (k*((1-theta)*(x j-y j)-(x i-y i))) (c*(x i-y i))
  rw [abs_mul,abs_mul,abs_of_nonneg hk] at hout
  have h1 := mul_le_mul_of_nonneg_left hin hk
  have h2 := mul_le_mul_of_nonneg_left hi (abs_nonneg c)
  have h3 := mul_le_mul_of_nonneg_right hkW (dist_nonneg (x := x) (y := y))
  have h4 := mul_le_mul_of_nonneg_right hc (dist_nonneg (x := x) (y := y))
  nlinarith

theorem zfield_exists_unique {a b : ℝ} (hab : a ≤ b) (p : Parameters)
    (i : ℝ → Inputs) (kf kr tf tr : ℝ → ℝ) (initial : Pair) (Wf Wr : ℝ≥0)
    (hKf : ContinuousOn kf (Icc a b)) (hKr : ContinuousOn kr (Icc a b))
    (hTf : ContinuousOn tf (Icc a b)) (hTr : ContinuousOn tr (Icc a b))
    (hbKf : ∀ t ∈ Icc a b, 0 ≤ kf t ∧ kf t ≤ Wf)
    (hbKr : ∀ t ∈ Icc a b, 0 ≤ kr t ∧ kr t ≤ Wr)
    (hbTf : ∀ t ∈ Icc a b, UnitInterval (tf t))
    (hbTr : ∀ t ∈ Icc a b, UnitInterval (tr t))
    (hC0 : SocialAS.Open.PiecewiseContinuousBounded (fun t => (i t).clarifySmoke) a b)
    (hC1 : SocialAS.Open.PiecewiseContinuousBounded (fun t => (i t).clarifyClay) a b) :
    ∃ z, Volterra.Solution (zField p i kf kr tf tr) a b initial z ∧
      ∀ other, Volterra.Solution (zField p i kf kr tf tr) a b initial other →
        EqOn other z (Icc a b) := by
  obtain ⟨M0,hm0⟩ := hC0.bound
  obtain ⟨M1,hm1⟩ := hC1.bound
  let K : ℝ≥0 := 2*(Wf+Wr)+M0+M1
  apply Volterra.exists_unique_solution hab _ initial K
  · intro x hx
    apply intervalIntegrable_fin_iff.mpr
    intro j
    fin_cases j
    · change IntervalIntegrable (fun t => kr t *
        ((1-tr t)*x t 1+tr t*p.imposedReverse-x t 0) +
        (i t).clarifySmoke*(p.refSmoke-x t 0)) volume a b
      apply IntervalIntegrable.add
      · apply ContinuousOn.intervalIntegrable_of_Icc hab
        fun_prop
      · apply (hC0.intervalIntegrable hab).mul_continuousOn
        rw [uIcc_of_le hab]
        fun_prop
    · change IntervalIntegrable (fun t => kf t *
        ((1-tf t)*x t 0+tf t*p.imposedForward-x t 1) +
        (i t).clarifyClay*(p.refClay-x t 1)) volume a b
      apply IntervalIntegrable.add
      · apply ContinuousOn.intervalIntegrable_of_Icc hab
        fun_prop
      · apply (hC1.intervalIntegrable hab).mul_continuousOn
        rw [uIcc_of_le hab]
        fun_prop
  · intro t ht
    apply LipschitzWith.of_dist_le_mul
    intro x y
    apply (dist_pi_le_iff (by positivity)).mpr
    intro j
    fin_cases j
    · change |meaningDrift (kr t) (receivedMeaning (tr t) (x 1) p.imposedReverse) (x 0) (i t).clarifySmoke p.refSmoke -
        meaningDrift (kr t) (receivedMeaning (tr t) (y 1) p.imposedReverse) (y 0) (i t).clarifySmoke p.refSmoke| ≤ _
      apply (meaning_component_bound _ _ _ _ _ Wr M0 (hbKr t ht).1 (hbKr t ht).2
        (hbTr t ht) (hm0 t ht) x y 0 1).trans
      change (2*(Wr : ℝ)+M0)*dist x y ≤
        (2*((Wf : ℝ)+Wr)+M0+M1)*dist x y
      apply mul_le_mul_of_nonneg_right _ dist_nonneg
      linarith [Wf.2,M1.2]
    · change |meaningDrift (kf t) (receivedMeaning (tf t) (x 0) p.imposedForward) (x 1) (i t).clarifyClay p.refClay -
        meaningDrift (kf t) (receivedMeaning (tf t) (y 0) p.imposedForward) (y 1) (i t).clarifyClay p.refClay| ≤ _
      apply (meaning_component_bound _ _ _ _ _ Wf M1 (hbKf t ht).1 (hbKf t ht).2
        (hbTf t ht) (hm1 t ht) x y 1 0).trans
      change (2*(Wf : ℝ)+M1)*dist x y ≤
        (2*((Wf : ℝ)+Wr)+M0+M1)*dist x y
      apply mul_le_mul_of_nonneg_right _ dist_nonneg
      linarith [Wr.2,M0.2]

end
end SocialAS.Existence
