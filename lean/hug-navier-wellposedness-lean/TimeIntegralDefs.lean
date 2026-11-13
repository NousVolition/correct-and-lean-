import EnergyDefs

namespace HugNavierSingle.EnergyEstimate
noncomputable section

/-- The exact six-field difference paired with the difference of the existing
PDE rates. No integration by parts or dissipative estimate is built into this definition. -/
def differenceRateDensity (input : FieldInputs) (t : ℝ) (z w : Fields)
    (pz pw : ScalarField) (r : Point) : ℝ :=
  let d := differenceFields z w
  let dr := differenceFields (fieldRates input t z pz) (fieldRates input t w pw)
  d.ux r * dr.ux r + d.uy r * dr.uy r +
  d.xA r * dr.xA r + d.xB r * dr.xB r +
  d.gAB r * dr.gAB r + d.gBA r * dr.gBA r

/-- Extra analytic regularity of the explicit difference-rate density.
This is a sufficient hypothesis for the compact-cell dominated derivative argument;
it is not asserted to follow from FieldProblem or the guard-gradient hypothesis. -/
def JointDifferenceRateRegularity (input : FieldInputs) (z w : ℝ → Fields)
    (pz pw : ℝ → ScalarField) (a b : ℝ) : Prop :=
  ContinuousOn (fun p : ℝ × Point =>
    differenceRateDensity input p.1 (z p.1) (w p.1) (pz p.1) (pw p.1) p.2)
    (GuardTransport.timeCell a b)

end
end HugNavierSingle.EnergyEstimate
