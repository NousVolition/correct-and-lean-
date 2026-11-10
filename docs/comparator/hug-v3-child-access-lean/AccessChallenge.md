# Could the child have seen the crossing?

Pair two diaries with one native trace. Determine what the stored events say about direct access, reporting and the child’s response to cooperation.

[`AccessChallenge.lean`](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessChallenge.lean) · [Package configuration](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 Nous Volition. All rights reserved. The repository notice applies to material for which Nous Volition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessProofs.lean) · [AccessDefinitions](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessDefinitions.lean) · [Statement and proof inputs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/lake-manifest.json).

</details>

## When do the child’s two possible diaries first differ?

`paired_diaries_on_the_timeline`

**Proof request**

Compare the seeing and missing diaries before and after the incident ends.

**Reading the result**

Before the incident ends they agree. Thereafter the seeing diary includes both public occurrences and the missing diary includes only the first.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem paired_diaries_on_the_timeline :
    (∀ t, t < (events 1).endTime → diary .sees t=diary .misses t) ∧
    (∀ t, (events 1).endTime≤t →
      diary .sees t=[publicOccurrence 0,publicOccurrence 1] ∧
      diary .misses t=[publicOccurrence 0]) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessChallenge.lean#L7-L11) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessProofs.lean#L25-L36)

## Does choosing either diary restrict the native model’s possible traces?

`native_trace_set_for_either_diary`

**Proof request**

Prove that each diary arm admits exactly the native solving traces.

**Reading the result**

In each arm the compatible traces are exactly those that solve the original system.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem native_trace_set_for_either_diary (arm : DirectAccess) :
    {tr : Trace | ∃ log, fits arm tr log}={tr : Trace | Solves tr} := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessChallenge.lean#L13-L14) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessProofs.lean#L38-L45)

## Can the native history determine whether the child saw the incident?

`native_history_cannot_identify_direct_access`

**Proof request**

Rule out recovering both direct-access labels from the same native trace.

**Reading the result**

The same solving trace fits both access labels, so one reader of that trace cannot recover both.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem native_history_cannot_identify_direct_access (tr : Trace) (sol : Solves tr) :
    ¬ ∃ readAccess : Trace → DirectAccess,
       ∀ arm log, fits arm tr log → readAccess tr=arm := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessChallenge.lean#L16-L18) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessProofs.lean#L47-L53)

## Whose channel actually carries the incident score?

`actual_incident_stays_scored_for_dad`

**Proof request**

Compute the constructed incident record’s endpoints and score.

**Reading the result**

The built officer-to-father record has score −3/5.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem actual_incident_stays_scored_for_dad (s : State) (F₀ : Particle → Mat) (r : Record)
    (ok : makeEvent s F₀ 1=some r) :
    r.origin=officer ∧ r.recipient=father ∧ score r=some (-(3/5):ℝ) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessChallenge.lean#L20-L22) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessProofs.lean#L55-L60)

## Does the incident record list an event still in progress as a predecessor?

`incident_record_excludes_unfinished_predecessor`

**Proof request**

Show that the incident’s predecessor mask is zero.

**Reading the result**

Its predecessor mask is zero because the timing rule counts only finished predecessors.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem incident_record_excludes_unfinished_predecessor (s : State) (F₀ : Particle → Mat)
    (r₀ r : Record) (slot : Fin 4) (decoded : readRecords s=some [(slot,r₀)])
    (end₀ : r₀.endTime=(events 0).endTime) (ok : makeEvent s F₀ 1=some r) :
    r.predecessors=0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessChallenge.lean#L24-L27) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessProofs.lean#L62-L69)

## Which earlier events does the father’s later account link?

`later_record_to_child_links_both_earlier_events`

**Proof request**

Compute the later child-directed record’s endpoints, predecessor bits and report.

**Reading the result**

Its predecessor mask is three, selecting both earlier events, and its report to the child is 1/5.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem later_record_to_child_links_both_earlier_events (s : State) (F₀ : Particle → Mat)
    (r₀ r₁ r : Record) (a b : Fin 4) (decoded : readRecords s=some [(a,r₀),(b,r₁)])
    (id₀ : r₀.eventID=0) (id₁ : r₁.eventID=1)
    (end₀ : r₀.endTime=(events 0).endTime) (end₁ : r₁.endTime=(events 1).endTime)
    (ok : makeEvent s F₀ 2=some r) :
    r.origin=father ∧ r.recipient=child ∧ r.predecessors=3 ∧ r.report=some (1/5:ℝ) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessChallenge.lean#L29-L34) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessProofs.lean#L71-L86)

## Can editing predecessor bits directly change retrieval?

`predecessor_bits_do_not_drive_direct_retrieval`

**Proof request**

Prove that changing predecessor bits preserves direct scoring, weighting, exposure and retrieval.

**Reading the result**

