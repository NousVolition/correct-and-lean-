import Mathlib.Data.Fin.VecNotation
import Mathlib.Tactic

/-!
Pressure in the Hug v3 solver: it cannot see a push that has no divergence.

Transcribed from `continuum.py` (method `project`) in the Tick 41 packages. For each
Fourier mode with wave vector `k` and rate coefficient `h` after spectral masking:

    kd  = sum(k * h)
    den = where(k2 == 0, 1, k2)
    ph  = -1j * kd / den          # the pressure coefficient
    h  -= k * (kd / den)          # the projected rate

and from `breathing.py`, where the breathing push is added after this projection with
the comment "the native pressure increment is zero", after the constructor has checked
that projecting the breathing pattern returns the pattern itself.

What is shown, for one Fourier mode over any field (the real solver uses complex numbers):

1. Adding a push with `k · b = 0` leaves the pressure coefficient unchanged.
2. Such a push passes through the projection untouched, so adding it before or after
   projecting gives the same rate. This is the code comment, proved.
3. The projected rate has `k · rate = 0` when `k · k` is nonzero, or when `k = 0`.
   Over an arbitrary field, `k ≠ 0` alone does not imply `k · k ≠ 0`.
4. Therefore no rule that reads only the pressure can recover a divergence-free push:
   pressure cannot tell whether breathing is on (an instance of the ambiguous-observation
   rule).

What is NOT shown: that the breathing pattern used in the runs is exactly divergence-free
(the code checks this numerically, to 2e-13), anything about the full pressure field over
time, or anything about the earlier prototype's supplied "pressure" input or the clay
calculation's shear stress, which are different quantities under the same word.
At `k = 0` the code divides by 1 and Lean's division by zero gives 0; both give a zero
pressure coefficient and unchanged projected rate there. The transcription from
Python, spectral masking, and the Fourier transforms are outside the kernel.
See the accompanying verification receipt for the checked source and results.
-/
set_option autoImplicit false

namespace PressureBlindToBreathing

variable {K : Type} [Field K]

/-- `k · h` for one mode. -/
def dot (k h : Fin 3 → K) : K := k 0 * h 0 + k 1 * h 1 + k 2 * h 2

/-- The pressure coefficient of a mode; `c` stands for the constant factor `-i`. -/
def pressureMode (c : K) (k h : Fin 3 → K) : K := c * (dot k h / dot k k)

/-- The projected rate of a mode. -/
def projectMode (k h : Fin 3 → K) : Fin 3 → K := fun i => h i - k i * (dot k h / dot k k)

theorem dot_add (k h b : Fin 3 → K) : dot k (h + b) = dot k h + dot k b := by
  simp only [dot, Pi.add_apply]
  ring

/-! ### 1. Pressure does not respond to a divergence-free push -/

theorem pressure_ignores_divergence_free_push (c : K) (k h b : Fin 3 → K)
    (free : dot k b = 0) : pressureMode c k (h + b) = pressureMode c k h := by
  unfold pressureMode
  rw [dot_add, free, add_zero]

/-! ### 2. The push passes through the projection -/

theorem projection_passes_divergence_free_push (k h b : Fin 3 → K) (free : dot k b = 0) :
    projectMode k (h + b) = projectMode k h + b := by
  funext i
  simp only [projectMode, Pi.add_apply]
  rw [dot_add, free, add_zero]
  ring

/-- The constructor's check: projecting a divergence-free pattern returns it unchanged. -/
theorem projection_fixes_divergence_free_push (k b : Fin 3 → K) (free : dot k b = 0) :
    projectMode k b = b := by
  funext i
  simp only [projectMode]
  rw [free, zero_div, mul_zero, sub_zero]

/-! ### 3. What comes out of the projection has no divergence -/

theorem projected_rate_is_divergence_free (k h : Fin 3 → K) (nonzero : dot k k ≠ 0) :
    dot k (projectMode k h) = 0 := by
  have expand : dot k (projectMode k h) = dot k h - dot k k * (dot k h / dot k k) := by
    simp only [dot, projectMode]
    ring
  have cancel : dot k k * (dot k h / dot k k) = dot k h := by
    field_simp
  rw [expand, cancel, sub_self]

/-- The solver's special zero mode has zero pressure. -/
theorem zero_mode_pressure (c : K) (h : Fin 3 → K) :
    pressureMode c 0 h = 0 := by
  simp [pressureMode, dot]

/-- At the zero wave vector, the projected rate is unchanged. -/
theorem zero_mode_projection (h : Fin 3 → K) : projectMode 0 h = h := by
  funext i
  simp [projectMode]

