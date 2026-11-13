<a id="combined-observation-and-residual-theorem"></a>

# Matching readings can hide different equation results

**A worked example with a Lean-checked proof.** Two fields can give matching readings in one slice of space—even matching their slopes—while only one satisfies the equation being tested.

Picture a level straight line and a U-shaped curve at its bottom. They can have the same height and a flat slope there. Checking how the slope changes reveals the difference. That is a way to picture the comparison used here.

## What the example shows

In the selected part of each field, the readings at the shared slice are:

| What we read | Field A | Field B |
| --- | ---: | ---: |
| Value | 0 | 0 |
| Slope across the slice | 0 | 0 |
| How that slope changes | 0 | 2 |
| Leftover when checked against the equation | 0 | 2 |

The equation is the rule being tested. Its **residual** is the leftover after putting a field into that rule. Zero means it balances. Here, A satisfies the equation, while B leaves 2 in the tested component and fails it.

The proof connects the last two rows: **for these two fields, the extra reading gives exactly that equation leftover.** Matching the first two readings therefore does not settle whether the field satisfies the equation.

## What Lean checked

Lean checked the mathematical statement for the two explicit formulas below. At every point of their shared slice, all field values and first derivatives match; the selected second-derivative readings differ and equal the respective residuals, 0 and 2.

The main theorem and eleven supporting results passed **local Lean compilation and an axiom audit on 12 November 2026**. The [saved audit](logs/CombinedAxioms.log) lists all twelve results and their standard axiom dependencies. This package checks the formulas and proof; the fluid-simulation studies have their own measurements and verification records.

The title above describes this example in everyday words. Its exact Lean identifier remains `YangMillsCombined.combined_observation_and_residual`.

**AI-generated; dictated and directed by NousVolition.** [Sources and credits](CREDITS.md).

<details>
<summary>Exact formulas, proof statement, sources and verification details</summary>

**Recorded local Lean check: PASS (12 November 2026).** The package used Lean 4.34.0-rc2 and Mathlib commit `85e3a25e006c35636f0e53b0e9296caca2685bc0`.

The original [real-valued readJet example](../ambiguous-observation-lean/YangMillsInstance.lean) and [abelian field-equation example](../ambiguous-observation-lean/YangMillsCueTest.lean) retain their own files, claims and evidence. The dependency copies here have the same bytes.

## What the theorem says

Use the existing potentials, with coordinates numbered 0 through 3:

```text
A(x) = (-2, 0, 0, 0)
B(x) = (-2, 0, x₁², 0).
```

At **every point p with p₁ = 0**, the theorem proves:

1. All four potential components agree.
2. Every first coordinate partial derivative of every component agrees (all sixteen pairs).
3. The order-zero and order-one `readJet` measurements of component 2 along the transverse path `p + t e₁` agree.
4. The order-two readings equal the respective second transverse partial derivatives `∂₁∂₁ A₂` and `∂₁∂₁ B₂`.
5. Those readings also equal the respective residual components `R₂(A) = 0` and `R₂(B) = 2`, so the residuals differ.

| Component-2 measurement at p₁ = 0 | A | B |
|---|---:|---:|
| Value / order-zero readJet | 0 | 0 |
| First transverse derivative / order-one readJet | 0 | 0 |
| Second transverse derivative / order-two readJet | 0 | 2 |
| Field-equation residual R₂ | 0 | 2 |

`transverseReading` calls the **imported** `YangMillsInstance.readJet`. The input path has truncation order **m = 1**, while the readout derivative order **n** is independently 0, 1, or 2. This is intentional: the path is linear, but the test `B₂` is quadratic. At the slice, the measured functions are `0` and `t²`; the second derivative of `t²` is **2**, not its quadratic coefficient 1.

The residual definition is imported unchanged from `TwoMemoryTransport`:

```text
Rⱼ(A) = ∑ᵢ ∂ᵢ(∂ᵢ Aⱼ − ∂ⱼ Aᵢ).
```

The identification of one second derivative with one residual component is proved for these explicit potentials. It is not asserted for arbitrary potentials. B fails the source-free field equation; this is not a pair of Yang–Mills solutions, a mass-gap result, or a result about the upstream submission's admissible families.

