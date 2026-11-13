# Unchanged Hug–Navier system: unfinished well-posedness proof

**The requested full existence-and-uniqueness theorem is not proved by this package.**

Read [PROOF-STATUS.md](PROOF-STATUS.md) for the result, the exact obstacle checked, the research routes inspected and the remaining proof obligations. [CLASSICAL-UNIQUENESS-ARGUMENT.md](CLASSICAL-UNIQUENESS-ARGUMENT.md) is a written argument for sufficiently regular existing solutions. Lean checks its integrated guard residual, common-transport cancellation, and the connection from joint guard-gradient continuity to a transport bound uniform on a finite interval. The [gradient bridge walkthrough](GRADIENT-TRANSPORT-BRIDGE.md) states the assumptions and conclusion step by step.

- `FullModel.lean`, `OriginalAS.lean` and `FullChecks.lean` are unchanged copies from the previous package.
- `WellposednessTargets.lean` retains the full requested theorem as an unproved proposition and defines the separate diagnostic test.
- `WellposednessProofs.lean` collects the four diagnostic claims, imports the six existing theorems from [GuardTransport.lean](GuardTransport.lean), and imports the three new interval-wide bounds from [GuardTransportTime.lean](GuardTransportTime.lean).
- `WellposednessChallenge.lean` supplies Comparator's matching reference statements. Only its reference proofs contain intentional placeholders; the solution does not import it.
- `verification-report.json` and `evidence-linux/` distinguish the diagnostic results from the unproved requested theorem.

The [current Linux receipt](evidence-linux/source.json) records successful Comparator, Lean-kernel, nanoda, build, and axiom checks for all 13 named statements at its pinned proof commit. The six artifact members are saved byte for byte. The [earlier ten-target receipt](evidence-linux/historical-ten/source.json) and its logs are preserved separately. Native development checks of the new declarations are saved under `evidence-native-gradient/`.

With the pinned dependencies installed, `lake build` builds all 13 configured theorems. The environment-specific Linux script runs Comparator with real Landrun isolation and independent nanoda checking. The archive does not bundle Lean or dependency build caches. Successful execution is not a full-system existence or uniqueness certificate.
