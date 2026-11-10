# Proof and research status

## Results with recorded formal verification

- **A/S, seven-coordinate model:** the original 30 scoped claims are in `as-lean`; `as-existence-lean` subsequently records continuous integral evolution on every finite interval under the original assumptions; `as-invariance-lean` records the stated meaning bounds and nonnegative loads. These later packages address some earlier open items. Repeated-encounter coupling, the suppression-comparison claim, numerical-error certification and empirical validation are not established by these receipts.
- **Primary directional Hug, eight-state model:** `hug-existence-lean` records existence, uniqueness and guard preservation for every finite forward horizon with continuous prescribed force and admissible initial guards. This is a specific reduced model, not the full structural-memory v3 system.
- **Full Hug v3 components:** the source, transfer, hybrid, delay, memory-rule, boundary and supplied-proof packages establish the particular statements identified in their reports. For example, the transfer record has 14 checked transfer statements; the supplied-proof review records 77 repaired supplied statements. Counts across packages overlap and must not be added into a count of independent results.
- **Yang–Mills comparison:** 20 specified comparison statements passed in the recorded audit. Full Yang–Mills structure, dynamical equivalence and the mass-gap theorem are not proved.

## Written and incomplete work

- The [corrected revision-2 proof](research/hug-v3/corrected-proof-revision-2/proof.md) is a written conditional proof. Its [completion record](research/hug-v3/corrected-proof-revision-2/testing-packet/completion.json) records 19 targeted checks, no Lean/nanoda run and no unconditional continuation theorem.
- The [continuation argument](research/hug-v3/continuation-proof/continuation-proof.md) adds bounds for the unchanged full fixed-grid system. Its [static checks](research/hug-v3/continuation-proof/checks.json) preserve 21 sealed source files and include a rejected-write example. That example is not proved reachable from the prescribed initial state; it shows why readability and a budget bound alone do not guarantee an accepted write. Actual-trajectory bounds and write success remain obligations.
- The Hug–Navier PDE packages explicitly record partial or incomplete well-posedness work. Their `FullModel.lean` targets must not be mistaken for completed proofs.

## Numerical research

The SIMS restaurant trials gave a mean of 1.542 simulated seconds from Traveller A's first unsure report to identification of order 31. In the five paired Traveller B meetings, only one pair identified the pager in both conditions. The Lean package shows how later accepted evidence can resolve an earlier event at the same cue. It also checks the recorded basin circulation signs and the continuity of the eight-refill checkpoint chains. [SIMS two-memory, meeting and basin results](lean/sims-meeting-thread-lean/)

The [matched-stretch study](research/matched-stretch/final-matrix/README.md) contains 48 runs with 41 saved times each through t = 0.40. Its independent auditing passed. The finest-grid W curves differ by 46.7880%; halving the finest timestep changes the W curve by 7.4987%, and the complete final velocity fields differ by 41.2147% in relative L2. These are disagreements between approximations, not measured errors against a known exact solution. Small budget residuals do not establish convergence.

The original publication's payload checks and GitHub CI results are retained in [evidence](research/matched-stretch/evidence/). They refer to the original publication commit, not to a fresh numerical or formal run in this repository.

## Full records

See the [package index](lean/README.md) for every original status, and [provenance](provenance/files.json) for exact file identities. This overview does not replace the hypotheses and limitations in those records.
