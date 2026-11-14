import Std

/-!
AI-generated; dictated and directed by NousVolition.
Provisional operational model: an unchanged episode record, a supplied second
presentation, a reported judgment, and an unobserved mental return are distinct.
Accurate testimony and the two candidate causes are explicit model assumptions.
These statements do not prove a listener's hidden psychology or witness truth.
-/
set_option autoImplicit false
namespace FixedTremble

theorem same_observation_cannot_determine_different_properties {S O P : Type}
    (observe : S → O) (property : S → P) (a b : S)
    (same : observe a = observe b) (different : property a ≠ property b) :
    ¬ ∃ reader : O → P, ∀ s, reader (observe s) = property s := by
  rintro ⟨reader, correct⟩
  apply different
  exact (correct a).symm.trans ((congrArg reader same).trans (correct b))

theorem replay_preserves_an_observation_collision {S O R : Type}
    (observe : S → O) (replay : O → R) (a b : S)
    (same : observe a = observe b) :
    (observe a, replay (observe a)) = (observe b, replay (observe b)) := by
  rw [same]

theorem ambiguous_record_plus_replay_is_still_ambiguous {S O R P : Type}
    (observe : S → O) (replay : O → R) (property : S → P) (a b : S)
    (same : observe a = observe b) (different : property a ≠ property b) :
    ¬ ∃ reader : O × R → P, ∀ s,
      reader (observe s, replay (observe s)) = property s := by
  exact same_observation_cannot_determine_different_properties
    (fun s => (observe s, replay (observe s))) property a b
    (replay_preserves_an_observation_collision observe replay a b same) different

inductive Cause where
  | pager
  | phone
  deriving DecidableEq, BEq

def originalRecord (_ : Cause) : String :=
  "One brief tremble; phone and pager together; source unseen"

def accurateLink : Cause → Bool
  | .pager => true
  | .phone => false

def decodeLink (linked : Bool) : Cause := if linked then .pager else .phone

theorem original_tremble_does_not_select_a_cause :
    ¬ ∃ reader : String → Cause, ∀ c, reader (originalRecord c) = c := by
  exact same_observation_cannot_determine_different_properties
    originalRecord id Cause.pager Cause.phone rfl (by decide)

theorem accurate_link_identifies_the_cause_without_replay (c : Cause) :
    decodeLink (accurateLink c) = c := by cases c <;> rfl

def evidenceView (c : Cause) (shown : Bool) : String × Option String × Bool :=
  (originalRecord c, if shown then some (originalRecord c) else none, accurateLink c)

def evidenceDecoder (view : String × Option String × Bool) : Cause :=
  decodeLink view.2.2

theorem a_correct_decoder_exists_for_both_replay_conditions :
    ∃ reader : String × Option String × Bool → Cause,
      ∀ c shown, reader (evidenceView c shown) = c := by
  refine ⟨evidenceDecoder, ?_⟩
  intro c shown
  exact accurate_link_identifies_the_cause_without_replay c

theorem supplied_replay_is_not_logically_necessary_in_this_model :
    ∃ c shown, shown = false ∧ evidenceDecoder (evidenceView c shown) = Cause.pager := by
  exact ⟨Cause.pager, false, rfl, rfl⟩

/-- Witness words can be inaccurate. A claimed link alone is not certified truth. -/
theorem identical_testimony_can_accompany_different_causes :
    ∃ a b : Cause × Bool, a.2 = b.2 ∧ a.1 ≠ b.1 := by
  exact ⟨(.pager, true), (.phone, true), rfl, by decide⟩

/-- This domain allows either hidden return flag for the very same report.
The conclusion records the absence of a justified observation rule. -/
theorem a_report_cannot_determine_an_unobserved_return {O : Type} (report : O) :
    ¬ ∃ reader : O → Bool, ∀ state : O × Bool, reader state.1 = state.2 := by
  exact same_observation_cannot_determine_different_properties
    Prod.fst Prod.snd (report, false) (report, true) rfl (by change (false : Bool) ≠ true; decide)

theorem a_gap_can_preserve_the_same_episode_reference (episode : Nat) :
    ∃ first later : Nat × Nat, first.1 = episode ∧ later.1 = episode ∧
      first.2 < later.2 := by
  exact ⟨(episode, 0), (episode, 1), rfl, rfl, by change (0 : Nat) < 1; decide⟩

theorem one_settled_no_replay_record_refutes_recorded_necessity {R : Type}
    (settled replay : R → Prop) (r : R) (yes : settled r) (no : ¬ replay r) :
    ¬ ∀ x, settled x → replay x := by
  intro necessary
  exact no (necessary r yes)

end FixedTremble
