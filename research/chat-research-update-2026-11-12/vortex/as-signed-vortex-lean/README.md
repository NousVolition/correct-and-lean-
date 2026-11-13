# Signed A/S force and the periodic vortex

[Read the research note](RESEARCH-NOTE.md). [Machine-readable verification](verification-report.json).

The package tests the original signed tanh response against the viscosity-one native field at OpenAI commit `f9e8bc5b38b6e212696e8a30e3e91517af887bbd`. The 25 reference statements include an exact whole-box cancellation example, exterior identities imported from that commit, and a conditional obstruction for the full pressure-free momentum residual. The named hypothesis `hline` in the final statement is the remaining three-dimensional integral identity. The exterior observable and all proof statements are in the [frozen reference](Challenge.lean).

## Replaying the checks

Use the Lean version in `lean-toolchain` and the dependency revisions in `lake-manifest.json`. Run `lake build` for the proofs and `lake env lean Solution.lean` for all 25 axiom reports. The intentional `sorry` declarations in `Challenge.lean` specify the Comparator questions. The proofs belong to the solution modules. The solution build has no dependency on the reference module.

The [Linux replay script](run-check.sh) uses an existing unprivileged Linux verification installation with a clean pinned checkout named `project`, its pinned Comparator and lean4export builds, Landrun and nanoda. Its default verification root is `$HOME/verification`, adjustable with `HUG_VERIFICATION_ROOT`. Run `bash run-check.sh verify` inside that environment. Each verification creates a fresh directory, verifies the hashes in `reference-freeze.json`, checks dependency revisions and clean trees, and invokes Comparator with the systemd socket restriction. See the [upstream Comparator instructions](https://github.com/leanprover/comparator/blob/19e111e2141cf333c7daff0f64c5f24acc91dd2e/README.md).

Run `python snapshot.py` for the two quadrature resolutions shown in the note. Only the numerical example uses normalized unit coefficients.

## Evidence

- [Comparator output](evidence/comparator.log)
- [Lean build](evidence/lean-build.log)
- [Axioms by theorem](evidence/axioms.log)
- [Checked inputs and dependency revisions](evidence/preflight.json)
- [Post-run integrity check](evidence/postflight.json)
