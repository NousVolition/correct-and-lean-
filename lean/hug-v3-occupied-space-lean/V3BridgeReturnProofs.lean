import V3BridgeReturnDefinitions
import Mathlib.Analysis.Calculus.Deriv.MeanValue

namespace HugV3.Source.BridgeReturnVerified
noncomputable section
attribute [local instance] Classical.propDecidable
open BridgeReturn Set
open scoped BigOperators
set_option maxRecDepth 4096

private def written (G : Geometry) (s : State) (slot : Fin 4) (bytes : List ℕ) : State :=
  let account := writeAccount G s (targetFabric s slot bytes)
  let heatGrid := fun x => (∑ p, R s.X p x*G.V p*account.heat p)/dv
  {s with b := account.target
          g := fun x j => s.g x j+if j=4 then filt heatGrid x else 0
          writeWork := s.writeWork+account.work}

private theorem write_description (G : Geometry) (s w : State) (r : Record)
    (hw : writeEvent G s r=some w) :
    ∃ rs slot bytes, readRecords s=some rs ∧
      (List.ofFn (fun slot : Fin 4 => slot)).find?
        (fun slot => !(rs.any (fun r => r.1 == slot)))=some slot ∧
      w=written G s slot bytes ∧
      0≤(writeAccount G s (targetFabric s slot bytes)).work := by
  unfold writeEvent at hw
  obtain ⟨rs,hr,hw⟩ := Option.bind_eq_some_iff.mp hw
  split at hw
  · cases hw
  · obtain ⟨slot,hslot,hw⟩ := Option.bind_eq_some_iff.mp hw
    obtain ⟨bytes,_,hw⟩ := Option.bind_eq_some_iff.mp hw
    dsimp only at hw
    split at hw
    · cases hw
    · rename_i hgood
      refine ⟨rs,slot,bytes,hr,hslot,(Option.some.inj hw).symm,?_⟩
      exact le_of_not_gt (fun hn => hgood (Or.inr hn))

theorem write_preserves_person_group_state (G : Geometry) (s w : State) (r : Record)
    (hw : writeEvent G s r=some w) : socialSnapshot w=socialSnapshot s := by
  obtain ⟨_,slot,bytes,_,_,heq,_⟩ := write_description G s w r hw
  rw [heq]
  rfl

theorem write_preserves_source_accumulator (G : Geometry) (s w : State) (r : Record)
    (hw : writeEvent G s r=some w) : w.A=s.A := by
  obtain ⟨_,slot,bytes,_,_,heq,_⟩ := write_description G s w r hw
  rw [heq]
  rfl

theorem write_work_nondecreasing (G : Geometry) (s w : State) (r : Record)
    (hw : writeEvent G s r=some w) : s.writeWork≤w.writeWork := by
  obtain ⟨_,slot,bytes,_,_,heq,hwork⟩ := write_description G s w r hw
  rw [heq]
  change s.writeWork≤s.writeWork+(writeAccount G s (targetFabric s slot bytes)).work
  linarith

theorem write_preserves_destination {Ω : Type} (observe : SocialSnapshot → Ω)
    (O : Ω) (G : Geometry) (s w : State) (r : Record)
    (hw : writeEvent G s r=some w) (ho : AtO observe O s) : AtO observe O w := by
  unfold AtO at *
  rwa [write_preserves_person_group_state G s w r hw]

theorem same_destination_with_new_residue {Ω : Type} (observe : SocialSnapshot → Ω)
    (O : Ω) (G : Geometry) (s w : State) (r : Record)
    (hw : writeEvent G s r=some w) (ho : AtO observe O s)
    (hwork : s.writeWork<w.writeWork) : AtO observe O w ∧ w≠s := by
  refine ⟨write_preserves_destination observe O G s w r hw ho,?_⟩
  intro heq
  rw [heq] at hwork
  exact (lt_irrefl _ hwork)

