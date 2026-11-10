# Checking guard transport with a moving marker

At model time 0.603125, a marker is one thirty-second of the way from the 0.6 velocity snapshot to the 0.7 snapshot. Sample each snapshot at the marker's **new position**, then weight the samples by 31/32 and 1/32. The [matched-stretch tracker](https://github.com/NousVolition/My-Sources-Project-ALL/blob/f7b923c40011b2c3a261dc118959f75259cb5ce4/reports/matched-stretch/marker-stress/run.py#L81-L90) uses this rule in three dimensions with a snapshot interval of 0.01. This experiment uses the two-dimensional directional Hug–Navier equations and the 0.1 interval from the example.

## What the proof gains

For either guard $g$, the source equation has the form $\partial_t g+u\cdot\nabla g=(3/200)\Delta g+R_g$. Write $u_{\rm read}$ for the velocity read by the marker. At the same time and position, adding $u_{\rm read}\cdot\nabla g$ to the guard rate gives

$$
\partial_t g+u_{\rm read}\cdot\nabla g=\tfrac{3}{200}\Delta g+R_g+(u_{\rm read}-u)\cdot\nabla g.
$$

For a differentiable guard along a curve with velocity $u_{\rm read}$, the left side is the derivative of the guard on that curve by the chain rule. Both diffusion and the directional reaction still contribute when $u_{\rm read}=u$. The [Lean supplement](../../../lean/hug-navier-wellposedness-lean/GuardTransport.lean) checks the pointwise rate identity for both original guard equations, linearity of the velocity blend against a common gradient, and the two-history advection decomposition.

In the [classical uniqueness argument](../../../lean/hug-navier-wellposedness-lean/CLASSICAL-UNIQUENESS-ARGUMENT.md), take $\delta u=u-\tilde u$, let $h=g-\tilde g$, and use the comparison guard's gradient $\nabla\tilde g$. After separating common advection, the remaining integrand satisfies the pointwise Lean estimate,

$$
|h\,\delta u\cdot\nabla\tilde g|\ \le\
\tfrac12\bigl(|\delta u|^2+h^2|\nabla\tilde g|^2\bigr).
$$

A bounded comparison gradient therefore controls this term by the difference energy. The sampled velocities below illustrate the term. The theorem holds for arbitrary pointwise values. Lean also integrates this inequality over the whole periodic square and proves that shared, incompressible transport contributes exactly zero under the stated smoothness and periodicity hypotheses. The momentum, diffusion and time-dependent parts of the full energy argument still require formalization. Existence and full-system uniqueness remain open at the scope stated in the [proof status](../../../lean/hug-navier-wellposedness-lean/PROOF-STATUS.md).

## Withhold a field and predict it

