import EdgeControlProofs
import EdgeControlExterior

noncomputable section
namespace SignedVortex.Rescaled.EdgeControl.Examples
open Set NavierStokes NavierStokes.ProblemStatement

/-- A named silent exterior line and the exact edge are tested at the same
time as a nonzero reading in a 1%-wide strip below a 10⁻⁶ threshold. -/
theorem one_percent_probe {a : ℕ → ℕ} (ha : LocalScheduleWitness.Selected a)
    {ν l : ℝ} (hν : 0 < ν) (hl : 1 < l)
    (hK : compactSet ν l ⊆ PeriodicPaper.fundamentalInterior)
    (hu : ∀ t < (1:ℝ), ∀ x : Space, compact ν l a (t,x) ≠ 0 → ∀ i, |x i| ≤ 1/4) :
    ∃ η : ℝ, 0 < η ∧ ∀ σ : ℝ, 0 < σ → σ < η →
      (yLoop ν l a σ (-(1/32)) = 0 ∧ xLoop ν l a σ (-(1/32)) = 0) ∧
      (yLoop ν l a σ 0 = 0 ∧ xLoop ν l a σ 0 = 0) ∧
      ∃ d ∈ Ioo (0:ℝ) (1/8), width ν l*d < 1/100 ∧
        0 < |yLoop ν l a σ d| ∧ |yLoop ν l a σ d| < 1/1000000 ∧
        xLoop ν l a σ d = -yLoop ν l a σ d := by
  obtain ⟨η,hη,H⟩ := control_for_pinned_scale ha hν hl hK hu
  have hl' := zero_lt_one.trans hl
  have hfit := (support_fits_iff hν hl').mp hK
  have hd : (-(1/32):ℝ) ∈ Ioo (-(1/16):ℝ) 0 := by constructor <;> norm_num
  refine ⟨η,hη,?_⟩
  intro σ hσ hs
  obtain ⟨edge,inside⟩ := H σ hσ hs
  exact ⟨⟨exterior_from_support hν hl' hfit hu hd (1-σ) (by decide : (0:Fin 3) ≠ 1),
           exterior_from_support hν hl' hfit hu hd (1-σ) (by decide : (1:Fin 3) ≠ 0)⟩,
         edge 0 (by constructor <;> norm_num),
         inside (1/100) (by norm_num) (1/1000000) (by norm_num)⟩

#print axioms one_percent_probe

end SignedVortex.Rescaled.EdgeControl.Examples
