import V3CovarianceDefinitions

/-! Frozen reference statements only. The solution must not import this file. -/
namespace HugV3.Source.CovarianceVerified
noncomputable section
open Covariance Delay

theorem state_involution (ε : Particle → Bool) (s : State) :
    signState ε (signState ε s)=s := by sorry
theorem same_social_state (ε : Particle → Bool) (s : State) :
    SameSocial (signState ε s) s := by sorry
theorem material_stress_invariant (ε : Particle → Bool) (G : Geometry) (s : State) :
    materialStress G (signState ε s)=materialStress G s := by sorry
theorem fabric_stress_invariant (ε : Particle → Bool) (s : State) :
    fabricStress (signState ε s)=fabricStress s := by sorry
theorem extra_conductivity_invariant (ε : Particle → Bool) (G : Geometry) (s : State) :
    extraConductivity G (signState ε s)=extraConductivity G s := by sorry
theorem fiber_rate_invariant (ε : Particle → Bool) (G : Geometry) (s : State) :
    fiberRate G (signState ε s)=fiberRate G s := by sorry
theorem full_rhs_equivariant (ε : Particle → Bool) (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) :
    rhsFromRecords G t (signState ε s) rs=signState ε (rhsFromRecords G t s rs) := by sorry
theorem accepted_rhs_equivariant (ε : Particle → Bool) (G : Geometry) (t : ℝ) (s : State) :
    rhs G t (signState ε s)=(rhs G t s).map (signState ε) := by sorry
theorem event_record_invariant (ε : Particle → Bool) (s : State)
    (startF : Particle → Mat) (id : Fin 3) :
    makeEvent (signState ε s) (signedFabric ε startF) id=makeEvent s startF id := by sorry
theorem write_equivariant (ε : Particle → Bool) (G : Geometry) (s : State) (r : Record) :
    writeEvent G (signState ε s) r=(writeEvent G s r).map (signState ε) := by sorry
theorem capture_equivariant (ε : Particle → Bool) (id : Fin 3) (y : FullState) :
    capture id (signFull ε y)=signFull ε (capture id y) := by sorry
theorem complete_event_equivariant (ε : Particle → Bool) (id : Fin 3) (y : FullState) :
    completeEvent id (signFull ε y)=(completeEvent id y).map (signFull ε) := by sorry
theorem all_boundaries_equivariant (ε : Particle → Bool) (k : ℕ) (y : FullState) :
    boundary k (signFull ε y)=(boundary k y).map (signFull ε) := by sorry
theorem buffer_commutes (ε : Particle → Bool) (present past : State) :
    socialFrom (signState ε present) (signState ε past)=signState ε (socialFrom present past) := by sorry
theorem delayed_rhs_equivariant (ε : Particle → Bool) (G : Geometry) (t : ℝ)
    (present past : State) :
    rhsDelayed G t (signState ε present) (signState ε past)=
      (rhsDelayed G t present past).map (signState ε) := by sorry
theorem delayed_history_equivariant (ε : Particle → Bool) (G : Geometry) (τ t : ℝ)
    (history : ℝ → State) :
    rhsAlong G τ (fun r => signState ε (history r)) t=
      (rhsAlong G τ history t).map (signState ε) := by sorry
theorem derivative_covariant (ε : Particle → Bool) (s : ℝ → State) (d : State)
    (I : Set ℝ) (t : ℝ) (h : StateHasDerivWithinAt s d I t) :
    StateHasDerivWithinAt (fun r => signState ε (s r)) (signState ε d) I t := by sorry
theorem continuity_covariant (ε : Particle → Bool) (s : ℝ → State) (I : Set ℝ)
    (h : ContinuousStateOn s I) :
    ContinuousStateOn (fun r => signState ε (s r)) I := by sorry
theorem delayed_segment_covariant (ε : Particle → Bool) (G : Geometry) (τ : ℝ)
    (history : ℝ → State) (I : Set ℝ) (h : DelayedSegment G τ history I) :
    DelayedSegment G τ (fun t => signState ε (history t)) I := by sorry
theorem original_solution_predicate (tr : Trace) :
    SolvesFrom initialFull tr ↔ Solves tr := by sorry
theorem full_trace_covariant (ε : Particle → Bool) (y₀ : FullState) (tr : Trace)
    (h : SolvesFrom y₀ tr) :
    SolvesFrom (signFull ε y₀) (signTrace ε tr) := by sorry
theorem initial_reversal_is_not_fixed :
    signFull (fun _ => true) initialFull ≠ initialFull := by sorry
theorem forcing_has_fixed_direction (s : State) (x : Grid) :
    forcing s x 1=0 ∧ forcing s x 2=0 := by sorry
theorem gradient_witness_norm (G : Geometry) :
    sqnorm (centeredGradient (gradientWitness G) zeroGrid)=1 := by sorry
theorem witness_force_nonzero (G : Geometry) :
    forcing (gradientWitness G) zeroGrid 0<0 := by sorry
theorem quarter_turn_force_not_covariant (G : Geometry) :
    forcing (quarterState (gradientWitness G)) zeroGrid ≠
      quarterVector (forcing (gradientWitness G) (inverseQuarterGrid zeroGrid)) := by sorry

end
end HugV3.Source.CovarianceVerified
