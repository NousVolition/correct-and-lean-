# Clay boundary in the unchanged Hug v3 model

Status: the full existence-and-uniqueness theorem through every memory write is still unproved. This extension supplies a corpus connection and twelve formal consequences about the actual proposed v3 memory law, its accepted writes, and its full event schedule. The strongest schedule theorem explicitly assumes an existing solution and a deformation bound. It does not prove either assumption.

The focal person remains the returning student. The idea remains “Giving someone space to speak can change what I understand.” All 21 sealed source files and the seven copied Lean source/proof modules are unchanged. The full 193,122-coordinate state, moving material, fluid transfer and three event-start snapshots remain in the definitions. These person/idea labels preserve the interpretation; there is still no empirical calibration identifying the fictional numerical actor rows with that student.

## What the corpus connects

Your clarification identifies the Clay boundary with material that can adapt while retaining an imprint. The current corpus supports a connection through these existing v3 quantities:

| Part of the idea | Existing v3 representation | Qualification |
| --- | --- | --- |
| The same material adapts during the encounter | Material addresses move with X and deformation F; F evolves with the interpolated velocity gradient | This is the existing full material/fluid coupling. |
| An encounter leaves a retained imprint | Rest strains b enter the constitutive energy and stress; directional histories m are also retained | The continuous b values may evolve even while their encoded bits remain fixed. |
| The imprint can affect a later encounter | Mechanical probing recovers b, signs decode records, and retrieval feeds relationships, responses, permission margin and utility | The stored record and its current relevance are different: relevance can change without rewriting the record. |
| A boundary distinguishes readable memory from ambiguous material | The actual decoder accepts \|b\| ≥ 0.005 and refuses smaller magnitudes | A check that rejects a state does not itself stop the dynamics from reaching that state. |
| A new memory changes the material | An accepted write sets cells in one free slot to ±0.02, adds its calculated heat and records work | Acceptance still requires capacity, encoding, schema and work checks. |

The selected source explicitly describes a bistable residual-strain energy, stress feedback, mechanical probing, finite coding, and refusal of ambiguous reads without an external repair archive. Its declared new-law notes also say there is no imposed readout floor or automatic sign reset during the continuous evolution. These are direct source facts in `sources/rule_changes.json` and `sources/structural_hug.py`, freshly inspected here.

The corrected corpus's boundary-margin passage concerns an actor- and context-specific permitted action region. Its XML paragraphs 103–107 and 134–143 define a signed margin and say changing a boundary can change available actions. In v3, a separate continuous permission propensity consumes a disk margin. That social permission boundary is not identical to the material memory-read threshold. Experience can affect permission through the retained-record/retrieval/response chain; the equations do not establish an identity between these two boundaries.

