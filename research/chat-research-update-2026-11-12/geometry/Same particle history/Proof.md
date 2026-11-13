# An entire particle history can agree while vortex-line closure differs

This is an ordinary mathematical existence construction, using smooth linear parabolic theory and an implicit parameter choice. The accompanying Lean file checks selected algebra, geometry and the conditional observation theorem. It does **not** yet formalize the parabolic existence and parameter-selection steps or instantiate the complete fluid witnesses. The numerical example is an illustration, not a substitute for those steps.

## Statement and scope

Let ν = 3/200, tagging time t₀ = 589/500 = 1.178 and T = 6/5 = 1.2. On the unit three-dimensional torus there exist two smooth solutions of the **same unforced incompressible Navier–Stokes equations**, with different initial velocities, such that:

1. A is the same moving material particle path in both: A(t) = (0,(t−T)/10,0), modulo the periodic cube.
2. The actual vorticity vector at A(t) agrees for every t ∈ [t₀,T], including its direction and strength. It is nonzero throughout this interval.
3. At T both have ω(A,T) = (0,W,0), where W = 4π exp[−ν(4π)²T], preserving the preceding example's snapshot vector.
4. For B = (0,0,1/4) at T, both vortex lines through A have closest point C = A = (0,0,0), minimum periodic distance 1/4 and earliest winning arclength 0. This holds globally and on the forward trace of length 3/4.
5. One complete instantaneous vortex line at T closes. The other never returns exactly to A and has swirl strength bounded below by W/4 everywhere along it.

This is a new mathematical pair. It does not replay the saved Hug trajectory, reproduce the saved nonzero closest-point distance, or preserve B's earlier material path. The earlier permission to use periodic Navier–Stokes with different starts and any exact shared reading is retained; the numerical closest-point reading and paddle-wheel vector from the immediately preceding constructed pair are preserved. No claim is made that the closed/open distinction persists at every earlier fluid time.

The equation convention is

    ∂ₜu + (u·∇)u = νΔu − ∇p,    ∇·u = 0.

