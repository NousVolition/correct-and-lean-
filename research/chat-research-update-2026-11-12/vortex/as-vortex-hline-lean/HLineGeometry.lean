import HLineOperator

noncomputable section
namespace SignedVortex.HLine
open Set Filter NavierStokes NavierStokes.ProblemStatement NavierStokes.CorrectionInitialization
open scoped ContDiff Topology

abbrev nativeH := ActualPrimary.h
abbrev nativeC := BaseExterior.nominalHeatNormalization ActualPrimary.nominal
abbrev native (a : ℕ → ℕ) := R3CompactCandidate.periodicVelocity
  (LocalAngularGrowth.selectedPotential a) (LocalAngularGrowth.selectedDirect a)

structure Collar (a : ℕ → ℕ) (w : SpaceTime) : Prop where
  late : 3/4 < w.1
  before : w.1 < 1
  cube : w.2 ∈ PeriodicLocalization.innerCube (1/4)
  energy : 1/256 < AxisymmetricFields.radialEnergy w.2
  anchor : AxisymmetricFields.radialEnergy w.2 < 1
  height : |w.2 2| < 1/8
  scale : PhysicalWaveSum.physicalQ nativeH w < LocalPaperDomain.qstar a
  exterior : LocalPaperDomain.outerEdge < LocalPaperDomain.radius w

theorem collar_near {a : ℕ → ℕ} {w : SpaceTime} (hw : Collar a w) :
    ∀ᶠ z in 𝓝 w, Collar a z := by
  have hs : ContinuousAt (fun z : SpaceTime => AxisymmetricFields.radialEnergy z.2) w := by
    exact ContinuousAt.comp (f := fun z : SpaceTime => z.2) (g := AxisymmetricFields.radialEnergy)
      (AxisymmetricFields.hasFDerivAt_radialEnergy w.2).continuousAt continuous_snd.continuousAt
  have hz : ContinuousAt (fun z : SpaceTime => |z.2 2|) w :=
    ((AxisymmetricFields.projection 2).continuous.comp continuous_snd).abs.continuousAt
  have hc := (PhysicalWaveSum.physicalQ_smoothAt ActualPrimary.outgoing.data.h_pos
    ActualPrimary.outgoing.data.h_lt_half hw.before).continuousAt
  have hq := PhysicalWaveSum.physicalQ_pos ActualPrimary.outgoing.data.h_pos
    ActualPrimary.outgoing.data.h_lt_half hw.before
  have hr : ContinuousAt LocalPaperDomain.radius w := hs.div hc hq.ne'
  have hcube : ∀ᶠ z : SpaceTime in 𝓝 w, z.2 ∈ PeriodicLocalization.innerCube (1/4) :=
    continuous_snd.continuousAt ((PeriodicLocalization.isOpen_innerCube _).mem_nhds hw.cube)
  filter_upwards [continuous_fst.continuousAt.eventually_const_lt hw.late,
    continuous_fst.continuousAt.eventually_lt_const hw.before,hcube,
    hs.eventually_const_lt hw.energy,hs.eventually_lt_const hw.anchor,hz.eventually_lt_const hw.height,
    hc.eventually_lt_const hw.scale,hr.eventually_const_lt hw.exterior] with z h1 h2 h3 h4 h5 h6 h7 h8
  exact ⟨h1,h2,h3,h4,h5,h6,h7,h8⟩

private theorem outer_segment {w : SpaceTime}
    (he : w ∈ BaseExterior.cartesianExterior nativeH (BaseExterior.nominalExteriorRadius ActualPrimary.nominal))
    (hs : AxisymmetricFields.radialEnergy w.2 ≤ 1) :
    ∀ s ∈ uIcc (1:ℝ) (AxisymmetricFields.radialEnergy w.2), (w.1,(s,w.2 2)) ∈
      BaseExterior.exteriorDomain nativeH (BaseExterior.nominalExteriorRadius ActualPrimary.nominal) := by
  intro s hs'
  rw [uIcc_comm, uIcc_of_le hs] at hs'
  obtain ⟨ht,hx⟩ := he
  refine ⟨ht,lt_of_lt_of_le hx ?_⟩
  change AxisymmetricFields.radialEnergy w.2 / PhysicalWaveSum.physicalQ nativeH w ≤
    s / PhysicalWaveSum.physicalQ nativeH w
  exact div_le_div_of_nonneg_right hs'.1
    (PhysicalWaveSum.physicalQ_pos ActualPrimary.outgoing.data.h_pos ActualPrimary.outgoing.data.h_lt_half ht).le

