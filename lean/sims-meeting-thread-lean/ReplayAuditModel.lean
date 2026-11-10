import TwoTrembleModel

namespace MeetingThread.ReplayAudit
open TwoTrembles

def swap (marks : OrderedMarks) : OrderedMarks := ⟨marks.later, marks.earlier⟩

def opposite : Moment → Moment
  | .earlier => .later
  | .later => .earlier

/-- Both forms name the same two features. Only the linked memory places
    the sound at a particular action. Neither form contains an episode ID. -/
inductive ActionDetail
  | linked (sound action : Mark)
  | unlinked (sound action : Mark)
  deriving DecidableEq

def actionChoice (v : View) (witnessSound : Mark) : ActionDetail → Option Moment
  | .linked sounded action =>
    if sounded == witnessSound then resolve v (.landmark action) else none
  | .unlinked _ _ => none

structure Evidence where
  fromSound : Option Moment
  fromAction : Option Moment
  deriving DecidableEq

def assess (v : View) (sound : Mark) (detail : ActionDetail) : Evidence :=
  ⟨resolve v (.sound sound), actionChoice v sound detail⟩

def Evidence.conflict (e : Evidence) : Bool :=
  match e.fromSound, e.fromAction with
  | some a, some b => decide (a ≠ b)
  | _, _ => false

/-- This decision policy leaves incompatible determinate candidates open. -/
def Evidence.withholdOnConflict (e : Evidence) : Option Moment :=
  if e.conflict then none else e.fromSound.orElse (fun _ => e.fromAction)

/-- This policy gives priority to the action link when that source is trusted. -/
def Evidence.trustAction (e : Evidence) : Option Moment :=
  e.fromAction.orElse (fun _ => e.fromSound)

end MeetingThread.ReplayAudit
