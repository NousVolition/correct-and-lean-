import WitnessDefinitions
import StreetWholeProofs
import V3TransferProofs

namespace HugV3.Source.WitnessVerified
noncomputable section
open Set StreetWhole Transfer Witness
open scoped BigOperators

private theorem sigmoid_increasing {a b : ℝ} (h : a<b) : sigmoid a < sigmoid b := by
  unfold sigmoid
  apply one_div_lt_one_div_of_lt
  · positivity
  · linarith [Real.exp_lt_exp.mpr (neg_lt_neg h)]

private theorem recognition_projection (G : Geometry) (s : State) (t : ℝ)
    (rs : List (Fin 4 × Record)) (i j : Actor) :
    (rhsFromRecords G t s rs).relation i j 0 =
      2*(sigmoid (recognitionInput G s rs i j)*mask i j-s.relation i j 0) := by rfl

private theorem cooperation_projection (G : Geometry) (s : State) (t : ℝ)
    (rs : List (Fin 4 × Record)) (i j : Actor) :
    (rhsFromRecords G t s rs).responses i j 1 =
      4*(sigmoid (cooperationBase s i j+memory G s rs i j 0-memory G s rs i j 1)*
        attention s i j-s.responses i j 1) := by
  change 4*(sigmoid (-0.9+1.7*s.relation i j 2+
    Real.exp (-(∑ k,(s.expression j k-s.expression i k)^2)/0.6)+
    memory G s rs i j 0-memory G s rs i j 1+0.6*s.responses i j 6-0.5*s.responses i j 2)*
    attention s i j-s.responses i j 1)=_
  unfold cooperationBase
  congr 3 <;> ring

private theorem negative_record_channels (G : Geometry) (s : State)
    (r : Record) (b : Fin 4) (y : ℝ) (duration : r.startTime<r.endTime)
    (scored : score r=some y) (neg : y<0) :
    memory G s [(b,r)] r.recipient r.origin 0=0 ∧
    0<memory G s [(b,r)] r.recipient r.origin 1 := by
  have ww : 0<recordWeight G s r := by
    unfold recordWeight
    exact mul_pos (sub_pos.mpr duration) (Real.exp_pos _)
  have den : 0<(0.12:ℝ)+recordWeight G s r := by linarith
  constructor
  · simp [memory,exposure,scored,max_eq_right neg.le]
  · simpa [memory,exposure,scored,max_eq_left (neg_nonneg.mpr neg.le)] using
      div_pos (mul_pos ww (neg_pos.mpr neg)) den

private theorem completed_keeps_setting (id : Fin 3) (s w : FullState)
    (ok : completeEvent id s=some w) : SameCrossingSetting s.state w.state := by
  unfold completeEvent at ok
  obtain ⟨F,_,ok⟩ := Option.bind_eq_some_iff.mp ok
  obtain ⟨r,_,ok⟩ := Option.bind_eq_some_iff.mp ok
  obtain ⟨state,write,ok⟩ := Option.bind_eq_some_iff.mp ok
  rw [← Option.some.inj ok]
  obtain ⟨ex,ct,nm,lr,_,_,_,_,_,_,field,_⟩ :=
    StreetWholeVerified.successful_write_preserves_person_and_line sourceGeometry s.state state r write
  change SameCrossingSetting s.state state
  refine ⟨ct,field,?_⟩
  funext i j
  simp only [margin,lr,ex,nm]

theorem declared_event_roles :
    (events 0).origin=child ∧ (events 0).recipient=father ∧
    (events 1).origin=officer ∧ (events 1).recipient=father ∧
    (events 2).origin=father ∧ (events 2).recipient=child ∧
    (events 1).startTime < (events 0).endTime ∧ (events 0).endTime < (events 1).endTime ∧
    (events 1).endTime=(events 2).startTime := by
  norm_num [events,child,father,officer,Matrix.cons_val_two,Matrix.cons_val_succ]

theorem actual_built_record_keeps_its_participants (s : State) (F₀ : Particle → Mat)
    (id : Fin 3) (r : Record) (ok : makeEvent s F₀ id=some r) :
    r.origin=(events id).origin ∧ r.recipient=(events id).recipient ∧
    r.observed=(events id).observed ∧ r.report=(events id).report := by
  unfold makeEvent at ok
  obtain ⟨rs,_,eqn⟩ := Option.bind_eq_some_iff.mp ok
  rw [← Option.some.inj eqn]
  exact ⟨rfl,rfl,rfl,rfl⟩

