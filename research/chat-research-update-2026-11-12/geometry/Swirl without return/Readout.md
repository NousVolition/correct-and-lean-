# Same tick-41 reading, with nonzero swirl and no return

**PASS for the requested comparison at time 1.2.** Two smooth solutions of the same unforced periodic Navier–Stokes equations have the same closest-point reading and the same full swirl vector at A. One vortex line closes. The other winds indefinitely, never returns exactly, and stays uniformly away from zero swirl along the entire line at that time.

All four new proof modules passed in Lean. The final theorem directly applies the original ambiguity theorem to these certified fluid states.

## What is held fixed

| Reading or condition | Both states |
|---|---|
| Comparison time | T = 6/5 = 1.2 |
| Positions at T | A = (0,0,0); B = (0,0,1/4) |
| Closest point to B | A |
| Minimum periodic distance | 1/4 cube length |
| Winning arclength | 0 |
| Forward trace length | 3/4 cube length; the minimum is also valid on the entire line |
| Swirl at A | (0,W,0), with W = 4π exp(−0.015(4π)²T) > 0, matching the earlier example |
| Equations and domain | Unforced incompressible Navier–Stokes on the unit periodic cube |
| Viscosity | ν = 3/200 = 0.015 |

The axle direction and strength agree exactly. There is no zero-swirl endpoint or asymptotic approach to one on the open line. Lean proves the uniform bound

\[
|\omega|^2\geq W^2/2
\]

throughout the plane containing the line at T. Thus its swirl strength is always at least W/√2, about 70.7% of the strength at A.

![Nonzero winding compared with a closed line](<$USER_HOME/Documents/Codex/2026-11-10/lo/outputs/Swirl without return/Nonzero winding comparison.png>)

## Scope changes from the previous example

This is a new pair of full flows. A and B are identified by their common positions at the comparison time. Their earlier stationary particle histories and initial particle labels are not held fixed. In particular, velocity at A is now nonzero even though the curl there matches the previous reading.

The pressure fields are now p = −|u|²/2. They balance the turning of these flows within the ordinary Navier–Stokes pressure term. No external force, breathing term, threshold gate or tick-41 write was added. The old simulation and previous proof packages were preserved.

## The explicit fluid construction

Let h = 2πz, θ = 4π(x+y), λ = 6π. For a real parameter β, define

\[
V_{\beta,x}=-\beta\cos(3h)+(1-\beta)\sin(3h)
+\beta(\cos h+3\sin h)\cos\theta,
\]
\[
V_{\beta,y}=(1-\beta)\cos(3h)+\beta\sin(3h)
+\beta(\cos h-3\sin h)\cos\theta,
\]
\[
V_{\beta,z}=4\beta\sin h\sin\theta.
\]

Use β = 0 for the closed witness and β = 1/8 for the open witness. These fields obey

\[
\nabla\cdot V_\beta=0,\qquad
\nabla\times V_\beta=\lambda V_\beta,\qquad
\Delta V_\beta=-\lambda^2V_\beta.
\]

Set

\[
a(t)=\frac W\lambda e^{-\nu\lambda^2(t-T)},\qquad
u_\beta(x,t)=a(t)V_\beta(x),\qquad
p_\beta(x,t)=-\tfrac12|u_\beta(x,t)|^2.
\]

The decay gives ∂ₜu = νΔu. Because curl u = λu, the nonlinear advection equals ∇(|u|²/2), which is exactly balanced by −∇p. Thus both satisfy

\[
\partial_tu+(u\cdot\nabla)u=\nu\Delta u-\nabla p,
\qquad \nabla\cdot u=0.
\]

