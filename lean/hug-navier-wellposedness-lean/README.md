# Unchanged Hug–Navier system: unfinished well-posedness proof

**The requested full existence-and-uniqueness theorem is not proved by this package.**

Read [PROOF-STATUS.md](PROOF-STATUS.md) for the result, the exact obstacle checked, the research routes inspected and the remaining proof obligations. [CLASSICAL-UNIQUENESS-ARGUMENT.md](CLASSICAL-UNIQUENESS-ARGUMENT.md) is a written argument for sufficiently regular existing solutions. Lean checks its integrated guard residual, common-transport cancellation, and the connection from joint guard-gradient continuity to a transport bound uniform on a finite interval. The combined guard residuals are also bounded by a constant times the full difference energy in [EnergyEstimate.lean](EnergyEstimate.lean). [The energy connection and remaining gap](ENERGY-INEQUALITY-GAP.md) gives the next steps. The [time-derivative walkthrough](TIME-DERIVATIVE-ASSUMPTIONS.md) adds the pointwise difference-density chain rule and passage through the fixed cell integral under an explicit extra joint rate-density continuity assumption. The [gradient bridge walkthrough](GRADIENT-TRANSPORT-BRIDGE.md) states the assumptions and conclusion step by step.

- `FullModel.lean`, `OriginalAS.lean` and `FullChecks.lean` are unchanged copies from the previous package.
- `WellposednessTargets.lean` retains the full requested theorem as an unproved proposition and defines the separate diagnostic test.
- `WellposednessProofs.lean` collects the four diagnostic claims, imports the six existing theorems from [GuardTransport.lean](GuardTransport.lean), imports the three interval-wide bounds from [GuardTransportTime.lean](GuardTransportTime.lean), and imports the full-energy guard bound from [EnergyEstimate.lean](EnergyEstimate.lean), and imports the two derivative results from [TimeIntegral.lean](TimeIntegral.lean).
- `WellposednessChallenge.lean` supplies Comparator's matching reference statements. Only its reference proofs contain intentional placeholders; the solution does not import it.
- `verification-report.json` and `evidence-linux/` distinguish the diagnostic results from the unproved requested theorem.

The [earlier fourteen-target receipt](evidence-linux/historical-fourteen/source.json) is preserved byte for byte, alongside the older receipts. The current sixteen-target extension has its own status in `verification-report.json`; the older receipt is not claimed to check the new declarations. Native development evidence for the derivative step is saved under `evidence-native-time-integral/`.

With the pinned dependencies installed, `lake build` builds all 16 configured theorems. The environment-specific Linux script runs Comparator with real Landrun isolation and independent nanoda checking. The archive does not bundle Lean or dependency build caches. Successful execution is not a full-system existence or uniqueness certificate.
