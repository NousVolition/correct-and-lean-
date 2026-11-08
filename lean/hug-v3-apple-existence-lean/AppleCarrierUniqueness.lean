import AppleExistenceDefinitions
import AppleRealFlow

namespace HugV3.Source.AppleExistence
noncomputable section
open Set Metric
open scoped NNReal
open AppleBand

private theorem native_mechanical_eval (s : State) (z : Vec) :
    gridVelocity (velocity s) z=materialVelocity s z := rfl

theorem material_carrier_unique_on_trace (tr : Trace) (h : Solves tr) (R : ℝ≥0) (φ ψ : Vec × ℝ → Vec)
    (f : MaterialFlowAcross tr R φ) (g : MaterialFlowAcross tr R ψ) :
    CarrierAgreement R φ ψ := by
  obtain ⟨_,K,hK⟩ := continuous_grid_history_has_global_space_bounds
    (a:=time 0) (b:=time 5) (joinedVelocity tr 4) (joined_continuous tr h 4 (by decide)).continuousOn
  rintro ⟨z,t⟩ ⟨hz,ht⟩
  have from_left (k : ℕ) (hk : k<5) (start : φ (z,time k)=ψ (z,time k)) :
      EqOn (fun t => φ (z,t)) (fun t => ψ (z,t)) (Icc (time k) (time (k+1))) := by
    let v := fun t => gridVelocity (joinedVelocity tr 4 t)
    have deriv (θ : Vec × ℝ → Vec) (flow : MaterialFlowAcross tr R θ) (t : ℝ)
        (ht : t∈Icc (time k) (time (k+1))) :
        HasDerivWithinAt (fun τ => θ (z,τ)) (v t (θ (z,t))) (Icc (time k) (time (k+1))) t := by
      change HasDerivWithinAt _ (gridVelocity (joinedVelocity tr 4 t) (θ (z,t))) _ _
      rw [joined_equals_native tr h k hk t ht,native_mechanical_eval]
      exact flow.2.2.1 k hk z hz t ht
    apply ODE_solution_unique_of_mem_Icc_right (s:=fun _ => (univ : Set Vec))
      (fun t ht => ((hK t ⟨(time_monotone (Nat.zero_le _)).trans ht.1,
        ht.2.le.trans (time_monotone (show k+1≤5 by omega))⟩).2).lipschitzOnWith)
      (HasDerivWithinAt.continuousOn (deriv φ f)) _ (fun _ _ => mem_univ _)
      (HasDerivWithinAt.continuousOn (deriv ψ g)) _ (fun _ _ => mem_univ _) start
    · intro t ht
      exact (deriv φ f t (Ico_subset_Icc_self ht)).mono_of_mem_nhdsWithin (Icc_mem_nhdsGE_of_mem ht)
    · intro t ht
      exact (deriv ψ g t (Ico_subset_Icc_self ht)).mono_of_mem_nhdsWithin (Icc_mem_nhdsGE_of_mem ht)
  have seg : ∀ k<5, EqOn (fun t => φ (z,t)) (fun t => ψ (z,t)) (Icc (time k) (time (k+1))) := by
    intro k
    induction k with
    | zero => exact fun hk => from_left 0 hk ((f.2.1 z hz).trans (g.2.1 z hz).symm)
    | succ k ih =>
      intro hk
      exact from_left (k+1) hk (ih (by omega) (right_mem_Icc.mpr (time_monotone (Nat.le_succ k))))
  have cover : ∃ k<5, t∈Icc (time k) (time (k+1)) := by
    by_cases h1 : t≤time 1
    · exact ⟨0,by decide,ht.1,h1⟩
    by_cases h2 : t≤time 2
    · exact ⟨1,by decide,(le_of_not_ge h1),h2⟩
    by_cases h3 : t≤time 3
    · exact ⟨2,by decide,(le_of_not_ge h2),h3⟩
    by_cases h4 : t≤time 4
    · exact ⟨3,by decide,(le_of_not_ge h3),h4⟩
    exact ⟨4,by decide,(le_of_not_ge h4),ht.2⟩
  obtain ⟨k,hk,htk⟩ := cover
  exact seg k hk htk

theorem full_apple_iff_source (R : ℝ≥0) (hR : 1≤R) : FullApple R ↔ FullExistenceUniqueness := by
  constructor
  · rintro ⟨tr,solves,unique,_⟩
    exact ⟨tr,solves,unique⟩
  · rintro ⟨tr,solves,unique⟩
    obtain ⟨φ,flow,band⟩ := full_trace_material_flow_carries_band tr solves R hR
    exact ⟨tr,solves,unique,φ,flow,band,fun ψ g => material_carrier_unique_on_trace tr solves R φ ψ flow g⟩

end
end HugV3.Source.AppleExistence
