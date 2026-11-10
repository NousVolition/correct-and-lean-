# When can continuous pieces be joined across writes?

Give the segment and boundary hypotheses needed to assemble a trace. At simultaneous events the order of writing and capturing is part of the rule.

[`HybridChallenge.lean`](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/HybridChallenge.lean) · [Package configuration](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 Nous Volition. All rights reserved. The repository notice applies to material for which Nous Volition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

The project’s registered equations and its declared modeling choices have separate source records. [Equation register](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/equation_register.csv) · [Declared Hug rules](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-full-delay-proof/sources/declarations/main.json).

The hybrid package preserves the manuscript supplied for the audit in Codex. The surviving manuscript has no personal writer byline. Its argument, the review of that argument, and the subsequent Lean proof are separately identified. [Supplied manuscript](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/pasted-proof.tex) · [Paper review](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/PAPER_REVIEW.md) · [Hybrid proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/HybridProofs.lean).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/HybridProofs.lean) · [V3HybridSpecification](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/V3HybridSpecification.lean) · [Package account](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/README.md) · [Source audit](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/source-audit.json) · [Statement and proof inputs](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/lake-manifest.json).

</details>

## Which bit properties survive a small perturbation of the fabric?

`read_margin_stable`

**Proof request**

Preserve the read margin and bit signs under the stated perturbation bounds.

**Reading the result**

The stated distance bound leaves each magnitude beyond the threshold and preserves its sign.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem read_margin_stable {I : Type*} (b b₀ : I → ℝ) (r δ : ℝ)
    (hr : 0 ≤ r) (hδ : 0 < δ) (hmargin : ∀ i, r + δ ≤ |b₀ i|)
    (hclose : ∀ i, |b i - b₀ i| < δ) :
    (∀ i, r < |b i|) ∧ (∀ i, 0 < b i ↔ 0 < b₀ i) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/HybridChallenge.lean#L6-L9) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/HybridProofs.lean#L10-L30)

## Does a decoder see that perturbation?

`decoded_value_stable`

**Proof request**

Prove equality of the decoded values from the unchanged bit patterns.

**Reading the result**

When the signs agree the full bit patterns agree, so applying the same decoder gives the same value.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem decoded_value_stable {I D : Type*} (decode : (I → Bool) → D)
    (b b₀ : I → ℝ) (r δ : ℝ) (hr : 0 ≤ r) (hδ : 0 < δ)
    (hmargin : ∀ i, r + δ ≤ |b₀ i|) (hclose : ∀ i, |b i - b₀ i| < δ) :
    decode (V3Hybrid.bitPattern b) = decode (V3Hybrid.bitPattern b₀) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/HybridChallenge.lean#L11-L14) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/HybridProofs.lean#L32-L39)

## Can two admissible traces disagree under segment uniqueness?

`trace_uniqueness`

**Proof request**

Derive agreement of the two hybrid traces under the segment-uniqueness hypotheses.

**Reading the result**

Induction carries agreement through each continuous segment and its deterministic boundary.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem trace_uniqueness {E : Type*} (S : System E) (N : ℕ) (initial : E)
    (horder : Ordered S N) (hunique : SegmentUniqueness S N)
    (a b : Trace E) (ha : IsTrace S N initial a) (hb : IsTrace S N initial b) :
    Agreement S N a b := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/HybridChallenge.lean#L16-L19) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/HybridProofs.lean#L41-L73)

## What is needed to build one hybrid trace?

`trace_exists`

**Proof request**

Construct a full trace from the stated segment and event hypotheses.

**Reading the result**

The stated segment-existence and boundary-success hypotheses let the construction extend through every specified step.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem trace_exists {E : Type*} (S : System E) (N : ℕ) (initial : E)
    (hinit : S.admissible 0 initial) (hsolve : StepSolvability S N) :
    ∃ tr, IsTrace S N initial tr := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/HybridChallenge.lean#L21-L23) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/HybridProofs.lean#L92-L111)

