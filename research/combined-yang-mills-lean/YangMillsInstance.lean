import Mathlib

/-!
The order-zero Yang–Mills reading as an instance of the ambiguous-observation rule.

`curve` and `readJet` below are copied from `Implicit.lean` in the OpenAI October
submission preserved in `yang-mills-group/YM` at commit
55ba9fc36293b3f4d52c6b1f813169a0be76ee98 (lines 13 and 22). Both definitions were
confirmed against that upstream revision, ignoring whitespace, during the Codex check.

What is shown: for this definition of `readJet`, the order-zero reading depends only on
the leading coefficients. In the real projection example with truncation order 1, two
inputs with the same leading coefficient and different first coefficients give the
same order-zero reading and different order-one readings.

What is NOT shown: anything about the Yang–Mills construction itself. The example uses
the projection `W (z, v) = z` on real numbers. It is not an admissible Yang–Mills family,
and no theorem of the submission is contradicted. The submission limits its own claim to
leading order.

The three numbers are the Tick 41 accumulator value and its two rates, used only as
example coefficients, as in the Tick 41 report.
-/
set_option autoImplicit false
noncomputable section

namespace YangMillsInstance

/-- The rule, for a property of any type. Same proof as
`SIMSLatentReadout.no_exact_reader_of_ambiguous_observation`. -/
theorem no_exact_reader_of_any_property {S O P : Type}
    (observe : S → O) (property : S → P) (a b : S)
    (same : observe a = observe b) (different : property a ≠ property b) :
    ¬ ∃ reader : O → P, ∀ s, reader (observe s) = property s :=
  fun ⟨reader, correct⟩ =>
    different ((correct a).symm.trans ((congrArg reader same).trans (correct b)))

section definitions
variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]

/-- Copied from the source: Taylor data as a polynomial in `t`, truncated at order `m`. -/
def curve (x : ℕ → E) (m : ℕ) (t : ℝ) : E := ∑ i ∈ Finset.range (m + 1), t ^ i • x i

lemma curve_zero (x : ℕ → E) (m : ℕ) : curve x m 0 = x 0 := by
  induction m with
  | zero => simp [curve]
  | succ m ih =>
    unfold curve at ih ⊢
    rw [Finset.sum_range_succ, ih]
    simp [pow_succ]

variable {A C Z V : Type*} [NormedAddCommGroup A] [NormedSpace ℝ A]
  [NormedAddCommGroup C] [NormedSpace ℝ C] [NormedAddCommGroup Z] [NormedSpace ℝ Z]
  [NormedAddCommGroup V] [NormedSpace ℝ V]

/-- Copied from the source: `m` truncates the input, `n` is the derivative order read. -/
def readJet (φ : A → V) (m n : ℕ) (W : C × V → Z) (x : ℕ → A) (z : ℕ → C) :=
  iteratedDeriv n (fun t : ℝ => W (curve z m t, φ (curve x m t))) 0

/-- The source's `continuous_jet` reduction: at order zero only leading coefficients are read. -/
theorem order_zero_reads_only_leading (φ : A → V) (p : ℕ) (W : C × V → Z)
    (x : ℕ → A) (z : ℕ → C) : readJet φ p 0 W x z = W (z 0, φ (x 0)) := by
  simp only [readJet, iteratedDeriv_zero, curve_zero]

/-- For every truncation order, calibration and test: inputs that agree in their leading
coefficient get the same order-zero reading, whatever their higher coefficients are. -/
theorem order_zero_blind_to_higher_coefficients {φ : A → V} {p : ℕ} {W : C × V → Z}
    {x : ℕ → A} {z z' : ℕ → C} (leading : z 0 = z' 0) :
    readJet φ p 0 W x z = readJet φ p 0 W x z' := by
  rw [order_zero_reads_only_leading, order_zero_reads_only_leading, leading]

end definitions

/-! ### A local real-number example (not a Yang–Mills family) -/

