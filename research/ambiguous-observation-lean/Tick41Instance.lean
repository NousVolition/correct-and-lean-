import Mathlib

/-!
Tick 41 as an instance of the ambiguous-observation rule.

The three decimals are the printed values in `results.json` of the Tick 41 check
(threshold 1, breathing on, model time 1.2), read as exact decimals. Lean checks
statements about these transcribed numbers. It does not check the solver, the
snapshots, or that the numbers were copied correctly.
-/
set_option autoImplicit false

namespace Tick41Instance

/-- Same rule as `SIMSLatentReadout.no_exact_reader_of_ambiguous_observation`, restated here
so this file stands alone. -/
theorem no_exact_reader_of_ambiguous_observation {S O : Type}
    (observe : S → O) (present : S → Bool) (a b : S)
    (same : observe a = observe b) (different : present a ≠ present b) :
    ¬ ∃ reader : O → Bool, ∀ s, reader (observe s) = present s := by
  rintro ⟨reader, correct⟩
  apply different
  exact (correct a).symm.trans ((congrArg reader same).trans (correct b))

/-- The same rule for a property of any type, such as a rate. -/
theorem no_exact_reader_of_any_property {S O P : Type}
    (observe : S → O) (property : S → P) (a b : S)
    (same : observe a = observe b) (different : property a ≠ property b) :
    ¬ ∃ reader : O → P, ∀ s, reader (observe s) = property s := by
  rintro ⟨reader, correct⟩
  apply different
  exact (correct a).symm.trans ((congrArg reader same).trans (correct b))

/-- A three-field summary of the model at one instant. Not the full solver state. -/
structure TickState where
  accumulator : ℚ
  rate : ℚ
  thirdRecordStored : Bool

/-- Time 1.2, immediately before the third write. -/
def beforeWrite : TickState :=
  ⟨6429061322641351 / 1000000000000000000,
   8194451110496026 / 1000000000000000000,
   false⟩

/-- Time 1.2, immediately after the third write. -/
def afterWrite : TickState :=
  ⟨6429061322641351 / 1000000000000000000,
   8309196904720758 / 1000000000000000000,
   true⟩

/-- The write leaves the accumulator's value unchanged. -/
theorem accumulator_unchanged_by_write :
    beforeWrite.accumulator = afterWrite.accumulator := rfl

/-- The write changes the accumulator's rate. -/
theorem rate_changed_by_write : beforeWrite.rate ≠ afterWrite.rate := by
  norm_num [beforeWrite, afterWrite]

/-- The size of the change, as recorded. -/
theorem rate_jump :
    afterWrite.rate - beforeWrite.rate = 114745794224732 / 1000000000000000000 := by
  norm_num [beforeWrite, afterWrite]

/-- Tick 41 as an instance: no rule that reads only the accumulator's value can say,
for every state, whether the third record has been stored. -/
theorem accumulator_value_cannot_tell_whether_record_was_written :
    ¬ ∃ reader : ℚ → Bool, ∀ s : TickState, reader s.accumulator = s.thirdRecordStored := by
  apply no_exact_reader_of_ambiguous_observation (fun s : TickState => s.accumulator)
    (fun s => s.thirdRecordStored) beforeWrite afterWrite
  · rfl
  · decide

/-- Tick 41 as an instance: no rule that reads only the accumulator's value can give,
for every state, its rate. -/
theorem accumulator_value_cannot_determine_rate :
    ¬ ∃ reader : ℚ → ℚ, ∀ s : TickState, reader s.accumulator = s.rate := by
  apply no_exact_reader_of_any_property (fun s : TickState => s.accumulator)
    (fun s => s.rate) beforeWrite afterWrite
  · rfl
  · exact rate_changed_by_write

end Tick41Instance

#print axioms Tick41Instance.accumulator_unchanged_by_write
#print axioms Tick41Instance.rate_changed_by_write
#print axioms Tick41Instance.rate_jump
#print axioms Tick41Instance.accumulator_value_cannot_tell_whether_record_was_written
#print axioms Tick41Instance.accumulator_value_cannot_determine_rate
