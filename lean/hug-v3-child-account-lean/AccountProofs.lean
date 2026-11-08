import AccountDefinitions
import AccessProofs

namespace HugV3.Source.AccountVerified
noncomputable section
open ChildAccount ChildAccess Witness Transfer

private theorem without_older_rows (G : Geometry) (s : State)
    (old incident r : Record) (y : Option ℝ) (to₀ : old.recipient=father) (to₁ : incident.recipient=father) :
    exposure G s (panel old incident r y) child father=exposure G s [(2,setReport r y)] child father ∧
    ∀ k, memory G s (panel old incident r y) child father k=memory G s [(2,setReport r y)] child father k := by
  have fd : father≠child := by decide
  have a : old.recipient≠child := to₀ ▸ fd
  have b : incident.recipient≠child := to₁ ▸ fd
  have one := WitnessVerified.record_does_not_enter_bystander_retrieval G s
    [(1,incident),(2,setReport r y)] 0 old child a
  have two := WitnessVerified.record_does_not_enter_bystander_retrieval G s
    [(2,setReport r y)] 1 incident child b
  exact ⟨(one.1 father).trans (two.1 father),fun k => (one.2 father k).trans (two.2 father k)⟩

private theorem fraction_positive (G : Geometry) (s : State) (r : Record)
    (dt : r.startTime<r.endTime) : 0<historyFraction G s r := by
  have w : 0<recordWeight G s r := mul_pos (sub_pos.mpr dt) (Real.exp_pos _)
  exact div_pos w (by linarith)

private theorem increasing_sigmoid {u v : ℝ} (order : u<v) : sigmoid u<sigmoid v := by
  unfold sigmoid
  apply one_div_lt_one_div_of_lt
  · positivity
  · linarith [Real.exp_lt_exp.mpr (neg_lt_neg order)]

private theorem three_projections (G : Geometry) (s : State) (t : ℝ) (rs : List (Fin 4 × Record)) :
    let d := rhsFromRecords G t s rs
    d.responses child father 0 =
      4*(sigmoid (imitationInput G s rs)*attention s child father-s.responses child father 0) ∧
    d.responses child father 1 =
      4*(sigmoid (cooperationInput G s rs)*attention s child father-s.responses child father 1) ∧
    d.responses child father 5 =
      4*(sigmoid (withdrawalInput G s rs)*attention s child father-s.responses child father 5) := by
  exact ⟨rfl,rfl,rfl⟩

private theorem accepted_context (G : Geometry) (s d : State) (t : ℝ) (ok : rhs G t s=some d)
    (i : Actor) (l : Fin 2) : d.context i l=contextDrift s t i l := by
  unfold rhs at ok
  obtain ⟨rs,_,eqn⟩ := Option.bind_eq_some_iff.mp ok
  split at eqn
  · rw [← Option.some.inj eqn]
    rfl
  · cases eqn

private theorem project_c {P : (State → ℝ) → Prop} (all : AllCoordinates P)
    (i : Actor) (k : Fin 2) : P (fun s => s.context i k) := by
  obtain ⟨_,_,_,_,_,_,_,_,_,hc,_⟩ := all
  exact hc i k

private theorem project_r {P : (State → ℝ) → Prop} (all : AllCoordinates P)
    (i j : Actor) (m : Fin 7) : P (fun s => s.responses i j m) := by
  obtain ⟨_,_,_,_,_,_,_,_,_,_,_,_,_,hr,_⟩ := all
  exact hr i j m

theorem account_without_separate_rating_preserves_input (a : Account) (r : Record)
    (right : eligible a r) (noRating : a.evaluation=none) : inputRecord a r=some r := by
  simp [inputRecord,right,noRating]

theorem attributed_current_rating_uses_only_report_field (a : Account) (r : Record)
    (v : Evaluation) (right : eligible a r) (rated : a.evaluation=some v)
    (current : v.aboutEncounter=2) (valid : -1≤v.value ∧ v.value≤1) :
    inputRecord a r=some {r with report:=some v.value} := by
  simp [inputRecord,right,rated,current,valid.1,valid.2,setReport]

