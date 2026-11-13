# Research collected from recent chats — 12 November 2026

This collection adds completed AS/Hug proof work and saved audits located in recent research chats. It contains **161 Lean source files**, their available proof logs, numerical records, and explicit unfinished claims. These files are a publication snapshot; this collection did not run a simulation or a new Lean, Comparator, nanoda, or Lake check.

**AI-generated; dictated and directed by NousVolition.** Individual source and model credits are retained. [Repository reuse terms](../../LICENSE).

## Fresh verification after this collection

On 13 November UTC (12 November Pacific), nine current check batches passed fresh local Lean, Comparator, Lean-kernel and nanoda checks with the published source equations unchanged. The [dated verification record](../../provenance/chat-package-recheck-2026-11-13/README.md) distinguishes original frozen challenges from published-source rechecks, preserves the two failing original drafts and the failed diagnostic attempt, and keeps the full-system claims open. This follow-up adds new execution evidence; the collection audit described below remains the historical file-identity audit.

## New material collected here

| Work | What the retained evidence establishes | Important limit |
| --- | --- | --- |
| [Signed A/S vortex comparison](vortex/as-signed-vortex-lean/README.md), [line identity](vortex/as-vortex-hline-lean/README.md), [rescaling](vortex/as-vortex-rescaling-lean/README.md), and [edge controls](vortex/as-vortex-edge-control-lean/README.md) | Recorded Comparator, Lean-kernel, nanoda and Lake passes for the stated signed-force and pinned-vortex comparisons. The later packages discharge specific earlier obligations, including the line identity and rescaling. | These results concern the specified force predicate and candidate, with the stated direction and regularity conditions. They do not settle the evolving full Hug material/memory balance. Each package's dated open-item list is historical. |
| [Energy balances and carrying/history accounts](energy/README.md) | Kernel-checked balance identities, conditional storage statements, restricted counterexamples, and saved numerical accounting checks. | The physical energy store needed to close the general A/S account has not been identified by these packages. A defined balancing ledger is not an independently derived physical store. |
| [Observation and vortex-geometry proofs](geometry/README.md) | Particular examples can share specified readings while their vortex lines have different closure properties. | The complete pair with the requested shared evolving history remains **unproved**. The corrected status supersedes the earlier broad existence wording. These mathematical examples do not certify the saved Hug trajectory. |
| [Full-flow journal energy comparison](numerical/full-flow-energy/RESULTS.md) | For the declared A-trusting/B-untrusting case through time 1.3, independent work/heat accounts and time-step checks pass; the initial energy offset is included. [Verification](numerical/full-flow-energy/verification.json). | A finite numerical comparison of the implemented journal model, not a universal conservation theorem or empirical calibration. [Model declaration and source rules](numerical/material-trust-v3/README.md). |
| [Pull after shutoff](numerical/pull-after-shutoff/Hug%20pull%20continuation%20notes.md) and [zero utility from tick 41](numerical/pull-after-shutoff/Zero%20utility%20run%20notes.md) | Saved controls and their verification records show continued energy growth over the tested interval, including the case with fixed accumulated A. | This does not establish indefinite growth or transfer the result to a different branch. |
| [Backward Hug onset audit](numerical/backward-onset/Backward%20Hug%20onset%20and%20cause%20audit.md) | Preserved measurements locate growing velocity error and the later negative-temperature onset; clock corrections and their tests are recorded. | The damaged backward history was not repaired by this audit. The subsequent reconstruction was still being worked on when the chats were reviewed. |

## Recent work already published

These were found on the repository's current main branch and are linked rather than duplicated:

- [A/S suppression comparison](../../lean/as-suppression-lean/README.md): matched inputs and initial data; both S coordinates stay at or below their no-suppression counterparts on the specified finite interval. The repeated-encounter process remains open.
- [Fresh checks of the 19 core packages](../../provenance/core-package-recheck-2026-11-12/README.md), retaining each package's scope.
- [Hug heat-grid study](../hug-v3/heat-grid-study/README.md) and [414 finite Lean checks](../hug-v3/heat-grid-lean/README.md). The recorded grid-settling failure remains a finding, despite the finite record checks passing.
- [Matched-stretch final matrix](../matched-stretch/final-matrix/README.md) and [verification evidence](../matched-stretch/evidence/). The 48-run matrix through time 0.40 remains complete. No newer replacement final matrix was found in the reviewed chats. The spatial and time-resolution failures are retained; a difference between two numerical runs is not a measured error against an exact continuum solution.
- [Combined transverse-derivative example](../combined-yang-mills-lean/README.md) and [threshold-1 finite window checks](../hug-v3/threshold-one-window-lean/README.md), within their recorded scope.

Work on finer heat grids, continuous threshold-1 certificates, the full coupled vortex balance, scalar existence for the same-history construction, and advancing-clock writes was still in progress in the reviewed chats. This snapshot does not turn that work into completed proof evidence. The collection is not a claim that every historical chat or attachment was exhaustively recovered.

## How this publication was checked

[Publication manifest](publication-manifest.json) records each copied file's original SHA-256, published SHA-256, Git blob identity, and any transformation. All 487 available entries in the selected source checksum manifests and reference freezes matched the local files, including checks on retained local artifacts omitted from upload. All 161 Lean sources are byte-for-byte copies. **Those hash checks establish file identity, not a fresh mathematical remeasurement or kernel run.**

Personal home-directory prefixes in public copies of logs, scripts, and metadata are replaced with `$USER_HOME`. The old same-history note has a prominent correction banner. Historical receipts retain their original input hashes; the publication manifest explains which public files differ because of these edits. Original files and receipts remain unchanged locally.

Compiled objects, dependency caches, large raw state arrays, duplicate archives and some duplicate document exports are omitted; omissions are listed. Some historical notes and replay scripts refer to local environments or omitted artifacts. They are not represented as clean, portable rebuilds. The source/hash records and available logs are retained so those limits can be inspected.

Run `python verify_publication.py` in this directory to recheck the published copies against the collection manifest. [Collection verification](publication-verification.json) records what was checked for this publication. Failed original drafts, intermediate attempts and incomplete targets remain labeled in their own records.
