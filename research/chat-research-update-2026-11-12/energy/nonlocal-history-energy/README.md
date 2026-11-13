# Nonlocal carrying, history and the remaining energy account

**The specified nonlocal transfers do not fill the 43.6%. The checked original notes still do not supply an independent nonlocal stored-energy law that does.** There is a concrete result: the nonlocal flux explicitly constructed in the later notes cannot change the global energy deficit on the periodic domain. The carried spatial kernels and material stress transfers were also checked directly against the saved states.

No equations, coefficients or saved states were changed. There were zero new simulation steps. No new Lean theorem is claimed.

## The nonlocal mechanisms actually present

| Mechanism | Source and scope | What its energy account establishes |
|---|---|---|
| Accumulated A and normalized source K_h | Original A/S corpus | A retains input and K_h distributes the scalar source. Neither specifies a nonlocal gravitational storage density or an opposing energy debit. |
| Carried interpolation/spreading I_h and its adjoint | Later coupled material implementation | Transfers stress work between spatially separated grid and material representations. Their powers cancel globally. |
| Nonlocal allocation of writing power and thermal transport | Later coupled material implementation | Moves already-counted energy between viscous heating, material storage and heat; no additional global supply. |
| Nonlocal interaction flux −∇Δ⁻¹(r−mean(r)) | Later notes and current implementation | Corrects the spatial distribution of the local residual while deliberately retaining its mean. |
| Mirrored upper-half material-pair alignment | Older added comparison | Has a context-smoothing potential under fixed geometry; it is absent from the current run and does not supply a full gravitational energy law. |
| Material-encoded records, similarity-weighted retrieval and changing source weights | Current v3 implementation | Affect later evolution and source distribution. Their storage work is already in fabric/write/heat accounting. Retrieval weights are not an additional specified energy. |

The v3 solver overrides the older Volterra archive with retrieval from material-encoded records. It also removes the old mirrored paired-context source. Those historical mechanisms cannot silently be imported to pay this run's deficit. The older mirrored material pairing is distinct from the passive Pair 25 observer windows and from the user's intended continuing carrying relationship.

The source review is one targeted pass over the previously hash-checked 12 corpus documents, nine readable board archives and six later note files. It preserves original-versus-added provenance. The original reciprocal SR relation is an algebraic rescaling invariant, not a mapped dynamic energy for the spatial S field. Skipped board objects/images and live-board changes remain untested. See [source-check.json](source-check.json).

## Why the nonlocal flux cannot pay the global amount

The notes explicitly define, for a local energy residual r,

J_int = −∇Δ⁻¹(r−mean(r)).

On the periodic domain,

div J_int = −r+mean(r), ∫div J_int=0.

Therefore r+div J_int=mean(r): spatial variation can be redistributed, but the total remains. This is an analytical identity of the stated periodic inverse-Laplacian convention. It does not rule out a genuinely nonlocal *stored-energy functional*, which would contribute a time derivative rather than merely a divergence.

A direct diagnostic at all **62 saved states** tests this distinction. I removed A/S only from the *diagnostic energy account*, kept its force in the unchanged equations, and reconstructed a periodic correction flux. Breathing power was explicitly subtracted in the diagnostic. At tick 41/time 1.2:

| Quantity | Model power |
|---|---:|
| Mean residual before the diagnostic correction | 3.5043629814e-5 |
| Mean residual after it | 3.5043629814e-5 |
| Actual instantaneous A/S power | 3.5043629814e-5 |

The corrected residual is spatially constant within **2.64e-17** at this frame. Across all 62 frames, its mean agrees with A/S power within **1.90e-19**. This is a power test, not the cumulative 43.6% figure. The same zero-total-divergence identity prevents this type of periodic flux from supplying the cumulative **1.0654747938e-5** still required by the proposed activation-height account.

The native flux and the test flux are separate: the former already accounts for the model's local nonlocal transfers; the latter illustrates what happens if one tries to hide the omitted work in a redistribution flux. Neither was inserted into the state evolution.