We reran the [published two-dimensional solver](https://github.com/NousVolition/My-Sources-Project-ALL/blob/f7b923c40011b2c3a261dc118959f75259cb5ce4/reports/sims-navier-stokes-guard/model.py#L54-L83) from its prescribed initial condition, with directional guards, equal weights, and pulse B. We requested extra field outputs through 0.7. The original study saved full fields at 0, 1, 1.5, 2.5 and 4. The intermediate fields here are new finite-grid solver outputs.

We seeded 64 diagnostic markers at off-grid positions at 0.6. The 32×32 base run's two endpoint fields carried the markers by RK4. Every comparison used the same resulting positions, including the checks on the finer grid. Periodic Fourier evaluation sampled the native spatial representation. Guard advection errors use each withheld guard's own gradient at that same position. RMS velocity error is the square root of the mean **squared vector length** over the 64 markers, in model units.

| Test | 32×32, solver step 1/320 | 32×32, step 1/640 | 48×48, step 1/640 |
| --- | ---: | ---: | ---: |
| 0.603125, both snapshots sampled at the new position | 0.000037771 | 0.000037771 | 0.000037790 |
| 0.603125, earlier snapshot sampled at the old position | 0.00201647 | 0.00201647 | 0.00201648 |
| 0.65, predicted from 0.6 and 0.7 | 0.000309362 | 0.000309362 | 0.000309524 |
| 0.65, predicted from 0.625 and 0.675 | 0.000077354 | 0.000077354 | 0.000077395 |

On the 48×48 grid, reusing the old position increased the first error by a factor of 53.36. Halving snapshot spacing around the same withheld midpoint reduced the error by a factor of 4.00. At 0.603125, the RMS error in $u_{\rm read}\cdot\nabla g$ was $2.71\times10^{-6}$ for $g_{AB}$ and $3.22\times10^{-6}$ for $g_{BA}$. These measurements concern one pulse and weighting condition and compare finite-grid fields. Additional conditions and spacings would be needed to infer a general convergence rate.

**Marker 17.** This is array index 17 in the new 2D sample. In the fine-grid comparison its earlier field's $x$-velocity read 0.538105 at the starting point and 0.538277 at the new point. The later field read 0.552305 at the new point. Their blend gave 0.538715. The withheld solver field gave 0.538747 there. The [full precision results](results.json) include both velocity components, positions, error maxima, and both guard errors for all three configurations.

## Repeat across inputs and sampling intervals

The [broader Hug–Navier test](check_guard_breadth.py) uses all nine directional cases (three weight choices crossed with pulses A, B or neither). Each is tested over 0.4–0.5, 0.6–0.7 and 0.8–0.9 on the 48×48 grid with a solver step of 1/640. Each interval seeds a 16×16 off-grid array of 256 markers. Against the same withheld midpoint, the coarse-to-fine velocity RMS ratios range from 3.9990 to 3.9994 across the 27 comparisons. [All measurements](breadth-results.json)

## Withhold a basin field

The original **two-dimensional** closed-basin trail export labels all 401 specks at time 0.6 with coincidence prime 17. A marker ID identifies an individual speck. The 7.52 and 7.67 cases use a 384×384 flow grid. We reran the original closed-disk update and measured additional fields every 0.05 using the original 96×96 export grid and its float32 precision. All ten original 0.1-spaced velocity frames from 0 through 0.9 in each case matched their archived component arrays byte-for-byte. We moved the original 401 trail markers with the published 32 midpoint steps per 0.1 interval. Both predictions and the withheld reference sample the same positions.

| Held-out time | Case | RMS from fields 0.2 apart | RMS from fields 0.1 apart | Error ratio |
| --- | --- | ---: | ---: | ---: |
| 0.35 | 7.52 | 0.016108 | 0.004070 | 3.958 |
| 0.65 | 7.52 | 0.014335 | 0.003634 | 3.945 |
| 0.85 | 7.52 | 0.013910 | 0.003650 | 3.811 |
| 0.35 | 7.67 | 0.016773 | 0.004242 | 3.954 |
| 0.65 | 7.67 | 0.015304 | 0.003894 | 3.930 |
| 0.85 | 7.67 | 0.014726 | 0.003888 | 3.787 |

At 0.65 the narrower pair is 0.6 and 0.7. The wider pair is 0.55 and 0.75. Errors are RMS vector lengths in each flow's own model units. The spatial downsampling is shared by every prediction and reference. The basin ratios vary with time. The separate three-dimensional breathing runs have their own [solver provenance](basin_sources/README.md). [Basin replay](check_basin.py) · [Measurements and frame checksums](basin-results.json)

## Reproduce the checks

In the Hug–Navier well-posedness package, `lake build` builds the configured solution including the transport proofs. The Comparator comparison lists all ten declarations and checks them with the default Lean kernel and nanoda. [Verification report](../../../lean/hug-navier-wellposedness-lean/verification-report.json) · [Saved logs](../../../lean/hug-navier-wellposedness-lean/evidence-linux/)

Use NumPy and SciPy for the numerical checks. Run these commands beside the scripts. The two Hug–Navier checks require the upstream model folder at commit `f7b923c40011b2c3a261dc118959f75259cb5ce4`. The basin check uses the included closed-disk source. Its optional `--archive` argument points to the original `continued/` directory for bytewise comparison.

```sh
python check_guard_transport.py /path/to/My-Sources-Project-ALL/reports/sims-navier-stokes-guard
python check_guard_breadth.py /path/to/My-Sources-Project-ALL/reports/sims-navier-stokes-guard
python check_basin.py
```
