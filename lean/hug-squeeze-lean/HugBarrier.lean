import ActiveHugModel

open Set MeasureTheory intervalIntegral
namespace ActiveHug.Barrier

-- A continuous integral solution cannot cross below zero if its drift is
-- nonnegative throughout the negative half-line. No differentiability at
-- switching times is assumed.
theorem solution_nonnegative {F : ℝ → ℝ → ℝ} {a b x₀ : ℝ} {x : ℝ → ℝ}
    (hab : a ≤ b) (hx : IntegralSolution F a b x₀ x) (h₀ : 0 ≤ x₀)
    (hF : ∀ t ∈ Icc a b, ∀ y ≤ 0, 0 ≤ F t y) :
    ∀ t ∈ Icc a b, 0 ≤ x t := by
  intro t ht
  by_contra hn
  have hneg : x t < 0 := lt_of_not_ge hn
  have hcont : ContinuousOn x (Icc a t) := hx.1.mono (Icc_subset_Icc_right ht.2)
  have hxa : 0 ≤ x a := by rw [hx.2.1]; exact h₀
  obtain ⟨v,hv,hvz⟩ := intermediate_value_Icc' ht.1 hcont ⟨hneg.le,hxa⟩
  let zeros := Icc a t ∩ x ⁻¹' ({0} : Set ℝ)
  have hclosed : IsClosed zeros :=
    hcont.preimage_isClosed_of_isClosed isClosed_Icc isClosed_singleton
  have hcompact : IsCompact zeros := isCompact_Icc.of_isClosed_subset hclosed inter_subset_left
  have hnon : zeros.Nonempty := ⟨v,hv,hvz⟩
  obtain ⟨s,hs,hmax⟩ := hcompact.exists_isGreatest hnon
  have hsab : s ∈ Icc a b := ⟨hs.1.1,hs.1.2.trans ht.2⟩
  have hsz : x s = 0 := hs.2
  have hnonpos : ∀ u ∈ Icc s t, x u ≤ 0 := by
    intro u hu
    by_contra hnu
    have hupos : 0 < x u := lt_of_not_ge hnu
    have huat : u ∈ Icc a t := ⟨hs.1.1.trans hu.1,hu.2⟩
    obtain ⟨v,hv,hvz⟩ := intermediate_value_Icc' hu.2
      (hcont.mono (Icc_subset_Icc_left huat.1)) ⟨hneg.le,hupos.le⟩
    have hvzero : v ∈ zeros := ⟨⟨huat.1.trans hv.1,hv.2⟩,hvz⟩
    have hvle : v ≤ s := hmax hvzero
    have hueq : u = s := le_antisymm (hv.1.trans hvle) hu.1
    rw [hueq,hsz] at hupos
    exact (lt_irrefl 0) hupos
  have hint_t := hx.2.2.1.mono_set (show uIcc a t ⊆ uIcc a b by
    rw [uIcc_of_le hab]; exact uIcc_subset_Icc ⟨le_rfl,hab⟩ ht)
  have hint_s := hx.2.2.1.mono_set (show uIcc a s ⊆ uIcc a b by
    rw [uIcc_of_le hab]; exact uIcc_subset_Icc ⟨le_rfl,hab⟩ hsab)
  have hdiff : x t - x s = ∫ u in s..t, F u (x u) := by
    rw [hx.2.2.2 t ht,hx.2.2.2 s hsab,add_sub_add_left_eq_sub]
    exact integral_interval_sub_left hint_t hint_s
  have hpos : 0 ≤ ∫ u in s..t, F u (x u) :=
    intervalIntegral.integral_nonneg hs.1.2 fun u hu =>
      hF u ⟨hsab.1.trans hu.1,hu.2.trans ht.2⟩ (x u) (hnonpos u hu)
  rw [←hdiff,hsz,sub_zero] at hpos
  exact (not_lt_of_ge hpos) hneg

end ActiveHug.Barrier
