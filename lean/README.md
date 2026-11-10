# Lean package index

These packages retain their individual model definitions, assumptions and histories. Read the verification report linked below before interpreting a successful build. The saved checks are historical evidence, not new runs performed during publication.

| Package | Recorded result | Evidence |
| --- | --- | --- |
| [as-lean](as-lean/) | PASS for 30 scoped claims; full coupled model remains unproved | [record](as-lean/verification-report.json) |
| [as-existence-lean](as-existence-lean/) | PASS | [record](as-existence-lean/verification-report.json) |
| [as-invariance-lean](as-invariance-lean/) | PASS | [record](as-invariance-lean/verification-report.json) |
| [hug-squeeze-lean](hug-squeeze-lean/) | PASS for 51 specified claims; full Hug system not certified | [record](hug-squeeze-lean/verification-report.json) |
| [hug-existence-lean](hug-existence-lean/) | PASS: exact frozen full coupled theorem | [record](hug-existence-lean/verification-report.json) |
| [hug-navier-bridge-lean](hug-navier-bridge-lean/) | PARTIAL: conditional compatibility verified; a full combined PDE/ODE system remains unspecified and unproved | [record](hug-navier-bridge-lean/verification-report.json) |
| [hug-navier-full-audit-lean](hug-navier-full-audit-lean/) | PARTIAL: corpus search and formal audit completed; full joint evolution remains unspecified and unproved | [record](hug-navier-full-audit-lean/verification-report.json) |
| [hug-navier-single-system-lean](hug-navier-single-system-lean/) | PARTIAL: whole source PDE formulation encoded and ten specific theorems verified; full existence and uniqueness are unproved. | [record](hug-navier-single-system-lean/verification-report.json) |
| [hug-navier-wellposedness-lean](hug-navier-wellposedness-lean/) | INCOMPLETE: requested full theorem not proved. | [record](hug-navier-wellposedness-lean/verification-report.json) |
| [hug-v3-proof-attempt](hug-v3-proof-attempt/) | INCOMPLETE_FULL_HUG_V3_EXISTENCE_UNIQUENESS_NOT_PROVED | [record](hug-v3-proof-attempt/verification-report.json) |
| [hug-v3-hybrid-lean](hug-v3-hybrid-lean/) | PARTIAL_CONDITIONAL_HYBRID_ASSEMBLY_VERIFIED_FULL_V3_THEOREM_UNPROVED | [record](hug-v3-hybrid-lean/verification-report.json) |
| [hug-v3-source-lean](hug-v3-source-lean/) | INCOMPLETE_FULL_HUG_V3_EXISTENCE_UNIQUENESS_NOT_PROVED | [record](hug-v3-source-lean/verification-report.json) |
| [hug-v3-transfer-lean](hug-v3-transfer-lean/) | PARTIAL: exact local transfer links verified; full finite-time transfer and full existence/uniqueness remain open. | [record](hug-v3-transfer-lean/verification-report.json) |
| [hug-v3-delay-lean](hug-v3-delay-lean/) | PASS: nine definition-level timing identities; DDE dynamics remain unproved | [record](hug-v3-delay-lean/verification-report.json) |
| [hug-v3-full-delay-proof](hug-v3-full-delay-proof/) | PARTIAL: full hybrid delayed existence and uniqueness remain UNPROVED | [record](hug-v3-full-delay-proof/verification-report.json) |
| [hug-v3-memory-rules-lean](hug-v3-memory-rules-lean/) | PARTIAL: existing memory and fixed-delay rules verified; variable timing, reconstructed episodes and anticipation cost remain unspecified | [record](hug-v3-memory-rules-lean/verification-report.json) |
| [hug-v3-clay-boundary-lean](hug-v3-clay-boundary-lean/) | PARTIAL: full existence and uniqueness remain unproved | [record](hug-v3-clay-boundary-lean/verification-report.json) |
| [hug-v3-yang-mills-audit-lean](hug-v3-yang-mills-audit-lean/) | PASS | [record](hug-v3-yang-mills-audit-lean/verification-report.json) |
| [hug-v3-gemini-review](hug-v3-gemini-review/) | PASS for 77 repaired supplied statements; full Hug v3 delayed hybrid existence/uniqueness remains unproved | [record](hug-v3-gemini-review/verification-report.json) |

Challenge files can contain intentional placeholders defining a target. An unfinished target is not a proof; use the package’s checked solution modules, permitted-axiom policy and verification report.

## Further Lean packages

Each directory below is a separate Lake project. From that directory, use its pinned toolchain and run `lake build`. The Comparator configuration names the challenge, solution, allowed axioms and target declarations. The saved reports and Linux logs record the original checks. The historical scripts accept a configurable verification directory. The current CI instructions follow below.

