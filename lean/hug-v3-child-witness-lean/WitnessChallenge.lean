import WitnessDefinitions

namespace HugV3.Source.WitnessVerified
noncomputable section
open Set StreetWhole Transfer Witness
open scoped BigOperators

theorem declared_event_roles :
    (events 0).origin=child ∧ (events 0).recipient=father ∧
    (events 1).origin=officer ∧ (events 1).recipient=father ∧
    (events 2).origin=father ∧ (events 2).recipient=child ∧
    (events 1).startTime < (events 0).endTime ∧ (events 0).endTime < (events 1).endTime ∧
    (events 1).endTime=(events 2).startTime := by sorry

theorem actual_built_record_keeps_its_participants (s : State) (F₀ : Particle → Mat)
    (id : Fin 3) (r : Record) (ok : makeEvent s F₀ id=some r) :
    r.origin=(events id).origin ∧ r.recipient=(events id).recipient ∧
    r.observed=(events id).observed ∧ r.report=(events id).report := by sorry

theorem record_does_not_enter_bystander_retrieval (G : Geometry) (s : State)
    (rs : List (Fin 4 × Record)) (slot : Fin 4) (r : Record) (i : Actor)
    (outside : r.recipient≠i) :
    (∀ j, exposure G s ((slot,r)::rs) i j = exposure G s rs i j) ∧
    ∀ j k, memory G s ((slot,r)::rs) i j k = memory G s rs i j k := by sorry

theorem first_two_records_have_no_child_channel (G : Geometry) (s : State)
    (r₀ r₁ : Record) (a b : Fin 4) (h₀ : r₀.recipient=father) (h₁ : r₁.recipient=father) :
    ∀ j k, memory G s [(a,r₀),(b,r₁)] child j k=0 := by sorry

theorem original_personal_rate_uses_present_relationships (G : Geometry) (t : ℝ)
    (s : State) (rs : List (Fin 4 × Record)) (i : Actor) (k : Fin 2) :
    (rhsFromRecords G t s rs).context i k = contextDrift s t i k := by sorry

theorem record_scores_have_no_instant_personal_rate (G : Geometry) (t : ℝ)
    (s : State) (first second : List (Fin 4 × Record)) :
    (rhsFromRecords G t s first).context = (rhsFromRecords G t s second).context := by sorry

theorem adverse_record_changes_fathers_recognition_rate (G : Geometry) (s : State)
    (t y : ℝ) (old r : Record) (a b : Fin 4)
    (oldFrom : old.origin=child) (laterFrom : r.origin=officer) (laterTo : r.recipient=father)
    (duration : r.startTime<r.endTime) (scored : score r=some y) (negative : y<0) :
    0 < memory G s [(a,old),(b,r)] father officer 1 ∧
    (rhsFromRecords G t s [(a,old),(b,r)]).relation father officer 0 <
    (rhsFromRecords G t s [(a,old),(b,unscored r)]).relation father officer 0 := by sorry

theorem matched_tests_keep_setting (s : State) (h : ℝ) :
    SameCrossingSetting s (changeRating s father officer h) ∧
    SameCrossingSetting s (bumpCooperation s child father h) ∧
    (shiftPersonalContext s father h).context child=s.context child ∧
    (shiftPersonalContext s father h).g=s.g ∧ margin (shiftPersonalContext s father h)=margin s := by sorry

theorem fathers_rating_enters_childs_recognition (G : Geometry) (s : State) (t : ℝ)
    (rs : List (Fin 4 × Record)) (h : ℝ) (pos : 0<h) :
    recognitionInput G (changeRating s father officer h) rs child officer =
      recognitionInput G s rs child officer + 0.7*h/6 ∧
    (rhsFromRecords G t s rs).relation child officer 0 <
      (rhsFromRecords G t (changeRating s father officer h) rs).relation child officer 0 := by sorry

theorem childs_recognition_changes_cooperation_rate (G : Geometry) (s : State) (t : ℝ)
    (rs : List (Fin 4 × Record)) (h : ℝ) (pos : 0<h) (within : s.responses child officer 5≤1) :
    (rhsFromRecords G t s rs).responses child officer 1 <
      (rhsFromRecords G t (changeRating s child officer h) rs).responses child officer 1 := by sorry

