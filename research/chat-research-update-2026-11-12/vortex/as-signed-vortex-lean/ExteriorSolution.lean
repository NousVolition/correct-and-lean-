import NavierStokes.LocalPaperHeat
import NavierStokes.PaperLocalization
import NavierStokes.NaturalCore

noncomputable section
namespace SignedVortex
open Set Filter MeasureTheory intervalIntegral NavierStokes
open scoped Topology
open NavierStokes.ProblemStatement NavierStokes.CorrectionInitialization

/-- Identify the original potential used BEFORE multiplication by the spatial cutoff. -/
theorem selected_raw_exterior {a : ℕ → ℕ} {w : SpaceTime}
    (hw : w ∈ ActualExteriorPrefix.exteriorDomain LocalPaperDomain.residualBand)
    (hs : 0 < AxisymmetricFields.radialEnergy w.2)
    (hsmall : |(a 0 : ℝ) * PhysicalWaveSum.physicalQ ActualPrimary.h w| < 1/2)
    (hseg : ∀ s ∈ uIcc (1:ℝ) (AxisymmetricFields.radialEnergy w.2),
      (w.1,(s,w.2 2)) ∈ BaseExterior.exteriorDomain ActualPrimary.h
        (BaseExterior.nominalExteriorRadius ActualPrimary.nominal)) :
    LocalAngularGrowth.selectedPotential a w =
      TailGaugePotential.heatPotential (BaseExterior.nominalHeatNormalization ActualPrimary.nominal)
        ActualPrimary.h w ∧ LocalAngularGrowth.selectedDirect a w = 0 := by
  refine ⟨?_, LocalPotentialRebundle.selectedDirect_eq_zero hw⟩
  rw [LocalPotentialRebundle.selectedPotential_eq_base hw hsmall]
  apply TailGaugePotential.potential_eq_heatPotential
    (FinalSlowBase.scales_strictMono ActualPrimary.certificate ActualPrimary.modulation
      ActualPrimary.upper ActualCandidateConstruction.selectedBudget)
    ActualPrimary.outgoing.data.h_pos ActualPrimary.outgoing.data.h_lt_half
    (BaseExterior.nominalExteriorRadius_pos ActualPrimary.nominal).le
    (FinalSlowBase.coefficients_smooth ActualPrimary.certificate ActualPrimary.modulation)
  · exact ModulatedExterior.realized_exterior_coefficients ActualPrimary.nominal
      ActualPrimary.modulation.profiles ActualPrimary.modulation.finiteModification
      (FinalSlowBase.realizesScheme ActualPrimary.certificate ActualPrimary.modulation)
      (EntranceAlignedBase.modulated_base_eq ActualPrimary.certificate ActualPrimary.modulation)
      (EntranceAlignedBase.modulated_outer ActualPrimary.certificate ActualPrimary.modulation)
  · intro p hp
    exact ModulatedExterior.realized_angular_pure_heat ActualPrimary.nominal
      ActualPrimary.modulation.profiles ActualPrimary.modulation.finiteModification
      (FinalSlowBase.realizesScheme ActualPrimary.certificate ActualPrimary.modulation)
      (EntranceAlignedBase.modulated_base_eq ActualPrimary.certificate ActualPrimary.modulation) hp
  · exact hw.1.1
  · exact hs
  · exact hseg

theorem exterior_primitive_positive {C h t s z : ℝ} (hC : 0 < C) (hh : 0 < h)
    (ht : t < 1) (hs : 0 < s) (hs1 : s < 1) :
    0 < TailGaugePotential.heatPrimitive C h (t,(s,z)) := by
  rw [TailGaugePotential.heatPrimitive_eq_integral, intervalIntegral.integral_symm, neg_neg]
  apply intervalIntegral.intervalIntegral_pos_of_pos_on
  · apply ContinuousOn.intervalIntegrable_of_Icc hs1.le
    intro v hv
    have hpt : ContinuousAt (fun y : ℝ => (t,y,z)) v :=
      (continuous_const.prodMk (continuous_id.prodMk continuous_const)).continuousAt
    have hsmooth := (TailGaugePotential.extendedHeatCoefficient_smoothAt C hh
      (p := (t,(v,z))) (hs.trans_le hv.1)).continuousAt
    exact (ContinuousAt.comp (f := fun y : ℝ => (t,y,z)) hsmooth hpt).continuousWithinAt
  · intro v hv
    have hv0 := hs.trans hv.1
    rw [TailGaugePotential.extendedHeatCoefficient_eq C h ht.le hv0,BaseExterior.heatCoefficient_eq]
    unfold TerminalStress.physicalHeat RadialHeatProfile.spatialProfile
    exact div_pos (mul_pos hC (mul_pos (Real.rpow_pos_of_pos hv0 _)
      (RadialHeatProfile.profile_pos (by linarith)
        (div_nonneg (mul_nonneg (by norm_num) (sub_nonneg.mpr ht.le)) hv0.le))))
      (Real.sqrt_pos.2 (mul_pos (by norm_num) hv0))
  · exact hs1

