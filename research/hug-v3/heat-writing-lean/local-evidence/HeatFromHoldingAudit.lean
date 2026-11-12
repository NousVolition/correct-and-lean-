import Mathlib

/-!
Heat in the Hug v3 solver: holding makes warmth, and warmth thins the fluid.

Transcribed from the Tick 41 packages:

    # structural_hug.py, Fabric.prepare_write
    delta     = target - b
    heat_cell = stroke_drag*delta*delta/stroke_duration
    work      = stored + dissipation
    # structural_hug.py, Solver.write_event
    out['g'][...,4] += self.filter(heat_grid)          # heat goes into the temperature field
    # continuum.py, rhs
    nu = c.nu*np.exp(-c.thermal_feedback*np.tanh(theta/.03))

with stroke_drag 0.05, stroke_duration 0.02 and thermal_feedback 0.35.

What is shown:

1. Every stroke that moves a mark makes heat, never a negative amount, and the same
   amount whichever way the mark moves.
2. So no rule that reads only the heat can say which way a mark was moved (an instance
   of the ambiguous-observation rule): the warmth does not say what was written.
3. A write's work is what it stores plus what it turns to heat. When nothing more is
   stored, all of the work becomes heat.
4. The third write of the saved run (tick 41): the stored energy went slightly down, so
   the heat was larger than the work put in.
5. Warmer fluid is thinner, but never thinner than a fixed floor and never zero.

What is NOT shown: how the heat spreads afterwards, whether it builds up over many
writes, or anything about trajectories. In part 5 the warmth level `s` stands for
`tanh(theta/0.03)`, which lies between -1 and 1 and rises with temperature; that property
of `tanh` is assumed, not proved here. The transcription from Python and from
`results.json` is outside the kernel. Not compiled when written.
-/
set_option autoImplicit false
noncomputable section

namespace HeatFromHolding

/-! ### 1. A stroke makes heat -/

/-- Heat made in one cell when its mark is moved by `δ`. -/
def strokeHeat (drag duration δ : ℝ) : ℝ := drag * δ * δ / duration

theorem stroke_heat_never_negative (drag duration δ : ℝ)
    (dragOk : 0 ≤ drag) (durationOk : 0 < duration) : 0 ≤ strokeHeat drag duration δ := by
  have shape : drag * δ * δ = drag * (δ * δ) := by ring
  unfold strokeHeat
  rw [shape]
  exact div_nonneg (mul_nonneg dragOk (mul_self_nonneg δ)) durationOk.le

/-- If the mark moves at all, heat is made. -/
theorem moving_a_mark_makes_heat (drag duration δ : ℝ)
    (dragOk : 0 < drag) (durationOk : 0 < duration) (moved : δ ≠ 0) :
    0 < strokeHeat drag duration δ := by
  have shape : drag * δ * δ = drag * (δ * δ) := by ring
  unfold strokeHeat
  rw [shape]
  exact div_pos (mul_pos dragOk (mul_self_pos.mpr moved)) durationOk

/-- Moving a mark up or down by the same amount makes the same heat. -/
theorem heat_ignores_direction (drag duration δ : ℝ) :
    strokeHeat drag duration (-δ) = strokeHeat drag duration δ := by
  unfold strokeHeat
  ring

/-! ### 2. The warmth does not say what was written -/

/-- The ambiguous-observation rule, for a property of any type. Same proof as
`SIMSLatentReadout.no_exact_reader_of_ambiguous_observation`. -/
theorem no_exact_reader_of_any_property {S O P : Type}
    (observe : S → O) (property : S → P) (a b : S)
    (same : observe a = observe b) (different : property a ≠ property b) :
    ¬ ∃ reader : O → P, ∀ s, reader (observe s) = property s :=
  fun ⟨reader, correct⟩ =>
    different ((correct a).symm.trans ((congrArg reader same).trans (correct b)))

/-- For any drag and duration: no rule that reads only the heat can give the stroke. -/
theorem heat_cannot_tell_which_way (drag duration : ℝ) :
    ¬ ∃ reader : ℝ → ℝ, ∀ δ : ℝ, reader (strokeHeat drag duration δ) = δ :=
  no_exact_reader_of_any_property (strokeHeat drag duration) (fun δ : ℝ => δ) (-1) 1
    (heat_ignores_direction drag duration 1)
    (by
      show (-1 : ℝ) ≠ 1
      norm_num)

/-! ### 3. Work is what is stored plus what turns to heat -/

/-- The write account: `work = stored + dissipation`. -/
def writeWork (stored heat : ℝ) : ℝ := stored + heat

