import PairTools

open Set MeasureTheory
open scoped NNReal
namespace SocialAS.Existence
noncomputable section

def sField (p : Parameters) (A forward reverse : ℝ → ℝ) (t : ℝ) (s : Pair) : Pair :=
  ![exchange p.wSmokeClay (reverse t) (s 1-s 0) + p.KSmoke*(p.kappa*A t)-p.decay*s 0,
    exchange p.wClaySmoke (forward t) (s 0-s 1) + p.KClay*(p.kappa*A t)-p.decay*s 1]

theorem influence_component_bound (w chi d source : ℝ) (hc : UnitInterval chi)
    (x y : Pair) (i j : Fin 2) :
    |(exchange w chi (x j-x i)+source-d*x i) -
      (exchange w chi (y j-y i)+source-d*y i)| ≤ (4*|w|+|d|)*dist x y := by
  have heq : (exchange w chi (x j-x i)+source-d*x i) -
      (exchange w chi (y j-y i)+source-d*y i) =
      (exchange w chi (x j-x i)-exchange w chi (y j-y i))-d*(x i-y i) := by ring
  rw [heq]
  have hi : |x i-y i| ≤ dist x y := dist_le_pi_dist x y i
  have hg := abs_gap_sub x y j i
  have he := abs_exchange_sub w chi (x j-x i) (y j-y i) hc
  have htri := abs_sub (exchange w chi (x j-x i)-exchange w chi (y j-y i)) (d*(x i-y i))
  rw [abs_mul] at htri
  have h1 := mul_le_mul_of_nonneg_left hg (by positivity : 0 ≤ 2*|w|)
  have h2 := mul_le_mul_of_nonneg_left hi (abs_nonneg d)
  nlinarith

theorem sfield_exists_unique {a b : ℝ} (hab : a ≤ b) (p : Parameters)
    (A forward reverse : ℝ → ℝ) (initial : Pair)
    (hA : ContinuousOn A (Icc a b)) (hF : ContinuousOn forward (Icc a b))
    (hR : ContinuousOn reverse (Icc a b))
    (hbF : ∀ t ∈ Icc a b, UnitInterval (forward t))
    (hbR : ∀ t ∈ Icc a b, UnitInterval (reverse t)) :
    ∃ s, Volterra.Solution (sField p A forward reverse) a b initial s ∧
      ∀ other, Volterra.Solution (sField p A forward reverse) a b initial other →
        EqOn other s (Icc a b) := by
  let K : ℝ≥0 := ⟨4*(|p.wSmokeClay|+|p.wClaySmoke|)+|p.decay|,by positivity⟩
  apply Volterra.exists_unique_solution hab _ initial K
  · intro x hx
    apply ContinuousOn.intervalIntegrable_of_Icc hab
    unfold sField exchange pos
    fun_prop
  · intro t ht
    apply LipschitzWith.of_dist_le_mul
    intro x y
    apply (dist_pi_le_iff (by positivity)).mpr
    intro j
    fin_cases j
    · change |(exchange p.wSmokeClay (reverse t) (x 1-x 0)+p.KSmoke*(p.kappa*A t)-p.decay*x 0)-
        (exchange p.wSmokeClay (reverse t) (y 1-y 0)+p.KSmoke*(p.kappa*A t)-p.decay*y 0)| ≤ _
      apply (influence_component_bound p.wSmokeClay (reverse t) p.decay _ (hbR t ht) x y 0 1).trans
      change (4*|p.wSmokeClay|+|p.decay|)*dist x y ≤
        (4*(|p.wSmokeClay|+|p.wClaySmoke|)+|p.decay|)*dist x y
      nlinarith [mul_nonneg (abs_nonneg p.wClaySmoke) (dist_nonneg (x := x) (y := y))]
    · change |(exchange p.wClaySmoke (forward t) (x 0-x 1)+p.KClay*(p.kappa*A t)-p.decay*x 1)-
        (exchange p.wClaySmoke (forward t) (y 0-y 1)+p.KClay*(p.kappa*A t)-p.decay*y 1)| ≤ _
      apply (influence_component_bound p.wClaySmoke (forward t) p.decay _ (hbF t ht) x y 1 0).trans
      change (4*|p.wClaySmoke|+|p.decay|)*dist x y ≤
        (4*(|p.wSmokeClay|+|p.wClaySmoke|)+|p.decay|)*dist x y
      nlinarith [mul_nonneg (abs_nonneg p.wSmokeClay) (dist_nonneg (x := x) (y := y))]

end
end SocialAS.Existence
