import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Tactic

/-!
Clay in the Hug v3 solver: it holds an imprint, and it is soft.

Sections 1–5 transcribe one cell of the fabric from `structural_hug.py` (class `Fabric`)
in the Tick 41 packages:

    w        = .5*micro_k*(e-b)**2 + well_height/4*((b/rest_amplitude)**2-1)**2
    gradient = micro_k*(b-e) + well_height*b/rest_amplitude**2*((b/rest_amplitude)**2-1)
    bd       = -fabric_mobility*gradient
    heat     = fabric_mobility*gradient*gradient
    estimated = mean(loads - tractions/micro_k),  tractions = micro_k*(load - b)
    bit      = estimated > 0

Here `e` is the local strain, `b` the cell's rest strain (the mark), `κ` = micro_k,
`H` = well_height, `a` = rest_amplitude, `M` = fabric_mobility. The source file opens:
"Declared synthetic material-memory candidate, not calibrated clay or human memory."

What is shown:

1. With nonzero amplitude and matching strain, both marks `+a` and `-a` are rest points.
   This is a rest-point statement, not a stability or memory-retention theorem.
2. At either mark, a strain mismatch gives a nonzero rate when mobility and stiffness
   are nonzero.
3. The well-energy difference from a mark to zero is `H/4`, positive when `H > 0`.
   This is not the total transition cost at fixed strain or a proof of crossing.
4. For nonnegative mobility, relaxation at fixed strain dissipates energy into heat.
   This does not rule out energy exchange caused by changing the strain.
