# Early rest and a later reading on one fixed loop

[Read the comparison and its scope](../RESEARCH-NOTE.md) · [Reference statements](TemporalChallenge.lean) · [Verification record](verification-report.json)

This separately frozen check uses the same original equation, velocity and clock. `early_loop_zero` follows from OpenAI’s extension by zero before the source clock starts. `same_loop_before_after` selects an offset with a nonzero reading at a sufficiently late time, then checks that same offset at all times in the early interval. There are two Comparator targets in this supplement.

The [runner](run-check.sh) uses the same prepared Linux toolchain as the spatial audit. Run `bash run-check.sh verify` to build the pinned local inputs in an isolated workspace and check the reference and solution with both kernels. [Comparator output](evidence/comparator.log) · [Axioms](evidence/axioms.log)
