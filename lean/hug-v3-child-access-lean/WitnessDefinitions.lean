import StreetWholeDefinitions
import V3TransferDefinitions

namespace HugV3.Source.Witness
noncomputable section
open scoped BigOperators

-- Interpretive roles for the existing three directed records.
abbrev child : Actor := 0
abbrev father : Actor := 1
abbrev officer : Actor := 2

def unscored (r : Record) : Record := {r with observed := none, report := none}

-- A projection of the original context derivative, including withdrawal.
def contextTerm (s : State) (i j : Actor) (k : Fin 2) : ℝ :=
  let D := fun l => s.context i l - s.context j l
  (-(s.responses i j 0 + s.responses i j 1)*D k +
    s.responses i j 5*2*s.context i k*(D k - ∑ l, s.context i l*D l))

def contextDrift (s : State) (t : ℝ) (i : Actor) (k : Fin 2) : ℝ :=
  2*(0.6*home i k+0.4*room t k-s.context i k)+(∑ j, contextTerm s i j k)/5

def changeCoord (h : ℝ) (k : Fin 2) : ℝ := if k=0 then h else -h

def neighborTermChange (s : State) (i j : Actor) (h : ℝ) (k : Fin 2) : ℝ :=
  (s.responses i j 0 + s.responses i j 1)*changeCoord h k +
    s.responses i j 5*2*s.context i k*
    ((∑ l, s.context i l*changeCoord h l)-changeCoord h k)

def recognitionMean (s : State) (j : Actor) : ℝ := (∑ i, s.relation i j 0)/6

def recognitionInput (G : Geometry) (s : State) (rs : List (Fin 4 × Record))
    (i j : Actor) : ℝ :=
  3*((∑ k, s.context i k*recognitionBase j k)-0.5)+0.7*recognitionMean s j+
    0.8*(s.responses i j 0+s.responses i j 2)+memory G s rs i j 0-
    0.5*memory G s rs i j 1

-- These are matched snapshots. The source evolution and event inputs are untouched.
def changeRating (s : State) (a j : Actor) (h : ℝ) : State :=
  {s with relation := fun i b k => s.relation i b k +
    if i=a ∧ b=j ∧ k=0 then h else 0}

def SameCrossingSetting (s w : State) : Prop :=
  w.context=s.context ∧ (∀ x, w.g x 3=s.g x 3) ∧ margin w=margin s

end
end HugV3.Source.Witness
