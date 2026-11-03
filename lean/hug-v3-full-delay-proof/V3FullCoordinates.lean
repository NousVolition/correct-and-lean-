import V3DelayDefinitions
import Mathlib.Analysis.ODE.ExistUnique
import Mathlib.Analysis.Calculus.Deriv.Prod

/-! A lossless coordinate chart for the entire saved state. No dynamics are changed. -/
namespace HugV3.Source.FullDelay
noncomputable section
open Set Metric
open scoped NNReal

inductive Coordinate where
  | grid : Grid → Fin 5 → Coordinate
  | position : Particle → Axis → Coordinate
  | deformation : Particle → Axis → Axis → Coordinate
  | directional : Particle → Direction → Fin 2 → Coordinate
  | fabric : Cell → Coordinate
  | accumulator : Coordinate
  | ledger : Fin 4 → Coordinate
  | work : Coordinate
  | expression : Actor → Fin 2 → Coordinate
  | context : Actor → Fin 2 → Coordinate
  | normCenter : Actor → Fin 2 → Coordinate
  | logRadius : Actor → Actor → Coordinate
  | relation : Actor → Actor → Fin 3 → Coordinate
  | responses : Actor → Actor → Fin 7 → Coordinate
  | association : Actor → Actor → Fin 3 → Coordinate
  deriving DecidableEq, Fintype

abbrev FullVector := Coordinate → ℝ

def encode (s : State) : FullVector
  | .grid x k => s.g x k
  | .position p i => s.X p i
  | .deformation p i j => s.F p i j
  | .directional p k a => s.m p k a
  | .fabric l => s.b l
  | .accumulator => s.A
  | .ledger k => s.ledger k
  | .work => s.writeWork
  | .expression i k => s.expression i k
  | .context i k => s.context i k
  | .normCenter i k => s.normCenter i k
  | .logRadius i j => s.logRadius i j
  | .relation i j k => s.relation i j k
  | .responses i j k => s.responses i j k
  | .association i j k => s.association i j k

def decode (z : FullVector) : State where
  g := fun x k => z (.grid x k)
  X := fun p i => z (.position p i)
  F := fun p i j => z (.deformation p i j)
  m := fun p k a => z (.directional p k a)
  b := fun l => z (.fabric l)
  A := z .accumulator
  ledger := fun k => z (.ledger k)
  writeWork := z .work
  expression := fun i k => z (.expression i k)
  context := fun i k => z (.context i k)
  normCenter := fun i k => z (.normCenter i k)
  logRadius := fun i j => z (.logRadius i j)
  relation := fun i j k => z (.relation i j k)
  responses := fun i j k => z (.responses i j k)
  association := fun i j k => z (.association i j k)

@[simp] theorem decode_encode (s : State) : decode (encode s) = s := by
  cases s
  rfl

@[simp] theorem encode_decode (z : FullVector) : encode (decode z) = z := by
  funext i
  cases i <;> rfl

theorem encode_injective : Function.Injective encode := by
  intro a b h
  simpa using congrArg decode h

theorem allCoordinates_of_chart (P : (State → ℝ) → Prop)
    (h : ∀ c, P (fun s => encode s c)) : AllCoordinates P :=
  ⟨fun x k => h (.grid x k), fun p i => h (.position p i),
   fun p i j => h (.deformation p i j), fun p k a => h (.directional p k a),
   fun l => h (.fabric l), h .accumulator, fun k => h (.ledger k), h .work,
   fun i k => h (.expression i k), fun i k => h (.context i k),
   fun i k => h (.normCenter i k), fun i j => h (.logRadius i j),
   fun i j k => h (.relation i j k), fun i j k => h (.responses i j k),
   fun i j k => h (.association i j k)⟩

theorem decoded_derivative {z : ℝ → FullVector} {d : State} {I : Set ℝ} {t : ℝ}
    (hd : HasDerivWithinAt z (encode d) I t) :
    StateHasDerivWithinAt (fun s => decode (z s)) d I t := by
  apply allCoordinates_of_chart
  intro c
  simpa only [encode_decode] using (hasDerivWithinAt_pi.mp hd) c

