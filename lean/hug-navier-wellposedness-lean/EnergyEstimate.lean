import EnergyDefs
import GuardTransportTime

namespace HugNavierSingle.EnergyEstimate
noncomputable section
open Set MeasureTheory GuardTransport

private lemma cellIntegrable {f : ScalarField} (hf : Continuous f) : Integrable f cellMeasure := by
  rw [cellMeasure, cellAxis, Measure.prod_restrict, ← Measure.volume_eq_prod]
  exact (hf.continuousOn.integrableOn_compact (isCompact_Icc.prod isCompact_Icc)).mono_set
    (Set.prod_mono Ioc_subset_Icc_self Ioc_subset_Icc_self)

private lemma energy_split (z w : Fields) (p q : ScalarField)
    (hz : SpatialRegularity z p) (hw : SpatialRegularity w q) :
    differenceEnergy z w =
      ((∫ r, (z.ux r-w.ux r)^2 + (z.uy r-w.uy r)^2 ∂cellMeasure) +
       (∫ r, (z.xA r-w.xA r)^2 ∂cellMeasure) +
       (∫ r, (z.xB r-w.xB r)^2 ∂cellMeasure) +
       (∫ r, (z.gAB r-w.gAB r)^2 ∂cellMeasure) +
       (∫ r, (z.gBA r-w.gBA r)^2 ∂cellMeasure)) / 2 := by
  rcases hz with ⟨zu, zv, za, zb, zh, zj, zp⟩
  rcases hw with ⟨wu, wv, wa, wb, wh, wj, wp⟩
  have iu := cellIntegrable (((zu.continuous.sub wu.continuous).pow 2).add
    ((zv.continuous.sub wv.continuous).pow 2))
  have ia := cellIntegrable ((za.continuous.sub wa.continuous).pow 2)
  have ib := cellIntegrable ((zb.continuous.sub wb.continuous).pow 2)
  have ih := cellIntegrable ((zh.continuous.sub wh.continuous).pow 2)
  have ij := cellIntegrable ((zj.continuous.sub wj.continuous).pow 2)
  have e1 := integral_add iu ia
  have e2 := integral_add (iu.add ia) ib
  have e3 := integral_add ((iu.add ia).add ib) ih
  have e4 := integral_add (((iu.add ia).add ib).add ih) ij
  simp only [Pi.add_apply, Pi.sub_apply, Pi.pow_apply] at e1 e2 e3 e4
  simp only [differenceEnergy, differenceFields, energy]
  rw [integral_div, e4, e3, e2, e1]

/-- The two actual guard transport residuals are bounded by one constant times
the full six-field difference energy, at every time of the chosen interval.
This does not assert an energy derivative or a full evolution inequality. -/
theorem fieldproblem_guard_transport_energy_bound (input : FieldInputs) (a b : ℝ)
    (initial : Fields) (z w : ℝ → Fields) (pz pw : ℝ → ScalarField)
    (hz : FieldProblem input a b initial z pz)
    (hw : FieldProblem input a b initial w pw)
    (joint : GuardTransport.JointGuardGradientRegularity w a b) :
    ∃ Cg : ℝ, 0 ≤ Cg ∧ ∀ t ∈ Set.Icc a b,
      guardTransportMagnitude (z t) (w t) ≤ Cg * differenceEnergy (z t) (w t) := by
  obtain ⟨M, hM, bounds⟩ := fieldproblem_guard_transport_bounds input a b initial z w pz pw hz hw joint
  refine ⟨2 + M^2, by positivity, ?_⟩
  intro t ht
  let U := ∫ r, ((z t).ux r-(w t).ux r)^2 + ((z t).uy r-(w t).uy r)^2 ∂cellMeasure
  let A := ∫ r, ((z t).xA r-(w t).xA r)^2 ∂cellMeasure
  let B := ∫ r, ((z t).xB r-(w t).xB r)^2 ∂cellMeasure
  let H := ∫ r, ((z t).gAB r-(w t).gAB r)^2 ∂cellMeasure
  let J := ∫ r, ((z t).gBA r-(w t).gBA r)^2 ∂cellMeasure
  let E := differenceEnergy (z t) (w t)
  have split : E = (U + A + B + H + J) / 2 :=
    energy_split (z t) (w t) (pz t) (pw t) (hz.2.2.1 t ht).1 (hw.2.2.1 t ht).1
  have hu : 0 ≤ U := integral_nonneg (fun r => by positivity)
  have ha : 0 ≤ A := integral_nonneg (fun r => sq_nonneg _)
  have hb : 0 ≤ B := integral_nonneg (fun r => sq_nonneg _)
  have hh : 0 ≤ H := integral_nonneg (fun r => sq_nonneg _)
  have hj : 0 ≤ J := integral_nonneg (fun r => sq_nonneg _)
  have hvel : U ≤ 2 * E := by linarith
  have hguard : H + J ≤ 2 * E := by linarith
  obtain ⟨hab, hba⟩ := bounds t ht
  have hsum : guardTransportMagnitude (z t) (w t) ≤ U + M^2 * (H + J) / 2 := by
    unfold guardTransportMagnitude
    change _ ≤ (U + M^2 * H) / 2 at hab
    change _ ≤ (U + M^2 * J) / 2 at hba
    nlinarith only [hab, hba]
  calc
    guardTransportMagnitude (z t) (w t) ≤ U + M^2 * (H + J) / 2 := hsum
    _ ≤ 2 * E + M^2 * (2 * E) / 2 := by
      nlinarith only [hvel, mul_le_mul_of_nonneg_left hguard (sq_nonneg M)]
    _ = (2 + M^2) * differenceEnergy (z t) (w t) := by dsimp [E]; ring

end
end HugNavierSingle.EnergyEstimate
