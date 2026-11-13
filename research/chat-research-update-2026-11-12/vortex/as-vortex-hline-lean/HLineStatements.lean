import TargetSolution

noncomputable section
namespace SignedVortex.HLine
open NavierStokes NavierStokes.ProblemStatement NavierStokes.CorrectionInitialization

/-- The actual localized, periodically repeated velocity at viscosity one. -/
abbrev vortex (a : ℕ → ℕ) : VelocityField :=
  R3CompactCandidate.periodicVelocity (LocalAngularGrowth.selectedPotential a)
    (LocalAngularGrowth.selectedDirect a)

/-- The observable from the previous audit, including the derivatives of the
original product cutoff and of its anchored heat primitive. -/
def signal (t d : ℝ) := deriv (fun z =>
  shellTime (BaseExterior.nominalHeatNormalization ActualPrimary.nominal) ActualPrimary.h t (1/4-z) -
  deriv (deriv (fun v => shellTrace (BaseExterior.nominalHeatNormalization ActualPrimary.nominal)
    ActualPrimary.h t (1/4-v))) z) d
end SignedVortex.HLine
