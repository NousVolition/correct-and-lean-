# Checking guard transport with a moving marker

At model time 0.603125, a marker is one thirty-second of the way from the 0.6 velocity snapshot to the 0.7 snapshot. Sample each snapshot at the marker's **new position**, then weight the samples by 31/32 and 1/32. The [matched-stretch tracker](https://github.com/NousVolition/My-Sources-Project-ALL/blob/f7b923c40011b2c3a261dc118959f75259cb5ce4/reports/matched-stretch/marker-stress/run.py#L81-L90) uses this rule in three dimensions with a snapshot interval of 0.01. This experiment uses the two-dimensional directional Hug–Navier equations and the 0.1 interval from the example.

## What the proof gains

For either guard $g$, the source equation has the form $\partial_t g+u\cdot\nabla g=(3/200)\Delta g+R_g$. Write $v$ for the velocity read by the marker. At the same time and position, adding $v\cdot\nabla g$ to the guard rate gives

$$
\partial_t g+v\cdot\nabla g=\tfrac{3}{200}\Delta g+R_g+(v-u)\cdot\nabla g.
$$

For a differentiable guard along a curve with velocity $v$, the left side is the derivative of the guard on that curve by the chain rule. Both diffusion and the directional reaction still contribute when $v=u$. The [Lean supplement](../../../lean/hug-navier-wellposedness-lean/GuardTransport.lean) checks the pointwise rate identity for both original guard equations, linearity of the velocity blend against a common gradient, and the two-history advection decomposition.

In the [classical uniqueness argument](../../../lean/hug-navier-wellposedness-lean/CLASSICAL-UNIQUENESS-ARGUMENT.md), take $\delta u=u-\tilde u$, let $h=g-\tilde g$, and use the comparison guard's gradient $\nabla\tilde g$. After separating common advection, the remaining integrand satisfies the fourth Lean result,

$$
|h\,\delta u\cdot\nabla\tilde g|\ \le\
\tfrac12\bigl(|\delta u|^2+h^2|\nabla\tilde g|^2\bigr).
$$

A bounded comparison gradient therefore controls this term by the difference energy. The sampled velocities below illustrate the term. The theorem holds for arbitrary pointwise values. Formalizing the periodic cancellation of common advection and the remaining space–time estimates is further work. Existence and full-system uniqueness remain open at the scope stated in the [proof status](../../../lean/hug-navier-wellposedness-lean/PROOF-STATUS.md).

## Withhold a field and predict it

We reran the [published two-dimensional solver](https://github.com/NousVolition/My-Sources-Project-ALL/blob/f7b923c40011b2c3a261dc118959f75259cb5ce4/reports/sims-navier-stokes-guard/model.py#L54-L83) from its prescribed initial condition, with directional guards, equal weights, and pulse B. We requested extra field outputs through 0.7. The original study saved full fields at 0, 1, 1.5, 2.5 and 4. The intermediate fields here are new finite-grid solver outputs.

We seeded 64 diagnostic markers at off-grid positions at 0.6. The 32×32 base run's two endpoint fields carried the markers by RK4. Every comparison used the same resulting positions, including the checks on the finer grid. Periodic Fourier evaluation sampled the native spatial representation. Guard advection errors use each withheld guard's own gradient at that same position. RMS velocity error is the square root of the mean **squared vector length** over the 64 markers, in model units.

| Test | 32×32, solver step 1/320 | 32×32, step 1/640 | 48×48, step 1/640 |
| --- | ---: | ---: | ---: |
| 0.603125, both snapshots sampled at the new position | 0.000037771 | 0.000037771 | 0.000037790 |
| 0.603125, earlier snapshot sampled at the old position | 0.00201647 | 0.00201647 | 0.00201648 |
| 0.65, predicted from 0.6 and 0.7 | 0.000309362 | 0.000309362 | 0.000309524 |
| 0.65, predicted from 0.625 and 0.675 | 0.000077354 | 0.000077354 | 0.000077395 |

On the 48×48 grid, reusing the old position increased the first error by a factor of 53.36. Halving snapshot spacing around the same withheld midpoint reduced the error by a factor of 4.00. At 0.603125, the RMS error in $v\cdot\nabla g$ was $2.71\times10^{-6}$ for $g_{AB}$ and $3.22\times10^{-6}$ for $g_{BA}$. These measurements concern one pulse and weighting condition and compare finite-grid fields. Additional conditions and spacings would be needed to infer a general convergence rate.

**Marker 17.** This is array index 17 in the new 2D sample. In the fine-grid comparison its earlier field's $x$-velocity read 0.538105 at the starting point and 0.538277 at the new point. The later field read 0.552305 at the new point. Their blend gave 0.538715. The withheld solver field gave 0.538747 there. The [full precision results](results.json) include both velocity components, positions, error maxima, and both guard errors for all three configurations.

## Reproduce the checks

From a checkout of this proof repository with its pinned Lean dependencies installed, run the supplement in the existing well-posedness package.

```sh
cd lean/hug-navier-wellposedness-lean
lake build FullModel
lake env lean -o .lake/build/lib/lean/GuardTransport.olean GuardTransport.lean
lake env leanchecker --verbose GuardTransport
```

We rebuilt the pinned `FullModel.lean` and checked the four declarations with Lean 4.34.0-rc2 and mathlib `85e3a25e006c35636f0e53b0e9296caca2685bc0`. The Lean kernel replayed the new module from its imports using `leanchecker`. Each axiom query reported only `propext`, `Classical.choice` and `Quot.sound`. The existing Comparator receipt covers the package's earlier diagnostic theorems.

Run the [numerical check](check_guard_transport.py) with NumPy and SciPy (tested with 2.3.5 and 1.18.1) and a checkout of `My-Sources-Project-ALL` at `f7b923c40011b2c3a261dc118959f75259cb5ce4`. The script verifies the solver and protocol hashes. An analytic, divergence-free shear tests both spatial axes, periodic wrapping, temporal endpoints and interior weights, guard gradients, and detection of the old-position substitution before the numerical runs.

```sh
python check_guard_transport.py /path/to/My-Sources-Project-ALL/reports/sims-navier-stokes-guard
```
