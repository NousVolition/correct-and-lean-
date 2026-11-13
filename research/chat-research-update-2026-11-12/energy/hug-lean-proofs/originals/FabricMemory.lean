/-!
The fabric in the Hug v3 solver: what it stores, what it refuses, and what moves.

Sections 1–3 transcribe rules from `structural_hug.py` (class `Fabric`) in the Tick 41
packages:

    byte_count    = 2*(HEADER + 6*P) + 4          # HEADER = 23, P = 384 material points
    bits_per_slot = byte_count*8
    size          = capacity*bits_per_slot        # capacity = 4
    ...
    if any(r['event_id']==record['event_id'] ...): raise ValueError('duplicate event ID')
    if not free: raise CapacityError('declared material capacity exhausted; no overwrite')
    slot = free[0]
    ...
    if min(abs(estimated)) < read_margin*rest_amplitude: raise MemoryReadError(...)
    bit = estimated > 0                           # read_margin = 0.25

Section 4 uses numbers measured from the saved threshold-1 snapshots (frames 400, 599
and 600) with the sealed solver, in this session.

What is shown:

1. The layout: 37,264 cells per record, four records, 149,056 cells in all.
2. Writing: a record is never overwritten or removed, a repeated event is refused, and
   a full fabric refuses a further write.
3. Reading: both marks are readable; the middle is refused, not guessed.
4. Between the second write and the third, every cell moved and the decoded records did
   not change. So no rule that reads only the decoded records can give the fabric's
   marks (an instance of the ambiguous-observation rule).

What is NOT shown: that the fabric is real clay (its source says it is not calibrated),
that the write/read model below covers every branch of the Python code (checksums and
schema checks are left out), or anything about trajectories. Section 4 is about
transcribed counts and one cell's exact value, not the full arrays. The transcription
from Python and from the snapshots is outside the kernel. No Mathlib is needed.
Not compiled when written.
-/
set_option autoImplicit false

namespace FabricMemory

/-! ### 1. The layout -/

def header : Nat := 23
def materialPoints : Nat := 384
def capacity : Nat := 4
def byteCount : Nat := 2 * (header + 6 * materialPoints) + 4
def bitsPerSlot : Nat := byteCount * 8
def size : Nat := capacity * bitsPerSlot

theorem layout : byteCount = 4658 ∧ bitsPerSlot = 37264 ∧ size = 149056 := by decide

/-! ### 2. Writing: nothing is overwritten -/

/-- The fabric's records, as the list of stored event IDs in slot order. A write is
refused (`none`) for a repeated event or when every slot is used; otherwise the record
goes into the first free slot. -/
def write (store : List Nat) (event : Nat) : Option (List Nat) :=
  if event ∈ store then none
  else if capacity ≤ store.length then none
  else some (store ++ [event])

/-- An accepted write keeps every record that was already there. -/
theorem write_keeps_every_record (store after : List Nat) (event : Nat)
    (accepted : write store event = some after) : ∀ earlier ∈ store, earlier ∈ after := by
  unfold write at accepted
  split at accepted
  · cases accepted
  · split at accepted
    · cases accepted
    · cases accepted
      intro earlier found
      exact List.mem_append_left _ found

theorem repeated_event_is_refused (store : List Nat) (event : Nat) (stored : event ∈ store) :
    write store event = none := by
  unfold write
  split
  · rfl
  · contradiction

theorem full_fabric_refuses (store : List Nat) (event : Nat) (full : capacity ≤ store.length) :
    write store event = none := by
  unfold write
  split
  · rfl
  · split
    · rfl
    · contradiction

/-- The run's three writes, and what would follow: a fourth record fits, a fifth does not. -/
theorem the_three_writes_and_the_limit :
    write [] 0 = some [0] ∧ write [0] 1 = some [0, 1] ∧ write [0, 1] 2 = some [0, 1, 2] ∧
      write [0, 1, 2] 3 = some [0, 1, 2, 3] ∧ write [0, 1, 2, 3] 4 = none := by
  decide

/-! ### 3. Reading: the middle is refused, not guessed -/

/-- Reading one cell whose mark is `b`, with rest amplitude `a`. The cell is refused when
`|b| < a/4`; otherwise the bit is whether `b` is positive. -/
def readCell (a b : Int) : Option Bool :=
  if 4 * b < a ∧ -a < 4 * b then none else some (decide (0 < b))

theorem upper_mark_reads_one (a : Int) (positive : 0 < a) : readCell a a = some true := by
  have outside : ¬ (4 * a < a ∧ -a < 4 * a) := by omega
  unfold readCell
  rw [if_neg outside, decide_eq_true positive]

