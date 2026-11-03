# Hug v3 and Yang–Mills: corpus and proof audit

**PASS — 20 targeted theorems accepted by Lean, Comparator and the independent nanoda checker.** The fresh isolated check and final Lake build exited successfully. This certifies the listed claims under their stated hypotheses; it does not certify Yang–Mills equivalence or every property of the full model. Your equations, returning student and idea remain unchanged.

The concrete connection is **invariance under a specified transformation, together with a matrix transport law**. Hug v3 already contains an objective strain measurement: rotating the fabric without changing its stretch leaves that measurement unchanged. This audit proves how far that property extends through the actual observations, retrieval, response rates, event records and memory writes. It also proves an exact obstruction to treating a fabric-only rotation as a symmetry of the full evolution. These results establish a mathematical connection worth developing; they do not establish that Hug v3 is a Yang–Mills theory.

The same returning student and idea are retained: **“Giving someone space to speak can change what I understand.”** Actor 1 is the student; actors 0 and 2 are the first and second teachers in this interpretation. Those names are interpretive aliases, not replacements for the actors' numerical parameters. No additional student, substitute idea, or reduced two-state model was introduced.

**The checked source is the full selected Hug v3 model.** The package imports its six existing source modules, including the fixed geometry, physical transfer, social feedback, fabric memory, captures and event boundaries. It also preserves the saved delay definitions. The continuous state has 193,122 real coordinates, including the 16³ grid, 384 particles and 149,056 fabric coordinates; capture buffers are additional hybrid state. The original Python source and its exact-real Lean transcription were preserved. The new definitions describe comparison transformations and derivative predicates only; they do not change a Hug equation, parameter, event, write rule or delay convention.

**Your corpus supplies relevant invariance questions and an implemented strain rule.** The corrected corpus distinguishes within-context consistency from invariance across contexts (paragraphs 51, 222 and 374). Its reciprocal scalar rescaling preserves a product, with an explicit qualification that this alone does not establish a dynamical invariant (paragraphs 497–515). Its field and accumulated-input discussion supplies transport and history structure (paragraphs 517 and 520). In the selected Hug source, `continuum.py:15` explicitly defines Green–Lagrange strain as objective under left multiplication by a rotation. The formal results below are grounded in that implemented definition, rather than in matching the word “field.”

The read-only search covered the 638-paragraph corrected document, the selected Hug source, the connected corpus-board search recorded with 1,123 items and no Yang/Mills/gauge/curvature/rotation/objectivity matches, and the recorded GitHub searches. No explicit Yang–Mills identification was found in those searches. That is a bounded search result, not a claim about every document you own. Exact passages, query results and source hashes are in the package's `corpus` directory.

**What the Lean statements establish.** Every theorem is about the imported source definitions. In the table, “rotation” means a matrix satisfying \(Q^TQ=I\); the proofs also cover reflections. The explicit counterexample uses a proper 90-degree rotation. A different such matrix may be used at each particle for these algebraic comparisons.

| Checked part | Result and scope | Targets |
|---|---|---:|
| Strain and fabric | Green–Lagrange strain, its norm, fiber strain and fabric strain are unchanged under \(F_p\mapsto Q_pF_p\). | 4 |
| Reading and response | Decoded records, observations, weighted retrieval and social rates are unchanged under this transformation while other state fields remain fixed. The theorem about accepted full right-hand sides explicitly requires both evaluations to succeed. | 5 |
| Events and writes | Rotating both captured and current fabric leaves `makeEvent` unchanged, even with independent rotations at the two endpoints. Write accounting is unchanged. The complete `writeEvent` result commutes with the rotation, including rejection cases. | 3 |
| Record enumeration | Permuting the same list of records leaves retrieval and the entire `rhsFromRecords` unchanged. This does not interchange encounters or their dates, contents, captures or predecessor information. | 2 |
| Actual deformation equation | The source's deformation component is exactly \(\dot F_p=L_p(s)F_p\). The matrix product rule and exact frame mismatch are proved. | 3 |
| Limit of the proposed symmetry | A specified rotation is orthogonal, its mismatch has an entry equal to 2, and the universal fabric-only rotation covariance claim is false. | 3 |
| Total | The complete list and hypotheses are frozen in `V3YangMillsAuditChallenge.lean`. | **20** |