These are the unforced periodic equations in the [official Clay statement](https://www.claymath.org/wp-content/uploads/2022/06/navierstokes.pdf). The pressure is included below; no Hug, breathing, forcing, threshold or tick-write term is introduced.

The previous Beltrami pair is not itself a witness for this stronger question. It agrees at a fixed spatial origin, but its material particles leave that origin. On its z = 0 plane the closed flow has velocity proportional to (0,1,0), whereas the open flow's first component is proportional to β[cos(4π(x+y))−1]. Along the candidate common moving path this component cannot stay zero on a nontrivial interval. The previous formal PASS therefore was not carried over to the present history claim.

## 1. A common two-dimensional velocity and pressure

First work in coordinates (x,y,z), before a fixed rotation and constant-velocity change of frame. Put k = 2π and

\[
\Psi(x,y)=\sin(kx)\sin(ky)\bigl(\cos(kx)-\cos(ky)\bigr),
\qquad q(t)=e^{-5\nu k^2t},\qquad \psi=\varepsilon q(t)\Psi.
\]

Here ε > 0 will be sufficiently small. The identity

\[
\Psi=\tfrac12[\sin(2kx)\sin(ky)-\sin(kx)\sin(2ky)]
\]

gives ΔΨ = −5k²Ψ. Define

\[
b=(\psi_y,-\psi_x),\qquad
p=-\tfrac12\bigl(|\nabla\psi|^2+5k^2\psi^2\bigr).
\]

Then div b = 0 and ∂ₜb = νΔb. Its scalar vorticity is −Δψ = 5k²ψ. Direct differentiation, or the identity (b·∇)b = ∇(|b|²/2) − b×curl b, gives

\[
(b\cdot\nabla)b=\nabla\tfrac12\bigl(|\nabla\psi|^2+5k^2\psi^2\bigr)=-\nabla p.
\]

Thus b is an exact decaying two-dimensional Navier–Stokes velocity, with the displayed periodic pressure.

## 2. Three scalar solutions and the full three-dimensional flows

Let S, F and G solve the same linear equation on the unit two-torus:

\[
\partial_t h+b\cdot\nabla h=\nu\Delta h,
\]

with initial data

\[
S(0)=e^{\nu k^2T}\sin(kx),\quad
F(0)=e^{\nu k^2T}[\cos(kx)-\cos(ky)],\quad
G(0)=e^{2\nu k^2T}\sin(kx)\sin(ky).
\]

These are smooth periodic data and the common drift b is smooth with bounded derivatives on every finite time interval. The linear parabolic problem has unique smooth solutions. Periodicity follows by uniqueness after integer translation. Smooth dependence on ε in each finite Cᵐ norm follows from the difference equation and differentiated equations, or the heat-semigroup integral equation

\[
h_\varepsilon(t)=e^{\nu t\Delta}h(0)
-\varepsilon\int_0^t e^{\nu(t-s)\Delta}
q(s)(\Psi_y,-\Psi_x)\cdot\nabla h_\varepsilon(s)\,ds.
\]

For the smooth linear-drift existence and regularity result, see §1.5.3, page 46, of [Lenya Ryzhik's Stanford Math 272 notes](https://math.stanford.edu/~ryzhik/STANFORD/STANF272-21/lecture-notes-stanf272-21.pdf). Here only smooth bounded coefficients and smooth periodic initial data are used. No general three-dimensional Navier–Stokes regularity assertion is needed.

For real parameters β,η, set

\[
H_{\beta,\eta}=S+\beta(F+\eta G),\qquad
u_{\beta,\eta}=(\psi_y,-\psi_x,\alpha H_{\beta,\eta}),
\]

where α < 0 is constant in space and time, chosen below. The third component has no z dependence. Consequently:

- div u = div b = 0;
- the first two momentum equations are exactly those for b;
- the third momentum equation is exactly the displayed linear equation for αH;
- p has no z dependence and is the **same pressure in both states**.

This verifies the full unforced three-dimensional equation, including nonlinear advection and pressure. The construction supplies smooth solutions from t = 0 onward. Calling H a passive scalar describes the reduction; αH is actually a velocity component in the final fluid.

## 3. Exact equality of the material history

The function Ψ is invariant under R(x,y) = (−y,x), and changes sign under either coordinate reflection. Therefore b is equivariant under R and both reflections. The scalar evolution commutes with these symmetries by uniqueness.

The resulting symmetries are:

| Function | Exact symmetries at every time |
|---|---|
| S | odd in x; even in y |
| F | even in x and y; F(Rp) = −F(p) |
| G | odd in x and y; G(Rp) = −G(p) |

If h(Rp) = −h(p), evaluating and differentiating at the origin gives h(0) = −h(0), hᵧ(0) = −hₓ(0), and hₓ(0) = hᵧ(0). Hence

\[
F(0,t)=G(0,t)=0,\qquad \nabla F(0,t)=\nabla G(0,t)=0
\]

**for every time**, not merely at the recorded samples. Also S(0,t) = Sᵧ(0,t) = 0. Write m(t) = Sₓ(0,t). At ε = 0,

\[
m(t)=k e^{\nu k^2(T-t)}>0.
\]

Smooth dependence lets us choose ε > 0 small enough that m(t) > 0 on [0,T] and m(T) < 2k. Put

\[
\alpha=-\frac{W}{m(T)}.
\]

The origin is a stationary **material** particle for every β,η because ∇ψ(0,t) = 0 and H(0,t) = 0. The actual curl is

\[
\omega=(\alpha H_y,-\alpha H_x,5k^2\psi),
\]

so at that particle

\[
\omega(0,t)=\left(0,W\frac{m(t)}{m(T)},0\right).
\]

This entire vector function is independent of β and η. In fact the full velocity derivative matrix at the particle is also independent of those parameters: the velocity difference has zero value and zero first derivatives there. Thus the stretch matrix and carried-swirl comparison would agree as well, if appended to this observation.

To give A an explicitly moving path and restore the previous position of B, use the proper rotation Q(x,y,z) = (−z,y,x) and the constant velocity c = (0,1/10,0):

\[
v(P,t)=c+Q\,u\bigl(Q^{-1}[P-c(t-T)],t\bigr),
\quad
\widetilde p(P,t)=p\bigl(Q^{-1}[P-c(t-T)],t\bigr).
\]

A constant Galilean change of frame and a proper rotation preserve the same unforced equation and viscosity. A(t) = c(t−T) satisfies A′ = v(A(t),t) = c. Its vorticity remains the displayed vector. At T the shift is zero; Q maps the reference point (1/4,0,0) to B = (0,0,1/4).

## 4. Closed line, and a family of winding lines

All the following line geometry is at the single physical time T; the tracing parameter is distinct from physical time.

For the closed state use β = 0. Since S is odd in x, S(0,y,T) = 0. Both Sᵧ and Ψ vanish on x = 0. For sufficiently small ε, Sₓ(0,y,T) > k/2 uniformly in y, since its ε = 0 value is k. Thus the vortex line through the origin is precisely the nonvanishing circle (0,y,0), closing after y increases by one.

For the other state fix β = 1/8 and initially allow 0 ≤ η ≤ 1/2. At ε = 0, the chosen initial amplitudes give at time T

\[
H^0_{\beta,\eta}=\sin(kx)+\beta[\cos(kx)-\cos(ky)+\eta\sin(kx)\sin(ky)].
\]

On −1/8 ≤ x ≤ 0 its x derivative is strictly greater than k/2. Its value at x = −1/8 is uniformly negative. At x = 0 its value is β[1−cos(ky)], positive except at integer y.

These properties persist for sufficiently small ε. For the last property, use the **exact** identities S(0,y) = G(0,y) = 0 and F(0,0) = Fᵧ(0,0) = 0: C² closeness to 1−cos(ky) keeps F(0,y) positive away from integers and keeps its positive quadratic vanishing at integers. For example, on |y| ≤ 1/2, 1−cos(2πy) ≥ 8y², whereas a C² error with zero value and first derivative at zero is bounded by one half of its second-derivative bound times y².

The implicit function theorem therefore supplies a unique smooth periodic zero curve

\[
x=X_\eta(y),\qquad -1/8<X_\eta(y)\leq0,
\quad X_\eta(0)=0,\quad H_x(X_\eta(y),y,T)>k/2.
\]

The curve lies strictly at x < 0 when y is not an integer. It is an invariant level curve for the horizontal vorticity (αHᵧ,−αHₓ). Since −αHₓ > 0, y increases along the full vortex line. Its remaining coordinate obeys

\[
Z_\eta'(y)=\frac{5k^2\varepsilon q(T)\Psi(X_\eta(y),y)}{-\alpha H_x(X_\eta(y),y,T)},
\qquad Z_\eta(0)=0.
\]

The integrand is periodic. Define its exact one-turn displacement

\[
D(\varepsilon,\eta)=Z_\eta(1).
\]

Then Zη(n) = nD for every integer n. Both numerator and denominator are bounded; the denominator is bounded below. The y parametrization therefore covers the complete vortex trajectory in both directions, with a positive change of tracing clock. It is not a finite segment selected to avoid a return.

Furthermore, everywhere on this line,

\[
|\omega|\geq-\alpha H_x>\frac{W}{m(T)}\frac{k}{2}>\frac W4.
\]

Thus neither a zero-swirl endpoint nor an approach to zero swirl is used.

## 5. Why a nonzero irrational displacement exists

When η = 0, H is even in y, so X₀(y) is even. Ψ is odd in y. The one-turn integral is therefore exactly zero:

\[
D(\varepsilon,0)=0.
\]

We show that D changes with η; it is not secretly forced to stay zero. At ε = 0 write θ = kX₀(y), φ = ky, s = sin θ, c₀ = cos θ, d = cos φ, and b₀ = 1/8. The level equation is

\[
s+b_0c_0=b_0d,\qquad L=c_0-b_0s>0.
\]

Let Jη(y) = Ψ(Xη(y),y)/Hₓ(Xη(y),y,T) in this ε = 0 limit. Implicit differentiation gives θη = −b₀s sin φ/L at η = 0. Differentiating J and using the level equation and s²+c₀² = 1 yields

\[
\left.\partial_\eta J_\eta(y)\right|_{\eta=0}
=\frac{s^2\sin^2\varphi\,[2-(1+b_0^2)s^2]}{kL^3}.
\]

The numerator bracket is at least 63/64. The expression is positive on an open set of y and nonnegative everywhere, so its integral is **strictly positive**. Lean checks the rational expression obtained from the quotient and implicit-derivative rules, its reduction to the displayed formula, and the positive bracket. The actual implicit-function differentiation and passage through the integral are supplied here as ordinary analysis.

Although D(0,η) = 0 because ε = 0 removes the horizontal flow, D/ε has the smooth extension

\[
\frac{D}{\varepsilon}=
\frac{5k^2q(T)}{-\alpha(\varepsilon)}\int_0^1J_{\varepsilon,\eta}(y)\,dy.
\]

Its η derivative at (0,0) is strictly positive. Continuity therefore gives, for sufficiently small fixed ε > 0, a small η₁ ∈ (0,1/2) with D(ε,η₁) > 0. Choose an integer N sufficiently large that

\[
0<\delta=\frac{\sqrt2}{N}<D(\varepsilon,\eta_1).
\]

The intermediate value theorem supplies η* ∈ (0,η₁) with the **exact** equality D(ε,η*) = δ. This is the implicit parameter choice in the existence construction. It is not a decimal approximation declared irrational.

For the open witness take β = 1/8 and η = η*. A periodic return to the origin would require y = n for a positive integer n and Z(n) = nδ to be an integer. Irrationality of δ excludes that for every n > 0. The complete vortex line never returns exactly. It can come arbitrarily close on later windings; exact nonreturn is the property at issue.

## 6. The same closest-point reading

After Q, every point of the open line has physical third coordinate Xη(y) ∈ [−1/8,0]. The closed circle has third coordinate zero. For every integer image n of B, the third-coordinate separation is Xη(y)−1/4−n:

- if n ≥ 0, it is at most −1/4;
- if n ≤ −1, it is at least 5/8.

Thus every periodic distance to B is at least 1/4. A at y = 0 attains 1/4. The two other squared coordinate separations cannot reduce it. This proves the full-line minimum and hence the same minimum on the finite forward trace. The earliest minimizing arclength is 0. These image-distance inequalities are checked in Lean.

## 7. The history observation and the ambiguity theorem

| Item | Meaning in this construction |
|---|---|
| State | A full smooth velocity/pressure solution above, the tagged material path A, and B at T. |
| Observation | The functions t ↦ A(t) and t ↦ curl u(A(t),t) on [1.178,1.2], together with the tick-41 closest point, distance and winning arclength. |
| Property | Whether the complete instantaneous vortex line through A at T returns after positive tracing time. |

The construction proves equal observations and opposite property values. The original `no_exact_reader_of_ambiguous_observation` allows any observation type, including these entire time functions. Therefore it applies to this stronger observation as an ordinary mathematical consequence.

`HistoryMatchCore.no_exact_reader_with_history` checks that corollary in Lean **given** the history equality, closest-reading equality and opposite closure. The fluid states and their existence/selection arguments have not been installed as unconditional Lean witnesses. An end-to-end formal PASS is not claimed.

## 8. Verification, illustration and preservation

`Numerical checks.json` records an illustrative ε = 0.001, β = 1/8 calculation with η approximately 0.099360091806354. It normalizes the final paddle wheel to W and numerically selects a displacement near √2/100000. Spatial grids 32² and 48² and time steps 0.002 and 0.001 agree closely; first-jet/history discrepancies are around floating-point roundoff. A central time-difference check of the scalar equation decreases by about a factor of four when the time step is halved. These checks are neither a rigorous parameter enclosure nor a proof of irrational nonreturn.

In particular, the analytical proof chooses ε sufficiently small and selects η exactly by continuity. The numerical ε = 0.001 is a concrete illustration, not a certified bound for that existence proof. `Formal core verification.json` reports the ten checked statements, all using only the standard Lean axioms propext, Classical.choice and Quot.sound. Earlier failed logs are retained as diagnostic history; only the final successful log is a pass. Fresh installation of the pinned Lean/Mathlib dependencies was not tested. Original simulation files and all preceding proof packages were left unchanged.
