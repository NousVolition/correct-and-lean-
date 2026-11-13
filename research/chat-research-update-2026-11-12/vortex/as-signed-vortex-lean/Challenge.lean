import SignedDefinitions
import TraceDefinitions
import NavierStokes.LocalPaperHeat
import NavierStokes.PaperLocalization
import NavierStokes.NaturalCore

noncomputable section
namespace SignedVortex
open Set Filter MeasureTheory intervalIntegral NavierStokes
open NavierStokes.ProblemStatement NavierStokes.CorrectionInitialization
open scoped Topology ContDiff

theorem signed_flat_negative {ε Γ : ℝ} (hΓ : 0 < Γ) : signed ε (-Γ) < 0 := by
  sorry

theorem scalar_periodic (l : ℝ) : Function.Periodic (scalar l) 1 := by
  sorry

theorem scalar_gradient {l : ℝ} (hl : 0 ≤ l) (x : ℝ) :
    |deriv (scalar l) x| = l * gradientShape x := by
  sorry

theorem balanced_snapshot {ε Γ c : ℝ} (he : 0 < ε) (hg : 0 < Γ) (hc : 0 < c) :
    ∃ l : ℝ, Γ < l ∧ boxPush c ε Γ l = 0 ∧
      0 < -c * signed ε (|deriv (scalar l) (1/4)| - Γ) ∧
      -c * signed ε (|deriv (scalar l) 0| - Γ) < 0 := by
  sorry

theorem transverse_period (R P : ℝ → ℝ) (hP : ∀ y, HasDerivAt P (R y) y)
    (hR : Continuous R) (hperiod : P 1 = P 0) : (∫ y in (0:ℝ)..1, R y) = 0 := by
  sorry

theorem cutoff_line_obstruction (I I₁ I₂ Q : ℝ → ℝ) {L ν B : ℝ}
    (hν : 0 < ν) (_hB : 0 ≤ B)
    (hI : ContinuousOn I (Icc 0 L)) (hI₁ : ContinuousOn I₁ (Icc 0 L))
    (hd : ∀ s ∈ Ico 0 L, HasDerivAt I (I₁ s) s)
    (hdd : ∀ s ∈ Ico 0 L, HasDerivAt I₁ (I₂ s) s)
    (h0 : I 0 = 0) (h10 : I₁ 0 = 0)
    (hbound : ∀ s ∈ Ico 0 L, |Q s| ≤ B * |I s|)
    (hw : ∃ s ∈ Icc 0 L, I s ≠ 0) :
    ¬ ∀ s ∈ Ico 0 L, Q s = ν * I₂ s := by
  sorry

theorem balanced_active_shear {ε Γ c : ℝ} (he : 0 < ε) (hg : 0 < Γ) (hc : 0 < c) :
    ∃ l > Γ, boxPush c ε Γ l = 0 ∧
    ¬ ∃ P : ℝ → ℝ, P 1 = P 0 ∧
      ∀ y, HasDerivAt P (-c * signed ε (|deriv (scalar l) 0| - Γ)) y := by
  sorry

theorem transverse_line_balance (T N X Y dP P V : ℝ → ℝ) (ν : ℝ)
    (hT : Continuous T) (hN : Continuous N) (hX : Continuous X)
    (hY : Continuous Y) (hp : Continuous dP)
    (hOdd : ∀ y : ℝ, N (-y) = -N y)
    (hD : ∀ y, HasDerivAt P (dP y) y) (hV : ∀ y, HasDerivAt V (Y y) y)
    (hPper : P (1/2) = P (-1/2)) (hVper : V (1/2) = V (-1/2))
    (hmom : ∀ y, T y + N y = ν * (X y + Y y) - dP y) :
    (∫ y in (-(1/2):ℝ)..1/2, T y) = ν * ∫ y in (-(1/2):ℝ)..1/2, X y := by
  sorry

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
  sorry

