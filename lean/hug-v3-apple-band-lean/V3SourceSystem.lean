import V3SourceFlow
import V3SourceGeometry
namespace HugV3.Source
noncomputable section
attribute [local instance] Classical.propDecidable
open scoped BigOperators
open Finset Set

structure Event where
  origin : Actor
  recipient : Actor
  startTime : ℝ
  endTime : ℝ
  observed : Option ℝ
  report : Option ℝ

def events : Fin 3 → Event := ![
  ⟨0,1,0,0.4,some 0.6,some 0.5⟩,
  ⟨2,1,0.2,0.8,some (-0.5),some (-0.7)⟩,
  ⟨1,0,0.8,1.2,none,some 0.2⟩]
def component : Fin 6 → Axis × Axis := ![(0,0),(1,1),(2,2),(0,1),(0,2),(1,2)]
def makeEvent (s : State) (startF : Particle → Mat) (id : Fin 3) : Option Record := do
  let records ← readRecords s
  let event := events id
  let predecessors : ℕ := (records.map fun pair =>
    if pair.2.endTime≤event.startTime then 2^pair.2.eventID.val else 0).sum
  return {
    origin := event.origin, recipient := event.recipient, eventID := ⟨id.val, by omega⟩
    startTime := event.startTime, endTime := event.endTime, predecessors := predecessors
    observed := event.observed, report := event.report
    context := fun k => (s.context event.origin k+s.context event.recipient k)/2
    recognition := s.relation event.recipient event.origin 0
    authority := s.relation event.recipient event.origin 1
    actions := s.responses event.origin event.recipient
    deltaE := fun p k => green (s.F p) (component k).1 (component k).2-
      green (startF p) (component k).1 (component k).2 }
def capture (id : Fin 3) (y : FullState) : FullState :=
  { y with starts := Function.update y.starts id (some y.state.F) }
def completeEvent (id : Fin 3) (y : FullState) : Option FullState := do
  let startF ← y.starts id
  let record ← makeEvent y.state startF id
  let state ← writeEvent sourceGeometry y.state record
  return ⟨state,Function.update y.starts id none⟩
def boundary : ℕ → FullState → Option FullState
  | 0, y => some (capture 0 y)
  | 1, y => some (capture 1 y)
  | 2, y => completeEvent 0 y
  | 3, y => (completeEvent 1 y).map (capture 2)
  | 4, y => completeEvent 2 y
  | _, y => some y
def time : ℕ → ℝ
  | 0 => 0
  | 1 => 1/5
  | 2 => 2/5
  | 3 => 4/5
  | 4 => 6/5
  | _ => 8/5
def initialFull : FullState := capture 0 ⟨initial sourceGeometry,fun _ => none⟩

-- Each entry in the complete numerical state dictionary is represented.
-- This avoids imposing a topology on a partially encoded record type.
def AllCoordinates (P : (State → ℝ) → Prop) : Prop :=
  (∀ x k, P (fun s => s.g x k)) ∧
  (∀ p i, P (fun s => s.X p i)) ∧
  (∀ p i j, P (fun s => s.F p i j)) ∧
  (∀ p k a, P (fun s => s.m p k a)) ∧
  (∀ l, P (fun s => s.b l)) ∧ P State.A ∧
  (∀ k, P (fun s => s.ledger k)) ∧ P State.writeWork ∧
  (∀ i k, P (fun s => s.expression i k)) ∧
  (∀ i k, P (fun s => s.context i k)) ∧
  (∀ i k, P (fun s => s.normCenter i k)) ∧
  (∀ i j, P (fun s => s.logRadius i j)) ∧
  (∀ i j k, P (fun s => s.relation i j k)) ∧
  (∀ i j k, P (fun s => s.responses i j k)) ∧
  (∀ i j k, P (fun s => s.association i j k))
def ContinuousStateOn (s : ℝ → State) (I : Set ℝ) : Prop :=
  AllCoordinates (fun f => ContinuousOn (fun t => f (s t)) I)
def StateHasDerivWithinAt (s : ℝ → State) (d : State) (I : Set ℝ) (t : ℝ) : Prop :=
  AllCoordinates (fun f => HasDerivWithinAt (fun τ => f (s τ)) (f d) I t)

structure Trace where
  after : ℕ → FullState
  path : ℕ → ℝ → FullState

def Solves (tr : Trace) : Prop :=
  tr.after 0=initialFull ∧ ∀ k<5,
    tr.path k (time k)=tr.after k ∧
    ContinuousStateOn (fun t => (tr.path k t).state) (Icc (time k) (time (k+1))) ∧
    (∀ t ∈ Icc (time k) (time (k+1)), (tr.path k t).starts=(tr.after k).starts) ∧
    (∀ t ∈ Icc (time k) (time (k+1)), ∃ d,
      rhs sourceGeometry t (tr.path k t).state=some d ∧
      StateHasDerivWithinAt (fun τ => (tr.path k τ).state) d (Icc (time k) (time (k+1))) t) ∧
    boundary (k+1) (tr.path k (time (k+1)))=some (tr.after (k+1))
def Agreement (a b : Trace) : Prop :=
  (∀ k≤5, a.after k=b.after k) ∧
  ∀ k<5, ∀ t ∈ Icc (time k) (time (k+1)), a.path k t=b.path k t

-- The user's actual requested target. It is a proposition, not a proved
-- theorem, and is deliberately not filled with a placeholder or an axiom.
def FullExistenceUniqueness : Prop :=
  ∃ tr, Solves tr ∧ ∀ other, Solves other → Agreement tr other

end
end HugV3.Source
