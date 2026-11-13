import ActiveHugModel
import Mathlib.Tactic

/-!
The guard in the eight-state Hug model: one opening, two effects.

These theorems are about the definitions in `ActiveHugModel.lean` of the
`hug-existence-lean` package (`rhs`, `guardRate`, `targetAB`, `targetBA`, `guardLoss`),
imported unchanged. That file describes itself as a reduced, synthetic realization.

What is shown, for every parameter set with nonnegative weights and damping and for
every guard value, not only the 0.2 and 0.8 settings used in the 31 October check:

1. Opening a guard further increases or preserves the admitted-influence expressions
   and guard loss. For nonnegative guards the influence expressions are magnitudes;
   with nonnegative damping the guard loss is also nonnegative.
2. Reversing the motion leaves the guard's update and the guard's energy loss unchanged.
3. Therefore no rule that reads only the guard's response can recover the direction of
   motion (an instance of the ambiguous-observation rule).

What is NOT shown: that these effects are socially positive or negative, that the
reduced model is the full Hug-and-Navier–Stokes system, or anything about trajectories.
The statements concern the right-hand side of the equations at a single state.

Compile inside `lean/hug-existence-lean`, for example with
`lake env lean GuardTwoEffects.lean`. See the accompanying verification receipt for
the checked toolchain, source hashes, and results.
-/
set_option autoImplicit false
noncomputable section

namespace ActiveHug.GuardTwoEffects
open ActiveHug

/-! ### Where the guard sits in the equations -/

/-- A's response is its pull to baseline plus weight × guard × difference. -/
theorem response_A_formula (p : Parameters) (F : ℝ) (s : State) :
    (rhs p F s).xA = p.lambda * (p.baselineA - s.xA) + p.weightAB * s.gAB * (s.xB - s.xA) :=
  rfl

/-- B's response has the same form with the opposite difference. -/
theorem response_B_formula (p : Parameters) (F : ℝ) (s : State) :
    (rhs p F s).xB = p.lambda * (p.baselineB - s.xB) + p.weightBA * s.gBA * (s.xA - s.xB) :=
  rfl

/-- The energy removed through the guards. -/
theorem guard_loss_formula (p : Parameters) (s : State) :
    guardLoss p s = p.damping * (s.gAB + s.gBA) * s.v ^ 2 :=
  rfl

/-! ### One opening, two effects -/

/-- Size of the influence admitted to A through its guard. -/
def admittedToA (p : Parameters) (s : State) : ℝ := p.weightAB * s.gAB * |s.xB - s.xA|

/-- Size of the influence admitted to B through its guard. -/
def admittedToB (p : Parameters) (s : State) : ℝ := p.weightBA * s.gBA * |s.xA - s.xB|

/-- `admittedToA` is the absolute value of the guard term in A's response. -/
theorem admittedToA_is_size (p : Parameters) (s : State)
    (weight : 0 ≤ p.weightAB) (guard : 0 ≤ s.gAB) :
    |p.weightAB * s.gAB * (s.xB - s.xA)| = admittedToA p s := by
  unfold admittedToA
  rw [abs_mul, abs_of_nonneg (mul_nonneg weight guard)]

/-- The corresponding magnitude statement for B. -/
theorem admittedToB_is_size (p : Parameters) (s : State)
    (weight : 0 ≤ p.weightBA) (guard : 0 ≤ s.gBA) :
    |p.weightBA * s.gBA * (s.xA - s.xB)| = admittedToB p s := by
  unfold admittedToB
  rw [abs_mul, abs_of_nonneg (mul_nonneg weight guard)]

/-- Nonnegative damping and nonnegative guards make the guard loss nonnegative. -/
theorem guard_loss_nonnegative (p : Parameters) (s : State)
    (damping : 0 ≤ p.damping) (guardAB : 0 ≤ s.gAB) (guardBA : 0 ≤ s.gBA) :
    0 ≤ guardLoss p s := by
  unfold guardLoss
  exact mul_nonneg (mul_nonneg damping (add_nonneg guardAB guardBA)) (sq_nonneg s.v)

