# How records are scored, weighted and retrieved

Follow one record from observation and report to a partner-specific channel. Compare changing its cue, merging two record lists and using a buffered social state.

[`V3MemoryRulesChallenge.lean`](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesChallenge.lean) · [Package configuration](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 Nous Volition. All rights reserved. The repository notice applies to material for which Nous Volition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesProofs.lean) · [V3MemoryRulesDefinitions](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesDefinitions.lean) · [Saved source digests](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/preserved-inputs.json) · [Statement and proof inputs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/lake-manifest.json).

</details>

## What score does a report get without an independent observation?

`report_without_observation`

**Proof request**

Evaluate a report-only record’s score.

**Reading the result**

The scoring rule selects the report’s own value.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem report_without_observation (r : Record) (y : ℝ) :
    score {r with observed := none, report := some y}=some y := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesChallenge.lean#L9-L10) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesProofs.lean#L8-L9)

## What if both score sources are missing?

`both_missing_ignored`

**Proof request**

Show that adding a record with both scores absent leaves retrieval unchanged.

**Reading the result**

Adding that record contributes zero to the weighted channels and leaves retrieval unchanged.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem both_missing_ignored (G : Geometry) (s : State) (rs : List (Fin 4 × Record))
    (slot : Fin 4) (r : Record) (i j : Actor) (k : Fin 4)
    (ho : r.observed=none) (hr : r.report=none) :
    memory G s ((slot,r)::rs) i j k=memory G s rs i j k := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesChallenge.lean#L12-L15) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesProofs.lean#L11-L16)

## What happens when observation and report are equal and opposite?

`opposing_reports_zero`

**Proof request**

Evaluate the score for opposite observation and report values.

**Reading the result**

Their average is the observed score zero.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem opposing_reports_zero (r : Record) (y : ℝ) :
    score {r with observed := some y, report := some (-y)}=some 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesChallenge.lean#L17-L18) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesProofs.lean#L18-L20)

## Can different observation–report pairs produce the same score?

`different_reports_same_score`

**Proof request**

Preserve the score under equal and opposite shifts of observation and report.

**Reading the result**

Adding delta to one and subtracting it from the other preserves their mean.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem different_reports_same_score (r : Record) (x y δ : ℝ) :
    score {r with observed := some (x+δ), report := some (y-δ)}=
    score {r with observed := some x, report := some y} := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesChallenge.lean#L20-L22) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesProofs.lean#L22-L27)

## Does moving both timestamps together alter record weight?

`time_translation_weight`

**Proof request**

Prove invariance of weight under joint translation of start and end times.

**Reading the result**

Their difference, the event duration, stays fixed.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem time_translation_weight (G : Geometry) (s : State) (r : Record) (δ : ℝ) :
    recordWeight G s {r with startTime := r.startTime+δ, endTime := r.endTime+δ}=
    recordWeight G s r := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesChallenge.lean#L24-L26) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesProofs.lean#L29-L34)

## When does a closer cue increase relevance?

`closer_cue_increases_weight`

**Proof request**

Prove a strict weight increase from the stated strict cue-distance decrease.

**Reading the result**

For positive event duration, a smaller squared cue distance gives a larger exponential weight.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem closer_cue_increases_weight (G : Geometry) (s z : State) (r : Record)
    (ht : r.startTime<r.endTime)
    (hc : cueDistanceSquared G s r<cueDistanceSquared G z r) :
    recordWeight G z r<recordWeight G s r := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesChallenge.lean#L28-L31) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesProofs.lean#L36-L44)

## Exactly how does changing an association move the cue?

`association_changes_cue`

**Proof request**

Calculate the exact cue change under association replacement.

**Reading the result**

Subtraction isolates −0.15 times the difference between the two transformed association values.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem association_changes_cue (G : Geometry) (s : State) (r : Record)
    (a : Actor → Actor → Fin 3 → ℝ) (k : Fin 3) :
    cueDifference G {s with association := a} r k-cueDifference G s r k=
    -0.15*(tanh (a r.recipient r.origin k)-tanh (s.association r.recipient r.origin k)) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesChallenge.lean#L33-L36) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesProofs.lean#L46-L51)

## Does changing context and association rewrite stored content?

`changed_context_and_association_keep_record_bytes`

**Proof request**

Show that replacing context and association preserves the decoded records.

**Reading the result**

Neither change alters the storage decoder, so it reads the same records.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem changed_context_and_association_keep_record_bytes (s : State)
    (c : Actor → Fin 2 → ℝ) (a : Actor → Actor → Fin 3 → ℝ) :
    readRecords {s with context := c, association := a}=readRecords s := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesChallenge.lean#L38-L40) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesProofs.lean#L53-L55)

## How does exposure accumulate across two lists?

`exposure_adds_across_records`

**Proof request**

Prove additivity of exposure over concatenated record lists.

**Reading the result**

The defining sum over a concatenation splits into the sum of the two exposures.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem exposure_adds_across_records (G : Geometry) (s : State)
    (rs zs : List (Fin 4 × Record)) (i j : Actor) :
    exposure G s (rs++zs) i j=exposure G s rs i j+exposure G s zs i j := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesChallenge.lean#L42-L44) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesProofs.lean#L57-L60)

