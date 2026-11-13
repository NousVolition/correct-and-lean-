# Trust with lead-up retained in material

Open [the updated meter](index.html). The A/B speck identities and independently chosen trust starts are preserved. The lead-up is now encoded in material cells as the flow develops, read through mechanical probes, and used in subsequent recall. The previous version's software profiles are not an input to either recall or later writing.

This is revision 3 of the local trust extension. It runs the full underlying structural Hug solver, with an explicitly added material journal. It is not a claim that the unchanged original four-slot record format already retained a chronological trajectory. See [the source review](SOURCE-RULES.md) and [the declaration fixed before the full runs](DECLARATION.json).

## The actual write/read path

At initialization and each accepted time step, the writer takes the current sample and appends it to a free material-journal slot. It does not look up older software samples. There are 801 slots for the fixed times `0, .002, ..., 1.6`. Every row encodes:

- The sample clock, the A/B actor IDs and the original seed-12 identity code.
- Context and local strain features for all six actors, allowing the existing event pairs to retrieve their own context/strain prefix.
- A's trust toward B, B's trust toward A, and both three-dimensional speck positions.
- A CRC32 checksum over the complete row.

Each row is 31 signed 16-bit words plus the four checksum bytes: **66 bytes, or 528 bistable cells**. Numerical features, trust and positions use a declared quantum of 0.0001; clocks use the original 0.001 quantum. There is no clipping or rounding of time to a different accepted step. The current run samples at 0.002, so these clocks are exact. Numerical values are retained to half a quantum, not as exact floating-point trajectories.

The journal has **422,928 added cells**, allocated at initialization. The original four event slots retain their original **149,056 cells**, original payload format and original capacity. Total fabric state is **571,984 cells**. The same 384 constitutive material points remain; the additional internal cells are attached to these points using the existing material-address/axis scheme. No material points or storage are created during a run.

The writer checks schema, quantization range, append order, capacity and the supplied work budget before changing the state. Existing entries are not overwritten. The original outcome writes still occur at 0.4, 0.8 and 1.2, after the sample at that time is committed. These events reference their prefix through their existing encoded end time; they do not duplicate an entire history in every event slot.

The reader performs the original two-load traction probe, infers residual strains, tests the original read margin, decodes signs and verifies checksums. It reconstructs the journal solely from the current `F` and `b` arrays. It obtains an event's profile from the material samples from time zero through that event's end. The existing Gaussian relevance and the previously declared duration-normalized prefix weighting then feed the original trust RHS. Outcomes remain unavailable until their original event record exists.

Software history, viewer files and exported JSON are diagnostic copies. Deleting or poisoning them does not supply a replacement memory, change the read result or prevent the next material sample from being written. A corrupted or unreadable cell causes an error, even if a correct diagnostic copy exists. Within one unchanged RHS evaluation, a probe result can be reused; it is discarded before any new state, read or write, so it is not a persistent memory cache or recovery path.

## The material cost is included

Every added cell uses the original bistable energy, stress, gradient-flow and dissipation equations. Original cells keep their original point weights; added cells use those same per-cell weights. The total is not renormalized to hide the added internal material contribution. This increases the fabric's aggregate constitutive contribution and changes its dynamics; it is an explicit model extension.

Each journal write uses the original fixed-deformation linear-stroke accounting: supplied work equals stored-energy change plus nonnegative drag heat. The quartic stroke polynomial supplies the peak-work check and conservative required-budget bound. Heat is deposited into the evolving temperature field and work into `write_work`. Each jump retains the original 0.02 budget. There are 651 sample writes and three event writes in a run to time 1.3, including the initial sample write.

The original 0.02 stroke-duration parameter is used in this idealized jump accounting. The code does not resolve actuator motion during a stroke or prove that physical actuators could perform these closely spaced writes. This is a synthetic material-memory model with accounted numerical costs, not a calibrated implementation in clay.

## Run, read without an archive, and resume

With Python, NumPy and SciPy available, use this directory:

```text
python material_trust.py --trust-ab 0.8 --trust-ba 0.2 --out runs/new-start
python material_trust.py --resume runs/new-start/checkpoint.zip --out runs/resumed
python -m unittest -v test_material_trust
python verify_full_runs.py
python build_viewer.py
node test_viewer.cjs
```

Output folders must be empty. A checkpoint preserves its declared horizon. The four viewer presets use the four independent 0/1 start combinations and each runs 650 steps through time 1.3. Intermediate starts are supported by the runner; the viewer selects completed runs.

`material-only.npz` contains only `F` and `b`. A fresh solver can decode its complete outcome records and retained lead-up without a checkpoint, software history or recorded profile:

