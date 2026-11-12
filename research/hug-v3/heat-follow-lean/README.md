# Recorded heat spread and accumulation: 56 passing targets

The [threshold-1 heat follow-up](../heat-follow-study/README.md) has **56 passing Lean declarations**, using Lean **4.34.0-rc2** and Mathlib revision `85e3a25e006c35636f0e53b0e9296caca2685bc0`. This package is separate from the earlier 12-theorem heat draft and the 134 checks for observers 540 and 872.

| Part | Checked scope |
|---|---|
| [HeatAccounting.lean](HeatAccounting.lean), 4 targets | Finite sums: a two-stage update preserves its sum when both stage sums are zero; a write adds its pulse total; three positive writes accumulate; rearrangement of the source account. The transport hypotheses are explicit. |
| [RecordedHeat.lean](RecordedHeat.lean), 52 targets | Every source account in 2,408 saved rows, step/write-side coverage, cumulative writes, transcribed spread and negative-ripple measures, rounding of the writes' 20.7% share of new warmth, step-size comparison criteria, and differing recorded checksums. |
| [CheckAxioms.lean](CheckAxioms.lean) | Dependency reports for every target in [targets.json](targets.json). |

All 52 recorded-data targets have no axiom dependencies. The four general rules use `propext`, `Classical.choice` and `Quot.sound`. No added axioms, `sorry` or `native_decide` are used. The [receipt](receipt.json) records the actual compiler, exact files, source fingerprint, targets and dependencies. The three local compiler checks exited zero; their logs remain beside the receipt. This run used the pinned compiler directly with the existing Mathlib cache. That original run did not run Lake build, Comparator or nanoda. The separate [GitHub receipt](github-lean-receipt.json) records a fresh full `lake build` and all 56 dependency reports; Comparator and nanoda remain outside this package's verification.

The generator transcribes the selected saved decimals as integers with a common scale of 10³⁴, with no rounding. Account bounds use 10⁻¹² globally and 10⁻¹⁴ per source. [Generation details](generation.json) identify the columns and phase encoding. A separate read-only regeneration check matched every generated Lean byte to the saved CSVs and analysis. The raw grid arrays were recounted separately in the numerical study.

These proofs check the stated algebra and exact recorded numbers. They do not execute the numerical solver or prove source transcription, the grid-derived metrics, fluid evolution, zero-sum flux for the solver/PDE, positive heat parcels, or grid/continuum convergence. The number of targets counts declarations and row blocks, not independent experiments.

To check the transcription without changing the files:

```text
python generate_records.py --check
```

To rebuild with the pinned toolchain and dependencies:

```text
lake update
lake exe cache get
lake build
lake env lean CheckAxioms.lean
```

The [publication manifest](publication-manifest.json) binds the unchanged original proof inputs, saved study evidence and verification tools. The workflow rejects a receipt with a stale fingerprint or target list. New proof material and tooling are AI-generated; dictated and directed by NousVolition. The earlier draft and historical evidence remain unchanged.