theorem exterior_primitive_positive {C h t s z : ℝ} (hC : 0 < C) (hh : 0 < h)
    (ht : t < 1) (hs : 0 < s) (hs1 : s < 1) :
    0 < TailGaugePotential.heatPrimitive C h (t,(s,z)) := by
  sorry

theorem selected_normalization_positive :
    0 < BaseExterior.nominalHeatNormalization ActualPrimary.nominal := by
  sorry

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
  sorry

theorem actual_midplane_strip (a : ℕ → ℕ) {b : ℝ} (hb : 0 < b) :
    ∃ η : ℝ, 0 < η ∧ ∀ τ : ℝ, 0 < τ → τ < η →
      ∀ x : Space, x 2 = 0 → b ≤ AxisymmetricFields.radialEnergy x →
        AxisymmetricFields.radialEnergy x < 1 → x ∈ PeriodicLocalization.innerCube (1/4) →
        R3CompactCandidate.periodicVelocity (LocalAngularGrowth.selectedPotential a)
          (LocalAngularGrowth.selectedDirect a) (1-τ,x) =
        SpatialCurl.spatialCurl (SpatialLocalization.cutPotential
          (TailGaugePotential.heatPotential (BaseExterior.nominalHeatNormalization ActualPrimary.nominal)
            ActualPrimary.h)) (1-τ,x) := by
  sorry

theorem shell_weight_is_native (x : NavierStokes.ProblemStatement.Space) (hz : x 2 = 0) :
    SpatialLocalization.spatialCutoff x = shellWeight (x 0) (x 1) := by
  sorry

theorem shell_trace_zero_outside (C h t : ℝ) {x : ℝ} (hx : 1/4 ≤ x) :
    shellTrace C h t x = 0 := by
  sorry