/-- Both admissible cases: the zero mode, or a nonzero squared wave-vector sum. -/
theorem projected_rate_is_divergence_free_including_zero (k h : Fin 3 → K)
    (admissible : k = 0 ∨ dot k k ≠ 0) : dot k (projectMode k h) = 0 := by
  rcases admissible with zero | nonzero
  · subst k
    simp [dot]
  · exact projected_rate_is_divergence_free k h nonzero

/-! ### 4. As an instance of the ambiguous-observation rule -/

/-- The rule, for a property of any type. Same proof as
`SIMSLatentReadout.no_exact_reader_of_ambiguous_observation`. -/
theorem no_exact_reader_of_any_property {S O P : Type}
    (observe : S → O) (property : S → P) (a b : S)
    (same : observe a = observe b) (different : property a ≠ property b) :
    ¬ ∃ reader : O → P, ∀ s, reader (observe s) = property s :=
  fun ⟨reader, correct⟩ =>
    different ((correct a).symm.trans ((congrArg reader same).trans (correct b)))

theorem dot_zero (k : Fin 3 → K) : dot k (0 : Fin 3 → K) = 0 := by
  simp [dot]

/-- For any mode, any underlying rate `h` and any nonzero divergence-free push `b`: no rule
that reads only the pressure coefficient can give, for every divergence-free push, what
that push is. In particular it cannot tell "no push" from `b`. -/
theorem pressure_cannot_tell_whether_breathing_is_on (c : K) (k h b : Fin 3 → K)
    (free : dot k b = 0) (present : b ≠ 0) :
    ¬ ∃ reader : K → (Fin 3 → K),
      ∀ push : {f : Fin 3 → K // dot k f = 0},
        reader (pressureMode c k (h + push.1)) = push.1 :=
  no_exact_reader_of_any_property
    (fun push : {f : Fin 3 → K // dot k f = 0} => pressureMode c k (h + push.1))
    (fun push => push.1)
    ⟨0, dot_zero k⟩ ⟨b, free⟩
    (by
      show pressureMode c k (h + (0 : Fin 3 → K)) = pressureMode c k (h + b)
      rw [pressure_ignores_divergence_free_push c k h 0 (dot_zero k),
        pressure_ignores_divergence_free_push c k h b free])
    (by
      show (0 : Fin 3 → K) ≠ b
      exact fun equal => present equal.symm)

/-- Such a push exists: for the wave vector (1, 0, 0), the push (0, 1, 0) is
divergence-free and not zero. -/
theorem a_divergence_free_push_exists :
    dot (![1, 0, 0] : Fin 3 → ℚ) ![0, 1, 0] = 0 ∧ (![0, 1, 0] : Fin 3 → ℚ) ≠ 0 := by
  constructor
  · simp [dot]
  · intro equal
    have second := congrFun equal 1
    simp at second

/-- Even a Boolean on/off switch cannot be recovered from this one-mode pressure
observation when switching adds a divergence-free push. -/
theorem pressure_cannot_read_breathing_switch (c : K) (k h b : Fin 3 → K)
    (free : dot k b = 0) :
    ¬ ∃ reader : K → Bool, ∀ enabled : Bool,
      reader (pressureMode c k (h + (if enabled then b else 0))) = enabled := by
  apply no_exact_reader_of_any_property
    (fun enabled : Bool => pressureMode c k (h + (if enabled then b else 0)))
    (fun enabled : Bool => enabled) false true
  · change pressureMode c k (h + (0 : Fin 3 → K)) = pressureMode c k (h + b)
    rw [pressure_ignores_divergence_free_push c k h 0 (dot_zero k),
      pressure_ignores_divergence_free_push c k h b free]
  · decide

end PressureBlindToBreathing

#print axioms PressureBlindToBreathing.pressure_ignores_divergence_free_push
#print axioms PressureBlindToBreathing.projection_passes_divergence_free_push
#print axioms PressureBlindToBreathing.projection_fixes_divergence_free_push
#print axioms PressureBlindToBreathing.projected_rate_is_divergence_free
#print axioms PressureBlindToBreathing.pressure_cannot_tell_whether_breathing_is_on
#print axioms PressureBlindToBreathing.a_divergence_free_push_exists
#print axioms PressureBlindToBreathing.zero_mode_pressure
#print axioms PressureBlindToBreathing.zero_mode_projection
#print axioms PressureBlindToBreathing.projected_rate_is_divergence_free_including_zero
#print axioms PressureBlindToBreathing.pressure_cannot_read_breathing_switch
