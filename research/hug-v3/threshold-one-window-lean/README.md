# Threshold-1 recorded window comparisons in Lean

**Lean checks the supplied saved numbers; it does not prove the fluid trajectories.** This package adds 23 finite statements about the [published threshold-1 window investigation](../threshold-one-window-study/README.md), which answers the viewing-window question linked from [PR #14](https://github.com/NousVolition/hug-sims-lean-proofs/pull/14). All 23 passed Lean's kernel locally, with empty axiom-dependency lists, and the Lake build passed. The [receipt](receipt.json) and [compiler/axiom logs](evidence/) record that execution. A dedicated [GitHub workflow](../../../.github/workflows/threshold-one-window-lean.yml) repeats the checks on Linux and publishes a separate run receipt.

The physical configuration and numerical records are unchanged: the same threshold-1, 16³, breathing-on history and three late saved exchange brackets. The original model's unforced meaning is preserved; the breathing branch is a numerical intervention. No new fluid simulation or line integration was performed for these Lean checks. The threshold-0.015 energy proofs and earlier finite-window package remain separate results.

## What is checked

The six windows are `[0, 0.75]`, `[0, 1.5]`, `[0, 3]`, `[-0.75, 0.75]`, `[-1.5, 1.5]`, and `[-3, 3]`, in cube lengths relative to A. The input contains 40 normal observation times and six tighter-tracing observations at the two saved sides of each of the three late brackets.

| Recorded property | Lean check |
| --- | --- |
| Coverage and representation | 40 distinct sample labels, six windows, 12 proper nested-window pairs, six tighter samples, positive common decimal scale, and 1,995 saved normal candidates |
| Each of the 240 normal selections | Positive recorded gap, selected signed arclength within its window, selected pair present in its saved candidate list and no greater gap than any listed candidate |
| Every saved normal candidate | Signed arclength lies within the stated window |
| Nested windows | All 480 recorded comparisons have nonincreasing selected gap as the window grows |
| Three late brackets, both sides | All 18 bidirectional-window selections have negative signed arclength and strictly smaller recorded gaps than the original forward-0.75 selection |
| Backward-0.75 improvement | All six recorded improvements exceed 0.0002 cube lengths |
| Saved bracket endpoints | Each positive time width is at most `2e-9`; original forward selected arclengths change by more than `0.1`, while all nine bidirectional endpoint changes are below `2e-6` |
| Forward extensions | For the first two brackets, forward-1.5 selects beyond `0.75` with a smaller gap on both sides; at the third bracket, forward-1.5 and forward-3 retain the original recorded selection, whose left side is A |
| Larger bidirectional view | Both-3 improves on both-1.5 on both sides of the first two brackets; their recorded selections agree on both sides of the third |
| Tighter tracing records | Labels and times align; all 36 distance differences are at most `2.20e-13` and all 36 signed-arclength differences are at most `6.68e-13` |

These are 23 named declarations, including coverage and supporting checks, not 23 independent discoveries. Their exact statements are in [WindowRecordChecks.lean](WindowRecordChecks.lean); the fixed target list and scope are in [certificate.py](certificate.py). The nine small bidirectional endpoint differences are **not a continuity theorem** and do not rule out intervening changes.

## Source binding and trust boundary

[source-inputs.json](source-inputs.json) pins the SHA256 of `measurements.json`, `measurements.csv`, `measurements-tight.json`, and `measurements-tight.csv` from repository commit `a4cc130568fe8318b809ab795709df427dc1653f`. The source commit identifies the numerical publication; matching file hashes allow later documentation-only changes without relabelling the data.

[generate.py](generate.py) verifies all four file hashes, checks JSON/CSV agreement and expected coverage, then reads the written decimals using Python `Decimal`, without converting them through binary floating point. It writes integer constants with common denominator **10¹⁹**. Every input decimal used by a theorem is represented exactly; this does not make a saved floating-point measurement an exact physical quantity. Regeneration must reproduce [WindowRecordData.lean](WindowRecordData.lean) byte for byte.

The Lean definitions and finite comparisons use only core Lean. Every theorem is proved with `by decide` and checked by Lean's kernel; `native_decide`, proof holes and added axioms are refused. [CheckAxioms.lean](CheckAxioms.lean) reports all 23 targets, each with no axiom dependencies. There is no Mathlib dependency. Comparator and nanoda were not run for this package.

The source hashes, CSV/JSON agreement, integer transcription, receipt validation and log fingerprints are **external Python checks**, not Lean theorems. The kernel checks the generated constants and statements. Hashes bind those constants to a reproducible transcription of the saved inputs; they do not verify the original solver, tracing routine, optimizer or provenance of a physical experiment.

## Reproduce the checks

Use Python 3.10 or later (standard library only) and the pinned **Lean 4.34.0-rc2**, with its matching Lake executable. From this directory:

```sh
python -B generate.py
python -B check_receipt.py
python -B -m unittest test_certificate.py
python -B verify.py --lean /path/to/lean-4.34.0-rc2/bin/lean --work-dir /tmp/threshold-one-window-check
python -B check_receipt.py --fresh /tmp/threshold-one-window-check/receipt.json
```

Choose a separate disposable build directory outside this package and the numerical study; on Windows, pass the full path to `lean.exe`. `verify.py` copies the exact proof inputs, checks the generated constants, compiles all modules, audits all target dependencies and runs `lake build`. It writes a fresh receipt and logs only in that build directory. A failed compile or missing/nonempty axiom report prevents a passing receipt.

The six refusal tests exercise missing targets, a failed compiler result, an added axiom dependency, a stale source fingerprint, a changed input file and a missing axiom report. The read-only receipt check verifies the fixed target inventory, all source/proof hashes, generated input and saved log hashes. It is not itself a new Lean run. For the numerical replay and its larger dependencies, use the [original numerical reproduction instructions](../threshold-one-window-study/README.md#evidence-and-reproduction).

The dedicated workflow uses the repository's pinned official Lean release archive and checksum, compiles in a separate directory and uploads the fresh receipt, compiler logs and GitHub execution context. Its evidence records the actual checkout and pull-request head separately. The committed local receipt remains a historical local result, not a GitHub run receipt.

## What remains unproved

The selected gap is minimal only among each **finite saved candidate list**. No theorem here says those candidates cover a continuous vorticity line, that the numerical values approximate it within a certified error, or that a global closest point was found. The tighter-pass comparisons bound disagreement between two written datasets, not error relative to a known true trajectory.

No fluid-solver correctness, line-integrator correctness, continuous-time closest-point exchange, trajectory, closed circulation, disconnection or reconnection theorem is supplied. Spatial refinement, full-history convergence and behavior outside the saved times remain open. The existing threshold-0.015 energy checks do not transfer to these measurements; this package supplies only the separately stated threshold-1 recorded-number checks.
