import StreetWholeDefinitions

/-! Proofs for the frozen street-context audit. -/
namespace HugV3.Source.StreetWholeVerified
noncomputable section
open StreetWhole
open scoped BigOperators

attribute [local instance] Classical.propDecidable
set_option maxRecDepth 4096

private theorem forcing_off_of_small_gradient (s : State) (x : Grid)
    (small : sqnorm (centeredGradient s x)≤(0.015:ℝ)^2) : forcing s x=![0,0,0] := by
  have hs : Real.sqrt (sqnorm (centeredGradient s x)+0.003^2)≤
      Real.sqrt (0.015^2+0.003^2) := Real.sqrt_le_sqrt (by linarith)
  have hq : ¬0<Real.sqrt (sqnorm (centeredGradient s x)+0.003^2)-
      Real.sqrt (0.015^2+0.003^2) := by linarith
  simp [forcing,activation,hq]

private theorem forcing_on_of_large_gradient (s : State) (x : Grid)
    (large : (0.015:ℝ)^2<sqnorm (centeredGradient s x)) : forcing s x 0<0 := by
  have hs : Real.sqrt (0.015^2+0.003^2)<Real.sqrt (sqnorm (centeredGradient s x)+0.003^2) :=
    Real.sqrt_lt_sqrt (by norm_num) (by linarith)
  have hq : 0<Real.sqrt (sqnorm (centeredGradient s x)+0.003^2)-
      Real.sqrt (0.015^2+0.003^2) := sub_pos.mpr hs
  simp only [forcing,Matrix.cons_val_zero,activation,if_pos hq]
  exact mul_neg_of_neg_of_pos (by norm_num) (mul_pos hq (Real.exp_pos _))

private def written (G : Geometry) (s : State) (slot : Fin 4) (bytes : List ℕ) : State :=
  let account := writeAccount G s (targetFabric s slot bytes)
  let heatGrid := fun x => (∑ p, R s.X p x*G.V p*account.heat p)/dv
  {s with b := account.target
          g := fun x j => s.g x j+if j=4 then filt heatGrid x else 0
          writeWork := s.writeWork+account.work}

private theorem write_description (G : Geometry) (s w : State) (r : Record)
    (hw : writeEvent G s r=some w) :
    ∃ slot bytes, w=written G s slot bytes ∧
      0≤(writeAccount G s (targetFabric s slot bytes)).work := by
  unfold writeEvent at hw
  obtain ⟨rs,_,hw⟩ := Option.bind_eq_some_iff.mp hw
  split at hw
  · cases hw
  · obtain ⟨slot,_,hw⟩ := Option.bind_eq_some_iff.mp hw
    obtain ⟨bytes,_,hw⟩ := Option.bind_eq_some_iff.mp hw
    dsimp only at hw
    split at hw
    · cases hw
    · rename_i hgood
      refine ⟨slot,bytes,(Option.some.inj hw).symm,?_⟩
      exact le_of_not_gt (fun hn => hgood (Or.inr hn))

theorem full_input_keeps_all_other_coordinates (y : FullState) (signal : Scalar) :
    (fullLineInput y signal).starts=y.starts ∧
    {(fullLineInput y signal).state with g := y.state.g}=y.state ∧
    (∀ x k, k≠3 → (fullLineInput y signal).state.g x k=y.state.g x k) := by
  refine ⟨rfl,rfl,?_⟩
  intro x k hk
  simp [fullLineInput,withLineSignal,hk]

theorem line_enters_original_observation (G : Geometry) (s : State)
    (i : Actor) (signal : Scalar) :
    observations G (withLineSignal s signal) i 0=tanh (lineRead G s i signal/0.08) := by
  simp [observations,withLineSignal,lineRead]

theorem line_keeps_body_and_heat_readings (G : Geometry) (s : State)
    (i : Actor) (signal : Scalar) :
    observations G (withLineSignal s signal) i 1=observations G s i 1 ∧
    observations G (withLineSignal s signal) i 2=observations G s i 2 := by
  simp [observations,withLineSignal]

theorem line_keeps_records_and_current_relevance (G : Geometry) (s : State)
    (signal : Scalar) (r : Record) :
    readRecords (withLineSignal s signal)=readRecords s ∧
    recordWeight G (withLineSignal s signal) r=recordWeight G s r := by
  exact ⟨rfl,rfl⟩

theorem line_keeps_current_guard (s : State) (signal : Scalar) (i j : Actor) :
    margin (withLineSignal s signal) i j=margin s i j := by
  rfl

theorem personal_context_keeps_physical_state_and_records (G : Geometry)
    (s : State) (i : Actor) (h : ℝ) :
    {shiftPersonalContext s i h with context := s.context}=s ∧
    readRecords (shiftPersonalContext s i h)=readRecords s ∧
    observations G (shiftPersonalContext s i h)=observations G s := by
  exact ⟨rfl,rfl,rfl⟩