/-- Both physical and delayed social rates are the original full rhsFromRecords.
The records are held fixed only on a neighborhood certified by Compatible below. -/
def frozenRate (G : Geometry) (records : List (Fin 4 × Record))
    (history : ℝ → State) (τ t : ℝ) (z : FullVector) : FullVector :=
  encode (Delay.socialFrom (rhsFromRecords G t (decode z) records)
    (rhsFromRecords G t (Delay.socialFrom (decode z) (history (t-τ))) records))

/-- This is an obligation, not an axiom or a theorem that decoding/acceptance holds. -/
def Compatible (G : Geometry) (records : List (Fin 4 × Record))
    (history : ℝ → State) (τ a b : ℝ) (center : FullVector) (radius : ℝ≥0) : Prop :=
  ∀ t ∈ Icc a b, ∀ z ∈ closedBall center radius,
    Delay.rhsDelayed G t (decode z) (history (t-τ)) =
      some (decode (frozenRate G records history τ t z))

/-- The derivative is the complete saved partial RHS, not a reduced ODE. -/
def Segment (G : Geometry) (history : ℝ → State) (τ a b : ℝ)
    (start : State) (z : ℝ → FullVector) : Prop :=
  z a = encode start ∧ ContinuousOn z (Icc a b) ∧
  ∀ t ∈ Icc a b, ∃ d : State,
    Delay.rhsDelayed G t (decode (z t)) (history (t-τ)) = some d ∧
    HasDerivWithinAt z (encode d) (Icc a b) t

/-- A proof-side concatenation of histories, not a change to any rate or write. -/
def extendHistory (a : ℝ) (past : ℝ → State) (z : ℝ → FullVector) (t : ℝ) : State :=
  if t ≤ a then past t else decode (z t)

/-- Sample the original five intervals, taking the post-write side at a checkpoint.
The social coordinates are unchanged by accepted writes; physical jumps are retained. -/
def sample (past : ℝ → State) (tr : Trace) (t : ℝ) : State :=
  if t < 0 then past t else
  if t < time 1 then (tr.path 0 t).state else
  if t < time 2 then (tr.path 1 t).state else
  if t < time 3 then (tr.path 2 t).state else
  if t < time 4 then (tr.path 3 t).state else
  if t < time 5 then (tr.path 4 t).state else (tr.after 5).state

/-- The full saved constant-delay family. The user's later variable/reconstructed
memory interpretation is not asserted to be represented by this definition. -/
def DelayedSolves (τ : ℝ) (past : ℝ → State) (tr : Trace) : Prop :=
  0 ≤ τ ∧ Delay.SameSocial (past 0) initialFull.state ∧
  tr.after 0 = initialFull ∧ ∀ k < 5,
    tr.path k (time k) = tr.after k ∧
    ContinuousStateOn (fun t => (tr.path k t).state) (Icc (time k) (time (k+1))) ∧
    (∀ t ∈ Icc (time k) (time (k+1)), (tr.path k t).starts = (tr.after k).starts) ∧
    (∀ t ∈ Icc (time k) (time (k+1)), ∃ d,
      Delay.rhsDelayed sourceGeometry t (tr.path k t).state
        (sample past tr (t-τ)) = some d ∧
      StateHasDerivWithinAt (fun s => (tr.path k s).state) d
        (Icc (time k) (time (k+1))) t) ∧
    Delay.eventBoundary (k+1) (tr.path k (time (k+1))) = some (tr.after (k+1))

/-- The full desired target remains a proposition, with no fabricated proof. -/
def FullDelayedExistenceUniqueness (τ : ℝ) (past : ℝ → State) : Prop :=
  ∃ tr, DelayedSolves τ past tr ∧ ∀ other, DelayedSolves τ past other → Agreement tr other

end
end HugV3.Source.FullDelay
