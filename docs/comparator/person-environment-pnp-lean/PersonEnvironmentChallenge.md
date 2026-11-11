# Can memory make a search faster and keep it correct?

Try remembered certificates first and check them against the current input. An exhaustive bounded fallback explains which decisions stay the same and when the work count changes.

[`PersonEnvironmentChallenge.lean`](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentChallenge.lean) · [Package configuration](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 NousVolition. All rights reserved. The repository notice applies to material for which NousVolition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentProofs.lean) · [PersonEnvironmentDefinitions](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentDefinitions.lean) · [Statement and proof inputs](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/lake-manifest.json).

</details>

## Can the scan return an answer it never saw or checked?

`scan_sound`

**Proof request**

Prove membership and checker acceptance for a successful scan answer.

**Reading the result**

A successful result belongs to the candidate list and passes the checker.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem scan_sound {Answer : Type*} (check : Answer → Bool) (candidates : List Answer)
    (answer : Answer) (h : (scan check candidates).answer = some answer) :
    answer ∈ candidates ∧ check answer = true := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentChallenge.lean#L5-L7) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentProofs.lean#L5-L19)

## When does scanning give no answer?

`scan_none_iff`

**Proof request**

Characterize a failed scan by rejection of every listed candidate.

**Reading the result**

Exactly when every candidate in the list fails the checker.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem scan_none_iff {Answer : Type*} (check : Answer → Bool) (candidates : List Answer) :
    (scan check candidates).answer = none ↔ ∀ a ∈ candidates, check a = false := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentChallenge.lean#L9-L10) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentProofs.lean#L21-L26)

## How many checks can a scan perform?

`scan_checks_le_length`

**Proof request**

Bound scan checks by candidate-list length.

**Reading the result**

It visits at most the length of its candidate list.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem scan_checks_le_length {Answer : Type*} (check : Answer → Bool) (candidates : List Answer) :
    (scan check candidates).checks ≤ candidates.length := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentChallenge.lean#L12-L13) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentProofs.lean#L28-L33)

## What if the whole scan fails?

`failed_scan_checks_every_candidate`

**Proof request**

Show equality with candidate-list length on a failed scan.

**Reading the result**

Every element had to be tested, so the check count equals list length.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem failed_scan_checks_every_candidate {Answer : Type*}
    (check : Answer → Bool) (candidates : List Answer)
    (h : (scan check candidates).answer = none) :
    (scan check candidates).checks = candidates.length := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentChallenge.lean#L15-L18) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentProofs.lean#L35-L46)

## Which bit strings count as bounded certificates?

`certificate_membership`

**Proof request**

Characterize membership in the complete bounded certificate list.

**Reading the result**

Membership in the enumerated list is equivalent to length at most the chosen bound.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem certificate_membership (bound : ℕ) (answer : Certificate) :
    answer ∈ certificates bound ↔ answer.length ≤ bound := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentChallenge.lean#L20-L21) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentProofs.lean#L48-L56)

## How many bit strings does that include?

`certificate_count`

**Proof request**

Count all binary certificates of length at most the bound.

**Reading the result**

At length j there are 2ʲ strings. Summing from length zero through the bound gives 2^(bound + 1) − 1.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem certificate_count (bound : ℕ) :
    (certificates bound).length+1 = 2^(bound+1) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentChallenge.lean#L23-L24) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentProofs.lean#L58-L66)

## Can a memory-first search return an oversized or invalid answer?

`memory_first_sound`

**Proof request**

Prove length admissibility and current-check acceptance of a memory-first answer.

**Reading the result**

Both hints and fallback candidates are length-bounded and a returned answer passes the current check.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem memory_first_sound {Input : Type*} (check : Input → Certificate → Bool)
    (suggest : Input → List Certificate) (input : Input) (bound : ℕ) (answer : Certificate)
    (h : (memoryFirst check suggest input bound).answer = some answer) :
    answer.length ≤ bound ∧ check input answer = true := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentChallenge.lean#L26-L29) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentProofs.lean#L68-L83)

## When does the entire memory-first search fail?

`memory_first_none_iff`

**Proof request**

Characterize failure by rejection of every bounded certificate.

**Reading the result**

