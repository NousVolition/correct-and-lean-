# Rescaled periodic vortex and the signed A/S force

[Read the research note](RESEARCH-NOTE.md) · [Verification record](verification-report.json) · [Reference statements](RescaleChallenge.lean)

This package tests the two transverse momentum integrals after the pinned construction’s viscosity scaling, parabolic compression and unit periodization. The [same-field theorem](RescaleCorollary.lean) couples the A/S exclusion to OpenAI’s original periodic candidate for every positive viscosity. The [all-scale theorem](RescaleForcing.lean) quantifies over all selected schedules and every compression fitting the original compact cylinder into the open cell.

## Replay

Keep this directory beside `as-signed-vortex-lean` and `as-vortex-hline-lean`. Use the version in `lean-toolchain` and the pinned dependencies in `lake-manifest.json`. The default `lake build` checks the solution. Run `lake env lean RescaleSolution.lean` to print its axioms. The twelve placeholders in `RescaleChallenge.lean` define the Comparator questions. The proof modules do not import that reference.

The [Linux runner](run-check.sh) uses an existing Linux verification installation. Under the verification root it expects the clean pinned upstream checkout in `project`, the matching Lean and Comparator tools, Landrun, lean4export and nanoda. It runs as an unprivileged user with systemd user services. Set `HUG_VERIFICATION_ROOT` to select the installation, then run `bash run-check.sh verify`. Each verification starts without compiled modules for this package or either inherited audit, while reusing the pinned external dependency builds. The runner verifies input hashes and dependency revisions before and after the run. [Original checker and isolation instructions](https://github.com/leanprover/comparator/blob/19e111e2141cf333c7daff0f64c5f24acc91dd2e/README.md)

[Comparator log](evidence/comparator.log) · [Lean build](evidence/lean-build.log) · [Axiom list](evidence/axioms.log) · [Frozen inputs](reference-freeze.json)
