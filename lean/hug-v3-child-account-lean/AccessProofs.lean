import AccessDefinitions
import WitnessProofs

namespace HugV3.Source.AccessVerified
noncomputable section
open Set ChildAccess Witness Transfer

private theorem built_previous_bits (s : State) (F₀ : Particle → Mat) (n : Fin 3)
    (rs : List (Fin 4 × Record)) (r : Record) (decoded : readRecords s=some rs)
    (ok : makeEvent s F₀ n=some r) :
    r.predecessors = ((rs.map (fun p => if p.2.endTime≤(events n).startTime then
      (2:ℕ)^p.2.eventID.val else 0)).sum : ℕ) := by
  unfold makeEvent at ok
  rw [decoded] at ok
  rw [← Option.some.inj ok]

private theorem unpack_rate (G : Geometry) (s d : State) (t : ℝ) (good : rhs G t s=some d) :
    ∃ rs, readRecords s=some rs ∧ d=rhsFromRecords G t s rs := by
  unfold rhs at good
  obtain ⟨rs,dec,eqn⟩ := Option.bind_eq_some_iff.mp good
  split at eqn
  · exact ⟨rs,dec,(Option.some.inj eqn).symm⟩
  · cases eqn

theorem paired_diaries_on_the_timeline :
    (∀ t, t < (events 1).endTime → diary .sees t=diary .misses t) ∧
    (∀ t, (events 1).endTime≤t →
      diary .sees t=[publicOccurrence 0,publicOccurrence 1] ∧
      diary .misses t=[publicOccurrence 0]) := by
  have order : (events 0).endTime≤(events 1).endTime := by
    norm_num [events,Matrix.cons_val_succ,Matrix.cons_val_two]
  constructor
  · intro t ht
    simp [diary,not_le.mpr ht]
  · intro t ht
    simp [diary,ht,order.trans ht]

theorem native_trace_set_for_either_diary (arm : DirectAccess) :
    {tr : Trace | ∃ log, fits arm tr log}={tr : Trace | Solves tr} := by
  ext tr
  constructor
  · rintro ⟨log,ok⟩
    exact ok.1
  · intro sol
    exact ⟨diary arm,sol,fun _ => rfl⟩

theorem native_history_cannot_identify_direct_access (tr : Trace) (sol : Solves tr) :
    ¬ ∃ readAccess : Trace → DirectAccess,
       ∀ arm log, fits arm tr log → readAccess tr=arm := by
  rintro ⟨readAccess,works⟩
  have seen := works .sees (diary .sees) ⟨sol,fun _ => rfl⟩
  have missed := works .misses (diary .misses) ⟨sol,fun _ => rfl⟩
  cases seen.symm.trans missed

theorem actual_incident_stays_scored_for_dad (s : State) (F₀ : Particle → Mat) (r : Record)
    (ok : makeEvent s F₀ 1=some r) :
    r.origin=officer ∧ r.recipient=father ∧ score r=some (-(3/5):ℝ) := by
  obtain ⟨orig,rec,obs,rep⟩ := WitnessVerified.actual_built_record_keeps_its_participants s F₀ 1 r ok
  refine ⟨orig,rec,?_⟩
  norm_num [score,obs,rep,events,Matrix.cons_val_succ]

theorem incident_record_excludes_unfinished_predecessor (s : State) (F₀ : Particle → Mat)
    (r₀ r : Record) (slot : Fin 4) (decoded : readRecords s=some [(slot,r₀)])
    (end₀ : r₀.endTime=(events 0).endTime) (ok : makeEvent s F₀ 1=some r) :
    r.predecessors=0 := by
  have overlap : (events 1).startTime < (events 0).endTime := by
    norm_num [events,Matrix.cons_val_succ]
  rw [built_previous_bits s F₀ 1 _ r decoded ok]
  simp [end₀,not_le.mpr overlap]

theorem later_record_to_child_links_both_earlier_events (s : State) (F₀ : Particle → Mat)
    (r₀ r₁ r : Record) (a b : Fin 4) (decoded : readRecords s=some [(a,r₀),(b,r₁)])
    (id₀ : r₀.eventID=0) (id₁ : r₁.eventID=1)
    (end₀ : r₀.endTime=(events 0).endTime) (end₁ : r₁.endTime=(events 1).endTime)
    (ok : makeEvent s F₀ 2=some r) :
    r.origin=father ∧ r.recipient=child ∧ r.predecessors=3 ∧ r.report=some (1/5:ℝ) := by
  obtain ⟨orig,rec,_,rep⟩ := WitnessVerified.actual_built_record_keeps_its_participants s F₀ 2 r ok
  have h₀ : (events 0).endTime≤(events 2).startTime := by
    norm_num [events,Matrix.cons_val_two,Matrix.cons_val_succ]
  have h₁ : (events 1).endTime≤(events 2).startTime := by
    norm_num [events,Matrix.cons_val_two,Matrix.cons_val_succ]
  refine ⟨orig,rec,?_,?_⟩
  · rw [built_previous_bits s F₀ 2 _ r decoded ok]
    norm_num [end₀,end₁,id₀,id₁,h₀,h₁]
  · rw [rep]
    norm_num [events,Matrix.cons_val_two,Matrix.cons_val_succ]