theorem crossing_reference_and_current_rating_have_distinct_targets (a : Account) (r : Record)
    (v : Evaluation) (rated : a.evaluation=some v) :
    (¬eligible a r → inputRecord a r=none) ∧
    (v.aboutEncounter≠2 → inputRecord a r=none) ∧
    (¬(-1≤v.value ∧ v.value≤1) → inputRecord a r=none) := by
  constructor
  · intro wrong; simp [inputRecord,wrong]
  constructor
  · intro wrong; by_cases h : eligible a r <;> simp [inputRecord,h,rated,wrong]
  · intro bad
    by_cases h : eligible a r
    · have nope : ¬(v.aboutEncounter=2 ∧ -1≤v.value ∧ v.value≤1) := fun x => bad x.2
      simp [inputRecord,h,rated,nope]
    · simp [inputRecord,h]

theorem words_and_direct_sight_do_not_choose_a_number (a : Account) (r : Record)
    (words : String) (access : DirectAccess) :
    inputRecord {a with wording:=words,access:=access} r=inputRecord a r := by
  rfl

theorem declared_third_record_is_childs_later_report (s : State) (F₀ : Particle → Mat)
    (r : Record) (ok : makeEvent s F₀ 2=some r) :
    r.origin=father ∧ r.recipient=child ∧ r.observed=none ∧ r.report=some (1/5:ℝ) := by
  obtain ⟨orig,rec,obs,rep⟩ := WitnessVerified.actual_built_record_keeps_its_participants s F₀ 2 r ok
  refine ⟨orig,rec,?_,?_⟩
  · simpa [events,Matrix.cons_val_two,Matrix.cons_val_succ] using obs
  · rw [rep]; norm_num [events,Matrix.cons_val_two,Matrix.cons_val_succ]

theorem score_uses_independent_observation_only_when_present (r : Record) (y v : ℝ) :
    score {r with observed:=none,report:=some y}=some y ∧
    score {r with observed:=some v,report:=some y}=some ((v+y)/2) ∧
    score {r with observed:=some v,report:=none}=some v ∧
    score {r with observed:=none,report:=none}=none := by
  exact ⟨rfl,rfl,rfl,rfl⟩

theorem private_report_enters_signed_retrieval (G : Geometry) (s : State)
    (old incident r : Record) (y : ℝ) (to₀ : old.recipient=father) (to₁ : incident.recipient=father)
    (fromDad : r.origin=father) (toChild : r.recipient=child) (independent : r.observed=none) :
    exposure G s (panel old incident r (some y)) child father=recordWeight G s r ∧
    memory G s (panel old incident r (some y)) child father 0 -
      memory G s (panel old incident r (some y)) child father 1 = historyFraction G s r*y := by
  let q := setReport r (some y)
  have fo : q.origin=father := fromDad
  have tc : q.recipient=child := toChild
  have sc : score q=some y := by simp [q,score,setReport,independent]
  have wt : recordWeight G s q=recordWeight G s r := rfl
  obtain ⟨dropE,dropM⟩ := without_older_rows G s old incident r (some y) to₀ to₁
  change exposure G s (panel old incident r (some y)) child father=recordWeight G s r ∧ _
  constructor
  · rw [dropE]
    change exposure G s [(2,q)] child father=_
    simp [exposure,fo,tc,sc,wt]
  · rw [dropM 0,dropM 1]
    change memory G s [(2,q)] child father 0 - memory G s [(2,q)] child father 1 = _
    by_cases hy : 0≤y
    · simp [memory,exposure,fo,tc,sc,wt,historyFraction,max_eq_left hy,max_eq_right (neg_nonpos.mpr hy)]
      ring
    · have lo : y≤0 := le_of_not_ge hy
      simp [memory,exposure,fo,tc,sc,wt,historyFraction,max_eq_right lo,max_eq_left (neg_nonneg.mpr lo)]
      ring

theorem neutral_report_and_missing_report_are_distinguishable (G : Geometry) (s : State)
    (old incident r : Record) (to₀ : old.recipient=father) (to₁ : incident.recipient=father)
    (fromDad : r.origin=father) (toChild : r.recipient=child) (independent : r.observed=none)
    (duration : r.startTime<r.endTime) :
    exposure G s (panel old incident r none) child father=0 ∧
    0<exposure G s (panel old incident r (some 0)) child father ∧
    memory G s (panel old incident r (some 0)) child father 0-
      memory G s (panel old incident r (some 0)) child father 1=0 := by
  obtain ⟨keep,net⟩ := private_report_enters_signed_retrieval G s old incident r 0 to₀ to₁ fromDad toChild independent
  obtain ⟨drop,_⟩ := without_older_rows G s old incident r none to₀ to₁
  have ww : 0<recordWeight G s r := mul_pos (sub_pos.mpr duration) (Real.exp_pos _)
  refine ⟨?_,keep.symm ▸ ww,by simpa using net⟩
  rw [drop]
  simp [exposure,setReport,fromDad,toChild,score,independent]