private theorem other_slot_unchanged (G : Geometry) (s : State) (slot old : Fin 4)
    (bytes : List ℕ) (hne : old≠slot) :
    slotBytes (written G s slot bytes) old=slotBytes s old := by
  have hb : ∀ bit : Fin 37264,
      (written G s slot bytes).b (cellAt old bit)=s.b (cellAt old bit) := by
    intro bit
    have hdiv : (cellAt old bit).val/37264=old.val := by
      simp only [cellAt]
      omega
    have hno : (cellAt old bit).val/37264≠slot.val := by
      rw [hdiv]
      exact fun h => hne (Fin.ext h)
    simp only [written,writeAccount,targetFabric,if_neg hno]
  simp only [slotBytes,ClayVerified.probe_recovers_cell]
  congr 1
  funext byte
  apply Finset.sum_congr rfl
  intro bit _
  rw [hb]

theorem successful_write_retains_occupied_slot_bytes (G : Geometry) (s w : State)
    (r : Record) (rs : List (Fin 4 × Record)) (old : Fin 4) (stored : Record)
    (hr : readRecords s=some rs) (hm : (old,stored)∈rs)
    (hw : writeEvent G s r=some w) : slotBytes w old=slotBytes s old := by
  obtain ⟨rs',slot,bytes,hr',hslot,heq,_⟩ := write_description G s w r hw
  have hrs : rs'=rs := Option.some.inj (hr'.symm.trans hr)
  subst rs'
  have hfree := List.find?_some hslot
  have hne : old≠slot := by
    intro h
    subst old
    have ha : rs.any (fun pair => pair.1 == slot)=true := by
      exact List.any_eq_true.mpr ⟨(slot,stored),hm,by simp⟩
    simp [ha] at hfree
  rw [heq]
  exact other_slot_unchanged G s slot old bytes hne

theorem full_trace_retains_records_between_writes (tr : Trace) (hsol : Solves tr) :
    ∀ k<5, ∀ t ∈ Icc (time k) (time (k+1)),
      readRecords (tr.path k t).state=readRecords (tr.after k).state := by
  exact ClayVerified.decoded_records_fixed_along_full_hybrid tr hsol

theorem conditional_fabric_durability_through_full_trace (tr : Trace) (hsol : Solves tr)
    (hF : ∀ k<5, ∀ t ∈ Ico (time k) (time (k+1)), ∀ l : Cell,
      (∑ i, ((tr.path k t).state.F (point l) i (axis l))^2)≤(2:ℝ)) :
    (∀ k≤5, ClayBuffer (tr.after k).state) ∧
    ∀ k<5, ∀ t ∈ Icc (time k) (time (k+1)),
      ClayBuffer (tr.path k t).state := by
  exact ClayVerified.clay_buffer_through_full_hybrid tr hsol hF

private theorem rhs_write_work_zero (G : Geometry) (t : ℝ) (s rate : State)
    (hr : rhs G t s=some rate) : rate.writeWork=0 := by
  unfold rhs at hr
  obtain ⟨rs,_,hr⟩ := Option.bind_eq_some_iff.mp hr
  split at hr
  · rw [← Option.some.inj hr]
    rfl
  · cases hr