private theorem raw {a : ℕ → ℕ} {w : SpaceTime} (hw : Collar a w) :
    LocalAngularGrowth.selectedPotential a w = TailGaugePotential.heatPotential nativeC nativeH w ∧
      LocalAngularGrowth.selectedDirect a w = 0 := by
  obtain ⟨h1,h2,h3⟩ := LocalPaperDomain.exterior_conditions hw.before hw.scale hw.exterior.le
  exact selected_raw_exterior h1 (by linarith [hw.energy]) h3 (outer_segment h2 hw.anchor.le)

private theorem height_free (C h t s z : ℝ) :
    TailGaugePotential.heatPrimitive C h (t,s,z) = TailGaugePotential.heatPrimitive C h (t,s,0) := by
  rw [TailGaugePotential.heatPrimitive_eq_integral,TailGaugePotential.heatPrimitive_eq_integral]
  rfl

private theorem cut_agrees {a : ℕ → ℕ} {w : SpaceTime} (hw : Collar a w) :
    SpatialLocalization.cutPotential (TailGaugePotential.heatPotential nativeC nativeH) w =
    AxisymmetricFields.potential 0 (liftProfile (radial nativeC nativeH)) w := by
  have hcut : SpatialLocalization.spatialCutoff w.2 =
      SmoothCutoffs.cutoff (32*AxisymmetricFields.radialEnergy w.2) := by
    have hh : |4 * w.2 2| ≤ 1/2 := by rw [abs_mul,abs_of_pos (by norm_num : (0:ℝ)<4)]; linarith [hw.height]
    simp only [SpatialLocalization.spatialCutoff,SpatialLocalization.cutoffProfile,
      SmoothCutoffs.cutoff_one_of_abs_le hh,mul_one]
    congr 1; unfold SpatialLocalization.radialSquare AxisymmetricFields.radialEnergy; ring
  simp only [SpatialLocalization.cutPotential,hcut,TailGaugePotential.heatPotential, AxisymmetricFields.potential,
    Pi.zero_apply,mul_zero,zero_smul,zero_add,AxisymmetricFields.profilePoint, liftProfile]
  change SmoothCutoffs.cutoff (32*AxisymmetricFields.radialEnergy w.2) •
    (TailGaugePotential.heatPrimitive nativeC nativeH (w.1,AxisymmetricFields.radialEnergy w.2,w.2 2) • coordinateVector 2) =
    radial nativeC nativeH (w.1,AxisymmetricFields.radialEnergy w.2) • coordinateVector 2
  rw [smul_smul,radial_eq _ _ hw.energy.le,height_free]

theorem native_is_spin {a : ℕ → ℕ} {w : SpaceTime} (hw : Collar a w) :
    native a =ᶠ[𝓝 w] spin (radial nativeC nativeH) := by
  filter_upwards [collar_near hw] with z hz
  have hn := collar_near hz
  have hA : LocalAngularGrowth.selectedPotential a =ᶠ[𝓝 z] TailGaugePotential.heatPotential nativeC nativeH :=
    hn.mono fun v hv => (raw hv).1
  change R3CompactCandidate.periodicVelocity _ _ z = _
  rw [native_periodic_curl hz.late.le hz.cube hA (raw hz).2]
  have hp := SolenoidalDiagonal.spatialCurl_eq_of_eventuallyEq (hn.mono fun v hv => cut_agrees hv)
  exact hp.trans (axial_curl_is_spin (radial_smooth _ _ ActualPrimary.outgoing.data.h_pos) _)

