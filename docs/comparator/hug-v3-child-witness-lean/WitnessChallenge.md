# How the child, father and officer enter one another’s readings

Use the declared participants and timeline to follow an officer-to-father record. Then trace how the father’s rating can influence the child through the relationship fields.

[`WitnessChallenge.lean`](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessChallenge.lean) · [Package configuration](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 NousVolition. All rights reserved. The repository notice applies to material for which NousVolition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessProofs.lean) · [WitnessDefinitions](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessDefinitions.lean) · [Statement and proof inputs](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/lake-manifest.json).

</details>

## Who is involved in each declared event, and when do they overlap?

`declared_event_roles`

**Proof request**

Verify the three scheduled origin–recipient pairs and their relative event times.

**Reading the result**

Reading the schedule gives child to father, officer to father and father to child, with the exact ordering of their endpoints.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem declared_event_roles :
    (events 0).origin=child ∧ (events 0).recipient=father ∧
    (events 1).origin=officer ∧ (events 1).recipient=father ∧
    (events 2).origin=father ∧ (events 2).recipient=child ∧
    (events 1).startTime < (events 0).endTime ∧ (events 0).endTime < (events 1).endTime ∧
    (events 1).endTime=(events 2).startTime := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessChallenge.lean#L8-L13) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessProofs.lean#L61-L67)

## Does building the record preserve who spoke to whom?

`actual_built_record_keeps_its_participants`

**Proof request**

Show that a built record inherits its event’s participants and score inputs.

**Reading the result**

A successful construction copies the event’s origin, recipient, observation and report.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem actual_built_record_keeps_its_participants (s : State) (F₀ : Particle → Mat)
    (id : Fin 3) (r : Record) (ok : makeEvent s F₀ id=some r) :
    r.origin=(events id).origin ∧ r.recipient=(events id).recipient ∧
    r.observed=(events id).observed ∧ r.report=(events id).report := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessChallenge.lean#L15-L18) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessProofs.lean#L69-L76)

## Can a bystander receive a record through direct retrieval?

`record_does_not_enter_bystander_retrieval`

**Proof request**

Prove equality of all direct retrieval channels for a bystander after adding the record.

**Reading the result**

If the actor is outside its recipient channel, adding the record leaves that actor’s exposure and retrieved values unchanged.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem record_does_not_enter_bystander_retrieval (G : Geometry) (s : State)
    (rs : List (Fin 4 × Record)) (slot : Fin 4) (r : Record) (i : Actor)
    (outside : r.recipient≠i) :
    (∀ j, exposure G s ((slot,r)::rs) i j = exposure G s rs i j) ∧
    ∀ j k, memory G s ((slot,r)::rs) i j k = memory G s rs i j k := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessChallenge.lean#L20-L24) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessProofs.lean#L78-L85)

## What can the child retrieve directly from just the first two records?

`first_two_records_have_no_child_channel`

**Proof request**

Show that the first two records give zero direct retrieval for the child.

**Reading the result**

Both are addressed to the father, so all the child’s retrieval channels evaluate to zero.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem first_two_records_have_no_child_channel (G : Geometry) (s : State)
    (r₀ r₁ : Record) (a b : Fin 4) (h₀ : r₀.recipient=father) (h₁ : r₁.recipient=father) :
    ∀ j k, memory G s [(a,r₀),(b,r₁)] child j k=0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessChallenge.lean#L26-L28) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessProofs.lean#L87-L92)

## Which equation sets a person’s current context rate?

`original_personal_rate_uses_present_relationships`

**Proof request**

Identify the original context drift inside the full rate computed from records.

**Reading the result**

The full rate projects to the defined context drift using the present state and relationships.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem original_personal_rate_uses_present_relationships (G : Geometry) (t : ℝ)
    (s : State) (rs : List (Fin 4 × Record)) (i : Actor) (k : Fin 2) :
    (rhsFromRecords G t s rs).context i k = contextDrift s t i k := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessChallenge.lean#L30-L32) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessProofs.lean#L94-L97)

