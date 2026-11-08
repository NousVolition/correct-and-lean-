import V3SourceSystem

/-!
Proposed interpretation and diagnostic input variations, not added evolution laws.
A line-associated scalar context signal is supplied to the existing C channel.
No claim identifies its numeric amplitude with paint, perception, truth or safety.
The person stays in the same full state as every field, material coordinate and actor.
The six wizards describe overlapping contributions to that whole, not actor IDs.
-/
namespace HugV3.Source.StreetWhole
noncomputable section
open scoped BigOperators

def withLineSignal (s : State) (signal : Scalar) : State :=
  {s with g := fun x k => if k=3 then signal x else s.g x k}

def fullLineInput (y : FullState) (signal : Scalar) : FullState :=
  {y with state := withLineSignal y.state signal}

def lineRead (G : Geometry) (s : State) (i : Actor) (signal : Scalar) : ℝ :=
  ∑ p, G.attach i p*(∑ x, R s.X p x*signal x)

/-- Move the selected person's two context weights by +h and -h.
This is a comparison of inputs, not an extra rule for changing a solution. -/
def shiftPersonalContext (s : State) (person : Actor) (h : ℝ) : State :=
  {s with context := fun i k => if i=person then
      s.context i k + (if k=0 then h else -h) else s.context i k}

def recordFeature (G : Geometry) (r : Record) : Vec :=
  ![r.context 0,r.context 1,
    tanh (0.5*(∑ p, (G.attach r.recipient p+G.attach r.origin p)*recordChange r p)/0.12)]

def cueDifference (G : Geometry) (s : State) (r : Record) : Vec := fun k =>
  recordFeature G r k-memoryFeature G s r.recipient r.origin k-
    0.15*tanh (s.association r.recipient r.origin k)

def sourceKernel (G : Geometry) (t : ℝ) (s : State)
    (records : List (Fin 4 × Record)) (x : Grid) : ℝ :=
  (∑ p, R s.X p x*(socialRates G t s records).sourceWeights p)/dv

/-- Synthetic line-shaped grid signal. Height is in model units, not road units. -/
def bandSignal (height : ℝ) : Scalar := fun x => if x 0=8 then height else 0
def testCell (first : Fin 16) : Grid := ![first,0,0]

end
end HugV3.Source.StreetWhole