These are the standard unforced periodic equations in the [Clay problem statement](https://www.claymath.org/wp-content/uploads/2022/06/navierstokes.pdf). The broader use of exponentially decaying Beltrami fields as exact Navier–Stokes solutions is described in [Beltrami fields and knotted vortex structures in incompressible fluid flows](https://londmathsoc.onlinelibrary.wiley.com/doi/full/10.1112/blms.12780); the explicit pair above was constructed for this test.

Lean verifies the actual coordinate derivatives, curl, Laplacian, pressure gradient, nonlinear advection, smoothness and periodicity. It does not treat these derivative identities as supplied assumptions.

## Matching A and the closest point

At z = 0, write c = cos(4π(x+y)). The vorticity at T is

\[
\omega_\beta=W\bigl(\beta(c-1),\ 1+\beta(c-1),\ 0\bigr).
\]

At A, c = 1, so both give (0,W,0). Everywhere in this plane, ωᵧ−ωₓ = W. That forces |ω|² ≥ W²/2 and prevents a zero or a zero limit along either line.

Both complete vortex curves stay in z = 0. Every periodic image of B is vertically at least 1/4 away, and horizontal separation can only increase the distance. A attains the bound. This establishes the same closest point and distance globally, and therefore on the requested finite arclength trace. The earliest minimizing arclength is zero.

The traces no longer coincide geometrically away from A. They retain the specified reading and the full swirl vector at A.

## Why the open line never returns

The closed curve is (0,r,0); it returns periodically at r = 1.

For the open curve, put

\[
\mu=\sqrt2,\qquad \rho=\frac{\mu-1}{\mu+1},
\]
\[
Q(r)=\mu\left[r-\frac1{2\pi}
\arctan\left(\frac{\rho\sin(4\pi r)}{1+\rho\cos(4\pi r)}\right)\right],
\]
\[
\gamma(r)=\left(\frac{r-Q(r)}2,\frac{r+Q(r)}2,0\right).
\]

Here r = x+y is an unwrapped geometric parameter, not fluid time or arclength. Since 0 < ρ < 1, its denominator never vanishes. Lean proves

\[
Q(0)=0,\qquad Q'(r)=\frac4{3+\cos(4\pi r)}\in[1,2],
\qquad Q(n)=\sqrt2\,n\quad(n\in\mathbb Z).
\]

The curve starts at A and its tangent is a strictly positive multiple of the actual vorticity. Its true vortex parameter is τ = Q(r)/W. The checked parameter map is strictly increasing and onto the whole real line, so this is a complete trajectory rather than a finite or artificially stopped portion. The corresponding parameter for the closed line is τ = r/W.

If the open curve returned to A, both x and y would be integers. Then r = x+y would be an integer n, and Q(r) = y−x would be another integer m. But the exact identity above gives m = √2 n. A positive return has n > 0, contradicting irrationality. **Every positive return is excluded.** The argument does not depend on how long a numerical trace was followed.

All spatial dependence remains in Vβ as fluid time advances; a(t) is a positive scalar for every finite time. Therefore the same closed/open geometry persists under viscous decay. At each fixed finite time there is a positive spatial lower bound on swirl along the line. The strength tends to zero as fluid time tends to infinity; no finite-time zero or geometric endpoint is used.

## The theorem instance

| Item | Named meaning |
|---|---|
| State | Either full velocity/pressure solution above, with a certificate of smoothness, periodicity, incompressibility and the same unforced equation. |
| Observation | T, the closest point, its minimum distance and winning arclength, and the full vorticity vector at A. |
| Property | Does the complete vortex line through A have a positive periodic return? |

`same_observation` and `opposite_closure` establish the two required hypotheses. `no_exact_reader_with_closest_point_and_paddle` directly invokes `SIMSLatentReadout.no_exact_reader_of_ambiguous_observation`.

Consequently, even after excluding zero-swirl behavior on the line, this closest-point reading plus the paddle-wheel vector at A cannot decide closure correctly on a class of allowed fluid states containing both witnesses. This is an information limit of that observation; it does not identify the cause of the saved Hug closest-point switch.

## Verification and preservation

Four new modules passed in Lean 4.34.0-rc2 with Mathlib commit `85e3a25e006c35636f0e53b0e9296caca2685bc0`. All 34 principal axiom reports use only `propext`, `Classical.choice` and `Quot.sound`. There are no custom axioms, proof placeholders or `native_decide` in the checked sources. Three existing dependency modules were reused after source/object hash checks against their successful records.

The final logs, commands and source/object hashes are retained. Earlier failed check logs are diagnostic history, not passes. Plot samples illustrate the analytic formulas and were not used to prove nonreturn. No fluid simulation was rerun; original states and previous proof packages were read only. Fresh installation of the pinned dependencies was not tested.

[Fluid-equation proof](<$USER_HOME/Documents/Codex/2026-11-10/lo/outputs/Swirl without return/lean/WindingFluid.lean>) · [Irrational nonreturn proof](<$USER_HOME/Documents/Codex/2026-11-10/lo/outputs/Swirl without return/lean/WindingCurve.lean:195>) · [Direct theorem instance](<$USER_HOME/Documents/Codex/2026-11-10/lo/outputs/Swirl without return/lean/WindingInstance.lean:126>)
