# Full Hug–Navier existence and uniqueness: still unproved

The requested theorem has **not** been established. The source's full six-field equations, nonuniform initial data, periodic domain, directed guards and shared flow are preserved. The same returning student and the idea “giving someone space to speak can change what I understand” remain the interpretation; no measured personal or social quantities are inferred from the formal checks.

`CLASSICAL-UNIQUENESS-ARGUMENT.md` gives a written uniqueness argument for existing solutions with explicitly stated joint classical regularity. It retains every coupling and derives guard bounds before using positive viscosity. The full argument remains to be formalized. It uses stronger regularity than the saved predicate. Existence remains open.

The [guard transport supplement](GuardTransport.lean) now proves the two pointwise directional identities, the integrated guard energy bound and shared-transport cancellation on the periodic square. Its [test and checking record](../../research/matched-stretch/guard-transport/README.md) connects these lemmas to the classical uniqueness argument.

The [time-uniform extension](GuardTransportTime.lean) derives the guard-gradient bound from joint continuity on the compact time-cell and spatial periodicity, then applies the integral estimate to both guards of two existing `FieldProblem` solutions. One constant works throughout the chosen finite interval. The comparison history's extra joint guard-gradient continuity remains an explicit assumption, as in the stronger classical argument. This completes that connection, while the remaining energy estimates, existence, continuation, and broader saved uniqueness target remain open. [Walkthrough](GRADIENT-TRANSPORT-BRIDGE.md)

The [full-energy guard bound](EnergyEstimate.lean) now controls the sum of both guard transport residual magnitudes by one constant times the full six-field difference energy throughout the interval. It supplies that term in the energy argument; it does not prove the time-dependent energy inequality. [The exact remaining gap](ENERGY-INEQUALITY-GAP.md) starts with the integrated two-history energy balance and includes the invariant guard range and remaining stress, transport and reaction bounds.

The [time-interchange step](TimeIntegral.lean) proves the exact pointwise difference-energy derivative and passes it through the fixed cell integral at interior times, under the additional `JointDifferenceRateRegularity` condition. This is a sufficient analytic hypothesis on the unchanged rates; it is not derived from the original predicate or the earlier guard-gradient condition. The remaining integrated stress/diffusion balance is still open. [Assumptions and source-context distinctions](TIME-DERIVATIVE-ASSUMPTIONS.md)

`RequestedExistenceAndUniqueness` names the conjunction of the two previously saved full-system targets. It is a proposition, not an asserted axiom or a proved theorem. No new claim of full existence or uniqueness is made by this package.

## The proof routes examined

The installed mathlib Picard–Lindelöf theorem constructs curves for a vector field on a Banach space with a local Lipschitz bound in that space. It cannot be applied to the raw spatial PDE right-hand side merely because its pointwise reaction formulas are smooth. The source's second derivatives have to be controlled in an appropriate spatial function space.

The earlier Navier–Stokes verification checkout contains actual heat estimates and a local mild-solution construction. Its `Euler/QuadraticHeatLocal.lean` uses constant-viscosity heat evolution and quadratic coefficient maps between its particular cylinder Sobolev spaces. The complete Hug–Navier system has evolving viscosity in its principal differential operator, coupled scalar diffusion and a sigmoid depending on strain. I have not constructed the required function-space representation and estimates connecting that theorem to this system. Listing it as an import would not prove the connection.

Amann's [maximal-regularity framework](https://user.math.uzh.ch/amann/files/amannsolo.pdf) is a possible analytical route. Its local theorem has maximal-regularity and local-Lipschitz hypotheses in specified function spaces; its global conclusion requires a continuation bound. Those operator hypotheses have not been formally verified for this complete system here. The [Gallagher–Moussa paper](https://arxiv.org/html/2407.08226v3) supplies another relevant parabolic reference on a torus, but its displayed system is not itself a proof of this incompressible pressure-coupled model. These are research leads, not imported axioms or certificates.

## A precise obstruction to reusing the ordinary-ODE proof

Keep the source datum unchanged and consider nearby candidate fields solely to test a necessary regularity bound for the raw right-hand side. Change just its A-state coordinate by

\[
h_n(x,y)=\frac{\cos(nx)}{n^2},\qquad n\ge1.
\]

These increments are smooth and periodic, their values are at most (1/n^2) in magnitude, and the velocity and both guards are untouched. They are not substituted initial conditions for an existence claim.

For the exact source equations with equal weights and no optional pulse, evaluate the difference of the A-state rates at the origin. The transport perturbation vanishes there, while its Laplacian is −1. The full equation gives exactly

\[
R_A(z_n)(0,0)-R_A(z_0)(0,0)
=-\frac1{50}-\frac{3}{2n^2}.
\]

Thus arbitrarily small uniform changes of the state values need not give small uniform changes of this PDE rate. No local rate bound of the form “one fixed constant times the uniform state difference” can hold even on this family. A bound in a norm controlling spatial derivatives is a different assertion and is not ruled out.

The four challenge statements in this package concern this diagnostic calculation. **They do not assert nonexistence, nonuniqueness, blowup, or a defect in the source equation. They also do not replace the requested full theorem.** Their actual tool results are recorded separately in `verification-report.json` after execution.

## What is still required for the requested certificate

1. Specify and construct the spatial solution space, including the incompressibility constraint and pressure recovery, and prove local existence for the coupled variable-viscosity operator.
2. Derive bounds on the evolving solutions that permit continuation to each finite horizon claimed in `FullExistenceStatement`.
3. Prove that two solutions with the same initial fields and inputs agree in an explicitly stated regularity class. Pressure is determined only up to a spatially uniform function of time unless normalized.
4. Export those actual existence and uniqueness theorems to Comparator and have both kernels accept them. The diagnostic claims have different statements and cannot satisfy this step.

No finite grid, constant-guard approximation, force chosen after a desired trajectory, or unproved existence axiom was substituted. The current record does not decide whether the full theorem is true; it records that I have not supplied its proof.
