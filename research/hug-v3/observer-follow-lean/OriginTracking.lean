import Std

namespace OriginTracking

inductive Class where
  | stayed | left | returned | arrived | visited | outside
  deriving DecidableEq, Repr

/-- A classification of finite observations, not continuous-time residence. -/
def classifyFlags (entry exit throughout ever : Bool) : Class :=
  if entry then
    if exit then (if throughout then .stayed else .returned) else .left
  else if exit then .arrived else if ever then .visited else .outside

structure History where
  id : Nat
  bits : Nat
  deriving DecidableEq, Repr

/-- Bit zero is entry. Bit `steps` is the last recorded step. -/
def classify (h : History) (steps : Nat) : Class :=
  classifyFlags (h.bits % 2 == 1) ((h.bits / 2^steps) % 2 == 1)
    (h.bits == 2^(steps+1)-1) (h.bits != 0)

def counts (hs : List History) (steps : Nat) : List Nat :=
  [.stayed, .left, .returned, .arrived, .visited, .outside].map fun c =>
    (hs.filter fun h => classify h steps == c).length

theorem present_throughout_classifies_as_stayed :
    classifyFlags true true true true = .stayed := rfl

theorem original_absent_at_exit_classifies_as_left (throughout ever : Bool) :
    classifyFlags true false throughout ever = .left := rfl

theorem returning_original_is_not_new :
    classifyFlags true true false true = .returned ∧
    classifyFlags true true false true ≠ .arrived := by decide

theorem outsider_present_at_exit_is_arrival (throughout ever : Bool) :
    classifyFlags false true throughout ever = .arrived := rfl

theorem visited_and_left_is_not_never_seen :
    classifyFlags false false false true = .visited ∧
    classifyFlags false false false true ≠ .outside := by decide

theorem stayed_implies_entry_and_exit (entry exit throughout ever : Bool)
    (h : classifyFlags entry exit throughout ever = .stayed) :
    entry = true ∧ exit = true := by
  cases entry <;> cases exit <;> cases throughout <;> cases ever <;>
    simp_all [classifyFlags]

/-- A label outside one view can remain in the complete recorded universe. -/
theorem leaving_view_need_not_destroy_identity :
    (25 ∈ ([25, 26] : List Nat)) ∧ ¬ (25 ∈ ([26] : List Nat)) := by decide

theorem unchanged_count_need_not_preserve_members :
    ([25] : List Nat).length = ([26] : List Nat).length ∧
    ¬ (25 ∈ ([26] : List Nat)) := by decide

/-- Common-denominator signed decimal numerators. C is not water mass. -/
structure Account where
  entry : Int
  oldInside : Int
  oldOutside : Int
  incoming : Int
  added : Int
  current : Int
  deriving DecidableEq, Repr

def Account.originDefect (a : Account) : Int := a.entry-a.oldInside-a.oldOutside
def Account.mixtureDefect (a : Account) : Int := a.current-a.oldInside-a.incoming-a.added
def Within (a : Account) (tolerance : Nat) : Prop :=
  a.originDefect.natAbs ≤ tolerance ∧ a.mixtureDefect.natAbs ≤ tolerance
instance (a : Account) (t : Nat) : Decidable (Within a t) := by unfold Within; infer_instance

theorem conserved_origin_may_be_elsewhere :
    (Account.mk 10 6 4 3 1 10).originDefect = 0 ∧
    (Account.mk 10 6 4 3 1 10).oldInside < (Account.mk 10 6 4 3 1 10).entry := by decide

theorem unchanged_total_can_include_replacement :
    (Account.mk 10 6 4 3 1 10).mixtureDefect = 0 ∧
    (Account.mk 10 6 4 3 1 10).current = (Account.mk 10 6 4 3 1 10).entry ∧
    (Account.mk 10 6 4 3 1 10).incoming + (Account.mk 10 6 4 3 1 10).added > 0 := by decide

theorem balanced_departure_reduces_original_inside (a : Account)
    (balance : a.originDefect = 0) (departure : 0 < a.oldOutside) :
    a.oldInside < a.entry := by unfold Account.originDefect at balance; omega

theorem balanced_new_origins_raise_current_above_old (a : Account)
    (balance : a.mixtureDefect = 0) (arrival : 0 < a.incoming+a.added) :
    a.oldInside < a.current := by unfold Account.mixtureDefect at balance; omega

theorem equal_total_balances_departure_and_arrival (a : Account)
    (origin : a.originDefect = 0) (mixture : a.mixtureDefect = 0)
    (same : a.current = a.entry) : a.oldOutside = a.incoming+a.added := by
  unfold Account.originDefect at origin
  unfold Account.mixtureDefect at mixture
  omega

theorem selected_inventory_cannot_supply_missing_coverage (covered retained : Prop)
    (missing : ¬ covered) : ¬ (covered ∧ retained) := by
  intro complete
  exact missing complete.1

end OriginTracking
