# The older paired-context potential and the remaining 43.6%

**The log-cosh potential follows from the older, added tanh alignment law under the stated gradient-flow convention. It does not follow from carrying continuity alone, and this particular potential cannot supply the remaining energy in the saved run—even with its geometry moving.** Its initial value is its minimum. The 62 saved states give a positive endpoint change, whereas closing the activation-height account requires a negative change.

This is a result about a specific candidate, not a proof that your intended carrying relationship cannot store gravitational energy. No original equation, solver coefficient, note or saved state was changed. There were no new simulation steps.

## What the source actually supplies

The carrying correction preserves your meaning: the relationship continues while position, shape and internal state change. It does not identify that whole relationship with a fixed spatial mirror, freeze the configuration, or introduce a separate mechanical system.

The historical specification makes the following choices separately:

| Item | Source status |
|---|---|
| Partners remain associated through solved motion | A realization of persistent carrying; their current positions need not remain mirror images. |
| Reference x-reflection selects partners | Explicit **proposal**, not a consequence of carrying continuity. |
| Product of two current height gates and a tanh alignment law | Explicit **added hypotheses**. |
| Gated, normalized receiving kernel and its adjoint | Part of the later computational realization. |
| Log-cosh functional | Derived here/last check from that particular alignment law; not a gravitational energy supplied by the original notes. |

`SPECIFICATION.md`, lines 261–283, calls the pairing and exchange proposals, describes their indirect mechanical influence through the scalar, and adds no separate pair traction or stress. `COUPLED_FIELD.md`, sections 1 and 7, likewise separates this exchange from the original A/S source. Its implemented height axis is laboratory z; the earlier scalar draft used laboratory y. This diagnostic follows the implemented z convention.

There is also a substantive later correction: `latest_interaction_design.json` explicitly supersedes the physical-half interpretation, records `fixed_physical_half: false`, retains history across context switches, and calls for replacing the fixed mirrored partner and spatial gate. Thus the old pair rule cannot be treated as the definition of your full carrying/history relationship. It is also distinct from the passive Pair 25 observation windows.

This was a targeted, read-only check of eight known source/provenance files. Exact passages, line numbers, paths and hashes are in [source-check.json](source-check.json). The earlier original-corpus/board review is retained as historical evidence; it was not repeated or represented as a new complete search.

## Full rate with moving configuration

Keep the reference partner map π and reference volumes V fixed, with π²=id and Vπp=Vp. Positions χ(t), sampling, heights and context all change. Set

\[
c_p=(R_U(\chi)C)_p,\qquad a_p=w(H_p)w(H_{\pi p}),\qquad
d_p=k a_p B\tanh\frac{c_{\pi p}-c_p}{B},
\]

\[
D=R_U^*\{V_pd_p\},\qquad
F=\frac{kB^2}{2}\sum_pV_pa_p\log\cosh\frac{c_{\pi p}-c_p}{B}.
\]

The grid inner product includes grid-cell volume. Differentiating the complete expression gives

\[
\boxed{\dot F=-\langle D,\dot C\rangle
-\sum_p V_pd_p(\dot R_U C)_p
+\frac{kB^2}{2}\sum_p V_p\dot a_p\log\cosh\frac{c_{\pi p}-c_p}{B}.}
\]

The second term includes parcel motion, motion of the centroid-based receiving gate, and differentiation of its normalization. The third includes both partner gates. They are not discarded or assumed to cancel.

At frozen geometry and under pair-only evolution Ċ=D, this reduces to −‖D‖². The actual saved solver has **D_pair=0**; its Ċ instead contains advection, diffusion and the A/S source. We evaluated the old functional passively along that unchanged evolution, without adding its old exchange term.

At time 1.2/tick 41, the derivative splits as follows, in raw diagnostic-potential units per model time:

| Contribution | Rate |
|---|---:|
| Context advection | +7.9167842509e-8 |
| Context diffusion | −2.4278868376e-8 |
| A/S scalar source | +1.8566130060e-8 |
| Moving receiving kernel | −8.3511762530e-8 |
| Moving pair gates | +1.5146123898e-11 |
| **Full rate** | **−1.0041512213e-8** |