theorem rating_changes_three_response_rates (G : Geometry) (s : State) (t low high : ℝ)
    (old incident r : Record) (to₀ : old.recipient=father) (to₁ : incident.recipient=father)
    (fromDad : r.origin=father) (toChild : r.recipient=child) (independent : r.observed=none)
    (duration : r.startTime<r.endTime) (present : 0<attention s child father) (order : low<high) :
    let d := rhsFromRecords G t s (panel old incident r (some low))
    let e := rhsFromRecords G t s (panel old incident r (some high))
    d.responses child father 0<e.responses child father 0 ∧
    d.responses child father 1<e.responses child father 1 ∧
    e.responses child father 5<d.responses child father 5 ∧ d.context=e.context := by
  let L := panel old incident r (some low)
  let H := panel old incident r (some high)
  have lowNet : memory G s L child father 0-memory G s L child father 1=historyFraction G s r*low :=
    (private_report_enters_signed_retrieval G s old incident r low to₀ to₁ fromDad toChild independent).2
  have highNet : memory G s H child father 0-memory G s H child father 1=historyFraction G s r*high :=
    (private_report_enters_signed_retrieval G s old incident r high to₀ to₁ fromDad toChild independent).2
  have increase := mul_lt_mul_of_pos_left order (fraction_positive G s r duration)
  have im : imitationInput G s L < imitationInput G s H := by unfold imitationInput; linarith
  have co : cooperationInput G s L < cooperationInput G s H := by unfold cooperationInput; linarith
  have wi : withdrawalInput G s H < withdrawalInput G s L := by unfold withdrawalInput; linarith
  obtain ⟨l₀,l₁,l₅⟩ := three_projections G s t L
  obtain ⟨h₀,h₁,h₅⟩ := three_projections G s t H
  change (rhsFromRecords G t s L).responses child father 0 < (rhsFromRecords G t s H).responses child father 0 ∧ _
  refine ⟨?_,?_,?_,rfl⟩
  · rw [l₀,h₀]; linarith [mul_lt_mul_of_pos_right (increasing_sigmoid im) present]
  · change (rhsFromRecords G t s L).responses child father 1 < (rhsFromRecords G t s H).responses child father 1
    rw [l₁,h₁]; linarith [mul_lt_mul_of_pos_right (increasing_sigmoid co) present]
  · change (rhsFromRecords G t s H).responses child father 5 < (rhsFromRecords G t s L).responses child father 5
    rw [h₅,l₅]; linarith [mul_lt_mul_of_pos_right (increasing_sigmoid wi) present]

theorem accepted_report_writes_preserve_immediate_context_and_agreement
    (G : Geometry) (s u v : State) (r : Record) (y z : Option ℝ) (t : ℝ)
    (ru rv : List (Fin 4 × Record))
    (wy : writeEvent G s (setReport r y)=some u) (wz : writeEvent G s (setReport r z)=some v) :
    SameCrossingSetting u v ∧
    (rhsFromRecords G t u ru).context=(rhsFromRecords G t v rv).context := by
  obtain ⟨ue,uc,un,ul,_,ur,_,_,_,_,ug,_⟩ :=
    StreetWholeVerified.successful_write_preserves_person_and_line G s u _ wy
  obtain ⟨ve,vc,vn,vl,_,vr,_,_,_,_,vg,_⟩ :=
    StreetWholeVerified.successful_write_preserves_person_and_line G s v _ wz
  refine ⟨⟨vc.trans uc.symm,fun x => (vg x).trans (ug x).symm,?_⟩,?_⟩
  · funext i j; simp only [margin,ue,ve,un,vn,ul,vl]
  · funext i l
    rw [WitnessVerified.original_personal_rate_uses_present_relationships,
        WitnessVerified.original_personal_rate_uses_present_relationships]
    simp only [contextDrift,contextTerm,uc,vc,ur,vr]

