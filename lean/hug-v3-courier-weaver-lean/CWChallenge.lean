import CWDefinitions

namespace HugV3.Source.CW
noncomputable section
open scoped BigOperators

theorem spectral_integration_by_parts (f g : Scalar) (j : Axis) :
    (∑ x, f x*grad g x j) = -(∑ x, g x*grad f x j) := by sorry

theorem raw_weaver_work_is_minus_heat (s : State) :
    inner (velocity s) (rawWeaver s (velocity s)) = -heat s := by sorry

theorem raw_courier_work_is_zero (u : Vector) (x : Grid) :
    dot (u x) (rawCourier u u x)=0 := by sorry

theorem accepted_velocity_decomposes (G : Geometry) (s d : State) (t : ℝ)
    (accepted : rhs G t s=some d) (x : Grid) (i : Axis) :
    velocity d x i = courier (velocity s) x i+weaver s (velocity s) x i+
      resolve (otherForces G s) x i := by sorry

theorem bracket_as_velocity_derivative (s : State) (u : Vector) (x : Grid) (i : Axis) :
    HasDerivAt (fun e : ℝ => courier (mix 1 e u (weaver s u)) x i -
      weaver s (mix 1 e u (courier u)) x i) (directionalBracket s u x i) 0 := by sorry

theorem reversed_native_roles (s : State) :
    courier (velocity (reversed s))=courier (velocity s) ∧
    weaver (reversed s) (velocity (reversed s))= -weaver s (velocity s) ∧
    (∀ x, viscousHeat (reversed s) x=viscousHeat s x) := by sorry

theorem pairing_reverses_and_heat_agrees (s : State) :
    pairing (reversed s)= -pairing s ∧ heat (reversed s)=heat s := by sorry

theorem no_common_coefficient_at_nonzero_pair (s : State) (nonzero : pairing s≠0) :
    ¬ ∃ k : ℝ, pairing s=k*heat s ∧ pairing (reversed s)=k*heat (reversed s) := by sorry

theorem dot_pair_is_symmetric (u v : Vector) : inner u v=inner v u := by sorry

theorem coefficient_at_single_state (s : State) (positive : 0<heat s) (k : ℝ) :
    pairing s=k*heat s ↔ k=pairing s/heat s := by sorry

theorem initial_state_does_not_identify_coefficient (G : Geometry) :
    pairing (initial G)=0 ∧ heat (initial G)=0 ∧
    ∀ k : ℝ, pairing (initial G)=k*heat (initial G) := by sorry

theorem same_accepted_rate_allows_any_wizard_entry (G : Geometry) (s d : State) (t k : ℝ)
    (accepted : rhs G t s=some d) :
    ∃ M : CommutatorMatrix, M.CentralHearth ∧
    M.κ Wizard.courier.toFin Wizard.weaver.toFin=k ∧
    M.κ Wizard.weaver.toFin Wizard.courier.toFin= -k ∧ rhs G t s=some d := by sorry

end
end HugV3.Source.CW
