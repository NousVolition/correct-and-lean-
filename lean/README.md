# Lean package index

These packages retain their own model definitions, assumptions and verification histories. **Status review: 12 November 2026.** The 19 reports in the first table record successful Comparator, Lean-kernel, nanoda and Lake checks for their listed declarations. The descriptions below distinguish those completed results from larger open targets and link later work where it addresses an earlier limitation.

This review checks the saved reports and configured targets; it is not a new compilation of those 19 packages. Counts can overlap across packages and must not be added as independent discoveries. The linked reports retain their original evidence and open items.

Newer standalone results are described below: [observation and field-equation checks](#separate-observation-and-field-equation-checks), [Pair-25 origins](#separate-finite-origin-checks), [540/872 histories](#following-540-and-872), and [heat from writing](#heat-from-writing).

| Package | Checked result and current limits | Evidence |
| --- | --- | --- |
| [as-lean](as-lean/) | 30 scoped A/S claims. Later [existence](as-existence-lean/) and [invariance](as-invariance-lean/) results cover the seven-coordinate model; suppression comparison and repeated-encounter coupling remain open. | [record](as-lean/verification-report.json) |
| [as-existence-lean](as-existence-lean/) | Existence and uniqueness of the seven-coordinate continuous integral evolution on every finite interval, under the original assumptions. | [record](as-existence-lean/verification-report.json) |
| [as-invariance-lean](as-invariance-lean/) | Both meaning states remain in [0,1] and both adverse-history loads remain nonnegative on every finite interval, under the original assumptions. | [record](as-invariance-lean/verification-report.json) |
| [hug-squeeze-lean](hug-squeeze-lean/) | 51 specified claims. [Later existence work](hug-existence-lean/) covers the primary eight-state model; the separate memory-field extension remains open. | [record](hug-squeeze-lean/verification-report.json) |
| [hug-existence-lean](hug-existence-lean/) | Existence, uniqueness and guard preservation on every finite forward horizon for the reduced eight-state model, with frozen parameters, continuous prescribed force and admissible initial guards. | [record](hug-existence-lean/verification-report.json) |
| [hug-navier-bridge-lean](hug-navier-bridge-lean/) | 14 conditional compatibility statements for the earlier proposed coupling. Read the [single-system scope correction](../research/comparisons/hug-navier-single-system-scope-correction.md#meaning-to-preserve-across-implementations); full PDE evolution remains unproved. | [record](hug-navier-bridge-lean/verification-report.json) |
| [hug-navier-full-audit-lean](hug-navier-full-audit-lean/) | 7 field/interface audit statements. The [later single-system correction](../research/comparisons/hug-navier-single-system-scope-correction.md#meaning-to-preserve-across-implementations) revises that interpretation; full PDE evolution remains unproved. | [record](hug-navier-full-audit-lean/verification-report.json) |
| [hug-navier-single-system-lean](hug-navier-single-system-lean/) | 10 identities and local checks for the six-field formulation. Full PDE existence, uniqueness and global guard invariance remain open. | [record](hug-navier-single-system-lean/verification-report.json) |
| [hug-navier-wellposedness-lean](hug-navier-wellposedness-lean/) | 4 auxiliary well-posedness statements. Full PDE existence, continuation and uniqueness remain open. | [record](hug-navier-wellposedness-lean/verification-report.json) |
| [hug-v3-proof-attempt](hug-v3-proof-attempt/) | 6 inter-event and write results under explicit event hypotheses. Full hybrid existence/uniqueness and execution correspondence remain open. | [record](hug-v3-proof-attempt/verification-report.json) |
| [hug-v3-hybrid-lean](hug-v3-hybrid-lean/) | 9 conditional assembly and event results. Actual segment solvability, successful admissible writes and full-rate uniqueness remain obligations. | [record](hug-v3-hybrid-lean/verification-report.json) |
| [hug-v3-source-lean](hug-v3-source-lean/) | 9 results for the exact-real fixed-grid transcription. Source-execution equivalence and successful continuation through every write remain open. | [record](hug-v3-source-lean/verification-report.json) |
| [hug-v3-transfer-lean](hug-v3-transfer-lean/) | 14 local transfer results under encounter and comparison hypotheses. End-to-end finite-time transfer and full existence/uniqueness remain open. | [record](hug-v3-transfer-lean/verification-report.json) |
| [hug-v3-delay-lean](hug-v3-delay-lean/) | 9 timing identities. Delay-equation existence, uniqueness, invariance and stability remain open. | [record](hug-v3-delay-lean/verification-report.json) |
| [hug-v3-full-delay-proof](hug-v3-full-delay-proof/) | 14 conditional fixed-delay and hybrid results. Full-rate regularity, readability, successful writes and all-event continuation remain open. | [record](hug-v3-full-delay-proof/verification-report.json) |
| [hug-v3-memory-rules-lean](hug-v3-memory-rules-lean/) | 17 retrieval, weighting, partner-identity and fixed-delay results. Variable timing, reconstructed episodes and anticipation accounting remain unspecified. | [record](hug-v3-memory-rules-lean/verification-report.json) |
| [hug-v3-clay-boundary-lean](hug-v3-clay-boundary-lean/) | 12 fabric, local-flow and conditional schedule results. Full-rate existence, continuation, readability and write-success bounds remain open. | [record](hug-v3-clay-boundary-lean/verification-report.json) |
| [hug-v3-yang-mills-audit-lean](hug-v3-yang-mills-audit-lean/) | 20 strain, frame and evolution comparison statements, including `green_objective`. Full Yang–Mills structure, dynamical equivalence and a mass-gap theorem are not proved. | [record](hug-v3-yang-mills-audit-lean/verification-report.json) · [recheck](../provenance/green-objective-2026-11-08/README.md) |
| [hug-v3-gemini-review](hug-v3-gemini-review/) | 77 repaired supplied statements. Delayed uniqueness covers existing seven-coordinate A/S solutions on one delay interval; full Hug v3 delayed hybrid evolution remains open. | [record](hug-v3-gemini-review/verification-report.json) |

Challenge files can contain intentional placeholders defining a target. An unfinished target is not a proof; use the package’s checked solution modules, permitted-axiom policy and verification report.

## Separate observation and field-equation checks

The [ambiguous-observation package](../research/ambiguous-observation-lean/README.md) has a passing pinned Lean build and axiom audit covering **51 public named theorems and lemmas**, including supporting results and repeated forms of the observation rule. [Successful GitHub run and axiom logs](https://github.com/NousVolition/hug-sims-lean-proofs/actions/runs/43172199579).

Its Tick 41 and Pair 25 instances concern supplied summaries and exact numbers. **YangMillsInstance** uses a real-valued projection with equal order-zero `readJet` readings and different first derivatives. **YangMillsCueTest** separately compares two explicit abelian potentials agreeing on `x₁ = 0`, with field-equation residuals 0 and 2; the modified potential fails the equation. Neither establishes an admissible Yang–Mills family. These are also separate from the 20-statement Hug v3 strain/frame audit above.

Simulator and transcription verification are outside this package; Comparator and nanoda were not run. [Preserved authorship and credits](../research/ambiguous-observation-lean/CREDITS.md).

## Separate finite origin checks

[Pair-25 origin tracking](../research/hug-v3/pair-origin-lean/README.md) has 77 finite statements about recorded identity histories, memory contents, material-field changes and context-origin accounts. Its [dedicated GitHub receipt](../research/hug-v3/pair-origin-study/github-lean-receipt.json) retains the exact inputs, targets and run. This package uses Lean-kernel compilation and a source-data certificate; Comparator and nanoda are not claimed. Fluid evolution and complete physical retention remain unproved.

## Following 540 and 872

[The observer-follow package](../research/hug-v3/observer-follow-lean/README.md) has 134 finite checks of the recorded neighborhood histories, crossings, context-origin accounts and shared bytes. Its [GitHub receipt](../research/hug-v3/observer-follow-study/github-lean-receipt.json) binds the exact proof inputs, targets and run. Fluid evolution and whether everything stays with either label remain unproved. Earlier 77- and 40-statement studies remain separate.

## Heat from writing

[The supplied heat draft](../research/hug-v3/heat-writing-lean/README.md) has 12 passing statements about scalar stroke heat, ambiguous recovery, work accounting, exact threshold-1 replay numbers and viscosity under stated hypotheses. Its [GitHub receipt](../research/hug-v3/heat-writing-lean/github-lean-receipt.json) binds the input fingerprint, targets and run. It is separate from the 134 observer-follow checks; thermal evolution and complete retention remain open.

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
| [SIMS two memories and the restaurant meeting](sims-meeting-thread-lean/) | 90 | [Verification report](sims-meeting-thread-lean/verification-report.json) |
| [Traveller B’s first thoughts, fresh listeners and one continuing encounter](sims-mentor-first-thought-lean/) | 20 | [Verification report](sims-mentor-first-thought-lean/verification-report.json) |

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

Each `verification-report.json` contains exactly six fields. `comparator`, `lean_kernel`, `nanoda`, `lean_build` record the outcomes of the four checks. PASS requires explicit successful evidence, FAIL records a reported failure, NOT_RUN means there is no record that the check ran, and UNKNOWN means the available evidence cannot settle its outcome. `scope` describes the result, and `open_items` lists claims outside that result. Each package’s checked-in report reflects its saved Linux run. The 39 packages standardized together archive their prior reports in `evidence-linux/historical-report.json`. The SIMS meeting package keeps its earlier [49-target](sims-meeting-thread-lean/evidence-history/pr-4/), [58-target](sims-meeting-thread-lean/evidence-history/pr-5/), [65-target](sims-meeting-thread-lean/evidence-history/pr-6/) and [76-target](sims-meeting-thread-lean/evidence-history/pr-8/) receipts in its evidence history. Fresh CI reports and their logs are attached to the corresponding workflow run.


## Standalone Lean-kernel checks

The [finite-window gap package](../research/hug-v3/finite-window-lean/README.md) is a dependency-free Lake project under `research/`. Its 15 statements check nested-window reasoning and the exact recorded decimals for 25 pairs at 51 times. Its [saved local receipt](../research/hug-v3/finite-window-lean/receipt.json) reports no axiom dependencies. Its [dedicated workflow](../.github/workflows/finite-window-lean.yml) reruns Lean and checks the receipt against the current proof inputs. It does not use Comparator or nanoda and does not verify the underlying fluid simulation.
