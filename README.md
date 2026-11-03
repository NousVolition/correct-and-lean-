# Correct and Lean: research, proofs and verification

This collection brings together the existing A/S and Hug Lean packages, corrected written proofs, and the completed matched-stretch numerical study. It preserves the original equations, the recorded successful checks, the failed attempts and the remaining open claims. These concern several different models; a proof for one does not certify the others.

## Start here

- [Proof and verification status](PROOF-STATUS.md): what each package actually establishes.
- [Lean packages](lean/README.md): source modules, pinned dependencies, build instructions and saved checking records.
- [Corrected Hug v3 proof, revision 2](research/hug-v3/corrected-proof-revision-2/proof.md) ([PDF](research/hug-v3/corrected-proof-revision-2/corrected-proof.pdf)): written local existence/uniqueness and conditional continuation through accepted writes.
- [Hug v3 continuation work](research/hug-v3/continuation-proof/continuation-proof.md): additional written bounds and static checks; the full all-write validity theorem remains unfinished.
- [Matched-stretch final report and seven charts](research/matched-stretch/final-matrix/README.md): all 48 original runs reached t = 0.40; independent numerical auditing passed, while spatial and finest-timestep convergence screens failed.
- [Comparison and audit records](research/comparisons/README.md): the separate Navier–Stokes formal-development audit and A/S comparisons, with their original scope statements.
- [File provenance and SHA256 manifest](provenance/files.json).

## How to read “verified”

**Lean-checked** refers to the exact declarations, assumptions and permitted axioms in a named package. Saved Comparator, Lean-kernel and nanoda records accompany the relevant packages. This publication checks the collected files and their recorded evidence; it does not claim a new Lean build.

**Written proof** refers to the mathematical argument in the document. It is not automatically a Lean certificate. **Numerical verification** checks the saved computations and reporting; it is not a proof that unresolved approximations follow the exact continuum solution.

The full Hug v3 continuation through every scheduled memory write is still open. The Yang–Mills comparison package is not a solution of the Clay Yang–Mills mass-gap problem. The numerical study does not prove a continuum PDE theorem or a physical stability threshold.

## Preservation and use

Existing research files are copied byte for byte. Their historical local paths, chronology, failed builds, reference challenges and unfinished targets are retained. Use the navigation above for current status; an older README may describe work later extended by another package. Compiler caches, downloaded dependencies and unrelated ongoing work are not included. The original simulation field archive remains at its existing location; the numerical collection contains the published report, summarized data, source, result records and verification evidence.

Each Lean directory has its own `lean-toolchain`, `lakefile.toml` and lockfile. Follow that package's README and default targets. Historical verification scripts may contain machine-specific paths. This collection is not a single combined executable model, and no new equations or simulations were introduced to publish it.
