import TimeIntegralDefs
import Mathlib.Analysis.Calculus.ParametricIntegral

namespace HugNavierSingle.EnergyEstimate
noncomputable section
open Set MeasureTheory Filter GuardTransport
open scoped Topology

/-- The pointwise chain rule uses exactly the existing PDE rates of both histories. -/
theorem difference_density_hasDerivAt (input : FieldInputs) (z w : ℝ → Fields)
    (pz pw : ℝ → ScalarField) (t : ℝ) (r : Point)
    (hz : FieldDifferentialAt input z pz t)
    (hw : FieldDifferentialAt input w pw t) :
    HasDerivAt (fun s => energy (differenceFields (z s) (w s)) r)
      (differenceRateDensity input t (z t) (w t) (pz t) (pw t) r) t := by
  rcases hz r with ⟨zu, zv, za, zb, zh, zj⟩
  rcases hw r with ⟨wu, wv, wa, wb, wh, wj⟩
  have hd := ((((((zu.sub wu).pow 2).add ((zv.sub wv).pow 2)).add
    ((za.sub wa).pow 2)).add ((zb.sub wb).pow 2)).add
    ((zh.sub wh).pow 2)).add ((zj.sub wj).pow 2) |>.div_const 2
  simp only [Pi.pow_def, Pi.add_def, Pi.sub_def, Nat.cast_ofNat, Nat.reduceSub, pow_one] at hd
  apply hd.congr_deriv
  dsimp only [differenceFields, differenceRateDensity]
  ring

private lemma cellIntegrableOn {f : ScalarField} (hf : ContinuousOn f closedCell) :
    Integrable f cellMeasure := by
  rw [cellMeasure, cellAxis, Measure.prod_restrict, ← Measure.volume_eq_prod]
  exact (hf.integrableOn_compact (isCompact_Icc.prod isCompact_Icc)).mono_set
    (Set.prod_mono Ioc_subset_Icc_self Ioc_subset_Icc_self)

private lemma ae_closedCell : ∀ᵐ r ∂cellMeasure, r ∈ closedCell := by
  rw [cellMeasure, cellAxis, Measure.prod_restrict, ← Measure.volume_eq_prod]
  exact (ae_restrict_mem (measurableSet_Ioc.prod measurableSet_Ioc)).mono
    (fun r hr => ⟨⟨hr.1.1.le, hr.1.2⟩, ⟨hr.2.1.le, hr.2.2⟩⟩)

private lemma cell_integral_hasDerivAt (F F' : ℝ → ScalarField) (a b t : ℝ)
    (ht : t ∈ Ioo a b)
    (hF : ∀ s ∈ Icc a b, Continuous (F s))
    (hF' : ContinuousOn (fun p : ℝ × Point => F' p.1 p.2) (timeCell a b))
    (hder : ∀ s ∈ Ioo a b, ∀ r, HasDerivAt (fun v => F v r) (F' s r) s) :
    Integrable (F' t) cellMeasure ∧
      HasDerivAt (fun s => ∫ r, F s r ∂cellMeasure) (∫ r, F' t r ∂cellMeasure) t := by
  have ht' : t ∈ Icc a b := ⟨ht.1.le, ht.2.le⟩
  have compact : IsCompact (timeCell a b) :=
    isCompact_Icc.prod (isCompact_Icc.prod isCompact_Icc)
  obtain ⟨B, hB⟩ := compact.bddAbove_image hF'.norm
  have rate_cont : ContinuousOn (F' t) closedCell :=
    hF'.comp (continuous_const.prodMk continuous_id).continuousOn (fun r hr => ⟨ht', hr⟩)
  have measurable : ∀ᶠ s in 𝓝 t, AEStronglyMeasurable (F s) cellMeasure := by
    filter_upwards [isOpen_Ioo.mem_nhds ht] with s hs
    exact (hF s ⟨hs.1.le, hs.2.le⟩).aestronglyMeasurable
  have bound : ∀ᵐ r ∂cellMeasure, ∀ s ∈ Ioo a b, ‖F' s r‖ ≤ |B| := by
    filter_upwards [ae_closedCell] with r hr
    intro s hs
    have bounded : ‖F' s r‖ ≤ B := hB (mem_image_of_mem
      (fun p : ℝ × Point => ‖F' p.1 p.2‖)
      (show (s, r) ∈ timeCell a b from ⟨⟨hs.1.le, hs.2.le⟩, hr⟩))
    exact bounded.trans (le_abs_self B)
  exact hasDerivAt_integral_of_dominated_loc_of_deriv_le
    (isOpen_Ioo.mem_nhds ht) measurable (cellIntegrableOn (hF t ht').continuousOn)
    (cellIntegrableOn rate_cont).aestronglyMeasurable bound
    (cellIntegrableOn continuous_const.continuousOn)
    (Eventually.of_forall (fun r s hs => hder s hs r))

private lemma continuous_difference_density (z w : Fields) (p q : ScalarField)
    (hz : SpatialRegularity z p) (hw : SpatialRegularity w q) :
    Continuous (fun r => energy (differenceFields z w) r) := by
  rcases hz with ⟨zu, zv, za, zb, zh, zj, zp⟩
  rcases hw with ⟨wu, wv, wa, wb, wh, wj, wp⟩
  exact ((((((zu.continuous.sub wu.continuous).pow 2).add
    ((zv.continuous.sub wv.continuous).pow 2)).add
    ((za.continuous.sub wa.continuous).pow 2)).add
    ((zb.continuous.sub wb.continuous).pow 2)).add
    ((zh.continuous.sub wh.continuous).pow 2)).add
    ((zj.continuous.sub wj.continuous).pow 2) |>.div_const 2

/-- The time derivative passes through the fixed cell integral at interior times,
under one explicit extra joint-continuity condition on the exact rate density.
No stress integration by parts or complete energy inequality is asserted. -/
theorem fieldproblem_energy_derivative_under_integral (input : FieldInputs) (a b : ℝ)
    (initial : Fields) (z w : ℝ → Fields) (pz pw : ℝ → ScalarField)
    (hz : FieldProblem input a b initial z pz)
    (hw : FieldProblem input a b initial w pw)
    (joint : JointDifferenceRateRegularity input z w pz pw a b)
    (t : ℝ) (ht : t ∈ Set.Ioo a b) :
    MeasureTheory.Integrable
      (differenceRateDensity input t (z t) (w t) (pz t) (pw t)) GuardTransport.cellMeasure ∧
    HasDerivAt (fun s => differenceEnergy (z s) (w s))
      (∫ r, differenceRateDensity input t (z t) (w t) (pz t) (pw t) r
        ∂GuardTransport.cellMeasure) t := by
  apply cell_integral_hasDerivAt
    (fun s r => energy (differenceFields (z s) (w s)) r)
    (fun s => differenceRateDensity input s (z s) (w s) (pz s) (pw s)) a b t ht
  · intro s hs
    exact continuous_difference_density (z s) (w s) (pz s) (pw s)
      (hz.2.2.1 s hs).1 (hw.2.2.1 s hs).1
  · exact joint
  · intro s hs r
    exact difference_density_hasDerivAt input z w pz pw s r (hz.2.2.2 s hs) (hw.2.2.2 s hs)

end
end HugNavierSingle.EnergyEstimate
