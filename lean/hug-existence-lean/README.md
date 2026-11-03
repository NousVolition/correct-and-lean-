# Full coupled later Hug: existence and uniqueness

This package proves `ActiveHug.Verified.full_coupled_existence_uniqueness` for the unchanged eight-state primary directional Hug model. The final check results are recorded in `verification-report.json`; the reference statement was frozen before proof implementation in `existence-reference-freeze.json`.

## Exact scope of the theorem

For every pair of finite times `a <= b`, every prescribed force continuous on `[a,b]`, and every real initial state whose two guards lie in `[0,1]`, there exists a solution of all eight coupled equations on `[a,b]`. Any other continuous integral solution with the same initial state and force agrees with it throughout that interval. The solution satisfies the differential equations at every interior time, and both guards remain in `[0,1]` throughout the closed interval.

The eight evolving coordinates are displacement `q`, velocity `v`, Kelvin strain `u`, Maxwell strain `w`, participant states `xA` and `xB`, and guards `gAB` and `gBA`. None is frozen or omitted. The nonlinear squeeze feedback, velocity-dependent guard targets, directional participant interaction, changing resistance and external force all remain coupled.

The theorem covers every finite forward horizon, not merely a short local interval. In particular, it does not require an assumed bound on the trajectory or an assumed Lipschitz constant for the full unbounded field. It establishes existence without finite-time breakdown under its stated conditions. It states the result interval by interval, with uniqueness ensuring agreement on overlaps; it does not introduce a separate function defined on an infinite time domain.

## Preserved equations and assumptions

The imported `ActiveHugModel.lean` is byte-for-byte identical to the model in the earlier 51-claim Hug proof package. Its source is `NousVolition/Nous-Volition` at commit `b4ae2c54cd85bfef282c501ecfca83de274e2070`, specifically the physical-unit equations in `studies/hug-active-guard/METHODS.md`, `model.py` and the primary `protocol.json` settings.

The equations are:

```text
sigma = GM (q/L - u - w)
q' = v
m v' = F + (a - b q^2) v - c (gAB + gBA) v - k q - (V/L) sigma
u' = (sigma - GK u)/etaK
w' = sigma/etaM
xA' = lambda (baselineA - xA) + gAB (xB - xA)
xB' = lambda (baselineB - xB) + gBA (xA - xB)
tau gAB' = sigmoid(theta + beta (xB - xA) + chi S) - gAB
tau gBA' = sigmoid(theta + beta (xA - xB) + chi S) - gBA
S = (1/2) (v/Q * rateReference)^2
sigmoid(z) = 1/(1 + exp(-z))
```

The fixed primary settings are mass 0.2, spring stiffness 0.7, volume `10^-7`, length 0.1, Maxwell modulus 28000, Kelvin modulus 19000, viscosities 5200000 and 900000, active gain 0.03, saturation 3000000, damping per guard 0.01, displacement scale 0.0001, rate reference 1, participant relaxation 1, baselines -0.55 and 0.35, both directional weights 1, guard response time 0.6, and guard coefficients -0.4, 2 and 0.5. These are the source's settings, not new fitted values.

The continuous-force hypothesis is explicit. No bound fixed in advance is imposed on that force: continuity supplies a finite bound on each compact time interval. Mechanical strains, displacement, velocity and participant states may start at any real values. Initial guards must lie in their stated transmission interval. The theorem does not address arbitrary parameter replacements, discontinuous forcing, or initially out-of-range guards.

The source describes this as a reduced synthetic Hug realization. The distinct memory-field extension is not silently combined with the guard-damper system. No independent memory PDE or additional accumulator has been inserted into these eight equations.

## How the proof handles the nonlinear term

Smoothness gives a Lipschitz bound on each bounded state region. It does not give a single global Lipschitz constant: the term involving `q^2 v` prevents using that shortcut.

On a chosen interval, let `M >= 0` bound the absolute prescribed force, and set `R0 = 1 + norm(initial)` using the maximum coordinate norm. The proof uses the deliberately loose comparison radius

```text
R(t) = R0 exp((100 + 5 M)(t-a)).
```

The six unrestricted coordinates stay between `-R(t)` and `R(t)`. The two guards stay between zero and one. These bounds are analytical estimates in the chosen coordinates, not predicted physical amplitudes, calibrated rates or additional model terms.

To construct a solution, an auxiliary field evaluates the original rates at a projection into this moving box. It is globally Lipschitz on the chosen time interval, so the proved integral fixed-point construction applies. Scalar comparison arguments then prove that its solution always stays inside the box. `project_identity` and `solution_congr_field` consequently recover the exact original field along the entire constructed trajectory. The final theorem contains no projection, modified coefficient, extra state, or clipping rule.

For uniqueness, two candidate original solutions are continuous and hence bounded on the interval. Their guards satisfy the same interval theorem. A common auxiliary box therefore leaves both candidates unchanged, and the integral uniqueness theorem forces equality. The fundamental theorem of calculus supplies the interior differential equation from the original integral equation.

## File guide

- `ActiveHugModel.lean`: unchanged source model and protocol.
- `HugFullClaim.lean`: reversible eight-coordinate representation and the exact final proposition.
- `HugExistenceChallenge.lean`: frozen Comparator target, with its intentional reference-only placeholder.
- `Volterra.lean`: previously proved general integral fixed-point existence and uniqueness machinery, copied without editing the earlier package.
- `HugTools.lean`: smoothness, bounded-region Lipschitz estimates, coordinate integral identities and scalar comparison.
- `HugBox.lean`: auxiliary projection and the original field's upper and lower boundary estimates.
- `HugBounds.lean`: moving bounds and guard invariance for the auxiliary solution.
- `HugConstruction.lean`: recovery of the original equations, full existence, uniqueness and differentiability.
- `HugExistenceSolution.lean`: proof of the exact frozen final proposition.
- `source-provenance.json`: source snapshots, unchanged model hash and prior package receipt.
- `verification-inputs.json`: hashes of all final inputs to the isolated check.
- `evidence-linux/`: preflight, Comparator, Linux build and postflight records.

## Checking and remaining scope

The configured checks are the native Windows Lean build, a fresh Linux Comparator run under real Landrun and the prescribed systemd restriction, independent nanoda and Lean kernel replay, and the normal Linux Lake build. The allowed axioms are only `propext`, `Quot.sound` and `Classical.choice`. Proof modules contain no `sorry`, `admit`, new axiom or unsafe declaration. The reference-only `sorry` in the challenge is not part of the solution proof.

The pinned toolchain remains Lean 4.34.0-rc2, mathlib `85e3a25e006c35636f0e53b0e9296caca2685bc0`, and Comparator `19e111e2141cf333c7daff0f64c5f24acc91dd2e`. Fresh verification uses an unused Linux directory, no precompiled project solution, the existing trusted dependency builds and a non-root user. Dependency commits and tool hashes are recorded. The previous Hug and A/S packages are preserved.

This proves mathematical well-posedness within the stated scope. It does not prove a limit cycle, synchronization, a recovery time, material contact or rupture, empirical parameter validity, Python floating-point correctness, or a measurement map from these variables to social experience. The separate complete memory-field system and other parameter/control variants retain their own proof obligations.

For a standalone checkout, install the pinned dependencies and run `lake build`. The supplied native and Linux scripts use this workstation's existing tool locations. `build-dev.sh` is a development helper only; its directory and compiled files are excluded from the isolated final check and the archive.
