import ClippedConstruction

open Set MeasureTheory
namespace SocialAS.Invariance
open SocialAS.Existence
noncomputable section

theorem clipped_solution_bounds {p : Parameters} {i : ℝ → Inputs}
    {kf kr tf tr : ℝ → ℝ} {a b : ℝ} {initial : Pair} {z : ℝ → Pair}
    (hab : a ≤ b)
    (hz : Volterra.Solution (clippedField p i kf kr tf tr) a b initial z)
    (h₀ : ∀ j, UnitInterval (initial j))
    (hkf : ∀ t ∈ Icc a b, 0 ≤ kf t) (hkr : ∀ t ∈ Icc a b, 0 ≤ kr t)
    (htf : ∀ t ∈ Icc a b, UnitInterval (tf t))
    (htr : ∀ t ∈ Icc a b, UnitInterval (tr t))
    (hcs : ∀ t ∈ Icc a b, 0 ≤ (i t).clarifySmoke)
    (hcc : ∀ t ∈ Icc a b, 0 ≤ (i t).clarifyClay)
    (himf : UnitInterval p.imposedForward) (himr : UnitInterval p.imposedReverse)
    (hrefs : UnitInterval p.refSmoke) (hrefc : UnitInterval p.refClay) :
    ∀ t ∈ Icc a b, ∀ j, UnitInterval (z t j) := by
  have hs : ∀ t ∈ Icc a b, UnitInterval (z t 0) := by
    apply scalar_meaning_bounds hab
      (pair_scalar_solution hab hz 0
        (fun t y => meaningDrift (kr t)
          (receivedMeaning (tr t) (clip (z t 1)) p.imposedReverse)
          y (i t).clarifySmoke p.refSmoke) (by intros; rfl))
      (h₀ 0) hkr _ hcs hrefs
    intro t ht
    exact SocialAS.Verified.received_meaning_bounds _ _ _ (htr t ht) (clip_bounds _) himr
  have hc : ∀ t ∈ Icc a b, UnitInterval (z t 1) := by
    apply scalar_meaning_bounds hab
      (pair_scalar_solution hab hz 1
        (fun t y => meaningDrift (kf t)
          (receivedMeaning (tf t) (clip (z t 0)) p.imposedForward)
          y (i t).clarifyClay p.refClay) (by intros; rfl))
      (h₀ 1) hkf _ hcc hrefc
    intro t ht
    exact SocialAS.Verified.received_meaning_bounds _ _ _ (htf t ht) (clip_bounds _) himf
  intro t ht j
  fin_cases j
  · exact hs t ht
  · exact hc t ht

theorem original_of_clipped {p : Parameters} {i : ℝ → Inputs}
    {kf kr tf tr : ℝ → ℝ} {a b : ℝ} {initial : Pair} {z : ℝ → Pair}
    (hab : a ≤ b)
    (hz : Volterra.Solution (clippedField p i kf kr tf tr) a b initial z)
    (hb : ∀ t ∈ Icc a b, ∀ j, UnitInterval (z t j)) :
    Volterra.Solution (zField p i kf kr tf tr) a b initial z := by
  have heq : ∀ t ∈ Icc a b,
      clippedField p i kf kr tf tr t (z t) = zField p i kf kr tf tr t (z t) := by
    intro t ht
    simp only [clippedField, zField, clip_eq (hb t ht 0), clip_eq (hb t ht 1)]
  refine ⟨hz.1,hz.2.1,?_,?_⟩
  · apply hz.2.2.1.congr
    intro t ht
    exact heq t ((uIoc_subset_uIcc.trans (by rw [uIcc_of_le hab])) ht)
  · intro t ht
    rw [hz.2.2.2 t ht]
    congr 1
    apply intervalIntegral.integral_congr
    intro s hs
    exact heq s (uIcc_subset_Icc ⟨le_rfl,hab⟩ ht hs)

