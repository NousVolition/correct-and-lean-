# Checked supplied Lean components

77 original theorem statements PASS after recorded import/proof repairs.
Lean build and Comparator with Lean + nanoda both succeeded.

Read Lean-review.md for the precise scope. This is not a full Hug v3
delayed fluid-transfer existence/uniqueness theorem.

Files:
- Four repaired modules: HugV3InterEventProofs, ASProofs,
  CombinedASHugProofs, DelayedReflexASProofs.
- Unchanged ASModel and scalar V3EventSpecification dependencies.
- AllGeminiProofs imports all four repaired modules; it is the default Lake target.
- originals preserves all four attachments and the earlier LaTeX.
- proof-repairs.diff and preservation-checks.json record repairs/preservation.
- GeminiChallenge contains frozen reference statement placeholders only.
  It is not imported by the solution. Comparator rejects sorryAx in solutions.
- evidence-linux and verification-report.json contain fresh checks and scope.
- The old failed ASProofs log is explicitly marked historical in originals.

`lake build` builds the four-module solution using the pinned toolchain and dependencies.
`run-linux-check.sh` reproduces the original isolated audit on this machine's
existing verifier setup, with a fresh output directory as its optional argument.
Its absolute verifier paths are local environment settings, not portable installs.
Mathlib, the compiler, Comparator and nanoda binaries are not bundled.

Original full Hug v3 files live in the separate existing source/delay packages
and were checked for preservation; they were not replaced by this smaller model.
