import RescaleLoops

noncomputable section
namespace SignedVortex.Rescaled
open Set Filter MeasureTheory intervalIntegral NavierStokes NavierStokes.ProblemStatement
open scoped ContDiff Topology

theorem matches_at_one (u : VelocityField) (p : PressureField) (S : Space → ℝ)
    (k : Fin 3) (ε Γ c t : ℝ) :
    MatchesAt 1 u p S k ε Γ c t ↔ MatchesSignedAt u p S k ε Γ c t := by
  simp only [MatchesAt,MatchesSignedAt,NavierStokesR3.ProblemStatement.residual_at_viscosity_one]

private theorem pressure_component (p : PressureField) (t : ℝ) (x : Space) (j : Fin 3) :
    (pressureGradient p t x) j = fderiv ℝ (fun v => p (t,v)) x (coordinateVector j) := by
  fin_cases j <;> simp [pressureGradient,Fin.sum_univ_three,coordinateVector]

theorem matching_force_has_zero_loop (ν l : ℝ) (u : VelocityField) (p : PressureField)
    (S : Space → ℝ) {k j : Fin 3} (i : Fin 3) {ε Γ c t d : ℝ} (hjk : j ≠ k)
    (hp : ContDiff ℝ 1 (fun x => p (t,x)))
    (hper : ∀ x, p (t,x + coordinateVector j) = p (t,x))
    (hm : MatchesAt ν u p S k ε Γ c t) : lineIntegral ν l u t i j d = 0 := by
  let X := linePoint ν l i j d
  let P := fun y : ℝ => p (t,X y)
  let R := fun y : ℝ => fderiv ℝ (fun x => p (t,x)) (X y) (coordinateVector j)
  have hX (y : ℝ) : HasDerivAt X (coordinateVector j) y := by
    change HasDerivAt (fun y : ℝ => (width ν l * HLine.off d) • coordinateVector i + y • coordinateVector j) _ _
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
      dsimp [X,linePoint]
      module
    change p (t,X (1/2)) = p (t,X (-(1/2)))
    rw [hx,hper]
  have hz : (∫ y in (-(1/2):ℝ)..1/2, R y) = 0 := by
    rw [intervalIntegral.integral_eq_sub_of_hasDerivAt (fun y _ => hd y)
      (hR.intervalIntegrable _ _),hperiod,sub_self]
  have hzero : ∀ x : Space, pressureGradient (fun _ => 0) t x = 0 := by
    intro x; simp [pressureGradient]
  have eq (y : ℝ) : (NavierStokesR3.ProblemStatement.navierStokesResidual ν u (fun _ => 0) t (X y)) j = -R y := by
    have h := congrArg (fun v : Space => v j) (hm (X y))
    simp [coordinateVector, hjk] at h
    have he : NavierStokesR3.ProblemStatement.navierStokesResidual ν u p t (X y) =
        NavierStokesR3.ProblemStatement.navierStokesResidual ν u (fun _ => 0) t (X y) + pressureGradient p t (X y) := by
      simp only [NavierStokesR3.ProblemStatement.navierStokesResidual, hzero, add_zero]
    rw [he] at h
    change (NavierStokesR3.ProblemStatement.navierStokesResidual ν u (fun _ => 0) t (X y)) j + (pressureGradient p t (X y)) j = 0 at h
    rw [pressure_component] at h
    exact eq_neg_of_add_eq_zero_left h
  unfold lineIntegral
  change (∫ y in (-(1/2):ℝ)..1/2, (NavierStokesR3.ProblemStatement.navierStokesResidual ν u (fun _ => 0) t (X y)) j) = 0
  simp_rw [eq]
  rw [intervalIntegral.integral_neg,hz,neg_zero]


/-- The angular trace and its time and spatial derivatives vanish strictly outside
the cutoff cylinder. This places the known nonzero reading on the inward side. -/
theorem signal_zero_left {t d : ℝ} (hd : d < 0) : HLine.signal t d = 0 := by
  let C := BaseExterior.nominalHeatNormalization CorrectionInitialization.ActualPrimary.nominal
  let h := CorrectionInitialization.ActualPrimary.h
  let F := fun z : ℝ => shellTrace C h t (1/4-z)
  let D := fun z : ℝ => shellTime C h t (1/4-z) - deriv (deriv F) z
  have zeroD : D =ᶠ[𝓝 d] (fun _ => 0) := by
    filter_upwards [gt_mem_nhds hd] with z hz
    have zF : F =ᶠ[𝓝 z] (fun _ => 0) := by
      filter_upwards [gt_mem_nhds hz] with y hy
      exact shell_trace_zero_outside C h t (by linarith)
    have hw (y : ℝ) : shellWeight (1/4-z) y = 0 := by
      apply SmoothCutoffs.cutoff_zero_of_one_le
      nlinarith [sq_nonneg z,sq_nonneg y]
    dsimp only [D,shellTime]
    rw [zF.deriv.deriv_eq]
    simp only [hw,zero_mul,intervalIntegral.integral_zero]
    simp
  change deriv D d = 0
  rw [zeroD.deriv_eq]
  simp