**The positive connection runs through your existing memory mechanism.** Write \(E\) for the source function `green`:

\[
E(F)=\frac{F^TF-I}{2},\qquad E(QF)=E(F)\quad\text{when }Q^TQ=I.
\]

An event stores the six independent components of

\[
\Delta E_p=E(F_p^{\mathrm{end}})-E(F_p^{\mathrm{start}}).
\]

Consequently, a rotation at either endpoint cannot by itself alter this stored strain difference. The present strain norm also enters the current observations and the retrieval cue. In the unchanged retrieval equation, a record's weight is

\[
w_r=(t_r^{\mathrm{end}}-t_r^{\mathrm{start}})
\exp\!\left[-\frac{\|f_r-c_{ij}(s)-0.15\tanh(\mathrm{association}_{ij})\|^2}
{2(0.32)^2}\right],
\]

where \(i\) is the recipient, \(j\) the origin, \(f_r\) the record feature and \(c_{ij}\) the source's `memoryFeature`. Here \(\tanh\) acts componentwise on association. Both strain-based features are unchanged under the proved comparison. Context, association, recipient, origin, times and scores are held fixed. Thus each relevant weight, the exposure denominator, retrieved channels and social response rates remain unchanged. Changing context or association is a different comparison and is not covered by this invariance claim.

The memory-write theorem is stronger than a comparison of readouts:

\[
\operatorname{writeEvent}(G,\operatorname{rotateFabric}(Q,s),r)
=\operatorname{map}(\operatorname{rotateFabric}(Q))
\bigl(\operatorname{writeEvent}(G,s,r)\bigr).
\]

It checks the actual decoding, duplicate-ID rejection, free-slot selection, payload, energy budget and write update in the saved definition. It does not assume that a write succeeds. If the original write rejects the record, the transformed write does too; if it succeeds, the post-write states correspond by the same fabric rotation. This is a symmetry of this event map, not a proof that every scheduled write on an evolving trajectory succeeds.

**For the returning student, this preserves one specific kind of sameness.** A different fabric orientation with the same strain, context, associations and stored content produces the same immediate retrieval and response cues in the equation. The student's experience with teacher 1 remains identified with its source when teacher 2 is encountered; rotating fabric does not relabel the teacher or invent a new experience. The model can still respond differently when context, timing, state or record contents change. The proof does not say that different teachers, social identities or lived experiences are interchangeable.

The mapping from numerical state to a returning student, and from response coordinates to actually giving space to speak, remains an interpretive assumption. These algebraic theorems do not establish that a student learns more, feels safer, or behaves identically under a real-world intervention. They also do not establish a complete teacher-to-teacher trajectory; they apply universally to the relevant instantaneous states and event inputs.

**The full transport law exposes the missing connection.** Your source has

\[
\dot F_p=L_p(s)F_p,
\qquad L_p(s)=\operatorname{particleGradient}(s,p).
\]

The comparison rotates only \(F\), holding the velocity grid and particle positions fixed, so \(L_p\) stays fixed. For a differentiable, time-dependent \(Q\), the exact discrepancy is

\[
\frac{d}{dt}(QF)-L(QF)
=\bigl(\dot Q+QL-LQ\bigr)F.
\]

This identity is proved using the actual deformation component, with the product rule stated under explicit derivative hypotheses. It need not vanish. For

\[
Q=\begin{pmatrix}0&-1&0\\1&0&0\\0&0&1\end{pmatrix},\quad
L=\operatorname{diag}(1,-1,0),\quad F=I,\quad\dot Q=0,
\]

the \((0,1)\) entry of the mismatch is exactly \(2\). Lean proves this exact rational example, without a floating-point tolerance.

The counterexample rejects the blanket claim that rotating fabric alone always commutes with deformation evolution. It does **not** reject every possible change of spatial frame: velocity, positions, forcing and other quantities would have to be transformed consistently in such a comparison. Nor does it prove that the example's prescribed \(L\) occurs on the selected initial trajectory. Arbitrary independently rotated particle fabrics also need not arise from a compatible deformation field. No such reachability or compatibility claim is made.