| Package | Comparator targets | Saved verification |
| --- | ---: | --- |
| [clay-problems-lean-audit](clay-problems-lean-audit/) | 3 | [Verification report](clay-problems-lean-audit/verification-report.json) |
| [fabric-frame-transition-audit](fabric-frame-transition-audit/) | 7 | [Verification report](fabric-frame-transition-audit/verification-report.json) |
| [hearth-wizard-lean](hearth-wizard-lean/) | 22 | [Verification report](hearth-wizard-lean/verification-report.json) |
| [hug-v3-apple-band-lean](hug-v3-apple-band-lean/) | 15 | [Verification report](hug-v3-apple-band-lean/verification-report.json) |
| [hug-v3-apple-existence-lean](hug-v3-apple-existence-lean/) | 13 | [Verification report](hug-v3-apple-existence-lean/verification-report.json) |
| [hug-v3-bridge-return-lean](hug-v3-bridge-return-lean/) | 18 | [Verification report](hug-v3-bridge-return-lean/verification-report.json) |
| [hug-v3-child-access-lean](hug-v3-child-access-lean/) | 13 | [Verification report](hug-v3-child-access-lean/verification-report.json) |
| [hug-v3-child-account-lean](hug-v3-child-account-lean/) | 14 | [Verification report](hug-v3-child-account-lean/verification-report.json) |
| [hug-v3-child-witness-lean](hug-v3-child-witness-lean/) | 20 | [Verification report](hug-v3-child-witness-lean/verification-report.json) |
| [hug-v3-coexistence-lean](hug-v3-coexistence-lean/) | 12 | [Verification report](hug-v3-coexistence-lean/verification-report.json) |
| [hug-v3-courier-weaver-lean](hug-v3-courier-weaver-lean/) | 13 | [Verification report](hug-v3-courier-weaver-lean/verification-report.json) |
| [hug-v3-full-covariance-lean](hug-v3-full-covariance-lean/) | 26 | [Verification report](hug-v3-full-covariance-lean/verification-report.json) |
| [hug-v3-hearth-readout-lean](hug-v3-hearth-readout-lean/) | 12 | [Verification report](hug-v3-hearth-readout-lean/verification-report.json) |
| [hug-v3-joint-frame-lean](hug-v3-joint-frame-lean/) | 31 | [Verification report](hug-v3-joint-frame-lean/verification-report.json) |
| [hug-v3-o-rumination-lean](hug-v3-o-rumination-lean/) | 12 | [Verification report](hug-v3-o-rumination-lean/verification-report.json) |
| [hug-v3-occupied-space-lean](hug-v3-occupied-space-lean/) | 15 | [Verification report](hug-v3-occupied-space-lean/verification-report.json) |
| [hug-v3-paint-value-lean](hug-v3-paint-value-lean/) | 19 | [Verification report](hug-v3-paint-value-lean/verification-report.json) |
| [hug-v3-street-whole-lean](hug-v3-street-whole-lean/) | 22 | [Verification report](hug-v3-street-whole-lean/verification-report.json) |
| [mira-local-paths-lean](mira-local-paths-lean/) | 18 | [Verification report](mira-local-paths-lean/verification-report.json) |
| [person-environment-pnp-lean](person-environment-pnp-lean/) | 21 | [Verification report](person-environment-pnp-lean/verification-report.json) |
| [SIMS two memories and the restaurant meeting](sims-meeting-thread-lean/) | 58 | [Verification report](sims-meeting-thread-lean/verification-report.json) |

The apple existence package records a conditional schedule theorem. Unconditional existence and uniqueness through all three memory writes remains open. Files kept in original, portable, references and reference-history directories retain their separate roles.

[Source hashes and publication scope](../provenance/lean-additions-2026-11-07.json).

## Reproduce the checks

From the repository root, run the inexpensive checks with Python 3.11 or later.

~~~sh
python3 -m unittest discover -s scripts/tests
python3 scripts/lean_package_report.py check
python3 scripts/check_public_paths.py
~~~

The source check follows the local imports of each configured solution and rejects standalone occurrences of `sorry`, `axiom`, `native_decide`, `sorryAx` anywhere in those files, including comments. The challenge statement is outside that closure. The independent kernel checks also cover imported dependencies. The policy permits only `propext`, `Classical.choice` and `Quot.sound`.

To replay a package, start with a clean package checkout on Linux with the pinned Lean toolchain, Go, Rust, Landlock and systemd available. Use a non-root user. Run the following commands from the repository root. Choose a package by setting `pkg`.

~~~bash
set -euo pipefail
repo=$PWD
pkg=hug-v3-apple-existence-lean
scratch=$(mktemp -d)
bash scripts/build-comparator-tools.sh "$scratch/tools"
cd "lean/$pkg"
lake exe cache get
bash "$repo/scripts/compare-package.sh" "$scratch/tools" "$scratch/evidence"
lake build 2>&1 | tee "$scratch/evidence/lake-build.log"
echo 0 > "$scratch/evidence/lake-build.exit"
python3 "$repo/scripts/lean_package_report.py" axioms . --output "$scratch/evidence/axioms.json"
python3 "$repo/scripts/lean_package_report.py" ci-report . "$scratch/evidence"
~~~

Comparator runs before the local solution build. It compares the challenge and solution declarations and exports the solution for nanoda and the default Lean kernel. The default Apple build now builds the solution; its reference remains available as an explicit Comparator target. The axiom file lists the dependencies Lean reported for each named theorem. [Pinned Comparator documentation](https://github.com/leanprover/comparator/blob/19e111e2141cf333c7daff0f64c5f24acc91dd2e/README.md)

Each `verification-report.json` contains exactly six fields. `comparator`, `lean_kernel`, `nanoda`, `lean_build` record the outcomes of the four checks. PASS requires explicit successful evidence, FAIL records a reported failure, NOT_RUN means there is no record that the check ran, and UNKNOWN means the available evidence cannot settle its outcome. `scope` describes the result, and `open_items` lists claims outside that result. Each package’s checked-in report reflects its saved Linux run. The more detailed prior report is archived in `evidence-linux/historical-report.json`. Fresh CI reports and their logs are attached to the corresponding workflow run.
