# Piecewise-in-time hybrid theorem for the selected Hug v3 realization

This is a precise target and a conditional assembly theorem. It keeps the full selected v3 state shape and event schedule. It is not a certificate that the full source RHS, decoder and writer have already been formalized or that the main trajectory exists through time 1.6.

Let \(s\in\mathbb R^{193122}\) contain every numerical block in the main v3 state dictionary, and let \(H\) contain the captured start-deformation arrays. The same returning student and the same idea—“Giving someone space to speak can change what I understand”—remain the interpretation. The six actors and two context coordinates are source fixture choices; they do not reduce the equation to two meaning states.

Write \(y=(s,H)\), \(t=(0,1/5,2/5,4/5,6/5,8/5)\), and let \(\mathcal F\) be the **unchanged full coupled source RHS**, interpreted in exact real arithmetic on the fixed grid. Between checkpoints,

\[
\dot s(t)=\mathcal F(t,s(t)),\qquad \dot H(t)=0.
\]

At each checkpoint apply the prescribed partial transition \(J_k\), which either returns the next full state or rejects the operation. The ordered actions are:

| Time | Action after the preceding flow |
| --- | --- |
| 0 | Capture event 0 before the first flow |
| 1/5 | Capture event 1 |
| 2/5 | Complete and write event 0; consume its capture |
| 4/5 | Complete and write event 1; consume its capture; then capture event 2 |
| 6/5 | Complete and write event 2; consume its capture |
| 8/5 | No write; final endpoint |

For each interval, use a continuous segment \(y_k:[t_k,t_{k+1}]\to E\), with the terminal value representing the **pre-event** state. Store the post-event state separately:

\[
y_k(t_k)=z_k,\qquad z_{k+1}=J_{k+1}(y_k(t_{k+1})).
\]

The actual path takes \(y_k(t)\) on \([t_k,t_{k+1})\) and the prescribed post-event value at a checkpoint. With continuous closed-interval segments this gives the usual right-continuous path with left limits. The current Lean assembly uses abstract segment laws; proving that those laws enforce the source ODE and this regularity remains part of the instantiation.

**Conditional existence-and-uniqueness statement.** Suppose:

1. The initial capture succeeds and the resulting full state is admissible.
2. From every admissible state covered by the theorem, the unchanged segment equations have a solution all the way to the next checkpoint, with an admissible successful endpoint transition.
3. Two such segment solutions from the same complete starting state agree throughout their closed interval.
4. The transition is a fixed single-valued partial function, including record construction, validation, the full write update, snapshot consumption and subsequent captures.

Then a hybrid trace exists through all five intervals and any other valid trace with the same complete initial state agrees at every boundary and throughout every interval. A rejected operation cannot be treated as a successful next state.

The existence proof chooses a successful segment and next state at each finite stage. The uniqueness proof is induction: equality of starting states gives equality of segment paths, hence equal left endpoint data for the deterministic transition, hence equal next states. Values of segment functions outside their actual intervals are deliberately excluded from the uniqueness claim.

**Analytic obligations for this to become a theorem of the actual source.** Formalize \(\mathcal F\), the finite spatial operators, read/encode/write semantics, capture rules and initial state; prove their correspondence with the sealed code. Establish local regularity on the semantically valid open domain described in `PAPER_REVIEW.md`. Derive segment uniqueness from those bounds, rather than assuming it. Prove continuation and successful writes through the stated endpoint. The first local existence theorem alone is insufficient for condition 2.

The current Lean theorem `Hybrid.Verified.v3_main_conditional` records conditions 1–3 explicitly through `Initialized`, `StepSolvability` and `SegmentUniqueness`; condition 4 is expressed by the function-valued action interface. These are genuine outstanding assumptions for full v3. The theorem is useful assembly work, but it does not claim those assumptions were proved from the user's equations.

The source equations, 21 sealed files and previous proof packages are unchanged. No global smoothness across a write, arbitrary-residual forcing, two-state replacement, infinite-grid limit or empirical validation is claimed.
