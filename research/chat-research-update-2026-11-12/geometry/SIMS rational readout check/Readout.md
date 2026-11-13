# Check of the pasted rational SIMS suite

The exact pasted version failed compilation. The separate corrected version passes all 32 named theorem checks in the same pinned Lean/mathlib environment used for the earlier real-number version.

| Version | Newly observed result |
|---|---|
| Exact attachment, preserved in `SIMSLatentReadout.lean` | FAIL: two rational arithmetic proofs using `decide` did not reduce. |
| Separate `corrected/SIMSLatentReadout.lean` | PASS: compiler exit 0; all 32 axiom reports checked. |
| Archived real-number package | All 94 manifest entries, including 84 frozen input files, match their recorded hashes. No files in that package were changed. Its earlier compilation remains historical evidence. |

The failing proofs were `clay_changes_while_sign_stays` and `clay_relative_change`, at lines 38 and 43 of the pasted file. In this environment, `decide` became stuck while reducing rational expressions. Lean's error recovery then reported `sorryAx` for these declarations and the theorem that depends on the first. Merely receiving 32 axiom reports therefore did not mean 32 valid proofs.

The corrected copy uses `norm_num` for those two arithmetic proofs. It also replaces the deprecated `if_pos` name with `ite_eq_left`. Every theorem statement, definition, saved case and weight trace is unchanged from the pasted rational version. The correction retains the exact clay values −1/50 and −12/625 and their 4% relative change.

The successful check finished at 9:36 p.m. Pacific on November 11, 2026. It used Lean 4.34.0-rc2 and mathlib commit `85e3a25e006c35636f0e53b0e9296caca2685bc0`. The checked dependencies are `propext`, `Quot.sound` and `Classical.choice`; there are no custom axioms, proof placeholders or `native_decide` calls in the corrected source. Rational arithmetic does not make this file free of all axioms.

The pasted generated literals and finite checks match the archived version. The surrounding translation script was inspected, and frozen input hashes were checked; JSON translation, file storage and the compiler executable are not themselves proved correct by these theorems. No new model replies or fluid simulations were produced.

## What this contributes to the Hug discussion

- A reading can remain the same while the underlying state changes. The clay example is a controlled numerical fixture, not a measurement from the Hug trajectory.
- A record can survive perfectly while a reader interprets it incorrectly. The saved filed-reader results retain the three contradictions in C02, C04 and C06; passing the proof does not repair those historical answers.
- If none of the supplied explanations fits, the suite returns no surviving explanation. The zero-total update gives all-zero weights, which are not a normalized probability distribution.

These are useful rules for auditing how the meaning travelled between conversations. They do not establish where Grok, OpenAI or the user first meant different things, what caused the closest-point switch, or whether breathing explains the fluid results. Both interpretations of “the earlier step” remain open.

The general numerical statements in this revision quantify over rational numbers. Their successful check does not extend them to every real value or verify floating-point execution. The original real-number package remains separate.

## Evidence files

- `SIMSLatentReadout.lean`, `lean-check.log`, `verification.json`: exact paste and failed compilation evidence.
- `corrected/SIMSLatentReadout.lean`, `corrected/lean-check.log`, `corrected/verification.json`: corrected source and successful verification evidence.

Exact pasted SHA-256: `dab94258fd9d1ced17b880c63ccef58702d1694d76f0f6e838ed84b36e0bd909`.

Corrected SHA-256: `37b84f3dc6192262aa15840af6ab5cb79b12a0a76fcd1e43e061dd1e69b75ce4`.