theorem shell_trace_positive {C h t x : ℝ} (hC : 0 < C) (hh : 0 < h)
    (ht : t < 1) (hx : 1/8 ≤ x) (hx' : x < 1/4) : 0 < shellTrace C h t x := by
  sorry

theorem shell_time_relative_bound {C h t : ℝ} (hC : 0 < C) (hh : 0 < h) (ht : t < 1) :
    ∃ B : ℝ, 0 ≤ B ∧ ∀ x ∈ Icc (1/8:ℝ) (1/4),
      |shellTime C h t x| ≤ B * |shellTrace C h t x| := by
  sorry

theorem actual_trace_heat_fails {C h t ν : ℝ} (hC : 0 < C) (hh : 0 < h)
    (ht : t < 1) (hν : 0 < ν) (D₁ D₂ : ℝ → ℝ)
    (hJ : ContinuousOn (fun s => shellTrace C h t (1/4-s)) (Icc 0 (1/8)))
    (hD : ContinuousOn D₁ (Icc 0 (1/8)))
    (h₁ : ∀ s ∈ Ico 0 (1/8), HasDerivAt (fun z => shellTrace C h t (1/4-z)) (D₁ s) s)
    (h₂ : ∀ s ∈ Ico 0 (1/8), HasDerivAt D₁ (D₂ s) s)
    (hflat : D₁ 0 = 0) :
    ¬ ∀ s ∈ Ico 0 (1/8), shellTime C h t (1/4-s) = ν * D₂ s := by
  sorry

theorem native_trace_residual_nonzero {C h t ν : ℝ} (hC : 0 < C) (hh : 0 < h)
    (ht : t < 1) (hν : 0 < ν) :
    ∃ s ∈ Ico (0:ℝ) (1/8), shellTime C h t (1/4-s) ≠
      ν * deriv (deriv (fun z => shellTrace C h t (1/4-z))) s := by
  sorry

theorem shell_time_is_derivative (C h t x : ℝ) (hh : 0 < h) (hx : 0 < x) :
    HasDerivAt (fun u => shellTrace C h u x) (shellTime C h t x) t := by
  sorry

theorem edge_heat_equation_fails {C h t ν : ℝ} (hC : 0 < C) (hh : 0 < h)
    (ht : t < 1) (hν : 0 < ν) :
    ∃ d ∈ Ico (0:ℝ) (1/8),
      deriv (fun u => shellTrace C h u (1/4-d)) t ≠
        ν * deriv (deriv (fun z => shellTrace C h t (1/4-z))) d := by
  sorry

theorem native_transverse_signal {C h t ν : ℝ} (hC : 0 < C) (hh : 0 < h)
    (ht : t < 1) (hν : 0 < ν) :
    ∃ s ∈ Ioo (-(1/16):ℝ) (1/8),
      deriv (fun d => shellTime C h t (1/4-d) -
        ν * deriv (deriv (fun z => shellTrace C h t (1/4-z))) d) s ≠ 0 := by
  sorry

theorem pinned_vortex_edge_test (a : ℕ → ℕ) :
    let h := CorrectionInitialization.ActualPrimary.h
    let C := BaseExterior.nominalHeatNormalization CorrectionInitialization.ActualPrimary.nominal
    ∃ η : ℝ, 0 < η ∧ ∀ τ : ℝ, 0 < τ → τ < η →
      (∀ x : ProblemStatement.Space, x 2 = 0 → (1/128:ℝ) ≤ AxisymmetricFields.radialEnergy x →
        AxisymmetricFields.radialEnergy x < 1 → x ∈ PeriodicLocalization.innerCube (1/4) →
        R3CompactCandidate.periodicVelocity (LocalAngularGrowth.selectedPotential a)
          (LocalAngularGrowth.selectedDirect a) (1-τ,x) =
          SpatialCurl.spatialCurl (SpatialLocalization.cutPotential (TailGaugePotential.heatPotential C h))
            (1-τ,x)) ∧
      (∃ s ∈ Ioo (-(1/16):ℝ) (1/8), deriv (fun d => shellTime C h (1-τ) (1/4-d) -
        deriv (deriv (fun z => shellTrace C h (1-τ) (1/4-z))) d) s ≠ 0) := by
  sorry

theorem matching_force_has_zero_loop (u : VelocityField) (p : PressureField)
    (S : Space → ℝ) {k j : Fin 3} (i : Fin 3) {ε Γ c t d : ℝ} (hjk : j ≠ k)
    (hp : ContDiff ℝ 1 (fun x => p (t,x)))
    (hper : ∀ x, p (t,x + coordinateVector j) = p (t,x))
    (hm : MatchesSignedAt u p S k ε Γ c t) : loopResidual u t i j d = 0 := by
  sorry

theorem signed_target_excluded_if_line_identified (a : ℕ → ℕ) {i j k : Fin 3}
    (hj : j ≠ k) {t ε Γ c : ℝ} (ht : t < 1) (orientation : ℝ) (ho : orientation ≠ 0)
    (hline : ∀ s ∈ Ioo (-(1/16):ℝ) (1/8),
      loopResidual (R3CompactCandidate.periodicVelocity (LocalAngularGrowth.selectedPotential a)
        (LocalAngularGrowth.selectedDirect a)) t i j s =
      orientation * deriv (fun d =>
        shellTime (BaseExterior.nominalHeatNormalization CorrectionInitialization.ActualPrimary.nominal)
          CorrectionInitialization.ActualPrimary.h t (1/4-d) -
        deriv (deriv (fun z => shellTrace
          (BaseExterior.nominalHeatNormalization CorrectionInitialization.ActualPrimary.nominal)
          CorrectionInitialization.ActualPrimary.h t (1/4-z))) d) s) :
    ¬ ∃ (p : PressureField) (S : Space → ℝ), ContDiff ℝ 1 (fun x => p (t,x)) ∧
      (∀ x, p (t,x + coordinateVector j) = p (t,x)) ∧
      MatchesSignedAt (R3CompactCandidate.periodicVelocity (LocalAngularGrowth.selectedPotential a)
        (LocalAngularGrowth.selectedDirect a)) p S k ε Γ c t := by
  sorry

end SignedVortex