theorem personal_context_total_preserved (s : State) (i : Actor) (h : ℝ) :
    (∑ k, (shiftPersonalContext s i h).context i k)=∑ k, s.context i k := by
  simp [shiftPersonalContext,Fin.sum_univ_succ]
  ring

theorem personal_context_stays_in_unit_interval (s : State) (i : Actor) (h : ℝ)
    (hzero : 0≤s.context i 0+h ∧ s.context i 0+h≤1)
    (hone : 0≤s.context i 1-h ∧ s.context i 1-h≤1) :
    ∀ k, 0≤(shiftPersonalContext s i h).context i k ∧
      (shiftPersonalContext s i h).context i k≤1 := by
  intro k
  fin_cases k
  · simpa [shiftPersonalContext] using hzero
  · simpa [shiftPersonalContext,sub_eq_add_neg] using hone

theorem shifted_record_cue_coordinates (G : Geometry) (s : State) (r : Record)
    (hne : r.recipient≠r.origin) (h : ℝ) (k : Axis) :
    cueDifference G (shiftPersonalContext s r.recipient h) r k=
      cueDifference G s r k-(if k=0 then h/2 else if k=1 then -h/2 else 0) := by
  fin_cases k <;>
    simp [cueDifference,memoryFeature,shiftPersonalContext,Ne.symm hne] <;> ring

theorem original_weight_uses_current_cue (G : Geometry) (s : State) (r : Record) :
    recordWeight G s r=(r.endTime-r.startTime)*
      Real.exp (-sqnorm (cueDifference G s r)/(2*0.32^2)) := by
  rfl

theorem matched_record_weight_after_context_shift (G : Geometry) (s : State) (r : Record)
    (hne : r.recipient≠r.origin) (matched : ∀ k, cueDifference G s r k=0) (h : ℝ) :
    recordWeight G (shiftPersonalContext s r.recipient h) r=
      (r.endTime-r.startTime)*Real.exp (-(h^2/2)/(2*0.32^2)) := by
  have hs : sqnorm (cueDifference G (shiftPersonalContext s r.recipient h) r)=h^2/2 := by
    simp only [sqnorm,Fin.sum_univ_succ,shifted_record_cue_coordinates G s r hne h]
    simp [matched]
    ring
  rw [original_weight_uses_current_cue,hs]

theorem nonzero_context_shift_reduces_matched_weight (G : Geometry) (s : State) (r : Record)
    (hne : r.recipient≠r.origin) (matched : ∀ k, cueDifference G s r k=0)
    (duration : r.startTime<r.endTime) (h : ℝ) (nonzero : h≠0) :
    0<recordWeight G (shiftPersonalContext s r.recipient h) r ∧
    recordWeight G (shiftPersonalContext s r.recipient h) r<recordWeight G s r := by
  have hz : cueDifference G s r=fun _ => 0 := funext matched
  have hw : recordWeight G s r=r.endTime-r.startTime := by
    rw [original_weight_uses_current_cue,hz]
    simp [sqnorm]
  rw [matched_record_weight_after_context_shift G s r hne matched h,hw]
  have hd : 0<r.endTime-r.startTime := sub_pos.mpr duration
  have hsq : 0<h^2/2 := div_pos (sq_pos_of_ne_zero nonzero) (by norm_num)
  constructor
  · exact mul_pos hd (Real.exp_pos _)
  · have he : Real.exp (-(h^2/2)/(2*0.32^2))<1 := by
      apply Real.exp_lt_one_iff.mpr
      exact div_neg_of_neg_of_pos (neg_neg_of_pos hsq) (by norm_num)
    simpa using mul_lt_mul_of_pos_left he hd

theorem record_weight_bounded_by_duration (G : Geometry) (s : State) (r : Record)
    (duration : r.startTime≤r.endTime) :
    0≤recordWeight G s r ∧ recordWeight G s r≤r.endTime-r.startTime := by
  rw [original_weight_uses_current_cue]
  have hd : 0≤r.endTime-r.startTime := sub_nonneg.mpr duration
  have hs : 0≤sqnorm (cueDifference G s r) :=
    Finset.sum_nonneg (fun _ _ => sq_nonneg _)
  have he : Real.exp (-sqnorm (cueDifference G s r)/(2*0.32^2))≤1 := by
    apply Real.exp_le_one_iff.mpr
    exact div_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr hs) (by norm_num)
  exact ⟨mul_nonneg hd (Real.exp_pos _).le, by simpa using mul_le_mul_of_nonneg_left he hd⟩

