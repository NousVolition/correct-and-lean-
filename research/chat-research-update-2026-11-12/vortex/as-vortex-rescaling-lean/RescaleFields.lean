import HLineProofs
import NavierStokes.PeriodicPaperTheorem

noncomputable section
namespace SignedVortex.Rescaled
open Set MeasureTheory intervalIntegral NavierStokes NavierStokes.ProblemStatement

/-- Factors converting unit-viscosity spatial coordinates to the final unit box, and back. -/
def width (ν l : ℝ) := Real.sqrt ν / l
def zoom (ν l : ℝ) := l / Real.sqrt ν

abbrev whole (a : ℕ → ℕ) := R3CompactCandidate.velocity
  (LocalAngularGrowth.selectedPotential a) (LocalAngularGrowth.selectedDirect a)
abbrev wholeP (a : ℕ → ℕ) := R3CompactCandidate.pressure (LocalScheduleWitness.pressureSum a)
abbrev compact (ν l : ℝ) (a : ℕ → ℕ) := NavierStokesR3.ParabolicScaling.velocity l (NavierStokesR3.ViscosityScaling.scaledVelocity ν (whole a))
abbrev torusVelocity (ν l : ℝ) (a : ℕ → ℕ) :=
  PeriodicLocalization.periodize (PeriodicPaper.beforeOne (compact ν l a))
abbrev torusPressure (ν l : ℝ) (a : ℕ → ℕ) :=
  PeriodicLocalization.periodize (PeriodicPaper.beforeOne (NavierStokesR3.ParabolicScaling.pressure l (NavierStokesR3.ViscosityScaling.scaledPressure ν (wholeP a))))
abbrev torusForce (ν l : ℝ) (f : VelocityField) :=
  PeriodicLocalization.periodize (NavierStokesR3.ParabolicScaling.force l (NavierStokesR3.ViscosityScaling.scaledVelocity ν f))
abbrev compactSet (ν l : ℝ) : Set Space :=
  (fun x : Space => l⁻¹ • x) '' ((fun x : Space => Real.sqrt ν • x) '' SpatialLocalization.supportCylinder)

def linePoint (ν l : ℝ) (i j : Fin 3) (d y : ℝ) : Space :=
  (width ν l * HLine.off d) • coordinateVector i + y • coordinateVector j

def lineIntegral (ν l : ℝ) (u : VelocityField) (t : ℝ) (i j : Fin 3) (d : ℝ) :=
  ∫ y in (-(1/2):ℝ)..1/2, (NavierStokesR3.ProblemStatement.navierStokesResidual ν u
    (fun _ => 0) t (linePoint ν l i j d y)) j

/-- Use the original A/S signed force at the physical coordinates. Only the
viscosity in the native momentum operator is now ν instead of 1. -/
def MatchesAt (ν : ℝ) (u : VelocityField) (p : PressureField) (S : Space → ℝ)
    (k : Fin 3) (ε Γ c t : ℝ) : Prop :=
  ∀ x, NavierStokesR3.ProblemStatement.navierStokesResidual ν u p t x =
    (-c * signed ε (‖fderiv ℝ S x‖ - Γ)) • coordinateVector k

def noTrajectory (ν : ℝ) (u : VelocityField) : Prop :=
  ∀ (k : Fin 3) (ε Γ c : ℝ), ¬ ∃ (p : PressureField) (S : ℝ → Space → ℝ),
    (∀ t ∈ Ioo (0:ℝ) 1, ContDiff ℝ 1 (fun x => p (t,x))) ∧
    (∀ t ∈ Ioo (0:ℝ) 1, ∀ x j, p (t,x+coordinateVector j) = p (t,x)) ∧
    ∀ t ∈ Ioo (0:ℝ) 1, MatchesAt ν u p (S t) k ε Γ c t

/-- The two full unit cycles have opposite readings at the same physical time and offset. -/
def BothReadings (ν l : ℝ) (a : ℕ → ℕ) (σ d : ℝ) : Prop :=
  lineIntegral ν l (torusVelocity ν l a) (1-σ) 0 1 d =
      l^2 * ν * HLine.signal (1-l^2*σ) d ∧
  lineIntegral ν l (torusVelocity ν l a) (1-σ) 1 0 d =
      -(l^2 * ν * HLine.signal (1-l^2*σ) d)

/-- All clauses refer to the very same compressed and periodized fields. -/
def FamilyWitness (ν l : ℝ) (a : ℕ → ℕ) (f : VelocityField) : Prop :=
  LocalScheduleWitness.Selected a ∧ 1 < l ∧
  compactSet ν l ⊆ PeriodicPaper.fundamentalInterior ∧
  PeriodicPaper.CandidateProperties ν (torusVelocity ν l a) (torusPressure ν l a)
    (torusForce ν l f) (compactSet ν l) ∧
  (¬ Nonempty (PeriodicPaper.GlobalSmoothSolution ν (torusForce ν l f))) ∧
  noTrajectory ν (torusVelocity ν l a) ∧
  ∃ η : ℝ, 0 < η ∧ ∀ σ : ℝ, 0 < σ → σ < η →
    ∀ d ∈ Ioo (-(1/16):ℝ) (1/8), BothReadings ν l a σ d

end SignedVortex.Rescaled
