import V3CoexistenceDefinitions

namespace HugV3.Source.CoexistenceVerified
noncomputable section
open Coexistence Set
open scoped BigOperators
set_option maxRecDepth 4096

private theorem rhs_recovers (G : Geometry) (t : ℝ) (s d : State)
    (h : rhs G t s=some d) :
    ∃ records, readRecords s=some records ∧ d=rhsFromRecords G t s records := by
  classical
  unfold rhs at h
  obtain ⟨records,hr,hd⟩ := Option.bind_eq_some_iff.mp h
  split at hd
  · exact ⟨records,hr,(Option.some.inj hd).symm⟩
  · cases hd

theorem accepted_full_norm_rate (G : Geometry) (t : ℝ) (s rate : State)
    (h : rhs G t s=some rate) (i : Actor) (k : Fin 2) :
    rate.normCenter i k=Transfer.normRate s i k := by
  obtain ⟨rs,_,heq⟩ := rhs_recovers G t s rate h
  rw [heq]
  rfl

theorem same_instant_norm_rate_with_any_association (s : State)
    (a : Actor → Actor → Fin 3 → ℝ) (i : Actor) (k : Fin 2) :
    Transfer.normRate {s with association := a} i k=Transfer.normRate s i k := by rfl

private theorem alignment_continuous (tr : Trace) (hsol : Solves tr)
    (q : ℕ) (hq : q<5) (baseline : State) (v : Actor → Fin 2 → ℝ) (i : Actor) :
    ContinuousOn (fun t => normAlignment (tr.path q t).state baseline v i)
      (Icc (time q) (time (q+1))) := by
  rcases (hsol.2 q hq).2.1 with ⟨_,_,_,_,_,_,_,_,_,_,hn,_,_,_,_⟩
  have hc (k : Fin 2) : ContinuousOn (fun t => (tr.path q t).state.normCenter i k)
      (Icc (time q) (time (q+1))) := hn i k
  have hp (k : Fin 2) : ContinuousOn
      (fun t => v i k*((tr.path q t).state.normCenter i k-baseline.normCenter i k))
      (Icc (time q) (time (q+1))) :=
    continuousOn_const.mul ((hc k).sub continuousOn_const)
  exact continuousOn_finset_sum Finset.univ (fun k _ => hp k)

theorem full_trace_alignment_derivative (tr : Trace) (hsol : Solves tr)
    (q : ℕ) (hq : q<5) (baseline : State) (v : Actor → Fin 2 → ℝ)
    (i : Actor) (t : ℝ) (ht : t ∈ Icc (time q) (time (q+1))) :
    HasDerivWithinAt (fun x => normAlignment (tr.path q x).state baseline v i)
      (normAlignmentRate (tr.path q t).state v i) (Icc (time q) (time (q+1))) t := by
  obtain ⟨rate,hr,hder⟩ := (hsol.2 q hq).2.2.2.1 t ht
  rcases hder with ⟨_,_,_,_,_,_,_,_,_,_,hn,_,_,_,_⟩
  have hc (k : Fin 2) := hn i k
  have hd (k : Fin 2) :
      HasDerivWithinAt (fun x => (tr.path q x).state.normCenter i k)
        (Transfer.normRate (tr.path q t).state i k) (Icc (time q) (time (q+1))) t := by
    simpa only [accepted_full_norm_rate sourceGeometry t (tr.path q t).state rate hr i k] using hc k
  have hsum := HasDerivWithinAt.sum (u := Finset.univ)
    (fun k _ => ((hd k).sub_const (baseline.normCenter i k)).const_mul (v i k))
  exact hsum

