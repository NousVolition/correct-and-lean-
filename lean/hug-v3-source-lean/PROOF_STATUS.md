# Full Hug v3 source transcription: proof status

**INCOMPLETE. The requested existence-and-uniqueness theorem through every event and memory write has not been proved.** The concrete proposed Lean model and nine component proofs build successfully. Comparator, Lean's kernel and nanoda accept those nine statements. Their success does not certify the full trajectory theorem or complete Python-to-Lean correspondence.

The same returning student and the idea “Giving someone space to speak can change what I understand” are preserved. All 21 sealed source files remain unchanged. The proposed model retains the 193,122 real numerical coordinates and event-start deformation snapshots. No two-state replacement or new restriction on the user's equations was introduced.

## What changed in this attempt

The previous hybrid package accepted unspecified segment laws and action callbacks. This package supplies concrete proposed definitions of the main v3 rates and event updates. The requested target now refers to those definitions directly in `V3SourceSystem.lean`, rather than assuming segment existence, segment uniqueness or successful writes.

| File | Proposed source connection |
| --- | --- |
| `V3SourceCore.lean` | Full state, finite Fourier operators, projection, finite-volume transport, moving mechanical/thermal kernels, structural strain and constitutive law |
| `V3SourceGeometry.lean` | Frozen 384-particle geometry, quadrature weights, 24 directions and six attachment rows exported from the approved main constructor |
| `V3SourceMemory.lean` | Probe interpretation, readable-bit guard, CRC, signed encoding, rounding, decoding, finite capacity, full write-work acceptance and state update |
| `V3SourceSocial.lean` | Current observations, decoded-record relevance, utility/baseline, responses, expression, context, norm, permission radius, relationships and associations |
| `V3SourceFlow.lean` | Coupled velocity, transported context, temperature, material position/deformation, directional records, structural memory, accumulator and ledgers |
| `V3SourceSystem.lean` | Exact scheduled events, start snapshots, record construction, successful-write transitions and the full unproved existence/uniqueness proposition |

The mapping records 39 source functions with their actual locations. This is a manually prepared mathematical transcription, **not a proved compiler translation**. Decimal coefficients are interpreted as exact real decimals. Source-computed binary64 geometry is represented by exact rational values. Floating-point roundoff equivalence, Heun accuracy, output-only pressure/energy diagnostics, display archives and the unused peak-work diagnostic are not proved by this package. The peak diagnostic does not control write acceptance; the actual required-budget and nonnegative-work checks are represented.

The codec uses the nearest-integer, ties-to-even interpretation documented for [NumPy `rint`](https://numpy.org/doc/stable/reference/generated/numpy.rint.html). Its CRC definition agrees on the newly checked reference input `123456789` with [Python's `zlib.crc32`](https://docs.python.org/3/library/zlib.html#zlib.crc32). One checked input is not a proof of full codec correspondence or of every payload round trip.

## A concrete result from the actual structural-memory formula

With the unchanged selected coefficients, the material-cell equation is

\[
\dot b=\frac{e}{500}+\frac{31}{125}b-625b^3,
\qquad e=\frac{\|F_{p,\cdot,a}\|^2-1}{2}.
\]

The read threshold is \(|b|=1/200=0.005\). Lean verified that at the **positive** threshold,

\[
\dot b\big|_{b=1/200}\ge \frac{259}{1600000}>0
\]

for every real deformation matrix, because a squared column norm is nonnegative.

At the **negative** threshold,

\[
\dot b\big|_{b=-1/200}
=\frac{\|F_{p,\cdot,a}\|^2}{1000}-\frac{3459}{1600000}.
\]

Consequently, the vector field points strictly inward there exactly when

\[
\|F_{p,\cdot,a}\|^2<\frac{3459}{1600}=2.161875.
\]

A bound of 2 is a convenient sufficient condition and supplies the symmetric strict margin \(-259/1600000\). This is **not imposed on the equations**. It is a sufficient condition for this barrier-proof route that still needs to be derived from the actual coupled trajectory. It is not a necessary condition for a cell to remain readable: a cell can remain far from the threshold even during a temporary larger deformation.

Lean also verified that a larger deformation can point outward at the negative boundary. That disproves an automatic barrier argument for arbitrary deformations. It does **not** refute the desired theorem for the declared initial condition.

Read-only inspection of the existing main display file found a largest sampled squared column norm of approximately **1.1638611 across 57 saved time samples**. These are historical Heun samples. They are not a validated interval enclosure and do not establish a continuous-time bound. The earlier successful three writes likewise remain numerical evidence.

## Exact scope of the new checks

The nine checked declarations establish: the concrete RHS's structural-memory component; its accumulator/utility connection; the geometric lower bound on structural strain; the positive read-boundary sign; the exact negative-boundary criterion; its sufficient bound of 2; an outward-boundary example; restoration of the selected write-target cells to magnitude 0.02; and the stated CRC reference value.

The write-target result concerns the concrete `targetFabric` operation. It does not establish that a trajectory reaches a successful full `writeEvent`, or that all its encoded records pass the entire decoder afterward.

Native Lean, a fresh Linux build and Comparator passed. The independent run used the pinned dependencies, actual Landrun isolation, a nonroot verification user, Lean's kernel and nanoda. The permitted axioms were only `propext`, `Quot.sound` and `Classical.choice`. Frozen input hashes and original source hashes remained unchanged. Reference-only placeholders are confined to `V3SourceChallenge.lean`; they are not imported by `V3SourceProofs.lean`. The full target is an unproved proposition, not a placeholder theorem.

A reference syntax error was corrected before any proof file existed. The invalid first reference and its hashes are preserved under `reference-history`; the valid second reference was frozen before the solution was written. No mathematical hypothesis was weakened to obtain the passing checks. One deprecated tactic-name warning remains in the solution log.

## Work still required for the requested theorem

1. Prove the proposed real-arithmetic definitions correspond to the intended full source equations and event semantics, including the codec and initial state.
2. Equip the complete coordinate space with the required analysis and establish local regularity/existence/uniqueness for the entire RHS, including wrapped kernels and locally fixed decoded records.
3. Prove finite-time bounds or construct rigorously validated enclosures that keep the full trajectory inside its domain and carry it to every checkpoint. The negative-well result identifies one concrete bound to address; it does not discharge continuation.
4. Derive successful capacity, quantization-range, semantic-record and writing-work checks at 0.4, 0.8 and 1.2, and valid continuation to 1.6 from the actual initial state.
5. Prove `HugV3.Source.FullExistenceUniqueness` and submit that proof to Comparator. This final claim has **not** been submitted or accepted.

The acceptance criterion remains the full theorem. This package preserves useful progress without substituting the nine component results for it.
