import Mathlib

/-!
SIMS latent-readout suite: mathematical rules and finite checks of saved data.
Rational restatement: every former real-number statement is now over ℚ.
The JSON-to-Lean translation and filesystem are outside the Lean kernel.
The finite inputs below are generated from the frozen suite, never from new model replies.
No theorem states that an arbitrary language model follows these rules.
-/
set_option autoImplicit false
set_option maxRecDepth 4096
set_option maxHeartbeats 800000

namespace SIMSLatentReadout

/- Equal observations cannot decide a property on which two possible states disagree. -/
theorem no_exact_reader_of_ambiguous_observation {S O : Type}
    (observe : S → O) (present : S → Bool) (a b : S)
    (same : observe a = observe b) (different : present a ≠ present b) :
    ¬ ∃ reader : O → Bool, ∀ s, reader (observe s) = present s := by
  rintro ⟨reader, correct⟩
  apply different
  exact (correct a).symm.trans ((congrArg reader same).trans (correct b))

/-- Rational version: the comparison is decidable, so the reading is computable. -/
def signRead (x : ℚ) : ℤ :=
  if x < 0 then -1 else if x = 0 then 0 else 1

theorem negative_marks_share_reading (x y : ℚ) (hx : x < 0) (hy : y < 0) :
    signRead x = signRead y := by
  unfold signRead
  rw [if_pos hx, if_pos hy]

/-- Exact decimals from controlled case C07, not a new Hug trajectory. -/
theorem clay_changes_while_sign_stays :
    (- (1 / 50) : ℚ) ≠ - (12 / 625) ∧
      signRead (- (1 / 50)) = signRead (- (12 / 625)) := by
  decide

/-- The change in this fixture is 4% of the initial magnitude. -/
theorem clay_relative_change :
    ((- (12 / 625) : ℚ) - (- (1 / 50))) / (1 / 50) = 1 / 25 := by
  decide

theorem sign_reading_does_not_determine_mark : ¬ Function.Injective signRead := by
  intro injective
  exact clay_changes_while_sign_stays.1 (injective clay_changes_while_sign_stays.2)

def present (record : Option String) : Bool := record.isSome
def sameRecord (before after : Option String) : Bool :=
  match before, after with
  | some a, some b => a == b
  | _, _ => false

/-- This uses the suite's explicit record-ID convention. -/
theorem same_record_requires_original (before after : Option String)
    (h : sameRecord before after = true) : present before = true := by
  cases before with
  | none => simp [sameRecord] at h
  | some id => rfl

theorem no_same_record_when_original_absent (before after : Option String)
    (h : present before = false) : sameRecord before after = false := by
  cases before with
  | none => rfl
  | some id => simp [present] at h

/-- A conditional round-trip law; actual saved strings are checked separately below. -/
theorem lossless_filing_preserves_readable_fields {S F A : Type}
    (file : S → F) (reopen : F → S) (field : S → A)
    (roundTrip : ∀ s, reopen (file s) = s) (s : S) :
    field (reopen (file s)) = field s := by
  rw [roundTrip]

/-- Perfect storage imposes no correctness law on a separate reader. -/
theorem lossless_storage_can_have_wrong_reader :
    ∃ (file reopen : Bool → Bool) (reader : Bool → Bool),
      (∀ s, reopen (file s) = s) ∧ reader (reopen (file true)) ≠ true := by
  exact ⟨id, id, fun _ => false, fun _ => rfl, by decide⟩

open scoped BigOperators

def evidenceTotal {n : ℕ} (w likelihood : Fin n → ℚ) : ℚ :=
  ∑ i, w i * likelihood i
def update {n : ℕ} (w likelihood : Fin n → ℚ) (i : Fin n) : ℚ :=
  w i * likelihood i / evidenceTotal w likelihood

theorem update_nonnegative {n : ℕ} (w likelihood : Fin n → ℚ)
    (hw : ∀ i, 0 ≤ w i) (hl : ∀ i, 0 ≤ likelihood i)
    (positiveTotal : 0 < evidenceTotal w likelihood) (i : Fin n) :
    0 ≤ update w likelihood i := by
  exact div_nonneg (mul_nonneg (hw i) (hl i)) positiveTotal.le