theorem full_segment_alignment_floor (tr : Trace) (hsol : Solves tr)
    (q : ℕ) (hq : q<5) (baseline : State) (v : Actor → Fin 2 → ℝ)
    (floor : Actor → ℝ) (hflow : NormInward tr q baseline v floor)
    (hstart : ∀ i, floor i≤normAlignment (tr.after q).state baseline v i) :
    ∀ t ∈ Icc (time q) (time (q+1)), ∀ i,
      floor i≤normAlignment (tr.path q t).state baseline v i := by
  intro t ht i
  have hc := alignment_continuous tr hsol q hq baseline v i
  have hd : ∀ x ∈ Ico (time q) (time (q+1)),
      HasDerivWithinAt (fun y => normAlignment (tr.path q y).state baseline v i)
        (normAlignmentRate (tr.path q x).state v i) (Ici x) x := by
    intro x hx
    have h := full_trace_alignment_derivative tr hsol q hq baseline v i x ⟨hx.1,hx.2.le⟩
    exact (h.mono (Icc_subset_Icc hx.1 le_rfl)).mono_of_mem_nhdsWithin (Icc_mem_nhdsGE hx.2)
  have hs : floor i≤normAlignment (tr.path q (time q)).state baseline v i := by
    simpa only [(hsol.2 q hq).1] using hstart i
  have bound := image_le_of_deriv_right_lt_deriv_boundary hc.neg
    (fun x hx => (hd x hx).neg) (B := fun _ => -floor i)
    (by linarith : -normAlignment (tr.path q (time q)).state baseline v i≤-floor i)
    (fun x => hasDerivAt_const x (-floor i))
    (by
      intro x hx heq
      change -normAlignment (tr.path q x).state baseline v i=-floor i at heq
      have he : normAlignment (tr.path q x).state baseline v i=floor i := by linarith
      have hp := hflow x hx i he
      linarith)
  have hb := bound ht
  change -normAlignment (tr.path q t).state baseline v i≤-floor i at hb
  linarith

theorem full_segment_association_floor (tr : Trace) (hsol : Solves tr)
    (q : ℕ) (hq : q<5) (rho : ℝ) (hflow : AssociationInward tr q rho)
    (hstart : rho≤(tr.after q).state.association 1 0 0) :
    ∀ t ∈ Icc (time q) (time (q+1)), rho≤(tr.path q t).state.association 1 0 0 := by
  have part := hsol.2 q hq
  have hc : ContinuousOn (fun t => (tr.path q t).state.association 1 0 0)
      (Icc (time q) (time (q+1))) := by
    rcases part.2.1 with ⟨_,_,_,_,_,_,_,_,_,_,_,_,_,_,ha⟩
    exact ha 1 0 0
  have hex (t : ℝ) (ht : t ∈ Ico (time q) (time (q+1))) :
      ∃ r : ℝ, HasDerivWithinAt (fun x => (tr.path q x).state.association 1 0 0) r (Ici t) t ∧
        ((tr.path q t).state.association 1 0 0=rho → 0<r) := by
    obtain ⟨rate,hr,hder⟩ := part.2.2.2.1 t ⟨ht.1,ht.2.le⟩
    obtain ⟨rs,hrs,_⟩ := rhs_recovers sourceGeometry t (tr.path q t).state rate hr
    rcases hder with ⟨_,_,_,_,_,_,_,_,_,_,_,_,_,_,ha⟩
    refine ⟨rate.association 1 0 0,?_,?_⟩
    · exact ((ha 1 0 0).mono (Icc_subset_Icc ht.1 le_rfl)).mono_of_mem_nhdsWithin (Icc_mem_nhdsGE ht.2)
    · intro he
      rw [ORuminationVerified.full_rhs_association_equation sourceGeometry t
        (tr.path q t).state rate rs hrs hr 1 0 0,he]
      exact mul_pos (by norm_num) (sub_pos.mpr (hflow t ht rs hrs he))
  classical
  let r : ℝ → ℝ := fun t => if ht : t ∈ Ico (time q) (time (q+1)) then
    (hex t ht).choose else 0
  have hd (t : ℝ) (ht : t ∈ Ico (time q) (time (q+1))) :
      HasDerivWithinAt (fun x => (tr.path q x).state.association 1 0 0) (r t) (Ici t) t := by
    simpa only [r,dif_pos ht] using (hex t ht).choose_spec.1
  have hp (t : ℝ) (ht : t ∈ Ico (time q) (time (q+1)))
      (he : (tr.path q t).state.association 1 0 0=rho) : 0<r t := by
    simpa only [r,dif_pos ht] using (hex t ht).choose_spec.2 he
  have hs : rho≤(tr.path q (time q)).state.association 1 0 0 := by
    simpa only [part.1] using hstart
  have bound := image_le_of_deriv_right_lt_deriv_boundary hc.neg
    (fun t ht => (hd t ht).neg) (B := fun _ => -rho)
    (by linarith : -(tr.path q (time q)).state.association 1 0 0≤-rho)
    (fun t => hasDerivAt_const t (-rho))
    (by
      intro t ht heq
      change -(tr.path q t).state.association 1 0 0=-rho at heq
      have he : (tr.path q t).state.association 1 0 0=rho := by linarith
      linarith [hp t ht he])
  intro t ht
  have hb := bound ht
  change -(tr.path q t).state.association 1 0 0≤-rho at hb
  linarith

