# What the full carrying check establishes

**The 43.6% remains an unfilled physical energy account. We have now traced its dominant contribution to diffusion and replenishment of the activation-driving scalar gradient.** Full configuration constrains that history, but neither the checked notes nor the implemented material/heat exchanges have supplied an independently specified energy store whose decrease pays this term. No original equation was changed.

## The new measured result

This table concerns the original threshold-1 saved experiment, time 0–1.2, with its historical breathing and write interventions preserved. It follows a uniform 16³ set of passive fluid labels through the saved Heun stages, using the actual finite-grid activation rule and resolved force. Amounts are in the model's energy units; no conversion to joules is asserted.

| Contribution to the activation-history demand | Integrated amount |
|---|---:|
| Diffusion changing the S/C gradient | +2.8253343788e-5 |
| Existing A/S source changing that gradient | −1.7574168830e-5 |
| Deformation contribution | −2.2763926056e-8 |
| Remaining discrete transport/filter contribution | −8.8798849599e-10 |
| **Net integrated demand** | **+1.0655523043e-5** |

This is a signed decomposition of how the candidate's missing term develops. The positive diffusion entry is not energy recovered from diffusion, and the source entry is not a separately verified energy reservoir. Their energy counterpart is the question still open. The existing heat equation contains viscous heating, material writing/release and thermal transport; it has no separately paired term for this activation-gradient demand.

The same paths reproduce the earlier endpoint-height release of **1.3768910744e-5** and endpoint history correction of **1.0654747938e-5**, exactly to the saved floating values. The new rate integral differs from that endpoint correction by **7.7510508296e-10**, because the native stage quadrature and endpoint summation-by-parts convention differ. Height release plus the new rate integral differs from the path work by **1.1477166663e-10**, or **4.70 parts per million** of that work. This small quadrature difference does not fill or remove the physical hole.

The 12³ passive-label calculation gives the same signed pattern. Changing 12³ to 16³ changes the net rate integral by about 2.0120e-10. This tests the passive integration, not grid convergence of the underlying continuum equations. The percentages refer to the specified displacement-based candidate; the measured full A/S work remains **2.4424321688e-5**.

## What full configuration adds to the proof

Writing the fluid configuration as F and its carried gradient history as G gives

**G=Fᵀ∇S, Ġ=Fᵀ∇Q, ∇S=F⁻ᵀG**, with Q=D_diff ΔS+κ A K_h.

Thus deformation and source history jointly determine activation. This corrects any inference that activation may simply be treated as independent of the full carrying configuration. The preceding restricted two-variable obstruction is not a no-go theorem for this larger state.

For the tested candidate V=σ ξ a(|F⁻ᵀG|−Γ), the energy rate has a specific deformation-stress contraction and a source-history contribution in addition to the opposite A/S power. Those are the terms measured above. The derivation and its exact assumptions are in [derivation.md](derivation.md).

**Six new Lean statements pass**, with only the standard `propext`, `Classical.choice`, and `Quot.sound` dependencies and no proof holes. They establish the finite-dimensional carried-gradient identities and conditional transfer balances. They do not prove existence of a smooth PDE solution, the spatial commutator, the simulator, or a gravitational storage law.

## The material store is already in the account

The full implemented W(F,m,b) was included. Over the threshold-1 continuous steps, stress transferred **1.7411405010e-6** into storage, directional writing transferred **1.8023368816e-7** from heat, and fabric relaxation returned **7.9241619708e-10** to heat. These are internal exchanges. Their combined energy-rate identity leaves the A/S power plus the recorded breathing power; its maximum defect over **1,200 stages** is **3.2526065175e-19**.

An independent finite difference of W(F,m,b) at the final saved state agrees with its stress/write/release rate within **5.17e-17** at the smallest tested perturbation. This checks an actual storage-rate formula rather than treating small endpoint storage as evidence that storage cannot matter. Event writing remains a separate recorded energy jump.

Counting those transfers again as payment for the activation demand would double-count them. Another independently derived energy functional of the full state/history remains possible; none has been identified by these checks.

## Pair 25 from saved data is now checked

The newly published complete membership files were used, together with the original local positions, F, m, and full endpoint states. Across all three saved continuations, **9,452,916 membership decisions** for three radii and A/B/union views agree exactly with geometry recomputed from the saved positions. In the primary windows, the same **133 material labels and 276 other observer labels** remain at every sampled step. All 384 material points change F and m; m does not decrease at recorded steps. The wider view reproduces observer 540 leaving and 872 arriving. The source certificate also matches the full shared-record bytes and context-origin accounts.

Pair 25 is a separate threshold-0.015 experiment, time 1.2–1.3. Its finest saved run gives:

| Full-domain endpoint account | Change |
|---|---:|
| Kinetic energy | +1.4785816816e-4 |
| Complete material stored energy | +6.5442520892e-6 |
| Heat | +6.3372822837e-5 |
| Total | +2.1777524309e-4 |
| Recorded A/S work | +1.4159002944e-4 |
| Recorded breathing work | +7.6185213525e-5 |
| Residual | +1.2405266430e-13 |

There are no write events during this interval. The material energy associated with the 133 initial primary-window members increases by **1.0046897269e-7**. These saved quantities therefore establish no net release from that assigned material energy to supply an extra term. They do not rule out transfers through storage or every possible larger energy functional. The window membership is not a complete inventory of physical contents, and local boundary transport cannot be confused with net global energy supply.

## Evidence and reproduction

- [New conditional Lean proofs](FullCarrying.lean), [axiom audit](logs/FullCarryingAudit.log), [verification receipt](verification.json).
- [Activation split and quadrature comparison](activation-results.json), [full time table](activation-history.csv).
- [Stage/state replay verification](stage-verification.json), [native transfer rates](native-transfer-rates.csv), [independent material derivative](storage-rate-check.json).
- [Pair 25 geometry, membership and energy recount](pair25-saved-check.json).

The replay compared every saved velocity stage, all **61 subsequent full checkpoints** (17 state blocks each), and the earlier reconstructed force samples. Maximum state difference was **7.77e-16**; force samples matched exactly. The initial checkpoint was loaded. Input hashes were checked before/after, and source equations and saved data remain unchanged. Pair 25 was checked read-only with **zero new solver steps**.

Use `build-native.ps1` with the pinned Lean toolchain and Mathlib cache, or the supplied Lake configuration. The scripts in `scripts/` preserve the original `work/full-carrying/` layout and absolute input paths; restore them there to reproduce the numerical checks. They also require the earlier `work/unwrapped-history/` scripts/data and the native local archives identified by the hashes. The ZIP is an evidence/source package, not a standalone distribution of the large simulation archives. Earlier output packages and receipts are preserved.

The next missing mathematical identification is precise: a storage functional derived from the existing carrying/source laws whose rate supplies the negative of the measured activation demand, with its exchange already present in the unchanged equations. The work ledger alone does not establish it.
