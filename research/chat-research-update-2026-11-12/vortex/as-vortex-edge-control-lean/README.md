# Vortex edge control

[Research note](RESEARCH-NOTE.md) · [Six reference statements](EdgeControlChallenge.lean) · [Verification record](verification-report.json)

This follow-up tests the spatial resolution of the signed A/S comparison on the same rescaled periodic vortex. It verifies silence outside and at the cutoff and nonzero readings arbitrarily close inside. The two interior line integrals have opposite signs and can have magnitude below any specified positive tolerance.

The [time supplement](time-check/README.md) has its own two-theorem configuration and receipts. It checks the same physical loop during early rest and at a later nonzero reading. The [concrete example](examples/SpecificProbe.lean) is a separate Lean specialization of the spatial test.

Keep this package next to `as-signed-vortex-lean`, `as-vortex-hline-lean` and `as-vortex-rescaling-lean`. The solution build uses `lake build`. The six axiom reports use `lake env lean EdgeControlSolution.lean`. Placeholders in the challenge specify questions for Comparator. All proofs are in the solution modules.

The [isolated Linux runner](run-check.sh) uses the same prepared verification installation as the [rescaling audit](../as-vortex-rescaling-lean/README.md). Run `bash run-check.sh verify` with that installation. It checks the pinned source hashes, stages empty local builds for all four audit packages, runs Comparator with Landrun and the systemd socket restriction, and checks the standalone build, per-theorem axioms and post-run integrity.

[Comparator log](evidence/comparator.log) · [Axiom list](evidence/axioms.log) · [Frozen inputs](reference-freeze.json)
