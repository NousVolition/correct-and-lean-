# The two edge loops after viscosity scaling

**Follow-up on the musical comparison.** Eight additional checked statements test the edge itself, arbitrarily faint readings just inside, and the same fixed spatial loop during early rest and at a later nonzero reading. [Read the spatial and temporal controls](../as-vortex-edge-control-lean/RESEARCH-NOTE.md).

**Can the signed A/S pushes drive any of the periodic vortices obtained by OpenAI’s rescaling?** For each of the three Cartesian choices of the force direction in the two-loop proof, the answer for exact reproduction of the velocity is **no**, at every positive viscosity and for every permitted compression of the selected construction. Near the singular time, the vortex needs a nonzero push around each of two perpendicular closed loops. A force directed along one fixed Cartesian axis necessarily gives zero on at least one of them. The obstruction uses the velocity that OpenAI actually periodizes. [Same-field theorem](RescaleCorollary.lean) · [All-scale exclusion](RescaleForcing.lean)

## What is carried through the change of scale?

Write \(U\) for the selected compact velocity at viscosity one, \(s=\sqrt\nu\), and \(\ell>1\) for the compression. The spatial dilation changes viscosity first. The parabolic compression then changes space and time together. At time \(t\) sufficiently close to one and on the central copy, the resulting velocity is

\[
u_{\nu,\ell}(t,x)=\ell s\,U(t_*,\alpha x),\qquad
t_*=1-\ell^2(1-t),\qquad \alpha=\ell/s.
\]