theorem record_does_not_enter_bystander_retrieval (G : Geometry) (s : State)
    (rs : List (Fin 4 × Record)) (slot : Fin 4) (r : Record) (i : Actor)
    (outside : r.recipient≠i) :
    (∀ j, exposure G s ((slot,r)::rs) i j = exposure G s rs i j) ∧
    ∀ j k, memory G s ((slot,r)::rs) i j k = memory G s rs i j k := by
  constructor
  · intro j; simp [exposure,outside]
  · intro j k; simp [memory,exposure,outside]

theorem first_two_records_have_no_child_channel (G : Geometry) (s : State)
    (r₀ r₁ : Record) (a b : Fin 4) (h₀ : r₀.recipient=father) (h₁ : r₁.recipient=father) :
    ∀ j k, memory G s [(a,r₀),(b,r₁)] child j k=0 := by
  intro j k
  have fd : father ≠ child := by decide
  simp [memory,exposure,h₀,h₁,fd]

theorem original_personal_rate_uses_present_relationships (G : Geometry) (t : ℝ)
    (s : State) (rs : List (Fin 4 × Record)) (i : Actor) (k : Fin 2) :
    (rhsFromRecords G t s rs).context i k = contextDrift s t i k := by
  rfl

theorem record_scores_have_no_instant_personal_rate (G : Geometry) (t : ℝ)
    (s : State) (first second : List (Fin 4 × Record)) :
    (rhsFromRecords G t s first).context = (rhsFromRecords G t s second).context := by
  rfl

theorem adverse_record_changes_fathers_recognition_rate (G : Geometry) (s : State)
    (t y : ℝ) (old r : Record) (a b : Fin 4)
    (oldFrom : old.origin=child) (laterFrom : r.origin=officer) (laterTo : r.recipient=father)
    (duration : r.startTime<r.endTime) (scored : score r=some y) (negative : y<0) :
    0 < memory G s [(a,old),(b,r)] father officer 1 ∧
    (rhsFromRecords G t s [(a,old),(b,r)]).relation father officer 0 <
    (rhsFromRecords G t s [(a,old),(b,unscored r)]).relation father officer 0 := by
  have diff : old.origin ≠ officer := by rw [oldFrom]; decide
  have drop : ∀ (q : Record) k, memory G s [(a,old),(b,q)] father officer k =
      memory G s [(b,q)] father officer k := fun q k =>
    TransferVerified.memory_stays_with_original_pair G s [(b,q)] a old father officer diff k
  obtain ⟨zero,harm⟩ := negative_record_channels G s r b y duration scored negative
  rw [laterTo,laterFrom] at zero harm
  have empty (k : Fin 4) : memory G s [(b,unscored r)] father officer k=0 := by
    simp [memory,exposure,unscored,score]
  refine ⟨by rw [drop]; exact harm,?_⟩
  rw [recognition_projection,recognition_projection]
  have logit : recognitionInput G s [(a,old),(b,r)] father officer <
      recognitionInput G s [(a,old),(b,unscored r)] father officer := by
    unfold recognitionInput
    simp only [drop,zero,empty]
    linarith
  have hm : mask father officer=1 := by norm_num [mask,father,officer,Fin.ext_iff]
  rw [hm,mul_one,mul_one]
  linarith [sigmoid_increasing logit]

theorem matched_tests_keep_setting (s : State) (h : ℝ) :
    SameCrossingSetting s (changeRating s father officer h) ∧
    SameCrossingSetting s (bumpCooperation s child father h) ∧
    (shiftPersonalContext s father h).context child=s.context child ∧
    (shiftPersonalContext s father h).g=s.g ∧ margin (shiftPersonalContext s father h)=margin s := by
  have hn : child≠father := by decide
  refine ⟨⟨rfl,fun _ => rfl,rfl⟩,⟨rfl,fun _ => rfl,rfl⟩,?_,rfl,rfl⟩
  funext k
  simp [shiftPersonalContext,hn]