theorem full_segment_coexistence (tr : Trace) (hsol : Solves tr)
    (q : ℕ) (hq : q<5) (baseline : State) (v : Actor → Fin 2 → ℝ)
    (floor : Actor → ℝ) (rho : ℝ)
    (hn : NormInward tr q baseline v floor) (ha : AssociationInward tr q rho)
    (hs : Coexists (tr.after q).state baseline v floor rho) :
    ∀ t ∈ Icc (time q) (time (q+1)),
      Coexists (tr.path q t).state baseline v floor rho := by
  intro t ht
  refine ⟨fun i => ⟨(hs.1 i).1,?_⟩,hs.2.1,?_,?_⟩
  · exact full_segment_alignment_floor tr hsol q hq baseline v floor hn
      (fun i => (hs.1 i).2) t ht i
  · exact full_segment_association_floor tr hsol q hq rho ha hs.2.2.1 t ht
  · rw [BridgeReturnVerified.full_trace_write_work_constant_between_writes tr hsol q hq t ht]
    exact hs.2.2.2

theorem write_preserves_coexistence (G : Geometry) (s w baseline : State)
    (r : Record) (v : Actor → Fin 2 → ℝ) (floor : Actor → ℝ) (rho : ℝ)
    (hw : writeEvent G s r=some w) (hs : Coexists s baseline v floor rho) :
    Coexists w baseline v floor rho := by
  have hss := BridgeReturnVerified.write_preserves_person_group_state G s w r hw
  have hn : w.normCenter=s.normCenter := congrArg BridgeReturn.SocialSnapshot.normCenter hss
  have ha : w.association=s.association := congrArg BridgeReturn.SocialSnapshot.association hss
  refine ⟨?_,hs.2.1,?_,?_⟩
  · intro i
    simpa only [normAlignment,hn] using hs.1 i
  · simpa only [ha] using hs.2.2.1
  · exact lt_of_lt_of_le hs.2.2.2 (BridgeReturnVerified.write_work_nondecreasing G s w r hw)

private theorem complete_preserves (id : Fin 3) (s w : FullState) (baseline : State)
    (v : Actor → Fin 2 → ℝ) (floor : Actor → ℝ) (rho : ℝ)
    (hw : completeEvent id s=some w) (hs : Coexists s.state baseline v floor rho) :
    Coexists w.state baseline v floor rho := by
  unfold completeEvent at hw
  obtain ⟨start,_,hw⟩ := Option.bind_eq_some_iff.mp hw
  obtain ⟨record,_,hw⟩ := Option.bind_eq_some_iff.mp hw
  obtain ⟨state,hwrite,hw⟩ := Option.bind_eq_some_iff.mp hw
  rw [← Option.some.inj hw]
  exact write_preserves_coexistence sourceGeometry s.state state baseline record v floor rho hwrite hs

theorem boundary_preserves_coexistence (q : ℕ) (s w : FullState) (baseline : State)
    (v : Actor → Fin 2 → ℝ) (floor : Actor → ℝ) (rho : ℝ)
    (hw : boundary q s=some w) (hs : Coexists s.state baseline v floor rho) :
    Coexists w.state baseline v floor rho := by
  match q with
  | 0 => rw [← Option.some.inj hw]; exact hs
  | 1 => rw [← Option.some.inj hw]; exact hs
  | 2 => exact complete_preserves 0 s w baseline v floor rho hw hs
  | 3 =>
    change (completeEvent 1 s).map (capture 2)=some w at hw
    obtain ⟨y,hy,heq⟩ := Option.map_eq_some_iff.mp hw
    rw [← heq]
    exact complete_preserves 1 s y baseline v floor rho hy hs
  | 4 => exact complete_preserves 2 s w baseline v floor rho hw hs
  | n+5 => rw [← Option.some.inj hw]; exact hs

