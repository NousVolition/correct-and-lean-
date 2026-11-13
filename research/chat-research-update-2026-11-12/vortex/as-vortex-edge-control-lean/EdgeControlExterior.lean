import RescaleSupport

noncomputable section
namespace SignedVortex.Rescaled.EdgeControl
open Set Filter MeasureTheory intervalIntegral NavierStokes NavierStokes.ProblemStatement
open scoped Topology

/-- An independent control using only support and the local lattice sum.
It does not use the heat trace, its edge signal, or either transferred loop identity. -/
theorem exterior_from_support {a : ℕ → ℕ} {ν l d : ℝ} (hν : 0 < ν) (hl : 0 < l)
    (hfit : width ν l < 2)
    (hu : ∀ t < (1:ℝ), ∀ x : Space, compact ν l a (t,x) ≠ 0 → ∀ i, |x i| ≤ 1/4)
    (hd : d ∈ Ioo (-(1/16):ℝ) 0) (t : ℝ) {i j : Fin 3} (hij : i ≠ j) :
    lineIntegral ν l (torusVelocity ν l a) t i j d = 0 := by
  let g := PeriodicPaper.beforeOne (compact ν l a)
  have hs : PeriodicLocalization.SupportedInCube (width ν l/4) g := before_support hν hl a
  have hquarter : PeriodicLocalization.SupportedInCube (1/4) g := PeriodicPaper.beforeOne_supported hu
  have hw := width_pos hν hl
  have hoff : 0 < HLine.off d := by unfold HLine.off; linarith [hd.2]
  have ha : |width ν l * HLine.off d| = width ν l * HLine.off d := abs_of_pos (mul_pos hw hoff)
  have lower : width ν l/4 < |width ν l * HLine.off d| := by
    rw [ha]; unfold HLine.off
    nlinarith [mul_neg_of_pos_of_neg hw hd.2]
  have upper : |width ν l * HLine.off d| < 1-(1/4:ℝ) := by
    rw [ha]; unfold HLine.off
    have h : 1/4-d < (5/16:ℝ) := by linarith [hd.1]
    linarith [mul_lt_mul_of_pos_left h hw]
  unfold lineIntegral
  calc _ = ∫ y in (-(1/2):ℝ)..1/2, (0:ℝ) := by
         apply intervalIntegral.integral_congr
         intro y hy
         rw [uIcc_of_le (by norm_num : (-(1/2):ℝ) ≤ 1/2)] at hy
         let x := linePoint ν l i j d y
         have hy' : |y| < 1-(1/4:ℝ) := abs_lt.mpr ⟨by linarith [hy.1],by linarith [hy.2]⟩
         have hx : x ∈ PeriodicLocalization.innerCube (1/4) := inner_line hij upper hy'
         have hi : x i = width ν l * HLine.off d := by simp [x,linePoint,coordinateVector,hij]
         have nb : ∀ᶠ z : SpaceTime in 𝓝 (t,x), width ν l/4 < |z.2 i| := by
           apply (((AxisymmetricFields.projection i).continuous.comp continuous_snd).abs.continuousAt).eventually_const_lt
           change width ν l/4 < |x i|
           rwa [hi]
         have zero : g =ᶠ[𝓝 (t,x)] (fun _ => 0) := by
           filter_upwards [nb] with z hz
           by_contra hn
           exact (not_lt_of_ge (hs z hn i)) hz
         have hg := (PeriodicLocalization.periodize_eventuallyEq (z := (t,x)) hquarter hx).trans zero
         have eq := NavierStokesR3.ParabolicScaling.residual_congr ν (z := (t,x)) hg
           (Filter.EventuallyEq.rfl (f := fun _ : SpaceTime => (0:ℝ)))
         have nil : NavierStokesR3.ProblemStatement.navierStokesResidual ν
             (fun _ => 0) (fun _ => 0) t x = 0 := by
           simp [NavierStokesR3.ProblemStatement.navierStokesResidual,
             temporalDerivative,advection,spatialLaplacian,spatialDerivative,pressureGradient]
         exact congrArg (fun v : Space => v j) (eq.trans nil)
       _ = 0 := intervalIntegral.integral_zero

end SignedVortex.Rescaled.EdgeControl
