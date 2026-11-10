import Mathlib.Data.Nat.Prime.Defs
import Mathlib.Data.Rat.Defs

namespace HugPrimeMeter

/-- Every recorded energy in this experiment is an integer multiple of 2⁻⁷⁷. -/
def unitDen : Int := 2 ^ 77

def hugUnits (n : Int) : ℚ := (n : ℚ) / (unitDen : ℚ)

structure WriteCost where
  work : Int
  heat : Int
  stored : Int
  deriving BEq, DecidableEq, Repr

structure Ledger where
  sourceWork : Int
  squeezeWork : Int
  breathingWork : Int
  writeWork : Int
  energy : Int
  residual : Int
  deriving BEq, DecidableEq, Repr

inductive Phase
  | atTick | beforeWrite | afterWrite | beforeFourth | afterFourth
  deriving BEq, DecidableEq, Repr

structure TickRow where
  tenth : Nat
  label : Nat
  mentor : Nat
  traveler : Nat
  extended : Bool
  phase : Phase
  threeCount : Nat
  fourCount : Nat
  startingEnergy : Int
  three : Ledger
  four : Ledger
  threeExpected : Int
  fourExpected : Int
  fourMinusThree : Int
  fourthCost : Option WriteCost
  deriving Repr

/-- Fields transcribed independently from each saved arm's simulation receipt. -/
structure Receipt where
  initialEnergy : Int
  eventId : Nat
  slot : Nat
  eventStart : Nat
  eventEnd : Nat
  endpoint : Nat
  cost : WriteCost
  before59 : Ledger
  after59 : Ledger
  three157 : Ledger
  four157 : Ledger
  deriving Repr

/-- Nearest-even rounding to 53 significant binary digits on this exact grid.
    The checked data are zero or finite normal binary64 values. -/
def round53 (x : Int) : Int :=
  let n := x.natAbs
  let spacing := 2 ^ (n.log2 + 1 - 53)
  let q := n / spacing
  let twiceRemainder := 2 * (n % spacing)
  let rounded := if twiceRemainder > spacing ∨ (twiceRemainder = spacing ∧ q % 2 = 1)
    then (q + 1) * spacing else q * spacing
  if x < 0 then -(rounded : Int) else (rounded : Int)

def workSum (l : Ledger) : Int :=
  round53 (l.sourceWork + l.squeezeWork + l.breathingWork + l.writeWork)

/-- These operations replay the printed expected energy and signed residual
    exactly for the archived rows, including intermediate binary rounding. -/
def goodBalance (initial reportedExpected : Int) (l : Ledger) : Bool :=
  reportedExpected == round53 (initial + workSum l) &&
  l.residual == round53 (round53 (l.energy - initial) - workSum l)

def labels : List Nat := [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,
  61,67,71,73,79,83,89,97,101,103,107,109,113,127,131,137,139,149,151,157]

def phases (i : Nat) : List Phase :=
  if i = 4 ∨ i = 8 ∨ i = 12 then [.beforeWrite, .afterWrite]
  else if i = 16 then [.beforeFourth, .afterFourth] else [.atTick]

def schedule : List (Nat × Phase) :=
  (List.range 37).flatMap fun i => (phases i).map fun p => (i, p)

def goodRow (receipt : Receipt) (r : TickRow) : Bool :=
  let beforeBranch := r.tenth < 16 || r.phase == .beforeFourth
  let afterBranch := r.tenth > 16 || r.phase == .afterFourth
  labels[r.tenth]? == some r.label &&
  r.mentor == 25 * r.tenth && r.traveler == 32 * r.tenth &&
  r.extended == decide (16 < r.tenth) &&
  r.startingEnergy == receipt.initialEnergy &&
  goodBalance r.startingEnergy r.threeExpected r.three &&
  goodBalance r.startingEnergy r.fourExpected r.four &&
  r.fourMinusThree == r.four.residual - r.three.residual &&
  (!beforeBranch || (r.three == r.four && r.threeCount == r.fourCount)) &&
  (!afterBranch || (r.threeCount == 3 && r.fourCount == 4)) &&
  r.fourthCost == (if r.phase == .afterFourth then some receipt.cost else none)

def includesReading (rows : List TickRow) (label : Nat) (phase : Phase)
    (three four : Ledger) : Bool :=
  rows.any fun r => r.label == label && r.phase == phase && r.three == three && r.four == four

def goodRun (rows : List TickRow) (r : Receipt) : Bool :=
  rows.map (fun x => (x.tenth, x.phase)) == schedule &&
  rows.all (goodRow r) &&
  r.eventId == 3 && r.slot == 3 && r.eventStart == 12 && r.eventEnd == 16 && r.endpoint == 36 &&
  includesReading rows 59 .beforeFourth r.before59 r.before59 &&
  includesReading rows 59 .afterFourth r.before59 r.after59 &&
  includesReading rows 157 .atTick r.three157 r.four157

/-- An integer printout in decimal units of 10⁻ᵖ has less than half a last digit of error. -/
def roundsTo (value : Int) (p : Nat) (printed : Int) : Prop :=
  2 * (value * 10 ^ p - printed * unitDen).natAbs < unitDen.natAbs

instance (v : Int) (p : Nat) (d : Int) : Decidable (roundsTo v p d) :=
  inferInstanceAs (Decidable (_ < _))

end HugPrimeMeter
