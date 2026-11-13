# The ambiguity theorem applied to tick 41 and the Yang–Mills example

**Two explicit instances pass in Lean: the memory write at tick 41 and the saved abelian Yang–Mills cue example.** A separate check shows why the archived tick-41 closure results do not supply another instance: every saved return fails the necessary x-coordinate condition for closure, so that finite collection has no opposite-property witnesses.

Both positive proofs apply `SIMSLatentReadout.no_exact_reader_of_ambiguous_observation` directly. The common conclusion is an information limit of the specified observations. It is not an equivalence between the physical systems.

| Case | State | Observation supplied to the reader | Property to decide | Witnesses and result |
|---|---|---|---|---|
| Tick 41, memory write | The two saved snapshots immediately before and after event 2 is written at model time 1.2, in the archived threshold-1, breathing-on run. | The complete saved velocity grid and all 804 water-marker positions, encoded without rounding. | Does the decoded material record contain event 2? | Observations are identical. Event IDs are `[0,1]` before and `[0,1,2]` after. **The theorem applies.** |
| Yang–Mills cue | Smooth candidate abelian potentials on four-dimensional Euclidean space, using the saved curvature/residual definitions. They are not assumed in advance to solve the field equation. | Every potential component and every curvature component on the entire slice `x₁=0`, which contains the cue line. | Do all four source-free residual components vanish at the origin? | The original and modified fields agree on the whole observation. Residual component 2 is respectively 0 and 2 at the origin. **The theorem applies.** |
| Tick 41, saved return geometry | The 24 saved A/B return records from twelve audited pair/run configurations. | Any chosen observation of this finite collection. | Does the saved x coordinate return modulo one cube length? This is necessary for full periodic closure. | Every property value is false. A constant “does not close” reader is correct on this finite collection. **The opposite-property hypothesis cannot be met here.** |

## Tick 41: the write is invisible to the chosen water observation

The equality check covers all 12,288 saved velocity components on the 16³ grid and all 804 marker positions: 117,600 bytes per observation. The before/after observations match byte for byte. They are exported as full hexadecimal strings into Lean, not replaced by their hashes.

The native material reader decodes event IDs `[0,1]` before the write and `[0,1,2]` afterwards. Meanwhile, 37,264 fabric values change and the mean temperature increases by approximately `1.5674081804063902e-5`. Those quantities are outside the specified water-only observation.

The formal state type has just the two observed snapshot alternatives. Lean checks the equality of their exported observations, the differing Boolean record-presence values, and the impossibility of a reader that gets both right from those observations alone. This also rules out such a reader on any larger domain containing both witnesses.

As a control, Lean proves that adding the decoded event list to the observation gives an exact reader for this property. The obstruction belongs to the limited observation; it is not a claim that the write is undetectable by every measurement.

**This proof concerns the memory write.** It does not show that the write caused the earlier closest-point switches or that those switches establish loss of vortex-line closure.

The witnesses come from one archived before/after pair in `go/work/threshold-one-pair/on`. Comparing the after state with this chat's earlier threshold-1 rerun revealed small floating-point differences, up to about `7.77e-16` across the compared arrays. Those separate replays were not mixed to manufacture an equality. The exact equality used in the proof is internal to the selected archived pair.

[Direct theorem application](<$USER_HOME/Documents/Codex/2026-11-10/lo/outputs/Ambiguity theorem checks/lean/AmbiguityInstances.lean:26>) · [Export and decoder checks](<$USER_HOME/Documents/Codex/2026-11-10/lo/outputs/Ambiguity theorem checks/Export checks.json>)

## Yang–Mills: matching the cue does not fix a transverse derivative

The two existing potentials, with component order 0,1,2,3, are

`A_original(x) = (−2, 0, 0, 0)`

`A_modified(x) = (−2, 0, (x₁)², 0)`.

The saved convention is abelian: `Fᵢⱼ = ∂ᵢAⱼ − ∂ⱼAᵢ`, and residual component `Rⱼ = Σᵢ ∂ᵢFᵢⱼ`.

