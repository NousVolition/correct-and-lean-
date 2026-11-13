# Full carrying configuration and the activation-energy demand

The target remains the original A/S–Navier equations. The user identifies one intended unforced continuum, with a continuing carrying relationship through changes of configuration. The historical driven numerical experiments and later constitutive choices remain evidence about their own implementations.

The previously measured 43.6% is the energetic counterpart still missing from the proposed activation-times-displacement store. A work integral measures this demand but does not identify its physical supplier. It is not the small numerical residual in the solver's work balance.

## Configuration determines activation history

Assume a smooth incompressible flow map χ(X,t), with F=D_Xχ invertible, L=∇u, g=∇S evaluated on the carried path, and

Q = D_diff ΔS + κ A K_h.

The unchanged scalar equation gives D_t S=Q. Differentiating in space gives

ġ = ∇Q − Lᵀg,       Ḟ=LF.

Define the carried gradient G=Fᵀg. Product differentiation cancels both deformation terms:

Ġ=Fᵀ∇Q,

G(t)=G(0)+∫₀ᵗ F(s)ᵀ∇Q(s) ds,

g=F⁻ᵀG,       α=a(|F⁻ᵀG|−Γ).

This is a genuine constraint from the existing transport equation. Activation and carrying are not arbitrary independent variables. G records the source/diffusion gradient in reference coordinates; it is defined without using the coupling-work ledger. F can change activation even when G is constant.

The Lean module proves the finite-dimensional product cancellation, carried-gradient derivative, inverse-transpose reconstruction under its exact inverse hypothesis, and integral history identity under continuous rates. The spatial PDE commutator and existence/invertibility of the flow map are analytical assumptions here, not newly formalized PDE theorems.

## What the proposed gravitational store requires

For ξ=χ_k−χ_k(0), take the candidate V=σ ξ a(|F⁻ᵀG|−Γ). This is the same displacement convention used in the earlier 43.6% calculation; it is a candidate, not a law identified in the notes. At |g|>0 and differentiable response a, put

c = σ ξ a'(|g|−Γ)/|g|.

Then

V̇ = −p_AS + τ_req:L + Y_G·Ġ,

τ_req = −c (g⊗g),       Y_G = c F⁻¹g,

p_AS=−σ α u_k.

Here τ_req is a coefficient in the candidate's energy derivative. It is not a new stress inserted into the momentum equation.

Consequently the remaining rate is

R = −c gᵀLg + c g·∇(D_diff ΔS) + c g·∇(κ A K_h).

The full configuration therefore gives concrete places to test: deformation, diffusive changes of the scalar gradient, and changes driven by the existing A/S source. It does not, just by retaining those histories, establish an energy decrease equal to −R. For this candidate, that decrease must be found in another independently specified part of the same continuum's stored energy or exchange law. A conserved combination constructed as minus accumulated work would not establish that identification.

The instantaneous two-variable no-go theorem in the preceding package did not address this correlated configuration. This analysis does not reuse it as a no-go theorem for the full state. Nor does failure to identify a store exclude all nonlocal or history-dependent storage laws.

## Compare with the actual material and heat transfers

The retained structural notes and v3 source specify a material energy W(F,m,b), its stress τ, heat-funded directional writing, and fabric relaxation that returns energy to heat. With viscous loss D, stress transfer T, directional writing J, and release B, their balances are

K̇ = −D−T+P_AS,

Ẇ = T+J−B,

Ḣ = D−J+B.

These quantities may depend on the entire coupled history. Their sum is still P_AS. Adding the candidate V leaves R. The new Lean theorem `complete_existing_transfers` checks this cancellation without requiring independently variable rates. The saved-run diagnostic checks the implemented transfers at every native Heun stage; added breathing work is explicitly included, while event writing is kept as the recorded jump work.

Thus the current material store is a real transfer/storage mechanism, but its already-counted stress, writing and heat exchanges cannot be counted a second time as payment of R. Small endpoint storage alone would not establish this; the rate identity is the relevant check. A different storage functional of the full configuration remains an open possibility, requiring an independent derivation and its own rate calculation.

## Respect the numerical carrier and observation boundary

The original continuum flow map is transported by u. In the regularized material implementation, saved material positions and F use v=I_hu, while the context scalar is transported by the fluid scheme. They must not be silently identified. With a smooth v-carried map, the corresponding effective scalar source is

Q_v=Q+(v−u)·∇S,

and the pullback identity becomes Ġ_v=F_vᵀ∇Q_v. The velocity difference belongs in the comparison; omitting it would manufacture a missing transfer or a false cancellation.

Pair 25's moving observation windows are a further distinction. Membership identifies which saved labels lie near the pair. It does not make the union of spheres a material volume or give an extra global energy term. A complete local energy account also needs transport across its boundary. Boundary transport can explain a local change but cannot supply net global energy on the periodic domain.

## Finite-run numerical decomposition

The threshold-1 run uses centered differences for ∇C and a retained Fourier force. The diagnostic differentiates the *actual smooth finite-grid activation map* with respect to the saved scalar rate. It follows the same passive fluid paths and Heun stages, and keeps four contributions to ∫ ξ D_t(σ α_resolved) dt:

1. A deformation term obtained by filtering −σ a' gᵀLg / sqrt(|g|²+δ²).
2. The exact derivative contribution of the native finite-volume diffusion term.
3. The exact derivative contribution of the native κ A kernel source.
4. The remaining native advection plus resolved path transport, after subtracting the deformation term.

The fourth term retains discrete product-rule and filtering effects. It is not removed, named heat, or treated as a discovered physical reservoir. A sum of mechanisms affecting activation identifies how the energetic demand develops; it is not an independent energy supplier. Heun integration of these rates is compared with the earlier endpoint summation-by-parts result, with the difference reported rather than forced to zero.

This finite-run test is separate from the continuum identity and does not establish continuum convergence. The 43.6% itself depends on the specified candidate and displacement reference; the full A/S work is the invariant measured quantity within this saved experiment's conventions.

## Source trail

- Original source: corrected-corpus.docx, paragraphs 230–231, 260, 517–520 and 545, previously transcribed and hash-bound in `gravity-storage-derivation/source-check.json` and the unchanged `OriginalAS.lean` in this package.
- Retained material notes: `STRUCTURAL_MEMORY.md` and `COUPLED_FIELD.md`, especially the carried configuration, constitutive energy/stress, and combined energy balance. Copies remain in the preceding `hug-source-energy-connection/sources` output.
- Meaning correction: repository `research/comparisons/hug-navier-single-system-scope-correction.md`. Its distinction between meaning, provisional implementation, and verified result is preserved.
- Native numerical source and all saved inputs are hash-bound in `stage-verification.json`; Pair 25 inputs and constitutive source files are in `pair25-saved-check.json`.

No original equations, constitutive coefficients, saved trajectories, work counters, or source notes are edited by this check.
