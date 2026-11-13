# Does the original carrying/history specify the missing energy G?

**The checked original notes do not yet identify an independent physical energy G that supplies the 43.6%. They do determine exactly what its change must be if the account is to close.** A causal history functional can be constructed to have that change without altering the equations. Its equality to the required debit is an accounting identity, not independent evidence that the notes contain the corresponding physical store.

The earlier statement that a configuration/history term could be added to the old pair potential described an undetermined mathematical freedom. It was not a discovery of a reservoir. This check makes that limitation and the required balance precise.

## What was checked in the sources

The original corrected DOCX was freshly opened; its 638 paragraphs and hash match the earlier source receipt. This check read the governing A/S passages, the reciprocal-scaling example, the retained carrying clarification, the broader guard-relationship formulation, the old-pair supersession and the actual retained-record implementation. Exact text and line/paragraph references are in [source-check.json](source-check.json).

| Source | What it supplies | Consequence for G |
|---|---|---|
| Original DOCX, paragraphs 230–231 and 266 | Momentum and the fixed-direction activation force; its work need not have a dissipative sign | Determines A/S power, not an opposing stored-energy law |
| Original DOCX, paragraphs 517–520 | Common scalar transport, diffusion, accumulated input A and source J=κA | Determines how activation/history evolve; the accumulated quantity is not identified there as physical energy |
| Original DOCX, paragraphs 498–515 | A scalar product preserved by reciprocal rescaling | Explicitly an algebraic transformation property, not a time-conservation law or a mapped energy for spatial S |
| Retained carrying clarification | The relationship continues while shape, position and internal state change; one intended continuum | Preserves the full configuration/history question; it does not imply frozen variables or constant energy |
| Broader guard-relationship note | Evolving directional relationships; response and physical stress laws remain choices | Does not provide an established energy mapping into the user's selected original A/S branch |
| Current material record implementation | Full strain-change records, physical fabric storage, retrieval and feedback | The material energy is already included in W and heat. `delta_E` in a record is a symmetric **strain change**, not an extra quantity of energy |
| Older paired-context comparison | An added alignment law, subsequently superseded | Its canonical potential rises from zero and does not supply the net debit |

For the record implementation, `make_event` defines `delta_E` from the difference of two strain tensors. `retrieve` uses that tensor to construct history-dependent weights; `utility` feeds the existing source mechanism. Neither assigns the retrieved history a separate energy decrease. The actual fabric energy and write/release transfers are explicit elsewhere in the same implementation and were already counted in the prior energy audit.

The broader corpus/archived-board searches remain historical evidence. A small read-only lookup of the known related chat exposed further rebuild/anticipation discussion but no energy law; no exhaustive chat search is claimed. Unread images, skipped board objects and live-board changes remain outside this check. The absence of G in the checked passages is not a claim about every possible note or energy functional.

## The requirement from the unchanged equations

Let E=kinetic + existing stored material energy + heat in the saved comparison. Between interventions, its checked balance is

\[
\dot E=P_{AS}+P_{\rm breathing}.
\]

Writing events have their separately recorded jumps. In the intended unforced case the added experimental drive terms are absent; the historical driven experiment is not reclassified as unforced.

For the tested displacement-based candidate

\[
V(t)=\int_{\Omega_0}\sigma\,\xi(X,t)\,\alpha(X,t)\,dX,
\qquad \dot V=-P_{AS}+\mathcal R,
\]

the remainder is

\[
\mathcal R(t)=\int_{\Omega_0}\sigma\xi\,\dot\alpha\,dX.
\]

The existing source and carrying equations determine this rate. With g=∇S, L=∇u and Q=D_diff ΔS+κAK_h,

