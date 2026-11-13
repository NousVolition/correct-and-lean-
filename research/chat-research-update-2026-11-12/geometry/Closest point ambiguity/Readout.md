# Closed and open vortex lines with one exact closest-point reading

**PASS. The ambiguity theorem applies to a pair of exact periodic Navier–Stokes solutions at time 1.2.** Both give the same closest point, distance and arclength reading. One vortex line closes; the other has no positive return at all. The fluid equations, geometric claims and direct theorem application were checked in Lean.

This uses the scope you selected: periodic Navier–Stokes with different starting flows, and any exactly shared reading at time 1.2. It is a new mathematical example, not a reconstruction of the saved Hug run or its closest-point switch.

## State, observation and property

| Item | Exact definition |
|---|---|
| State | A smooth velocity/pressure solution in the family below, on the unit three-dimensional periodic box, with the same two tagged water particles A and B. Lean's state type includes a certificate of the fluid-equation requirements. |
| Observation | At time 6/5: closest point C on the forward vortex trace of length 3/4 through A, its arclength s from A, and its periodic distance d to B. Ties use the earliest arclength. |
| Property | Does the entire vortex line through A return to A modulo the periodic box after some strictly positive parameter? |
| Closed witness | Parameter a = 0. |
| Open witness | Parameter a = √2. Here “open” means nonclosed: there are no endpoints or tears. |

The shared observation is **time = 1.2, C = A = (0,0,0), s = 0, d = 1/4**. The parameter, velocity field and vorticity vector are not included in that observation.

## Both flows solve the same equations

Use the unit torus, viscosity ν = 3/200 = 0.015, wavenumber k = 4π and decay q(t) = exp(−νk²t). For any real a, define

\[
u_a(x,y,z,t)=q(t)\sin(kz)(1,-a,0),\qquad p=0,\qquad f=0.
\]

These use the standard incompressible equations

\[
\partial_t u+(u\cdot\nabla)u=\nu\Delta u-\nabla p+f,
\qquad \nabla\cdot u=0,
\]

with the same periodic boundary conditions and the same force in both cases. Only the initial velocity differs. These equations and the unit-periodic setting are specified in the [Clay problem statement, equations (1), (2), (8) and (10)](https://www.claymath.org/wp-content/uploads/2022/06/navierstokes.pdf).

The checks are exact: velocity depends only on z, and its z component is zero. Consequently its divergence and advection term vanish. Also Δu = −k²u and ∂ₜu = −νk²u, so the remaining terms balance. Sine gives spatial periodicity; sine and exponential give smoothness. Lean checks these derivative identities rather than accepting supplied derivative values.

Choose A = (0,0,0) and B = (0,0,1/4). Both are stationary material particles in both flows: sin(0) = sin(π) = 0. Thus the same water particles can be followed from time zero to time 1.2.

## Why one line closes and the other never does

The actual curl is

\[
\omega_a=kq(t)\cos(kz)(a,1,0).
\]

At z = 0 its scale kq(t) is strictly positive at every finite time. Therefore the vortex line through A is

\[
\gamma_a(r)=(ar,r,0)\pmod{\mathbb Z^3}.
\]

Lean verifies that multiplying the parameter by kq(t) makes this an exact integral curve of the computed curl. Its arclength parametrization is γₐ(s/√(a²+1)), with unit tangent.

For a = 0, γ₀(1) = (0,1,0), which is A in the periodic box. The line closes after one cube length.

For a = √2, a return would require both r = n and √2r = m for integers n and m. A positive return has n ≠ 0, which would imply √2 = m/n. That contradicts irrationality. **This excludes every positive return, however late.** It does not infer nonclosure from a missed numerical circuit.

## Why the closest-point readings are exactly equal

Every point on either line lies at z = 0. B lies at z = 1/4. For every integer image of B, the vertical separation has magnitude at least 1/4; the horizontal components can only increase the squared distance. A attains distance 1/4 in both cases.

This proves the shared reading on the forward trace of length 3/4, with earliest minimizing arclength zero. In fact, the same distance bound holds along the entire line, so matching the nearest point and distance is not an artifact of truncating the trace.

The `ValidReading` predicate checks the point's membership on the trace, the allowed arclength, nonnegative distance, attainment of the distance at an integer image, comparison with every trace point and every integer image, and the earliest-parameter tie rule. The common observation is backed by that predicate; it is not an arbitrary matching label.

## Direct theorem application

In `Tick41ClosestPointInstance.lean`, the state is a parameter together with its `Admissible` certificate. Observation and property are named explicitly. Lean proves

`observation closedState = observation openState`

and

`property closedState ≠ property openState`.

The final result directly invokes `SIMSLatentReadout.no_exact_reader_of_ambiguous_observation`. Consequently **no reader using only this observation can decide vortex-line closure correctly for every state in this family**. The obstruction also applies to any larger allowed family containing both witnesses and using the same observation.

## What this settles, and what it leaves open

It settles the requested existence test under your chosen scope: the same fluid equations allow a closed line and a nonclosed line with exactly the same closest-point reading at time 1.2.

The example has its minimum at the trace's starting point and has no closest-point switch. It does not reproduce the saved interior minimum or establish what caused the switch. Its two vorticity vectors at A differ, so this result does not claim that the paddle-wheel direction or the full velocity field can also be identical. The added Hug material, breathing and write rules are outside this chosen equation class. Time 1.2 is the comparison time; there is no write event in these flows.

The earlier saved-return certificates remain useful as checks of their particular exported returns. Missing those returns does not prove that the corresponding whole vortex lines never close later. The new irrationality argument supplies that stronger property for the constructed open witness only.

## Verification and preservation

All three new proof modules passed in the installed Lean 4.34.0-rc2 environment, using Mathlib commit `85e3a25e006c35636f0e53b0e9296caca2685bc0`. The 20 principal axiom reports contain only `propext`, `Classical.choice` and `Quot.sound`. The successful source modules contain no custom axioms, proof placeholders or `native_decide` calls. The original general theorem module was copied with its source and compiled-object hashes verified against its prior successful check.

The final logs and source/object hashes are retained in the three module verification records and the combined `Verification.json`. Earlier failed check logs and a small derivative diagnostic are retained as historical diagnostics, not successful verification. Nonblocking style warnings in the successful fluid log do not affect its result.

The saved fluid data and previous proofs were read only. No simulation was rerun, no prior equation was changed, and no equality is based on rounded numerical output. Fresh installation of the pinned dependencies was not tested.

[Geometry proof](<$USER_HOME/Documents/Codex/2026-11-10/lo/outputs/Closest point ambiguity/lean/ClosestPointGeometry.lean>) · [Fluid-equation proof](<$USER_HOME/Documents/Codex/2026-11-10/lo/outputs/Closest point ambiguity/lean/PeriodicNavierStokes.lean>) · [Direct tick-41 theorem instance](<$USER_HOME/Documents/Codex/2026-11-10/lo/outputs/Closest point ambiguity/lean/Tick41ClosestPointInstance.lean>)
