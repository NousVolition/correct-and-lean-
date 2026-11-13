# The line identity at the vortex edge

[Research note](RESEARCH-NOTE.md) · [Verification report](verification-report.json) · [Final theorems](HLineProofs.lean).

The reference includes five new theorems. The first gives both horizontal identities in the same late-time interval. The next two give each orientation individually. The final two exclude a match at sufficiently late times and across the entire presingular trajectory. All five use the original `MatchesSignedAt` force predicate from the [signed A/S package](../as-signed-vortex-lean/TraceDefinitions.lean).

## Replaying

Keep this folder next to `as-signed-vortex-lean`. The relative Lake dependency uses that previously checked package. Both packages pin OpenAI’s source at `f9e8bc5b38b6e212696e8a30e3e91517af887bbd`. The prior source files, including the equations and the matching predicate, are verified by SHA-256 during replay.

For the default Lean build, run `lake build` in this folder with the pinned dependencies and toolchain available. Run `lake env lean HLineSolution.lean` to print the axiom list for each target. The `sorry` declarations in [HLineChallenge.lean](HLineChallenge.lean) define the reference questions for Comparator. The solution imports [HLineProofs.lean](HLineProofs.lean).

For the recorded Linux check, run `bash run-check.sh verify` in the verification installation used for the original Navier–Stokes replay. It uses a clean pinned checkout named `project`, the pinned Lean installation, Landrun, lean4export, nanoda, and a non-root systemd user session. The default tools root is `$HOME/verification`, adjustable with `HUG_VERIFICATION_ROOT`. The runner creates a new staging directory on every verification. Both the inherited and the new project begin without compiled solution files. Their build caches are inside the new project’s writable `.lake` directory. The source trees stay outside it. [Comparator’s isolation requirements](https://github.com/leanprover/comparator/blob/19e111e2141cf333c7daff0f64c5f24acc91dd2e/README.md)

## Evidence

- [Final Comparator replay](evidence/comparator.log)
- [Default Lean build](evidence/lean-build.log)
- [Axioms for all five targets](evidence/axioms.log)
- [Frozen inputs](reference-freeze.json), [dependencies](evidence/preflight.json) and [post-run integrity](evidence/postflight.json)
- [First attempt](evidence/initial-cache-layout/comparator.log), in which the isolation layer denied a write to the sibling package’s build cache before the reference compiled
