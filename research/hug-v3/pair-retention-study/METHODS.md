# Publication and reproduction scope

This is the next finite window, after the write at tick 41 (time 1.2) through time 1.3. It is distinct from the earlier gap study and its newer every-step audit. Pair 25 is fixed pair ID24, observer slots 825 and 850. The simulation retains threshold 0.015, breathing on and the original 384 material points; the intended underlying unforced system and the threshold-1 experiment retain their own scope.

## Files that can be rechecked here

The sibling `pair-retention-lean/source-data` directory holds the complete recorded memory payloads, local budget tables, global ledgers and original run receipts. This directory adds the pair positions, controlled-repeat payloads, original audit, failed-account receipt, diagram, declared plans and original measurement scripts. `publication-manifest.json` identifies their exact bytes. `provenance.json` maps original local evidence labels to public paths. The original local Lean receipt is unchanged.

From this directory, using Python 3.11+ with NumPy installed:

```
python verify_publication.py --self-test
python ../pair-retention-lean/check_certificate.py --self-test
```

The dedicated GitHub workflow runs these saved-data checks, installs the pinned Lean 4.34.0-rc2 release, compiles all four proof modules in a fresh copy and compares every fingerprint, target and axiom dependency with the preserved receipt. It keeps a separate receipt identifying the GitHub source revision and run. No Comparator or nanoda result is claimed for this package.

## What remains local

Full entry/exit state snapshots and the older full-history checkpoints are preserved locally. Their hashes and per-array inventories are published, but the large snapshots are not included. The original files under `source/` retain the workspace-relative layout used for the simulations; they are an exact methodological archive, not a standalone runner for this published subset. They need those original full-state checkpoints and the solver files identified in the earlier [finer-grid source record](../finer-grid-study/source/README.md). No simulation is rerun by the publication workflow.

The original audit compared all 17 entry/exit state arrays and every saved pair position during the controlled readout correction. GitHub can newly compare the published pair positions, observed values, payloads and recorded array fingerprints, but cannot independently replay or compare the omitted state snapshots. Runtime memory extrema remain recorded observations. The 51 saved times do not establish all-time physical retention.

The original failed 40-grid account remains a failure at the unchanged 1e-6 target. The cell-crossing correction is a separate controlled result. Closing the local account does not establish that original physical contents remain: equal incoming replacement can balance outgoing content. The finite Lean counterexample makes that limitation explicit.

The original plan ends with the then-current local-only delivery scope. Publication was subsequently requested; the original plan and local receipt are preserved as historical evidence.

**AI-generated; dictated and directed by NousVolition.**
