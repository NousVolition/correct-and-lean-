# Same closest point and same paddle wheel, different closure

**PASS at the fixed comparison time 1.2.** Two exact solutions of the same unforced, periodic Navier–Stokes equations have the same closest-point reading and the same complete vorticity vector at A. One vortex trajectory returns to A; the other never returns. The enlarged observation is a checked instance of your ambiguity theorem.

This construction uses a zero of vorticity farther along the open line. Every point actually reached on its integral curve has nonzero swirl; the curve approaches the zero asymptotically. The open result concerns tracing the line with fluid time held at 1.2. This example does not keep that line open at every later fluid time.

## Exactly what matches

| Quantity | Both solutions at time 1.2 |
|---|---|
| Tagged water particles | A = (0,0,0), B = (0,0,1/4) |
| Closest point on the forward trace | A |
| Minimum periodic distance to B | 1/4 cube length |
| Winning arclength from A | 0 |
| Trace length | 3/4 cube length |
| Full vorticity vector at A | (0,W,0), where W = 4π exp(−0.015(4π)²·1.2) > 0 |

Thus both the axle direction and the swirl strength match exactly. This is also the vorticity vector of the previous closed witness at A. The comparison uses a new pair of full velocity fields; it preserves the specified readings from the previous example.

Both A and B are stationary material particles from time zero onward. The two new curves also coincide geometrically throughout the full forward trace: both are (0,s,0), for 0 ≤ s ≤ 3/4, with coordinates understood periodically. Swirl strength away from A is not part of the observation and differs between the two flows.

![The swirl strengths agree at A and differ farther along the line](<$USER_HOME/Documents/Codex/2026-11-10/lo/outputs/Closest point and paddle wheel/Swirl along the two lines.png>)

## The two exact flows

Set T = 6/5, ν = 3/200, k = 4π, ℓ = 2π,

\[
q(t)=e^{-\nu k^2t},\qquad R(t)=e^{-\nu\ell^2(t-T)}.
\]

Define

\[
u_{\rm closed}(x,y,z,t)=(0,0,-q(t)\sin(kx)),
\]

\[
u_{\rm open}(x,y,z,t)=
(0,0,-2q(t)\sin(kx)[1-R(t)\cos(\ell y+\pi/3)]).
\]

For both flows, p = 0 and external force f = 0. They are smooth and unit-periodic, and use the same positive viscosity. They satisfy

\[
\partial_tu+(u\cdot\nabla)u=\nu\Delta u-\nabla p+f,
\qquad \nabla\cdot u=0.
\]

These are the standard equations and periodic setting in the [Clay problem statement, equations (1), (2), (8) and (10)](https://www.claymath.org/wp-content/uploads/2022/06/navierstokes.pdf).

Only the z component of velocity is nonzero, and it does not depend on z. Divergence and advection therefore vanish. Each remaining Fourier mode decays at its heat-equation rate: νk² for sin(kx), and ν(k²+ℓ²) for sin(kx)cos(ℓy+π/3). The factor exp(νℓ²T) fixes the second mode's starting amplitude so the chosen comparison occurs at T. It is part of the initial condition, not an added force or a write at tick 41.

Lean verifies the coordinate derivatives, the full fluid equation, smoothness, periodicity and stationary material markers.

## Why the paddle wheel matches

At T, R(T) = 1. Along x = z = 0, the actual curls are

\[
\omega_{\rm closed}(0,y,0,T)=(0,W,0),
\]

\[
\omega_{\rm open}(0,y,0,T)=(0,Wg(y),0),
\qquad g(y)=2[1-\cos(2\pi y+\pi/3)].
\]

At A, y = 0 and g(0) = 2(1−1/2) = 1. Hence the vectors are identical and nonzero. Any function of that vector, including its magnitude and normalized direction, also agrees.

On 0 ≤ y ≤ 3/4, g(y) is strictly positive. Thus both normalized vortex traces have unit tangent (0,1,0). This verifies the shared trace as an actual vortex trace, rather than merely drawing two arbitrary matching curves. Since every trace point lies in z = 0 and B lies at z = 1/4, the periodic distance is at least 1/4, attained at A. The earlier exact closest-point certificate applies to this common geometry, including its earliest-arclength tie rule.

## Why only one returns

Let λ denote the vortex-line parameter; fluid time remains fixed at T.

The closed integral curve is (0,Wλ,0). At λ = 1/W it reaches (0,1,0), which is A in the periodic box.

An exact integral curve for the open case is (0,y(λ),0), where

\[
y(\lambda)=\frac13-
\frac{\arctan(\sqrt3-4\pi W\lambda)}{\pi}.
\]

Lean verifies that it starts at A and that its derivative equals the computed curl, for every real λ. For every λ > 0 it proves

\[
0<y(\lambda)<\frac56<1.
\]

A periodic return would require y to be an integer. These bounds exclude every positive return, with no finite sampling cutoff.

From the explicit arctangent formula, y approaches 5/6 as λ tends to infinity. At y = 5/6 the swirl is zero. The zero lies beyond the saved trace length 3/4, so it does not invalidate that trace. Vorticity stays nonzero at every point reached for finite λ, as also checked in Lean.

Geometrically, the open trajectory follows the same circle with its zero-swirl point excluded. Adding that limiting point would close the geometric set, but would not make it a regular periodic vortex trajectory. The property tested here is a positive return of the vortex trajectory through A.

## The enlarged ambiguity instance

| Item | Definition used in the proof |
|---|---|
| State | Either explicitly defined flow, together with its smoothness, periodicity, incompressibility and Navier–Stokes certificate. |
| Observation | Time T; closest point, distance and winning arclength on the trace; and the full computed vorticity vector at A. |
| Property | Does the complete vortex trajectory through A return periodically after a positive vortex parameter? |

The final proof directly applies `no_exact_reader_of_ambiguous_observation` to equal enlarged observations and opposite closure values. Therefore **adding this paddle-wheel reading at A still does not allow a reader to determine closure correctly for every allowed state containing these two witnesses**.

The flow is smooth in both cases. This is not a blowup, a closest-point switch, or a reconstruction of the saved Hug simulation. The theorem concerns an observation at one fixed fluid time. In this particular construction R(t) < 1 for t > T, so the zero on the y-circle disappears under later viscous evolution and the line can complete the circuit. No claim of permanent nonclosure is made.

## Verification and files

Three new modules passed in Lean 4.34.0-rc2 with Mathlib commit `85e3a25e006c35636f0e53b0e9296caca2685bc0`. Their 23 principal axiom reports contain only `propext`, `Classical.choice` and `Quot.sound`. The checked sources contain no custom axioms, proof placeholders or `native_decide`. Three existing dependency modules were reused after source/object hash checks against their successful records.

The fluid solver was not rerun. Previous simulation data, previous proof packages and the user's original equations were read only. Initial failed check logs are retained as diagnostics and are not counted as passes. The graph evaluates the exact formulas for illustration; sampled plot values are not used as proof. Fresh installation of the pinned Lean dependencies was not tested.

[Fluid and paddle-wheel proof](<$USER_HOME/Documents/Codex/2026-11-10/lo/outputs/Closest point and paddle wheel/lean/MatchingPaddleFluid.lean>) · [Complete vortex-line proof](<$USER_HOME/Documents/Codex/2026-11-10/lo/outputs/Closest point and paddle wheel/lean/MatchingPaddleLines.lean>) · [Direct enlarged-observation theorem](<$USER_HOME/Documents/Codex/2026-11-10/lo/outputs/Closest point and paddle wheel/lean/MatchingPaddleInstance.lean>)
