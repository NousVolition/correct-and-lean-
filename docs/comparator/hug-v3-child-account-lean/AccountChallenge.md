# How an attributed report enters the child’s account

Follow a separately supplied rating from its encounter record into retrieval and later response. A missing rating and a reported zero have different consequences.

[`AccountChallenge.lean`](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountChallenge.lean) · [Package configuration](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 Nous Volition. All rights reserved. The repository notice applies to material for which Nous Volition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountProofs.lean) · [AccountDefinitions](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountDefinitions.lean) · [Statement and proof inputs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/lake-manifest.json).

</details>

## What if someone gives an eligible account without a separate rating?

`account_without_separate_rating_preserves_input`

**Proof request**

Recover the original eligible record when no separate rating is supplied.

**Reading the result**

The input rule returns the original record intact.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem account_without_separate_rating_preserves_input (a : Account) (r : Record)
    (right : eligible a r) (noRating : a.evaluation=none) : inputRecord a r=some r := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountChallenge.lean#L7-L8) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountProofs.lean#L61-L63)

## Where does an eligible attributed rating go?

`attributed_current_rating_uses_only_report_field`

**Proof request**

Show that the admissible attributed rating replaces only the report field.

**Reading the result**

A valid rating about the current encounter replaces the report field with its supplied value.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem attributed_current_rating_uses_only_report_field (a : Account) (r : Record)
    (v : Evaluation) (right : eligible a r) (rated : a.evaluation=some v)
    (current : v.aboutEncounter=2) (valid : -1≤v.value ∧ v.value≤1) :
    inputRecord a r=some {r with report:=some v.value} := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountChallenge.lean#L10-L13) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountProofs.lean#L65-L69)

## What makes a proposed rating ineligible?

`crossing_reference_and_current_rating_have_distinct_targets`

**Proof request**

Derive each stated rejection from eligibility, encounter identity or range failure.

**Reading the result**

A mismatched account, a rating about the wrong encounter, or a value outside [−1,1] causes rejection in the stated cases.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem crossing_reference_and_current_rating_have_distinct_targets (a : Account) (r : Record)
    (v : Evaluation) (rated : a.evaluation=some v) :
    (¬eligible a r → inputRecord a r=none) ∧
    (v.aboutEncounter≠2 → inputRecord a r=none) ∧
    (¬(-1≤v.value ∧ v.value≤1) → inputRecord a r=none) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountChallenge.lean#L15-L19) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountProofs.lean#L71-L84)

## Can wording or direct sight alone pick the numerical rating?

`words_and_direct_sight_do_not_choose_a_number`

**Proof request**

Prove input-record invariance under changes of wording and direct-access label.

**Reading the result**

Replacing either field gives the same input record because the rating comes from a separate field.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem words_and_direct_sight_do_not_choose_a_number (a : Account) (r : Record)
    (words : String) (access : DirectAccess) :
    inputRecord {a with wording:=words,access:=access} r=inputRecord a r := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountChallenge.lean#L21-L23) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountProofs.lean#L86-L89)

## What does the third built record actually contain?

`declared_third_record_is_childs_later_report`

**Proof request**

Identify the participants and the two score sources of the third built record.

**Reading the result**

It runs from father to child, with a report of 1/5 and no independent observation.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem declared_third_record_is_childs_later_report (s : State) (F₀ : Particle → Mat)
    (r : Record) (ok : makeEvent s F₀ 2=some r) :
    r.origin=father ∧ r.recipient=child ∧ r.observed=none ∧ r.report=some (1/5:ℝ) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountChallenge.lean#L25-L27) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountProofs.lean#L91-L97)

## How are observation and report combined?

`score_uses_independent_observation_only_when_present`

**Proof request**

Evaluate score in all four observation-and-report cases.

**Reading the result**

One present value supplies the score, two are averaged, and with both missing the score is absent.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem score_uses_independent_observation_only_when_present (r : Record) (y v : ℝ) :
    score {r with observed:=none,report:=some y}=some y ∧
    score {r with observed:=some v,report:=some y}=some ((v+y)/2) ∧
    score {r with observed:=some v,report:=none}=some v ∧
    score {r with observed:=none,report:=none}=none := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountChallenge.lean#L29-L33) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountProofs.lean#L99-L104)

## How does the child’s private report enter signed retrieval?

`private_report_enters_signed_retrieval`

**Proof request**

Derive the child’s exposure and signed retrieval for the eligible private report.

**Reading the result**

The selected record contributes its weight to exposure, and the difference of the two signed channels is the report times its history fraction.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem private_report_enters_signed_retrieval (G : Geometry) (s : State)
    (old incident r : Record) (y : ℝ) (to₀ : old.recipient=father) (to₁ : incident.recipient=father)
    (fromDad : r.origin=father) (toChild : r.recipient=child) (independent : r.observed=none) :
    exposure G s (panel old incident r (some y)) child father=recordWeight G s r ∧
    memory G s (panel old incident r (some y)) child father 0 -
      memory G s (panel old incident r (some y)) child father 1 = historyFraction G s r*y := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountChallenge.lean#L35-L40) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountProofs.lean#L106-L130)

## Can a neutral report be told apart from a missing one?

`neutral_report_and_missing_report_are_distinguishable`

**Proof request**

Distinguish zero exposure from positive exposure with zero signed retrieval.

**Reading the result**

