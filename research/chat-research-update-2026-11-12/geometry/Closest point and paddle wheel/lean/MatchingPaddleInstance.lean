import MatchingPaddleLines

set_option autoImplicit false

namespace ClosestPointExample.MatchingPaddle
noncomputable section

def FlowAllowed (b : Bool) : Prop :=
  (∀ i, ContDiff ℝ ⊤ (fun tx : ℝ × Point => flow b tx.1 tx.2 i)) ∧
  (∀ (t : ℝ) (p : Point) (n : Fin 3 → ℤ), flow b t (fun i => p i + n i) = flow b t p) ∧
  (∀ t p, (∑ i : Fin 3, coordinateDerivative i (fun q => flow b t q i) p) = 0) ∧
  (∀ t p i, deriv (fun v => flow b v p i) t +
    (∑ j : Fin 3, flow b t p j * coordinateDerivative j (fun q => flow b t q i) p) =
    viscosity * (∑ j : Fin 3,
      coordinateDerivative j (fun q => coordinateDerivative j (fun r => flow b t r i) q) p)
      - coordinateDerivative i (pressure t) p + force t p i)

theorem both_flows_allowed (b : Bool) : FlowAllowed b :=
  ⟨smooth_flow b, periodic_flow b, divergence_zero b, solves_navier_stokes b⟩

abbrev State := {b : Bool // FlowAllowed b}
abbrev Observation := ℝ × Reading × Point
def closedState : State := ⟨false, both_flows_allowed false⟩
def openState : State := ⟨true, both_flows_allowed true⟩
def observation (s : State) : Observation :=
  (tick41, observe 0, vorticity s.val tick41 markerA)
def property (s : State) : Bool := by
  classical
  exact decide (ClosedAtTick s.val)

theorem same_enlarged_observation : observation closedState = observation openState := by
  simp only [observation, closedState, openState]
  rw [same_paddle_wheel]

theorem opposite_closure : property closedState ≠ property openState := by
  simp [property, closedState, openState, closed_witness_returns, open_witness_never_returns]

theorem no_exact_reader_even_with_paddle_wheel :
    ¬ ∃ reader : Observation → Bool, ∀ s : State, reader (observation s) = property s := by
  exact SIMSLatentReadout.no_exact_reader_of_ambiguous_observation
    observation property closedState openState same_enlarged_observation opposite_closure

theorem every_function_of_paddle_matches {O : Type} (reading : Point → O) :
    reading (vorticity false tick41 markerA) = reading (vorticity true tick41 markerA) :=
  congrArg reading same_paddle_wheel

theorem zero_swirl_at_open_limit : vorticity true tick41 (line 0 (5 / 6)) = (fun _ => 0) := by
  funext i
  rw [curl_on_axis]
  have angle : transverseWave * (5 / 6 : ℝ) + phase = 2 * Real.pi := by
    unfold transverseWave phase
    ring
  simp [gain, angle, Real.cos_two_pi]

theorem zero_is_beyond_saved_trace : traceLength < (5 / 6 : ℝ) := by
  norm_num [traceLength]

#print axioms both_flows_allowed
#print axioms same_enlarged_observation
#print axioms opposite_closure
#print axioms no_exact_reader_even_with_paddle_wheel
#print axioms every_function_of_paddle_matches
#print axioms zero_swirl_at_open_limit
#print axioms zero_is_beyond_saved_trace

end
end ClosestPointExample.MatchingPaddle