theorem full_trace_write_work_constant_between_writes (tr : Trace) (hsol : Solves tr) :
    ∀ k<5, ∀ t ∈ Icc (time k) (time (k+1)),
      (tr.path k t).state.writeWork=(tr.after k).state.writeWork := by
  intro k hk t ht
  have part := hsol.2 k hk
  have hc : ContinuousOn (fun t => (tr.path k t).state.writeWork)
      (Icc (time k) (time (k+1))) := part.2.1.2.2.2.2.2.2.2.1
  have hd : ∀ x ∈ Icc (time k) (time (k+1)),
      HasDerivWithinAt (fun t => (tr.path k t).state.writeWork) 0
        (Icc (time k) (time (k+1))) x := by
    intro x hx
    obtain ⟨rate,hr,hder⟩ := part.2.2.2.1 x hx
    have h := hder.2.2.2.2.2.2.2.1
    change HasDerivWithinAt (fun t => (tr.path k t).state.writeWork) rate.writeWork
      (Icc (time k) (time (k+1))) x at h
    rw [rhs_write_work_zero sourceGeometry x (tr.path k x).state rate hr] at h
    exact h
  have hm := monotoneOn_of_hasDerivWithinAt_nonneg
    (convex_Icc (time k) (time (k+1))) hc
    (fun x hx => (hd x (interior_subset hx)).mono interior_subset)
    (fun _ _ => le_refl (0:ℝ))
  have hmneg := monotoneOn_of_hasDerivWithinAt_nonneg
    (convex_Icc (time k) (time (k+1))) hc.neg
    (fun x hx => ((hd x (interior_subset hx)).mono interior_subset).neg)
    (fun _ _ => by norm_num)
  have ha := left_mem_Icc.mpr (ht.1.trans ht.2)
  have h₁ := hm ha ht ht.1
  have h₂ := hmneg ha ht ht.1
  have heq : (tr.path k t).state.writeWork=(tr.path k (time k)).state.writeWork := by
    change -(tr.path k (time k)).state.writeWork≤-(tr.path k t).state.writeWork at h₂
    exact le_antisymm (neg_le_neg_iff.mp h₂) h₁
  simpa only [part.1] using heq

private theorem complete_work_nondecreasing (id : Fin 3) (s w : FullState)
    (hw : completeEvent id s=some w) : s.state.writeWork≤w.state.writeWork := by
  unfold completeEvent at hw
  obtain ⟨start,_,hw⟩ := Option.bind_eq_some_iff.mp hw
  obtain ⟨record,_,hw⟩ := Option.bind_eq_some_iff.mp hw
  obtain ⟨state,hwrite,hw⟩ := Option.bind_eq_some_iff.mp hw
  rw [← Option.some.inj hw]
  exact write_work_nondecreasing sourceGeometry s.state state record hwrite

private theorem boundary_work_nondecreasing (k : ℕ) (s w : FullState)
    (hw : boundary k s=some w) : s.state.writeWork≤w.state.writeWork := by
  match k with
  | 0 => rw [← Option.some.inj hw]; exact le_rfl
  | 1 => rw [← Option.some.inj hw]; exact le_rfl
  | 2 => exact complete_work_nondecreasing 0 s w hw
  | 3 =>
    change (completeEvent 1 s).map (capture 2)=some w at hw
    obtain ⟨v,hv,heq⟩ := Option.map_eq_some_iff.mp hw
    rw [← heq]
    exact complete_work_nondecreasing 1 s v hv
  | 4 => exact complete_work_nondecreasing 2 s w hw
  | n+5 => rw [← Option.some.inj hw]

theorem full_trace_write_work_nondecreasing_at_checkpoints (tr : Trace) (hsol : Solves tr) :
    ∀ k<5, (tr.after k).state.writeWork≤(tr.after (k+1)).state.writeWork := by
  intro k hk
  have hab : time k≤time (k+1) := by interval_cases k <;> norm_num [time]
  have h := boundary_work_nondecreasing (k+1) (tr.path k (time (k+1)))
    (tr.after (k+1)) (hsol.2 k hk).2.2.2.2
  rwa [full_trace_write_work_constant_between_writes tr hsol k hk
    (time (k+1)) (right_mem_Icc.mpr hab)] at h

theorem positive_write_work_precludes_full_reset (tr : Trace) (hsol : Solves tr)
    (k : ℕ) (hk : k≤5) (hw : 0<(tr.after k).state.writeWork) :
    (tr.after k).state≠(tr.after 0).state := by
  intro heq
  rw [heq,hsol.1] at hw
  norm_num [initialFull,capture,initial] at hw

