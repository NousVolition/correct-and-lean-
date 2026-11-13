import Std

/-!
AI-generated; dictated and directed by NousVolition.
The general observation rule is the same proof as Tick41Instance's
no_exact_reader_of_any_property, specialized to standard-library types.
The two restaurant worlds below are new explicit test choices. They model
truthful timing evidence and one incident cause. They do not encode a human
or model listener's psychological response to testimony.
-/
set_option autoImplicit false
namespace ContinuingEvidence

theorem no_exact_reader_of_any_property {S O P : Type}
    (observe : S → O) (property : S → P) (a b : S)
    (same : observe a = observe b) (different : property a ≠ property b) :
    ¬ ∃ reader : O → P, ∀ s, reader (observe s) = property s := by
  rintro ⟨reader, correct⟩
  apply different
  exact (correct a).symm.trans ((congrArg reader same).trans (correct b))

/-- Any deterministic reprocessing of a shared record preserves its equality. -/
theorem same_record_same_reprocessing {S O R : Type} (observe : S → O)
    (process : O → R) (a b : S) (same : observe a = observe b) :
    process (observe a) = process (observe b) := congrArg process same

/-- Appending the same elapsed time supplies no differing observation. -/
theorem same_record_with_same_clock {S O : Type} (observe : S → O) (a b : S)
    (same : observe a = observe b) (elapsed : Nat) :
    (observe a, elapsed) = (observe b, elapsed) := by rw [same]

/-- Identical incoming histories and initial record give identical fold results.
A changed interview is a changed input, so that comparison needs its own trial. -/
theorem same_history_same_updated_record {H O : Type} (update : H → O → H)
    (initial : H) (first second : List O) (same : first = second) :
    first.foldl update initial = second.foldl update initial := by rw [same]

inductive Cause where
  | pager
  | phone
  deriving DecidableEq, BEq, Repr

inductive World where
  | pagerAtIncident
  | phoneAtIncident
  deriving DecidableEq

def cause : World → Cause
  | .pagerAtIncident => .pager
  | .phoneAtIncident => .phone

/-- Both hypothetical worlds contain an earlier pager test. In the second
world the felt incident is a separate phone event. -/
def unspecificTest (_ : World) : String := "The pager was tested earlier"

def timingLink : World → Bool
  | .pagerAtIncident => true
  | .phoneAtIncident => false

theorem quiet_waiting_does_not_supply_the_missing_link (elapsed : Nat) :
    ¬ ∃ reader : String × Nat → Cause,
      ∀ w, reader (unspecificTest w, elapsed) = cause w := by
  apply no_exact_reader_of_any_property (fun w => (unspecificTest w, elapsed))
    cause World.pagerAtIncident World.phoneAtIncident
  · rfl
  · decide

theorem a_second_copy_of_the_same_answer_is_still_ambiguous :
    ¬ ∃ reader : String × String → Cause,
      ∀ w, reader (unspecificTest w, unspecificTest w) = cause w := by
  apply no_exact_reader_of_any_property (fun w => (unspecificTest w, unspecificTest w))
    cause World.pagerAtIncident World.phoneAtIncident
  · rfl
  · decide

/-- The extra observation varies between the two worlds. -/
theorem accurate_timing_separates_the_two_worlds :
    timingLink .pagerAtIncident ≠ timingLink .phoneAtIncident := by decide

def fromTiming (linked : Bool) : Cause := if linked then .pager else .phone

/-- Conditional on the declared two-world model and accurate timing evidence. -/
theorem accurate_timing_recovers_the_declared_cause (w : World) :
    fromTiming (timingLink w) = cause w := by cases w <;> rfl

/-- Allow inaccurate testimony and the words alone again admit both causes. -/
theorem the_same_claim_can_accompany_either_cause :
    ∃ a b : Cause × Bool, a.2 = b.2 ∧ a.1 ≠ b.1 := by
  exact ⟨(.pager, true), (.phone, true), rfl, by decide⟩

/-- Sampling only a finite prefix leaves at least these two futures possible. -/
theorem finite_quiet_prefix_leaves_future_settlement_open (cutoff : Nat) :
    ∃ later never : Nat → Bool,
      (∀ n, n ≤ cutoff → later n = never n) ∧
      later (cutoff + 1) = true ∧ never (cutoff + 1) = false := by
  refine ⟨fun n => decide (cutoff < n), fun _ => false, ?_, ?_, rfl⟩
  · intro n hn
    simp [Nat.not_lt.mpr hn]
  · simp

end ContinuingEvidence