theorem lower_mark_reads_zero (a : Int) (positive : 0 < a) : readCell a (-a) = some false := by
  have outside : ¬ (4 * -a < a ∧ -a < 4 * -a) := by omega
  have notPositive : ¬ (0 < -a) := by omega
  unfold readCell
  rw [if_neg outside, decide_eq_false notPositive]

/-- A cell sitting on the barrier is not given a bit at all. -/
theorem barrier_is_refused (a : Int) (positive : 0 < a) : readCell a 0 = none := by
  have inside : 4 * 0 < a ∧ -a < 4 * 0 := by omega
  unfold readCell
  rw [if_pos inside]

/-! ### 4. Saved run: the records stay, every mark moves -/

/-- Two saved instants of the threshold-1, breathing-on run. -/
inductive Instant
  | afterSecondWrite   -- frame 400, model time 0.8
  | beforeThirdWrite   -- frame 599, model time 1.198
  deriving DecidableEq, Repr

/-- Event IDs decoded from the fabric by the sealed solver. -/
def decoded : Instant → List Nat
  | .afterSecondWrite => [0, 1]
  | .beforeThirdWrite => [0, 1]

/-- The mark of cell 0 as an exact fraction over 2^58 (the saved binary64 value):
0.01998557262231108 at frame 400 and 0.019974321339023573 at frame 599. -/
def cellZeroNumerator : Instant → Nat
  | .afterSecondWrite => 5760449114536075
  | .beforeThirdWrite => 5757206152921927

def cellZeroDenominator : Nat := 288230376151711744

/-- Counts measured between the two instants. -/
def cellsThatMoved : Nat := 149056
def cellsThatChangedSign : Nat := 0
/-- Cells changed by the third write itself, from the before/after pair at time 1.2. -/
def cellsChangedByThirdWrite : Nat := 37264
/-- Cells of the third record's slot left at the upper mark. -/
def bitsSetByThirdWrite : Nat := 18726

theorem denominator_is_a_power_of_two : cellZeroDenominator = 2 ^ 58 := by decide +kernel

theorem every_cell_moved_and_no_bit_flipped :
    cellsThatMoved = size ∧ cellsThatChangedSign = 0 := by decide

theorem third_write_touched_exactly_one_slot :
    cellsChangedByThirdWrite = bitsPerSlot ∧ bitsSetByThirdWrite ≤ bitsPerSlot := by decide

theorem same_records_decoded :
    decoded .afterSecondWrite = decoded .beforeThirdWrite := rfl

theorem cell_zero_moved :
    cellZeroNumerator .afterSecondWrite ≠ cellZeroNumerator .beforeThirdWrite := by
  decide +kernel

/-- The ambiguous-observation rule, for a property of any type. Same proof as
`SIMSLatentReadout.no_exact_reader_of_ambiguous_observation`. -/
theorem no_exact_reader_of_any_property {S O P : Type}
    (observe : S → O) (property : S → P) (a b : S)
    (same : observe a = observe b) (different : property a ≠ property b) :
    ¬ ∃ reader : O → P, ∀ s, reader (observe s) = property s :=
  fun ⟨reader, correct⟩ =>
    different ((correct a).symm.trans ((congrArg reader same).trans (correct b)))

/-- The fabric as an instance: no rule that reads only the decoded records can give the
mark of cell 0. The records are carried unchanged while the material holding them moves. -/
theorem decoded_records_cannot_give_the_marks :
    ¬ ∃ reader : List Nat → Nat, ∀ t : Instant, reader (decoded t) = cellZeroNumerator t :=
  no_exact_reader_of_any_property decoded cellZeroNumerator
    .afterSecondWrite .beforeThirdWrite same_records_decoded cell_zero_moved

end FabricMemory

#print axioms FabricMemory.layout
#print axioms FabricMemory.write_keeps_every_record
#print axioms FabricMemory.repeated_event_is_refused
#print axioms FabricMemory.full_fabric_refuses
#print axioms FabricMemory.the_three_writes_and_the_limit
#print axioms FabricMemory.upper_mark_reads_one
#print axioms FabricMemory.lower_mark_reads_zero
#print axioms FabricMemory.barrier_is_refused
#print axioms FabricMemory.every_cell_moved_and_no_bit_flipped
#print axioms FabricMemory.third_write_touched_exactly_one_slot
#print axioms FabricMemory.decoded_records_cannot_give_the_marks