-- This is a property of every solution of the ORIGINAL zField. The auxiliary
-- projection has been eliminated by original_of_clipped and uniqueness.
theorem stages_state_bounds {p : Parameters} {i : ℝ → Inputs} {a b : ℝ}
    {initial : State} (st : Stages p i a b initial)
    (hp : ParametersOK p) (hi : ∀ t ∈ Icc a b, InputsOK (i t))
    (hr : SocialAS.Open.RegularInputs i a b) (hab : a ≤ b) (hx : StateOK initial) :
    ∀ t ∈ Icc a b, StateOK (assemble st t) := by
  rcases hp with ⟨hgamma,hkappa,hd,hwR,hwF,hKS,hKC,hKsum,hthreshold,hrstar,
    hg,hp0,heta,hbeta,halpha,hls,hms,hchi,htheta,himF,himR,hrefS,hrefC⟩
  rcases hr with ⟨hu,heF,heR,hcF,hcR,hzS,hzC⟩
  have hFn : ∀ t ∈ Icc a b, 0 ≤ st.LF t := by
    apply linear_solution_nonnegative hab st.hLF.1 hx.1
    · intro t ht
      have hi0 : 0 ≤ indicator (i t).adverseForward := by cases (i t).adverseForward <;> norm_num [indicator]
      exact mul_nonneg (mul_nonneg halpha hi0) (hi t ht).1
    · intro t ht
      exact (hi t ht).2.2.1
  have hRn : ∀ t ∈ Icc a b, 0 ≤ st.LR t := by
    apply linear_solution_nonnegative hab st.hLR.1 hx.2.1
    · intro t ht
      have hi0 : 0 ≤ indicator (i t).adverseReverse := by cases (i t).adverseReverse <;> norm_num [indicator]
      exact mul_nonneg (mul_nonneg halpha hi0) (hi t ht).2.1
    · intro t ht
      exact (hi t ht).2.2.2.1
  have hCF : ContinuousOn (chi p st.LF) (Icc a b) := effect_continuousOn st.hLF.1.1 hFn hls
  have hCR : ContinuousOn (chi p st.LR) (Icc a b) := effect_continuousOn st.hLR.1.1 hRn hls
  have hTF : ContinuousOn (theta p st.LF) (Icc a b) := effect_continuousOn st.hLF.1.1 hFn hls
  have hTR : ContinuousOn (theta p st.LR) (Icc a b) := effect_continuousOn st.hLR.1.1 hRn hls
  have hbCF : ∀ t ∈ Icc a b, UnitInterval (chi p st.LF t) :=
    fun t ht => SocialAS.Verified.effect_bounds _ _ _ hchi (hFn t ht) hls
  have hbCR : ∀ t ∈ Icc a b, UnitInterval (chi p st.LR t) :=
    fun t ht => SocialAS.Verified.effect_bounds _ _ _ hchi (hRn t ht) hls
  have hbTF : ∀ t ∈ Icc a b, UnitInterval (theta p st.LF t) :=
    fun t ht => SocialAS.Verified.effect_bounds _ _ _ htheta (hFn t ht) hls
  have hbTR : ∀ t ∈ Icc a b, UnitInterval (theta p st.LR t) :=
    fun t ht => SocialAS.Verified.effect_bounds _ _ _ htheta (hRn t ht) hls
  have hSc0 : ContinuousOn (fun t => st.S t 0) (Icc a b) := (continuous_apply 0).comp_continuousOn st.hS.1.1
  have hSc1 : ContinuousOn (fun t => st.S t 1) (Icc a b) := (continuous_apply 1).comp_continuousOn st.hS.1.1
  have hkF : ContinuousOn (rateF p st.LF st.S) (Icc a b) := rate_continuousOn hCF hSc0 hms
  have hkR : ContinuousOn (rateR p st.LR st.S) (Icc a b) := rate_continuousOn hCR hSc1 hms
  have hbkF : ∀ t ∈ Icc a b, 0 ≤ rateF p st.LF st.S t ∧ rateF p st.LF st.S t ≤ p.wClaySmoke :=
    fun t ht => SocialAS.Verified.meaning_rate_bounds _ _ _ _ hwF (hbCF t ht) hms
  have hbkR : ∀ t ∈ Icc a b, 0 ≤ rateR p st.LR st.S t ∧ rateR p st.LR st.S t ≤ p.wSmokeClay :=
    fun t ht => SocialAS.Verified.meaning_rate_bounds _ _ _ _ hwR (hbCR t ht) hms
  obtain ⟨q,hq⟩ := clipped_exists_unique hab p i (rateF p st.LF st.S) (rateR p st.LR st.S)
    (theta p st.LF) (theta p st.LR) ![initial 5,initial 6] ⟨p.wClaySmoke,hwF⟩ ⟨p.wSmokeClay,hwR⟩
    hkF hkR hTF hTR hbkF hbkR hbTF hbTR hzS hzC
  have hinit : ∀ j : Fin 2, UnitInterval (![initial 5,initial 6] j) := by
    intro j
    fin_cases j
    · exact hx.2.2.1
    · exact hx.2.2.2
  have hqb := clipped_solution_bounds hab hq.1 hinit
    (fun t ht => (hbkF t ht).1) (fun t ht => (hbkR t ht).1) hbTF hbTR
    (fun t ht => (hi t ht).2.2.2.2.1) (fun t ht => (hi t ht).2.2.2.2.2)
    himF himR hrefS hrefC
  have heq : EqOn q st.Z (Icc a b) := st.hZ.2 q (original_of_clipped hab hq.1 hqb)
  intro t ht
  have h0 : UnitInterval (st.Z t 0) := by rw [←heq ht]; exact hqb t ht 0
  have h1 : UnitInterval (st.Z t 1) := by rw [←heq ht]; exact hqb t ht 1
  exact ⟨hFn t ht,hRn t ht,h0,h1⟩

end
end SocialAS.Invariance