Formally, keeping a transported equation covariant would require the transport matrix to change consistently; for invertible \(Q\), its required time-component transformation has the form \(L'=(\dot Q+QL)Q^{-1}\). This is an algebraic interpretation of the proved mismatch, not a replacement rule inserted into Hug and not a separately submitted theorem about an altered system.

**Where this meets Yang–Mills.** Yang–Mills theory uses a gauge connection \(\mathcal A\) and curvature \(\mathcal F=d\mathcal A+\mathcal A\wedge\mathcal A\), with covariant field equations. It distinguishes quantities that depend on a choice of local representation from appropriate invariant observables. Hug's proved invariance and its matrix transport calculation make a precise comparison possible. A complete identification would require the connection, curvature, transformation laws and dynamics to match. [Jaffe and Witten, official Yang–Mills problem description](https://www.claymath.org/wp-content/uploads/2022/06/yangmills.pdf).

Hug's \(F\) is a deformation matrix; it has not been identified with Yang–Mills curvature. Hug's accumulated input \(A\) has not been identified with a gauge connection. Neither matching letters, reciprocal rescaling, noncommuting matrices nor history dependence supplies that identification on its own. These symmetry properties are not a distinctive Yang–Mills fingerprint. The rotation used here acts on the implemented fabric variables; calling differences in a person's identity or experience “gauge” would require an additional, justified definition.

| Connection still needed | What would have to be established without changing the equations |
|---|---|
| Gauge structure on the full state | Specify a group action on all affected fields, geometry, captures and histories, and identify which transformations describe the same modeled situation. |
| Connection and curvature | Identify existing Hug expressions that have the required transformation law and curvature relation; show how they relate to transfer and guards. |
| Full dynamical covariance | Prove the complete physical/social right-hand side, partial-domain conditions, events and chosen delay/history convention transform consistently. The present fabric-only transformation does not provide this. |
| Yang–Mills field equations | Derive the required equations from the unchanged Hug laws. No such derivation is established by this audit. |
| Complete hybrid/delayed well-posedness | Prove existence, continuation, valid-domain preservation, successful scheduled writes and uniqueness with specified histories and timing rules. The saved `FullExistenceUniqueness` remains a target proposition, not a theorem proved here. |
| Implementation and human interpretation | Prove the exact-real transcription corresponds to the Python numerical implementation, and separately test the interpretation and measurements against observations. |

The saved delay extension is imported unchanged, but the new 20 targets do not prove variable-delay covariance or delayed existence and uniqueness. A remembered or reimagined episode is not automatically a gauge transformation or a Yang–Mills loop. No Yang–Mills quantum mass-gap claim is made.

**What the verification certifies.** The solution imports the unchanged source definitions and the audit definitions, but not the challenge file. The challenge contains deliberately unproved reference statements for Comparator; their placeholders are not allowed in submitted proof closures. Comparator accepted all 20 targets with only `propext`, `Quot.sound` and `Classical.choice` permitted. Both nanoda and Lean's default kernel explicitly accepted the solution. The fresh solution was checked without precompiled solution objects, using pinned clean dependencies and non-root Landrun isolation. The final Lake build also passed. Two unused-simplification-argument warnings are harmless and are retained in the logs.

The read-only preservation check freshly verified the seven copied model/delay modules and two dependency pins, plus all 21 sealed original Python/configuration files and their 21 saved copies. The corrected corpus hash also matched its extraction source. Preflight and postflight checks confirmed that verification inputs and dependency sources remained unchanged. These are checks performed for this audit, rather than results borrowed from previous Hug or Navier–Stokes runs.

No new numerical simulation or convergence test was run for this audit. The nonzero mismatch is an exact theorem. Importing and compiling the complete source does not prove every property of that source. In particular, this check does not settle full continuum existence, all memory/delay trajectories, originality, empirical validity, or equivalence to Yang–Mills.

The reproducible package retains the frozen statements, proof source, original copied definitions, development failures, reference revision note, corpus evidence, run scripts and source-preservation checks. `verification-report.json` records the outcome; `evidence-linux/comparator.log` contains the independent-checker and Lean-kernel acceptance messages. `evidence-linux/lake-build.log`, the exit-code files, and preflight/postflight records provide the build and preservation evidence.