The exhaustive fallback gives failure exactly when every bounded candidate fails the current check.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem memory_first_none_iff {Input : Type*} (check : Input → Certificate → Bool)
    (suggest : Input → List Certificate) (input : Input) (bound : ℕ) :
    (memoryFirst check suggest input bound).answer = none ↔
      ∀ a, a.length ≤ bound → check input a = false := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentChallenge.lean#L31-L34) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentProofs.lean#L85-L107)

## Can remembering a poor guess hide an existing bounded solution?

`memory_first_finds_iff`

**Proof request**

Prove that memory-first success is equivalent to existence of a bounded witness.

**Reading the result**

With fallback included, finding an answer is equivalent to there being a passing bounded witness.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem memory_first_finds_iff {Input : Type*} (check : Input → Certificate → Bool)
    (suggest : Input → List Certificate) (input : Input) (bound : ℕ) :
    (∃ answer, (memoryFirst check suggest input bound).answer = some answer) ↔
      BoundedWitness check input bound := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentChallenge.lean#L36-L39) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentProofs.lean#L109-L121)

## Can two different suggestion histories change whether the search succeeds?

`different_experience_preserves_decision`

**Proof request**

Prove the success-or-failure decision is independent of the suggestion function.

**Reading the result**

Both eventually search the same bounded space with the same checker, so their yes/no decisions agree.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem different_experience_preserves_decision {Input : Type*}
    (check : Input → Certificate → Bool) (first second : Input → List Certificate)
    (input : Input) (bound : ℕ) :
    ((memoryFirst check first input bound).answer = none) ↔
      ((memoryFirst check second input bound).answer = none) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentChallenge.lean#L41-L45) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentProofs.lean#L123-L128)

## What if the person changes but the checks agree?

`changed_person_same_check_preserves_decision`

**Proof request**

Prove decision agreement for the two inputs under the stated checker agreement.

**Reading the result**

Under the stated agreement on candidate checks, the two inputs have the same success or failure decision.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem changed_person_same_check_preserves_decision {Input : Type*}
    (check : Input → Certificate → Bool) (suggest : Input → List Certificate)
    (first second : Input) (bound : ℕ)
    (same : ∀ a, a.length ≤ bound → check first a = check second a) :
    ((memoryFirst check suggest first bound).answer = none) ↔
      ((memoryFirst check suggest second bound).answer = none) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentChallenge.lean#L47-L52) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentProofs.lean#L130-L143)

## How much work is done after a remembered hint passes?

`successful_memory_skips_fallback`

**Proof request**

Identify the result with the hint scan when a bounded hint succeeds.

**Reading the result**

The returned result is exactly the hint scan, including its count.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem successful_memory_skips_fallback {Input : Type*}
    (check : Input → Certificate → Bool) (suggest : Input → List Certificate)
    (input : Input) (bound : ℕ) (answer : Certificate)
    (h : (scan (check input) (hintsWithin (suggest input) bound)).answer = some answer) :
    memoryFirst check suggest input bound = scan (check input) (hintsWithin (suggest input) bound) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentChallenge.lean#L54-L58) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentProofs.lean#L145-L150)

## What does a failed hint stage cost?

`failed_memory_adds_checks`

**Proof request**

Compute the additional work after all bounded hints fail.

**Reading the result**

Its entire filtered list is checked before adding the checks from the ordinary fallback.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem failed_memory_adds_checks {Input : Type*}
    (check : Input → Certificate → Bool) (suggest : Input → List Certificate)
    (input : Input) (bound : ℕ)
    (h : (scan (check input) (hintsWithin (suggest input) bound)).answer = none) :
    (memoryFirst check suggest input bound).checks =
      (hintsWithin (suggest input) bound).length + (scan (check input) (certificates bound)).checks := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentChallenge.lean#L60-L65) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentProofs.lean#L152-L159)

## How many checks does rejecting every bounded bit string require?

`rejecting_fallback_exact_count`

**Proof request**

Compute the exact fallback check count when every bounded certificate is rejected.

**Reading the result**

The fallback exhausts the list and uses exactly 2^(bound + 1) − 1 checks.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem rejecting_fallback_exact_count (bound : ℕ) :
    (scan (fun _ : Certificate => false) (certificates bound)).checks+1 = 2^(bound+1) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentChallenge.lean#L67-L68) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentProofs.lean#L161-L166)

## When can a passing checker result be called valid?

`faithful_checker_gives_valid_answer`

