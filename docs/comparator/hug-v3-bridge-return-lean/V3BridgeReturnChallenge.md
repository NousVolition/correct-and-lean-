# What survives a return to the same destination?

Separate a person’s observable destination, accumulated write work and a record’s changing relevance. Each can be read directly from a different part of the state.

[`V3BridgeReturnChallenge.lean`](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnChallenge.lean) · [Package configuration](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 NousVolition. All rights reserved. The repository notice applies to material for which NousVolition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnProofs.lean) · [V3BridgeReturnDefinitions](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnDefinitions.lean) · [Statement and proof inputs](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/lake-manifest.json).

</details>

## Which personal and group fields survive a successful write?

`write_preserves_person_group_state`

**Proof request**

Show that the social snapshot survives a successful event write.

**Reading the result**

Reading the social snapshot before and after gives the same values.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem write_preserves_person_group_state (G : Geometry) (s w : State) (r : Record)
    (hw : writeEvent G s r=some w) : socialSnapshot w=socialSnapshot s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnChallenge.lean#L8-L9) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnProofs.lean#L38-L42)

## Does writing a record change the source accumulator?

`write_preserves_source_accumulator`

**Proof request**

Show that a successful write preserves the source accumulator.

**Reading the result**

The write updates other fields and preserves A.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem write_preserves_source_accumulator (G : Geometry) (s w : State) (r : Record)
    (hw : writeEvent G s r=some w) : w.A=s.A := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnChallenge.lean#L11-L12) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnProofs.lean#L44-L48)

## Can accumulated write work decrease on acceptance?

`write_work_nondecreasing`

**Proof request**

Prove monotonicity of accumulated write work across a successful write.

**Reading the result**

The acceptance check requires nonnegative work, which is added to the previous total.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem write_work_nondecreasing (G : Geometry) (s w : State) (r : Record)
    (hw : writeEvent G s r=some w) : s.writeWork≤w.writeWork := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnChallenge.lean#L14-L15) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnProofs.lean#L50-L55)

## Can the observer still recognize the same destination after a write?

`write_preserves_destination`

**Proof request**

Transport the stated destination observation across the write.

**Reading the result**

Under the specified observation rule, the preserved snapshot gives the same destination.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem write_preserves_destination {Ω : Type} (observe : SocialSnapshot → Ω)
    (O : Ω) (G : Geometry) (s w : State) (r : Record)
    (hw : writeEvent G s r=some w) (ho : AtO observe O s) :
    AtO observe O w := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnChallenge.lean#L17-L20) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnProofs.lean#L57-L61)

## Can you return to the same observed destination in a different state?

`same_destination_with_new_residue`

**Proof request**

Prove equal destination observations and different full states under strictly increased write work.

**Reading the result**

A strict increase in write work distinguishes the states even when the observation agrees.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem same_destination_with_new_residue {Ω : Type} (observe : SocialSnapshot → Ω)
    (O : Ω) (G : Geometry) (s w : State) (r : Record)
    (hw : writeEvent G s r=some w) (ho : AtO observe O s)
    (hwork : s.writeWork<w.writeWork) : AtO observe O w ∧ w≠s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnChallenge.lean#L22-L25) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnProofs.lean#L63-L70)

## Can a new write erase bytes in an already occupied slot?

`successful_write_retains_occupied_slot_bytes`

**Proof request**

Show that a successful write preserves the bytes in the occupied slot.

**Reading the result**

An accepted write fills a free slot and preserves the bytes of the specified occupied slot.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem successful_write_retains_occupied_slot_bytes (G : Geometry) (s w : State)
    (r : Record) (rs : List (Fin 4 × Record)) (old : Fin 4) (stored : Record)
    (hr : readRecords s=some rs) (hm : (old,stored)∈rs)
    (hw : writeEvent G s r=some w) : slotBytes w old=slotBytes s old := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnChallenge.lean#L27-L30) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnProofs.lean#L92-L107)

## Can the decoded record list drift between writes on a solving trace?

`full_trace_retains_records_between_writes`

**Proof request**

Prove constant decoded records along each stipulated inter-write segment.

**Reading the result**

Under the stated trace conditions each segment reads exactly the list at its starting checkpoint.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_trace_retains_records_between_writes (tr : Trace) (hsol : Solves tr) :
    ∀ k<5, ∀ t ∈ Icc (time k) (time (k+1)),
      readRecords (tr.path k t).state=readRecords (tr.after k).state := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnChallenge.lean#L32-L34) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnProofs.lean#L109-L112)

## What keeps the fabric memory buffer durable across the schedule?

`conditional_fabric_durability_through_full_trace`

**Proof request**

Propagate the fabric buffer through the given full trace under its stated bounds.

**Reading the result**

The segment bounds preserve its margins and the accepted boundaries carry them to successive checkpoints.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem conditional_fabric_durability_through_full_trace (tr : Trace) (hsol : Solves tr)
    (hF : ∀ k<5, ∀ t ∈ Ico (time k) (time (k+1)), ∀ l : Cell,
      (∑ i, ((tr.path k t).state.F (point l) i (axis l))^2)≤(2:ℝ)) :
    (∀ k≤5, ClayBuffer (tr.after k).state) ∧
    ∀ k<5, ∀ t ∈ Icc (time k) (time (k+1)),
      ClayBuffer (tr.path k t).state := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnChallenge.lean#L36-L41) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnProofs.lean#L114-L120)

## Does accumulated write work change while a segment simply evolves?

`full_trace_write_work_constant_between_writes`

**Proof request**

Show that accumulated write work is constant between writes.

**Reading the result**