The connected corpus also contains a [separate Clay contact model](https://github.com/NousVolition/My-Sources-Project-ALL/blob/7fbc7f28f685c86f824d7587aff91feedf20d3da/reports/clay-contact-stress/README.md) with a logarithmic gap barrier. It provides a useful example of an explicit boundary force. Its contact law is not present in the selected v3 equations. Importing it would change this model, so it was not imported. Neither its numerical clearance checks nor its separate finite experiments prove v3's memory continuation.

This search used the two local corrected-corpus documents, the sealed v3 sources, and bounded connected-repository searches at commit `7fbc7f28f685c86f824d7587aff91feedf20d3da`. It is not a claim to have exhaustively searched every corpus artifact. Retrieved passages and search results are preserved in `corpus/`.

## The new mathematical connection

The unchanged cell equation is

\[
\dot b_l=\frac{e_l(F)}{500}+\frac{31}{125}b_l-625b_l^3,
\qquad
e_l(F)=\frac{\sum_i F_{p(l),i,a(l)}^2-1}{2}.
\]

The actual decoder threshold remains 0.005. The new proof introduces the property

\[
\mathrm{ClayBuffer}(s):\quad |b_l|\geq0.006\quad\text{for every cell }l.
\]

This is a property to prove about trajectories, not an additional equation, force, clipping rule, changed threshold or restriction in the simulator.

At b = +0.006, the actual rate is at least +0.000353 for every deformation matrix. At b = −0.006, it is at most −0.000353 provided

\[
\sum_i F_{p(l),i,a(l)}^2\leq2.
\]

The first-crossing argument is now formalized: with the actual cell derivative, continuity, and the stated deformation bound, a cell starting outside this buffer cannot cross into it between writes. The initial state has b = −0.02. The actual successful write sets selected cells to ±0.02 and leaves the others' b values unchanged. Thus an accepted write preserves the buffer. The strict clearance above the decoder's threshold is at least 0.001.

The deformation bound is an explicit unproved hypothesis about the coupled trajectory. No cap on F was added to the source. A small set of numerical samples cannot discharge this hypothesis. The earlier outward-boundary example at larger deformation still shows why the well alone is not an automatic invariant for arbitrary forcing; it does not refute the requested result for the prescribed initial condition.

## What the Lean statements establish

The twelve claims are frozen before their corresponding solution modules were written. The final two were appended after the first ten passed; none of the original ten statements or source definitions was changed. Both freezes are retained.

1. The exact-real mechanical probe recovers each b cell.
2. A positive well stays beyond +0.006 under the actual cell derivative.
3. A negative well stays below −0.006 under that derivative and the stated deformation bound.
4. These facts preserve the all-cell buffer on a continuous segment.
5. The buffer implies strict clearance above the actual read threshold.
6. The actual initial state has the buffer.
7. A successful concrete `writeEvent` preserves it.
8. A successful concrete `completeEvent` preserves it.
9. Every successful scheduled boundary operation preserves it, including the write-before-capture order at time 0.8.
10. Decoded records remain equal throughout a continuous segment on which reads succeed. The proof uses continuity and the intermediate value theorem to exclude a sign flip without entering the unreadable region.
11. For a trace satisfying the complete `Solves` definition and the deformation bound, the buffer holds on every interval and after every boundary in the actual schedule 0, 0.2, 0.4, 0.8, 1.2, 1.6.
12. For a trace satisfying `Solves`, decoded records are constant within each of those intervals. Retrieval weights and responses can still evolve.

Claims 11 and 12 assume `Solves tr`. That premise includes a valid continuous trajectory and successful writes. They are preservation consequences, not existence witnesses, and cannot be used to claim that all writes will succeed. The successful-write lemmas likewise do not prove that encoding and work checks accept the actual event record, nor a complete encode/decode round-trip theorem.

## What still blocks the requested full theorem

The Clay connection identifies a real preservation mechanism and a concrete mathematical obligation. It does not close the following gaps:

- Complete source-to-Lean correspondence, including the full codec. The existing definitions remain a proposed exact-real transcription; floating-point execution and Heun error are not formally equated to it.
- Local existence and uniqueness for the entire coupled vector field, with its finite operators, moving kernels, norms, denominators and decoded-record domains. No segment existence or uniqueness proof was supplied by this extension.
- Continuation to each event and the final time. This requires full state bounds and nonvanishing fibers, as well as a memory-read margin. The displayed deformation bound is one sufficient route to the latter; a different valid bound could also work.
- Successful writes at 0.4, 0.8 and 1.2: valid decoded records, remaining slots, quantization range, successful payload round trips, and the exact nonnegative-work and budget conditions must follow from the actual trajectory.
- A proof of `HugV3.Source.FullExistenceUniqueness`. It remains an unproved proposition in unchanged `V3SourceSystem.lean`, and is not among the twelve claims submitted to Comparator.

The earlier saved successful simulation is historical numerical evidence. It was not rerun or relabeled as a proof in this extension. Finding a related contact barrier in the corpus did not justify transferring its invariant to different equations. A further complete proof needs new analytical estimates or rigorously validated trajectory enclosures; rerunning the same component checks would not resolve these gaps.

## Verification

Native Lean accepted both new proof modules. The fresh Linux build and Comparator also passed: both exit codes are 0, and both Lean's kernel and nanoda accepted all twelve submitted claims. The results are recorded in `verification-report.json` and `evidence-linux/`. The challenge modules contain reference-only placeholders and are not imported by either solution module. The proof files contain no `sorry`, `admit`, new axiom or unsafe declaration.

The Linux check uses the existing nonroot verifier, actual Landrun isolation, pinned clean dependencies, Lean's kernel and nanoda. It compares the twelve frozen statements. Its success certifies those statements and their stated assumptions only. The original-source and copied-definition hash checks are in `source-preservation.json`.

`source-audit.json` and `source-map.json` are preserved records from the previous source-transcription package. Their nine-claim check description is historical. The current twelve-claim result is in `verification-report.json`; the unchanged full-theorem status remains unproved. One inherited deprecated-tactic warning remains in the copied source component proofs; the new proof modules compile without warnings.
