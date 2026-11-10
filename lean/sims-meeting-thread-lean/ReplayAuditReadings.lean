import Lean
import ReplayAuditModel
import TwoTrembleReadings

namespace MeetingThread.ReplayAudit
open TwoTrembles

open Lean Elab Term in
local elab "reversalCells% " input:term : term => do
  let .lit (.strVal contents) ← elabTerm input (some (mkConst ``String))
    | throwError "expected the paired trial table"
  return toExpr (((contents.replace "\r\n" "\n").trimAscii.toString.splitOn "\n").map (·.splitOn "\t"))

def tableCells : List (List String) :=
  reversalCells% (include_str "observations/reversed-replay/readings.tsv")

inductive Order | faithful | reversed deriving BEq, DecidableEq
inductive Followup | linked | unlinked deriving DecidableEq

structure Continuation where
  answer : BReport
  explicitNotice : Bool

structure Trial where
  world : String
  order : Order
  target : Moment
  mentionedAction : Mark
  mentionedSound : Mark
  initial : BReport
  linked : Continuation
  unlinked : Continuation

private def decodeAnswer : String → Option BReport
  | "EARLIER" => some (.picked .earlier)
  | "LATER" => some (.picked .later)
  | "OPEN" => some .undecided
  | "INVALID" => some .invalid
  | _ => none

private def decodeNotice : String → Option Bool
  | "EXPLICIT" => some true
  | "NOT_EXPLICIT" => some false
  | _ => none

private def decodeOrder : String → Option Order
  | "faithful" => some .faithful
  | "reversed" => some .reversed
  | _ => none

private def decodeMoment : String → Option Moment
  | "EARLIER" => some .earlier
  | "LATER" => some .later
  | _ => none

private def decodeMark : String → Option Mark
  | "A" => some .a
  | "B" => some .b
  | _ => none

def decode : List String → Option Trial
  | [world, ord, target, action, sound, first, linked, linkedNotice, unlinked, unlinkedNotice] => do
    return ⟨world, ← decodeOrder ord, ← decodeMoment target, ← decodeMark action, ← decodeMark sound, ← decodeAnswer first,
      ⟨← decodeAnswer linked, ← decodeNotice linkedNotice⟩,
      ⟨← decodeAnswer unlinked, ← decodeNotice unlinkedNotice⟩⟩
  | _ => none

def trials : List Trial := tableCells.tail.filterMap decode

def Trial.afterDetail (r : Trial) : Followup → Continuation
  | .linked => r.linked
  | .unlinked => r.unlinked

def orderedTrials (order : Order) := trials.filter (fun r => r.order == order)

def initiallyWrong (rows : List Trial) : List Trial :=
  rows.filter fun r => decide (r.initial = .picked (opposite r.target))

def tally (rows : List Trial) (getAnswer : Trial → BReport) : Counts :=
  ⟨(rows.filter fun r => decide (getAnswer r = .picked r.target)).length,
   (rows.filter fun r => decide (getAnswer r = .picked (opposite r.target))).length,
   (rows.filter fun r => decide (getAnswer r = .undecided)).length,
   (rows.filter fun r => decide (getAnswer r = .invalid)).length⟩

def firstCounts (order : Order) : Counts := tally (orderedTrials order) Trial.initial

def followingCounts (rows : List Trial) (kind : Followup) : Counts :=
  tally rows (fun r => (r.afterDetail kind).answer)

def explicitCount (rows : List Trial) (kind : Followup) : Nat :=
  (rows.filter fun r => (r.afterDetail kind).explicitNotice).length

def bothOrdersPresent (world : String) : Bool :=
  [Order.faithful, .reversed].all fun order =>
    ((orderedTrials order).filter fun r => r.world == world).length == 1

def originalWorld (r : Trial) : Option TwoTrembles.Reading :=
  TwoTrembles.readings.find? (fun s => s.world == r.world && s.kind == .sound)

def originalTargetPreserved (r : Trial) : Bool :=
  match originalWorld r with
  | none => false
  | some s => decide (s.target = r.target)

def presentedView (r : Trial) (s : TwoTrembles.Reading) : View :=
  replayView s.actions (match r.order with | .faithful => s.sounds | .reversed => swap s.sounds)

def toReport (candidate : Option Moment) : BReport :=
  (candidate.map BReport.picked).getD .undecided

/-- Join the six original worlds by their retained study key for scoring.
    The initial choice rule sees only the supplied view and the original clue. -/
def firstFitsOriginalModel (r : Trial) : Bool :=
  match originalWorld r with
  | none => false
  | some s =>
    decide (r.initial = toReport (resolve (presentedView r s) s.clue))

/-- The added features are taken from the supplied action detail. The true
    target is not used to construct either policy's choice. -/
def policyFitsLinkedAnswer (policy : Evidence → Option Moment) (r : Trial) : Bool :=
  match originalWorld r with
  | some s =>
    match s.clue with
    | .sound w =>
      let evidence := assess (presentedView r s) w (.linked r.mentionedSound r.mentionedAction)
      decide (r.linked.answer = toReport (policy evidence))
    | _ => false
  | none => false

end MeetingThread.ReplayAudit
