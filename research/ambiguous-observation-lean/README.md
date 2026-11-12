# Ambiguous-observation instances and an abelian field-equation comparison

The original three instance files compile with Lean 4.34.0-rc2 and Mathlib commit `85e3a25e006c35636f0e53b0e9296caca2685bc0`. The added abelian-potential comparison and its local dependencies have now been freshly recompiled in the same pinned environment. No proof step required correction.

| File | What Lean checks | Axiom reports |
|---|---|---|
| `Pair25Instance.lean` | Equal endpoint counts cannot determine either selected observer's membership; the specified intermediate count is 365. | 5 reports, no axioms |
| `Tick41Instance.lean` | The exact rational summaries have equal accumulator values, different rates and record flags, and the stated rate jump; the value alone cannot determine either property. | 5 reports, standard axioms only |
| `YangMillsInstance.lean` | Order-zero `readJet` depends only on leading coefficients; the real projection at truncation order 1 has equal order-zero readings but unequal order-one readings, preventing a universal exact reader. | 6 reports, standard axioms only |

The standard axioms reported are `propext`, `Quot.sound`, and `Classical.choice`. No report contains `sorryAx` or a custom axiom. The source scan also found no `sorry`, `admit`, `axiom` declarations, `native_decide`, or `implemented_by`. Compilation produces one nonfatal unused-section-variable warning in `YangMillsInstance.order_zero_reads_only_leading`; its statement and proof were preserved.

## Changes to the drafts

- Pair 25: added the missing opening `/-!` for the introductory comment. The mathematical code is unchanged.
- Tick 41: no source changes beyond saving the supplied text as a file.
- Yang–Mills: no changes to definitions, theorem statements, or proofs. Updated the previously unresolved provenance note and clarified that unequal first-derivative readings concern the projection example at truncation order 1.

`curve` and `readJet` match the [upstream Implicit.lean definitions](https://github.com/yang-mills-group/YM/blob/55ba9fc36293b3f4d52c6b1f813169a0be76ee98/submissions/openai-20261028/submission/YM/Pert/Position/Implicit.lean), ignoring whitespace. They remain copied definitions in a separate namespace; this check does not compile the full upstream submission.

## Scope

Pair 25 and Tick 41 prove statements about the supplied summaries and exact transcribed numbers. This session did not rerun their simulations or verify the transcription, positions, complete label lists, snapshots, or attainability of arbitrary summary states. Pair 25's intermediate-state theorem specifies a count; it does not construct a trajectory or verify crossing times.

`YangMillsInstance` is the real-valued `readJet` projection example. It establishes no result about an admissible Yang–Mills family.

## Separate abelian field-equation comparison

`YangMillsCueTest.lean` compares explicit abelian potentials on four-dimensional Euclidean space. With coordinates numbered 0 through 3, they are

```text
A(x) = (-2, 0, 0, 0)
B(x) = (-2, 0, x₁², 0).
```

Every component agrees on the slice `x₁ = 0`. For the defined abelian residual `Rⱼ(A) = ∑ᵢ ∂ᵢ(∂ᵢAⱼ − ∂ⱼAᵢ)`, the original potential has zero residual in every component; the modified potential has `R₂(B) = 2` everywhere, including the origin. Thus their common slice data do not determine whether this field equation holds. The central theorem is `YangMillsCueTest.same_data_different_field_equation`; `transverse_residual` supplies the exact value 2.

This comparison uses field-equation derivatives. It is separate from `YangMillsInstance`, which compares derivative orders of a real projection through `readJet`. The modified potential fails the source-free equation; this is not a pair of Yang–Mills solutions or a result about the submission's admissible families.

The package includes unchanged copies of `YangMillsCueTest.lean` and its local dependency chain: `TwoMemoryTransport.lean` → `TwoMemory.lean` → `Volterra.lean`. Their hashes match the earlier Ambiguity theorem checks package. `YangMillsCueAxioms.lean` is a new audit file that prints axiom dependencies for eight relevant results, including slice agreement, curvature, both residual facts, and the two loop identities.

**Fresh verification: PASS.** All four copied modules and the audit file compiled using newly built local objects. Import-path checks confirmed that each local dependency resolved to this fresh build. The [compilation log](logs/YangMillsCueTest-cue-fresh.log) records the original three axiom reports; the [expanded axiom log](logs/YangMillsCueAxioms-cue-fresh.log) records all eight audit reports. They use only `propext`, `Quot.sound`, and `Classical.choice`, with no `sorryAx` or custom axioms. Dependency compilation logs are included alongside them.

## Verification and reproduction

`verification.json` identifies the final files by SHA-256 and points to the compilation/axiom logs. `verification-initial.json` records the initial check of all three drafts; `verification-final.json` records the final readJet example after its comment-only update. `verification-cue.json` records the fresh abelian-comparison build, source provenance, and exact dependency objects. The original three instance files and their logs are unchanged; their earlier passing checks are retained without claiming they were rerun during this addition.

The files were compiled individually with Lean using an existing pinned Lake environment whose tracked Mathlib sources were clean. The new dependency chain used a fresh object directory ahead of all pre-existing project paths. The supplied Lake configuration pins the same versions and includes the abelian-comparison modules and audit target. These saved local checks did not install Mathlib afresh or run the standalone Lake build. The dedicated GitHub workflow performs that build and writes a separate receipt tied to the tested source revision. To reproduce from this directory with Lean/Elan and Git installed:

```text
lake update
lake exe cache get
lake build
```

See [CREDITS.md](CREDITS.md) for the distinct roles of NousVolition, Claude, the earlier assistant session, and this Codex compilation session.

## GitHub build and public evidence

The **Ambiguous observation and field equation** workflow installs the repository's checked Lean archive, fetches the pinned Mathlib cache, runs `lake build`, and audits all **51 public named theorems and lemmas** in this package. The count includes supporting results and repeated forms of the general observation rule; it is not a count of 51 independent discoveries. The private helper used by `TwoMemory` is checked transitively through the public proofs.

`CheckAllAxioms.lean` and the CI checker were added by Codex (OpenAI), directed by NousVolition. All eight pre-existing Lean source files and `CREDITS.md` retain their exact local bytes. Existing proof authorship is unchanged. The original three instance drafts remain credited to Claude, and the field-equation proofs to the earlier assistant session.

The public copies of local logs and receipts replace machine-specific paths with portable labels. `publication-changes.json` records original and published hashes; changed log hashes in the receipts were updated. The local originals remain preserved. A GitHub run produces fresh, separate build and axiom logs plus `github-receipt.json`, attached as a workflow artifact. A local PASS is not represented as a GitHub PASS.

Comparator and nanoda are not run by this workflow. It checks Lean compilation and axiom dependencies. It does not rerun the simulator, verify transcription, establish admissible Yang–Mills families, or prove a mass-gap result.

To run the publication fingerprint checks and then the build/axiom audit:

```text
python3 verify_ci.py --check-only
lake update
lake exe cache get
python3 verify_ci.py
```
