import TraceSolution

noncomputable section
namespace SignedVortex
open Set MeasureTheory intervalIntegral NavierStokes NavierStokes.ProblemStatement
open scoped ContDiff Topology

private theorem pressure_component (p : PressureField) (t : ℝ) (x : Space) (j : Fin 3) :
    (pressureGradient p t x) j = fderiv ℝ (fun v => p (t,v)) x (coordinateVector j) := by
  fin_cases j <;> simp [pressureGradient,Fin.sum_univ_three,coordinateVector]

theorem matching_force_has_zero_loop (u : VelocityField) (p : PressureField)
    (S : Space → ℝ) {k j : Fin 3} (i : Fin 3) {ε Γ c t d : ℝ} (hjk : j ≠ k)
    (hp : ContDiff ℝ 1 (fun x => p (t,x)))
    (hper : ∀ x, p (t,x + coordinateVector j) = p (t,x))
    (hm : MatchesSignedAt u p S k ε Γ c t) : loopResidual u t i j d = 0 := by
  let X := loopPoint i j d
  let P := fun y : ℝ => p (t,X y)
  let R := fun y : ℝ => fderiv ℝ (fun x => p (t,x)) (X y) (coordinateVector j)
  have hX (y : ℝ) : HasDerivAt X (coordinateVector j) y := by
    change HasDerivAt (fun y : ℝ => (1/4-d) • coordinateVector i + y • coordinateVector j) _ _
    rw [hasDerivAt_const_add_iff]
    simpa only [one_smul] using ((hasDerivAt_id' y).smul_const (coordinateVector j))
  have hd (y : ℝ) : HasDerivAt P (R y) y :=
    ((hp.differentiable (by norm_num) (X y)).hasFDerivAt.comp_hasDerivAt y (hX y))
  have hR : Continuous R := by
    apply continuous_iff_continuousAt.mpr
    intro y
    exact ContinuousAt.comp (f := X) (((hp.continuous_fderiv (by norm_num)).clm_apply
      (continuous_const (y := coordinateVector j))).continuousAt) (hX y).continuousAt
  have hperiod : P (1/2) = P (-(1/2)) := by
    have hx : X (1/2) = X (-(1/2)) + coordinateVector j := by
      dsimp [X,loopPoint]
      module
    change p (t,X (1/2)) = p (t,X (-(1/2)))
    rw [hx,hper]
  have hz : (∫ y in (-(1/2):ℝ)..1/2, R y) = 0 := by
    rw [intervalIntegral.integral_eq_sub_of_hasDerivAt (fun y _ => hd y)
      (hR.intervalIntegrable _ _),hperiod,sub_self]
  have hzero : ∀ x : Space, pressureGradient (fun _ => 0) t x = 0 := by
    intro x; simp [pressureGradient]
  have eq (y : ℝ) : (navierStokesResidual u (fun _ => 0) t (X y)) j = -R y := by
    have h := congrArg (fun v : Space => v j) (hm (X y))
    simp [coordinateVector, hjk] at h
    have he : navierStokesResidual u p t (X y) =
        navierStokesResidual u (fun _ => 0) t (X y) + pressureGradient p t (X y) := by
      simp only [navierStokesResidual, hzero, add_zero]
    rw [he] at h
    change (navierStokesResidual u (fun _ => 0) t (X y)) j + (pressureGradient p t (X y)) j = 0 at h
    rw [pressure_component] at h
    exact eq_neg_of_add_eq_zero_left h
  unfold loopResidual
  change (∫ y in (-(1/2):ℝ)..1/2, (navierStokesResidual u (fun _ => 0) t (X y)) j) = 0
  simp_rw [eq]
  rw [intervalIntegral.integral_neg,hz,neg_zero]

/-- The only comparison identity assumed here is the identified transverse line
integral of the original pressure-free momentum residual for the selected field.
Either orientation of the two horizontal axes is admitted through the sign. -/
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
  rintro ⟨p,S,hp,hper,hm⟩
  obtain ⟨s,hs,hn⟩ := native_transverse_signal selected_normalization_positive
    CorrectionInitialization.ActualPrimary.outgoing.data.h_pos ht (ν := 1) (by norm_num)
  simp only [one_mul] at hn
  have hz := matching_force_has_zero_loop _ p S i (d := s) hj hp hper hm
  rw [hline s hs] at hz
  exact (mul_ne_zero ho hn) hz

end SignedVortex