theorem selected_normalization_positive :
    0 < BaseExterior.nominalHeatNormalization ActualPrimary.nominal :=
  PhysicalHeatCoordinates.normalization_pos _
    (BaseExterior.nominalHeatSwitch_pos ActualPrimary.nominal)

/-- If the native heat potential is identified on a neighborhood, the genuine periodic
localized velocity is its cutoff CURL, including every derivative of the cutoff. -/
theorem native_periodic_curl {a : ℕ → ℕ} {w : SpaceTime}
    (ht : 3/4 ≤ w.1) (hc : w.2 ∈ PeriodicLocalization.innerCube (1/4))
    (hA : LocalAngularGrowth.selectedPotential a =ᶠ[𝓝 w]
      TailGaugePotential.heatPotential (BaseExterior.nominalHeatNormalization ActualPrimary.nominal)
        ActualPrimary.h)
    (hD : LocalAngularGrowth.selectedDirect a w = 0) :
    R3CompactCandidate.periodicVelocity (LocalAngularGrowth.selectedPotential a)
      (LocalAngularGrowth.selectedDirect a) w =
    SpatialCurl.spatialCurl (SpatialLocalization.cutPotential
      (TailGaugePotential.heatPotential (BaseExterior.nominalHeatNormalization ActualPrimary.nominal)
        ActualPrimary.h)) w := by
  rw [(R3CompactCandidate.velocity_locally_eq _ _ w hc).self_of_nhds,
    R3CompactCandidate.velocity, TimeLocalization.activatedVelocity_eq_late _ ht]
  change SpatialCurl.spatialCurl _ w + SpatialLocalization.spatialCutoff w.2 •
    LocalAngularGrowth.selectedDirect a w = _
  rw [hD,smul_zero,add_zero]
  apply SolenoidalDiagonal.spatialCurl_eq_of_eventuallyEq
  filter_upwards [hA] with z hz
  exact congrArg (fun v : Space => SpatialLocalization.spatialCutoff z.2 • v) hz

/-- Increasing the radial energy at fixed height leaves q fixed, so an entire
integration segment from the exterior point to the anchor stays in the heat exterior. -/
private theorem segment_in_exterior {w : SpaceTime}
    (he : w ∈ BaseExterior.cartesianExterior ActualPrimary.h
      (BaseExterior.nominalExteriorRadius ActualPrimary.nominal))
    (hs : AxisymmetricFields.radialEnergy w.2 ≤ 1) :
    ∀ s ∈ uIcc (1:ℝ) (AxisymmetricFields.radialEnergy w.2),
      (w.1,(s,w.2 2)) ∈ BaseExterior.exteriorDomain ActualPrimary.h
        (BaseExterior.nominalExteriorRadius ActualPrimary.nominal) := by
  intro s hs'
  rw [uIcc_comm, uIcc_of_le hs] at hs'
  obtain ⟨ht,hx⟩ := he
  refine ⟨ht,lt_of_lt_of_le hx ?_⟩
  change AxisymmetricFields.radialEnergy w.2 / PhysicalWaveSum.physicalQ ActualPrimary.h w ≤
    s / PhysicalWaveSum.physicalQ ActualPrimary.h w
  exact div_le_div_of_nonneg_right hs'.1
    (PhysicalWaveSum.physicalQ_pos ActualPrimary.outgoing.data.h_pos ActualPrimary.outgoing.data.h_lt_half ht).le

