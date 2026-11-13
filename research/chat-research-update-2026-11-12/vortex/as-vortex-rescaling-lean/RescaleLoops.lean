import RescaleCovariance

noncomputable section
namespace SignedVortex.Rescaled
open Set NavierStokes NavierStokes.ProblemStatement


theorem timed_loops_with_support {a : ℕ → ℕ} (ha : LocalScheduleWitness.Selected a)
    {ν l r : ℝ} (hν : 0 < ν) (hl : 1 < l) (hfit : width ν l < 2)
    (hr : r < 1/2) (hsup : PeriodicLocalization.SupportedInCube r
      (PeriodicPaper.beforeOne (compact ν l a))) :
    ∃ η : ℝ, 0 < η ∧ ∀ σ : ℝ, 0 < σ → σ < η →
      ∀ d ∈ Ioo (-(1/16):ℝ) (1/8), |width ν l * HLine.off d| < 1-r →
        BothReadings ν l a σ d := by
  obtain ⟨T,hT,H⟩ := HLine.hline_both a
  have hl' : 0 < l := zero_lt_one.trans hl
  have hs : 0 < l^2 := sq_pos_of_pos hl'
  refine ⟨min 1 T / l^2,div_pos (lt_min zero_lt_one hT) hs,?_⟩
  intro σ hσ hsmall d hd hx
  have htime : l^2*σ < min 1 T := by
    simpa only [mul_comm σ] using (lt_div_iff₀ hs).mp hsmall
  have hpos : 0 < l^2*σ := mul_pos hs hσ
  have hin : NavierStokesR3.ParabolicScaling.clock l (1-σ) ∈ Ioo (0:ℝ) 1 := by
    rw [clock_at_remaining]
    exact ⟨by linarith [htime.trans_le (min_le_left 1 T)],by linarith⟩
  have hv := H _ hpos (htime.trans_le (min_le_right 1 T)) d hd
  have h01 := loop_transfer ha hν hl' hfit hr hsup (show 1-σ<1 by linarith) hin hd hx
    (show (0:Fin 3) ≠ 1 by decide)
  have h10 := loop_transfer ha hν hl' hfit hr hsup (show 1-σ<1 by linarith) hin hd hx
    (show (1:Fin 3) ≠ 0 by decide)
  rw [clock_at_remaining,hv.1] at h01
  rw [clock_at_remaining,hv.2,mul_neg] at h10
  exact ⟨h01,h10⟩

/-- Any scale fitting the entire native cylinder in the open cell admits both
identities on all offsets from the edge inward. -/
theorem hline_any_fit {a : ℕ → ℕ} (ha : LocalScheduleWitness.Selected a)
    {ν l : ℝ} (hν : 0 < ν) (hl : 1 < l) (hfit : width ν l < 2) :
    ∃ η : ℝ, 0 < η ∧ ∀ σ : ℝ, 0 < σ → σ < η →
      ∀ d ∈ Ico (0:ℝ) (1/8), BothReadings ν l a σ d := by
  have hl' := zero_lt_one.trans hl
  have hw := width_pos hν hl'
  obtain ⟨η,hη,H⟩ := timed_loops_with_support ha hν hl hfit
    (show width ν l/4 < 1/2 by linarith) (before_support hν hl' a)
  refine ⟨η,hη,?_⟩
  intro σ hσ ht d hd
  apply H σ hσ ht d ⟨by linarith [hd.1],hd.2⟩
  unfold HLine.off
  rw [abs_of_nonneg (mul_nonneg hw.le (by linarith [hd.2]))]
  nlinarith [mul_nonneg hw.le hd.1]

/-- The pinned compression additionally puts the velocity in the central quarter cube.
This gives both identities even on the exterior side of the entire original offset window. -/
theorem hline_pinned_quarter {a : ℕ → ℕ} (ha : LocalScheduleWitness.Selected a)
    {ν l : ℝ} (hν : 0 < ν) (hl : 1 < l)
    (hK : compactSet ν l ⊆ PeriodicPaper.fundamentalInterior)
    (hu : ∀ t < (1:ℝ), ∀ x : Space, compact ν l a (t,x) ≠ 0 → ∀ i, |x i| ≤ 1/4) :
    ∃ η : ℝ, 0 < η ∧ ∀ σ : ℝ, 0 < σ → σ < η →
      ∀ d ∈ Ioo (-(1/16):ℝ) (1/8), BothReadings ν l a σ d := by
  have hl' := zero_lt_one.trans hl
  have hf := (support_fits_iff hν hl').mp hK
  have hw := width_pos hν hl'
  obtain ⟨η,hη,H⟩ := timed_loops_with_support ha hν hl hf (by norm_num : (1/4:ℝ)<1/2)
    (PeriodicPaper.beforeOne_supported hu)
  refine ⟨η,hη,?_⟩
  intro σ hσ ht d hd
  apply H σ hσ ht d hd
  unfold HLine.off
  rw [abs_of_nonneg (mul_nonneg hw.le (by linarith [hd.2]))]
  have h : 1/4-d < (5/16:ℝ) := by linarith [hd.1]
  linarith [mul_lt_mul_of_pos_left h hw]

end SignedVortex.Rescaled