## Source and attribution

- `curve` and `readJet` were copied from the [upstream Yang–Mills source](https://github.com/yang-mills-group/YM/blob/55ba9fc36293b3f4d52c6b1f813169a0be76ee98/submissions/openai-20261028/submission/YM/Pert/Position/Implicit.lean), as recorded in `YangMillsInstance.lean`'s header. This package uses that imported definition.
- The `YangMillsInstance.lean` instance file was **NousVolition’s draft, compiled by Codex**, following the supplied attribution correction.
- The field pair is in the repository's [YangMillsCueTest.lean](https://github.com/NousVolition/hug-sims-lean-proofs/blob/main/research/ambiguous-observation-lean/YangMillsCueTest.lean), where the added transverse coefficient is labelled **“an explicit test choice.”** That label is retained as the provenance of the added transverse coefficient.
- The combined theorem, audit file, and new verification are by **Codex (OpenAI), directed by NousVolition**. See [CREDITS.md](CREDITS.md) for the retained earlier context and corrected attribution.

All five imported mathematical source files are byte-for-byte preserved. Their provenance and hashes are recorded in [verification.json](verification.json). Existing files in the earlier package were read only; this work created a separate package.

## Recorded local checks

- Freshly compiled `Volterra`, `TwoMemory`, `TwoMemoryTransport`, `YangMillsInstance`, and `YangMillsCueTest` into an isolated, initially empty object directory.
- Compiled `YangMillsCombined` against those newly built local objects; checked the resolved import paths and recorded their hashes.
- Compiled `CombinedAxioms`, which prints axiom dependencies for **all twelve** new named theorems and lemmas and the type of the final theorem.
- All twelve reports use only `propext`, `Quot.sound`, and `Classical.choice`; none contains `sorryAx` or a custom axiom. Source scans found no proof placeholders, custom axiom declarations, `native_decide`, or `implemented_by` in the seven Lean files.
- Verified the pinned compiler's binary hash and Mathlib commit; tracked Mathlib sources were clean. Verified final delivered sources and logs against the test receipts.

The compilation log contains two nonfatal unused-simp-argument warnings in the new file. Imported files retain their existing warnings. These are linter warnings, not missing proofs.

These logs record the local Lean compilation and axiom audit on 12 November 2026. Publication preserves that evidence; it does not turn it into a fresh GitHub Lean build or an independent-kernel check. Simulations and the full upstream submission were not rerun.

The result is **not axiom-free**: all twelve new results use `propext`, `Quot.sound`, and `Classical.choice`. No `sorryAx` or custom axiom appears.

Published logs replace machine-specific paths with portable labels. [publication-changes.json](publication-changes.json) records the original and published hashes; [verification.json](verification.json) retains both log hashes. All seven Lean files have their exact tested bytes, and the original local package remains preserved.

## Files and reproduction

- [YangMillsCombined.lean](YangMillsCombined.lean): the new theorem and its supporting lemmas.
- [CombinedAxioms.lean](CombinedAxioms.lean): the complete new-result axiom audit.
- [logs/CombinedAxioms.log](logs/CombinedAxioms.log): actual audit output and final theorem type.
- [verification.json](verification.json): compiler, source, object, and log evidence.
- [manifest.json](manifest.json): SHA-256 hashes of the delivered package files.

With Lean/Elan and Git installed, the included Lake configuration pins the checked versions. To build in this directory:

```text
lake update
lake exe cache get
lake build
```

The checks recorded here used the already installed pinned Mathlib environment and direct Lean compilation. These fresh-install Lake commands were not executed in this package. The receipt records the actual commands used.

## Documentation history

On 13 November 2026, the display title and introductory explanation were updated. The Lean identifiers, seven Lean source files, logs and verification receipt retain their tested bytes. The current manifest updates only this README's hash; the [earlier manifest](https://github.com/NousVolition/hug-sims-lean-proofs/blob/f161358d497a397078c361897763d777526c129c/research/combined-yang-mills-lean/manifest.json) records the preceding documentation.

</details>