The compact pressure carries amplitude \(\ell^2\nu\) and the prescribed compact force carries amplitude \(\ell^3s\). OpenAI repeats the compressed fields with unit spatial period. The loop in the final box still goes from \(-1/2\) to \(1/2\). Changing variables maps that interval into \([-\alpha/2,\alpha/2]\) in the original compact field, where the residual on the line vanishes outside \([-1/4,1/4]\). The fit of the compact support into the open unit cell gives \(\alpha>1/2\), so the mapped interval contains the entire contribution. Near each loop the lattice sum agrees locally with the compact field, which permits taking the actual time derivative, advection and Laplacian there. [Support and periodization](RescaleSupport.lean) · [Momentum and integral transformation](RescaleCovariance.lean) · [OpenAI’s §10.5](https://cdn.openai.com/pdf/32d9f210-8b73-45e0-91bc-82a30aef8a9a/navier-stokes.pdf#page=125)

Let \(\delta=1/\alpha=\sqrt\nu/\ell\). Let \(G(t_*,d)\) denote the previously proved viscosity-one edge signal, the inward derivative of the time-minus-diffusion defect of the cutoff heat trace. The offset \(d\) is measured in the original coordinates. The edge of the compressed field lies at \(\delta/4\). The table reads the pressure-free momentum residual \(R_\nu(u,0)=u_t+(u\cdot\nabla)u-\nu\Delta u\) on the middle plane.

| Complete unit loop | Component integrated | Reading |
|---|---|---|
| Hold \(x=\delta(1/4-d)\), traverse \(y\) | \(R_\nu(u,0)_y\) | \(+\ell^2\nu\,G(t_*,d)\) |
| Hold \(y=\delta(1/4-d)\), traverse \(x\) | \(R_\nu(u,0)_x\) | \(-\ell^2\nu\,G(t_*,d)\) |

The momentum residual brings a factor \(\ell^3s\) and the line integral brings \(s/\ell\). Their product \(\ell^2\nu\) is strictly positive. For the quarter-cube compression in the pinned theorem, both equalities hold throughout \(-1/16<d<1/8\) in one late-time window. At **each** sufficiently late time, **some** common offset in \([0,1/8)\) makes both readings nonzero. The offset may depend on time. Even under the weaker condition that the entire scaled support cylinder fits strictly inside the unit cell, this inner range already suffices. [Two identities](RescaleLoops.lean) · [Nonzero pair](RescaleForcing.lean) · [Edge signal at viscosity one](../as-vortex-hline-lean/HLineProofs.lean)

## What this tells us about the A/S equation

The signed branch in the corrected corpus has
\[
f_{\rm AS}(t,x)=-c\,a_\varepsilon(\lVert\nabla S(t,x)\rVert-\Gamma_{\rm crit})e_k,
\qquad a_\varepsilon(q)=\tfrac12 q\bigl(1+\tanh(q/\varepsilon)\bigr),\qquad c=\sigma/\rho.
\]
The existing memory and transport equations determine which histories of \(S\) are feasible. The exclusion allows *any* \(S(t,\cdot)\) in this force law, so a history obeying the existing memory and transport equations is already included. At viscosity one Lean also checks that the new momentum comparison reduces exactly to the previous A/S comparison. [Corpus equation register](https://github.com/NousVolition/Nous-Volition/blob/b4ae2c54cd85bfef282c501ecfca83de274e2070/studies/community-chain-audit/equation_register.csv) · [Original signed branch](../as-signed-vortex-lean/SignedDefinitions.lean) · [Matching predicates](RescaleFields.lean)

If the force points along \(x\), its contribution along the \(y\)-loop is zero. If it points along \(y\), use the \(x\)-loop. For the vertical axis either loop works. A spatially \(C^1\), periodic pressure contributes its endpoint difference around the chosen loop, exactly zero. At the offset just proved to exist, the vortex requires a nonzero reading on that very loop. Consequently there is no matching pressure and scalar field there, and no time-dependent pair that produces the target velocity throughout \(0<t<1\). The box average can still cancel exactly as in the earlier audit. [Pressure cancellation and exclusion](RescaleForcing.lean) · [Original whole-box cancellation](../as-signed-vortex-lean/SignedSolution.lean)

## Which family is covered?

The proof follows the source’s selected whole-space candidate, its viscosity dilation, its parabolic compression and its final periodization. For every \(\nu>0\), it constructs witnesses sharing the very same velocity, pressure, force and support between the loop proof and the pinned periodic breakdown theorem. OpenAI’s original absence of a global smooth periodic solution uses its **own prescribed force**. Our conclusion about the A/S law comes from the two closed loops. The exclusion holds for every admissible scale and every selected schedule, including the witnesses produced by OpenAI’s compression lemma. [Constructed witnesses](RescaleCorollary.lean) · [Pinned periodization theorem](https://github.com/openai/NavierStokesAndEuler/blob/f9e8bc5b38b6e212696e8a30e3e91517af887bbd/NavierStokes/PeriodicPaperTheorem.lean#L155-L162)

## What remains open

The corrected corpus displays a single vector \(e_k\) and describes it as a “fixed unit direction”. The checked comparison represents \(k\) as one of the three Cartesian coordinates. If that phrase includes a fixed oblique vector with nonzero components along both horizontal axes, neither of these two coordinate loops is perpendicular to it. The present proof leaves that reading open. [Corrected corpus, governing momentum equation and variable definitions](../outputs/full-fluid-transfer-source-review/sources/original-corpus/corrected-corpus.docx) · [Exact type of the force direction](RescaleFields.lean)

The proof supplies a late-time window and a nonzero offset by existence. It gives no numeric onset time, offset, or lower bound on the magnitude uniform in viscosity. Other velocity fields, other localizations and approximate reproduction would each need their own argument. Which complete A/S histories can sustain a nontrivial vortex or sustained whole-box cancellation also remains open.

## Verification

**PASS for 12 new theorems.** The clean Linux replay ran on 9 November 2026 from 04:46:28 to 05:09:21 UTC. Comparator matched the twelve frozen statements against the solutions. Nanoda and Lean’s default kernel both accepted the export. The default build and the separate axiom listing each exited with code zero. Every solution theorem uses only `propext`, `Classical.choice` and `Quot.sound`. The earlier 25-target signed-force audit and five-target edge proof have their own reports. [Verification record](verification-report.json) · [Comparator log](evidence/comparator.log) · [Axiom list](evidence/axioms.log)

This package and both inherited audit packages started with empty build directories. All twelve external repositories were checked against their pinned clean revisions. Input hashes agreed before and after the run, including the original signed force and comparison predicate. The corrected corpus file also matched the SHA-256 recorded by both earlier audits. [Frozen inputs](reference-freeze.json) · [Preflight](evidence/preflight.json) · [Postflight](evidence/postflight.json)
