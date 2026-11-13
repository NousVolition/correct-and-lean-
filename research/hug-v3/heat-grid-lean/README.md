# Recorded heat-grid checks

PASS: 414 Lean targets: 5 finite accounting rules and 409 recorded claims. Of the recorded claims, 346 use no axioms and 63 word-comparison claims use standard propext. The five general rules use propext, Classical.choice and Quot.sound. No added axioms, sorry or native_decide.

The source records contain 4820 global account rows, 21 complete record comparisons and 48909 pairs of 16-bit words. Lean checks exact saved decimals, account coverage, recorded numerical limits, heat-cost partitions and exact word/bit comparisons. An exceeded numerical limit is recorded as an exceedance; a passing Lean theorem does not turn it into convergence.

Lean does not execute the fluid simulation, calculate array-derived observables, prove transcription, validate CRC computations, or prove a continuum or physical-retention result. Python separately verifies source hashes, CRCs, exact regeneration and the numerical arrays. Read [the numerical report](../heat-grid-study/README.md) separately from [this receipt](receipt.json).

Pinned versions are in lean-toolchain and lakefile.toml. This local verification used the pinned Lean compiler directly with existing pinned mathlib libraries. The original local run did not run Lake build, Comparator or nanoda. The separate [GitHub receipt](github-lean-receipt.json) records a fresh full Lake build and exact dependency lists for all 414 targets; Comparator and nanoda remain outside this package’s verification. For another environment, obtain the declared dependencies and run `lake build`; exact regeneration is `python generate_records.py --check`. Original source/artifact hashes and compiler logs are retained; the machine-specific local helper is omitted. The [publication manifest](publication-manifest.json) binds the proof inputs and numerical source files. The workflow rejects a saved receipt whose fingerprint, target list or axiom lists do not match.

AI-generated; dictated and directed by NousVolition.