/-- With everything else equal, a more open guard admits at least as much to A. -/
theorem more_open_guard_admits_more_to_A (p : Parameters) (s s' : State)
    (weight : 0 ≤ p.weightAB) (sameA : s'.xA = s.xA) (sameB : s'.xB = s.xB)
    (wider : s.gAB ≤ s'.gAB) : admittedToA p s ≤ admittedToA p s' := by
  unfold admittedToA
  rw [sameA, sameB]
  exact mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_left wider weight) (abs_nonneg _)

/-- The same for B. -/
theorem more_open_guard_admits_more_to_B (p : Parameters) (s s' : State)
    (weight : 0 ≤ p.weightBA) (sameA : s'.xA = s.xA) (sameB : s'.xB = s.xB)
    (wider : s.gBA ≤ s'.gBA) : admittedToB p s ≤ admittedToB p s' := by
  unfold admittedToB
  rw [sameA, sameB]
  exact mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_left wider weight) (abs_nonneg _)

/-- With the same motion, more open guards remove at least as much energy. -/
theorem more_open_guards_resist_more (p : Parameters) (s s' : State)
    (damping : 0 ≤ p.damping) (sameMotion : s'.v = s.v)
    (widerAB : s.gAB ≤ s'.gAB) (widerBA : s.gBA ≤ s'.gBA) :
    guardLoss p s ≤ guardLoss p s' := by
  unfold guardLoss
  rw [sameMotion]
  exact mul_le_mul_of_nonneg_right
    (mul_le_mul_of_nonneg_left (add_le_add widerAB widerBA) damping) (sq_nonneg _)

/-- The 31 October finding for every guard value: opening the guards admits more
influence on both sides and adds resistance, together. -/
theorem one_opening_two_effects (p : Parameters) (s s' : State)
    (weightAB : 0 ≤ p.weightAB) (weightBA : 0 ≤ p.weightBA) (damping : 0 ≤ p.damping)
    (sameA : s'.xA = s.xA) (sameB : s'.xB = s.xB) (sameMotion : s'.v = s.v)
    (widerAB : s.gAB ≤ s'.gAB) (widerBA : s.gBA ≤ s'.gBA) :
    admittedToA p s ≤ admittedToA p s' ∧ admittedToB p s ≤ admittedToB p s' ∧
      guardLoss p s ≤ guardLoss p s' :=
  ⟨more_open_guard_admits_more_to_A p s s' weightAB sameA sameB widerAB,
   more_open_guard_admits_more_to_B p s s' weightBA sameA sameB widerBA,
   more_open_guards_resist_more p s s' damping sameMotion widerAB widerBA⟩

/-! ### Reversing the motion does not reverse the guard -/

theorem strain_ignores_direction (p : Parameters) (s s' : State) (reversed : s'.v = -s.v) :
    strainSignal p s' = strainSignal p s := by
  unfold strainSignal
  rw [reversed]
  ring

/-- Reversing the motion leaves the A-to-B guard's update unchanged. -/
theorem reversal_keeps_guard_update_AB (p : Parameters) (F : ℝ) (s s' : State)
    (reversed : s'.v = -s.v) (sameA : s'.xA = s.xA) (sameB : s'.xB = s.xB)
    (sameGuard : s'.gAB = s.gAB) : (rhs p F s').gAB = (rhs p F s).gAB := by
  have target : targetAB p s' = targetAB p s := by
    unfold targetAB
    rw [sameA, sameB, strain_ignores_direction p s s' reversed]
  show guardRate p.tau (targetAB p s') s'.gAB = guardRate p.tau (targetAB p s) s.gAB
  rw [target, sameGuard]

/-- Reversing the motion leaves the B-to-A guard's update unchanged. -/
theorem reversal_keeps_guard_update_BA (p : Parameters) (F : ℝ) (s s' : State)
    (reversed : s'.v = -s.v) (sameA : s'.xA = s.xA) (sameB : s'.xB = s.xB)
    (sameGuard : s'.gBA = s.gBA) : (rhs p F s').gBA = (rhs p F s).gBA := by
  have target : targetBA p s' = targetBA p s := by
    unfold targetBA
    rw [sameA, sameB, strain_ignores_direction p s s' reversed]
  show guardRate p.tau (targetBA p s') s'.gBA = guardRate p.tau (targetBA p s) s.gBA
  rw [target, sameGuard]

/-- Reversing the motion preserves guard loss. Its nonnegativity is a separate
statement, `guard_loss_nonnegative`, with explicit sign assumptions. -/
theorem reversal_keeps_guard_loss (p : Parameters) (s s' : State)
    (reversed : s'.v = -s.v) (sameAB : s'.gAB = s.gAB) (sameBA : s'.gBA = s.gBA) :
    guardLoss p s' = guardLoss p s := by
  unfold guardLoss
  rw [reversed, sameAB, sameBA]
  ring

/-! ### As an instance of the ambiguous-observation rule -/

/-- The rule, for a property of any type. Same proof as
`SIMSLatentReadout.no_exact_reader_of_ambiguous_observation`. -/
theorem no_exact_reader_of_any_property {S O P : Type}
    (observe : S → O) (property : S → P) (a b : S)
    (same : observe a = observe b) (different : property a ≠ property b) :
    ¬ ∃ reader : O → P, ∀ s, reader (observe s) = property s :=
  fun ⟨reader, correct⟩ =>
    different ((correct a).symm.trans ((congrArg reader same).trans (correct b)))

/-- What the guards do at a state: both updates and the energy they remove. -/
def guardResponse (p : Parameters) (F : ℝ) (s : State) : ℝ × ℝ × ℝ :=
  ((rhs p F s).gAB, (rhs p F s).gBA, guardLoss p s)

/-- The same state with the motion reversed. -/
def reverseMotion (s : State) : State := ⟨s.q, -s.v, s.u, s.w, s.xA, s.xB, s.gAB, s.gBA⟩

/-- A state at rest position, moving at unit speed, with everything else zero. -/
def unitMotion : State := ⟨0, 1, 0, 0, 0, 0, 0, 0⟩

theorem guard_response_same_after_reversal (p : Parameters) (F : ℝ) (s : State) :
    guardResponse p F s = guardResponse p F (reverseMotion s) := by
  have updateAB := reversal_keeps_guard_update_AB p F s (reverseMotion s) rfl rfl rfl rfl
  have updateBA := reversal_keeps_guard_update_BA p F s (reverseMotion s) rfl rfl rfl rfl
  have loss := reversal_keeps_guard_loss p s (reverseMotion s) rfl rfl rfl
  unfold guardResponse
  rw [updateAB, updateBA, loss]

/-- For every parameter set and force: no rule that reads only the guards' response can
give, for every state, the velocity. The guards respond the same to a motion and to its
reverse. -/
theorem guard_response_cannot_tell_direction (p : Parameters) (F : ℝ) :
    ¬ ∃ reader : ℝ × ℝ × ℝ → ℝ, ∀ s : State, reader (guardResponse p F s) = s.v :=
  no_exact_reader_of_any_property (guardResponse p F) (fun s : State => s.v)
    unitMotion (reverseMotion unitMotion)
    (guard_response_same_after_reversal p F unitMotion)
    (by
      show (1 : ℝ) ≠ -1
      norm_num)

/-- Even the Boolean question "is the velocity positive?" cannot always be answered
from the guard response alone. This states the direction obstruction explicitly. -/
theorem guard_response_cannot_tell_positive_motion (p : Parameters) (F : ℝ) :
    ¬ ∃ reader : ℝ × ℝ × ℝ → Bool,
      ∀ s : State, reader (guardResponse p F s) = decide (0 < s.v) := by
  apply no_exact_reader_of_any_property (guardResponse p F)
    (fun s : State => decide (0 < s.v)) unitMotion (reverseMotion unitMotion)
    (guard_response_same_after_reversal p F unitMotion)
  norm_num [unitMotion, reverseMotion]

end ActiveHug.GuardTwoEffects

#print axioms ActiveHug.GuardTwoEffects.one_opening_two_effects
#print axioms ActiveHug.GuardTwoEffects.reversal_keeps_guard_update_AB
#print axioms ActiveHug.GuardTwoEffects.reversal_keeps_guard_update_BA
#print axioms ActiveHug.GuardTwoEffects.reversal_keeps_guard_loss
#print axioms ActiveHug.GuardTwoEffects.guard_response_same_after_reversal
#print axioms ActiveHug.GuardTwoEffects.guard_response_cannot_tell_direction
#print axioms ActiveHug.GuardTwoEffects.admittedToB_is_size
#print axioms ActiveHug.GuardTwoEffects.guard_loss_nonnegative
#print axioms ActiveHug.GuardTwoEffects.guard_response_cannot_tell_positive_motion
