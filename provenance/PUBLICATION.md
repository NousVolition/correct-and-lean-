# Public evidence and provenance

The [publication map](publication-map.json) pairs each revised historical file with its SHA-256 at the collection revision and its SHA-256 in this edition. Its paths are relative to the repository. The original collection is commit `fda9dd0f916e4f9c737597d3e75190384a9206ed`. A digest recorded by an earlier run refers to the bytes available at that revision. The original Git history remains public.

## What changed in this edition

Personal Windows, WSL and Linux home paths have been removed from the public copies. Published inputs have repository-relative paths. The label `external-source/<id>/<name>` identifies an input held outside this collection. The ID derives from its original location. Its content digest, when supplied, is the way to check a proposed copy. In transcripts `$VERIFY_ROOT` stands for the historical verifier directory. These edits change the bytes of affected evidence files.

Each Lean package now has a [six-field verification report](../scripts/verification-report.schema.json). The original 39 packages keep their prior receipts in `evidence-linux/historical-report.json`. The later SIMS meeting package preserves its earlier Linux artifacts in [evidence history](../lean/sims-meeting-thread-lean/evidence-history/). The [original inventory](files.json) and dated receipts still describe the original run. The current verification-input manifests identify the distributed sources, including the updated Apple default target and comment edits made for the literal-token gate. Five generated Python bytecode paths absent from the distributed Clay-boundary package have been removed from its active input lists. The historical hashes remain recoverable at the collection revision.

## Replaying historical tools

The [current CI instructions](../lean/README.md#reproduce-the-checks) use pinned tools and a fresh evidence directory. The earlier package scripts accept `VERIFY_ROOT` and default to the invoking user's `verification` directory. Historical audit and rendering programs that depend on external inputs accept those locations through environment variables.

| Archived procedure | External inputs |
| --- | --- |
| Proof review and rendering | `PROOF_WORKSPACE`, `PROOF_PACKAGE`, `PROOF_ATTACHMENT`, `PROOF_DEPS`, `PROOF_SKILL`, `PROOF_NODE_MODULES`, as used by the chosen script |
| Matched-stretch numerical audit | `MATCHED_STRETCH_STUDY`, `MATCHED_STRETCH_WORKSPACE`, `MATCHED_STRETCH_BASELINE`, as used by the chosen script |
| Yang–Mills source preservation | `HUG_CORPUS_FILE` supplies the corrected corpus for the hash check. `HUG_SOURCE_ARCHIVE` optionally supplies a second copy of the sealed source tree. |

GitHub Actions uploads new reports as run artifacts. Each artifact records the checks on that commit separately from the historical evidence stored here.
