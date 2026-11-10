import Lean

namespace MeetingThread.PagerReturn

structure BranchReadings where
  before : String
  matched : String
  grounded : String
  different : String
  motif : String
  deriving DecidableEq

structure PairedReading where
  episode : String
  originalMotif : String
  initial : String
  direct : BranchReadings
  replay : BranchReadings
  deriving DecidableEq

/- Parse only the input cells at elaboration. The kernel receives ordinary lists
of string literals and checks all claims about them with its own reduction. -/
open Lean Elab Term in
local elab "readingCells% " input:term : term => do
  let .lit (.strVal raw) ← elabTerm input (some (mkConst ``String))
    | throwError "expected a literal table"
  let lines := (raw.replace "\r\n" "\n").trimAscii.toString.splitOn "\n"
  return toExpr (lines.map (·.splitOn "\t"))

def readingCells : List (List String) :=
  readingCells% (include_str "observations/pager-return/readings.tsv")

def parseReading (cells : List String) : Option PairedReading :=
  match cells with
  | [episode, motif, initial, dBefore, dMatch, dGrounded, dOther, dMotif,
      rBefore, rMatch, rGrounded, rOther, rMotif] =>
    some ⟨episode, motif, initial, ⟨dBefore, dMatch, dGrounded, dOther, dMotif⟩,
      ⟨rBefore, rMatch, rGrounded, rOther, rMotif⟩⟩
  | _ => none

def readings : List PairedReading := readingCells.tail.filterMap parseReading

def groundedPager (r : BranchReadings) : Bool :=
  r.matched == "PAGER/IDENTIFIED" && r.grounded == "yes"

def openControls (r : BranchReadings) : Bool :=
  r.before == "UNKNOWN/OPEN" && r.different == "UNKNOWN/OPEN"

end MeetingThread.PagerReturn
