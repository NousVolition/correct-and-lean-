/-!
Pair 25 as an instance of the ambiguous-observation rule.

Source: the Pair 25 origin-tracking report, wider observation window (radius 0.10),
after-write tick-41 state followed from model time 1.2 to 1.3. The same identities are
reported in all three runs (40³ and 48³ grids, two time steps).

The counts and the two observer labels below are transcribed from that report. The full
list of 364 labels was not available, so the state here is a summary: the count and
whether observers 540 and 872 are inside. Lean checks statements about this summary.
It does not check the simulator, the positions, or the transcription.

No Mathlib import is needed; everything is over natural numbers and booleans.
-/
set_option autoImplicit false

namespace Pair25Instance

/-- Same rule as `SIMSLatentReadout.no_exact_reader_of_ambiguous_observation`, restated here
so this file stands alone. -/
theorem no_exact_reader_of_ambiguous_observation {S O : Type}
    (observe : S → O) (present : S → Bool) (a b : S)
    (same : observe a = observe b) (different : present a ≠ present b) :
    ¬ ∃ reader : O → Bool, ∀ s, reader (observe s) = present s :=
  fun ⟨reader, correct⟩ =>
    different ((correct a).symm.trans ((congrArg reader same).trans (correct b)))

/-- What the wider window holds at one recorded time: how many labels, and whether the
two labels that change are among them. -/
structure WindowState where
  labelCount : Nat
  holds540 : Bool
  holds872 : Bool

/-- Model time 1.2: 364 labels, observer 540 inside, observer 872 outside. -/
def atStart : WindowState := ⟨364, true, false⟩

/-- Between the two crossings: 872 has arrived and 540 has not yet left. -/
def between : WindowState := ⟨365, true, true⟩

/-- Model time 1.3: 363 of the original labels plus observer 872. -/
def atEnd : WindowState := ⟨364, false, true⟩

/-- The count reads the same at the start and at the end. -/
theorem count_same_at_start_and_end : atStart.labelCount = atEnd.labelCount := rfl

/-- The membership is not the same: 540 has left and 872 has arrived. -/
theorem membership_differs :
    atStart.holds540 ≠ atEnd.holds540 ∧ atStart.holds872 ≠ atEnd.holds872 := by
  decide

/-- The count is not constant in between; it passes through 365. -/
theorem count_passes_through_365 :
    between.labelCount = atStart.labelCount + 1 ∧ between.labelCount = atEnd.labelCount + 1 := by
  decide

/-- Pair 25 as an instance: no rule that reads only the count can say, for every state,
whether observer 540 is inside the window. -/
theorem count_cannot_tell_whether_540_is_inside :
    ¬ ∃ reader : Nat → Bool, ∀ s : WindowState, reader s.labelCount = s.holds540 :=
  no_exact_reader_of_ambiguous_observation (fun s : WindowState => s.labelCount)
    (fun s => s.holds540) atStart atEnd rfl (by decide)

/-- The same for the arriving label: the count cannot say whether observer 872 is inside. -/
theorem count_cannot_tell_whether_872_is_inside :
    ¬ ∃ reader : Nat → Bool, ∀ s : WindowState, reader s.labelCount = s.holds872 :=
  no_exact_reader_of_ambiguous_observation (fun s : WindowState => s.labelCount)
    (fun s => s.holds872) atStart atEnd rfl (by decide)

end Pair25Instance

#print axioms Pair25Instance.count_same_at_start_and_end
#print axioms Pair25Instance.membership_differs
#print axioms Pair25Instance.count_passes_through_365
#print axioms Pair25Instance.count_cannot_tell_whether_540_is_inside
#print axioms Pair25Instance.count_cannot_tell_whether_872_is_inside
