# Finite checks for following 540 and 872

This package checks recorded observations from the follow-up described in the [study and diagram](../observer-follow-study/README.md). It does not prove the fluid simulation, geometric membership, interpolation or a complete physical inventory.

The pinned Lean 4.34.0-rc2 compiler passed 134 theorem targets: 20 general finite rules and 114 recorded-data checks. The package adds no axioms and uses neither `sorry` nor `native_decide`. The actual dependency audit contains only the standard `propext` and `Quot.sound` axioms; see the [receipt](receipt.json) and [axiom log](evidence/CheckAxioms.log).

The general rules cover finite residence classes, identity, overlapping views and origin accounting. The recorded checks cover:

- 7,854 neighbor histories, representing 2,102,254 membership bits around the two moving radius-0.075 windows.
- Six recorded crossing brackets and 1,606 crossing-history bits against the original pair's separate radius-0.10 union.
- 1,606 point-origin accounts and 322 local-window accounts, using the exact recorded decimals at a common scale of 10^32 and the declared tolerances.
- 48 selected material-field records and 2,409 complete shared-record payload comparisons.
- 306 additional point accounts using the original pair-wide origin partition, which is a different reference from the individual local windows.

The external source checker matches the actual Lean constants to the saved arrays and CSV files, independently recounts the saved trilinear stencil arithmetic, and refuses eight deliberately altered copies. That source matching and numerical recount are not themselves Lean proofs. The main simulation analyzer separately checks the saved diagnostic fields, original masks, geometry, prior source hashes and native states.

Run the full package with Python, NumPy and the pinned Lean executable:

```text
python verify_lean.py --lean /path/to/lean
```

This runs the source/refusal checks, compiles all four modules, audits every declared theorem, verifies unchanged inputs, and writes a fresh receipt. `lake build` alone does not run the source certificate checks or receipt audit.

The source model gives 540 and 872 positions, not private material or memory inventories. These overlapping windows are observations, not owned parcels. Context C is not water mass, and complete physical retention remains unknown.

AI-generated implementation and explanation; dictated and directed by NousVolition. Earlier proof packages and publication receipts are preserved separately.

The [GitHub receipt](../observer-follow-study/github-lean-receipt.json) identifies the published revision and run with the same input fingerprint and 134 targets. The original local receipt remains unchanged. Comparator and nanoda were not run.