5. The ideal exact-real probe reads the mark when stiffness is nonzero. Both the
   three-way sign and the solver's Boolean `mark > 0` lose the mark's magnitude.
   Two distinct example marks have the same readings; no trajectory between them is
   established (an ambiguous-observation instance using SIMS case C07's numbers).

Section 6 uses two formulas quoted in the handoff audit for the earlier clay models.
Their source files were not inspected here, so those theorems are about the quoted
formulas only.

What is NOT shown: that this fabric is real clay, that it matches the earlier clay
models, or anything about a whole trajectory. Statements are for one cell at one
instant. The transcription from Python is outside the kernel and does not certify
floating-point execution. The ideal probe here has no added noise. The full reader's
finite-value, array-shape, read-margin, and payload checks are not formalized; the
two example marks are separately shown to clear the declared read margin of 0.005.
See the accompanying verification receipt.
-/
set_option autoImplicit false
noncomputable section

namespace ClayFabric

/-! ### The fabric cell -/

def wellEnergy (H a b : ℝ) : ℝ := H / 4 * ((b / a) ^ 2 - 1) ^ 2

def energy (κ H a e b : ℝ) : ℝ := κ / 2 * (e - b) ^ 2 + wellEnergy H a b

def gradient (κ H a e b : ℝ) : ℝ := κ * (b - e) + H * b / a ^ 2 * ((b / a) ^ 2 - 1)

/-- How fast the mark moves. -/
def rate (M κ H a e b : ℝ) : ℝ := -(M * gradient κ H a e b)

/-- Heat produced as the mark moves. -/
def heat (M κ H a e b : ℝ) : ℝ := M * gradient κ H a e b ^ 2

/-- The two-load probe: average of `load - traction/κ` at loads `e - q` and `e + q`. -/
def probeEstimate (κ q e b : ℝ) : ℝ :=
  (((e - q) - κ * ((e - q) - b) / κ) + ((e + q) - κ * ((e + q) - b) / κ)) / 2

/-! ### 1. It holds an imprint -/

theorem upper_mark_rests (κ H a : ℝ) (amplitude : a ≠ 0) : gradient κ H a a a = 0 := by
  unfold gradient
  rw [div_self amplitude]
  simp

theorem lower_mark_rests (κ H a : ℝ) (amplitude : a ≠ 0) : gradient κ H a (-a) (-a) = 0 := by
  unfold gradient
  rw [neg_div, div_self amplitude]
  simp

/-! ### 2. It is soft: strain moves the mark -/

/-- At the upper mark, only the mismatch between strain and mark is left. -/
theorem gradient_at_upper_mark (κ H a e : ℝ) (amplitude : a ≠ 0) :
    gradient κ H a e a = κ * (a - e) := by
  unfold gradient
  rw [div_self amplitude]
  simp

/-- So if the strain differs from the mark, the mark is moving. -/
theorem mismatched_strain_moves_the_mark (M κ H a e : ℝ) (amplitude : a ≠ 0)
    (mobile : M ≠ 0) (stiff : κ ≠ 0) (mismatch : e ≠ a) : rate M κ H a e a ≠ 0 := by
  unfold rate
  rw [gradient_at_upper_mark κ H a e amplitude]
  exact neg_ne_zero.mpr
    (mul_ne_zero mobile (mul_ne_zero stiff (sub_ne_zero.mpr (Ne.symm mismatch))))

/-- The corresponding gradient at the lower mark. -/
theorem gradient_at_lower_mark (κ H a e : ℝ) (amplitude : a ≠ 0) :
    gradient κ H a e (-a) = κ * (-a - e) := by
  unfold gradient
  rw [neg_div, div_self amplitude]
  simp

/-- A strain mismatch also moves the lower mark, under the same nonzero assumptions. -/
theorem mismatched_strain_moves_lower_mark (M κ H a e : ℝ) (amplitude : a ≠ 0)
    (mobile : M ≠ 0) (stiff : κ ≠ 0) (mismatch : e ≠ -a) :
    rate M κ H a e (-a) ≠ 0 := by
  unfold rate
  rw [gradient_at_lower_mark κ H a e amplitude]
  exact neg_ne_zero.mpr
    (mul_ne_zero mobile (mul_ne_zero stiff (sub_ne_zero.mpr (Ne.symm mismatch))))

/-! ### 3. It is not hard locked: the barrier is finite -/

theorem energy_at_a_mark (H a : ℝ) (amplitude : a ≠ 0) : wellEnergy H a a = 0 := by
  unfold wellEnergy
  rw [div_self amplitude]
  simp

theorem energy_at_the_barrier (H a : ℝ) : wellEnergy H a 0 = H / 4 := by
  norm_num [wellEnergy]

/-- The well-energy difference between a mark and zero is positive and equals H/4.
This does not include the elastic energy or establish a transition path. -/
theorem barrier_is_finite_and_positive (H a : ℝ) (amplitude : a ≠ 0) (height : 0 < H) :
    wellEnergy H a a < wellEnergy H a 0 ∧ wellEnergy H a 0 - wellEnergy H a a = H / 4 := by
  rw [energy_at_a_mark H a amplitude, energy_at_the_barrier]
  constructor
  · positivity
  · ring

/-! ### 4. Settling only makes heat -/

/-- With strain held fixed, `gradient` is the derivative of the declared cell energy. -/
theorem energy_has_derivative_gradient (κ H a e b : ℝ) (amplitude : a ≠ 0) :
    HasDerivAt (fun mark : ℝ => energy κ H a e mark) (gradient κ H a e b) b := by
  have elastic := (((hasDerivAt_const b e).sub (hasDerivAt_id b)).pow 2).const_mul (κ / 2)
  have well := ((((hasDerivAt_id b).div_const a).pow 2).sub_const 1).pow 2
  have total := elastic.add (well.const_mul (H / 4))
  convert total using 1 <;>
    first
    | rfl
    | (dsimp [energy, wellEnergy, gradient]; field_simp [amplitude]; ring)

theorem heat_is_never_negative (M κ H a e b : ℝ) (mobility : 0 ≤ M) : 0 ≤ heat M κ H a e b := by
  unfold heat
  exact mul_nonneg mobility (sq_nonneg _)

/-- The energy change from the mark's own motion is exactly minus the heat. -/
theorem settling_turns_energy_into_heat (M κ H a e b : ℝ) :
    gradient κ H a e b * rate M κ H a e b = -heat M κ H a e b := by
  unfold rate heat
  ring

/-- The fixed-strain contribution from relaxation is nonpositive for nonnegative mobility. -/
theorem settling_energy_rate_nonpositive (M κ H a e b : ℝ) (mobility : 0 ≤ M) :
    gradient κ H a e b * rate M κ H a e b ≤ 0 := by
  rw [settling_turns_energy_into_heat]
  exact neg_nonpos.mpr (heat_is_never_negative M κ H a e b mobility)

/-! ### 5. The reading: exact mark, stored as a sign -/

theorem probe_reads_the_mark (κ q e b : ℝ) (stiff : κ ≠ 0) : probeEstimate κ q e b = b := by
  have low : κ * ((e - q) - b) / κ = (e - q) - b := by field_simp
  have high : κ * ((e + q) - b) / κ = (e + q) - b := by field_simp
  unfold probeEstimate
  rw [low, high]
  ring

/-- The same three-way sign reading as `SIMSLatentReadout.signRead`. The solver stores
the bit `estimated > 0`. -/
def signRead (x : ℝ) : ℤ := if x < 0 then -1 else if x = 0 then 0 else 1

/-- The actual Boolean reading in the solver. Unlike `signRead`, zero and negative
marks have the same reading. -/
def storedBit (mark : ℝ) : Bool := decide (0 < mark)

/-- An unwritten cell starts at `-a = -0.02`. A mark of `-0.0192` is 4% closer to zero.
These are distinct values with the same sign. The second number is SIMS case C07's,
not a solver sample, and this statement does not establish motion between the two. -/
theorem mark_moves_while_bit_stays :
    (-(1 / 50) : ℝ) ≠ -(12 / 625) ∧ signRead (-(1 / 50)) = signRead (-(12 / 625)) := by
  constructor
  · norm_num
  · norm_num [signRead]

/-- The ambiguous-observation rule, for a property of any type. Same proof as
`SIMSLatentReadout.no_exact_reader_of_ambiguous_observation`. -/
theorem no_exact_reader_of_any_property {S O P : Type}
    (observe : S → O) (property : S → P) (a b : S)
    (same : observe a = observe b) (different : property a ≠ property b) :
    ¬ ∃ reader : O → P, ∀ s, reader (observe s) = property s :=
  fun ⟨reader, correct⟩ =>
    different ((correct a).symm.trans ((congrArg reader same).trans (correct b)))

/-- No reader of the three-way sign can recover every mark. The Boolean result follows below. -/
theorem stored_bit_cannot_give_back_the_mark :
    ¬ ∃ reader : ℤ → ℝ, ∀ mark : ℝ, reader (signRead mark) = mark :=
  no_exact_reader_of_any_property signRead (fun mark : ℝ => mark)
    (-(1 / 50)) (-(12 / 625)) mark_moves_while_bit_stays.2
    (by
      show (-(1 / 50) : ℝ) ≠ -(12 / 625)
      exact mark_moves_while_bit_stays.1)

/-- The two example marks also have the same solver-style Boolean bit. -/
theorem distinct_marks_same_boolean_bit :
    (-(1 / 50) : ℝ) ≠ -(12 / 625) ∧
      storedBit (-(1 / 50)) = storedBit (-(12 / 625)) := by
  norm_num [storedBit]

/-- A reader of the actual Boolean bit cannot recover every mark. -/
theorem boolean_bit_cannot_give_back_the_mark :
    ¬ ∃ reader : Bool → ℝ, ∀ mark : ℝ, reader (storedBit mark) = mark :=
  no_exact_reader_of_any_property storedBit (fun mark : ℝ => mark)
    (-(1 / 50)) (-(12 / 625)) distinct_marks_same_boolean_bit.2
    distinct_marks_same_boolean_bit.1

/-- With read_margin = 0.25 and rest_amplitude = 0.02, the acceptance threshold
is 0.005. Both example marks clear it. -/
theorem example_marks_clear_read_margin :
    (1 / 4 : ℝ) * (1 / 50) = 1 / 200 ∧
      (1 / 200 : ℝ) ≤ |-(1 / 50)| ∧ (1 / 200 : ℝ) ≤ |-(12 / 625)| := by
  norm_num

/-- The Boolean ambiguity remains even when restricting to marks beyond the declared
read margin. This does not model the full array or payload validation. -/
theorem boolean_bit_cannot_recover_margin_accepted_marks :
    ¬ ∃ reader : Bool → ℝ, ∀ mark : ℝ, (1 / 200 : ℝ) ≤ |mark| →
      reader (storedBit mark) = mark := by
  rintro ⟨reader, correct⟩
  have first := correct (-(1 / 50)) example_marks_clear_read_margin.2.1
  have second := correct (-(12 / 625)) example_marks_clear_read_margin.2.2
  apply distinct_marks_same_boolean_bit.1
  exact first.symm.trans ((congrArg reader distinct_marks_same_boolean_bit.2).trans second)

/-! ### 6. The two earlier clay formulas, as quoted in the handoff audit -/

/-- Early prototype: `imprint_new = p + (imprint_old - p) * r`, where `r = exp(-dt/tau)`
lies between 0 and 1. This theorem says the distance to pressure does not increase. -/
theorem imprint_moves_toward_pressure (p old r : ℝ) (lower : 0 ≤ r) (upper : r ≤ 1) :
    |p + (old - p) * r - p| ≤ |old - p| := by
  have step : p + (old - p) * r - p = (old - p) * r := by ring
  rw [step, abs_mul, abs_of_nonneg lower]
  exact mul_le_of_le_one_right (abs_nonneg _) upper

/-- Clay calculation: after release, the strain kept is `stress * holdTime / viscosity`. -/
def retained (stress holdTime viscosity : ℝ) : ℝ := stress * holdTime / viscosity

/-- The kept shape cannot say how hard versus how long: a light load held long and a
heavy load held briefly leave the same imprint. -/
theorem kept_shape_cannot_tell_how_hard :
    ¬ ∃ reader : ℝ → ℝ, ∀ load : ℝ × ℝ, reader (retained load.1 load.2 1) = load.1 :=
  no_exact_reader_of_any_property (fun load : ℝ × ℝ => retained load.1 load.2 1)
    (fun load => load.1) (1, 2) (2, 1)
    (by
      show retained 1 2 1 = retained 2 1 1
      norm_num [retained])
    (by
      show (1 : ℝ) ≠ 2
      norm_num)

end ClayFabric

#print axioms ClayFabric.upper_mark_rests
#print axioms ClayFabric.lower_mark_rests
#print axioms ClayFabric.mismatched_strain_moves_the_mark
#print axioms ClayFabric.barrier_is_finite_and_positive
#print axioms ClayFabric.heat_is_never_negative
#print axioms ClayFabric.settling_turns_energy_into_heat
#print axioms ClayFabric.probe_reads_the_mark
#print axioms ClayFabric.mark_moves_while_bit_stays
#print axioms ClayFabric.stored_bit_cannot_give_back_the_mark
#print axioms ClayFabric.imprint_moves_toward_pressure
#print axioms ClayFabric.kept_shape_cannot_tell_how_hard
#print axioms ClayFabric.gradient_at_lower_mark
#print axioms ClayFabric.mismatched_strain_moves_lower_mark
#print axioms ClayFabric.energy_has_derivative_gradient
#print axioms ClayFabric.settling_energy_rate_nonpositive
#print axioms ClayFabric.distinct_marks_same_boolean_bit
#print axioms ClayFabric.boolean_bit_cannot_give_back_the_mark
#print axioms ClayFabric.example_marks_clear_read_margin
#print axioms ClayFabric.boolean_bit_cannot_recover_margin_accepted_marks
