import AccessDefinitions

namespace HugV3.Source.AccessVerified
noncomputable section
open Set ChildAccess Witness Transfer

theorem paired_diaries_on_the_timeline :
    (∀ t, t < (events 1).endTime → diary .sees t=diary .misses t) ∧
    (∀ t, (events 1).endTime≤t →
      diary .sees t=[publicOccurrence 0,publicOccurrence 1] ∧
      diary .misses t=[publicOccurrence 0]) := by sorry

theorem native_trace_set_for_either_diary (arm : DirectAccess) :
    {tr : Trace | ∃ log, fits arm tr log}={tr : Trace | Solves tr} := by sorry

theorem native_history_cannot_identify_direct_access (tr : Trace) (sol : Solves tr) :
    ¬ ∃ readAccess : Trace → DirectAccess,
       ∀ arm log, fits arm tr log → readAccess tr=arm := by sorry

theorem actual_incident_stays_scored_for_dad (s : State) (F₀ : Particle → Mat) (r : Record)
    (ok : makeEvent s F₀ 1=some r) :
    r.origin=officer ∧ r.recipient=father ∧ score r=some (-(3/5):ℝ) := by sorry

theorem incident_record_excludes_unfinished_predecessor (s : State) (F₀ : Particle → Mat)
    (r₀ r : Record) (slot : Fin 4) (decoded : readRecords s=some [(slot,r₀)])
    (end₀ : r₀.endTime=(events 0).endTime) (ok : makeEvent s F₀ 1=some r) :
    r.predecessors=0 := by sorry

theorem later_record_to_child_links_both_earlier_events (s : State) (F₀ : Particle → Mat)
    (r₀ r₁ r : Record) (a b : Fin 4) (decoded : readRecords s=some [(a,r₀),(b,r₁)])
    (id₀ : r₀.eventID=0) (id₁ : r₁.eventID=1)
    (end₀ : r₀.endTime=(events 0).endTime) (end₁ : r₁.endTime=(events 1).endTime)
    (ok : makeEvent s F₀ 2=some r) :
    r.origin=father ∧ r.recipient=child ∧ r.predecessors=3 ∧ r.report=some (1/5:ℝ) := by sorry

theorem predecessor_bits_do_not_drive_direct_retrieval (G : Geometry) (s : State)
    (r : Record) (bits : ℤ) (slot : Fin 4) (rs : List (Fin 4 × Record)) :
    score {r with predecessors:=bits}=score r ∧
    recordWeight G s {r with predecessors:=bits}=recordWeight G s r ∧
    (∀ i j, exposure G s ((slot,{r with predecessors:=bits})::rs) i j=
       exposure G s ((slot,r)::rs) i j) ∧
    ∀ i j k, memory G s ((slot,{r with predecessors:=bits})::rs) i j k=
       memory G s ((slot,r)::rs) i j k := by sorry

theorem earlier_dad_records_still_outside_child_channel (G : Geometry) (s : State)
    (r₀ r₁ r₂ : Record) (a b c : Fin 4)
    (to₀ : r₀.recipient=father) (to₁ : r₁.recipient=father) :
    ∀ j k, memory G s [(a,r₀),(b,r₁),(c,r₂)] child j k=
      memory G s [(c,r₂)] child j k := by sorry

theorem missing_or_wrong_crossing_is_unassessed (p q r : CrossingReport) :
    contrast none (some q) (some r)=none ∧ contrast (some p) none (some r)=none ∧
    contrast (some p) (some q) none=none ∧
    (q.reference≠0 → contrast (some p) (some q) (some r)=none) := by sorry

theorem observed_access_allows_different_report_patterns (tr : Trace) (sol : Solves tr) :
    fits .sees tr (diary .sees) ∧ fits .misses tr (diary .misses) ∧
    contrast (some (report .simpleCrossing)) (some (report .simpleCrossing))
      (some (report .simpleCrossing))=some ⟨false,false,false⟩ ∧
    contrast (some (report .simpleCrossing)) (some (report .fathersSafety))
      (some (report .simpleCrossing))=some ⟨true,false,true⟩ ∧
    contrast (some (report .simpleCrossing)) (some (report .fathersSafety))
      (some (report .yardRule))=some ⟨true,true,true⟩ := by sorry

theorem different_validated_readings_require_different_personal_contexts
    (decode : (Fin 2 → ℝ) → Formulation) (seen missed : Fin 2 → ℝ)
    (a b : Formulation) (hs : decode seen=a) (hm : decode missed=b) (different : a≠b) :
    seen≠missed := by sorry

theorem conditional_response_difference_uses_original_c_rate
    (G : Geometry) (s d e : State) (t h : ℝ) (k : Fin 2)
    (base : rhs G t s=some d) (change : rhs G t (bumpCooperation s child father h)=some e) :
    SameCrossingSetting s (bumpCooperation s child father h) ∧
    readRecords (bumpCooperation s child father h)=readRecords s ∧
    e.context child k-d.context child k=h*(s.context father k-s.context child k)/5 := by sorry

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
      (bumpCooperation s child father h).responses child father 1≤1 := by sorry

end
end HugV3.Source.AccessVerified