/-- Calibration adjustment `φ x = -x`. -/
def negate : ℝ → ℝ := fun x => -x
/-- Independent test `W (z, v) = z`. -/
def project : ℝ × ℝ → ℝ := fun q => q.1
/-- Calibration input held at zero. -/
def zeroInput : ℕ → ℝ := fun _ => 0
/-- Taylor data with leading coefficient `a`, first coefficient `b`, nothing higher. -/
def jetData (a b : ℝ) : ℕ → ℝ := fun i => if i = 0 then a else if i = 1 then b else 0

lemma jetData_zero (a b : ℝ) : jetData a b 0 = a := by simp [jetData]
lemma jetData_one (a b : ℝ) : jetData a b 1 = b := by simp [jetData]

lemma curve_one_eq (z : ℕ → ℝ) (t : ℝ) : curve z 1 t = z 0 + t * z 1 := by
  simp [curve, Finset.sum_range_succ]

/-- With truncation order 1, the order-one reading of the projection is the first coefficient. -/
lemma readJet_one_project (z : ℕ → ℝ) : readJet negate 1 1 project zeroInput z = z 1 := by
  have shape : (fun t : ℝ => project (curve z 1 t, negate (curve zeroInput 1 t))) =
      fun t => z 0 + t * z 1 := by
    funext t
    exact curve_one_eq z t
  have slope : HasDerivAt (fun t : ℝ => z 0 + t * z 1) (z 1) 0 := by
    simpa using ((hasDerivAt_id (0 : ℝ)).mul_const (z 1)).const_add (z 0)
  unfold readJet
  rw [shape, iteratedDeriv_one]
  exact slope.deriv

/-- Example coefficients: the Tick 41 accumulator value and its two rates. -/
def leadingValue : ℝ := 6429061322641351 / 1000000000000000000
def rateBefore : ℝ := 8194451110496026 / 1000000000000000000
def rateAfter : ℝ := 8309196904720758 / 1000000000000000000

/-- The order-zero readings agree. -/
theorem order_zero_readings_agree :
    readJet negate 1 0 project zeroInput (jetData leadingValue rateBefore) =
      readJet negate 1 0 project zeroInput (jetData leadingValue rateAfter) :=
  order_zero_blind_to_higher_coefficients (by rw [jetData_zero, jetData_zero])

/-- The order-one readings differ. -/
theorem order_one_readings_differ :
    readJet negate 1 1 project zeroInput (jetData leadingValue rateBefore) ≠
      readJet negate 1 1 project zeroInput (jetData leadingValue rateAfter) := by
  rw [readJet_one_project, readJet_one_project, jetData_one, jetData_one]
  norm_num [rateBefore, rateAfter]

/-- The instance: no rule that reads only the order-zero `readJet` value can give, for
every input, the order-one `readJet` value. -/
theorem order_zero_reading_cannot_determine_first_derivative :
    ¬ ∃ reader : ℝ → ℝ, ∀ z : ℕ → ℝ,
      reader (readJet negate 1 0 project zeroInput z) =
        readJet negate 1 1 project zeroInput z :=
  no_exact_reader_of_any_property
    (fun z : ℕ → ℝ => readJet negate 1 0 project zeroInput z)
    (fun z : ℕ → ℝ => readJet negate 1 1 project zeroInput z)
    (jetData leadingValue rateBefore) (jetData leadingValue rateAfter)
    order_zero_readings_agree order_one_readings_differ

end YangMillsInstance

#print axioms YangMillsInstance.order_zero_reads_only_leading
#print axioms YangMillsInstance.order_zero_blind_to_higher_coefficients
#print axioms YangMillsInstance.readJet_one_project
#print axioms YangMillsInstance.order_zero_readings_agree
#print axioms YangMillsInstance.order_one_readings_differ
#print axioms YangMillsInstance.order_zero_reading_cannot_determine_first_derivative
