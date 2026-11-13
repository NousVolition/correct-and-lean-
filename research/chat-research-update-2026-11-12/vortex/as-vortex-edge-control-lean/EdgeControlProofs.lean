import EdgeControlNative
import RescaleCorollary

noncomputable section
namespace SignedVortex.Rescaled.EdgeControl
open Set NavierStokes NavierStokes.ProblemStatement HLine

private theorem controls_from_transfer {a : ℕ → ℕ} {ν l : ℝ} (hν : 0 < ν) (hl : 1 < l)
    (transfer : ∃ η : ℝ, 0 < η ∧ ∀ σ : ℝ, 0 < σ → σ < η →
      ∀ d ∈ Ioo (-(1/16):ℝ) (1/8), BothReadings ν l a σ d) :
    SilentAndFaint ν l a := by
  obtain ⟨η,hη,read⟩ := transfer
  refine ⟨η,hη,?_⟩
  intro σ hσ hsmall
  have hl2 : 0 < l^2 := sq_pos_of_pos (zero_lt_one.trans hl)
  have ht : 1-l^2*σ < 1 := by linarith [mul_pos hl2 hσ]
  have hw : 0 < width ν l := width_pos hν (zero_lt_one.trans hl)
  constructor
  · intro d hd
    have hpair := read σ hσ hsmall d ⟨hd.1,by linarith [hd.2]⟩
    have hz : signal (1-l^2*σ) d = 0 := by
      rcases lt_or_eq_of_le hd.2 with hn | he
      · exact signal_zero_left hn
      · rw [he,edge_signal_zero]
    exact ⟨hpair.1.trans (by rw [hz,mul_zero]),hpair.2.trans (by rw [hz,mul_zero,neg_zero])⟩
  · intro b hb ε hε
    obtain ⟨d,hd,hD,hp,hsmallValue⟩ :=
      inward_small ht (mul_pos hl2 hν) (div_pos hb hw) hε
    have pair := read σ hσ hsmall d ⟨by linarith [hd.1],hd.2⟩
    have hy : yLoop ν l a σ d = l^2*ν*signal (1-l^2*σ) d := pair.1
    refine ⟨d,hd,?_,?_,?_,?_⟩
    · simpa only [mul_comm d] using (lt_div_iff₀ hw).mp hD
    · rwa [hy]
    · rwa [hy]
    · change xLoop ν l a σ d = -(yLoop ν l a σ d)
      rw [hy]
      exact pair.2

theorem control_for_pinned_scale {a : ℕ → ℕ} (ha : LocalScheduleWitness.Selected a)
    {ν l : ℝ} (hν : 0 < ν) (hl : 1 < l)
    (hK : compactSet ν l ⊆ PeriodicPaper.fundamentalInterior)
    (hu : ∀ t < (1:ℝ), ∀ x : Space, compact ν l a (t,x) ≠ 0 → ∀ i, |x i| ≤ 1/4) :
    SilentAndFaint ν l a :=
  controls_from_transfer hν hl (hline_pinned_quarter ha hν hl hK hu)

/-- The cutoff control and the nonzero readings belong to the same periodic
fields as the previously verified construction at every positive viscosity. -/
theorem every_viscosity_has_control (ν : ℝ) (hν : 0 < ν) :
    ∃ a : ℕ → ℕ, ∃ l : ℝ, ∃ f : VelocityField, FamilyWitness ν l a f ∧ SilentAndFaint ν l a := by
  obtain ⟨a,l,f,h⟩ := every_positive_viscosity ν hν
  rcases h with ⟨ha,hl,hK,hp,hglobal,hn,hr⟩
  exact ⟨a,l,f,⟨ha,hl,hK,hp,hglobal,hn,hr⟩,controls_from_transfer hν hl hr⟩

end SignedVortex.Rescaled.EdgeControl