This potential is decreasing at the final frame. That does **not** mean it supplies a net amount over the whole run: its endpoint value remains above its initial value.

## The net-energy test

For k≥0, B>0, Vp>0 and nonnegative gates, log cosh(z)≥0, hence F≥0. At the saved initial state C=0, every sampled context is zero and **F(0)=0 for any geometry**. Therefore

\[
F(T)-F(0)\ge0.
\]

This is an endpoint statement and does not assume frozen positions, monotone evolution, or an absence of intermediate release and replenishment. Any positive conversion to energy units preserves it. A constant reference-energy offset also cancels from the change.

All 62 saved states were evaluated using the old coefficients k=1.2, B=0.03, height scale 0.06 and thermal kernel width 0.045. The old reference-pair prescription was applied at the saved run's resolution (16³ grid, 384 parcels). Reference positions and volumes agree exactly with the current solver at that resolution; the reconstructed positive kernel agrees exactly with the old code at every checked frame.

- Initial diagnostic potential: **0**.
- Final diagnostic potential and net change: **+7.6046573250e-9**.
- Required additional storage change in the existing activation-height account: **−1.0654747938e-5** model-energy units, the reported **43.6%**.

The two numerical amounts are **not directly comparable in magnitude**. This normalization of the alignment functional has units of context² × volume / time; the notes do not supply its conversion to physical energy or a mobility establishing one. No fraction of the deficit is claimed from dividing these numbers. The decisive comparison is the direction: under any positive conversion, this candidate accumulates rather than supplies net energy.

The 43.6% remains the residual of this experiment and this activation-height account. It is not asserted as a universal percentage for every unforced HugandNavier solution.

## What the pair law leaves undetermined

At frozen configuration/history, the equation δF/δC=−D cannot determine a term independent of C. Adding

\[
E_{\rm extra}=F+G(\chi,\text{retained history})
\]

leaves that fixed-configuration context derivative unchanged, but adds Ġ to the full energy balance. This is the precise unresolved freedom: **the pair law does not tell us G**. Persistent carrying supplies kinematics and provenance; it does not by itself give the units, value or rate of that stored energy.

The old functional uses current carried samples and a persistent reference pairing. It has no independent all-history energy variable. The checked passages do not specify a G whose decrease supplies the residual, or existing work/heat transfers that establish that balance. Defining G afterward as minus the missing accumulated work would reproduce the ledger without deriving its physical source. Activating the removed exchange, fitting a coefficient, or adding a compensating stress/heat law would not establish conservation from the unchanged original equations.

This check therefore excludes the **canonical old alignment potential**, including its moving geometry, as the missing net supply. It leaves a genuinely source-derived configuration/history energy open; it does not prove that all such energies are impossible.

## Verification and limits

- [PairContext.lean](PairContext.lean) formalizes the actual log-cosh functional, its nonnegativity, its zero-context value, the full directed-pair chain rule with changing weights and sampled contexts, and the inability to pay a positive net demand from that initial minimum under nonnegative energy scaling and a constant offset. Compilation and axiom audit are recorded in [verification.json](verification.json).
- The collapsed adjoint rate above was derived analytically and checked numerically at all 62 frames: maximum difference from the direct chain rule **1.13e-22**. Directional finite differences of both configuration and context at five frames give a maximum error **7.02e-16** at perturbation size 1e-4. These perturbations evaluate a diagnostic; they do not advance the solver.
- The old pair term is exactly zero in every actual saved-state RHS. Source/state file hashes and loaded state arrays were unchanged. The full numerical receipt is [potential-check.json](potential-check.json); per-frame values are in [checkpoints.csv](checkpoints.csv).
- The Lean proof is finite-dimensional and conditional on the stated derivatives. The full spatial PDE, all-history constitutive identification, physical calibration and trajectory are not thereby formally verified. Original source documents, old proof packages and prior numerical receipts are preserved.

The copied scripts preserve their original `work/paired-context-energy/` layout and use the recorded local runtime and source locations; rerun them from that layout in the existing workspace. They are not a portable standalone distribution of the solver. `build-native.ps1` compiles the two supplied Lean modules using an existing matching Lean/Mathlib installation; it does not install dependencies. No full saved-run arrays are redistributed in this package.
