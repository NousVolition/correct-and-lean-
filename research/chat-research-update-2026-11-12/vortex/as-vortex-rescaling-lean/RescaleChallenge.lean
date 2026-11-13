import RescaleFields

noncomputable section
namespace SignedVortex.Rescaled
open Set MeasureTheory intervalIntegral NavierStokes NavierStokes.ProblemStatement
open NavierStokesR3.ParabolicScaling
open scoped Topology ContDiff

theorem support_fits_iff {ν l : ℝ} (hν : 0 < ν) (hl : 0 < l) :
    compactSet ν l ⊆ PeriodicPaper.fundamentalInterior ↔ width ν l < 2 := by sorry

theorem loop_transfer {a : ℕ → ℕ} (ha : LocalScheduleWitness.Selected a)
    {ν l r t d : ℝ} (hν : 0 < ν) (hl : 0 < l) (hfit : width ν l < 2)
    (hr : r < 1/2) (hsup : PeriodicLocalization.SupportedInCube r (PeriodicPaper.beforeOne (compact ν l a)))
    (ht : t < 1) (hclock : clock l t ∈ Ioo (0:ℝ) 1)
    (hd : d ∈ Ioo (-(1/16):ℝ) (1/8)) (hx : |width ν l * HLine.off d| < 1-r)
    {i j : Fin 3} (hij : i ≠ j) :
    lineIntegral ν l (torusVelocity ν l a) t i j d =
      l^2 * ν * loopResidual (HLine.vortex a) (clock l t) i j d := by sorry

theorem hline_any_fit {a : ℕ → ℕ} (ha : LocalScheduleWitness.Selected a)
    {ν l : ℝ} (hν : 0 < ν) (hl : 1 < l) (hfit : width ν l < 2) :
    ∃ η : ℝ, 0 < η ∧ ∀ σ : ℝ, 0 < σ → σ < η →
      ∀ d ∈ Ico (0:ℝ) (1/8), BothReadings ν l a σ d := by sorry

theorem hline_pinned_quarter {a : ℕ → ℕ} (ha : LocalScheduleWitness.Selected a)
    {ν l : ℝ} (hν : 0 < ν) (hl : 1 < l)
    (hK : compactSet ν l ⊆ PeriodicPaper.fundamentalInterior)
    (hu : ∀ t < (1:ℝ), ∀ x : Space, compact ν l a (t,x) ≠ 0 → ∀ i, |x i| ≤ 1/4) :
    ∃ η : ℝ, 0 < η ∧ ∀ σ : ℝ, 0 < σ → σ < η →
      ∀ d ∈ Ioo (-(1/16):ℝ) (1/8), BothReadings ν l a σ d := by sorry

theorem matches_at_one (u : VelocityField) (p : PressureField) (S : Space → ℝ)
    (k : Fin 3) (ε Γ c t : ℝ) :
    MatchesAt 1 u p S k ε Γ c t ↔ MatchesSignedAt u p S k ε Γ c t := by sorry

theorem matching_force_has_zero_loop (ν l : ℝ) (u : VelocityField) (p : PressureField)
    (S : Space → ℝ) {k j : Fin 3} (i : Fin 3) {ε Γ c t d : ℝ} (hjk : j ≠ k)
    (hp : ContDiff ℝ 1 (fun x => p (t,x)))
    (hper : ∀ x, p (t,x + coordinateVector j) = p (t,x))
    (hm : MatchesAt ν u p S k ε Γ c t) : lineIntegral ν l u t i j d = 0 := by sorry

theorem inward_signal {t : ℝ} (ht : t < 1) :
    ∃ d ∈ Ico (0:ℝ) (1/8), HLine.signal t d ≠ 0 := by sorry

theorem opposite_nonzero_loops {a : ℕ → ℕ} (ha : LocalScheduleWitness.Selected a)
    {ν l : ℝ} (hν : 0 < ν) (hl : 1 < l) (hfit : width ν l < 2) :
    ∃ η : ℝ, 0 < η ∧ ∀ σ : ℝ, 0 < σ → σ < η →
      ∃ d ∈ Ico (0:ℝ) (1/8), BothReadings ν l a σ d ∧
        l^2 * ν * HLine.signal (1-l^2*σ) d ≠ 0 := by sorry

theorem late_exclusion {a : ℕ → ℕ} (ha : LocalScheduleWitness.Selected a)
    {ν l : ℝ} (hν : 0 < ν) (hl : 1 < l) (hfit : width ν l < 2) :
    ∃ η : ℝ, 0 < η ∧ ∀ σ : ℝ, 0 < σ → σ < η →
    ∀ (k : Fin 3) (ε Γ c : ℝ), ¬ ∃ (p : PressureField) (S : Space → ℝ),
      ContDiff ℝ 1 (fun x => p (1-σ,x)) ∧
      (∀ x j, p (1-σ,x+coordinateVector j) = p (1-σ,x)) ∧
      MatchesAt ν (torusVelocity ν l a) p S k ε Γ c (1-σ) := by sorry

theorem excludes_every_fitting_scale {a : ℕ → ℕ} (ha : LocalScheduleWitness.Selected a)
    {ν l : ℝ} (hν : 0 < ν) (hl : 1 < l)
    (hK : compactSet ν l ⊆ PeriodicPaper.fundamentalInterior) :
    noTrajectory ν (torusVelocity ν l a) := by sorry

theorem candidate_for_schedule {a : ℕ → ℕ} (ha : LocalScheduleWitness.Selected a)
    {ν : ℝ} (hν : 0 < ν) : ∃ l : ℝ, ∃ f : VelocityField, FamilyWitness ν l a f := by sorry

theorem every_positive_viscosity (ν : ℝ) (hν : 0 < ν) :
    ∃ a : ℕ → ℕ, ∃ l : ℝ, ∃ f : VelocityField, FamilyWitness ν l a f := by sorry

end SignedVortex.Rescaled
