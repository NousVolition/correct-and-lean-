import AppleFlowDefinitions
import Mathlib.Analysis.ODE.ExistUnique

namespace HugV3.Source.AppleExistence
noncomputable section
open Set Metric
open scoped NNReal

/-- One index for each scalar coordinate, preserving the source's full State. -/
inductive Coordinate where
  | grid : Grid → Fin 5 → Coordinate
  | position : Particle → Axis → Coordinate
  | fabric : Particle → Axis → Axis → Coordinate
  | directional : Particle → Direction → Fin 2 → Coordinate
  | cell : Cell → Coordinate
  | accumulator : Coordinate
  | ledger : Fin 4 → Coordinate
  | writing : Coordinate
  | expression : Actor → Fin 2 → Coordinate
  | context : Actor → Fin 2 → Coordinate
  | center : Actor → Fin 2 → Coordinate
  | radius : Actor → Actor → Coordinate
  | relation : Actor → Actor → Fin 3 → Coordinate
  | responses : Actor → Actor → Fin 7 → Coordinate
  | association : Actor → Actor → Fin 3 → Coordinate
  deriving Fintype, DecidableEq

abbrev Coordinates := Coordinate → ℝ

def pack (s : State) : Coordinates
  | .grid x j => s.g x j
  | .position p i => s.X p i
  | .fabric p i j => s.F p i j
  | .directional p k a => s.m p k a
  | .cell l => s.b l
  | .accumulator  => s.A
  | .ledger k => s.ledger k
  | .writing  => s.writeWork
  | .expression i k => s.expression i k
  | .context i k => s.context i k
  | .center i k => s.normCenter i k
  | .radius i j => s.logRadius i j
  | .relation i j k => s.relation i j k
  | .responses i j k => s.responses i j k
  | .association i j k => s.association i j k

def unpack (v : Coordinates) : State where
  g := fun x j => v (.grid x j)
  X := fun p i => v (.position p i)
  F := fun p i j => v (.fabric p i j)
  m := fun p k a => v (.directional p k a)
  b := fun l => v (.cell l)
  A := v  .accumulator
  ledger := fun k => v (.ledger k)
  writeWork := v  .writing
  expression := fun i k => v (.expression i k)
  context := fun i k => v (.context i k)
  normCenter := fun i k => v (.center i k)
  logRadius := fun i j => v (.radius i j)
  relation := fun i j k => v (.relation i j k)
  responses := fun i j k => v (.responses i j k)
  association := fun i j k => v (.association i j k)

/-- Outside the successful domain this total function has an arbitrary default.
Every use to infer a physical rate also requires the actual Option-valued RHS to succeed. -/
def fullRate (t : ℝ) (x : Coordinates) : Coordinates :=
  ((rhs sourceGeometry t (unpack x)).map pack).getD 0

structure Tube (k : ℕ) where
  center : ℝ → Coordinates
  slope : ℝ → Coordinates
  width : ℝ≥0
  entryError : ℝ≥0
  defect : ℝ≥0
  speed : ℝ≥0
  lip : ℝ≥0

def Tube.error {k : ℕ} (B : Tube k) (t : ℝ) : ℝ :=
  gronwallBound B.entryError B.lip B.defect (t-time k)

def Tube.region {k : ℕ} (B : Tube k) : Set (ℝ × Coordinates) :=
  {q | q.1 ∈ Icc (time k) (time (k+1)) ∧ q.2 ∈ closedBall (B.center q.1) (B.width:ℝ)}

/-- All conditions concern explicit functions and regions, independently of exact trajectories. -/
structure Bounds {k : ℕ} (B : Tube k) : Prop where
  center_deriv : ∀ t ∈ Icc (time k) (time (k+1)),
    HasDerivWithinAt B.center (B.slope t) (Icc (time k) (time (k+1))) t
  defined : ∀ q ∈ B.region, ∃ d, rhs sourceGeometry q.1 (unpack q.2)=some d
  regular : ContinuousOn (fun q : ℝ × Coordinates => fullRate q.1 q.2) B.region
  spatial : ∀ t ∈ Icc (time k) (time (k+1)),
    LipschitzOnWith B.lip (fullRate t) (closedBall (B.center t) (B.width:ℝ))
  bounded : ∀ q ∈ B.region, ‖fullRate q.1 q.2‖ ≤ B.speed
  residual : ∀ t ∈ Ico (time k) (time (k+1)), dist (B.slope t) (fullRate t (B.center t)) ≤ B.defect
  interior : ∀ t ∈ Icc (time k) (time (k+1)), B.error t < B.width

/-- Every boundary is the source's Option-valued reset, including both saved fabric snapshots. -/
structure ScheduleCertificate where
  tube : ∀ k : ℕ, Tube k
  entry : ℕ → Set FullState
  initial : initialFull ∈ entry 0
  bounds : ∀ k<5, Bounds (tube k)
  starts_close : ∀ k<5, ∀ y ∈ entry k,
    dist (pack y.state) ((tube k).center (time k)) ≤ (tube k).entryError
  reset : ∀ k<5, ∀ y ∈ entry k, ∀ z : Coordinates,
    dist z ((tube k).center (time (k+1))) ≤ (tube k).error (time (k+1)) →
    ∃ w ∈ entry (k+1), boundary (k+1) ⟨unpack z,y.starts⟩=some w

def PackedSegment (k : ℕ) (x : ℝ → Coordinates) : Prop :=
  ∀ t ∈ Icc (time k) (time (k+1)), ∃ d : State,
    rhs sourceGeometry t (unpack (x t))=some d ∧
    HasDerivWithinAt x (pack d) (Icc (time k) (time (k+1))) t

def CarrierAgreement (R : ℝ≥0) (φ ψ : Vec × ℝ → Vec) : Prop :=
  EqOn φ ψ (closedBall 0 (R:ℝ) ×ˢ Icc (time 0) (time 5))

/-- The unique source trace and a unique passive carrier on the observed domain.
The latitude homotopy is an existence claim. -/
def FullApple (R : ℝ≥0) : Prop := ∃ tr : Trace, Solves tr ∧
  (∀ other, Solves other → Agreement tr other) ∧
  ∃ φ, AppleBand.MaterialFlowAcross tr R φ ∧
    AppleBand.MovingContraction (fun r z => φ (z,(r:ℝ)*time 5)) ∧
    ∀ ψ, AppleBand.MaterialFlowAcross tr R ψ → CarrierAgreement R φ ψ

end
end HugV3.Source.AppleExistence
