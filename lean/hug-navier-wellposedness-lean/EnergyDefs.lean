import GuardTransportTimeDefs

namespace HugNavierSingle.EnergyEstimate
noncomputable section
open MeasureTheory
open GuardTransport

/-- The six differences of two histories of the same field system. -/
def differenceFields (z w : Fields) : Fields :=
  ⟨(fun r => z.ux r - w.ux r), (fun r => z.uy r - w.uy r),
   (fun r => z.xA r - w.xA r), (fun r => z.xB r - w.xB r),
   (fun r => z.gAB r - w.gAB r), (fun r => z.gBA r - w.gBA r)⟩

/-- The full quadratic difference functional, integrated over the periodic cell. -/
def differenceEnergy (z w : Fields) : ℝ :=
  ∫ r, energy (differenceFields z w) r ∂cellMeasure

/-- Absolute magnitudes of the two residual guard transport contributions. -/
def guardTransportMagnitude (z w : Fields) : ℝ :=
  |∫ r, (z.gAB r - w.gAB r) * residual (velocityAt z r) w w.gAB r ∂cellMeasure| +
  |∫ r, (z.gBA r - w.gBA r) * residual (velocityAt z r) w w.gBA r ∂cellMeasure|

end
end HugNavierSingle.EnergyEstimate
