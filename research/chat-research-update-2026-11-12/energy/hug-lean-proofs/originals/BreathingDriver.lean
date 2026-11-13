import Mathlib

/-!
Breathing in the Hug v3 comparison: a driver set by the clock.

Transcribed from `breathing.py` (class `ComparisonSolver`) in the Tick 41 packages:

    def breath_at(self, time):
        return self.pattern * (self.peak * np.cos(2*np.pi*time/self.period))
    ...
    rates["g"][..., :3] += force
    power = np.mean(np.sum(u*force, axis=-1))

with the declared settings peak 0.5 and period 0.6.

What is shown, for this formula:

1. The breathing push depends on the time and the fixed settings only. Two different
   states at the same time receive exactly the same push, so no rule that reads only the
   push can recover anything that differs between states (an instance of the
   ambiguous-observation rule).
2. The push repeats every period and never exceeds the peak.
3. Model time 1.2 (tick 41) is exactly two periods, so the push is at its full peak there.
4. The work breathing does reverses sign when the flow reverses. Breathing can give
   energy or take it, depending on the flow it meets.

What is NOT shown: anything about the fluid's response, about whether breathing causes
the closest-point switches, or about the intended unforced system. This file describes
the added drive used in the breathing-on experiments. The transcription of the Python
formula into Lean is outside the kernel. Not compiled when written.
-/
set_option autoImplicit false
noncomputable section

namespace BreathingDriver

/-! ### The formula -/

/-- The time factor: `peak * cos(2π t / period)`. -/
def amplitude (peak period t : ℝ) : ℝ := peak * Real.cos (2 * Real.pi * t / period)

/-- The push applied at a place `x`, in a system that is in state `state`.
The state is an argument so that the theorems can say it is ignored. -/
def push {S X : Type} (pattern : X → ℝ) (peak period t : ℝ) (_state : S) (x : X) : ℝ :=
  amplitude peak period t * pattern x

/-- The mean rate of work done on a flow `u` by a push `f`, over `n` sample points. -/
def power {n : ℕ} (u f : Fin n → ℝ) : ℝ := (∑ i, u i * f i) / n

/-! ### 1. The push ignores the state -/

theorem push_ignores_state {S X : Type} (pattern : X → ℝ) (peak period t : ℝ) (s s' : S) :
    push pattern peak period t s = push pattern peak period t s' :=
  rfl

/-- The ambiguous-observation rule, for a property of any type. Same proof as
`SIMSLatentReadout.no_exact_reader_of_ambiguous_observation`. -/
theorem no_exact_reader_of_any_property {S O P : Type}
    (observe : S → O) (property : S → P) (a b : S)
    (same : observe a = observe b) (different : property a ≠ property b) :
    ¬ ∃ reader : O → P, ∀ s, reader (observe s) = property s :=
  fun ⟨reader, correct⟩ =>
    different ((correct a).symm.trans ((congrArg reader same).trans (correct b)))

/-- Breathing as an instance: at any time, no rule that reads only the breathing push can
give a property that differs between two states. The push is not a reading of the state. -/
theorem push_cannot_report_state {S X P : Type} (pattern : X → ℝ) (peak period t : ℝ)
    (property : S → P) (a b : S) (different : property a ≠ property b) :
    ¬ ∃ reader : (X → ℝ) → P, ∀ s : S, reader (push pattern peak period t s) = property s :=
  no_exact_reader_of_any_property (push pattern peak period t) property a b
    (push_ignores_state pattern peak period t a b) different

/-! ### 2. It repeats, and it is bounded -/

theorem amplitude_repeats (peak period t : ℝ) (nonzero : period ≠ 0) :
    amplitude peak period (t + period) = amplitude peak period t := by
  have angle : 2 * Real.pi * (t + period) / period = 2 * Real.pi * t / period + 2 * Real.pi := by
    rw [mul_add, add_div, mul_div_assoc (2 * Real.pi) period period, div_self nonzero, mul_one]
  unfold amplitude
  rw [angle, Real.cos_add_two_pi]

theorem amplitude_bounded (peak period t : ℝ) : |amplitude peak period t| ≤ |peak| := by
  unfold amplitude
  calc |peak * Real.cos (2 * Real.pi * t / period)|
      = |peak| * |Real.cos (2 * Real.pi * t / period)| := abs_mul _ _
    _ ≤ |peak| * 1 := mul_le_mul_of_nonneg_left (Real.abs_cos_le_one _) (abs_nonneg _)
    _ = |peak| := mul_one _

/-! ### 3. Tick 41 falls on a full peak -/

/-- With peak 0.5 and period 0.6, model time 1.2 is two whole periods: the push is at its
full positive peak, the same as at time 0. -/
theorem full_peak_at_tick_41 : amplitude (1 / 2) (3 / 5) (6 / 5) = 1 / 2 := by
  have angle : 2 * Real.pi * (6 / 5) / (3 / 5) = ((2 : ℕ) : ℝ) * (2 * Real.pi) := by
    push_cast
    ring
  unfold amplitude
  rw [angle, Real.cos_nat_mul_two_pi, mul_one]

theorem full_peak_at_start : amplitude (1 / 2) (3 / 5) 0 = 1 / 2 := by
  unfold amplitude
  rw [mul_zero, zero_div, Real.cos_zero, mul_one]

/-! ### 4. Its work reverses with the flow -/

/-- Reversing the flow reverses the work breathing does on it. -/
theorem power_reverses_with_flow {n : ℕ} (u f : Fin n → ℝ) :
    power (fun i => -u i) f = -power u f := by
  unfold power
  simp [neg_mul, Finset.sum_neg_distrib, neg_div]

/-- So breathing is not a pure source or a pure sink: if it feeds one flow, it drains the
reversed flow by the same amount. -/
theorem feeds_one_flow_drains_its_reverse {n : ℕ} (u f : Fin n → ℝ) (feeds : 0 < power u f) :
    power (fun i => -u i) f < 0 := by
  rw [power_reverses_with_flow]
  exact neg_lt_zero.mpr feeds

end BreathingDriver

#print axioms BreathingDriver.push_ignores_state
#print axioms BreathingDriver.push_cannot_report_state
#print axioms BreathingDriver.amplitude_repeats
#print axioms BreathingDriver.amplitude_bounded
#print axioms BreathingDriver.full_peak_at_tick_41
#print axioms BreathingDriver.full_peak_at_start
#print axioms BreathingDriver.power_reverses_with_flow
#print axioms BreathingDriver.feeds_one_flow_drains_its_reverse