theorem heat_is_work_minus_stored (stored heat : ℝ) :
    heat = writeWork stored heat - stored := by
  unfold writeWork
  ring

/-- When a write stores nothing more, at least all of its work becomes heat. -/
theorem nothing_more_stored_means_all_work_is_heat (stored heat : ℝ) (noGain : stored ≤ 0) :
    writeWork stored heat ≤ heat := by
  unfold writeWork
  linarith

/-! ### 4. The third write of the saved run -/

/-- The recorded account at tick 41, in units of 1e-27 so that every value is whole:
work 1.5672159979486206e-05, stored -1.9218245776950046e-09, heat 1.5674081804063902e-05. -/
def recordedWork : ℤ := 15672159979486206000000
def recordedStored : ℤ := -1921824577695004600
def recordedHeat : ℤ := 15674081804063902000000

/-- The stored energy went down a little, and the heat exceeded the work put in. -/
theorem third_write_was_all_heat :
    recordedStored < 0 ∧ recordedWork < recordedHeat := by
  constructor <;> norm_num [recordedStored, recordedWork, recordedHeat]

/-- The recorded numbers satisfy `work = stored + heat` to within 1e-21 (their last
printed digits). -/
theorem recorded_account_balances :
    |recordedWork - (recordedStored + recordedHeat)| < 1000000 := by
  norm_num [recordedStored, recordedWork, recordedHeat, abs_lt]

/-! ### 5. Warmth thins the fluid, down to a floor -/

/-- Viscosity at warmth level `s`, where `s = tanh(theta/0.03)`. -/
def viscosity (base feedback s : ℝ) : ℝ := base * Real.exp (-(feedback * s))

theorem warmer_is_thinner (base feedback s s' : ℝ)
    (baseOk : 0 ≤ base) (feedbackOk : 0 ≤ feedback) (warmer : s ≤ s') :
    viscosity base feedback s' ≤ viscosity base feedback s := by
  unfold viscosity
  exact mul_le_mul_of_nonneg_left
    (Real.exp_le_exp.mpr (neg_le_neg (mul_le_mul_of_nonneg_left warmer feedbackOk))) baseOk

/-- However warm, the viscosity never falls below `base * exp(-feedback)`.
With feedback 0.35 that floor is about 70% of the base value. -/
theorem viscosity_has_a_floor (base feedback s : ℝ)
    (baseOk : 0 ≤ base) (feedbackOk : 0 ≤ feedback) (bounded : s ≤ 1) :
    base * Real.exp (-feedback) ≤ viscosity base feedback s := by
  unfold viscosity
  exact mul_le_mul_of_nonneg_left
    (Real.exp_le_exp.mpr (neg_le_neg (mul_le_of_le_one_right feedbackOk bounded))) baseOk

/-- And it is never zero: the fluid never stops resisting. -/
theorem viscosity_never_vanishes (base feedback s : ℝ) (baseOk : 0 < base) :
    0 < viscosity base feedback s := by
  unfold viscosity
  exact mul_pos baseOk (Real.exp_pos _)

end HeatFromHolding

#print axioms HeatFromHolding.stroke_heat_never_negative
#print axioms HeatFromHolding.moving_a_mark_makes_heat
#print axioms HeatFromHolding.heat_cannot_tell_which_way
#print axioms HeatFromHolding.nothing_more_stored_means_all_work_is_heat
#print axioms HeatFromHolding.third_write_was_all_heat
#print axioms HeatFromHolding.recorded_account_balances
#print axioms HeatFromHolding.warmer_is_thinner
#print axioms HeatFromHolding.viscosity_has_a_floor
#print axioms HeatFromHolding.viscosity_never_vanishes

#print axioms HeatFromHolding.stroke_heat_never_negative
#print axioms HeatFromHolding.moving_a_mark_makes_heat
#print axioms HeatFromHolding.heat_ignores_direction
#print axioms HeatFromHolding.no_exact_reader_of_any_property
#print axioms HeatFromHolding.heat_cannot_tell_which_way
#print axioms HeatFromHolding.heat_is_work_minus_stored
#print axioms HeatFromHolding.nothing_more_stored_means_all_work_is_heat
#print axioms HeatFromHolding.third_write_was_all_heat
#print axioms HeatFromHolding.recorded_account_balances
#print axioms HeatFromHolding.warmer_is_thinner
#print axioms HeatFromHolding.viscosity_has_a_floor
#print axioms HeatFromHolding.viscosity_never_vanishes