## How should two retrieved memory values be merged?

`weighted_memory_merge`

**Proof request**

Derive the weighted-merge formula under its denominator assumptions.

**Reading the result**

Recover their weighted numerators, add them, then divide by a single baseline of 0.12 plus both exposures.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem weighted_memory_merge (G : Geometry) (s : State)
    (rs zs : List (Fin 4 × Record)) (i j : Actor) (k : Fin 4)
    (hr : 0.12+exposure G s rs i j≠0) (hz : 0.12+exposure G s zs i j≠0) :
    memory G s (rs++zs) i j k=
    ((0.12+exposure G s rs i j)*memory G s rs i j k+
     (0.12+exposure G s zs i j)*memory G s zs i j k)/
    (0.12+exposure G s rs i j+exposure G s zs i j) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesChallenge.lean#L46-L52) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesProofs.lean#L62-L72)

## Can opposing events both leave an influence?

`opposite_events_both_influence`

**Proof request**

Exhibit positive contributions to both signed channels from the two opposite records.

**Reading the result**

The stated two records with opposite scores make both signed retrieval channels strictly positive.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem opposite_events_both_influence (G : Geometry) (s : State) (r z : Record)
    (hr : r.startTime<r.endTime) (hz : z.startTime<z.endTime)
    (hi : z.recipient=r.recipient) (hj : z.origin=r.origin)
    (y v : ℝ) (hy : 0<y) (hv : v<0)
    (hry : score r=some y) (hzv : score z=some v) :
    0<memory G s [(0,r),(1,z)] r.recipient r.origin 0 ∧
    0<memory G s [(0,r),(1,z)] r.recipient r.origin 1 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesChallenge.lean#L54-L60) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesProofs.lean#L79-L95)

## Can a record contribute to a different partner’s channel?

`source_partner_remains_identified`

**Proof request**

Show that a mismatched partner’s record leaves the selected retrieval channel unchanged.

**Reading the result**

The origin–recipient filter excludes the mismatched pair and leaves that channel’s retrieval unchanged.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem source_partner_remains_identified (G : Geometry) (s : State)
    (rs : List (Fin 4 × Record)) (slot : Fin 4) (r : Record) (i j : Actor)
    (hne : r.origin≠j) (k : Fin 4) :
    memory G s ((slot,r)::rs) i j k=memory G s rs i j k := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesChallenge.lean#L62-L65) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesProofs.lean#L97-L101)

## Can an actor write a record addressed to itself?

`self_record_rejected`

**Proof request**

Show that a self-addressed record fails payload validation.

**Reading the result**

The payload validation rejects a record with equal origin and recipient.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem self_record_rejected (r : Record) (h : r.origin=r.recipient) :
    payload r=none := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesChallenge.lean#L67-L68) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesProofs.lean#L103-L106)

## What does the mixed-time memory cue read?

`buffered_cue_mixes_current_body_past_context`

**Proof request**

Identify the three buffered memory-feature coordinates with their past and present sources.

**Reading the result**

Its first two coordinates come from past context and its strain coordinate comes from the present fabric.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem buffered_cue_mixes_current_body_past_context (G : Geometry) (present past : State)
    (i j : Actor) :
    memoryFeature G (socialFrom present past) i j 0=memoryFeature G past i j 0 ∧
    memoryFeature G (socialFrom present past) i j 1=memoryFeature G past i j 1 ∧
    memoryFeature G (socialFrom present past) i j 2=memoryFeature G present i j 2 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesChallenge.lean#L70-L74) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesProofs.lean#L108-L115)

## Which stored records enter that mixed state?

`buffered_records_current`

**Proof request**

Identify the records read by the mixed present–past state.

**Reading the result**

The current physical storage supplies the present decoder result.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem buffered_records_current (present past : State) :
    readRecords (socialFrom present past)=readRecords present := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesChallenge.lean#L76-L77) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesProofs.lean#L117-L118)

## What happens when the delay is zero?

`zero_delay_unchanged`

**Proof request**

Recover the original optional rate from zero-delay history.

**Reading the result**

Both samples select the same time and the original rate is recovered.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem zero_delay_unchanged (G : Geometry) (history : ℝ → State) (t : ℝ) :
    rhsAlong G 0 history t=rhs G t (history t) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesChallenge.lean#L79-L80) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesProofs.lean#L120-L122)

## How much of a history can this delayed rate distinguish?

`only_selected_history_samples`

**Proof request**

Prove rate equality for histories agreeing at the selected sample times.

**Reading the result**

Agreement at the specified sampled times suffices for equality of the two results.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem only_selected_history_samples (G : Geometry) (τ t : ℝ)
    (h₁ h₂ : ℝ → State) (hn : h₁ t=h₂ t) (hp : h₁ (t-τ)=h₂ (t-τ)) :
    rhsAlong G τ h₁ t=rhsAlong G τ h₂ t := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesChallenge.lean#L82-L84) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-memory-rules-lean/V3MemoryRulesProofs.lean#L124-L127)
