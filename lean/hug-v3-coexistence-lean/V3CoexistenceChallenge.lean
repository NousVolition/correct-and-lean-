import V3CoexistenceDefinitions

namespace HugV3.Source.CoexistenceVerified
noncomputable section
open Coexistence Set

theorem accepted_full_norm_rate (G : Geometry) (t : ℝ) (s rate : State)
    (h : rhs G t s=some rate) (i : Actor) (k : Fin 2) :
    rate.normCenter i k=Transfer.normRate s i k := by sorry

theorem same_instant_norm_rate_with_any_association (s : State)
    (a : Actor → Actor → Fin 3 → ℝ) (i : Actor) (k : Fin 2) :
    Transfer.normRate {s with association := a} i k=Transfer.normRate s i k := by sorry

theorem full_trace_alignment_derivative (tr : Trace) (hsol : Solves tr)
    (q : ℕ) (hq : q<5) (baseline : State) (v : Actor → Fin 2 → ℝ)
    (i : Actor) (t : ℝ) (ht : t ∈ Icc (time q) (time (q+1))) :
    HasDerivWithinAt (fun x => normAlignment (tr.path q x).state baseline v i)
      (normAlignmentRate (tr.path q t).state v i) (Icc (time q) (time (q+1))) t := by sorry

theorem full_segment_alignment_floor (tr : Trace) (hsol : Solves tr)
    (q : ℕ) (hq : q<5) (baseline : State) (v : Actor → Fin 2 → ℝ)
    (floor : Actor → ℝ) (hflow : NormInward tr q baseline v floor)
    (hstart : ∀ i, floor i≤normAlignment (tr.after q).state baseline v i) :
    ∀ t ∈ Icc (time q) (time (q+1)), ∀ i,
      floor i≤normAlignment (tr.path q t).state baseline v i := by sorry

theorem full_segment_association_floor (tr : Trace) (hsol : Solves tr)
    (q : ℕ) (hq : q<5) (rho : ℝ) (hflow : AssociationInward tr q rho)
    (hstart : rho≤(tr.after q).state.association 1 0 0) :
    ∀ t ∈ Icc (time q) (time (q+1)), rho≤(tr.path q t).state.association 1 0 0 := by sorry

theorem full_segment_coexistence (tr : Trace) (hsol : Solves tr)
    (q : ℕ) (hq : q<5) (baseline : State) (v : Actor → Fin 2 → ℝ)
    (floor : Actor → ℝ) (rho : ℝ)
    (hn : NormInward tr q baseline v floor) (ha : AssociationInward tr q rho)
    (hs : Coexists (tr.after q).state baseline v floor rho) :
    ∀ t ∈ Icc (time q) (time (q+1)),
      Coexists (tr.path q t).state baseline v floor rho := by sorry

theorem write_preserves_coexistence (G : Geometry) (s w baseline : State)
    (r : Record) (v : Actor → Fin 2 → ℝ) (floor : Actor → ℝ) (rho : ℝ)
    (hw : writeEvent G s r=some w) (hs : Coexists s baseline v floor rho) :
    Coexists w baseline v floor rho := by sorry

theorem boundary_preserves_coexistence (q : ℕ) (s w : FullState) (baseline : State)
    (v : Actor → Fin 2 → ℝ) (floor : Actor → ℝ) (rho : ℝ)
    (hw : boundary q s=some w) (hs : Coexists s.state baseline v floor rho) :
    Coexists w.state baseline v floor rho := by sorry

theorem full_hybrid_conditional_coexistence (tr : Trace) (hsol : Solves tr)
    (start : ℕ) (hstart : start<5) (baseline : State) (v : Actor → Fin 2 → ℝ)
    (floor : Actor → ℝ) (rho : ℝ)
    (hn : ∀ q<5, start≤q → NormInward tr q baseline v floor)
    (ha : ∀ q<5, start≤q → AssociationInward tr q rho)
    (hs : Coexists (tr.after start).state baseline v floor rho) :
    (∀ q, start≤q → q≤5 → Coexists (tr.after q).state baseline v floor rho) ∧
    (∀ q, start≤q → q<5 → ∀ t ∈ Icc (time q) (time (q+1)),
      Coexists (tr.path q t).state baseline v floor rho) := by sorry

theorem erosion_witness_has_coexisting_markers (G : Geometry) :
    Coexists (erosionWitness G) (initial G) (fun _ _ => 1) (fun _ => 1/2) (1/2) := by sorry

theorem active_association_allows_alignment_erosion (G : Geometry) (t : ℝ)
    (rs : List (Fin 4 × Record)) :
    (erosionWitness G).association 1 0 0=1 ∧
    normAlignmentRate (erosionWitness G) (fun _ _ => 1) 1=-(7/5:ℝ) ∧
    (rhsFromRecords G t (erosionWitness G) rs).normCenter 1 0=-(7/10:ℝ) := by sorry

theorem delayed_full_norm_rate (G : Geometry) (t : ℝ) (present past rate : State)
    (h : Delay.rhsDelayed G t present past=some rate) (i : Actor) (k : Fin 2) :
    rate.normCenter i k=Transfer.normRate past i k := by sorry

end
end HugV3.Source.CoexistenceVerified
