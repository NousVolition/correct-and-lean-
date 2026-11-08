import WitnessDefinitions

/- The diary and formulations are external observation data. The native state,
   event schedule and solution predicate are inherited verbatim. -/
namespace HugV3.Source.ChildAccess
noncomputable section

inductive DirectAccess | sees | misses deriving DecidableEq

structure PublicOccurrence where
  event : Fin 3
  origin : Actor
  recipient : Actor
  completed : ℝ

def publicOccurrence (n : Fin 3) : PublicOccurrence :=
  ⟨n,(events n).origin,(events n).recipient,(events n).endTime⟩

def diary (arm : DirectAccess) (t : ℝ) : List PublicOccurrence :=
  (if (events 0).endTime≤t then [publicOccurrence 0] else []) ++
  (if (events 1).endTime≤t ∧ arm=.sees then [publicOccurrence 1] else [])

def fits (arm : DirectAccess) (tr : Trace) (log : ℝ → List PublicOccurrence) : Prop :=
  Solves tr ∧ ∀ t, log t=diary arm t

inductive Formulation | simpleCrossing | yardRule | fathersSafety deriving DecidableEq

structure CrossingReport where
  reference : Fin 3
  formulation : Formulation

structure ReadingContrast where
  seenChanged : Bool
  unseenChanged : Bool
  finalReadingsDiffer : Bool
  deriving DecidableEq

def report (v : Formulation) : CrossingReport := ⟨0,v⟩

-- Compare formulations only if all three explicitly refer to the earlier crossing.
def contrast (before seenAfter missedAfter : Option CrossingReport) : Option ReadingContrast := do
  let p ← before
  let q ← seenAfter
  let r ← missedAfter
  if p.reference=0 ∧ q.reference=0 ∧ r.reference=0 then
    return ⟨decide (q.formulation≠p.formulation),decide (r.formulation≠p.formulation),
      decide (q.formulation≠r.formulation)⟩
  else none

end
end HugV3.Source.ChildAccess
