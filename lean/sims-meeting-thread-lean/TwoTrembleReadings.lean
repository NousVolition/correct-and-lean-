import Lean
import TwoTrembleModel

namespace MeetingThread.TwoTrembles

open Lean Elab Term in
local elab "trembleCells% " input:term : term => do
  let .lit (.strVal contents) ← elabTerm input (some (mkConst ``String))
    | throwError "expected a literal trial table"
  return toExpr (((contents.replace "\r\n" "\n").trimAscii.toString.splitOn "\n").map (·.splitOn "\t"))

def cells : List (List String) :=
  trembleCells% (include_str "observations/two-trembles/readings.tsv")

inductive Arm | direct | replay deriving DecidableEq
inductive Kind | sound | landmark | generic deriving DecidableEq, BEq
inductive BReport | picked (m : Moment) | undecided | invalid deriving DecidableEq

structure Reading where
  world : String
  actions : OrderedMarks
  sounds : OrderedMarks
  clue : WitnessClue
  target : Moment
  direct : BReport
  replay : BReport

private def parseMark : String → Option Mark
  | "A" => some .a
  | "B" => some .b
  | _ => none

private def parseMoment : String → Option Moment
  | "EARLIER" => some .earlier
  | "LATER" => some .later
  | _ => none

private def parseAnswer : String → Option BReport
  | "EARLIER" => some (.picked .earlier)
  | "LATER" => some (.picked .later)
  | "OPEN" => some .undecided
  | "INVALID" => some .invalid
  | _ => none

private def parseClue : String → String → Option WitnessClue
  | "sound", x => (parseMark x).map WitnessClue.sound
  | "landmark", x => (parseMark x).map WitnessClue.landmark
  | "generic", "-" => some .generic
  | _, _ => none

def parseRow : List String → Option Reading
  | [world, kind, a₁, a₂, s₁, s₂, mark, target, direct, replay] => do
    return ⟨world, ⟨← parseMark a₁, ← parseMark a₂⟩, ⟨← parseMark s₁, ← parseMark s₂⟩,
      ← parseClue kind mark, ← parseMoment target, ← parseAnswer direct, ← parseAnswer replay⟩
  | _ => none

def readings : List Reading := cells.tail.filterMap parseRow

def Reading.kind (r : Reading) : Kind :=
  match r.clue with
  | .sound _ => .sound
  | .landmark _ => .landmark
  | .generic => .generic

def observed (r : Reading) : Arm → BReport
  | .direct => r.direct
  | .replay => r.replay

def predicted (r : Reading) (arm : Arm) : BReport :=
  let v := match arm with
    | .direct => directView r.actions r.sounds
    | .replay => replayView r.actions r.sounds
  match resolve v r.clue with
  | none => .undecided
  | some m => .picked m

structure Counts where
  targetMatches : Nat
  wrongSlot : Nat
  openReports : Nat
  invalidReports : Nat
  deriving DecidableEq

def counts (kind : Kind) (arm : Arm) : Counts :=
  let rows := readings.filter (fun r => r.kind == kind)
  ⟨(rows.filter fun r => decide (observed r arm = .picked r.target)).length,
   (rows.filter fun r => match observed r arm with
     | .picked m => decide (m ≠ r.target)
     | _ => false).length,
   (rows.filter fun r => decide (observed r arm = .undecided)).length,
   (rows.filter fun r => decide (observed r arm = .invalid)).length⟩

def completeWorld (world : String) : Bool :=
  [Kind.sound, .landmark, .generic].all fun kind =>
    (readings.filter fun r => r.world == world && r.kind == kind).length == 1

end MeetingThread.TwoTrembles
