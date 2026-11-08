import StreetWholeDefinitions

/- Auxiliary readouts of full Hug v3, at one time. A constant contrast over a
   known footprint and a known background are identification assumptions. -/
namespace HugV3.Source.PaintCalibration
noncomputable section
open StreetWhole
open scoped BigOperators

abbrev Footprint := Grid → Bool

def indicator (mark : Footprint) (x : Grid) : ℝ := if mark x then 1 else 0

def profile (background : Scalar) (mark : Footprint) (height : ℝ) : Scalar :=
  fun x => background x + height * indicator mark x

def total (f : Scalar) : ℝ := dv * ∑ x : Grid, f x

def sensitivity (G : Geometry) (s : State) (i : Actor) (mark : Footprint) : ℝ :=
  lineRead G s i (indicator mark)

def sensor (G : Geometry) (s : State) (i : Actor) (f : Scalar) : ℝ :=
  observations G (withLineSignal s f) i 0

end
end HugV3.Source.PaintCalibration