theorem accepted_full_rhs_keeps_the_coupling (G : Geometry) (t : ℝ) (s d : State)
    (accepted : rhs G t s=some d) :
    ∃ records, readRecords s=some records ∧ d=rhsFromRecords G t s records ∧
      d.A=0.08*(socialRates G t s records).utility ∧
      (∀ x, d.g x 3=contextTransport (fun y => s.g y 3) (velocity s) x+
        s.A*sourceKernel G t s records x) ∧
      d.expression=(socialRates G t s records).expression ∧
      d.context=(socialRates G t s records).context := by
  unfold rhs at accepted
  obtain ⟨records,hr,hd⟩ := Option.bind_eq_some_iff.mp accepted
  split at hd
  · have heq : d=rhsFromRecords G t s records := (Option.some.inj hd).symm
    refine ⟨records,hr,heq,?_,?_,?_,?_⟩ <;> rw [heq]
    · rfl
    · intro x; rfl
    · rfl
    · rfl
  · cases hd

theorem original_guard_rate_uses_line_observation_and_experience
    (G : Geometry) (t : ℝ) (s : State) (records : List (Fin 4 × Record)) (i j : Actor) :
    (rhsFromRecords G t s records).logRadius i j=
      1.8*(Real.log (0.55+0.45*sigmoid
        (1.4*s.relation i j 2+memory G s records i j 0-memory G s records i j 1+
          s.responses i j 6-s.responses i j 4-0.3*observations G s i 0))-s.logRadius i j) := by
  rfl

theorem constant_signal_shift_keeps_gradient_and_force (s : State) (signal : Scalar)
    (h : ℝ) :
    centeredGradient (withLineSignal s (fun x => signal x+h))=
      centeredGradient (withLineSignal s signal) ∧
    forcing (withLineSignal s (fun x => signal x+h))=
      forcing (withLineSignal s signal) := by
  have hg : centeredGradient (withLineSignal s (fun x => signal x+h))=
      centeredGradient (withLineSignal s signal) := by
    funext x k
    simp only [centeredGradient,withLineSignal,ite_true]
    ring
  refine ⟨hg,?_⟩
  funext x
  simp only [forcing,hg]

theorem band_edge_gradient (s : State) (height : ℝ) :
    centeredGradient (withLineSignal s (bandSignal height)) (testCell 7)=![8*height,0,0] := by
  funext k
  fin_cases k <;> norm_num [centeredGradient,withLineSignal,bandSignal,testCell,shifted,dx,Fin.ext_iff] <;> ring

theorem band_center_does_not_activate (s : State) (height : ℝ) :
    forcing (withLineSignal s (bandSignal height)) (testCell 8)=![0,0,0] := by
  have hg : centeredGradient (withLineSignal s (bandSignal height)) (testCell 8)=![0,0,0] := by
    funext k
    fin_cases k <;> norm_num [centeredGradient,withLineSignal,bandSignal,testCell,shifted,dx,Fin.ext_iff]
  apply forcing_off_of_small_gradient
  rw [hg]
  norm_num [sqnorm,Fin.sum_univ_succ]

theorem small_band_edge_is_off (s : State) :
    forcing (withLineSignal s (bandSignal (1/1000))) (testCell 7)=![0,0,0] := by
  apply forcing_off_of_small_gradient
  rw [band_edge_gradient]
  norm_num [sqnorm,Fin.sum_univ_succ]

theorem larger_band_edge_is_on (s : State) :
    forcing (withLineSignal s (bandSignal (1/100))) (testCell 7) 0<0 := by
  apply forcing_on_of_large_gradient
  rw [band_edge_gradient]
  norm_num [sqnorm,Fin.sum_univ_succ]

theorem successful_write_preserves_person_and_line (G : Geometry) (s w : State) (r : Record)
    (accepted : writeEvent G s r=some w) :
    w.expression=s.expression ∧ w.context=s.context ∧ w.normCenter=s.normCenter ∧
    w.logRadius=s.logRadius ∧ w.relation=s.relation ∧ w.responses=s.responses ∧
    w.association=s.association ∧ w.X=s.X ∧ w.F=s.F ∧ w.A=s.A ∧
    (∀ x, w.g x 3=s.g x 3) ∧ s.writeWork≤w.writeWork := by
  obtain ⟨slot,bytes,heq,hn⟩ := write_description G s w r accepted
  rw [heq]
  refine ⟨rfl,rfl,rfl,rfl,rfl,rfl,rfl,rfl,rfl,rfl,?_,?_⟩
  · intro x; simp [written]
  · change s.writeWork≤s.writeWork+(writeAccount G s (targetFabric s slot bytes)).work
    linarith

theorem self_addressed_episode_is_rejected (r : Record) (self : r.origin=r.recipient) :
    payload r=none := by
  unfold payload
  rw [ite_eq_left (Or.inl self)]

end
end HugV3.Source.StreetWholeVerified
