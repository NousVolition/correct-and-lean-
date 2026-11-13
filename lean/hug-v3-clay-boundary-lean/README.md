# Hug v3: Clay boundary and memory writes

**Full existence and uniqueness: UNPROVED. Seventeen conditional/component memory-boundary statements: checked by Lean, Comparator and nanoda. Five are new decoder-preservation statements.**

Read [the report](CLAY_BOUNDARY_REPORT.md) for the corpus connection, exact assumptions and remaining gaps. Read [the current verification record](verification-report.json) for this run's results. The original equations and sources are unchanged.

The source model remains the full finite Hug v3 realization. `V3ClayProofs.lean` proves the concrete memory and accepted-write results. `V3ClayTrajectoryProofs.lean` connects them to the actual `Solves` definition and event schedule. Its preservation theorem requires an existing full solution and an explicit deformation bound. It does not prove existence, uniqueness or the bound.

The actual read threshold remains 0.005. `ClayBuffer` describes a candidate invariant at 0.006; it changes no rate, write rule, forcing or source configuration. The same returning student and idea are preserved as interpretation metadata.

`V3ClayChallenge.lean` and `V3ClayTrajectoryChallenge.lean` are reference-only statements for Comparator, with placeholders. Neither is imported by a solution module. The full target remains an unproved proposition in `V3SourceSystem.lean`.

`reference-freeze-first-ten.json` preserves the first freeze; the earlier twelve-target freeze is retained in the [decoder update provenance](../../provenance/hug-v3-decoder-2026-11-13/before/reference-freeze.json). The current `reference-freeze.json` includes five additional reference statements frozen before their implementations. All original statement/source hashes remained unchanged. The only intervening Lake configuration change adds those two modules and selects the aggregate build target; the original configuration is preserved as `lakefile-first-ten.toml`.

The Linux reproduction script requires the already configured nonroot Lean/Comparator/Landrun verifier and a fresh output directory. It records input/dependency hashes, uses real isolation, checks with Lean and nanoda, and saves evidence. It intentionally does not submit the unproved full existence-and-uniqueness proposition.


## Decoder proof strengthened on 13 November 2026

Previously, `decoded_records_fixed_on_segment` assumed that decoding succeeded at every time. The new proof derives that continuing success from one successful starting read, continuity of the memory values, and their read margin. The intermediate theorem works directly with the unchanged threshold 0.005; the existing 0.006 buffer is a sufficient way to obtain that margin. Exact bits stay fixed, so the actual decoder, including its checksum and record fields, returns the same result.

`initial_read_records` proves that the concrete initial state decodes to an empty record list. `initial_segment_read_records` combines that fact with the unchanged fabric equation and the existing deformation hypothesis. No successful-read premise is needed for that initial interval.

The five new statements are related lemmas and corollaries, not five independent models. A frozen-reference Comparator check covers all seventeen targets, including the original twelve. Both kernels, the Lake build and every target's axiom audit passed. Only the three standard permitted axioms occur.

This closes the **between-write decoding implication**, not full continuation: it still requires the margin/deformation bound on the actual trajectory. The remaining write-acceptance, evolution-existence and full source-correspondence obligations are unchanged. No equation, decoder threshold, write budget, event schedule, or simulation was changed or run.

[New proofs](V3ClayProofs.lean) · [New reference statements](V3ClayChallenge.lean) · [Verification and preservation records](../../provenance/hug-v3-decoder-2026-11-13/README.md)