theorem inward_signal {t : ℝ} (ht : t < 1) :
    ∃ d ∈ Ico (0:ℝ) (1/8), HLine.signal t d ≠ 0 := by
  obtain ⟨d,hd,hne⟩ := native_transverse_signal selected_normalization_positive
    CorrectionInitialization.ActualPrimary.outgoing.data.h_pos ht (ν := 1) (by norm_num)
  have hv : HLine.signal t d ≠ 0 := by simpa only [HLine.signal,one_mul] using hne
  exact ⟨d,⟨le_of_not_gt (fun hn => hv (signal_zero_left hn)),hd.2⟩,hv⟩

theorem opposite_nonzero_loops {a : ℕ → ℕ} (ha : LocalScheduleWitness.Selected a)
    {ν l : ℝ} (hν : 0 < ν) (hl : 1 < l) (hfit : width ν l < 2) :
    ∃ η : ℝ, 0 < η ∧ ∀ σ : ℝ, 0 < σ → σ < η →
      ∃ d ∈ Ico (0:ℝ) (1/8), BothReadings ν l a σ d ∧
        l^2 * ν * HLine.signal (1-l^2*σ) d ≠ 0 := by
  obtain ⟨η,hη,H⟩ := hline_any_fit ha hν hl hfit
  refine ⟨η,hη,?_⟩
  intro σ hσ hsmall
  have hl2 : 0 < l^2 := sq_pos_of_pos (zero_lt_one.trans hl)
  obtain ⟨d,hd,hn⟩ := inward_signal (show 1-l^2*σ < 1 by linarith [mul_pos hl2 hσ])
  exact ⟨d,hd,H σ hσ hsmall d hd,mul_ne_zero (mul_pos hl2 hν).ne' hn⟩

theorem late_exclusion {a : ℕ → ℕ} (ha : LocalScheduleWitness.Selected a)
    {ν l : ℝ} (hν : 0 < ν) (hl : 1 < l) (hfit : width ν l < 2) :
    ∃ η : ℝ, 0 < η ∧ ∀ σ : ℝ, 0 < σ → σ < η →
    ∀ (k : Fin 3) (ε Γ c : ℝ), ¬ ∃ (p : PressureField) (S : Space → ℝ),
      ContDiff ℝ 1 (fun x => p (1-σ,x)) ∧
      (∀ x j, p (1-σ,x+coordinateVector j) = p (1-σ,x)) ∧
      MatchesAt ν (torusVelocity ν l a) p S k ε Γ c (1-σ) := by
  obtain ⟨η,hη,H⟩ := opposite_nonzero_loops ha hν hl hfit
  refine ⟨η,hη,?_⟩
  intro σ hσ hsmall k ε Γ c
  rintro ⟨p,S,hp,hper,hm⟩
  obtain ⟨d,_,pair,hn'⟩ := H σ hσ hsmall
  by_cases hk : (1:Fin 3) ≠ k
  · have hz := matching_force_has_zero_loop ν l _ p S 0 (d := d) hk hp (fun x => hper x 1) hm
    exact hn' (pair.1.symm.trans hz)
  · have hk' : (0:Fin 3) ≠ k := by have := not_ne_iff.mp hk; omega
    have hz := matching_force_has_zero_loop ν l _ p S 1 (d := d) hk' hp (fun x => hper x 0) hm
    exact (neg_ne_zero.mpr hn') (pair.2.symm.trans hz)

theorem excludes_every_fitting_scale {a : ℕ → ℕ} (ha : LocalScheduleWitness.Selected a)
    {ν l : ℝ} (hν : 0 < ν) (hl : 1 < l)
    (hK : compactSet ν l ⊆ PeriodicPaper.fundamentalInterior) :
    noTrajectory ν (torusVelocity ν l a) := by
  intro k ε Γ c
  rintro ⟨p,S,hp,hper,hm⟩
  obtain ⟨η,hη,H⟩ := late_exclusion ha hν hl ((support_fits_iff hν (zero_lt_one.trans hl)).mp hK)
  let σ := min 1 η / 2
  have ht : 0 < σ := div_pos (lt_min zero_lt_one hη) (by norm_num)
  have hsmall : σ < η := by dsimp [σ]; linarith [min_le_right (1:ℝ) η]
  have hin : 1-σ ∈ Ioo (0:ℝ) 1 := by
    constructor <;> dsimp [σ] at * <;> linarith [min_le_left (1:ℝ) η]
  exact H σ ht hsmall k ε Γ c ⟨p,S (1-σ),hp _ hin,hper _ hin,hm _ hin⟩

end SignedVortex.Rescaled