Score, weight, exposure and every retrieved channel use other fields, so those readings agree for any replacement mask.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem predecessor_bits_do_not_drive_direct_retrieval (G : Geometry) (s : State)
    (r : Record) (bits : ℤ) (slot : Fin 4) (rs : List (Fin 4 × Record)) :
    score {r with predecessors:=bits}=score r ∧
    recordWeight G s {r with predecessors:=bits}=recordWeight G s r ∧
    (∀ i j, exposure G s ((slot,{r with predecessors:=bits})::rs) i j=
       exposure G s ((slot,r)::rs) i j) ∧
    ∀ i j k, memory G s ((slot,{r with predecessors:=bits})::rs) i j k=
       memory G s ((slot,r)::rs) i j k := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessChallenge.lean#L36-L43) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessProofs.lean#L88-L96)

## Do the two earlier records enter the child’s own retrieval channels?

`earlier_dad_records_still_outside_child_channel`

**Proof request**

Reduce the child’s three-record retrieval to its later addressed record.

**Reading the result**

With the stated participants, filtering by recipient leaves the same result as the third record alone.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem earlier_dad_records_still_outside_child_channel (G : Geometry) (s : State)
    (r₀ r₁ r₂ : Record) (a b c : Fin 4)
    (to₀ : r₀.recipient=father) (to₁ : r₁.recipient=father) :
    ∀ j k, memory G s [(a,r₀),(b,r₁),(c,r₂)] child j k=
      memory G s [(c,r₂)] child j k := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessChallenge.lean#L45-L49) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessProofs.lean#L98-L107)

## When does the crossing comparison remain unassessed?

`missing_or_wrong_crossing_is_unassessed`

**Proof request**

Identify the specified missing or reference-mismatched comparisons that yield no assessment.

**Reading the result**

A missing report or the specified wrong reference makes the comparison return no result.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem missing_or_wrong_crossing_is_unassessed (p q r : CrossingReport) :
    contrast none (some q) (some r)=none ∧ contrast (some p) none (some r)=none ∧
    contrast (some p) (some q) none=none ∧
    (q.reference≠0 → contrast (some p) (some q) (some r)=none) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessChallenge.lean#L51-L54) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessProofs.lean#L109-L115)

## Does knowing who saw the crossing determine the reports?

`observed_access_allows_different_report_patterns`

**Proof request**

Exhibit the three report contrasts compatible with the matched access diaries.

**Reading the result**

The same native trace fits both diaries, and the explicit reports yield three different contrast patterns.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem observed_access_allows_different_report_patterns (tr : Trace) (sol : Solves tr) :
    fits .sees tr (diary .sees) ∧ fits .misses tr (diary .misses) ∧
    contrast (some (report .simpleCrossing)) (some (report .simpleCrossing))
      (some (report .simpleCrossing))=some ⟨false,false,false⟩ ∧
    contrast (some (report .simpleCrossing)) (some (report .fathersSafety))
      (some (report .simpleCrossing))=some ⟨true,false,true⟩ ∧
    contrast (some (report .simpleCrossing)) (some (report .fathersSafety))
      (some (report .yardRule))=some ⟨true,true,true⟩ := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessChallenge.lean#L56-L63) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessProofs.lean#L117-L125)

## Can one personal context support two different validated readings under the stated rules?

`different_validated_readings_require_different_personal_contexts`

**Proof request**

Derive different personal contexts from the distinct validated readings.

**Reading the result**

Their different validated values force the two personal contexts to differ.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem different_validated_readings_require_different_personal_contexts
    (decode : (Fin 2 → ℝ) → Formulation) (seen missed : Fin 2 → ℝ)
    (a b : Formulation) (hs : decode seen=a) (hm : decode missed=b) (different : a≠b) :
    seen≠missed := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessChallenge.lean#L65-L68) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessProofs.lean#L127-L132)

## How much does changing cooperation alter the child’s context rate?

`conditional_response_difference_uses_original_c_rate`

**Proof request**

Prove preservation of the setting and decoded records and compute the conditional context-rate difference.

**Reading the result**

Holding the crossing and records fixed leaves the exact change h times the father–child context gap divided by five.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem conditional_response_difference_uses_original_c_rate
    (G : Geometry) (s d e : State) (t h : ℝ) (k : Fin 2)
    (base : rhs G t s=some d) (change : rhs G t (bumpCooperation s child father h)=some e) :
    SameCrossingSetting s (bumpCooperation s child father h) ∧
    readRecords (bumpCooperation s child father h)=readRecords s ∧
    e.context child k-d.context child k=h*(s.context father k-s.context child k)/5 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessChallenge.lean#L70-L75) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessProofs.lean#L134-L148)

## Can that rate change have either sign?

`conditional_increment_can_be_zero_or_have_either_sign`

**Proof request**

Exhibit lower, equal and higher context rates under the stated admissible cooperation increments.

**Reading the result**

With the given positive gap and admissible room around the response, opposite increments bracket the original rate and zero increment recovers it.

<details>
<summary>Exact Lean statement</summary>

```lean
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
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessChallenge.lean#L77-L88) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-access-lean/AccessProofs.lean#L150-L174)
