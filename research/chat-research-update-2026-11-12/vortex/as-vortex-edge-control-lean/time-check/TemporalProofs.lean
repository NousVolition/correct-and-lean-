import TemporalStatements
import RescaleForcing

noncomputable section
namespace SignedVortex.Rescaled.TimeControl
open Set Filter MeasureTheory intervalIntegral NavierStokes NavierStokes.ProblemStatement
open NavierStokesR3.ParabolicScaling
open scoped Topology

private theorem before_clock {l t : ℝ} (hl : 1 < l) (ht : t < startTime l) :
    clock l t < 0 := by
  have hl2 : 0 < l^2 := sq_pos_of_pos (zero_lt_one.trans hl)
  change t < 1-1/l^2 at ht
  have hb : 1/l^2 < 1-t := by linarith
  have hc := (div_lt_iff₀ hl2).mp hb
  unfold clock
  nlinarith

private theorem early_residual_zero (a : ℕ → ℕ) {ν l t : ℝ} (hl : 1 < l)
    (ht : t < startTime l) (x : Space) :
    NavierStokesR3.ProblemStatement.navierStokesResidual ν (torusVelocity ν l a) (fun _ => 0) t x = 0 := by
  have hc : Continuous (fun w : SpaceTime => clock l w.1) := by unfold clock; fun_prop
  have early : ∀ᶠ w : SpaceTime in 𝓝 (t,x), clock l w.1 < 0 :=
    hc.continuousAt.eventually_lt_const (before_clock hl ht)
  have hzero : torusVelocity ν l a =ᶠ[𝓝 (t,x)] (fun _ => 0) := by
    filter_upwards [early] with z hz
    apply PeriodicLocalization.periodize_eq_zero_of_timeSlice
    intro y
    by_cases h1 : z.1 < 1
    · simp [PeriodicPaper.beforeOne,h1,compact,velocity,pull,zeroBefore,not_le_of_gt hz]
    · simp [PeriodicPaper.beforeOne,h1]
  have he := residual_congr ν (z := (t,x)) hzero (Filter.EventuallyEq.rfl (f := fun _ : SpaceTime => (0:ℝ)))
  apply he.trans
  simp [NavierStokesR3.ProblemStatement.navierStokesResidual,temporalDerivative,advection,
    spatialLaplacian,spatialDerivative,pressureGradient]

theorem early_loop_zero (a : ℕ → ℕ) {ν l t : ℝ} (hl : 1 < l) (ht : t < startTime l)
    (i j : Fin 3) (d : ℝ) : lineIntegral ν l (torusVelocity ν l a) t i j d = 0 := by
  unfold lineIntegral
  simp only [early_residual_zero a hl ht]
  exact intervalIntegral.integral_zero

theorem same_loop_before_after {a : ℕ → ℕ} (ha : LocalScheduleWitness.Selected a)
    {ν l : ℝ} (hν : 0 < ν) (hl : 1 < l) (hfit : width ν l < 2) :
    SameLoopBeforeAfter ν l a := by
  have hl2 : 1 < l^2 := by nlinarith [sq_nonneg (l-1),hl]
  have hi : 0 < 1/l^2 := div_pos zero_lt_one (zero_lt_one.trans hl2)
  have hlt : 1/l^2 < 1 := (div_lt_one (zero_lt_one.trans hl2)).mpr hl2
  have hp : 0 < startTime l := by unfold startTime; linarith
  have hb : startTime l < 1 := by unfold startTime; linarith
  obtain ⟨T,hT,H⟩ := opposite_nonzero_loops ha hν hl hfit
  refine ⟨hp,hb,min T (1-startTime l),lt_min hT (sub_pos.mpr hb),?_⟩
  intro σ hσ hs
  have hlate : startTime l < 1-σ := by linarith [hs.trans_le (min_le_right T (1-startTime l))]
  obtain ⟨d,hd,Hpair,hn⟩ := H σ hσ (hs.trans_le (min_le_left _ _))
  exact ⟨hlate,d,hd,
    fun t ht => ⟨early_loop_zero a hl ht.2 0 1 d,early_loop_zero a hl ht.2 1 0 d⟩,
    fun hz => hn (Hpair.1.symm.trans hz),
    Hpair.2.trans (congrArg Neg.neg Hpair.1.symm)⟩

end SignedVortex.Rescaled.TimeControl
