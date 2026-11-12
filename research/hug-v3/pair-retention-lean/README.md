# Pair retention: finite Lean checks

This package checks complete **recorded memory payloads** and **recorded numerical accounts** for the pair-25 follow-up. It does not prove the fluid evolution, physical ownership of every content by a pair, or complete recovery of the incoming physical state.

The simulation continued the same historical threshold-0.015, breathing-on states from after-write tick 41 (time 1.2) to 1.3. There is no newly assigned prime label or physical departure implied. The 40-grid local account failed its original 1e-6 precision target; its failure is retained in the formal statements. A controlled repeat changed only the integration of the readout at cell boundaries, leaving the simulated state and observed values unchanged.

- CarryingInventory.lean: general rules and counterexamples for full finite record contents, missing/changed records, preservation through intermediate states, and changing or replaced contents under a balanced scalar account.
- RecordedRetention.lean: the actual full memory payloads and exact decimal numerators; all 153 saved record inventories and 612 local accounts from the three runs, plus 306 whole-system accounts.
- ReadoutCorrection.lean: the additional 204 local accounts and equality of all 204 observed values for the controlled 40-grid repeat.
- CheckAxioms.lean and targets.json: the complete list of checked statements and their axiom dependencies.
- check_certificate.py: independently matches Lean's constants to the raw observation CSVs and full payload bytes. It rejects tampered payloads or decimals.
- verify_lean.py: runs that match, compiles the sources with the pinned compiler, records the input fingerprint and checks the target/axiom log.

Run with Python 3.11+ and NumPy installed:

~~~
python check_certificate.py --self-test
python verify_lean.py --lean /path/to/lean
~~~

Use Lean 4.34.0-rc2, as specified in lean-toolchain. No added axioms, sorry or native_decide are used. Standard Lean axiom dependencies, if any, are explicitly listed in the receipt.

The data constants are exact encodings of the saved observations. Full payloads include a leading bit before encoding as a natural number, preserving leading zero bytes; no hash-only substitution is used in these content checks. Numerical decimals have one explicit common positive denominator. Their source fidelity is checked in Python before the finite arithmetic and membership assertions are checked by Lean.

The private physical inventory of the pair remains incomplete. A balanced budget can hide replacement by equal incoming content; the general counterexample makes that limitation explicit. [Simulation report and diagram](../pair-retention-study/README.md)

**AI-generated; dictated and directed by NousVolition.**

The original local [receipt](receipt.json) is preserved byte-for-byte. The separate [GitHub receipt](../pair-retention-study/github-lean-receipt.json) identifies the published run, exact proof-input fingerprint and all 40 targets. Comparator and nanoda are not used for this package.
