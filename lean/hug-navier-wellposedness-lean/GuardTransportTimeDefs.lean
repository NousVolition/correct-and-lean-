import GuardTransportDefs

namespace HugNavierSingle.GuardTransport
noncomputable section
open Set

/-- The closed cell is used only for the compactness argument. -/
def closedCell : Set Point := Icc 0 (2 * Real.pi) ×ˢ Icc 0 (2 * Real.pi)

/-- A closed finite time interval times the closed spatial cell. -/
def timeCell (a b : ℝ) : Set (ℝ × Point) := Icc a b ×ˢ closedCell

/-- The extra joint space-time continuity used in the classical argument.
The original FieldProblem only states spatial regularity at each time.
Only the two comparison guards' first spatial derivatives are needed here. -/
def JointGuardGradientRegularity (w : ℝ → Fields) (a b : ℝ) : Prop :=
  ContinuousOn (fun p : ℝ × Point => partialX (w p.1).gAB p.2) (timeCell a b) ∧
  ContinuousOn (fun p : ℝ × Point => partialY (w p.1).gAB p.2) (timeCell a b) ∧
  ContinuousOn (fun p : ℝ × Point => partialX (w p.1).gBA p.2) (timeCell a b) ∧
  ContinuousOn (fun p : ℝ × Point => partialY (w p.1).gBA p.2) (timeCell a b)

end
end HugNavierSingle.GuardTransport
