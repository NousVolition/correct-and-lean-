# Full tick-41 replay: broad waves, phase and tolerances

**PASS.** A fresh Linux execution carried all seven arms from **prime 41, model time 1.2 after the third write, to 1.22**. It reproduced the published broad-wave response within the tolerance declared before this replay. The entire complex coefficient vectors were compared, so agreement includes phase as well as size.

This is a fresh execution and separately written comparison of the unchanged published solver. It is not a second integrator or an independent human review. The starting state, perturbation and all files in the original source manifest retained their hashes. No saved endpoint or trajectory was an input to the evolution.

## What was rerun

- Grid 32 cubed, threshold 1, breathing off; all original coupling retained.
- The same full after-write-41 state and the same velocity-only fine-band perturbation, with initial RMS equal to 0.01% of the starting velocity RMS.
- Fine waves: `8 <= max(|kx|, |ky|, |kz|) <= 10`. Broad waves: `1 <= max(...) <= 2`, excluding the mean.
- Step sizes 0.0005, 0.00025 and 0.000125, with baseline and full-amplitude arms at each size, plus a half-amplitude arm at 0.00025: seven arms and 640 arm steps.
- No new memory write in this interval. Records 0, 1 and 2 remained readable in every final state.

The original run used Windows, Python 3.12.14, NumPy 2.3.5 and SciPy 1.16.3. This replay used Linux under WSL, Python 3.14.4 and the same NumPy/SciPy versions, with one numerical-library thread. The [protocol written before execution](evidence/linux-2026-11-12/PROTOCOL.json) records the exact runtime, inputs, source hashes and criteria. The [completion receipt](evidence/linux-2026-11-12/RUN-COMPLETE.json) hashes every new run output.

## Measured results

| Check | Fresh result | Criterion or comparison |
| --- | ---: | --- |
| Finest-step broad difference at 1.22 | 4.124655002731452e-12 | Published: 4.124655000767898e-12 |
| Finest-step complex-vector discrepancy at 1.22 | 2.553375636771065e-20 | Allowed: 4.124655000767899e-16 |
| Relative complex-vector discrepancy at 1.22 | 6.190519295057879e-9 | Full vector, without alignment |
| Weighted phase RMS discrepancy at 1.22 | 2.5220832993122943e-7 degrees | Supplemental descriptive measure |
| Largest weighted phase RMS discrepancy after the start | 6.957811520335176e-6 degrees | Half-amplitude arm, time 1.2005 |
| Fine-wave difference reduction by 1.22 | 75.9677789803808% | Same measured decay as the published run |
| Coarse versus medium: maximum relative vector discrepancy after the start | 0.0748553637027013% | Below 1% |
| Medium versus fine: maximum relative vector discrepancy after the start | 0.0184727292719570% | Below 1% |
| Full versus twice half amplitude: maximum relative vector discrepancy after the start | 0.1940092535263685% | Below 1% |

All **164 saved complex-mode snapshots** and **364 broad-wave readings across 283 history rows** passed the replay comparison. All **123 control comparisons** were recorded; their noninitial entries passed the 1% criterion. The largest error used 0.07121% of its permitted replay tolerance. The [machine-readable results](evidence/linux-2026-11-12/comparison/RESULTS.json) and the complete [phase and vector comparisons](evidence/linux-2026-11-12/comparison/complex-mode-comparisons.csv) retain the unrounded values.

## How phase and tolerances were checked

For a published broad-mode vector `reference` and freshly evolved vector `actual`, the replay checks

```text
norm(actual - reference) <= max(1e-17, 1e-4 * norm(reference))
```

This is the existing first-step verification envelope, explicitly extended to every saved full-interval snapshot in the protocol before execution. The 1% step-size and amplitude criteria are retained from the original analysis. None was adjusted after seeing the fresh run. These are numerical acceptance criteria, not a universal error guarantee or a claim that the original experiment was preregistered.

No phase rotation, sign reversal or fitted amplitude is removed before comparison. A synthetic 0.1-radian rotation leaves the vector magnitude unchanged but fails this check, confirming that a magnitude-only agreement cannot pass as phase agreement.

The supplemental angle is the reference-power-weighted RMS of the wrapped coefficient phase differences. Both coefficient amplitudes must exceed 1e-18; the retained reference power is reported for each row. At 1.2, the broad difference is only subtraction roundoff, so the angle is deliberately undefined and the absolute floor governs acceptance. At the finest endpoint the phase calculation retains effectively all reference power. No separate angular pass threshold is invented.

Fresh controls compare complete complex vectors at matching times. The initial near-zero vectors are recorded but excluded from relative control acceptance. The [control rows](evidence/linux-2026-11-12/comparison/fresh-controls.csv) and [broad-norm comparisons](evidence/linux-2026-11-12/comparison/history-norm-comparisons.csv) cover the whole interval. All 119 final-state array comparisons are reported in the [endpoint difference table](evidence/linux-2026-11-12/comparison/endpoint-array-differences.csv); finite values, shapes and readable record IDs were checked, without inventing a common tolerance for arrays with different meanings and units.

## Preserved study links and evidence

The index resolution retains all 44 unique links from PR 23 and all 49 from main: their union is 51 links. The new replay link brings the index to 52 unique links. All 48 local targets were checked against the merged file tree. Both the tick-41 studies and the observer/pair studies remain present. The [resolution receipt](index-resolution.json) records the exact source commits and resulting index hash.

The original study, frozen-field evidence and their manifests are unchanged. The seven unresolved radial precision checks remain unresolved. This replay supports the fine-to-broad response in this numerical configuration; it does not establish spatial convergence, reconstruct the earlier history, identify the source of prior errors, or prove that this response causes the frozen-field return-miss rise.

## Reproduce on Linux

From the repository root, with Python and `numpy==2.3.5 scipy==1.16.3` installed:

```bash
python3 -B research/hug-v3/tick-41-wave-transfer/independent-replay/verify_evidence.py
python3 -B research/hug-v3/tick-41-wave-transfer/independent-replay/replay.py run --output /tmp/tick41-fresh-replay
python3 -B research/hug-v3/tick-41-wave-transfer/independent-replay/replay.py analyze --output /tmp/tick41-fresh-replay
```

Choose an output directory that does not already exist. The run refuses to overwrite an earlier run. The analysis verifies the declared criteria, executed runner hash and all fresh output hashes before comparing with the published reference. A failed criterion makes the command fail.

The checked-in evidence includes the new complex-mode arrays, full history tables, summaries and comparison tables. The seven full endpoint states are retained in the original local replay output and regenerated by the workflow, rather than duplicated here; their hashes are in the completion receipt. The GitHub workflow now repeats the complete interval and uploads its own full outputs and receipts, including endpoint states. Its numerical results are a separate execution and need not have byte-identical output files across platforms.

Execution and comparison code were prepared by Codex at NousVolition's request. This report preserves the distinction between replay verification and validation by another numerical method.
