import RescaleSupport

noncomputable section
namespace SignedVortex.Rescaled
open Set Filter MeasureTheory intervalIntegral NavierStokes NavierStokes.ProblemStatement
open NavierStokesR3.ParabolicScaling NavierStokesR3.ViscosityScaling
open scoped Topology ContDiff

theorem clock_at_remaining (l σ : ℝ) : clock l (1-σ) = 1-l^2*σ := by unfold clock; ring

private theorem positive_clock_germ (a : ℕ → ℕ) (ν l : ℝ) {t : ℝ} (ht : 0 < clock l t) (x : Space) :
    compact ν l a =ᶠ[𝓝 (t,x)] pull l l (scaledVelocity ν (whole a)) := by
  have hc : Continuous (fun z : SpaceTime => clock l z.1) := by unfold clock; fun_prop
  filter_upwards [hc.continuousAt.eventually_const_lt ht] with z hz
  change l • zeroBefore (scaledVelocity ν (whole a)) (clock l z.1,l • z.2) = _
  simp [zeroBefore,pull,hz.le]

theorem viscous_raw (u : VelocityField) {ν : ℝ} (hν : 0 < ν) (t : ℝ) (x : Space) :
    NavierStokesR3.ProblemStatement.navierStokesResidual ν (scaledVelocity ν u) (fun _ => 0) t x =
      Real.sqrt ν • navierStokesResidual u (fun _ => 0) t ((Real.sqrt ν)⁻¹ • x) := by
  have hz : rescale ν (Real.sqrt ν)⁻¹ (fun _ : SpaceTime => (0:ℝ)) = (fun _ => 0) := by
    funext z; simp [rescale]
  simpa only [scaledVelocity,Real.sq_sqrt hν.le,mul_one,hz,
    NavierStokesR3.ProblemStatement.residual_at_viscosity_one] using
    (rescale_residual 1 (Real.sqrt ν) (Real.sqrt_pos.mpr hν).ne' u (fun _ => 0) t x)

set_option maxHeartbeats 1200000 in
theorem transformed_residual {a : ℕ → ℕ} (ha : LocalScheduleWitness.Selected a)
    {ν l r t : ℝ} (hν : 0 < ν) (ht : t < 1) (hclock : clock l t ∈ Ioo (0:ℝ) 1)
    (hsup : PeriodicLocalization.SupportedInCube r (PeriodicPaper.beforeOne (compact ν l a)))
    {x : Space} (hx : x ∈ PeriodicLocalization.innerCube r) :
    NavierStokesR3.ProblemStatement.navierStokesResidual ν (torusVelocity ν l a) (fun _ => 0) t x =
      (l^3 * Real.sqrt ν) • navierStokesResidual (whole a) (fun _ => 0) (clock l t) (zoom ν l • x) := by
  obtain ⟨f,hc⟩ := LocalScheduleWitness.selected_compact_candidate ha
  have hsmooth : ContDiffOn ℝ ∞ (scaledVelocity ν (whole a)) preSingularDomain :=
    rescale_smooth_on hc.velocity_smooth _ _
  have hat : ContDiffAt ℝ ∞ (scaledVelocity ν (whole a)) (clock l t, l • x) :=
    hsmooth.contDiffAt (prod_mem_nhds (Ico_mem_nhds hclock.1 hclock.2) univ_mem)
  have hdiff : DifferentiableAt ℝ (fun s => scaledVelocity ν (whole a) (s,l • x)) (clock l t) :=
    (hat.comp (clock l t) (contDiffAt_id.prodMk contDiffAt_const)).differentiableAt (by simp)
  have hg := ((PeriodicLocalization.periodize_eventuallyEq (z := (t,x)) hsup hx).trans
    (PeriodicPaper.beforeOne_eventuallyEq (compact ν l a) (z := (t,x)) ht)).trans (positive_clock_germ a ν l hclock.1 x)
  have hz : pull (l^2) l (fun _ : SpaceTime => (0:ℝ)) = (fun _ => 0) := by funext z; simp [pull]
  calc _ = NavierStokesR3.ProblemStatement.navierStokesResidual ν
            (pull l l (scaledVelocity ν (whole a))) (fun _ => 0) t x :=
          residual_congr ν hg (Filter.EventuallyEq.rfl (f := fun _ : SpaceTime => (0:ℝ)))
       _ = l^3 • NavierStokesR3.ProblemStatement.navierStokesResidual ν
            (scaledVelocity ν (whole a)) (fun _ => 0) (clock l t) (l • x) := by
          simpa only [hz] using pull_residual ν l (scaledVelocity ν (whole a)) (fun _ => 0) t x hdiff
       _ = _ := by rw [viscous_raw _ hν,smul_smul,scale_space]

/-- Extension or shortening of an interval carrying the compact original force
does not add an extra vortex. Both integration intervals contain its support. -/
theorem mapped_interval (a : ℕ → ℕ) {i j : Fin 3} (hij : i ≠ j) {t d α : ℝ}
    (hα : 1/2 < α) :
    (∫ y in α*(-(1/2):ℝ)..α*(1/2), originalSlice a t i j d y) =
      ∫ y in (-(1/2):ℝ)..1/2, originalSlice a t i j d y := by
  have hs := slice_support a t d hij
  have h1 : Function.support (originalSlice a t i j d) ⊆ Ioc (α*(-(1/2):ℝ)) (α*(1/2)) := by
    intro y hy; exact ⟨by linarith [(hs hy).1],by linarith [(hs hy).2]⟩
  have h2 : Function.support (originalSlice a t i j d) ⊆ Ioc (-(1/2):ℝ) (1/2) := by
    intro y hy; exact ⟨by linarith [(hs hy).1],by linarith [(hs hy).2]⟩
  rw [intervalIntegral.integral_eq_integral_of_support_subset h1, intervalIntegral.integral_eq_integral_of_support_subset h2]

theorem loop_transfer {a : ℕ → ℕ} (ha : LocalScheduleWitness.Selected a)
    {ν l r t d : ℝ} (hν : 0 < ν) (hl : 0 < l) (hfit : width ν l < 2)
    (hr : r < 1/2) (hsup : PeriodicLocalization.SupportedInCube r (PeriodicPaper.beforeOne (compact ν l a)))
    (ht : t < 1) (hclock : clock l t ∈ Ioo (0:ℝ) 1)
    (hd : d ∈ Ioo (-(1/16):ℝ) (1/8)) (hx : |width ν l * HLine.off d| < 1-r)
    {i j : Fin 3} (hij : i ≠ j) :
    lineIntegral ν l (torusVelocity ν l a) t i j d =
      l^2 * ν * loopResidual (HLine.vortex a) (clock l t) i j d := by
  let g := originalSlice a (clock l t) i j d
  have hc (y : ℝ) (hy : y ∈ uIcc (-(1/2):ℝ) (1/2)) :
      (NavierStokesR3.ProblemStatement.navierStokesResidual ν (torusVelocity ν l a) (fun _ => 0)
        t (linePoint ν l i j d y)) j = (l^3*Real.sqrt ν) * g (zoom ν l*y) := by
    rw [uIcc_of_le (by norm_num : (-(1/2):ℝ) ≤ 1/2)] at hy
    have hy' : |y| < 1-r := abs_lt.mpr ⟨by linarith [hy.1],by linarith [hy.2]⟩
    rw [transformed_residual ha hν ht hclock hsup (inner_line hij hx hy'),zoom_line ν l hν hl]
    rfl
  unfold lineIntegral
  rw [intervalIntegral.integral_congr hc,intervalIntegral.integral_const_mul,
    intervalIntegral.integral_comp_mul_left g (zoom_pos hν hl).ne']
  have hraw := (mapped_interval a hij (t := clock l t) (d := d) (half_lt_zoom hν hl hfit)).trans
    (compact_loop_is_old a (clock l t) hij hd)
  change l^3*Real.sqrt ν * ((zoom ν l)⁻¹ *
    (∫ y in zoom ν l*(-(1/2):ℝ)..zoom ν l*(1/2), originalSlice a (clock l t) i j d y)) = _
  rw [hraw,←mul_assoc]
  congr 1
  have hsq := Real.sq_sqrt hν.le
  unfold zoom; field_simp [hl.ne',(Real.sqrt_pos.mpr hν).ne']; nlinarith [hsq]

end SignedVortex.Rescaled
