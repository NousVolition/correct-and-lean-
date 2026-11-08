import AccountDefinitions

namespace HugV3.Source.AccountVerified
noncomputable section
open ChildAccount ChildAccess Witness Transfer

theorem account_without_separate_rating_preserves_input (a : Account) (r : Record)
    (right : eligible a r) (noRating : a.evaluation=none) : inputRecord a r=some r := by sorry

theorem attributed_current_rating_uses_only_report_field (a : Account) (r : Record)
    (v : Evaluation) (right : eligible a r) (rated : a.evaluation=some v)
    (current : v.aboutEncounter=2) (valid : -1≤v.value ∧ v.value≤1) :
    inputRecord a r=some {r with report:=some v.value} := by sorry

theorem crossing_reference_and_current_rating_have_distinct_targets (a : Account) (r : Record)
    (v : Evaluation) (rated : a.evaluation=some v) :
    (¬eligible a r → inputRecord a r=none) ∧
    (v.aboutEncounter≠2 → inputRecord a r=none) ∧
    (¬(-1≤v.value ∧ v.value≤1) → inputRecord a r=none) := by sorry

theorem words_and_direct_sight_do_not_choose_a_number (a : Account) (r : Record)
    (words : String) (access : DirectAccess) :
    inputRecord {a with wording:=words,access:=access} r=inputRecord a r := by sorry

theorem declared_third_record_is_childs_later_report (s : State) (F₀ : Particle → Mat)
    (r : Record) (ok : makeEvent s F₀ 2=some r) :
    r.origin=father ∧ r.recipient=child ∧ r.observed=none ∧ r.report=some (1/5:ℝ) := by sorry

theorem score_uses_independent_observation_only_when_present (r : Record) (y v : ℝ) :
    score {r with observed:=none,report:=some y}=some y ∧
    score {r with observed:=some v,report:=some y}=some ((v+y)/2) ∧
    score {r with observed:=some v,report:=none}=some v ∧
    score {r with observed:=none,report:=none}=none := by sorry

theorem private_report_enters_signed_retrieval (G : Geometry) (s : State)
    (old incident r : Record) (y : ℝ) (to₀ : old.recipient=father) (to₁ : incident.recipient=father)
    (fromDad : r.origin=father) (toChild : r.recipient=child) (independent : r.observed=none) :
    exposure G s (panel old incident r (some y)) child father=recordWeight G s r ∧
    memory G s (panel old incident r (some y)) child father 0 -
      memory G s (panel old incident r (some y)) child father 1 = historyFraction G s r*y := by sorry

theorem neutral_report_and_missing_report_are_distinguishable (G : Geometry) (s : State)
    (old incident r : Record) (to₀ : old.recipient=father) (to₁ : incident.recipient=father)
    (fromDad : r.origin=father) (toChild : r.recipient=child) (independent : r.observed=none)
    (duration : r.startTime<r.endTime) :
    exposure G s (panel old incident r none) child father=0 ∧
    0<exposure G s (panel old incident r (some 0)) child father ∧
    memory G s (panel old incident r (some 0)) child father 0-
      memory G s (panel old incident r (some 0)) child father 1=0 := by sorry

theorem rating_changes_three_response_rates (G : Geometry) (s : State) (t low high : ℝ)
    (old incident r : Record) (to₀ : old.recipient=father) (to₁ : incident.recipient=father)
    (fromDad : r.origin=father) (toChild : r.recipient=child) (independent : r.observed=none)
    (duration : r.startTime<r.endTime) (present : 0<attention s child father) (order : low<high) :
    let d := rhsFromRecords G t s (panel old incident r (some low))
    let e := rhsFromRecords G t s (panel old incident r (some high))
    d.responses child father 0<e.responses child father 0 ∧
    d.responses child father 1<e.responses child father 1 ∧
    e.responses child father 5<d.responses child father 5 ∧ d.context=e.context := by sorry

theorem accepted_report_writes_preserve_immediate_context_and_agreement
    (G : Geometry) (s u v : State) (r : Record) (y z : Option ℝ) (t : ℝ)
    (ru rv : List (Fin 4 × Record))
    (wy : writeEvent G s (setReport r y)=some u) (wz : writeEvent G s (setReport r z)=some v) :
    SameCrossingSetting u v ∧
    (rhsFromRecords G t u ru).context=(rhsFromRecords G t v rv).context := by sorry

theorem heun_context_difference_for_a_changed_child_response
    (G : Geometry) (t h : ℝ) (s d p k e s' d' p' k' e' : State) (l : Fin 2)
    (left : FullStep G t h s d p k e) (right : FullStep G t h s' d' p' k' e')
    (ct : s.context=s'.context) (rr : s.responses=s'.responses)
    (other : ∀ j : Actor, j≠father → ∀ m : Fin 7, (m=0 ∨ m=1 ∨ m=5) →
      d.responses child j m=d'.responses child j m) :
    e.context child l-e'.context child l=h^2/10*rateContribution p d d' l := by sorry

theorem two_coordinate_direction_of_the_next_step (p d f : State)
    (sumC : p.context child 0+p.context child 1=1)
    (sumD : p.context father 0+p.context father 1=1) :
    rateContribution p d f 0 = (p.context father 0-p.context child 0)*
      ((d.responses child father 0-f.responses child father 0)+
        (d.responses child father 1-f.responses child father 1)-
        4*p.context child 0*(1-p.context child 0)*(d.responses child father 5-f.responses child father 5)) := by sorry

theorem a_validated_contrast_determines_only_the_stated_change (u v : Fin 2 → ℝ) (z : ℝ)
    (sameTotal : v 0+v 1=u 0+u 1) (measured : contextContrast v-contextContrast u=z) :
    v 0-u 0=z/2 ∧ v 1-u 1= -(z/2) := by sorry

theorem a_direction_alone_admits_distinct_context_weights :
    ∃ u v w : Fin 2 → ℝ, u 0+u 1=1 ∧ v 0+v 1=1 ∧ w 0+w 1=1 ∧
      (∀ k, u k∈Set.Icc (0:ℝ) 1 ∧ v k∈Set.Icc (0:ℝ) 1 ∧ w k∈Set.Icc (0:ℝ) 1) ∧
      contextContrast u<contextContrast v ∧ contextContrast u<contextContrast w ∧ v 0≠w 0 := by sorry

end
end HugV3.Source.AccountVerified