## Carried kernels and interaction power

The saved-state checks also give:

- The moving source kernel has volume integral one, and its source weights sum to one, within 1e-12 at all frames.
- Spreading the parcel energy through the nonlocal interpolation changes its global total by at most **8.47e-22**.
- Fluid stress work and material stress work cancel within **3.39e-21**.
- Heat extraction and the assigned material writing power agree within **1.06e-22**.
- The old direct paired-context grid term is exactly zero in this run. Social and shared-history feedback remain active.

Thus these mechanisms can change where energy is located and how later motion develops, but their already-specified accounts do not reveal another global reservoir. Normalization of a scalar source alone would not prove energy conservation; the separate work/heat checks are essential.

Full values are in [nonlocal-check.json](nonlocal-check.json) and [nonlocal-checkpoints.csv](nonlocal-checkpoints.csv).

## A nonlocal potential that can be derived from the older pair law

For completeness, the older paired-alignment law has a mathematical potential when its geometry is held fixed. Let c_p=R_U C, π be its involutive partner map with equal partner volumes V_p, and w_p its nonnegative height gate. The old law is

d_p=k w_p w_πp B tanh[(c_πp−c_p)/B], D_pair=R_U*{V_p d_p}.

For k≥0 and B>0, define

F_pair[C]=½ k B² Σ_p V_p w_p w_πp log cosh[(c_πp−c_p)/B].

At fixed geometry, differentiating both members of each pair gives δF_pair/δC=−D_pair with the declared adjoint weights. Pair-only evolution Ċ=D_pair therefore gives

dF_pair/dt=−∫D_pair²≤0.

This is a derived **context-smoothing functional**, not an original physical energy law selected for the current model. Moving R_U, gates and configuration produce additional derivative terms. Advection, diffusion and the A/S source also enter the full derivative; the notes do not provide a corresponding physical stress/heat law that cancels all those terms. The current run does not include D_pair. Moreover F_pair is nonnegative and zero when C=0, so this positive potential would not supply a net release from this run's zero initial C even if evaluated diagnostically.

A small finite-dimensional derivative/adjoint check of this algebra is recorded in [pair-potential-check.json](pair-potential-check.json). It is not a new simulation or Lean theorem. No old pair term is activated and no force is changed.

## The independent calculation supplied by the user

The user supplied a separate three-part endpoint calculation from frames 0, 400, 599 and 600. Its endpoint total agrees with the earlier 62-frame check after rounding. Its third component, called “fabric wells,” groups **both** the fabric strain–memory term and the quartic well term:

4.3120438097e-8 + 8.4806239570e-11 = 4.3205244336e-8.

The user explicitly did not verify the 62-frame history, relaxation-to-heat transfer or searched original notes. Those limits are preserved. The pasted comparison is corroboration of the endpoint arithmetic, not independent verification of this whole analysis. The independent script or four source files were not supplied in that message.

## What remains missing

A nonlocal energy may depend on all carried points, their relationships and genuine history. To fill the residual, its independently defined change must be **−1.0654747938e-5** for the endpoint convention, with its time rate and event balances derived from the unchanged equations. This must include any energy in pair relations or shared history without counting the existing W and heat twice.

No such full energy functional and exchange law was identified in the checked original passages. The redistribution flux, normalized source kernel, memory retrieval weights and old paired smoothing law do not supply that missing identification. This is not a universal impossibility theorem for nonlocal energy, and it does not require redefining the user's intended single continuum as an externally driven system.

The 43.6% remains an unresolved physical account. Changing the description from local to nonlinear to nonlocal has now exposed specific mechanisms to check, but has not produced an additional source-derived storage law.

## Evidence and preservation

[Verification receipt](verification.json) records source/data hashes and test scope. The previous Lean and full-trajectory results are retained as historical evidence; they were not recompiled or rerun here. The scripts retain their original `work/nonlocal-history-energy/` layout and local dependencies. This package does not distribute all original simulation arrays. No source notes, physical equations, original coefficients or saved frames were edited.
