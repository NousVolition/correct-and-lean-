# Exact remaining proof obligations

Status: **UNPROVED**. This file is a map of the remaining work, not an additional assumption package to be declared as axioms.

The final Lean proposition is `HistoryCompletionTarget.FullPairExists`. Its two witnesses are actual velocity/pressure functions satisfying the unforced periodic equations, together with actual material and curl trajectories. The desired deliverable is an unconditional theorem of that proposition and then its ambiguity-theorem consequence.

## 1. Scalar existence and dependence

Supply `SmallParameterThreeScalarExistence` in `HistoryScalarLift.lean`, or a stronger theorem that implies it. It asks for some r > 0 such that for each 0 ≤ ε < r, the specified initial S, F and G have forward smooth periodic solutions. Each `ScalarEvolution` must certify actual time and space derivatives and solve

    h_t + b₁ h_x + b₂ h_y = ν Δh,
    b = HistoryPlanarBase.flow ε,
    ν = 3/200.

Then prove uniqueness and uniform C² dependence near ε = 0 on a compact spatial cell and 0 ≤ t ≤ 6/5. Higher regularity is needed for the implicit curve and its derivatives. Existence alone does not give these later properties.

The installed-library audit did not locate a directly usable general existence theorem for this equation. That is a bounded search result, not a claim that such a theorem is impossible or unavailable in every Lean project. External parabolic libraries were inspected, but none was imported or checked as a dependency here. A theorem for a Lipschitz map from one Sobolev space to itself cannot be applied to the derivative-losing map h ↦ b·∇h without proving appropriate mapping and regularity estimates.

## 2. Symmetries and the shared history

Derive the reflection and quarter-turn symmetries from the actual PDE and uniqueness. In particular, at the origin prove F = G = 0 and ∇F = ∇G = 0 at every time, with S = S_y = 0. The existing first-jet algebra consumes derivative symmetry identities; it does not prove those identities from PDE uniqueness.

Set m(t) = S_x(0,t). Prove m(t) > 0 on [0,6/5] and m(6/5) < 2k for small positive ε, where k = 2π. Define α = −W/m(6/5), with the required W. Prove the actual velocity vanishes at the origin and the actual curl there is (0,W m(t)/m(6/5),0), independent of β and η.

## 3. The displacement used by parameter selection

For β = 1/8, construct the unique periodic root X(ε,η,y) of H(x,y,6/5) = 0 in −1/8 < x ≤ 0, and prove H_x > k/2 there. The sign of H at x = 0 must use its exact vanishing jet and a uniform second-derivative bound near integer y; pointwise continuity alone does not supply this sign.

Construct the one-turn integral D(ε,η) from the actual curl and an extension E of D/ε at ε = 0. Prove:

- E(ε,0) = 0, using reflection symmetry.
- `HasDerivAt (E 0) d 0` for some d > 0.
- The continuity in ε and η required by `select_parameters`.
- A common positive parameter rectangle on which the regularity, strip and swirl bounds all hold.

The checked `select_parameters` theorem uses an E defined on all real parameters and two-sided continuity at ε = 0. If scalar existence is proved only for nonnegative ε, provide a suitable continuous extension of E, or prove a one-sided version of the selector. Do not silently identify right continuity with `ContinuousAt`.

The algebraic identity for the derivative integrand is checked in the earlier core. The implicit derivative, the positive integral, and interchange of derivative and integral still require formal proofs for these actual functions. Once these hypotheses are established, the checked selection theorem supplies ε, η and N with D = sqrt(2)/N exactly.

## 4. Complete lines and their geometry

Construct Z(y) as the integral of the actual vertical-to-horizontal curl ratio. Prove its increment is D over every full turn, including the integer identity Z(n) = nD.

Construct a globally defined strictly increasing y-clock that reparametrizes (X(y),y,Z(y)) as a solution of γ′ = curl u(γ), in both tracing directions. Establish the bounds needed for global existence of that clock. A curve tangent to curl up to an unspecified multiplier does not yet satisfy the final target's `line_equation`.

For β = 0 prove the circle closes. For the selected β = 1/8 state, use the actual turn identity and irrational D to exclude every positive return modulo the integer lattice. Prove the nonzero swirl floor everywhere and the global distance bound to all periodic images of B. No finite numerical trace can replace the universal quantifiers in these statements.

## 5. Moving A and final assembly

Verify the transformation Q(x,y,z) = (−z,y,x), c = (0,1/10,0),

    v(P,t) = c + Q u(Q⁻¹(P − c(t−6/5)),t),

with the corresponding pressure transformation. Derive the actual derivatives, divergence, curl and momentum equation after this transformation, including periodicity. Then A(t) = (0,(t−6/5)/10,0) must be certified as a material path in both states.

Assemble both `FluidState` values. Prove equal pressure functions and equal curl histories on [589/500,6/5], closure of the first line and nonclosure of the second. Only then prove `FullPairExists` and apply `full_pair_rules_out_exact_reader` without leaving `FullPairExists` as an input hypothesis.

## Required final audit

Check the resulting closed existence theorem in Lean, print its axioms, and trace its source dependencies. It must introduce neither an assumed fluid witness nor an assumed parameter satisfying the desired conclusion. A source scan alone is insufficient; successful compilation of unrelated or conditional theorems is also insufficient.
