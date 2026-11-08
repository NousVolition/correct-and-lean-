import AccessDefinitions

namespace HugV3.Source.ChildAccount
noncomputable section
open scoped BigOperators
open Witness ChildAccess

structure Evaluation where
  aboutEncounter : Fin 3
  value : ℝ

-- External, attributed observation. Wording and provenance stay outside the solver.
structure Account where
  speaker : Actor
  recollects : Fin 3
  atTime : ℝ
  wording : String
  access : DirectAccess
  evaluation : Option Evaluation

def eligible (a : Account) (r : Record) : Prop :=
  a.speaker=child ∧ a.recollects=0 ∧ r.eventID=2 ∧ r.origin=father ∧ r.recipient=child ∧
  (events 2).startTime≤a.atTime ∧ a.atTime≤(events 2).endTime

def setReport (r : Record) (y : Option ℝ) : Record := {r with report:=y}

-- This is an optional input adapter for the tested later exchange, not a new dynamic.
def inputRecord (a : Account) (r : Record) : Option Record := by
  classical
  exact if eligible a r then
    match a.evaluation with
    | none => some r
    | some v => if v.aboutEncounter=2 ∧ -1≤v.value ∧ v.value≤1
        then some (setReport r (some v.value)) else none
  else none

def panel (old incident r : Record) (y : Option ℝ) : List (Fin 4 × Record) :=
  [(0,old),(1,incident),(2,setReport r y)]

def historyFraction (G : Geometry) (s : State) (r : Record) : ℝ :=
  recordWeight G s r/(0.12+recordWeight G s r)

def imitationInput (G : Geometry) (s : State) (rs : List (Fin 4 × Record)) : ℝ :=
  -0.7+1.8*s.relation child father 0+0.7*s.relation child father 2+
    memory G s rs child father 0-memory G s rs child father 1+
    0.4*sigmoid (margin s child father/0.18)-0.7*s.responses child father 3
def cooperationInput (G : Geometry) (s : State) (rs : List (Fin 4 × Record)) : ℝ :=
  -0.9+1.7*s.relation child father 2+
    Real.exp (-(∑ k,(s.expression father k-s.expression child k)^2)/0.6)+
    memory G s rs child father 0-memory G s rs child father 1+
    0.6*s.responses child father 6-0.5*s.responses child father 2
def withdrawalInput (G : Geometry) (s : State) (rs : List (Fin 4 × Record)) : ℝ :=
  -1.8+memory G s rs child father 1+s.responses father child 4+
    0.5*(1-sigmoid (margin s child father/0.18))+0.35*(observations G s child 1)-
    memory G s rs child father 0

-- Existing Heun update in structural_hug.py: all full-state coordinates and both accepted evaluations.
structure FullStep (G : Geometry) (t h : ℝ) (s d p k e : State) : Prop where
  first : rhs G t s=some d
  predictor : AllCoordinates (fun f => f p=f s+h*f d)
  second : rhs G (t+h) p=some k
  endpoint : AllCoordinates (fun f => f e=f s+h/2*(f d+f k))

def gapResidual (p : State) (k : Fin 2) : ℝ :=
  (p.context child k-p.context father k) -
    ∑ l,p.context child l*(p.context child l-p.context father l)

def rateContribution (p : State) (d f : State) (k : Fin 2) : ℝ :=
  ((d.responses child father 0-f.responses child father 0)+
    (d.responses child father 1-f.responses child father 1))*
    (p.context father k-p.context child k) +
    2*(d.responses child father 5-f.responses child father 5)*p.context child k*gapResidual p k

def contextContrast (v : Fin 2 → ℝ) : ℝ := v 0-v 1

end
end HugV3.Source.ChildAccount