\[
\dot\alpha=\frac{a'(q)}{|g|}\left(g\cdot\nabla Q-g^TLg\right),\qquad q=|g|-\Gamma.
\]

This expression applies on smooth branches with nonzero gradient; sharp-switch and zero-gradient cases retain their separate qualifications. The actual saved run used its documented regularized activation. No response branch is changed here.

Full carrying constrains this expression: for deformation F, the pulled-back gradient \(\mathcal H=F^Tg\) satisfies \(\dot{\mathcal H}=F^T\nabla Q\). Thus activation is not treated as independent of configuration/history. The energy called G here is distinct from the pulled-back gradient named G in an earlier proof package.

An additional physical store closing the account must satisfy

\[
\boxed{\dot G=-\mathcal R.}
\]

This condition allows G to depend on the full configuration and entire retained history, spatially nonlocal and nonlinear. It does not restrict G to A/S alone or to instantaneous local variables.

## A history account exists; its physical identification remains open

One can always define the causal functional

\[
G_{\rm account}(t)=G_0-\int_0^t\mathcal R(s)\,ds.
\]

It uses existing carried displacement and activation history and does not feed back into or change the equations. Substitution gives

\[
\frac{d}{dt}(E+V+G_{\rm account})=P_{\rm breathing},
\]

with the existing writing-event terms retained when integrating the saved experiment. The corresponding unforced continuous account is constant under the stated balance assumptions.

That is a valid mathematical accounting construction. It is not an independently identified physical G: its rate was defined to cancel the residual. Conversely, any independently proposed G that closes this same account must have the same change along this trajectory. The source question is therefore a constitutive identification—what energy of the actual carrying/history has that rate—not another unknown numerical deficit.

The original equations do not mention G, so appending a passive G=0 or appending the constructed history account leaves the same observed dynamics. Only the latter satisfies the desired balance by construction. The unchanged dynamics alone do not select its physical interpretation. A proposed independent functional could still establish the connection; none was supplied by the inspected passages.

## What the saved history requires numerically

This turn rechecked arithmetic from the previously validated **601-time path table** and the **62 old-potential samples**. It performed no new simulation, raw-frame evaluation or force integration. The original replay and state checks remain historical evidence.

At time 1.2/tick 41, using the endpoint summation-by-parts convention:

| Account | Change/work in model-energy units |
|---|---:|
| Endpoint-trapezoidal A/S path work | +2.4423658682e-5 |
| Candidate V | −1.3768910744e-5 |
| **Required G change** | **−1.0654747938e-5** |
| Conditional sum | 1.69e-21 |

Across all 601 times the maximum arithmetic defect is 6.78e-21. This close agreement is the expected discrete product-rule identity. It is **not** a newly measured physical reservoir closing the hole.

The native-stage path work is 2.4424319015e-5, differing from endpoint quadrature by 6.6033341633e-10. Using the source-rate integral instead requires G change −1.0655523043e-5 and leaves a native quadrature defect −1.1477166663e-10. Those known numerical distinctions are preserved; they do not supply the missing physical energy. The reported 43.6% belongs to this candidate/reference convention and saved experiment, not every possible unforced solution.

Full values are in [required-history-trace.csv](required-history-trace.csv) and [trace-check.json](trace-check.json).

## Correction when keeping the old pair potential

The previous answer's G appeared in an expression containing the old pair potential as well. If that potential is actually retained in the energy account, its own change must also be included. Write it P_pair and let λ≥0 be an **unspecified conversion to model-energy units**. Then

\[
\dot G=-\mathcal R-\lambda\dot P_{\rm pair},
\qquad
\boxed{\Delta G=-\int\mathcal R\,dt-\lambda\Delta P_{\rm pair}.}
\]

For the endpoint convention in this run this means

\[
\Delta G=-1.0654747938\times10^{-5}
-\lambda\,(7.6046573250\times10^{-9}).
\]

The second number is in the raw context-potential units before multiplication by λ. No conversion coefficient was fitted or assumed to be one. Since the pair potential's net change is nonnegative, retaining it cannot reduce the required debit from G. Omitting it sets λ=0 and returns the original 43.6% requirement. [Symbolic per-frame account](required-history-with-pair.csv).

## Verification

[HistoryRequirement.lean](HistoryRequirement.lean) proves that any differentiable G satisfying the required rate must have exactly the trajectory change above, and that including a nonnegative increase in the old potential cannot reduce the debit. These are conditional requirements, not an existence theorem for an independently specified physical G. The prior full-carrying and history-work proofs are preserved, not represented as freshly recompiled here.

The new modules compile and their axiom audit uses only the standard `propext`, `Classical.choice` and `Quot.sound`; see [verification.json](verification.json). Original source files and all reused receipts retained their hashes. The copied Python scripts retain the `work/carrying-history-G/` layout and local dependency paths; `build-native.ps1` accepts an existing matching Lean/Mathlib installation. No physical equation, coefficient, saved state or historical result was changed.

**The current outcome is an exact requirement and a conditional history account. A source-derived physical G that pays the 43.6% has still not been established.** Renaming the required account as an energy would not resolve that distinction.
