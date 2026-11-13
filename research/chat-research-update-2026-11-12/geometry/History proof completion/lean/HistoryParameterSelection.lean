import HistoryMatchCore

/-!
Exact parameter selection from the analytic hypotheses used in Proof.md.
The hypotheses are continuity of the reduced drift and a positive derivative
at the limiting field. They do not assert the desired irrational parameter.
Constructing the scalar PDE solutions and verifying these hypotheses for
their drift remain separate obligations.
-/
namespace HistoryParameterSelection
noncomputable section
open Set Filter
open scoped Topology

theorem exists_scaled_sqrt_two (upper : ℝ) (hu : 0 < upper) :
    ∃ N : ℕ, 0 < N ∧ 0 < Real.sqrt 2 / (N : ℝ) ∧
      Real.sqrt 2 / (N : ℝ) < upper ∧ Irrational (Real.sqrt 2 / (N : ℝ)) := by
  obtain ⟨N,hN⟩ := exists_nat_gt (max (1 : ℝ) (Real.sqrt 2 / upper))
  have hn1 : (1 : ℝ) < N := (le_max_left _ _).trans_lt hN
  have hn : 0 < N := by exact_mod_cast (lt_trans (by norm_num : (0 : ℝ) < 1) hn1)
  have hnR : (0 : ℝ) < N := by exact_mod_cast hn
  have hs : (0 : ℝ) < Real.sqrt 2 := Real.sqrt_pos.2 (by norm_num)
  have hquot : Real.sqrt 2 / upper < N := (le_max_right _ _).trans_lt hN
  have hsmall : Real.sqrt 2 / (N : ℝ) < upper := by
    apply (div_lt_iff₀ hnR).2
    have h := (div_lt_iff₀ hu).1 hquot
    nlinarith
  exact ⟨N,hn,div_pos hs hnR,hsmall,
    irrational_sqrt_two.div_natCast (Nat.ne_of_gt hn)⟩

