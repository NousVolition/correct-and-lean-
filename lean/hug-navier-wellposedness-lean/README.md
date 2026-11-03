# Unchanged Hug–Navier system: unfinished well-posedness proof

**The requested full existence-and-uniqueness theorem is not proved by this package.**

Read [PROOF-STATUS.md](PROOF-STATUS.md) for the result, the exact obstacle checked, the research routes inspected and the remaining proof obligations. [CLASSICAL-UNIQUENESS-ARGUMENT.md](CLASSICAL-UNIQUENESS-ARGUMENT.md) is a written argument for sufficiently regular existing solutions; it has not been certified by Lean.

- `FullModel.lean`, `OriginalAS.lean` and `FullChecks.lean` are unchanged copies from the previous package.
- `WellposednessTargets.lean` retains the full requested theorem as an unproved proposition and defines the separate diagnostic test.
- `WellposednessProofs.lean` proves only the four explicitly listed diagnostic claims about smooth periodic perturbations and the exact PDE right-hand side.
- `WellposednessChallenge.lean` supplies Comparator's matching reference statements. Only its reference proofs contain intentional placeholders; the solution does not import it.
- `verification-report.json` and `evidence-linux/` distinguish the diagnostic results from the unproved requested theorem.

With the pinned dependencies installed, `lake build` builds the diagnostic proofs. The environment-specific Linux script runs Comparator with real Landrun isolation and independent nanoda checking. The archive does not bundle Lean or dependency build caches. Successful execution is not a full-system existence or uniqueness certificate.