theorem heun_context_difference_for_a_changed_child_response
    (G : Geometry) (t h : ℝ) (s d p k e s' d' p' k' e' : State) (l : Fin 2)
    (left : FullStep G t h s d p k e) (right : FullStep G t h s' d' p' k' e')
    (ct : s.context=s'.context) (rr : s.responses=s'.responses)
    (other : ∀ j : Actor, j≠father → ∀ m : Fin 7, (m=0 ∨ m=1 ∨ m=5) →
      d.responses child j m=d'.responses child j m) :
    e.context child l-e'.context child l=h^2/10*rateContribution p d d' l := by
  have dc : d.context=d'.context := by
    funext i m
    rw [accepted_context G s d t left.first,accepted_context G s' d' t right.first]
    simp only [contextDrift,contextTerm,ct,rr]
  have pc : p.context=p'.context := by
    funext i m
    have ca : p.context i m=s.context i m+h*d.context i m := project_c left.predictor i m
    have cb : p'.context i m=s'.context i m+h*d'.context i m := project_c right.predictor i m
    rw [ca,cb,ct,dc]
  have one (j : Actor) : contextTerm p child j l-contextTerm p' child j l =
      if j=father then h*rateContribution p d d' l else 0 := by
    have L (m : Fin 7) : p.responses child j m=s.responses child j m+h*d.responses child j m :=
      project_r left.predictor child j m
    have R (m : Fin 7) : p'.responses child j m=s'.responses child j m+h*d'.responses child j m :=
      project_r right.predictor child j m
    by_cases hj : j=father
    · subst j
      simp only [ite_true,contextTerm,rateContribution,gapResidual,← pc,L,R,← rr]
      ring
    · simp only [if_neg hj,contextTerm,← pc,L,R,← rr,
        other j hj 0 (Or.inl rfl),other j hj 1 (Or.inr (Or.inl rfl)),other j hj 5 (Or.inr (Or.inr rfl)),sub_self]
  have sum : (∑ j,contextTerm p child j l)-(∑ j,contextTerm p' child j l)=h*rateContribution p d d' l := by
    rw [← Finset.sum_sub_distrib]; simp_rw [one]; simp
  have drift : k.context child l-k'.context child l=h*rateContribution p d d' l/5 := by
    rw [accepted_context G p k (t+h) left.second,accepted_context G p' k' (t+h) right.second]
    simp only [contextDrift,← pc]
    linarith
  have ea : e.context child l=s.context child l+h/2*(d.context child l+k.context child l) :=
    project_c left.endpoint child l
  have eb : e'.context child l=s'.context child l+h/2*(d'.context child l+k'.context child l) :=
    project_c right.endpoint child l
  rw [ea,eb,← ct,← dc]
  linear_combination (h/2)*drift

theorem two_coordinate_direction_of_the_next_step (p d f : State)
    (sumC : p.context child 0+p.context child 1=1)
    (sumD : p.context father 0+p.context father 1=1) :
    rateContribution p d f 0 = (p.context father 0-p.context child 0)*
      ((d.responses child father 0-f.responses child father 0)+
        (d.responses child father 1-f.responses child father 1)-
        4*p.context child 0*(1-p.context child 0)*(d.responses child father 5-f.responses child father 5)) := by
  have c₁ : p.context child 1=1-p.context child 0 := by linarith
  have d₁ : p.context father 1=1-p.context father 0 := by linarith
  simp only [rateContribution,gapResidual,Fin.sum_univ_succ]
  rw [show (Fin.succ (0 : Fin 1)) = (1 : Fin 2) by decide,c₁,d₁]
  ring

theorem a_validated_contrast_determines_only_the_stated_change (u v : Fin 2 → ℝ) (z : ℝ)
    (sameTotal : v 0+v 1=u 0+u 1) (measured : contextContrast v-contextContrast u=z) :
    v 0-u 0=z/2 ∧ v 1-u 1= -(z/2) := by
  unfold contextContrast at measured
  constructor <;> linarith

theorem a_direction_alone_admits_distinct_context_weights :
    ∃ u v w : Fin 2 → ℝ, u 0+u 1=1 ∧ v 0+v 1=1 ∧ w 0+w 1=1 ∧
      (∀ k, u k∈Set.Icc (0:ℝ) 1 ∧ v k∈Set.Icc (0:ℝ) 1 ∧ w k∈Set.Icc (0:ℝ) 1) ∧
      contextContrast u<contextContrast v ∧ contextContrast u<contextContrast w ∧ v 0≠w 0 := by
  refine ⟨![(1/2:ℝ),1/2],![(3/5:ℝ),2/5],![(3/4:ℝ),1/4],?_,?_,?_,?_,?_,?_,?_⟩
  · norm_num
  · norm_num
  · norm_num
  · intro k; fin_cases k <;> norm_num [Set.mem_Icc,Matrix.cons_val_succ]
  · norm_num [contextContrast,Matrix.cons_val_succ]
  · norm_num [contextContrast,Matrix.cons_val_succ]
  · norm_num [Matrix.cons_val_succ]

end
end HugV3.Source.AccountVerified