/-- One positive time window works for both complete lines, including their endpoints. -/
theorem late_loops (a : ℕ → ℕ) : ∃ η : ℝ, 0 < η ∧ ∀ τ : ℝ, 0 < τ → τ < η →
    ∀ d ∈ Ioo (-(1/16):ℝ) (1/8), ∀ y ∈ Icc (-(1/2):ℝ) (1/2),
      Collar a (1-τ,loopPoint 0 1 d y) ∧ Collar a (1-τ,loopPoint 1 0 d y) := by
  let K := max 1 LocalPaperDomain.outerEdge
  have hK : 0 < K := lt_of_lt_of_le (by norm_num : (0:ℝ) < 1) (le_max_left _ _)
  refine ⟨min (1/4) (min (LocalPaperDomain.qstar a) ((1/128)/K)),
    lt_min (by norm_num) (lt_min (LocalPaperDomain.qstar_pos a) (div_pos (by norm_num) hK)),?_⟩
  intro τ hτ hsmall d hd y hy
  have htq : 1-τ < 1 := by linarith
  have hx : 1/8 < off d := by dsimp [off]; linarith [hd.2]
  have hx1 : off d < 5/16 := by dsimp [off]; linarith [hd.1]
  have hsq : (1/128:ℝ) < shellEnergy (off d) y := by
    unfold shellEnergy; nlinarith [sq_nonneg y, mul_pos (by linarith : 0 < off d-1/8)
      (by linarith : 0 < off d+1/8)]
  have hse : shellEnergy (off d) y < 1 := by
    unfold shellEnergy; nlinarith [mul_nonneg (by linarith : 0 ≤ 5/16-off d) (by linarith : 0 ≤ 5/16+off d),
      mul_nonneg (by linarith [hy.1] : 0 ≤ 1/2+y) (by linarith [hy.2] : 0 ≤ 1/2-y)]
  have forPoint (x : Space) (hz : x 2 = 0) (hs : AxisymmetricFields.radialEnergy x = shellEnergy (off d) y)
      (hc : x ∈ PeriodicLocalization.innerCube (1/4)) : Collar a (1-τ,x) := by
    have hq : PhysicalWaveSum.physicalQ nativeH (1-τ,x) = τ := by
      change NaturalCore.physicalQ nativeH (1-τ,AxisymmetricFields.radialEnergy x,x 2) = τ
      rw [hz,NaturalCore.physicalQ_at_zero_z ActualPrimary.outgoing.data.h_pos
        ActualPrimary.outgoing.data.h_lt_half htq]; ring
    refine ⟨by linarith [(lt_min_iff.mp hsmall).1],htq,hc,by rw [hs]; linarith,hs ▸ hse,
      by norm_num [hz], ?_, ?_⟩
    · rw [hq]; exact (lt_min_iff.mp (lt_min_iff.mp hsmall).2).1
    · change LocalPaperDomain.outerEdge < AxisymmetricFields.radialEnergy x / PhysicalWaveSum.physicalQ nativeH (1-τ,x)
      rw [hq,hs]; apply (lt_div_iff₀ hτ).2
      have hτK := (lt_div_iff₀ hK).mp (lt_min_iff.mp (lt_min_iff.mp hsmall).2).2
      exact (mul_le_mul_of_nonneg_right (le_max_right 1 _) hτ.le).trans_lt (by nlinarith)
  rcases loop_coords d y with ⟨h1,h2,h3,h4,h5,h6⟩
  have cube (x : Space) (b0 : |x 0| < 1-1/4) (b1 : |x 1| < 1-1/4) (b2 : |x 2| < 1-1/4) :
      x ∈ PeriodicLocalization.innerCube (1/4) := by
    intro i; fin_cases i
    · exact b0
    · exact b1
    · exact b2
  have bx : |off d| < 1-1/4 := abs_lt.mpr ⟨by linarith,by linarith⟩
  have by' : |y| < 1-1/4 := abs_lt.mpr ⟨by linarith [hy.1],by linarith [hy.2]⟩
  constructor
  · refine forPoint _ h3 ?_ ?_
    · simp [AxisymmetricFields.radialEnergy,shellEnergy,h1,h2]
    · exact cube _ (by rwa [h1]) (by rwa [h2]) (by rw [h3]; norm_num)
  · refine forPoint _ h6 ?_ ?_
    · simp [AxisymmetricFields.radialEnergy,shellEnergy,h4,h5,add_comm (y^2) ((off d)^2)]
    · exact cube _ (by rwa [h4]) (by rwa [h5]) (by rw [h6]; norm_num)

end SignedVortex.HLine
