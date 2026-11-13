# A/S suppression comparison

**Proved:** with matched starting data and inputs, both S coordinates stay at or
below their values without suppression throughout each finite interval.

The theorem compares the full evolving histories, including allowed input
switches. It covers signed S values, zero or unequal exchange weights, and an
interval whose endpoints coincide. Smoke and Clay are one agent's inward
speaking and listening positions.

```text
suppressed(t).S_Smoke <= baseline(t).S_Smoke
suppressed(t).S_Clay  <= baseline(t).S_Clay
```

[Lean proof](ASSuppressionSolution.lean) · [Verification report](verification-report.json)
· [Verification logs](evidence-linux/) · [Credits](CREDITS.md)

**Still open:** the repeated-encounter process and its connection to the
continuous evolution. Comparisons of meaning, reception and understanding,
numerical error certification, and empirical validation are also separate tasks.

## Why the comparison holds

Let `x` and `y` be baseline minus suppressed for the Smoke and Clay S coordinates.
Set `u = wSmokeClay`, `v = wClaySmoke`, and `d = decay`. The common starting data
give `x(a) = y(a) = 0`. The accumulated-experience coordinate A is identical in
the two solutions, so its source contribution cancels from the differences.

The integral barrier proves that the suppressed trajectory's two
adverse-history loads remain nonnegative. The parameter bounds then
make both suppression coefficients nonnegative. Consequently the terms

```text
f(t) = u * chiReverse(t) * max(S_Clay(t)  - S_Smoke(t), 0)
g(t) = v * chiForward(t) * max(S_Smoke(t) - S_Clay(t),  0)
```

are nonnegative. Here the S values and chi coefficients are from the suppressed
solution. Subtracting the integral equations yields the following
equations, written in differential shorthand:

```text
x' = u*(y-x) - d*x + f
y' = v*(x-y) - d*y + g
```

The weighted sum `T = v*x + u*y` cancels the exchange terms:

```text
T' = v*f + u*g - d*T
```

Its initial value is zero and its forcing is nonnegative. The scalar integral
barrier therefore gives `T >= 0`. Each coordinate can then be rewritten as

```text
x' = (T+f) - (u+v+d)*x
y' = (T+g) - (u+v+d)*y
```

The same barrier gives `x >= 0` and `y >= 0`. All three steps are proved for
integral solutions; no differentiability at switching instants is assumed.
There is no division by an exchange weight and no change to the model.

## Verification

The saved local run passed Comparator, Lean's kernel, nanoda, the axiom audit,
and a Lake build. Its [detailed receipt](evidence-linux/historical-report.json)
and logs are retained alongside the repository-format report. The proof uses
`propext`, `Classical.choice`, and `Quot.sound`.

The theorem is `SocialAS.Verified.full_suppression_comparison`. Its statement is
`SocialAS.Open.FullSuppressionComparison`, the comparison proposed in the A/S
package. The model, theorem statement, equation register, and all 13 inherited
Lean files match the checked source files. The reference challenge is separate
from the solution.

Run `lake build` with the pinned dependencies. The repository's Lean verification
workflow runs the protected comparison, both kernels, the build and axiom audit.
The local replay scripts accept configured toolchain/cache locations;
`run-linux-check.sh NEW_DIRECTORY` requires a new verification directory.
[Publication provenance](publication.json) records the portable scripts and
the normalization of machine-path metadata.

This result concerns A/S's two S coordinates. It does not settle the separate
Hug v3 proof obligations.