Its continuous rate is zero, giving the same value as at segment entry.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_trace_write_work_constant_between_writes (tr : Trace) (hsol : Solves tr) :
    ∀ k<5, ∀ t ∈ Icc (time k) (time (k+1)),
      (tr.path k t).state.writeWork=(tr.after k).state.writeWork := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnChallenge.lean#L43-L45) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnProofs.lean#L131-L162)

## Can the write-work total decline from checkpoint to checkpoint?

`full_trace_write_work_nondecreasing_at_checkpoints`

**Proof request**

Prove that successive checkpoint values of write work are nondecreasing.

**Reading the result**

Continuous segments preserve it and accepted writes add nonnegative amounts.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_trace_write_work_nondecreasing_at_checkpoints (tr : Trace) (hsol : Solves tr) :
    ∀ k<5, (tr.after k).state.writeWork≤(tr.after (k+1)).state.writeWork := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnChallenge.lean#L47-L48) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnProofs.lean#L187-L194)

## What prevents a complete reset to the initial state?

`positive_write_work_precludes_full_reset`

**Proof request**

Use a strict increase of work to distinguish the checkpoint from the initial state.

**Reading the result**

A strictly larger write-work coordinate at a checkpoint already distinguishes the two full states.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem positive_write_work_precludes_full_reset (tr : Trace) (hsol : Solves tr)
    (k : ℕ) (hk : k≤5) (hw : 0<(tr.after k).state.writeWork) :
    (tr.after k).state≠(tr.after 0).state := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnChallenge.lean#L50-L52) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnProofs.lean#L196-L201)

## How much relevance can a positive-duration event carry?

`record_relevance_positive_and_bounded`

**Proof request**

Bound the relevance of a positive-duration record between zero strictly and its duration inclusively.

**Reading the result**

Its exponential weight is positive and at most the event duration.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem record_relevance_positive_and_bounded (G : Geometry) (s : State) (r : Record)
    (ht : r.startTime<r.endTime) :
    0<recordWeight G s r ∧ recordWeight G s r≤r.endTime-r.startTime := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnChallenge.lean#L54-L56) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnProofs.lean#L203-L217)

## Can an unchanged record matter more later?

`stable_record_with_changed_relevance`

**Proof request**

Under the closer-cue hypothesis, show equal decoded records and a strictly greater weight.

**Reading the result**

Changing context and association to bring its cue closer increases its weight while the decoder returns the same records.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem stable_record_with_changed_relevance (G : Geometry) (s : State) (r : Record)
    (c : Actor → Fin 2 → ℝ) (a : Actor → Actor → Fin 3 → ℝ)
    (ht : r.startTime<r.endTime)
    (hc : MemoryRules.cueDistanceSquared G {s with context := c, association := a} r <
      MemoryRules.cueDistanceSquared G s r) :
    readRecords {s with context := c, association := a}=readRecords s ∧
    recordWeight G s r<recordWeight G {s with context := c, association := a} r := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnChallenge.lean#L58-L64) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnProofs.lean#L219-L226)

## Does the declared event route come back to the first teacher?

`declared_route_closes_at_first_teacher`

**Proof request**

Verify the specified event roles and ordering for the return to the first teacher.

**Reading the result**

The last listed return runs from actor one to actor zero, after the original zero-to-one event.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem declared_route_closes_at_first_teacher :
    (events 0).origin=0 ∧ (events 0).recipient=1 ∧
    (events 2).origin=1 ∧ (events 2).recipient=0 ∧
    (events 0).endTime≤(events 2).startTime := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnChallenge.lean#L66-L69) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnProofs.lean#L228-L233)

## Is there another declared reply to the student after that return?

`no_later_declared_reply_to_student`

**Proof request**

Rule out a later declared reply from actor zero to actor one after event two.

**Reading the result**

Inspecting the three scheduled events exhausts the possibilities and finds no such later zero-to-one event.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem no_later_declared_reply_to_student :
    ¬∃ id : Fin 3, (events id).origin=0 ∧ (events id).recipient=1 ∧
      (events 2).endTime≤(events id).startTime := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnChallenge.lean#L71-L73) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnProofs.lean#L235-L245)

## Can the engagement example start exactly at the stated intent?

`witness_preserves_original_intent_expression`

**Proof request**

Verify that the witness’s expression field equals intent.

**Reading the result**

Its expression field is set equal to that intent.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem witness_preserves_original_intent_expression (G : Geometry) :
    (engagementWitness G).expression=intent := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnChallenge.lean#L75-L76) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnProofs.lean#L247-L248)

## Can expression begin moving away even there?

`expression_rate_can_leave_intent`

**Proof request**

Prove that the witness has a positive expression rate in coordinate (1,0).

**Reading the result**

The displayed actor and coordinate have positive expression rate at that witness.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem expression_rate_can_leave_intent (G : Geometry) (t : ℝ)
    (rs : List (Fin 4 × Record)) :
    0<(socialRates G t (engagementWitness G) rs).expression 1 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnChallenge.lean#L78-L80) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnProofs.lean#L250-L255)

## Does that motion appear in an accepted full calculation?

`accepted_full_rate_can_leave_intent`

**Proof request**

Transfer that strict positivity to the given accepted full rate.

**Reading the result**

Given the successful full rate at the witness, its specified expression component is positive.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem accepted_full_rate_can_leave_intent (G : Geometry) (t : ℝ) (rate : State)
    (hr : rhs G t (engagementWitness G)=some rate) : 0<rate.expression 1 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnChallenge.lean#L82-L83) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-bridge-return-lean/V3BridgeReturnProofs.lean#L257-L264)
