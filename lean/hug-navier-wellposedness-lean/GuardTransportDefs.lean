import FullModel
import Mathlib.MeasureTheory.Integral.Prod

/- Pointwise transport identities for the two directional Hug–Navier guards. -/
namespace HugNavierSingle.GuardTransport
noncomputable section

def velocityAt (z : Fields) (r : Point) : Point := (z.ux r, z.uy r)

def sampleBlend (a : ℝ) (left right : Fields) (r : Point) : Point :=
  ((1 - a) * left.ux r + a * right.ux r,
   (1 - a) * left.uy r + a * right.uy r)

def transportAt (uRead : Point) (g : ScalarField) (r : Point) : ℝ :=
  uRead.1 * partialX g r + uRead.2 * partialY g r

def residual (uRead : Point) (z : Fields) (g : ScalarField) (r : Point) : ℝ :=
  (uRead.1 - z.ux r) * partialX g r + (uRead.2 - z.uy r) * partialY g r

/-- Lebesgue area of the fundamental 2π-periodic square, with each edge counted once. -/
def cellAxis : MeasureTheory.Measure ℝ :=
  MeasureTheory.volume.restrict (Set.Ioc 0 (2 * Real.pi))

def cellMeasure : MeasureTheory.Measure Point := cellAxis.prod cellAxis

end
end HugNavierSingle.GuardTransport
