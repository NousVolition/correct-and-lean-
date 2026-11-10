/-! Two pocket trembles occur in order. The witness can mention a shared
    background sound or a publicly remembered action, or leave both unspecified.
    A witness clue contains no episode ID, ordinal or target answer. -/
namespace MeetingThread.TwoTrembles

inductive Moment | earlier | later deriving DecidableEq, Repr
inductive Mark | a | b deriving DecidableEq, BEq, Repr

/-- The two letters name features within one scene. Either feature can occur
    at either moment. Equal features are also allowed. -/
structure OrderedMarks where
  earlier : Mark
  later : Mark
  deriving DecidableEq, Repr

def OrderedMarks.atMoment (marks : OrderedMarks) : Moment → Mark
  | .earlier => marks.earlier
  | .later => marks.later

structure Inventory where
  heardA : Bool
  heardB : Bool
  deriving DecidableEq, Repr

def inventory (sounds : OrderedMarks) : Inventory :=
  ⟨sounds.earlier == .a || sounds.later == .a, sounds.earlier == .b || sounds.later == .b⟩

def Inventory.heard (sounds : Inventory) : Mark → Bool
  | .a => sounds.heardA
  | .b => sounds.heardB

structure View where
  actions : OrderedMarks
  soundsHeard : Inventory
  soundOrder : Option OrderedMarks
  deriving DecidableEq, Repr

def directView (actions sounds : OrderedMarks) : View :=
  ⟨actions, inventory sounds, none⟩

def replayView (actions sounds : OrderedMarks) : View :=
  ⟨actions, inventory sounds, some sounds⟩

inductive WitnessClue
  | sound (value : Mark)
  | landmark (value : Mark)
  | generic
  deriving DecidableEq, Repr

/-- With an unordered sound inventory, a sound heard during the wait is
    compatible with either moment. An unheard sound matches neither. -/
def compatible (v : View) (w : WitnessClue) (m : Moment) : Bool :=
  match w with
  | .sound s =>
    match v.soundOrder with
    | some sounds => sounds.atMoment m == s
    | none => v.soundsHeard.heard s
  | .landmark action => v.actions.atMoment m == action
  | .generic => true

/-- Return an episode only when the available clue has a unique match.
    The evaluator's known target is not an input. -/
def resolve (v : View) (w : WitnessClue) : Option Moment :=
  match compatible v w .earlier, compatible v w .later with
  | true, false => some .earlier
  | false, true => some .later
  | _, _ => none

end MeetingThread.TwoTrembles
