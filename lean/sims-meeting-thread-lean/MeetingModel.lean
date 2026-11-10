import Mathlib.Tactic
import Mathlib.Analysis.Calculus.Deriv.Prod
import Mathlib.Analysis.Calculus.Deriv.Pow

/-! Sampled reports, witness acceptance, one well-mixed exchange and basin readouts. -/

namespace MeetingThread

structure Clocks where
  room : ℚ
  wall : ℚ

/-- In the restaurant, a private actor call advances a separately measured wall clock. -/
def awaitReply (c : Clocks) (duration : ℚ) : Clocks :=
  ⟨c.room, c.wall + duration⟩

/-- Candidate model for a single, lasting transition, reported without delay at each probe. -/
def sureAt (crossing probe : ℚ) : Prop := crossing ≤ probe

inductive Cause | phone | pager deriving DecidableEq, Repr

structure Tremble where
  id : Nat
  occurred : ℚ
  actualCause : Cause

structure WitnessReply where
  about : Nat
  arrives : ℚ
  identifies : Option Cause

structure Account where
  questionAbout : Nat
  answer : Option Cause
  deriving DecidableEq

/-- The past event belongs to the world. B retains its question and can accept
    an identified cause when a matching report arrives. The hidden actual cause
    is never used to produce B's answer. -/
def accountAt (event : Tremble) (w : WitnessReply) (accepted : Bool) (t : ℚ) : Account :=
  ⟨event.id, if event.occurred ≤ w.arrives ∧ w.arrives ≤ t ∧
      w.about = event.id ∧ accepted = true then w.identifies else none⟩

def remainingVolume (V r : ℚ) : ℚ := V - r*V

def returnedVolume (V r : ℚ) : ℚ := remainingVolume V r + r*V

def returnedMarker (V r old incoming : ℚ) : ℚ :=
  remainingVolume V r * old + r*V*incoming

def sharpPush (slope : ℚ) := max 0 (slope-1)

def energy2 (velocity : ℚ × ℚ) : ℚ :=
  (velocity.1^2 + velocity.2^2)/2

/-- Each circuit reads the state returned by the previous circuit before
    choosing its displacement. A restart at a checkpoint preserves the full
    continuation under the same read, advance and branch rules. -/
def circuits {S D : Type*} (readDir : S → D) (advance : D → S → S) : Nat → S → S
  | 0, s => s
  | n+1, s => circuits readDir advance n (advance (readDir s) s)

end MeetingThread