theorem update_sums_to_one {n : ℕ} (w likelihood : Fin n → ℚ)
    (positiveTotal : 0 < evidenceTotal w likelihood) :
    (∑ i, update w likelihood i) = 1 := by
  simp only [update, ← Finset.sum_div]
  exact div_self (ne_of_gt positiveTotal)

theorem zero_weight_stays_zero {n : ℕ} (w likelihood : Fin n → ℚ)
    (i : Fin n) (zeroWeight : w i = 0) : update w likelihood i = 0 := by
  simp [update, zeroWeight]

/-- Lean division is total; this agrees with the suite's explicit all-zero branch. -/
theorem zero_total_returns_zero {n : ℕ} (w likelihood : Fin n → ℚ)
    (zeroTotal : evidenceTotal w likelihood = 0) :
    (∀ i, update w likelihood i = 0) ∧ (∑ i, update w likelihood i) = 0 := by
  simp [update, zeroTotal]

inductive Hypothesis | absent | held | changedRetained | writtenLater
  deriving DecidableEq, Repr
inductive Probe | initialPresent | afterPresent | componentChanged
  deriving DecidableEq, Repr

def menu : List Hypothesis := [.absent, .held, .changedRetained, .writtenLater]
def prediction (h : Hypothesis) (p : Probe) : Bool :=
  match p, h with
  | .initialPresent, .held | .initialPresent, .changedRetained => true
  | .afterPresent, .held | .afterPresent, .changedRetained | .afterPresent, .writtenLater => true
  | .componentChanged, .changedRetained | .componentChanged, .writtenLater => true
  | _, _ => false

def survivors (observations : List (Probe × Bool)) : List Hypothesis :=
  menu.filter (fun h => observations.all (fun o => prediction h o.1 == o.2))

theorem further_evidence_does_not_reintroduce (old : List Hypothesis)
    (p : Probe) (value : Bool) (h : Hypothesis)
    (survived : h ∈ old.filter (fun c => prediction c p == value)) : h ∈ old := by
  exact (List.mem_filter.mp survived).1

theorem erased_record_fits_none_of_current_menu :
    survivors [(.initialPresent, true), (.afterPresent, false), (.componentChanged, true)] = [] := by
  decide

/-- All saved traces have 0, 1, 2 or 4 candidates; their weights are exact quarters. -/
def quarters (observations : List (Probe × Bool)) : List Nat :=
  let remaining := survivors observations
  menu.map (fun h => if h ∈ remaining then 4 / remaining.length else 0)

theorem uninformative_start_keeps_four_equal_weights : quarters [] = [1, 1, 1, 1] := by
  decide

inductive Answer | yes | no | unknown | unavailable
  deriving DecidableEq, Repr
def answerOf (b : Bool) : Answer := if b then .yes else .no

structure Reply where
  earlierAvailable : Bool
  earlier : Answer
  quoteText : Option String
  stored : Answer
  changed : Answer
  same : Answer
  readTime : Option Nat
  deriving Repr

structure SavedCase where
  id : String
  firstDisplay : Nat
  before : Option String
  after : Option String
  initialComponentJSON : String
  heldComponentJSON : String
  expectedStored : Answer
  expectedChanged : Answer
  expectedSame : Answer
  initialReplyBefore : String
  initialReplyAfter : String
  afterStatus : String
  afterDecisionJSON : String
  ai : Reply
  sims : Reply
  lossy : Reply
  deriving Repr

def contradictedOwnRecordClaim (r : Reply) : Bool := r.stored == .no && r.same == .yes
def storedCorrect (c : SavedCase) (r : Reply) : Bool := r.stored == answerOf (present c.before)
def historicalFieldsCorrect (c : SavedCase) (r : Reply) : Bool :=
  storedCorrect c r &&
    r.changed == answerOf (c.initialComponentJSON != c.heldComponentJSON) &&
    r.same == answerOf (sameRecord c.before c.after) && r.readTime == some 2
