import Mathlib.Data.Real.Basic
import Mathlib.Order.Interval.Set.Basic
import Mathlib.Tactic

/- Generic assembly of complete-state trajectories. The segment law must be
   supplied and justified for the actual model. Nothing here assumes that a
   name, source hash or callback already represents the V3 equations. -/
namespace Hybrid
noncomputable section
open Set

structure System (E : Type*) where
  time : ℕ → ℝ
  law : ℕ → (ℝ → E) → Prop
  admissible : ℕ → E → Prop
  boundary : ℕ → E → Option E

def interval {E : Type*} (S : System E) (k : ℕ) : Set ℝ :=
  Icc (S.time k) (S.time (k+1))

def Segment {E : Type*} (S : System E) (k : ℕ) (start : E) (path : ℝ → E) : Prop :=
  path (S.time k) = start ∧ S.law k path

def Step {E : Type*} (S : System E) (k : ℕ) (start : E)
    (path : ℝ → E) (next : E) : Prop :=
  Segment S k start path ∧
  S.boundary (k+1) (path (S.time (k+1))) = some next ∧
  S.admissible (k+1) next

structure Trace (E : Type*) where
  after : ℕ → E
  path : ℕ → ℝ → E

def IsTrace {E : Type*} (S : System E) (N : ℕ) (initial : E) (tr : Trace E) : Prop :=
  tr.after 0 = initial ∧
  (∀ k ≤ N, S.admissible k (tr.after k)) ∧
  ∀ k < N, Step S k (tr.after k) (tr.path k) (tr.after (k+1))

-- Equality is asserted on the actual intervals and boundary states only.
-- No uniqueness is claimed for unused path values outside the horizon.
def Agreement {E : Type*} (S : System E) (N : ℕ) (a b : Trace E) : Prop :=
  (∀ k ≤ N, a.after k = b.after k) ∧
  ∀ k < N, EqOn (a.path k) (b.path k) (interval S k)

def Ordered {E : Type*} (S : System E) (N : ℕ) : Prop :=
  ∀ k < N, S.time k ≤ S.time (k+1)

-- Explicit unresolved analytic obligations for a concrete model.
def SegmentUniqueness {E : Type*} (S : System E) (N : ℕ) : Prop :=
  ∀ k < N, ∀ start, S.admissible k start → ∀ a b,
    Segment S k start a → Segment S k start b → EqOn a b (interval S k)

def StepSolvability {E : Type*} (S : System E) (N : ℕ) : Prop :=
  ∀ k < N, ∀ start, S.admissible k start →
    ∃ pair : (ℝ → E) × E, Step S k start pair.1 pair.2

end
end Hybrid
