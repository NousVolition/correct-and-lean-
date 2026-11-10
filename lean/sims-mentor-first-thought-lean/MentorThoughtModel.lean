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

namespace Sweep

structure Sample where
  prime : String
  episode : String
  certainty : String
  feeling : String
  source : String
  judgment : String
  grounded : String
  deriving DecidableEq

def sweepCells : List (List String) := reportCells% (include_str "prime-sweep/readings.tsv")

def parseSample : List String → Option Sample
  | [prime,episode,certainty,feeling,source,judgment,grounded] =>
    some ⟨prime,episode,certainty,feeling,source,judgment,grounded⟩
  | _ => none

def samples := sweepCells.tail.filterMap parseSample

def atPrime (p : Nat) := samples.filter (fun r => r.prime == toString p)

def identified (r : Sample) : Bool :=
  r.source == "PAGER" && r.judgment == "IDENTIFIED" && r.grounded == "yes"

def ownFeeling (r : Sample) : Bool :=
  r.feeling == "personal_mention" || r.feeling == "recollection"

def counts (test : Sample → Bool) : List Nat :=
  labels.map (fun p => ((atPrime p).filter test).length)

def locations (test : Sample → Bool) : List (String × String) :=
  (samples.filter test).map (fun r => (r.prime,r.episode))

end Sweep

namespace Continuing

structure Observation where
  prime : String
  offsetUs : String
  session : String
  freeTurn : String
  statusTurn : String
  freeCertainty : String
  freeFeeling : String
  source : String
  judgment : String
  grounded : String
  statusFeeling : String
  deriving DecidableEq

def trackCells : List (List String) := reportCells% (include_str "one-traveller/readings.tsv")

def parseObservation : List String → Option Observation
  | [p,offset,session,freeTurn,statusTurn,certainty,freeFeeling,source,judgment,grounded,statusFeeling] =>
    some ⟨p,offset,session,freeTurn,statusTurn,certainty,freeFeeling,source,judgment,grounded,statusFeeling⟩
  | _ => none

def track := trackCells.tail.filterMap parseObservation

def turnIds := track.flatMap (fun r => [r.freeTurn,r.statusTurn])

def own (grade : String) := grade == "personal_mention" || grade == "recollection"

end Continuing
end MentorThought