theorem full_hybrid_conditional_coexistence (tr : Trace) (hsol : Solves tr)
    (start : ℕ) (hstart : start<5) (baseline : State) (v : Actor → Fin 2 → ℝ)
    (floor : Actor → ℝ) (rho : ℝ)
    (hn : ∀ q<5, start≤q → NormInward tr q baseline v floor)
    (ha : ∀ q<5, start≤q → AssociationInward tr q rho)
    (hs : Coexists (tr.after start).state baseline v floor rho) :
    (∀ q, start≤q → q≤5 → Coexists (tr.after q).state baseline v floor rho) ∧
    (∀ q, start≤q → q<5 → ∀ t ∈ Icc (time q) (time (q+1)),
      Coexists (tr.path q t).state baseline v floor rho) := by
  have checkpoints : ∀ q, start≤q → q≤5 → Coexists (tr.after q).state baseline v floor rho := by
    intro q
    induction q with
    | zero =>
      intro hle _
      have he : start=0 := by omega
      simpa only [he] using hs
    | succ q ih =>
      intro hle hq5
      by_cases he : start=q+1
      · simpa only [he] using hs
      · have hq : q<5 := by omega
        have hsq : start≤q := by omega
        have hprev := ih hsq (by omega)
        have hseg := full_segment_coexistence tr hsol q hq baseline v floor rho
          (hn q hq hsq) (ha q hq hsq) hprev
        have hab : time q≤time (q+1) := by interval_cases q <;> norm_num [time]
        exact boundary_preserves_coexistence (q+1) (tr.path q (time (q+1))) (tr.after (q+1))
          baseline v floor rho (hsol.2 q hq).2.2.2.2
          (hseg (time (q+1)) (right_mem_Icc.mpr hab))
  refine ⟨checkpoints,?_⟩
  intro q hsq hq
  exact full_segment_coexistence tr hsol q hq baseline v floor rho
    (hn q hq hsq) (ha q hq hsq) (checkpoints q hsq (by omega))

theorem erosion_witness_has_coexisting_markers (G : Geometry) :
    Coexists (erosionWitness G) (initial G) (fun _ _ => 1) (fun _ => 1/2) (1/2) := by
  refine ⟨?_,by norm_num,by norm_num [erosionWitness],by norm_num [erosionWitness]⟩
  intro i
  fin_cases i <;> norm_num [normAlignment,erosionWitness,initial,intent,Fin.sum_univ_two]

theorem active_association_allows_alignment_erosion (G : Geometry) (t : ℝ)
    (rs : List (Fin 4 × Record)) :
    (erosionWitness G).association 1 0 0=1 ∧
    normAlignmentRate (erosionWitness G) (fun _ _ => 1) 1=-(7/5:ℝ) ∧
    (rhsFromRecords G t (erosionWitness G) rs).normCenter 1 0=-(7/10:ℝ) := by
  refine ⟨rfl,?_,?_⟩
  · norm_num [normAlignmentRate,Transfer.normRate,erosionWitness,initial,intent,Fin.sum_univ_succ]
  · change Transfer.normRate (erosionWitness G) 1 0=-(7/10:ℝ)
    norm_num [Transfer.normRate,erosionWitness,initial,intent,Fin.sum_univ_succ]

theorem delayed_full_norm_rate (G : Geometry) (t : ℝ) (present past rate : State)
    (h : Delay.rhsDelayed G t present past=some rate) (i : Actor) (k : Fin 2) :
    rate.normCenter i k=Transfer.normRate past i k := by
  unfold Delay.rhsDelayed at h
  obtain ⟨current,_,h⟩ := Option.bind_eq_some_iff.mp h
  obtain ⟨buffered,hb,h⟩ := Option.bind_eq_some_iff.mp h
  rw [← Option.some.inj h]
  exact accepted_full_norm_rate G t (Delay.socialFrom present past) buffered hb i k

end
end HugV3.Source.CoexistenceVerified