def earlierRecovered (r : Reply) : Bool := r.earlierAvailable && r.earlier == .no
def countCases (cases : List SavedCase) (p : SavedCase → Bool) : Nat := (cases.filter p).length

/- Generated declarations and kernel checks of the saved run follow. -/

def firstReply : String := "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}"

def case01 : SavedCase :=
  ⟨"C01",
   0,
   (some "r"),
   (some "r"),
   "0.01",
   "0.0096",
   .yes,
   .yes,
   .yes,
   "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}",
   "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}",
   "open",
   "null",
   ⟨true, .no, (some "{\"stored_before\": \"no\", \"next_check\": \"time 2\"}"), .yes, .yes, .yes, (some 2)⟩,
   ⟨true, .no, (some "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}"), .yes, .yes, .yes, (some 2)⟩,
   ⟨false, .unknown, none, .unknown, .unknown, .unknown, (some 2)⟩⟩

def case02 : SavedCase :=
  ⟨"C02",
   0,
   (some "r"),
   (some "r"),
   "[0.0, 0.0]",
   "[-1.5707963267948966, 1.5707963267948966]",
   .yes,
   .yes,
   .yes,
   "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}",
   "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}",
   "open",
   "null",
   ⟨true, .no, (some "{\"stored_before\": \"no\", \"next_check\": \"time 2\"}"), .yes, .yes, .yes, (some 2)⟩,
   ⟨true, .no, (some "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}"), .no, .yes, .yes, (some 2)⟩,
   ⟨false, .unknown, none, .unknown, .unknown, .unknown, (some 2)⟩⟩

def case03 : SavedCase :=
  ⟨"C03",
   0,
   (some "r"),
   (some "r"),
   "440.0",
   "440.0",
   .yes,
   .no,
   .yes,
   "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}",
   "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}",
   "open",
   "null",
   ⟨true, .no, (some "{\"stored_before\": \"no\", \"next_check\": \"time 2\"}"), .yes, .no, .yes, (some 2)⟩,
   ⟨true, .no, (some "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}"), .yes, .no, .yes, (some 2)⟩,
   ⟨false, .unknown, none, .unknown, .unknown, .unknown, (some 2)⟩⟩

def case04 : SavedCase :=
  ⟨"C04",
   0,
   (some "r"),
   (some "r"),
   "[0, 1, 1]",
   "[0, 1, 1]",
   .yes,
   .no,
   .yes,
   "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}",
   "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}",
   "open",
   "null",
   ⟨true, .no, (some "{\"stored_before\": \"no\", \"next_check\": \"time 2\"}"), .yes, .no, .yes, (some 2)⟩,
   ⟨true, .no, (some "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}"), .no, .no, .yes, (some 2)⟩,
   ⟨false, .unknown, none, .unknown, .unknown, .unknown, (some 2)⟩⟩

def case05 : SavedCase :=
  ⟨"C05",
   0,
   (some "r"),
   (some "r"),
   "3.0",
   "3.0",
   .yes,
   .no,
   .yes,
   "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}",
   "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}",
   "open",
   "null",
   ⟨true, .no, (some "{\"stored_before\": \"no\", \"next_check\": \"time 2\"}"), .yes, .no, .yes, (some 2)⟩,
   ⟨true, .no, (some "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}"), .yes, .no, .yes, (some 2)⟩,
   ⟨false, .unknown, none, .unknown, .unknown, .unknown, (some 2)⟩⟩

def case06 : SavedCase :=
  ⟨"C06",
   0,
   (some "r"),
   (some "r"),
   "\"letter-6\"",
   "\"letter-6\"",
   .yes,
   .no,
   .yes,
   "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}",
   "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}",
   "open",
   "null",
   ⟨true, .no, (some "{\"stored_before\": \"no\", \"next_check\": \"time 2\"}"), .yes, .no, .yes, (some 2)⟩,
   ⟨true, .no, (some "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}"), .no, .no, .yes, (some 2)⟩,
   ⟨false, .unknown, none, .unknown, .unknown, .unknown, (some 2)⟩⟩