The neutral report produces positive exposure with zero signed retrieval. Missing the report gives zero exposure in this panel.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem neutral_report_and_missing_report_are_distinguishable (G : Geometry) (s : State)
    (old incident r : Record) (to₀ : old.recipient=father) (to₁ : incident.recipient=father)
    (fromDad : r.origin=father) (toChild : r.recipient=child) (independent : r.observed=none)
    (duration : r.startTime<r.endTime) :
    exposure G s (panel old incident r none) child father=0 ∧
    0<exposure G s (panel old incident r (some 0)) child father ∧
    memory G s (panel old incident r (some 0)) child father 0-
      memory G s (panel old incident r (some 0)) child father 1=0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountChallenge.lean#L42-L49) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountProofs.lean#L132-L145)

## Which immediate rates move with the rating?

`rating_changes_three_response_rates`

**Proof request**

Compare the three affected response rates and establish equality of the immediate context rates.

**Reading the result**

In the matched comparison, raising it increases response rates zero and one and decreases rate five. The immediate context rates agree.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem rating_changes_three_response_rates (G : Geometry) (s : State) (t low high : ℝ)
    (old incident r : Record) (to₀ : old.recipient=father) (to₁ : incident.recipient=father)
    (fromDad : r.origin=father) (toChild : r.recipient=child) (independent : r.observed=none)
    (duration : r.startTime<r.endTime) (present : 0<attention s child father) (order : low<high) :
    let d := rhsFromRecords G t s (panel old incident r (some low))
    let e := rhsFromRecords G t s (panel old incident r (some high))
    d.responses child father 0<e.responses child father 0 ∧
    d.responses child father 1<e.responses child father 1 ∧
    e.responses child father 5<d.responses child father 5 ∧ d.context=e.context := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountChallenge.lean#L51-L59) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountProofs.lean#L147-L174)

## Do two accepted report writes make context diverge immediately?

`accepted_report_writes_preserve_immediate_context_and_agreement`

**Proof request**

Prove equal crossing settings and immediate context rates across the accepted report writes.

**Reading the result**

The stated writes preserve the shared crossing setting and produce equal immediate context rates.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem accepted_report_writes_preserve_immediate_context_and_agreement
    (G : Geometry) (s u v : State) (r : Record) (y z : Option ℝ) (t : ℝ)
    (ru rv : List (Fin 4 × Record))
    (wy : writeEvent G s (setReport r y)=some u) (wz : writeEvent G s (setReport r z)=some v) :
    SameCrossingSetting u v ∧
    (rhsFromRecords G t u ru).context=(rhsFromRecords G t v rv).context := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountChallenge.lean#L61-L66) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountProofs.lean#L176-L191)

## Where does a changed response enter the next Heun context step?

`heun_context_difference_for_a_changed_child_response`

**Proof request**

Derive the h²/10 contribution to the matched Heun context difference.

**Reading the result**

Under the matched-stage hypotheses the difference is h²/10 times the specified response contribution.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem heun_context_difference_for_a_changed_child_response
    (G : Geometry) (t h : ℝ) (s d p k e s' d' p' k' e' : State) (l : Fin 2)
    (left : FullStep G t h s d p k e) (right : FullStep G t h s' d' p' k' e')
    (ct : s.context=s'.context) (rr : s.responses=s'.responses)
    (other : ∀ j : Actor, j≠father → ∀ m : Fin 7, (m=0 ∨ m=1 ∨ m=5) →
      d.responses child j m=d'.responses child j m) :
    e.context child l-e'.context child l=h^2/10*rateContribution p d d' l := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountChallenge.lean#L68-L74) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountProofs.lean#L193-L232)

## Which response differences set the direction in a two-coordinate context?

`two_coordinate_direction_of_the_next_step`

**Proof request**

Expand the first coordinate of the specified next-step contribution.

**Reading the result**

The formula multiplies the father–child context gap by the displayed combination of changes in responses zero, one and five.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem two_coordinate_direction_of_the_next_step (p d f : State)
    (sumC : p.context child 0+p.context child 1=1)
    (sumD : p.context father 0+p.context father 1=1) :
    rateContribution p d f 0 = (p.context father 0-p.context child 0)*
      ((d.responses child father 0-f.responses child father 0)+
        (d.responses child father 1-f.responses child father 1)-
        4*p.context child 0*(1-p.context child 0)*(d.responses child father 5-f.responses child father 5)) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountChallenge.lean#L76-L82) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountProofs.lean#L234-L245)

## What coordinate changes follow from a validated contrast of size z?

`a_validated_contrast_determines_only_the_stated_change`

**Proof request**

Recover both coordinate increments from a fixed total and contrast change z.

**Reading the result**

The normalization and contrast give +z/2 in the first coordinate and −z/2 in the second.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem a_validated_contrast_determines_only_the_stated_change (u v : Fin 2 → ℝ) (z : ℝ)
    (sameTotal : v 0+v 1=u 0+u 1) (measured : contextContrast v-contextContrast u=z) :
    v 0-u 0=z/2 ∧ v 1-u 1= -(z/2) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountChallenge.lean#L84-L86) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountProofs.lean#L247-L251)

## Can knowing the direction of change fix both context weights?

`a_direction_alone_admits_distinct_context_weights`

**Proof request**

Construct two different admissible context changes with the same direction of contrast.

**Reading the result**

Two admissible endpoints both increase the contrast from one start and have different first coordinates.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem a_direction_alone_admits_distinct_context_weights :
    ∃ u v w : Fin 2 → ℝ, u 0+u 1=1 ∧ v 0+v 1=1 ∧ w 0+w 1=1 ∧
      (∀ k, u k∈Set.Icc (0:ℝ) 1 ∧ v k∈Set.Icc (0:ℝ) 1 ∧ w k∈Set.Icc (0:ℝ) 1) ∧
      contextContrast u<contextContrast v ∧ contextContrast u<contextContrast w ∧ v 0≠w 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountChallenge.lean#L88-L91) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-account-lean/AccountProofs.lean#L253-L264)