/-- Any diagonal schedule has a real late-time strip in which the pinned compact
periodic target is exactly the curl of its cut heat potential. The coordinate b
bounds radial energy below, uniformly across the strip. -/
theorem actual_midplane_strip (a : ℕ → ℕ) {b : ℝ} (hb : 0 < b) :
    ∃ η : ℝ, 0 < η ∧ ∀ τ : ℝ, 0 < τ → τ < η →
      ∀ x : Space, x 2 = 0 → b ≤ AxisymmetricFields.radialEnergy x →
        AxisymmetricFields.radialEnergy x < 1 → x ∈ PeriodicLocalization.innerCube (1/4) →
        R3CompactCandidate.periodicVelocity (LocalAngularGrowth.selectedPotential a)
          (LocalAngularGrowth.selectedDirect a) (1-τ,x) =
        SpatialCurl.spatialCurl (SpatialLocalization.cutPotential
          (TailGaugePotential.heatPotential (BaseExterior.nominalHeatNormalization ActualPrimary.nominal)
            ActualPrimary.h)) (1-τ,x) := by
  let K := max 1 LocalPaperDomain.outerEdge
  have hK : 0 < K := lt_of_lt_of_le (by norm_num : (0:ℝ)<1) (le_max_left _ _)
  refine ⟨min (1/4) (min (LocalPaperDomain.qstar a) (b/K)),
    lt_min (by norm_num) (lt_min (LocalPaperDomain.qstar_pos a) (div_pos hb hK)), ?_⟩
  intro τ ht hη x hz hx hx1 hc
  have hh := ActualPrimary.outgoing.data.h_pos
  have hh1 := ActualPrimary.outgoing.data.h_lt_half
  have hτ : 1-τ < 1 := by linarith
  have hq : PhysicalWaveSum.physicalQ ActualPrimary.h (1-τ,x) = τ := by
    change NaturalCore.physicalQ ActualPrimary.h (1-τ, AxisymmetricFields.radialEnergy x,x 2) = τ
    rw [hz,NaturalCore.physicalQ_at_zero_z hh hh1 hτ]; ring
  have hqstar : PhysicalWaveSum.physicalQ ActualPrimary.h (1-τ,x) < LocalPaperDomain.qstar a := by
    rw [hq]; exact (lt_min_iff.mp (lt_min_iff.mp hη).2).1
  have hE : LocalPaperDomain.outerEdge ≤ LocalPaperDomain.radius (1-τ,x) := by
    change LocalPaperDomain.outerEdge ≤ AxisymmetricFields.radialEnergy x / PhysicalWaveSum.physicalQ ActualPrimary.h (1-τ,x)
    rw [hq]
    apply (le_div_iff₀ ht).2
    have htK := (lt_div_iff₀ hK).mp (lt_min_iff.mp (lt_min_iff.mp hη).2).2
    exact (mul_le_mul_of_nonneg_right (le_max_right 1 _) ht.le).trans (by nlinarith)
  obtain ⟨hw,he,hsmall⟩ := LocalPaperDomain.exterior_conditions hτ hqstar hE
  have hpos := hb.trans_le hx
  have hraw := selected_raw_exterior (a := a) hw hpos hsmall (segment_in_exterior he hx1.le)
  apply native_periodic_curl (by linarith [(lt_min_iff.mp hη).1]) hc _ hraw.2
  have hr : ContinuousAt (fun z : SpaceTime => AxisymmetricFields.radialEnergy z.2) (1-τ,x) := by
    exact ContinuousAt.comp (f := fun z : SpaceTime => z.2) (g := AxisymmetricFields.radialEnergy)
      (AxisymmetricFields.hasFDerivAt_radialEnergy x).continuousAt continuous_snd.continuousAt
  filter_upwards [LocalPaperDomain.exterior_conditions_eventually hw he hsmall,
    hr.eventually_lt_const hx1, hr.eventually_const_lt hpos] with z hz h1 hp
  exact (selected_raw_exterior (a := a) hz.1 hp hz.2.2 (segment_in_exterior hz.2.1 h1.le)).1

end SignedVortex