theorem select_irrational_value (f : ℝ → ℝ) (upper : ℝ) (hu : 0 < upper)
    (hc : ContinuousOn f (Icc 0 upper)) (hzero : f 0 = 0) (hpos : 0 < f upper) :
    ∃ η : ℝ, ∃ N : ℕ, 0 < η ∧ η < upper ∧ 0 < N ∧
      f η = Real.sqrt 2 / (N : ℝ) ∧ 0 < f η ∧ Irrational (f η) := by
  obtain ⟨N,hN,hdpos,hdlt,hdirr⟩ := exists_scaled_sqrt_two (f upper) hpos
  have hd : Real.sqrt 2 / (N : ℝ) ∈ Icc (f 0) (f upper) := by
    exact ⟨by simpa [hzero] using hdpos.le, hdlt.le⟩
  obtain ⟨η,hη,hvalue⟩ := intermediate_value_Icc hu.le hc hd
  have hηpos : 0 < η := by
    rcases lt_or_eq_of_le hη.1 with h | h
    · exact h
    · have h' : η = 0 := h.symm
      rw [h',hzero] at hvalue
      linarith
  have hηlt : η < upper := by
    rcases lt_or_eq_of_le hη.2 with h | h
    · exact h
    · rw [h] at hvalue
      linarith
  refine ⟨η,N,hηpos,hηlt,hN,hvalue,?_,?_⟩
  · simpa [hvalue] using hdpos
  · simpa [hvalue] using hdirr

theorem positive_point_from_positive_derivative (f : ℝ → ℝ) (d r : ℝ)
    (hf : HasDerivAt f d 0) (hd : 0 < d) (hz : f 0 = 0) (hr : 0 < r) :
    ∃ x : ℝ, 0 < x ∧ x < r ∧ 0 < f x := by
  have hs : ∀ᶠ x in 𝓝[>] (0 : ℝ), 0 < slope f 0 x :=
    (hf.tendsto_slope.mono_left (nhdsGT_le_nhdsNE 0)).eventually
      (eventually_gt_nhds hd)
  have hlt : ∀ᶠ x in 𝓝[>] (0 : ℝ), x < r :=
    nhdsWithin_le_nhds (eventually_lt_nhds hr)
  have hpos : ∀ᶠ x in 𝓝[>] (0 : ℝ), 0 < x := self_mem_nhdsWithin
  obtain ⟨x,hxs,hxr,hxp⟩ := (hs.and (hlt.and hpos)).exists
  exact ⟨x,hxp,hxr,pos_of_slope_pos hxp hxs hz⟩

/-- The reduced drift E is D/ε with its continuous ε=0 extension.
The theorem selects both ε and η, strictly inside the supplied validity bound.
The result is an exact irrational number, not a rounded numerical witness. -/
theorem select_parameters (E : ℝ → ℝ → ℝ) (r d : ℝ) (hr : 0 < r)
    (hzero : ∀ ε, E ε 0 = 0)
    (hderiv : HasDerivAt (E 0) d 0) (hd : 0 < d)
    (hparameter : ∀ η, 0 < η → η < r → ContinuousAt (fun ε => E ε η) 0)
    (hslice : ∀ ε, 0 < ε → ε < r → ContinuousOn (E ε) (Icc 0 r)) :
    ∃ ε η : ℝ, ∃ N : ℕ, 0 < ε ∧ ε < r ∧ 0 < η ∧ η < r ∧ 0 < N ∧
      ε * E ε η = Real.sqrt 2 / (N : ℝ) ∧
      0 < ε * E ε η ∧ Irrational (ε * E ε η) := by
  obtain ⟨η₁,hηpos,hηlt,hE⟩ :=
    positive_point_from_positive_derivative (E 0) d r hderiv hd (hzero 0) hr
  have hevent : ∀ᶠ ε in 𝓝 (0 : ℝ), 0 < E ε η₁ :=
    (hparameter η₁ hηpos hηlt).eventually (eventually_gt_nhds hE)
  have hevent' : ∀ᶠ ε in 𝓝[>] (0 : ℝ), 0 < E ε η₁ :=
    nhdsWithin_le_nhds hevent
  have hsmall : ∀ᶠ ε in 𝓝[>] (0 : ℝ), ε < r :=
    nhdsWithin_le_nhds (eventually_lt_nhds hr)
  have hpositive : ∀ᶠ ε in 𝓝[>] (0 : ℝ), 0 < ε := self_mem_nhdsWithin
  obtain ⟨ε,hεE,hεlt,hεpos⟩ := (hevent'.and (hsmall.and hpositive)).exists
  have hc : ContinuousOn (fun η => ε * E ε η) (Icc 0 η₁) := by
    apply (hslice ε hεpos hεlt).const_mul ε |>.mono
    intro x hx
    exact ⟨hx.1,hx.2.trans hηlt.le⟩
  obtain ⟨η,N,hη0,hη1,hN,hvalue,hvaluepos,hvalueirr⟩ :=
    select_irrational_value (fun η => ε * E ε η) η₁ hηpos hc
      (by simp [hzero]) (mul_pos hεpos hεE)
  exact ⟨ε,η,N,hεpos,hεlt,hη0,hη1.trans hηlt,hN,hvalue,hvaluepos,hvalueirr⟩

theorem selected_parameters_preserve_validity (E : ℝ → ℝ → ℝ) (r d : ℝ)
    (Good : ℝ → ℝ → Prop) (hr : 0 < r)
    (hzero : ∀ ε, E ε 0 = 0)
    (hderiv : HasDerivAt (E 0) d 0) (hd : 0 < d)
    (hparameter : ∀ η, 0 < η → η < r → ContinuousAt (fun ε => E ε η) 0)
    (hslice : ∀ ε, 0 < ε → ε < r → ContinuousOn (E ε) (Icc 0 r))
    (hgood : ∀ ε η, 0 < ε → ε < r → 0 < η → η < r → Good ε η) :
    ∃ ε η : ℝ, ∃ N : ℕ, Good ε η ∧ 0 < N ∧
      ε * E ε η = Real.sqrt 2 / (N : ℝ) ∧ Irrational (ε * E ε η) := by
  obtain ⟨ε,η,N,hε0,hεr,hη0,hηr,hN,heq,hpos,hirr⟩ :=
    select_parameters E r d hr hzero hderiv hd hparameter hslice
  exact ⟨ε,η,N,hgood ε η hε0 hεr hη0 hηr,hN,heq,hirr⟩

#print axioms exists_scaled_sqrt_two
#print axioms select_irrational_value
#print axioms positive_point_from_positive_derivative
#print axioms select_parameters
#print axioms selected_parameters_preserve_validity
end
end HistoryParameterSelection
