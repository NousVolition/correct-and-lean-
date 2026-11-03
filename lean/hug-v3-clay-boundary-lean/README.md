# Hug v3: Clay boundary and memory writes

**Full existence and uniqueness: UNPROVED. Twelve conditional/component memory-boundary statements: checked by Lean and Comparator.**

Read [the report](CLAY_BOUNDARY_REPORT.md) for the corpus connection, exact assumptions and remaining gaps. Read [the current verification record](verification-report.json) for this run's results. The original equations and sources are unchanged.

The source model remains the full finite Hug v3 realization. `V3ClayProofs.lean` proves the concrete memory and accepted-write results. `V3ClayTrajectoryProofs.lean` connects them to the actual `Solves` definition and event schedule. Its preservation theorem requires an existing full solution and an explicit deformation bound. It does not prove existence, uniqueness or the bound.

The actual read threshold remains 0.005. `ClayBuffer` describes a candidate invariant at 0.006; it changes no rate, write rule, forcing or source configuration. The same returning student and idea are preserved as interpretation metadata.

`V3ClayChallenge.lean` and `V3ClayTrajectoryChallenge.lean` are reference-only statements for Comparator, with placeholders. Neither is imported by a solution module. The full target remains an unproved proposition in `V3SourceSystem.lean`.

`reference-freeze-first-ten.json` preserves the first freeze; `reference-freeze.json` adds two full-schedule consequence statements before their solution file was created. All original statement/source hashes remained unchanged. The only intervening Lake configuration change adds those two modules and selects the aggregate build target; the original configuration is preserved as `lakefile-first-ten.toml`.

The Linux reproduction script requires the already configured nonroot Lean/Comparator/Landrun verifier and a fresh output directory. It records input/dependency hashes, uses real isolation, checks with Lean and nanoda, and saves evidence. It intentionally does not submit the unproved full existence-and-uniqueness proposition.
