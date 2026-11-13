# A uniqueness argument for the unchanged full PDE

**Status: written argument with Lean-checked guard transport steps. The full argument is written. It proves an at-most-one result in the regularity class below, provided solutions exist. It does not construct a solution, establish global existence, or prove the broader saved Lean uniqueness target.**

Consider the exact six-field directional system in `FullModel.lean`, on the same two-dimensional periodic square, with the same initial data and the same prescribed inputs for both candidate solutions. The agent and idea are unchanged; the comparison is between two candidate mathematical histories of that same encounter.

Assume the candidate solutions have jointly continuous space/time fields, first time derivatives and spatial derivatives through order two on the finite interval under consideration. Pressure has jointly continuous first spatial derivatives. These are analytical regularity assumptions. They are stronger than the pointwise-in-time conditions of the saved `FieldProblem` predicate, and have not been obtained from an existence theorem here.

## Guard bounds for such solutions

The sigmoid is strictly between 0 and 1 for every finite argument. Suppose a guard, initially 1/2, becomes negative. On a compact time interval ending at an interior violation time, its negative has a positive space/time maximum. Periodicity supplies a spatial local maximum there, so its spatial gradient is zero and its Laplacian is nonpositive. This maximum cannot occur initially. Its time derivative is nonnegative when approached from the left. The full guard equation instead makes that derivative strictly negative: the transport term is zero, diffusion is nonpositive, and the reaction is −(sigmoid + the positive maximum)/0.6. This is a contradiction. The same argument applied to guard − 1 rules out values above 1. Endpoint violations reduce to interior violations by continuity.

Consequently both candidates have guards in [0,1], and their viscosities are at least ν₀ = 1/50 throughout. This argument uses the full advection-diffusion-reaction equation, not a guard ODE.

## Compare two complete histories

Write their differences as

\[
v=u-\widetilde u,\quad a=x_A-\widetilde x_A,\quad b=x_B-\widetilde x_B,
\quad h=g_{AB}-\widetilde g_{AB},\quad j=g_{BA}-\widetilde g_{BA}.
\]

Let

\[
E(t)=\frac12\int_{\mathbb T^2}(|v|^2+a^2+b^2+h^2+j^2).
\]

The regularity assumptions and compactness give a finite bound M on the two candidates' field values and first spatial derivatives. Constants below may depend on M, the fixed coefficients and the finite interval. They do not depend on E or on the differences.

The guard-gradient part of this step is now formalized in `GuardTransportTime.lean`. Joint continuity of each comparison guard's two spatial derivatives on the closed time interval times the closed periodic cell gives a finite bound by compactness. Periodicity extends it to all spatial representatives. `fieldproblem_guard_transport_bounds` then applies the existing integral estimate to both actual guard differences with one constant valid at every time. The extra joint continuity is stated explicitly by `JointGuardGradientRegularity`; it is not deduced from the weaker pointwise-in-time `FieldProblem` predicate. [Step-by-step connection](GRADIENT-TRANSPORT-BRIDGE.md)

For momentum, subtract the full equations, retain both parts of the variable stress and test with v. Incompressibility and periodicity cancel pressure and common advection. The result is

\[
\frac12\frac{d}{dt}\|v\|_2^2+
\int2\nu(g)|D v|^2
=-\int v\cdot((v\cdot\nabla)\widetilde u)
-\int2\delta\nu\,D\widetilde u:Dv,
\quad \delta\nu=(h+j)/25.
\]

The right side is bounded by (C E+\epsilon\|Dv\|_2^2), using Cauchy–Schwarz and Young's inequality. In particular, viscosity gradients were not deleted: integration by parts was applied to the complete stress divergence.

For the A-state reaction, its exact difference is

\[
-a+k_{AB}\{g_{AB}(b-a)+h(\widetilde x_B-\widetilde x_A)\}.
\]

The analogous B expression has the opposite state difference and its own guard and weight. The prescribed inputs cancel. Testing these two difference equations with a and b, the common transport cancels, the residual transport is (v\cdot\nabla\widetilde x_i), and their total contribution is bounded by (CE), with their nonnegative scalar diffusion dissipation retained on the left.

For guards, the sigmoid derivative is at most 1/4: writing r = exp(−s) > 0, this is (r/(1+r)^2\le1/4), equivalent to ((r-1)^2\ge0). Thus, for either directional target,

\[
|\delta\mathrm{target}|
\le\tfrac12(|a|+|b|)
+\tfrac18(|Du|+|D\widetilde u|)|Dv|
\le\tfrac12(|a|+|b|)+\tfrac M4|Dv|,
\]

where M bounds each strain magnitude. Testing both guard difference equations with h and j cancels common transport. Their remaining transport, relaxation and state terms are bounded by (CE); their strain-coupling terms are bounded by (CE+\epsilon\|Dv\|_2^2). Guard diffusion remains nonnegative on the left.

For either comparison guard $\tilde g$, the sharpened pointwise step is

$$
|h\,v\cdot\nabla\tilde g|
\le \tfrac12\bigl(|v|^2+h^2|\nabla\tilde g|^2\bigr),
\qquad h=g-\tilde g .
$$

Here $v=u-\tilde u$ is the difference of the two candidate velocities. The numerical marker's reading is $u_{\rm read}$. For $C^1$ periodic velocity and guard difference and an incompressible transporting velocity, `common_transport_cancels` proves $\int h\,u\cdot\nabla h=0$ over the full fundamental square. Its proof integrates the two flux derivatives in their respective coordinate directions. Periodicity gives equal endpoint fluxes, and incompressibility cancels the remaining divergence term.

The theorem `integrated_residual_bound` bounds the absolute integral of the residual by $\frac12(\|v\|_2^2+M^2\|h\|_2^2)$ given $|\nabla\tilde g|^2\le M^2$. Use $j$ for the second guard difference. [Lean declarations](GuardTransport.lean) · [Withheld-field tests](../../research/matched-stretch/guard-transport/README.md)

Choose the two Young-inequality parameters so their total is less than (2\nu_0). Summing all six component balances gives

\[
E'(t)\le C E(t),\qquad E(0)=0,\qquad E(t)\ge0.
\]

Gronwall's inequality gives E(t) = 0. Spatial continuity then gives equality of the velocity, both participant states and both guards everywhere on the interval. Substitution into the momentum equations gives \(\nabla(p-\widetilde p)=0\); on the connected periodic domain, the remaining pressure difference depends only on time.

This supplies a classical uniqueness argument with explicit regularity assumptions and pressure freedom. The work still needed for a Lean certificate is to formalize the compact-domain maximum principle, the remaining momentum and diffusion integration-by-parts identities, the space/time estimates and their application to these full PDE solutions. The generic Gronwall theorem alone does not verify those steps. The existence construction and continuation estimates remain separate unresolved work.