theorem fathers_rating_enters_childs_recognition (G : Geometry) (s : State) (t : ℝ)
    (rs : List (Fin 4 × Record)) (h : ℝ) (pos : 0<h) :
    recognitionInput G (changeRating s father officer h) rs child officer =
      recognitionInput G s rs child officer + 0.7*h/6 ∧
    (rhsFromRecords G t s rs).relation child officer 0 <
      (rhsFromRecords G t (changeRating s father officer h) rs).relation child officer 0 := by
  have cf : child ≠ father := by decide
  have co : child ≠ officer := by decide
  have hm : recognitionMean (changeRating s father officer h) officer=recognitionMean s officer+h/6 := by
    unfold recognitionMean changeRating
    simp [Finset.sum_add_distrib]
    ring
  have mem (k : Fin 4) : memory G (changeRating s father officer h) rs child officer k =
      memory G s rs child officer k := rfl
  have q : recognitionInput G (changeRating s father officer h) rs child officer =
      recognitionInput G s rs child officer+0.7*h/6 := by
    simp only [recognitionInput,hm,mem]
    change 3*((∑ k,s.context child k*recognitionBase officer k)-0.5)+0.7*(recognitionMean s officer+h/6)+
      0.8*(s.responses child officer 0+s.responses child officer 2)+memory G s rs child officer 0-
      0.5*memory G s rs child officer 1 = _
    ring
  refine ⟨q,?_⟩
  rw [recognition_projection,recognition_projection,q]
  have hmask : mask child officer=1 := by simp [mask,co]
  rw [hmask,mul_one,mul_one]
  have rated : (changeRating s father officer h).relation child officer 0=s.relation child officer 0 := by
    simp [changeRating,cf]
  rw [rated]
  have hs := sigmoid_increasing (show recognitionInput G s rs child officer <
    recognitionInput G s rs child officer+0.7*h/6 by linarith)
  linarith

theorem childs_recognition_changes_cooperation_rate (G : Geometry) (s : State) (t : ℝ)
    (rs : List (Fin 4 × Record)) (h : ℝ) (pos : 0<h) (within : s.responses child officer 5≤1) :
    (rhsFromRecords G t s rs).responses child officer 1 <
      (rhsFromRecords G t (changeRating s child officer h) rs).responses child officer 1 := by
  rw [cooperation_projection,cooperation_projection]
  have mm (k : Fin 4) : memory G (changeRating s child officer h) rs child officer k =
      memory G s rs child officer k := rfl
  have base : cooperationBase (changeRating s child officer h) child officer =
      cooperationBase s child officer := by simp [cooperationBase,changeRating,show (2:Fin 3)≠0 by decide]
  simp only [base,mm]
  have hmask : mask child officer=1 := by norm_num [mask,child,officer,Fin.ext_iff]
  have ha : attention s child officer < attention (changeRating s child officer h) child officer := by
    unfold attention
    simp [changeRating,hmask]
    have hs : 0 < 0.15+(0.85:ℝ)*Real.exp (-(∑ k,(s.context child k-s.context officer k)^2)/0.35) := by positivity
    have hw : 0<1-0.6*s.responses child officer 5 := by linarith
    gcongr <;> linarith
  have hs : 0<sigmoid (cooperationBase s child officer+memory G s rs child officer 0-memory G s rs child officer 1) :=
    one_div_pos.mpr (add_pos (by norm_num) (Real.exp_pos _))
  have hr : (changeRating s child officer h).responses child officer 1=s.responses child officer 1 := rfl
  rw [hr]
  linarith [mul_lt_mul_of_pos_left ha hs]

