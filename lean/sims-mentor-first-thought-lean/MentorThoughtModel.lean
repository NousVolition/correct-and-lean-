import Lean

/-! A prime is a label for a shared instant on the listener and mentor clocks.
The finite report table contains recorded answers and reviewed textual grades. -/
namespace MentorThought

def shared (listener mentor : Nat) : Prop := 250 * listener = 320 * mentor

def primeLabel (p : Nat) : Bool :=
  2 ≤ p && (List.range (p - 2)).all (fun i => p % (i + 2) != 0)

def labels : List Nat := (List.range 42).filter primeLabel

structure Tick where
  label : Nat
  listener : Nat
  mentor : Nat
  offsetUs : Nat
  deriving DecidableEq

def schedule : List Tick :=
  labels.zipIdx.map (fun (p,i) => ⟨p, 32*i, 25*i, 100000*i⟩)

open Lean Elab Term in
local elab "reportCells% " input:term : term => do
  let .lit (.strVal raw) ← elabTerm input (some (mkConst ``String))
    | throwError "expected the literal room table"
  let lines := (raw.replace "\r\n" "\n").trimAscii.toString.splitOn "\n"
  return toExpr (lines.map (·.splitOn "\t"))

def cells : List (List String) := reportCells% (include_str "readings.tsv")

structure Report where
  episode : String
  wording : String
  firstTick : String
  sourceTick : String
  grade : String
  source : String
  judgment : String
  deriving DecidableEq

def parseReport : List String → Option Report
  | [episode,wording,firstTick,sourceTick,grade,source,judgment] =>
    some ⟨episode,wording,firstTick,sourceTick,grade,source,judgment⟩
  | _ => none

def reports : List Report := cells.tail.filterMap parseReport

def countIn (wording : String) (test : Report → Bool) : Nat :=
  (reports.filter (fun r => r.wording == wording && test r)).length

def personallyMentioned (r : Report) : Bool := r.grade == "personal_mention" || r.grade == "recollection"

def pagerIdentified (r : Report) : Bool := r.source == "PAGER" && r.judgment == "IDENTIFIED"

end MentorThought