## Can the existence and uniqueness arguments be joined?

`assemble_exists_unique`

**Proof request**

Establish existence and uniqueness of the assembled trace.

**Reading the result**

Construct the trace, then apply segment and boundary uniqueness to compare every other trace with it.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem assemble_exists_unique {E : Type*} (S : System E) (N : ℕ) (initial : E)
    (horder : Ordered S N) (hinit : S.admissible 0 initial)
    (hsolve : StepSolvability S N) (hunique : SegmentUniqueness S N) :
    ∃ tr, IsTrace S N initial tr ∧
      ∀ other, IsTrace S N initial other → Agreement S N tr other := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/HybridChallenge.lean#L25-L29) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/HybridProofs.lean#L113-L119)

## Can a boundary fail along a trace that already solves the hybrid rules?

`event_failure_excluded`

**Proof request**

Deduce successful boundary evaluation at each specified transition of a trace.

**Reading the result**

Its trace equation supplies a successful next state at that boundary.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem event_failure_excluded {E : Type*} (S : System E) (N : ℕ) (initial : E)
    (tr : Trace E) (ht : IsTrace S N initial tr) (k : ℕ) (hk : k < N) :
    S.boundary (k+1) (tr.path k (S.time (k+1))) ≠ none := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/HybridChallenge.lean#L31-L33) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/HybridProofs.lean#L121-L125)

## Are the five main time intervals correctly ordered?

`v3_main_time_order`

**Proof request**

Verify the strict ordering of the five main time intervals.

**Reading the result**

Evaluating the listed event times gives a strictly positive length for each.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem v3_main_time_order : ∀ k < 5, V3Hybrid.time k < V3Hybrid.time (k+1) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/HybridChallenge.lean#L35) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/HybridProofs.lean#L127-L129)

## At a simultaneous event, which action runs first?

`v3_simultaneous_event_order`

**Proof request**

Compute the action order at the shared write-and-capture boundary.

**Reading the result**

The rule attempts write one, then runs capture two on its successful result.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem v3_simultaneous_event_order {E : Type*}
    (op : V3Hybrid.Action → E → Option E) (s : E) :
    V3Hybrid.runActions op (V3Hybrid.actions 3) s =
      (op (.write 1) s).bind (fun next => op (.capture 2) next) := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/HybridChallenge.lean#L37-L40) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/HybridProofs.lean#L131-L135)

## What does the main conditional assembly establish?

`v3_main_conditional`

**Proof request**

Derive initialization and the unique five-segment main trace from the given conditional hypotheses.

**Reading the result**

With the given initialization, flow and event hypotheses, it constructs the initialized five-segment trace and gives agreement for all other such traces.

<details>
<summary>Exact Lean statement</summary>

```lean
theorem v3_main_conditional
    (law : ℕ → (ℝ → V3Hybrid.MainState) → Prop)
    (admissible : ℕ → V3Hybrid.MainState → Prop)
    (op : V3Hybrid.Action → V3Hybrid.MainState → Option V3Hybrid.MainState)
    (raw initial : V3Hybrid.MainState)
    (hcaptured : V3Hybrid.Initialized op raw initial)
    (hinit : admissible 0 initial)
    (hsolve : StepSolvability (V3Hybrid.mainSystem law admissible op) 5)
    (hunique : SegmentUniqueness (V3Hybrid.mainSystem law admissible op) 5) :
    V3Hybrid.Initialized op raw initial ∧
    ∃ tr, IsTrace (V3Hybrid.mainSystem law admissible op) 5 initial tr ∧
      ∀ other, IsTrace (V3Hybrid.mainSystem law admissible op) 5 initial other →
        Agreement (V3Hybrid.mainSystem law admissible op) 5 tr other := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/HybridChallenge.lean#L42-L54) · [Proof](https://github.com/NousVolition/correct-and-lean-/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/hug-v3-hybrid-lean/HybridProofs.lean#L137-L153)