def case07 : SavedCase :=
  ⟨"C07",
   0,
   (some "r"),
   (some "r"),
   "-0.02",
   "-0.0192",
   .yes,
   .yes,
   .yes,
   "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}",
   "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}",
   "open",
   "null",
   ⟨true, .no, (some "{\"stored_before\": \"no\", \"next_check\": \"time 2\"}"), .yes, .yes, .yes, (some 2)⟩,
   ⟨true, .no, (some "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}"), .yes, .yes, .yes, (some 2)⟩,
   ⟨false, .unknown, none, .unknown, .unknown, .unknown, (some 2)⟩⟩

def case08 : SavedCase :=
  ⟨"C08",
   0,
   none,
   none,
   "null",
   "null",
   .no,
   .no,
   .no,
   "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}",
   "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}",
   "open",
   "null",
   ⟨true, .no, (some "{\"stored_before\": \"no\", \"next_check\": \"time 2\"}"), .no, .no, .unknown, (some 2)⟩,
   ⟨true, .no, (some "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}"), .no, .no, .unknown, (some 2)⟩,
   ⟨false, .unknown, none, .unknown, .unknown, .unknown, (some 2)⟩⟩

def case09 : SavedCase :=
  ⟨"C09",
   0,
   none,
   (some "new"),
   "null",
   "0.02",
   .no,
   .yes,
   .no,
   "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}",
   "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}",
   "open",
   "null",
   ⟨true, .no, (some "{\"stored_before\": \"no\", \"next_check\": \"time 2\"}"), .no, .unknown, .no, (some 1)⟩,
   ⟨true, .no, (some "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}"), .no, .yes, .no, (some 2)⟩,
   ⟨false, .unknown, none, .unknown, .unknown, .unknown, (some 2)⟩⟩

def case10 : SavedCase :=
  ⟨"C10",
   0,
   (some "lost"),
   none,
   "-0.02",
   "null",
   .yes,
   .yes,
   .no,
   "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}",
   "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}",
   "open",
   "null",
   ⟨true, .no, (some "{\"stored_before\": \"no\", \"next_check\": \"time 2\"}"), .yes, .yes, .no, (some 1)⟩,
   ⟨true, .no, (some "{\n\"stored_before\": \"no\",\n\"next_check\": \"time 2\"\n}"), .yes, .yes, .no, (some 2)⟩,
   ⟨false, .unknown, none, .unknown, .unknown, .unknown, (some 2)⟩⟩

def savedCases : List SavedCase := [case01, case02, case03, case04, case05, case06, case07, case08, case09, case10]