theorem predecessor_bits_do_not_drive_direct_retrieval (G : Geometry) (s : State)
    (r : Record) (bits : ℤ) (slot : Fin 4) (rs : List (Fin 4 × Record)) :
    score {r with predecessors:=bits}=score r ∧
    recordWeight G s {r with predecessors:=bits}=recordWeight G s r ∧
    (∀ i j, exposure G s ((slot,{r with predecessors:=bits})::rs) i j=
       exposure G s ((slot,r)::rs) i j) ∧
    ∀ i j k, memory G s ((slot,{r with predecessors:=bits})::rs) i j k=
       memory G s ((slot,r)::rs) i j k := by
  exact ⟨rfl,rfl,fun _ _ => rfl,fun _ _ _ => rfl⟩

theorem earlier_dad_records_still_outside_child_channel (G : Geometry) (s : State)
    (r₀ r₁ r₂ : Record) (a b c : Fin 4)
    (to₀ : r₀.recipient=father) (to₁ : r₁.recipient=father) :
    ∀ j k, memory G s [(a,r₀),(b,r₁),(c,r₂)] child j k=
      memory G s [(c,r₂)] child j k := by
  intro j k
  have no0 : r₀.recipient≠child := by rw [to₀]; decide
  have no1 : r₁.recipient≠child := by rw [to₁]; decide
  exact ((WitnessVerified.record_does_not_enter_bystander_retrieval G s [(b,r₁),(c,r₂)] a r₀ child no0).2 j k).trans
    ((WitnessVerified.record_does_not_enter_bystander_retrieval G s [(c,r₂)] b r₁ child no1).2 j k)

theorem missing_or_wrong_crossing_is_unassessed (p q r : CrossingReport) :
    contrast none (some q) (some r)=none ∧ contrast (some p) none (some r)=none ∧
    contrast (some p) (some q) none=none ∧
    (q.reference≠0 → contrast (some p) (some q) (some r)=none) := by
  refine ⟨rfl,rfl,rfl,?_⟩
  intro hq
  simp [contrast,hq]

theorem observed_access_allows_different_report_patterns (tr : Trace) (sol : Solves tr) :
    fits .sees tr (diary .sees) ∧ fits .misses tr (diary .misses) ∧
    contrast (some (report .simpleCrossing)) (some (report .simpleCrossing))
      (some (report .simpleCrossing))=some ⟨false,false,false⟩ ∧
    contrast (some (report .simpleCrossing)) (some (report .fathersSafety))
      (some (report .simpleCrossing))=some ⟨true,false,true⟩ ∧
    contrast (some (report .simpleCrossing)) (some (report .fathersSafety))
      (some (report .yardRule))=some ⟨true,true,true⟩ := by
  refine ⟨⟨sol,fun _ => rfl⟩,⟨sol,fun _ => rfl⟩,?_,?_,?_⟩ <;> decide

theorem different_validated_readings_require_different_personal_contexts
    (decode : (Fin 2 → ℝ) → Formulation) (seen missed : Fin 2 → ℝ)
    (a b : Formulation) (hs : decode seen=a) (hm : decode missed=b) (different : a≠b) :
    seen≠missed := by
  intro eqn
  exact different (hs.symm.trans ((congrArg decode eqn).trans hm))

theorem conditional_response_difference_uses_original_c_rate
    (G : Geometry) (s d e : State) (t h : ℝ) (k : Fin 2)
    (base : rhs G t s=some d) (change : rhs G t (bumpCooperation s child father h)=some e) :
    SameCrossingSetting s (bumpCooperation s child father h) ∧
    readRecords (bumpCooperation s child father h)=readRecords s ∧
    e.context child k-d.context child k=h*(s.context father k-s.context child k)/5 := by
  obtain ⟨rs,hr,hd⟩ := unpack_rate G s d t base
  obtain ⟨qs,hq,he⟩ := unpack_rate G (bumpCooperation s child father h) e t change
  have same : readRecords (bumpCooperation s child father h)=readRecords s := rfl
  rw [same,hr] at hq
  have lists := Option.some.inj hq
  subst qs
  refine ⟨⟨rfl,fun _ => rfl,rfl⟩,same,?_⟩
  rw [hd,he]
  exact WitnessVerified.own_cooperation_enters_context_rate G t s rs child father h k

theorem conditional_increment_can_be_zero_or_have_either_sign
    (G : Geometry) (s : State) (t : ℝ) (rs : List (Fin 4 × Record))
    (h : ℝ) (k : Fin 2) (positive : 0<h) (gap : s.context child k<s.context father k)
    (within : h≤s.responses child father 1 ∧ s.responses child father 1+h≤1) :
    (rhsFromRecords G t (bumpCooperation s child father (-h)) rs).context child k <
      (rhsFromRecords G t s rs).context child k ∧
    (rhsFromRecords G t s rs).context child k <
      (rhsFromRecords G t (bumpCooperation s child father h) rs).context child k ∧
    (rhsFromRecords G t (bumpCooperation s child father 0) rs).context child k =
      (rhsFromRecords G t s rs).context child k ∧
    0≤(bumpCooperation s child father (-h)).responses child father 1 ∧
      (bumpCooperation s child father h).responses child father 1≤1 := by
  have formula := WitnessVerified.own_cooperation_enters_context_rate G t s rs child father
  have gapPos := sub_pos.mpr gap
  have gain : 0 < h*(s.context father k-s.context child k)/5 := by positivity
  have neg := formula (-h) k
  have pos := formula h k
  have zer := formula 0 k
  refine ⟨?_,?_,?_,?_,?_⟩
  · linarith
  · linarith
  · exact sub_eq_zero.mp (by simpa using zer)
  · simp [bumpCooperation]
    linarith [within.1]
  · simpa [bumpCooperation] using within.2

end
end HugV3.Source.AccessVerified
