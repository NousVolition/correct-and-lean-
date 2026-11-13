import PeriodicNavierStokes

set_option autoImplicit false

namespace ClosestPointExample.Tick41
noncomputable section

/-- A member of the explicitly defined family, with its smoothness, periodicity,
incompressibility and Navier–Stokes certificate. The same A and B are used. -/
abbrev State := {a : ℝ // Admissible a}
abbrev Observation := ℝ × Reading

def closedState : State := ⟨0, every_family_member_admissible 0⟩
def openState : State := ⟨Real.sqrt 2, every_family_member_admissible (Real.sqrt 2)⟩
def observation (s : State) : Observation := (tick41, observe s.val)
def property (s : State) : Bool := closedProperty s.val

theorem same_observation : observation closedState = observation openState := rfl

theorem certified_reading (s : State) : ValidReading s.val (observation s).2 :=
  observation_is_valid s.val

/-- These are actual curl integral curves at model time 1.2. -/
theorem actual_vortex_lines_at_tick41 (s : State) (r : ℝ) (i : Fin 3) :
    HasDerivAt (fun v => line s.val ((wave * decay tick41) * v) i)
      (curl s.val tick41 (line s.val ((wave * decay tick41) * r)) i) r :=
  vortex_line_ODE s.val tick41 r i

theorem opposite_properties : property closedState ≠ property openState := by
  change closedProperty 0 ≠ closedProperty (Real.sqrt 2)
  rw [opposite_closure_values.1, opposite_closure_values.2]
  decide

/-- A direct instance of the user's general theorem, on certified fluid states. -/
theorem no_exact_reader_of_closure :
    ¬ ∃ reader : Observation → Bool, ∀ s : State, reader (observation s) = property s := by
  exact SIMSLatentReadout.no_exact_reader_of_ambiguous_observation
    observation property closedState openState same_observation opposite_properties

#print axioms same_observation
#print axioms certified_reading
#print axioms actual_vortex_lines_at_tick41
#print axioms opposite_properties
#print axioms no_exact_reader_of_closure

end
end ClosestPointExample.Tick41
