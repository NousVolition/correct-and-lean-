/- Exact finite records. No fluid state, curve, solver, or trajectory is defined here. -/
namespace ThresholdOneRecords

inductive Window where
  | forward075 | forward150 | forward300 | both075 | both150 | both300
  deriving DecidableEq, Repr

def windows : List Window :=
  [.forward075, .forward150, .forward300, .both075, .both150, .both300]

/-- Bounds in quarter cube lengths, relative to A. -/
def bounds : Window → Int × Int
  | .forward075 => (0, 3)
  | .forward150 => (0, 6)
  | .forward300 => (0, 12)
  | .both075 => (-3, 3)
  | .both150 => (-6, 6)
  | .both300 => (-12, 12)

def inclusions : List (Window × Window) :=
  (windows.flatMap fun small => windows.map fun large => (small, large)).filter
    (fun (small, large) => decide (small ≠ large ∧
      (bounds large).1 ≤ (bounds small).1 ∧ (bounds small).2 ≤ (bounds large).2))

structure Reading where
  s : Int
  gap : Nat
  candidates : List (Int × Nat)

structure Sample where
  label : String
  stamp : Nat
  forward075 : Reading
  forward150 : Reading
  forward300 : Reading
  both075 : Reading
  both150 : Reading
  both300 : Reading

def Sample.read (r : Sample) : Window → Reading
  | .forward075 => r.forward075
  | .forward150 => r.forward150
  | .forward300 => r.forward300
  | .both075 => r.both075
  | .both150 => r.both150
  | .both300 => r.both300

def backwardWindows : List Window := [.both075, .both150, .both300]

def inBounds (scale : Nat) (w : Window) (s : Int) : Bool :=
  decide ((bounds w).1 * (scale : Int) ≤ 4 * s ∧
    4 * s ≤ (bounds w).2 * (scale : Int))

/-- Minimum only among the explicitly recorded candidates, not along a curve. -/
def savedMinimum (r : Reading) : Bool :=
  r.candidates.contains (r.s, r.gap) &&
  r.candidates.all (fun candidate => decide (r.gap ≤ candidate.2))

end ThresholdOneRecords
