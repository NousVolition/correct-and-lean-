import NavierStokes.TailGaugePotential
import SignedDefinitions
import NavierStokes.SpatialLocalization

noncomputable section
namespace SignedVortex
open MeasureTheory intervalIntegral NavierStokes

def shellEnergy (x y : ℝ) := (x^2+y^2)/2

def shellWeight (x y : ℝ) := SmoothCutoffs.cutoff (16*(x^2+y^2))

def shellPrimitive (C h t x y : ℝ) :=
  TailGaugePotential.heatPrimitive C h (t,(shellEnergy x y,0))

def shellTrace (C h t x : ℝ) :=
  ∫ y in (-(1/2):ℝ)..1/2, shellWeight x y * shellPrimitive C h t x y

def timeSlope (C h t s : ℝ) : ℝ :=
  fderiv ℝ (TailGaugePotential.heatPrimitive C h) (t,s,(0:ℝ)) (1,0,0)

def shellTime (C h t x : ℝ) :=
  ∫ y in (-(1/2):ℝ)..1/2, shellWeight x y * timeSlope C h t (shellEnergy x y)

/-- A transverse coordinate loop in the central copy of the periodic cell. -/
def loopPoint (i j : Fin 3) (d y : ℝ) : ProblemStatement.Space :=
  (1/4-d) • ProblemStatement.coordinateVector i + y • ProblemStatement.coordinateVector j

def loopResidual (u : ProblemStatement.VelocityField) (t : ℝ) (i j : Fin 3) (d : ℝ) :=
  ∫ y in (-(1/2):ℝ)..1/2, (ProblemStatement.navierStokesResidual u (fun _ => 0)
    t (loopPoint i j d y)) j

/-- The original signed force at one time, using the Euclidean dual norm of dS. -/
def MatchesSignedAt (u : ProblemStatement.VelocityField) (p : ProblemStatement.PressureField)
    (S : ProblemStatement.Space → ℝ) (k : Fin 3) (ε Γ c t : ℝ) : Prop :=
  ∀ x, ProblemStatement.navierStokesResidual u p t x =
    (-c * signed ε (‖fderiv ℝ S x‖-Γ)) • ProblemStatement.coordinateVector k

end SignedVortex