## Can changing just the record list change that instantaneous context rate?

`record_scores_have_no_instant_personal_rate`

**Proof request**

Prove equality of immediate context rates for any two supplied lists at the same state.

**Reading the result**

With time and state fixed, both lists give the same context component.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem record_scores_have_no_instant_personal_rate (G : Geometry) (t : ℝ)
    (s : State) (first second : List (Fin 4 × Record)) :
    (rhsFromRecords G t s first).context = (rhsFromRecords G t s second).context := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessChallenge.lean#L34-L36) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessProofs.lean#L99-L102)

## How does the adverse incident affect the father’s recognition rate?

`adverse_record_changes_fathers_recognition_rate`

**Proof request**

Show positive adverse evidence and the reduced father-to-officer recognition rate.

**Reading the result**

Relative to its unscored version it contributes negative-channel memory and lowers the specified father–officer rate.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem adverse_record_changes_fathers_recognition_rate (G : Geometry) (s : State)
    (t y : ℝ) (old r : Record) (a b : Fin 4)
    (oldFrom : old.origin=child) (laterFrom : r.origin=officer) (laterTo : r.recipient=father)
    (duration : r.startTime<r.endTime) (scored : score r=some y) (negative : y<0) :
    0 < memory G s [(a,old),(b,r)] father officer 1 ∧
    (rhsFromRecords G t s [(a,old),(b,r)]).relation father officer 0 <
    (rhsFromRecords G t s [(a,old),(b,unscored r)]).relation father officer 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessChallenge.lean#L38-L44) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessProofs.lean#L104-L128)

## Which parts of the setting survive the comparison interventions?

`matched_tests_keep_setting`

**Proof request**

Check the stated invariants of the three matched interventions.

**Reading the result**

The rating and cooperation changes preserve the crossing setting. Changing the father’s context preserves the listed child and public readings.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem matched_tests_keep_setting (s : State) (h : ℝ) :
    SameCrossingSetting s (changeRating s father officer h) ∧
    SameCrossingSetting s (bumpCooperation s child father h) ∧
    (shiftPersonalContext s father h).context child=s.context child ∧
    (shiftPersonalContext s father h).g=s.g ∧ margin (shiftPersonalContext s father h)=margin s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessChallenge.lean#L46-L50) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessProofs.lean#L130-L138)

## How can the father’s rating enter the child’s recognition?

`fathers_rating_enters_childs_recognition`

**Proof request**

Compute the child’s recognition-input increase and prove its rate inequality.

**Reading the result**

The recognition input rises by 0.7h/6 and the monotone response gives a larger child–officer recognition rate under the stated conditions.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem fathers_rating_enters_childs_recognition (G : Geometry) (s : State) (t : ℝ)
    (rs : List (Fin 4 × Record)) (h : ℝ) (pos : 0<h) :
    recognitionInput G (changeRating s father officer h) rs child officer =
      recognitionInput G s rs child officer + 0.7*h/6 ∧
    (rhsFromRecords G t s rs).relation child officer 0 <
      (rhsFromRecords G t (changeRating s father officer h) rs).relation child officer 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessChallenge.lean#L52-L57) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessProofs.lean#L140-L170)

## Does the child’s own recognition affect cooperation?

`childs_recognition_changes_cooperation_rate`

**Proof request**

Derive increased cooperation from the specified increase in the child’s recognition.

**Reading the result**

The stipulated increase gives a strictly higher child–officer cooperation rate.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem childs_recognition_changes_cooperation_rate (G : Geometry) (s : State) (t : ℝ)
    (rs : List (Fin 4 × Record)) (h : ℝ) (pos : 0<h) (within : s.responses child officer 5≤1) :
    (rhsFromRecords G t s rs).responses child officer 1 <
      (rhsFromRecords G t (changeRating s child officer h) rs).responses child officer 1 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessChallenge.lean#L59-L62) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessProofs.lean#L172-L193)

## How much does a person’s cooperation change their context rate?

`own_cooperation_enters_context_rate`

**Proof request**

