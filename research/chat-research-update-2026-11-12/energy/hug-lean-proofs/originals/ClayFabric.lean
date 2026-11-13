import Mathlib

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

1. Holds an imprint: with the strain matching, both marks `+a` and `-a` are rest points.
2. Soft and moves: at a mark, any strain mismatch moves the mark.
3. Not hard locked: the barrier between the two marks is finite, `H/4`.
4. Settling only makes heat: relaxation never returns energy.
5. The probe reads the mark exactly, and the stored bit is its sign. So the bit stays the
   same while the mark moves, and the bit cannot give back the mark (an instance of the
   ambiguous-observation rule, with the same numbers as SIMS case C07).

Section 6 uses two formulas quoted in the handoff audit for the earlier clay models.
Their source files were not inspected here, so those theorems are about the quoted
formulas only.

What is NOT shown: that this fabric is real clay, that it matches the earlier clay
models, or anything about a whole trajectory. Statements are for one cell at one
instant. The transcription from Python is outside the kernel. Not compiled when written.
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

/-! ### 3. It is not hard locked: the barrier is finite -/

theorem energy_at_a_mark (H a : ℝ) (amplitude : a ≠ 0) : wellEnergy H a a = 0 := by
  unfold wellEnergy
  rw [div_self amplitude]
  simp

theorem energy_at_the_barrier (H a : ℝ) : wellEnergy H a 0 = H / 4 := by
  norm_num [wellEnergy]

/-- Moving a mark across costs a positive, finite amount: a quarter of the well height. -/
theorem barrier_is_finite_and_positive (H a : ℝ) (amplitude : a ≠ 0) (height : 0 < H) :
    wellEnergy H a a < wellEnergy H a 0 ∧ wellEnergy H a 0 - wellEnergy H a a = H / 4 := by
  rw [energy_at_a_mark H a amplitude, energy_at_the_barrier]
  constructor
  · positivity
  · ring

/-! ### 4. Settling only makes heat -/

theorem heat_is_never_negative (M κ H a e b : ℝ) (mobility : 0 ≤ M) : 0 ≤ heat M κ H a e b := by
  unfold heat
  exact mul_nonneg mobility (sq_nonneg _)

/-- The energy change from the mark's own motion is exactly minus the heat. -/
theorem settling_turns_energy_into_heat (M κ H a e b : ℝ) :
    gradient κ H a e b * rate M κ H a e b = -heat M κ H a e b := by
  unfold rate heat
  ring

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

/-- An unwritten cell starts at `-a = -0.02`. A mark of `-0.0192` is 4% closer to zero.
The value moved; the stored sign did not. (The second number is SIMS case C07's, not a
value taken from a solver run.) -/
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

/-- Clay as an instance: no rule that reads only the stored sign can give back the mark. -/
theorem stored_bit_cannot_give_back_the_mark :
    ¬ ∃ reader : ℤ → ℝ, ∀ mark : ℝ, reader (signRead mark) = mark :=
  no_exact_reader_of_any_property signRead (fun mark : ℝ => mark)
    (-(1 / 50)) (-(12 / 625)) mark_moves_while_bit_stays.2
    (by
      show (-(1 / 50) : ℝ) ≠ -(12 / 625)
      exact mark_moves_while_bit_stays.1)

/-! ### 6. The two earlier clay formulas, as quoted in the handoff audit -/

/-- Early prototype: `imprint_new = p + (imprint_old - p) * r`, where `r = exp(-dt/tau)`
lies between 0 and 1. The imprint moves toward the pressure and never overshoots. -/
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
