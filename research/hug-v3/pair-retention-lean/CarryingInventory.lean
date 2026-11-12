import Std

namespace CarryingInventory

/-- The complete finite payload is encoded as a natural number with a leading
one bit, so leading zero bytes are retained. The key is the event identity. -/
structure Record where
  key : Nat
  payload : Nat
  deriving DecidableEq, Repr

/-- Every original record, including its entire payload, remains present. -/
def Preserves (entry exit : List Record) : Prop :=
  ∀ r ∈ entry, r ∈ exit

instance (entry exit : List Record) : Decidable (Preserves entry exit) := by
  unfold Preserves
  infer_instance

def UniqueKeys (records : List Record) : Prop :=
  (records.map Record.key).Nodup

instance (records : List Record) : Decidable (UniqueKeys records) := by
  unfold UniqueKeys
  infer_instance

theorem preserves_self (records : List Record) : Preserves records records := by
  intro r h
  exact h

theorem preserves_through (first middle last : List Record)
    (h₁ : Preserves first middle) (h₂ : Preserves middle last) :
    Preserves first last := by
  intro r hr
  exact h₂ r (h₁ r hr)

theorem original_payload_still_present (entry exit : List Record) (r : Record)
    (h : Preserves entry exit) (hr : r ∈ entry) : r ∈ exit :=
  h r hr

/-- Keeping a name alone is not a content-preservation test. -/
theorem same_key_can_lose_payload :
    ([Record.mk 25 10].map Record.key = [Record.mk 25 11].map Record.key) ∧
    ¬ Preserves [Record.mk 25 10] [Record.mk 25 11] := by
  decide

theorem missing_record_is_not_retained :
    ¬ Preserves [Record.mk 0 100, Record.mk 1 200] [Record.mk 0 100] := by
  decide

/-- Signed exact-decimal numerators, all with the same positive denominator. -/
structure Account where
  entry : Int
  exit : Int
  diffusion : Int
  source : Int
  transport : Int
  deriving DecidableEq, Repr

def Account.defect (a : Account) : Int :=
  a.exit - a.entry - a.diffusion - a.source - a.transport

def Within (a : Account) (tolerance : Nat) : Prop :=
  a.defect.natAbs ≤ tolerance

instance (a : Account) (tolerance : Nat) : Decidable (Within a tolerance) := by
  unfold Within
  infer_instance

theorem balanced_zero_exchange_preserves_value (a : Account)
    (h : a.defect = 0) (hd : a.diffusion = 0)
    (hs : a.source = 0) (ht : a.transport = 0) : a.exit = a.entry := by
  unfold Account.defect at h
  omega

/-- Accounted exchange can change the local value without violating the budget. -/
theorem accounted_change_need_not_be_zero :
    (Account.mk 10 12 0 2 0).defect = 0 ∧
    (Account.mk 10 12 0 2 0).entry ≠ (Account.mk 10 12 0 2 0).exit := by
  decide

/-- A balanced replacement can leave a scalar total unchanged while the
original contents have gone. Accounting alone does not track provenance. -/
theorem balanced_replacement_need_not_retain_contents :
    (Account.mk 10 10 (-2) 2 0).defect = 0 ∧
    ¬ Preserves [Record.mk 0 100] [Record.mk 1 200] := by
  decide

/-- Complete retention needs an inventory covering the requested contents,
not merely evidence for a selected list of records. -/
def CompleteClaim (covered : Prop) (entry exit : List Record) : Prop :=
  covered ∧ Preserves entry exit

theorem missing_coverage_blocks_complete_claim (covered : Prop)
    (entry exit : List Record) (h : ¬ covered) :
    ¬ CompleteClaim covered entry exit := by
  intro hc
  exact h hc.1

theorem complete_claim_includes_payloads (covered : Prop)
    (entry exit : List Record) (h : CompleteClaim covered entry exit) :
    Preserves entry exit :=
  h.2

end CarryingInventory