theorem own_cooperation_enters_context_rate (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (i j : Actor) (h : ℝ) (k : Fin 2) :
    (rhsFromRecords G t (bumpCooperation s i j h) rs).context i k -
      (rhsFromRecords G t s rs).context i k = h*(s.context j k-s.context i k)/5 := by
  rw [original_personal_rate_uses_present_relationships,original_personal_rate_uses_present_relationships]
  have changes (p : Actor) : contextTerm (bumpCooperation s i j h) i p k =
      contextTerm s i p k + if p=j then h*(s.context j k-s.context i k) else 0 := by
    by_cases hp : p=j
    · subst p
      simp [contextTerm,bumpCooperation,show (0:Fin 7)≠1 by decide,show (5:Fin 7)≠1 by decide]
      ring
    · simp [contextTerm,bumpCooperation,hp]
  unfold contextDrift
  simp_rw [changes]
  rw [Finset.sum_add_distrib]
  simp [bumpCooperation]
  ring

theorem changed_neighbor_context_enters_child_rate (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (i j : Actor) (distinct : i≠j) (h : ℝ) (k : Fin 2) :
    (rhsFromRecords G t (shiftPersonalContext s j h) rs).context i k -
      (rhsFromRecords G t s rs).context i k = neighborTermChange s i j h k / 5 := by
  rw [original_personal_rate_uses_present_relationships,original_personal_rate_uses_present_relationships]
  have changes (p : Actor) : contextTerm (shiftPersonalContext s j h) i p k =
      contextTerm s i p k + if p=j then neighborTermChange s i j h k else 0 := by
    by_cases hp : p=j
    · subst p
      by_cases hk : k=0 <;>
        simp [contextTerm,neighborTermChange,changeCoord,shiftPersonalContext,distinct,Fin.sum_univ_succ,hk] <;> ring
    · simp [contextTerm,shiftPersonalContext,distinct,hp]
  unfold contextDrift
  simp_rw [changes]
  rw [Finset.sum_add_distrib]
  simp [shiftPersonalContext,distinct]
  ring

theorem uncoupled_neighbor_context_has_zero_effect (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (h : ℝ) (k : Fin 2)
    (noImitation : s.responses child father 0=0) (noCooperation : s.responses child father 1=0)
    (noWithdrawal : s.responses child father 5=0) :
    (rhsFromRecords G t (shiftPersonalContext s father h) rs).context child k =
      (rhsFromRecords G t s rs).context child k := by
  have hd := changed_neighbor_context_enters_child_rate G t s rs child father (by decide) h k
  simp [neighborTermChange,noImitation,noCooperation,noWithdrawal] at hd
  linarith

theorem declared_context_response_example (G : Geometry) (h : ℝ) :
    (rhsFromRecords G 0 (bumpCooperation (initial G) child father h) []).context child 0 -
      (rhsFromRecords G 0 (initial G) []).context child 0 = -(3/20)*h := by
  rw [own_cooperation_enters_context_rate]
  norm_num [initial,home,child,father,Matrix.cons_val_succ,Matrix.vecHead,Matrix.vecTail]
  ring

theorem an_eligible_old_record_can_be_reweighted (G : Geometry) (s : State)
    (old : Record) (rs : List (Fin 4 × Record)) (a : Fin 4) (now h : ℝ)
    (hr : readRecords s=some rs) (stored : (a,old)∈rs) (earlier : old.endTime≤now)
    (addressed : old.recipient=child) (distinct : old.recipient≠old.origin)
    (matched : ∀ k, cueDifference G s old k=0) (duration : old.startTime<old.endTime) (moved : h≠0) :
    readRecords (shiftPersonalContext s child h)=some rs ∧
    (a,old)∈rs ∧ old.endTime≤now ∧
    0 < recordWeight G (shiftPersonalContext s child h) old ∧
      recordWeight G (shiftPersonalContext s child h) old < recordWeight G s old := by
  have rd : readRecords (shiftPersonalContext s child h)=readRecords s := rfl
  refine ⟨rd.trans hr,stored,earlier,?_⟩
  rw [← addressed]
  exact StreetWholeVerified.nonzero_context_shift_reduces_matched_weight G s old distinct matched duration h moved

theorem all_accepted_checkpoints_keep_person_and_setting (n : ℕ) (s w : FullState)
    (accepted : boundary n s=some w) : SameCrossingSetting s.state w.state := by
  match n with
  | 0 | 1 => rw [← Option.some.inj accepted]; exact ⟨rfl,fun _ => rfl,rfl⟩
  | 2 => exact completed_keeps_setting 0 s w accepted
  | 3 =>
    change (completeEvent 1 s).map (capture 2)=some w at accepted
    obtain ⟨v,hv,eqn⟩ := Option.map_eq_some_iff.mp accepted
    rw [← eqn]
    exact completed_keeps_setting 1 s v hv
  | 4 => exact completed_keeps_setting 2 s w accepted
  | n+5 => rw [← Option.some.inj accepted]; exact ⟨rfl,fun _ => rfl,rfl⟩

theorem actual_trace_context_rate (tr : Trace) (sol : Solves tr) (n : ℕ) (hn : n<5)
    (t : ℝ) (ht : t ∈ Icc (time n) (time (n+1))) (i : Actor) (k : Fin 2) :
    HasDerivWithinAt (fun u => (tr.path n u).state.context i k)
      (contextDrift (tr.path n t).state t i k) (Icc (time n) (time (n+1))) t := by
  obtain ⟨d,accept,deriv⟩ := (sol.2 n hn).2.2.2.1 t ht
  obtain ⟨_,_,_,_,_,_,_,_,_,ctx,_⟩ := deriv
  have hc := ctx i k
  unfold rhs at accept
  obtain ⟨rs,_,eqn⟩ := Option.bind_eq_some_iff.mp accept
  split at eqn
  · rw [← Option.some.inj eqn] at hc
    exact hc
  · cases eqn

theorem actual_trace_has_no_checkpoint_jump_in_context (tr : Trace) (sol : Solves tr)
    (n : ℕ) (hn : n<5) :
    SameCrossingSetting (tr.path n (time (n+1))).state (tr.after (n+1)).state := by
  exact all_accepted_checkpoints_keep_person_and_setting _ _ _ (sol.2 n hn).2.2.2.2

theorem nonzero_rate_entails_a_later_change (tr : Trace) (sol : Solves tr)
    (n : ℕ) (hn : n<5) (t : ℝ) (left : time n≤t) (i : Actor) (k : Fin 2)
    (moving : contextDrift (tr.path n t).state t i k ≠ 0)
    (u : ℝ) (future : t<u) (limit : u≤time (n+1)) :
    ∃ v ∈ Ioc t u, (tr.path n v).state.context i k ≠ (tr.path n t).state.context i k := by
  by_contra! same
  let f := fun v => (tr.path n v).state.context i k
  have deriv := actual_trace_context_rate tr sol n hn t ⟨left,le_trans future.le limit⟩ i k
  have sub : Icc t u ⊆ Icc (time n) (time (n+1)) := Icc_subset_Icc left limit
  have fixed : HasDerivWithinAt f 0 (Icc t u) t := by
    apply (hasDerivWithinAt_const t (Icc t u) (f t)).congr
    · intro v hv
      rcases eq_or_lt_of_le hv.1 with e | l
      · rw [← e]
      · exact same v ⟨l,hv.2⟩
    · rfl
  have unique := uniqueDiffOn_Icc future t (show t∈Icc t u from ⟨le_rfl,future.le⟩)
  exact moving (((deriv.mono sub).derivWithin unique).symm.trans (fixed.derivWithin unique))

theorem distinct_personal_rates_with_same_public_history (G : Geometry)
    (z w : ℝ → State) (a b : ℝ) (hab : a<b) (i : Actor) (k : Fin 2)
    (nativeZ : ∀ t ∈ Icc a b, ∃ d, rhs G t (z t)=some d ∧ StateHasDerivWithinAt z d (Icc a b) t)
    (nativeW : ∀ t ∈ Icc a b, ∃ d, rhs G t (w t)=some d ∧ StateHasDerivWithinAt w d (Icc a b) t)
    (publicSame : ∀ t ∈ Icc a b, (∀ x, (z t).g x 3=(w t).g x 3) ∧ margin (z t)=margin (w t))
    (start : (z a).context i k=(w a).context i k)
    (rates : contextDrift (z a) a i k ≠ contextDrift (w a) a i k) :
    ∃ t ∈ Ioc a b, (z t).context i k≠(w t).context i k ∧
      (∀ x, (z t).g x 3=(w t).g x 3) ∧ margin (z t)=margin (w t) := by
  have project (f : ℝ → State) (hf : ∀ t ∈ Icc a b, ∃ d, rhs G t (f t)=some d ∧
      StateHasDerivWithinAt f d (Icc a b) t) :
      HasDerivWithinAt (fun t => (f t).context i k) (contextDrift (f a) a i k) (Icc a b) a := by
    obtain ⟨d,ac,hd⟩ := hf a ⟨le_rfl,hab.le⟩
    obtain ⟨_,_,_,_,_,_,_,_,_,ctx,_⟩ := hd
    have hc := ctx i k
    unfold rhs at ac
    obtain ⟨rs,_,eqn⟩ := Option.bind_eq_some_iff.mp ac
    split at eqn
    · rw [← Option.some.inj eqn] at hc
      exact hc
    · cases eqn
  have separated : ∃ t ∈ Ioc a b, (z t).context i k ≠ (w t).context i k := by
    by_contra! equal
    have zw : HasDerivWithinAt (fun t => (w t).context i k) (contextDrift (z a) a i k) (Icc a b) a := by
      apply (project z nativeZ).congr
      · intro t ht
        rcases eq_or_lt_of_le ht.1 with e | l
        · rw [← e]; exact start.symm
        · exact (equal t ⟨l,ht.2⟩).symm
      · exact start.symm
    have uq := uniqueDiffOn_Icc hab a (show a∈Icc a b from ⟨le_rfl,hab.le⟩)
    exact rates ((zw.derivWithin uq).symm.trans ((project w nativeW).derivWithin uq))
  obtain ⟨t,ht,diff⟩ := separated
  exact ⟨t,ht,diff,publicSame t ⟨ht.1.le,ht.2⟩⟩

end
end HugV3.Source.WitnessVerified
