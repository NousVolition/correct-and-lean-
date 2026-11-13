import SuppressionComparison

open Set MeasureTheory
namespace SocialAS.Verified
open SocialAS.Existence SocialAS.Suppression

-- Exactly the original target, without any additional premise.
theorem full_suppression_comparison : SocialAS.Open.FullSuppressionComparison := by
  unfold SocialAS.Open.FullSuppressionComparison
  intro p i a b initial suppressed baseline hp hi hr hab hinit hs hb
  rcases hp with ⟨hgamma,hkappa,hd,hwR,hwF,hKS,hKC,hKsum,hthreshold,hrstar,
    hg,hp0,heta,hbeta,halpha,hls,hms,hchi,htheta,himF,himR,hrefS,hrefC⟩
  have hA : ∀ t ∈ Icc a b, baseline t 0 = suppressed t 0 := by
    intro t ht
    rw [hb.2.2.2 0 t ht, hs.2.2.2 0 t ht]
    rfl
  have hLF : ∀ t ∈ Icc a b, 0 ≤ suppressed t 3 := by
    apply linear_solution_nonnegative hab
      (extract_scalar hab hs 3 (loadF p i) (by intros; rfl)) hinit.1
    · intro t ht
      have hind : 0 ≤ indicator (i t).adverseForward := by
        cases (i t).adverseForward <;> norm_num [indicator]
      exact mul_nonneg (mul_nonneg halpha hind) (hi t ht).1
    · intro t ht
      exact (hi t ht).2.2.1
  have hLR : ∀ t ∈ Icc a b, 0 ≤ suppressed t 4 := by
    apply linear_solution_nonnegative hab
      (extract_scalar hab hs 4 (loadR p i) (by intros; rfl)) hinit.2.1
    · intro t ht
      have hind : 0 ≤ indicator (i t).adverseReverse := by
        cases (i t).adverseReverse <;> norm_num [indicator]
      exact mul_nonneg (mul_nonneg halpha hind) (hi t ht).2.1
    · intro t ht
      exact (hi t ht).2.2.2.1
  let qSmoke := fun t => p.wSmokeClay * chiReverse p (suppressed t) *
    pos (suppressed t 2 - suppressed t 1)
  let qClay := fun t => p.wClaySmoke * chiForward p (suppressed t) *
    pos (suppressed t 1 - suppressed t 2)
  have hqSmoke : ∀ t ∈ Icc a b, 0 ≤ qSmoke t := by
    intro t ht
    exact mul_nonneg (mul_nonneg hwR
      (effect_bounds _ _ _ hchi (hLR t ht) hls).1) (le_max_right _ _)
  have hqClay : ∀ t ∈ Icc a b, 0 ≤ qClay t := by
    intro t ht
    exact mul_nonneg (mul_nonneg hwF
      (effect_bounds _ _ _ hchi (hLF t ht) hls).1) (le_max_right _ _)
  let dSmoke := fun t => baseline t 1 - suppressed t 1
  let dClay := fun t => baseline t 2 - suppressed t 2
  have hSmoke : Volterra.Solution
      (fun t r => p.wSmokeClay * (dClay t - r) - p.decay * r + qSmoke t)
      a b 0 dSmoke := by
    have h := solution_linear_combination hab
      (extract_scalar hab hb 1 (fun t _ => evolution {p with chiMax := 0} (i t) (baseline t) 1)
        (by intros; rfl))
      (extract_scalar hab hs 1 (fun t _ => evolution p (i t) (suppressed t) 1)
        (by intros; rfl)) (1 : ℝ) (-1 : ℝ)
      (H := fun t r => p.wSmokeClay * (dClay t - r) - p.decay * r + qSmoke t)
      (by
        intro t ht
        dsimp [evolution, smokeDrift, exchange, chiReverse, effect, source, qSmoke, dClay]
        rw [hA t ht]
        ring)
    simpa [dSmoke, sub_eq_add_neg] using h
  have hClay : Volterra.Solution
      (fun t r => p.wClaySmoke * (dSmoke t - r) - p.decay * r + qClay t)
      a b 0 dClay := by
    have h := solution_linear_combination hab
      (extract_scalar hab hb 2 (fun t _ => evolution {p with chiMax := 0} (i t) (baseline t) 2)
        (by intros; rfl))
      (extract_scalar hab hs 2 (fun t _ => evolution p (i t) (suppressed t) 2)
        (by intros; rfl)) (1 : ℝ) (-1 : ℝ)
      (H := fun t r => p.wClaySmoke * (dSmoke t - r) - p.decay * r + qClay t)
      (by
        intro t ht
        dsimp [evolution, clayDrift, exchange, chiForward, effect, source, qClay, dSmoke]
        rw [hA t ht]
        ring)
    simpa [dClay, sub_eq_add_neg] using h
  have hnonneg := cooperative_nonnegative hab hwR hwF hd.le hSmoke hClay
    (le_refl 0) (le_refl 0) hqSmoke hqClay
  intro t ht
  exact ⟨sub_nonneg.mp (hnonneg t ht).1, sub_nonneg.mp (hnonneg t ht).2⟩

end SocialAS.Verified

#print axioms SocialAS.Verified.full_suppression_comparison
