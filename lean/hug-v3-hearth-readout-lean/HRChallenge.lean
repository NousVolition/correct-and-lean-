import HRDefinitions

namespace HugV3.Source.HearthReadout
noncomputable section
open CW
open scoped BigOperators

theorem native_heat_form (s : State) (v : Vector) :
    heat (atVelocity s v)=thermalForm s v v := by sorry

theorem accepted_work_and_heat_ledgers (G : Geometry) (s d : State) (t : ℝ) (h : rhs G t s=some d) :
    d.ledger 1=CW.inner (velocity s) (forcing s) ∧
    d.ledger 3=heat s-(∑ x, extraction G s x)/4096+(∑ x, releaseGrid G s x)/4096 := by sorry

theorem ordered_heat_derivative (s : State) :
    HasDerivAt (fun e : ℝ => heat (atVelocity s (mix 1 e (velocity s) (ordered s)))) (heatReading s) 0 := by sorry

theorem ordered_kinetic_derivative (s : State) :
    HasDerivAt (fun e : ℝ => kinetic (mix 1 e (velocity s) (ordered s))) (workReading s) 0 := by sorry

theorem changing_order (s : State) :
    2*thermalForm s (velocity s) (-ordered s)= -heatReading s ∧
    CW.inner (velocity s) (-ordered s)= -workReading s ∧
    heat (atVelocity s (-ordered s))=bracketHeat s := by sorry

theorem signed_heat_bound (s : State) : (heatReading s)^2≤4*heat s*bracketHeat s := by sorry

theorem zero_heat_has_zero_signed_response (s : State) (h : heat s=0) : heatReading s=0 := by sorry

theorem work_is_heat_response_along_courier (s : State) (hu : retained (velocity s))
    (hc : retained (courier (velocity s))) (hw : retained (weaver s (velocity s))) :
    workReading s=2*thermalForm s (velocity s) (courier (velocity s)) := by sorry

theorem velocity_reversal (s : State) :
    ordered (reversed s)=ordered s ∧ heatReading (reversed s)= -heatReading s ∧
    workReading (reversed s)= -workReading s ∧ heat (reversed s)=heat s := by sorry

theorem nonzero_signed_reading_excludes_shared_multiplier (s : State) (h : heatReading s≠0) :
    ¬ ∃ k : ℝ, heatReading s=k*heat s ∧ heatReading (reversed s)=k*heat (reversed s) := by sorry

theorem encounter_multiplier_criterion {T : Type} (H L : T → ℝ) (a : T) (ha : H a≠0) :
    (∃ k : ℝ, ∀ t, L t=k*H t) ↔ ∀ t, L t*H a=L a*H t := by sorry

end
end HugV3.Source.HearthReadout