def savedWeightTraces : List (List (Probe × Bool) × List Nat) :=
  [([], [1, 1, 1, 1]),
   ([(.initialPresent, true)], [0, 2, 2, 0]),
   ([(.initialPresent, true), (.componentChanged, true)], [0, 0, 4, 0]),
   ([(.initialPresent, true), (.componentChanged, true), (.afterPresent, true)], [0, 0, 4, 0]),
   ([], [1, 1, 1, 1]),
   ([(.initialPresent, true)], [0, 2, 2, 0]),
   ([(.initialPresent, true), (.componentChanged, true)], [0, 0, 4, 0]),
   ([(.initialPresent, true), (.componentChanged, true), (.afterPresent, true)], [0, 0, 4, 0]),
   ([], [1, 1, 1, 1]),
   ([(.initialPresent, true)], [0, 2, 2, 0]),
   ([(.initialPresent, true), (.componentChanged, false)], [0, 4, 0, 0]),
   ([(.initialPresent, true), (.componentChanged, false), (.afterPresent, true)], [0, 4, 0, 0]),
   ([], [1, 1, 1, 1]),
   ([(.initialPresent, true)], [0, 2, 2, 0]),
   ([(.initialPresent, true), (.componentChanged, false)], [0, 4, 0, 0]),
   ([(.initialPresent, true), (.componentChanged, false), (.afterPresent, true)], [0, 4, 0, 0]),
   ([], [1, 1, 1, 1]),
   ([(.initialPresent, true)], [0, 2, 2, 0]),
   ([(.initialPresent, true), (.componentChanged, false)], [0, 4, 0, 0]),
   ([(.initialPresent, true), (.componentChanged, false), (.afterPresent, true)], [0, 4, 0, 0]),
   ([], [1, 1, 1, 1]),
   ([(.initialPresent, true)], [0, 2, 2, 0]),
   ([(.initialPresent, true), (.componentChanged, false)], [0, 4, 0, 0]),
   ([(.initialPresent, true), (.componentChanged, false), (.afterPresent, true)], [0, 4, 0, 0]),
   ([], [1, 1, 1, 1]),
   ([(.initialPresent, true)], [0, 2, 2, 0]),
   ([(.initialPresent, true), (.componentChanged, true)], [0, 0, 4, 0]),
   ([(.initialPresent, true), (.componentChanged, true), (.afterPresent, true)], [0, 0, 4, 0]),
   ([], [1, 1, 1, 1]),
   ([(.initialPresent, false)], [2, 0, 0, 2]),
   ([(.initialPresent, false), (.afterPresent, false)], [4, 0, 0, 0]),
   ([(.initialPresent, false), (.afterPresent, false), (.componentChanged, false)], [4, 0, 0, 0]),
   ([], [1, 1, 1, 1]),
   ([(.initialPresent, false)], [2, 0, 0, 2]),
   ([(.initialPresent, false), (.afterPresent, true)], [0, 0, 0, 4]),
   ([(.initialPresent, false), (.afterPresent, true), (.componentChanged, true)], [0, 0, 0, 4]),
   ([], [1, 1, 1, 1]),
   ([(.initialPresent, true)], [0, 2, 2, 0]),
   ([(.initialPresent, true), (.componentChanged, true)], [0, 0, 4, 0]),
   ([(.initialPresent, true), (.componentChanged, true), (.afterPresent, false)], [0, 0, 0, 0])]


theorem recorded_zero_has_opposite_histories :
    case01.firstDisplay = case08.firstDisplay ∧
      present case01.before = true ∧ present case08.before = false := by decide

theorem no_reader_of_the_first_display_is_always_right :
    ¬ ∃ reader : Nat → Bool, ∀ c : SavedCase, reader c.firstDisplay = present c.before := by
  apply no_exact_reader_of_ambiguous_observation (fun c : SavedCase => c.firstDisplay)
    (fun c => present c.before) case01 case08
  · decide
  · decide

theorem all_ten_first_replies_survive_filing :
    savedCases.map (fun c => (c.initialReplyBefore, c.initialReplyAfter)) =
      List.replicate 10 (firstReply, firstReply) := by decide

theorem all_ten_filings_remain_open_without_confirmation :
    savedCases.map (fun c => (c.afterStatus, c.afterDecisionJSON)) =
      List.replicate 10 ("open", "null") := by decide

theorem saved_rubric_matches_recorded_histories :
    savedCases.all (fun c =>
      c.expectedStored == answerOf (present c.before) &&
      c.expectedChanged == answerOf (c.initialComponentJSON != c.heldComponentJSON) &&
      c.expectedSame == answerOf (sameRecord c.before c.after)) = true := by decide

theorem both_readers_recover_earlier_answer_in_all_ten :
    countCases savedCases (fun c => earlierRecovered c.ai) = 10 ∧
      countCases savedCases (fun c => earlierRecovered c.sims) = 10 := by decide

theorem full_history_existence_score :
    countCases savedCases (fun c => storedCorrect c c.ai) = 10 := by decide

theorem filed_record_existence_score :
    countCases savedCases (fun c => storedCorrect c c.sims) = 7 := by decide

theorem precisely_three_filed_reader_contradictions :
    (savedCases.filter (fun c => contradictedOwnRecordClaim c.sims)).map (fun c => c.id) =
      ["C02", "C04", "C06"] := by decide