**Proof request**

Use checker faithfulness to derive validity of a returned answer.

**Reading the result**

The stated faithfulness relationship carries the checked result to the intended validity predicate.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem faithful_checker_gives_valid_answer {Input : Type*}
    (check : Input → Certificate → Bool) (valid : Input → Certificate → Prop)
    (faithful : Faithful check valid) (suggest : Input → List Certificate)
    (input : Input) (bound : ℕ) (answer : Certificate)
    (h : (memoryFirst check suggest input bound).answer = some answer) :
    valid input answer := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentChallenge.lean#L70-L75) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentProofs.lean#L168-L174)

## Is a suggestion from full Hug memory checked against the current context?

`full_hug_current_context_checked`

**Proof request**

Establish the length bound and current check for a full Hug input’s returned certificate.

**Reading the result**

A returned certificate meets the length bound and passes the checker on the current input.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem full_hug_current_context_checked
    (check : HugInput → Certificate → Bool) (suggest : HugInput → List Certificate)
    (input : HugInput) (bound : ℕ) (answer : Certificate)
    (h : (memoryFirst check suggest input bound).answer = some answer) :
    answer.length ≤ bound ∧ check input answer = true := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentChallenge.lean#L77-L81) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentProofs.lean#L176-L181)

## Does this setup alter the original Hug guard calculation?

`original_guard_is_unchanged`

**Proof request**

Identify the interface guard with the native Hug margin for the selected receiver and person.

**Reading the result**

The wrapper is exactly the source margin at the selected person and receiver.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem original_guard_is_unchanged (input : HugInput) (receiver : HugV3.Source.Actor) :
    originalGuard input receiver = HugV3.Source.margin input.fullState.state receiver input.person := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentChallenge.lean#L83-L84) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentProofs.lean#L183-L185)

## Does it alter the original Hug retrieval calculation?

`original_retrieval_is_unchanged`

**Proof request**

Identify the interface retrieval with the native Hug memory for the selected origin and channel.

**Reading the result**

On this input the wrapper returns the source memory value in the specified channel.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem original_retrieval_is_unchanged (G : HugV3.Source.Geometry) (input : HugInput)
    (records : List (Fin 4 × HugV3.Source.Record)) (origin : HugV3.Source.Actor) (channel : Fin 4) :
    originalRetrieval G input records origin channel =
      HugV3.Source.memory G input.fullState.state records input.person origin channel := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentChallenge.lean#L86-L89) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentProofs.lean#L187-L191)

## Can relying on memory alone miss a valid answer?

`memory_only_can_miss_answer`

**Proof request**

Exhibit a failed memory-only scan despite an existing bounded witness.

**Reading the result**

The remembered false bit fails a true-bit check although a length-one witness exists.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem memory_only_can_miss_answer :
    (scan (singleBitCheck true) [[false]]).answer = none ∧
      BoundedWitness singleBitCheck true 1 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentChallenge.lean#L91-L93) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentProofs.lean#L193-L198)

## Can identical answers have different search costs?

`different_memory_same_answer_different_checks`

**Proof request**

Compute the same answer with one check versus four for the two hint lists.

**Reading the result**

Starting with the true hint takes one check. Starting with the false hint takes four to reach the same true answer.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem different_memory_same_answer_different_checks :
    (memoryFirst (fun _ : Unit => singleBitCheck true) (fun _ => [[true]]) () 1) = ⟨some [true],1⟩ ∧
    (memoryFirst (fun _ : Unit => singleBitCheck true) (fun _ => [[false]]) () 1) = ⟨some [true],4⟩ := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentChallenge.lean#L95-L97) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentProofs.lean#L200-L203)

## What happens to an answer remembered from an outdated context?

`stale_answer_is_rechecked`

**Proof request**

Verify rejection of a stale bit and recovery of the current answer after three checks.

**Reading the result**

The old true bit fails the new check and the run returns the false bit after three checks.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem stale_answer_is_rechecked :
    singleBitCheck true [true] = true ∧ singleBitCheck false [true] = false ∧
    memoryFirst singleBitCheck (fun _ => [[true]]) false 1 = ⟨some [false],3⟩ := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentChallenge.lean#L99-L101) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/person-environment-pnp-lean/PersonEnvironmentProofs.lean#L205-L208)