```python
from material_trust import Settings, build_solver, np
reader, _ = build_solver(Settings(1, 0))
with np.load('runs/a-trusting/material-only.npz', allow_pickle=False) as z:
    records = reader.read_material({'F': z['F'], 'b': z['b']})
```

`body.npz` additionally contains the current flow/social state, utility baseline and any pending event-start deformation needed to continue the full solver. It contains no chronological software history or recall profiles. `Session.from_body(path, settings)` reads the sample clock and identities from the material and can continue to write and read subsequent memories. Deformation and cells suffice to decode memory; the other current state variables are needed to resume the entire flow.

The checkpoint's `audit.json`, exported `decoded-material-leadup.json` and `memory-records.json` are inspectable diagnostics. They do not participate in physical decoding, trust retrieval or subsequent material writing.

## Verification and limits

The behavioral checks cover physical round trips, independent starts, deletion/poisoning of software archives, restart and subsequent writes, corrupt material, no silent repair, capacity/range/duplicate/budget failures, write energy and heat, unchanged old cells during a journal write, exact equivalence to the original traction probe, trust-RHS agreement and sensitivity to earlier material feature codes. Short event intervals are explicit unit fixtures; the full runs use the original event schedule.

[Full-run verification](verification/full-runs.json) checks all four runs, 651 physical samples per run, the three event prefixes of 201/401/601 samples, half-quantum error limits, original event readout, finite trust and work budgets. It loads only `F` and `b` into a fresh reader. It also restarts the entire flow at time 1.2 without any software history, writes new samples, and compares its future state to the uninterrupted run exactly.

[The material intervention](verification/material-intervention.json) changes earlier context/strain codes and their checksums in a diagnostic copy of `b`. Current trust, all other current state arrays, original event cells, stored trust/positions and each event's endpoint feature remain fixed. Both trust rates and subsequent trust are checked for change. This is a controlled alternative material state, not an allowed overwrite, a demonstrated naturally reachable history or an ambiguity-rule counterexample. Subsequent effects can include both recall and constitutive feedback because the changed memory is now material.

Successful finite runs do not prove permanent readability, global existence or unlimited capacity. Beyond the declared journal capacity the writer fails rather than dropping samples. After-write and before-write audit rows at the same time do not duplicate a material sample: the fields retained in that sample are unchanged by the instantaneous event write. The journal retains the declared fields, not every field of the full state at every time.

The moving speck assignment and prefix relevance remain the explicit additions from revision 2. Neighbor/family-specific trust coefficients and luck attribution remain unspecified; existing interactions with all six actors continue. No original document, upstream source, historical snapshot or GitHub repository was modified.

Viewer JavaScript is checked with a DOM interaction test. Its rendered appearance has not been visually inspected; the previously diagnosed headless-browser path was not retried. The original source preflight still verifies the inherited source/configuration; it is not presented as certification of this added journal law.

## Observed result

Nine distinct behavioral checks passed, with relevant checks repeated after probe-evaluation changes. All four full runs completed 650 steps, 651 material sample writes and three original outcome writes. Each fresh `F`/`b`-only reader recovered all prefixes exactly at their encoded precision. Maximum observed error against the sampled numerical values stayed below 0.00005. The final smallest cell magnitude exceeded 0.019925 in every run, above the inherited 0.005 read threshold; this is a finite-run observation.

The A-trusting/B-untrusting run supplied total write work `0.00015020208710602958`, including `0.00010969603997341476` for the journal. All write-account identities and declared budgets passed. These are dimensionless model units. Full-flow restart from time 1.2 without software history reproduced every future state array and newly written journal row exactly.

In the diagnostic material intervention, later trust at time 1.3 changed from `(0.3462759658, 0.3894184862)` to `(0.3463466484, 0.3891208013)` for A→B and B→A. The original event payloads, stored trust/positions and event endpoint features were preserved; earlier material context/strain codes differed. The effects are small and nonzero in this fixture. This establishes the implemented material dependency, subject to the intervention qualifications above.

The viewer interaction check also passed for all four starts, both meters, timeline, speck paths, material-decoded trust and supplied write work. Original source preservation checks passed for all 25 inherited files.

The subsequent [full-flow energy audit](../full-flow-energy/RESULTS.md) verifies the A-trusting/B-untrusting case against a control with the same quantized software recall and no material journal. It includes the initial bank-energy offset and time-zero write, integrates heat channels independently, and checks both 0.002 and 0.001 integration steps while retaining the 0.002 journal cadence. Both refined full-flow residuals are below `1.46e-10`; the standard-step journal state matches this version's saved final state exactly. That energy comparison covers this one declared initial-trust case, not all four starts or every allowed trajectory.