theorem both_clay_readers_recognize_the_change_and_identity :
    historicalFieldsCorrect case07 case07.ai = true ∧
      historicalFieldsCorrect case07 case07.sims = true := by decide

theorem historical_scores_are_seven_and_six :
    countCases savedCases (fun c => historicalFieldsCorrect c c.ai) = 7 ∧
      countCases savedCases (fun c => historicalFieldsCorrect c c.sims) = 6 := by decide

theorem exact_first_quote_counts_are_zero_and_ten :
    countCases savedCases (fun c => c.ai.quoteText == some firstReply) = 0 ∧
      countCases savedCases (fun c => c.sims.quoteText == some firstReply) = 10 := by decide

theorem lossy_reader_has_no_history_and_answers_unknown :
    savedCases.all (fun c => !c.lossy.earlierAvailable &&
      c.lossy.stored == .unknown && c.lossy.changed == .unknown && c.lossy.same == .unknown) = true := by decide

theorem every_saved_weight_trace_matches_finite_filtering :
    savedWeightTraces.all (fun t => quarters t.1 == t.2) = true := by decide

theorem quarters_encoding_is_exact_for_these_traces :
    savedWeightTraces.all (fun t =>
      decide ((survivors t.1).length ∈ ([0, 1, 2, 4] : List Nat))) = true := by decide

theorem forty_weight_states_checked : savedWeightTraces.length = 40 := by decide

end SIMSLatentReadout

#print axioms SIMSLatentReadout.no_exact_reader_of_ambiguous_observation
#print axioms SIMSLatentReadout.negative_marks_share_reading
#print axioms SIMSLatentReadout.clay_changes_while_sign_stays
#print axioms SIMSLatentReadout.clay_relative_change
#print axioms SIMSLatentReadout.sign_reading_does_not_determine_mark
#print axioms SIMSLatentReadout.same_record_requires_original
#print axioms SIMSLatentReadout.no_same_record_when_original_absent
#print axioms SIMSLatentReadout.lossless_filing_preserves_readable_fields
#print axioms SIMSLatentReadout.lossless_storage_can_have_wrong_reader
#print axioms SIMSLatentReadout.update_nonnegative
#print axioms SIMSLatentReadout.update_sums_to_one
#print axioms SIMSLatentReadout.zero_weight_stays_zero
#print axioms SIMSLatentReadout.zero_total_returns_zero
#print axioms SIMSLatentReadout.further_evidence_does_not_reintroduce
#print axioms SIMSLatentReadout.erased_record_fits_none_of_current_menu
#print axioms SIMSLatentReadout.uninformative_start_keeps_four_equal_weights
#print axioms SIMSLatentReadout.recorded_zero_has_opposite_histories
#print axioms SIMSLatentReadout.no_reader_of_the_first_display_is_always_right
#print axioms SIMSLatentReadout.all_ten_first_replies_survive_filing
#print axioms SIMSLatentReadout.all_ten_filings_remain_open_without_confirmation
#print axioms SIMSLatentReadout.saved_rubric_matches_recorded_histories
#print axioms SIMSLatentReadout.both_readers_recover_earlier_answer_in_all_ten
#print axioms SIMSLatentReadout.full_history_existence_score
#print axioms SIMSLatentReadout.filed_record_existence_score
#print axioms SIMSLatentReadout.precisely_three_filed_reader_contradictions
#print axioms SIMSLatentReadout.both_clay_readers_recognize_the_change_and_identity
#print axioms SIMSLatentReadout.historical_scores_are_seven_and_six
#print axioms SIMSLatentReadout.exact_first_quote_counts_are_zero_and_ten
#print axioms SIMSLatentReadout.lossy_reader_has_no_history_and_answers_unknown
#print axioms SIMSLatentReadout.every_saved_weight_trace_matches_finite_filtering
#print axioms SIMSLatentReadout.quarters_encoding_is_exact_for_these_traces
#print axioms SIMSLatentReadout.forty_weight_states_checked