Compute the exact contribution of a cooperation increment to the personal context rate.

**Reading the result**

Its contribution is h times the partner’s context minus their own, divided by five.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem own_cooperation_enters_context_rate (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (i j : Actor) (h : ℝ) (k : Fin 2) :
    (rhsFromRecords G t (bumpCooperation s i j h) rs).context i k -
      (rhsFromRecords G t s rs).context i k = h*(s.context j k-s.context i k)/5 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessChallenge.lean#L64-L67) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessProofs.lean#L195-L211)

## How can a neighbor’s changed context enter the child’s rate?

`changed_neighbor_context_enters_child_rate`

**Proof request**

Compute the change induced by a shifted neighbor’s context.

**Reading the result**

Subtracting the two rate equations isolates the specified neighbor contribution divided by five.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem changed_neighbor_context_enters_child_rate (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (i j : Actor) (distinct : i≠j) (h : ℝ) (k : Fin 2) :
    (rhsFromRecords G t (shiftPersonalContext s j h) rs).context i k -
      (rhsFromRecords G t s rs).context i k = neighborTermChange s i j h k / 5 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessChallenge.lean#L69-L72) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessProofs.lean#L213-L229)

## What if the father’s relevant coupling to the child vanishes?

`uncoupled_neighbor_context_has_zero_effect`

**Proof request**

Show equality of the child’s rate when the relevant neighbor coupling vanishes.

**Reading the result**

Under those zero-coupling hypotheses the neighbor perturbation has zero effect on this rate.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem uncoupled_neighbor_context_has_zero_effect (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (h : ℝ) (k : Fin 2)
    (noImitation : s.responses child father 0=0) (noCooperation : s.responses child father 1=0)
    (noWithdrawal : s.responses child father 5=0) :
    (rhsFromRecords G t (shiftPersonalContext s father h) rs).context child k =
      (rhsFromRecords G t s rs).context child k := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessChallenge.lean#L74-L79) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessProofs.lean#L231-L239)

## What is the effect in the declared initial example?

`declared_context_response_example`

**Proof request**

Evaluate the declared initial example and obtain −3h/20.

**Reading the result**

At time zero with empty records the child’s first context-rate difference is −3h/20.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem declared_context_response_example (G : Geometry) (h : ℝ) :
    (rhsFromRecords G 0 (bumpCooperation (initial G) child father h) []).context child 0 -
      (rhsFromRecords G 0 (initial G) []).context child 0 = -(3/20)*h := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessChallenge.lean#L81-L83) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessProofs.lean#L241-L246)

## Can changing the child’s context alter the relevance of an old record?

`an_eligible_old_record_can_be_reweighted`

**Proof request**

Show that the same eligible old record still decodes after the context shift and has a strictly smaller positive retrieval weight.

**Reading the result**

Under the stated cue and duration conditions the same eligible record still decodes, while its weight becomes smaller and stays positive.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem an_eligible_old_record_can_be_reweighted (G : Geometry) (s : State)
    (old : Record) (rs : List (Fin 4 × Record)) (a : Fin 4) (now h : ℝ)
    (hr : readRecords s=some rs) (stored : (a,old)∈rs) (earlier : old.endTime≤now)
    (addressed : old.recipient=child) (distinct : old.recipient≠old.origin)
    (matched : ∀ k, cueDifference G s old k=0) (duration : old.startTime<old.endTime) (moved : h≠0) :
    readRecords (shiftPersonalContext s child h)=some rs ∧
    (a,old)∈rs ∧ old.endTime≤now ∧
    0 < recordWeight G (shiftPersonalContext s child h) old ∧
      recordWeight G (shiftPersonalContext s child h) old < recordWeight G s old := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessChallenge.lean#L85-L93) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessProofs.lean#L248-L260)

## Do accepted checkpoints preserve the person and the public setting at the jump?

`all_accepted_checkpoints_keep_person_and_setting`

**Proof request**

Prove that an accepted checkpoint preserves the defined crossing setting.

**Reading the result**

The defined crossing-setting fields agree on the two sides of every accepted boundary.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem all_accepted_checkpoints_keep_person_and_setting (n : ℕ) (s w : FullState)
    (accepted : boundary n s=some w) : SameCrossingSetting s.state w.state := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessChallenge.lean#L95-L96) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessProofs.lean#L262-L273)

## Is the context drift really the derivative along a solving trace?

`actual_trace_context_rate`

**Proof request**

Identify the derivative of a personal context coordinate along a solving trace.

**Reading the result**

Applying the trace derivative to that context coordinate gives exactly the stated drift within the segment.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem actual_trace_context_rate (tr : Trace) (sol : Solves tr) (n : ℕ) (hn : n<5)
    (t : ℝ) (ht : t ∈ Icc (time n) (time (n+1))) (i : Actor) (k : Fin 2) :
    HasDerivWithinAt (fun u => (tr.path n u).state.context i k)
      (contextDrift (tr.path n t).state t i k) (Icc (time n) (time (n+1))) t := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessChallenge.lean#L98-L101) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessProofs.lean#L275-L287)

## Can the child’s context jump when a trace crosses its event boundary?

`actual_trace_has_no_checkpoint_jump_in_context`

**Proof request**

Prove continuity across the jump for the fields in the crossing setting.

**Reading the result**

The pre-boundary endpoint and post-boundary state have the same crossing-setting fields.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem actual_trace_has_no_checkpoint_jump_in_context (tr : Trace) (sol : Solves tr)
    (n : ℕ) (hn : n<5) :
    SameCrossingSetting (tr.path n (time (n+1))).state (tr.after (n+1)).state := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessChallenge.lean#L103-L105) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessProofs.lean#L289-L292)

## Does a nonzero context rate have a visible later consequence?

`nonzero_rate_entails_a_later_change`

**Proof request**

Deduce a later unequal context value from a nonzero derivative on the specified segment.

**Reading the result**

The within-segment derivative and the stated positive observation window imply a later point with a different coordinate.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem nonzero_rate_entails_a_later_change (tr : Trace) (sol : Solves tr)
    (n : ℕ) (hn : n<5) (t : ℝ) (left : time n≤t) (i : Actor) (k : Fin 2)
    (moving : contextDrift (tr.path n t).state t i k ≠ 0)
    (u : ℝ) (future : t<u) (limit : u≤time (n+1)) :
    ∃ v ∈ Ioc t u, (tr.path n v).state.context i k ≠ (tr.path n t).state.context i k := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessChallenge.lean#L107-L111) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessProofs.lean#L294-L311)

## Can personal contexts diverge while public histories still match?

`distinct_personal_rates_with_same_public_history`

**Proof request**

Exhibit a later difference of personal contexts alongside equal public readings.

**Reading the result**

With the stated rate difference and public-history assumptions, a later time has different personal coordinates and the same public field and margin.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem distinct_personal_rates_with_same_public_history (G : Geometry)
    (z w : ℝ → State) (a b : ℝ) (hab : a<b) (i : Actor) (k : Fin 2)
    (nativeZ : ∀ t ∈ Icc a b, ∃ d, rhs G t (z t)=some d ∧ StateHasDerivWithinAt z d (Icc a b) t)
    (nativeW : ∀ t ∈ Icc a b, ∃ d, rhs G t (w t)=some d ∧ StateHasDerivWithinAt w d (Icc a b) t)
    (publicSame : ∀ t ∈ Icc a b, (∀ x, (z t).g x 3=(w t).g x 3) ∧ margin (z t)=margin (w t))
    (start : (z a).context i k=(w a).context i k)
    (rates : contextDrift (z a) a i k ≠ contextDrift (w a) a i k) :
    ∃ t ∈ Ioc a b, (z t).context i k≠(w t).context i k ∧
      (∀ x, (z t).g x 3=(w t).g x 3) ∧ margin (z t)=margin (w t) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessChallenge.lean#L113-L121) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-child-witness-lean/WitnessProofs.lean#L313-L346)