theorem own_cooperation_enters_context_rate (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (i j : Actor) (h : ℝ) (k : Fin 2) :
    (rhsFromRecords G t (bumpCooperation s i j h) rs).context i k -
      (rhsFromRecords G t s rs).context i k = h*(s.context j k-s.context i k)/5 := by sorry

theorem changed_neighbor_context_enters_child_rate (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (i j : Actor) (distinct : i≠j) (h : ℝ) (k : Fin 2) :
    (rhsFromRecords G t (shiftPersonalContext s j h) rs).context i k -
      (rhsFromRecords G t s rs).context i k = neighborTermChange s i j h k / 5 := by sorry

theorem uncoupled_neighbor_context_has_zero_effect (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (h : ℝ) (k : Fin 2)
    (noImitation : s.responses child father 0=0) (noCooperation : s.responses child father 1=0)
    (noWithdrawal : s.responses child father 5=0) :
    (rhsFromRecords G t (shiftPersonalContext s father h) rs).context child k =
      (rhsFromRecords G t s rs).context child k := by sorry

theorem declared_context_response_example (G : Geometry) (h : ℝ) :
    (rhsFromRecords G 0 (bumpCooperation (initial G) child father h) []).context child 0 -
      (rhsFromRecords G 0 (initial G) []).context child 0 = -(3/20)*h := by sorry

theorem an_eligible_old_record_can_be_reweighted (G : Geometry) (s : State)
    (old : Record) (rs : List (Fin 4 × Record)) (a : Fin 4) (now h : ℝ)
    (hr : readRecords s=some rs) (stored : (a,old)∈rs) (earlier : old.endTime≤now)
    (addressed : old.recipient=child) (distinct : old.recipient≠old.origin)
    (matched : ∀ k, cueDifference G s old k=0) (duration : old.startTime<old.endTime) (moved : h≠0) :
    readRecords (shiftPersonalContext s child h)=some rs ∧
    (a,old)∈rs ∧ old.endTime≤now ∧
    0 < recordWeight G (shiftPersonalContext s child h) old ∧
      recordWeight G (shiftPersonalContext s child h) old < recordWeight G s old := by sorry

theorem all_accepted_checkpoints_keep_person_and_setting (n : ℕ) (s w : FullState)
    (accepted : boundary n s=some w) : SameCrossingSetting s.state w.state := by sorry

theorem actual_trace_context_rate (tr : Trace) (sol : Solves tr) (n : ℕ) (hn : n<5)
    (t : ℝ) (ht : t ∈ Icc (time n) (time (n+1))) (i : Actor) (k : Fin 2) :
    HasDerivWithinAt (fun u => (tr.path n u).state.context i k)
      (contextDrift (tr.path n t).state t i k) (Icc (time n) (time (n+1))) t := by sorry

theorem actual_trace_has_no_checkpoint_jump_in_context (tr : Trace) (sol : Solves tr)
    (n : ℕ) (hn : n<5) :
    SameCrossingSetting (tr.path n (time (n+1))).state (tr.after (n+1)).state := by sorry

theorem nonzero_rate_entails_a_later_change (tr : Trace) (sol : Solves tr)
    (n : ℕ) (hn : n<5) (t : ℝ) (left : time n≤t) (i : Actor) (k : Fin 2)
    (moving : contextDrift (tr.path n t).state t i k ≠ 0)
    (u : ℝ) (future : t<u) (limit : u≤time (n+1)) :
    ∃ v ∈ Ioc t u, (tr.path n v).state.context i k ≠ (tr.path n t).state.context i k := by sorry

theorem distinct_personal_rates_with_same_public_history (G : Geometry)
    (z w : ℝ → State) (a b : ℝ) (hab : a<b) (i : Actor) (k : Fin 2)
    (nativeZ : ∀ t ∈ Icc a b, ∃ d, rhs G t (z t)=some d ∧ StateHasDerivWithinAt z d (Icc a b) t)
    (nativeW : ∀ t ∈ Icc a b, ∃ d, rhs G t (w t)=some d ∧ StateHasDerivWithinAt w d (Icc a b) t)
    (publicSame : ∀ t ∈ Icc a b, (∀ x, (z t).g x 3=(w t).g x 3) ∧ margin (z t)=margin (w t))
    (start : (z a).context i k=(w a).context i k)
    (rates : contextDrift (z a) a i k ≠ contextDrift (w a) a i k) :
    ∃ t ∈ Ioc a b, (z t).context i k≠(w t).context i k ∧
      (∀ x, (z t).g x 3=(w t).g x 3) ∧ margin (z t)=margin (w t) := by sorry

end
end HugV3.Source.WitnessVerified