theorem record_relevance_positive_and_bounded (G : Geometry) (s : State) (r : Record)
    (ht : r.startTime<r.endTime) :
    0<recordWeight G s r ∧ recordWeight G s r≤r.endTime-r.startTime := by
  change 0<(r.endTime-r.startTime)*Real.exp
    (-MemoryRules.cueDistanceSquared G s r/(2*0.32^2)) ∧ _
  have hn : 0≤MemoryRules.cueDistanceSquared G s r := by
    change 0≤∑ k, (MemoryRules.cueDifference G s r k)^2
    exact Finset.sum_nonneg (fun k _ => sq_nonneg _)
  have he : Real.exp (-MemoryRules.cueDistanceSquared G s r/(2*0.32^2))≤1 :=
    Real.exp_le_one_iff.mpr (div_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr hn) (by norm_num))
  constructor
  · exact mul_pos (sub_pos.mpr ht) (Real.exp_pos _)
  · change (r.endTime-r.startTime)*Real.exp
      (-MemoryRules.cueDistanceSquared G s r/(2*0.32^2))≤r.endTime-r.startTime
    simpa using mul_le_mul_of_nonneg_left he (sub_nonneg.mpr ht.le)

theorem stable_record_with_changed_relevance (G : Geometry) (s : State) (r : Record)
    (c : Actor → Fin 2 → ℝ) (a : Actor → Actor → Fin 3 → ℝ)
    (ht : r.startTime<r.endTime)
    (hc : MemoryRules.cueDistanceSquared G {s with context := c, association := a} r <
      MemoryRules.cueDistanceSquared G s r) :
    readRecords {s with context := c, association := a}=readRecords s ∧
    recordWeight G s r<recordWeight G {s with context := c, association := a} r := by
  exact ⟨rfl,MemoryRulesVerified.closer_cue_increases_weight G _ _ r ht hc⟩

theorem declared_route_closes_at_first_teacher :
    (events 0).origin=0 ∧ (events 0).recipient=1 ∧
    (events 2).origin=1 ∧ (events 2).recipient=0 ∧
    (events 0).endTime≤(events 2).startTime := by
  change (0:Actor)=0 ∧ (1:Actor)=1 ∧ (1:Actor)=1 ∧ (0:Actor)=0 ∧ (0.4:ℝ)≤0.8
  norm_num

theorem no_later_declared_reply_to_student :
    ¬∃ id : Fin 3, (events id).origin=0 ∧ (events id).recipient=1 ∧
      (events 2).endTime≤(events id).startTime := by
  rintro ⟨id,h⟩
  fin_cases id
  · have hh : (1.2:ℝ)≤0 := h.2.2
    norm_num at hh
  · have hh : (2:Actor)=0 := h.1
    exact (by decide : (2:Actor)≠0) hh
  · have hh : (1:Actor)=0 := h.1
    exact (by decide : (1:Actor)≠0) hh

theorem witness_preserves_original_intent_expression (G : Geometry) :
    (engagementWitness G).expression=intent := by rfl

theorem expression_rate_can_leave_intent (G : Geometry) (t : ℝ)
    (rs : List (Fin 4 × Record)) :
    0<(socialRates G t (engagementWitness G) rs).expression 1 0 := by
  dsimp only [socialRates,engagementWitness,initial]
  norm_num [intent,Fin.sum_univ_succ]
  positivity

theorem accepted_full_rate_can_leave_intent (G : Geometry) (t : ℝ) (rate : State)
    (hr : rhs G t (engagementWitness G)=some rate) : 0<rate.expression 1 0 := by
  unfold rhs at hr
  obtain ⟨rs,_,hr⟩ := Option.bind_eq_some_iff.mp hr
  split at hr
  · rw [← Option.some.inj hr]
    exact expression_rate_can_leave_intent G t rs
  · cases hr

end
end HugV3.Source.BridgeReturnVerified
