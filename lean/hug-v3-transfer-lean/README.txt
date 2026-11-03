Verification package, 1 November 2026

Start with transfer-report.md and pasted-as-review.md.
The current verified status is verification-report.json.

V3TransferProofs.lean proves 14 local claims over the unchanged full Hug v3 definitions.
pasted-as-review/RepairedASProofs.lean proves all 44 unchanged statements from the separate older A/S paste.
The original pasted module and its failed build log are preserved beside the repaired copy.
Do not interpret either set as a proof of full Hug v3 existence and uniqueness.

The *Challenge.lean modules deliberately contain reference-only placeholders for Comparator.
Neither solution imports its challenge. Comparator checks both kernels and allows only
propext, Quot.sound, and Classical.choice. Solution proof files have no placeholders.

evidence-linux contains fresh full-model Comparator and Lean logs.
pasted-as-review/evidence-linux contains the independent 44-statement check.
numerical-evidence contains the fresh post-first-write full state and local RHS comparisons.
sources/results contains the unchanged main simulation's complete output.
Source definitions, sealed main parameters, all six agents and every state block were retained.

source-audit.json and source-map.json were inherited unchanged from the earlier nine-claim
source-transcription audit; their historical test count is not this run's count.
Use comparator.json, verification-report.json and the fresh logs for the current 14-claim run.

The supplied scripts describe the exact configured WSL environment used here. They require
the pinned Lean/mathlib/Comparator dependencies plus Landrun, lean4export, and nanoda.
Dependencies and binaries are identified by hashes in each evidence-linux/preflight.json.
The scripts require a new check directory and preserve prior evidence.
Numerical output and evidence directories must also be fresh for a repeated numerical run.
