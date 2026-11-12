# Fresh verification of the 19 core Lean packages

**Result: all 19 packages passed on GitHub.** This recheck covers **306 configured declarations across packages**, with overlap; this is not a count of independent discoveries. [Workflow run](https://github.com/NousVolition/hug-sims-lean-proofs/actions/runs/43185187598) · [Machine-readable collection](manifest.json).

Each package started with a fresh local build directory and its pinned dependencies. Comparator compared the frozen challenge statements with the solution, Lean's default kernel and nanoda accepted the exported solution, Lake built the declared targets, and every configured theorem's axiom list passed the existing allow-list. The toolchain was **Lean 4.34.0-rc2**. Exact compiler and checker hashes are in each source receipt.

The checked pull-request head is `5fc0fe45b6f6aea982eed3c4484e6d77da46a986`, based on `c54f47b9eca41413c1172839f4e5d2fff2a8d8e6`. The actual test-merge checkout, run attempt, completion time, original package tree, input hashes and target list are recorded separately for each package. The proof inputs are unchanged from that base.

## Results and evidence

PASS in this table means the four verification stages and the axiom audit all passed for the configured declarations.

| Package | Configured declarations | Result | Evidence |
| --- | ---: | --- | --- |
| [as-lean](../../lean/as-lean/) | 30 | PASS | [fresh report](as-lean/verification-report.json) · [axioms](as-lean/axioms.json) · [inputs and run](as-lean/source.json) · [earlier report](../../lean/as-lean/verification-report.json) |
| [as-existence-lean](../../lean/as-existence-lean/) | 1 | PASS | [fresh report](as-existence-lean/verification-report.json) · [axioms](as-existence-lean/axioms.json) · [inputs and run](as-existence-lean/source.json) · [earlier report](../../lean/as-existence-lean/verification-report.json) |
| [as-invariance-lean](../../lean/as-invariance-lean/) | 1 | PASS | [fresh report](as-invariance-lean/verification-report.json) · [axioms](as-invariance-lean/axioms.json) · [inputs and run](as-invariance-lean/source.json) · [earlier report](../../lean/as-invariance-lean/verification-report.json) |
| [hug-squeeze-lean](../../lean/hug-squeeze-lean/) | 51 | PASS | [fresh report](hug-squeeze-lean/verification-report.json) · [axioms](hug-squeeze-lean/axioms.json) · [inputs and run](hug-squeeze-lean/source.json) · [earlier report](../../lean/hug-squeeze-lean/verification-report.json) |
| [hug-existence-lean](../../lean/hug-existence-lean/) | 1 | PASS | [fresh report](hug-existence-lean/verification-report.json) · [axioms](hug-existence-lean/axioms.json) · [inputs and run](hug-existence-lean/source.json) · [earlier report](../../lean/hug-existence-lean/verification-report.json) |
| [hug-navier-bridge-lean](../../lean/hug-navier-bridge-lean/) | 14 | PASS | [fresh report](hug-navier-bridge-lean/verification-report.json) · [axioms](hug-navier-bridge-lean/axioms.json) · [inputs and run](hug-navier-bridge-lean/source.json) · [earlier report](../../lean/hug-navier-bridge-lean/verification-report.json) |
| [hug-navier-full-audit-lean](../../lean/hug-navier-full-audit-lean/) | 7 | PASS | [fresh report](hug-navier-full-audit-lean/verification-report.json) · [axioms](hug-navier-full-audit-lean/axioms.json) · [inputs and run](hug-navier-full-audit-lean/source.json) · [earlier report](../../lean/hug-navier-full-audit-lean/verification-report.json) |
| [hug-navier-single-system-lean](../../lean/hug-navier-single-system-lean/) | 10 | PASS | [fresh report](hug-navier-single-system-lean/verification-report.json) · [axioms](hug-navier-single-system-lean/axioms.json) · [inputs and run](hug-navier-single-system-lean/source.json) · [earlier report](../../lean/hug-navier-single-system-lean/verification-report.json) |
| [hug-navier-wellposedness-lean](../../lean/hug-navier-wellposedness-lean/) | 4 | PASS | [fresh report](hug-navier-wellposedness-lean/verification-report.json) · [axioms](hug-navier-wellposedness-lean/axioms.json) · [inputs and run](hug-navier-wellposedness-lean/source.json) · [earlier report](../../lean/hug-navier-wellposedness-lean/verification-report.json) |
| [hug-v3-proof-attempt](../../lean/hug-v3-proof-attempt/) | 6 | PASS | [fresh report](hug-v3-proof-attempt/verification-report.json) · [axioms](hug-v3-proof-attempt/axioms.json) · [inputs and run](hug-v3-proof-attempt/source.json) · [earlier report](../../lean/hug-v3-proof-attempt/verification-report.json) |
| [hug-v3-hybrid-lean](../../lean/hug-v3-hybrid-lean/) | 9 | PASS | [fresh report](hug-v3-hybrid-lean/verification-report.json) · [axioms](hug-v3-hybrid-lean/axioms.json) · [inputs and run](hug-v3-hybrid-lean/source.json) · [earlier report](../../lean/hug-v3-hybrid-lean/verification-report.json) |
| [hug-v3-source-lean](../../lean/hug-v3-source-lean/) | 9 | PASS | [fresh report](hug-v3-source-lean/verification-report.json) · [axioms](hug-v3-source-lean/axioms.json) · [inputs and run](hug-v3-source-lean/source.json) · [earlier report](../../lean/hug-v3-source-lean/verification-report.json) |
| [hug-v3-transfer-lean](../../lean/hug-v3-transfer-lean/) | 14 | PASS | [fresh report](hug-v3-transfer-lean/verification-report.json) · [axioms](hug-v3-transfer-lean/axioms.json) · [inputs and run](hug-v3-transfer-lean/source.json) · [earlier report](../../lean/hug-v3-transfer-lean/verification-report.json) |
| [hug-v3-delay-lean](../../lean/hug-v3-delay-lean/) | 9 | PASS | [fresh report](hug-v3-delay-lean/verification-report.json) · [axioms](hug-v3-delay-lean/axioms.json) · [inputs and run](hug-v3-delay-lean/source.json) · [earlier report](../../lean/hug-v3-delay-lean/verification-report.json) |
| [hug-v3-full-delay-proof](../../lean/hug-v3-full-delay-proof/) | 14 | PASS | [fresh report](hug-v3-full-delay-proof/verification-report.json) · [axioms](hug-v3-full-delay-proof/axioms.json) · [inputs and run](hug-v3-full-delay-proof/source.json) · [earlier report](../../lean/hug-v3-full-delay-proof/verification-report.json) |
| [hug-v3-memory-rules-lean](../../lean/hug-v3-memory-rules-lean/) | 17 | PASS | [fresh report](hug-v3-memory-rules-lean/verification-report.json) · [axioms](hug-v3-memory-rules-lean/axioms.json) · [inputs and run](hug-v3-memory-rules-lean/source.json) · [earlier report](../../lean/hug-v3-memory-rules-lean/verification-report.json) |
| [hug-v3-clay-boundary-lean](../../lean/hug-v3-clay-boundary-lean/) | 12 | PASS | [fresh report](hug-v3-clay-boundary-lean/verification-report.json) · [axioms](hug-v3-clay-boundary-lean/axioms.json) · [inputs and run](hug-v3-clay-boundary-lean/source.json) · [earlier report](../../lean/hug-v3-clay-boundary-lean/verification-report.json) |
| [hug-v3-yang-mills-audit-lean](../../lean/hug-v3-yang-mills-audit-lean/) | 20 | PASS | [fresh report](hug-v3-yang-mills-audit-lean/verification-report.json) · [axioms](hug-v3-yang-mills-audit-lean/axioms.json) · [inputs and run](hug-v3-yang-mills-audit-lean/source.json) · [earlier report](../../lean/hug-v3-yang-mills-audit-lean/verification-report.json) |
| [hug-v3-gemini-review](../../lean/hug-v3-gemini-review/) | 77 | PASS | [fresh report](hug-v3-gemini-review/verification-report.json) · [axioms](hug-v3-gemini-review/axioms.json) · [inputs and run](hug-v3-gemini-review/source.json) · [earlier report](../../lean/hug-v3-gemini-review/verification-report.json) |

## What remains unfinished

Each fresh report preserves its original `scope` and `open_items` exactly. In particular, the full single-system Hug–Navier PDE existence/uniqueness target and full Hug v3 hybrid/delayed continuation targets remain open. The A/S and reduced eight-state Hug existence theorems retain their own stated assumptions.

Challenge files may contain placeholders for frozen reference statements. Those are not completed proofs; the checked solution modules supply the proofs for the listed declarations. A passing build does not promote a separate unfinished target.

The 20-statement Hug v3 strain/frame audit is separate from both the real-valued `readJet` example and the explicit abelian field-equation comparison in the [observation package](../../research/ambiguous-observation-lean/README.md). Their [credits and scopes](../../research/ambiguous-observation-lean/CREDITS.md) remain attached to that package.

## Preservation and publication

The original proof sources, target lists, hypotheses, package credits and historical reports remain unchanged. The package index links these fresh reports alongside the earlier reports.

Every package directory here includes the complete fresh report, axiom lists, compiler/Comparator logs, exit codes and source receipt. The artifact ZIP checksums and public-file hashes are listed in `manifest.json` and each package's `publication.json`. Public log copies replace only CI home-directory prefixes with `$CI_HOME`; the mapping retains the original artifact hashes. Reports, axiom lists and source receipts are unchanged. The GitHub run retains the original artifacts and job transcripts subject to GitHub's retention policy.

**Credits:** AI-generated; dictated and directed by NousVolition. Original model, proof and review authorship remains with the package credits. The fresh workflow, evidence collection and publication integration were performed by Codex (OpenAI), directed by NousVolition.

## Reproduce

Open [Core 19 package verification](https://github.com/NousVolition/hug-sims-lean-proofs/actions/workflows/core-package-recheck.yml) and use **Run workflow** on the desired revision. The explicit [19-package selection](../../.github/core-packages.json) and [workflow](../../.github/workflows/core-package-recheck.yml) use the existing pinned verification scripts. Each replay produces its own run-bound artifacts; it does not overwrite these historical receipts.
