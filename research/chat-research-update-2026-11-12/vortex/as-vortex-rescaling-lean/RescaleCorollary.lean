import RescaleForcing

noncomputable section
namespace SignedVortex.Rescaled
open Set NavierStokes NavierStokes.ProblemStatement
open NavierStokesR3.ViscosityScaling

/-- Repeat the pinned construction with the schedule kept visible so that the
two-loop test and the original forced breakdown have identical witnesses. -/
theorem candidate_for_schedule {a : ℕ → ℕ} (ha : LocalScheduleWitness.Selected a)
    {ν : ℝ} (hν : 0 < ν) : ∃ l : ℝ, ∃ f : VelocityField, FamilyWitness ν l a f := by
  obtain ⟨f,hc⟩ := LocalScheduleWitness.selected_compact_candidate ha
  have hc' : NavierStokesR3.ProblemStatement.CandidateProperties ν
      (scaledVelocity ν (whole a)) (scaledPressure ν (wholeP a)) (scaledVelocity ν f)
      ((fun x : Space => Real.sqrt ν • x) '' SpatialLocalization.supportCylinder) :=
    candidate_at_viscosity hc hν
  have hrest (t : ℝ) (ht : |t| ≤ 3/8) (x : Space) :
      scaledVelocity ν (whole a) (t,x) = 0 ∧ scaledPressure ν (wholeP a) (t,x) = 0 := by
    constructor
    · change Real.sqrt ν • whole a (t,(Real.sqrt ν)⁻¹ • x) = 0
      rw [show whole a (t,(Real.sqrt ν)⁻¹ • x) = 0 from TimeLocalization.activatedVelocity_zero_early _ ht _,smul_zero]
    · change ν • wholeP a (t,(Real.sqrt ν)⁻¹ • x) = 0
      rw [show wholeP a (t,(Real.sqrt ν)⁻¹ • x) = 0 from TimeLocalization.activatedPressure_zero_early _ ht _,smul_zero]
  obtain ⟨l,hl,hK,hu,hp,hf⟩ := PeriodicPaper.exists_compression_scale hc'
  have hcomp := NavierStokesR3.ParabolicScaling.compressedCandidate hc' hrest hl
  have hperiod := PeriodicPaper.of_compact_candidate hcomp hK hu hp hf
  exact ⟨l,f,ha,hl,hK,hperiod,hperiod.no_global_solution hν,
    excludes_every_fitting_scale ha hν hl hK,hline_pinned_quarter ha hν hl hK hu⟩

theorem every_positive_viscosity (ν : ℝ) (hν : 0 < ν) :
    ∃ a : ℕ → ℕ, ∃ l : ℝ, ∃ f : VelocityField, FamilyWitness ν l a f := by
  obtain ⟨a,ha,_,_⟩ := LocalResidualFlatness.selected_schedule
  exact ⟨a,candidate_for_schedule ha hν⟩

end SignedVortex.Rescaled