Both fields are smooth, as checked in the new proof. On the slice `x₁=0`, the potentials agree and all curvature components agree. However, the modified field has `F₁₂=2x₁`, so its transverse derivative is 2 at the cue. The original field has zero curvature everywhere and hence zero residual. The property “all residual components vanish at the cue” is therefore true for the original and false for the modified field.

This is stronger than agreement at one point or along the cue line: even knowledge of the potential and curvature over the whole specified slice cannot decide that property for every allowed candidate field. The missing information is how the curvature changes away from the slice.

A checked control distinguishes the witnesses off the slice: at `x₁=1`, their `F₁₂` readings are 0 and 2. This control distinguishes these two fields; it is not a universal reconstruction theorem for arbitrary fields.

The modified field remains a counterexample used for this test. It does not replace the user's original field. The result concerns the saved classical abelian example and does not establish a quantum Yang–Mills mass gap.

[Smooth state space and observation](<$USER_HOME/Documents/Codex/2026-11-10/lo/outputs/Ambiguity theorem checks/lean/AmbiguityInstances.lean:50>) · [Direct theorem application](<$USER_HOME/Documents/Codex/2026-11-10/lo/outputs/Ambiguity theorem checks/lean/AmbiguityInstances.lean:112>)

## Why the closure result is different

For each saved return, the exported start and return x coordinates have a common exact integer scale. Lean checks that their difference is not divisible by that scale. It also proves that an integer-periodic return would imply divisibility. Thus none of these saved x coordinates closes, including after any integer shift.

On this finite state space, no two states can have opposite closure outcomes: they all fail a necessary condition for full closure. Lean explicitly proves the existence of a constant correct reader for the checked x-return property, for any observation function on that collection. That prevents us from presenting these records as witnesses to the ambiguity theorem.

This does not prove that closest-point readings determine closure for arbitrary curves. Establishing ambiguity for that broader question would require an allowed closed curve and an allowed open curve with exactly the same specified reading, plus the corresponding mathematical checks. The saved closest-point switches alone do not provide that pair.

[Checked negative condition and reader](<$USER_HOME/Documents/Codex/2026-11-10/lo/outputs/Ambiguity theorem checks/lean/AmbiguityInstances.lean:160>) · [Earlier saved-geometry certificate](<$USER_HOME/Documents/Codex/2026-11-07/mathlib4-the-main-library-good-first/outputs/hug-threshold1-refinement/tick41-lean/READOUT.md>)

## Verification and scope

All eight source modules compiled in the pinned Lean 4.34.0-rc2 environment with Mathlib commit `85e3a25e006c35636f0e53b0e9296caca2685bc0`. All 17 principal statements in `AmbiguityInstances.lean` have checked axiom reports. Only the standard `propext`, `Classical.choice` and `Quot.sound` occur; the four tick-41 write statements depend on no axioms. There are no custom axioms, proof placeholders or `native_decide` calls in the checked sources.

The numerical-to-Lean bridge is outside the kernel: NPZ decoding, exact byte export, the native material decoder, and attribution to the saved experiments were checked separately. An independent readback compared the Lean observation strings with the original arrays and all 24 exported return records with their source values. The existing geometry package's 67 manifest entries also matched. The corresponding files, logs and hashes are retained.

No fluid steps or model replies were generated. Original simulation states, original Yang–Mills definitions, and earlier certificates were preserved. The initial compiler-root setup error and first incomplete smoothness proof are retained separately from the final successful logs; neither was counted as a passing result.

The included Lake settings pin the same dependencies for a fresh checkout; fresh network installation was not tested. The actual successful commands and source/object hashes are in [Lean verification.json](<$USER_HOME/Documents/Codex/2026-11-10/lo/outputs/Ambiguity theorem checks/Lean verification.json>), and the final [principal proof log](<$USER_HOME/Documents/Codex/2026-11-10/lo/outputs/Ambiguity theorem checks/logs/AmbiguityInstances.log>) shows the dependency checks.
