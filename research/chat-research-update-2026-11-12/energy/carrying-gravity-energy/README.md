# Carrying, gravity and the separated work accounts

The work has made two distinct advances: the later solver demonstrably couples material history back into flow, and its saved work accounts separate breathing, physical record writing and A/S coupling. Neither result by itself identifies a gravitational energy whose decrease pays for the original A/S work. The new Lean results below establish a concrete carried-configuration example without changing the original equations, and locate the remaining restriction.

## What was checked now

This task freshly evaluated the unchanged native solver on saved frame 0 and frame 600 (time 1.2, tick 41, **after** the third write). It did not rerun the trajectory. The case is the later 16³, threshold-1, smooth-response, breathing-on experiment; it is not a simulation of just the original A/S equations. Source seals passed. All inspected source and frame hashes were unchanged before and after evaluation.

| Cumulative quantity since frame 0 | Recomputed value | Share of energy change |
|---|---:|---:|
| Change in kinetic + stored + heat energy | 1.721130389149843e-4 | 100% |
| Breathing work | 1.058562294280592e-4 | 61.5039% |
| Event-write work | 4.183134871165950e-5 | 24.3046% |
| A/S coupling work | 2.442432168805689e-5 | 14.1909% |
| Accounting residual | 1.139087208725746e-9 | 0.0006618% |

The residual is **6.61825 parts per million of the energy change**. These are dimensionless model quantities. This is a checkpoint accounting test, not a proof of physical conservation or a full error/convergence bound. The separate work entries measure channels along this one coupled trajectory; they are not the energy changes that would result from independently removing each channel.

The native `continuum.py` computes `source_work = mean(u · force)` and uses it as the derivative of `ledger[1]`. A fresh diagnostic changed only `ledger[1]` by +1 in a copied checkpoint: **every returned rate array was identical**, with maximum difference 0. This verifies that the receipt is passive in the evaluated RHS. It does not prove that no function of a larger state/history could reconstruct the receipt.

Let C denote the solver's positive coupling-work receipt. Our earlier compensating account has the opposite sign:

\[
C(t)=\int_0^t P_{AS}(s)\,ds,\qquad R(t)=R_0-C(t).
\]

Thus the code already records the information needed for R, but its +2.442432e-5 receipt means a **decrease** of 2.442432e-5 in R. The signed bookkeeping balance is

\[
E(t)-W_{breath}(t)-W_{write}(t)-C(t)\approx E(0).
\]

Calling that receipt the “mentor” is an interpretation proposed in the quoted explanation. This check establishes a diagnostic account, not a physical reservoir or a formal identification with the user's mentor concept.

## What the earlier two-way test already established

The preserved [coupled-influence report](sources/Report.md) records a matched write/withhold experiment: the write leaves velocity unchanged at that instant but changes stress, heat, acceleration and actor rates, followed by different later states. Its local time-step checks support that effect on its fixed grid. Those are historical results read in this task; the paired trajectories were not rerun here. They support the user's continuing shared evolution and must not be discarded when discussing energy closure.

The notes also preserve the distinction between a fixed carrying relationship and a changing configuration. The [meaning correction](sources/hug-navier-single-system-scope-correction.md) explicitly retains one intended continuum, an unforced underlying target, and gravity's conceptual role. We have not replaced those meanings with the driven experimental branch.

Two claims in the quoted explanation need narrower wording:

- Small instantaneous stored energy does not rule out substantial energy passing through storage and becoming heat. The recomputed stored energy is 2.156411e-6, but the decisive issue is the complete rate balance, not this size comparison.
- Drift kinetic energy is 2.203971e-6, about 9.02% of cumulative coupling work. That numerical ratio alone is not a causal allocation of the coupling's work. Mean-flow and fluctuating-flow power can be separated explicitly, as below.

## The gravity test in the saved periodic run

At tick 41, using the source's actual activation and native Fourier projection:

| Instantaneous quantity | Value |
|---|---:|
| Mean coupling force, x component | -1.985862370372231e-3 |
| Total coupling power | 3.504362981373114e-5 |
| Mean-force × mean-velocity power | 4.169337546616381e-6 |
| Fluctuating-force × fluctuating-velocity power | 3.087429226711476e-5 |
| RMS of nonconstant projected force | 8.322260418113459e-3 |
| Power of the removed gradient component | 8.470329472543003e-22 |

The two power components sum to total power; these are **rates at the checkpoint**, not cumulative work shares. The pressure projection removes periodic gradient forces while retaining the mean and divergence-free part. Both a nonzero mean and a nonconstant projected part occur here. Consequently, the whole measured coupling cannot be represented by a single-valued periodic scalar gravitational potential. A uniform-height interpretation addresses only a uniform force; it does not explain the nonconstant projected component. This is a numerical finding about this branch, not a universal impossibility claim about the user's intended gravity or configuration history.

For a conservative force, the relevant requirement is force equal to the negative potential gradient; closed-loop work must vanish. [OpenStax, conservative forces and potential energy](https://openstax.org/books/university-physics-volume-1/pages/8-2-conservative-and-non-conservative-forces).

The older [holding proposal](sources/HOLDING_AND_ENERGY.md) explicitly labels its potential as **ADDED**. Its own energy equation still contains A/S power after accounting for that added holding force. Its historical classifications do not override the user's later meaning correction. Adding a separate gravity force would not show that the existing coupling is already its exchange term.

## What the new Lean proof establishes

[CarryingGravity.lean](CarryingGravity.lean) contains 12 new checked theorems, with an axiom audit in [verification.json](verification.json). The imported original equations and prior proofs retain their bytes.

1. The positive work receipt and the compensating reservoir change have opposite signs. Three separately specified work rates give a constant signed account between event jumps. The continuous theorem does not formalize the solver's discrete write events.
2. Along a carried coordinate X with X′ = v, a static potential satisfying b = −ρΦ′ gives (ρΦ(X))′ = −bv. If the existing energy rate is bv, their sum has zero derivative. **The force–potential match is a hypothesis**, not silently supplied by naming the force gravity.
3. A proposed height energy σa(t)X(t) leaves σa′(t)X(t) when activation changes. The extra term cannot be dropped.
4. The previous exact solution of the original A/S equations has u = −(t+1)eₓ, S = y and A = 0. Its material trajectory is

\[
X_x(t)=x_0-t-\tfrac12t^2,\qquad X_y(t)=y_0.
\]

Lean proves that this position follows the original velocity and that

\[
\frac{(t+1)^2}{2}+X_x(t)=\frac12+x_0.
\]

Here the unit-force potential is the unwrapped coordinate Xₓ. This supplies an exact configuration-energy connection for that example without altering momentum, A or S. It also explains the scope of the earlier counterexample: that result excluded energy depending only on current A and S, not an energy depending on carried displacement.

5. A differentiable potential with constant nonzero slope cannot be periodic with period one. Therefore the example's height energy does not descend to the wrapped coordinate. Keeping an unwrapped path retains more information than a periodic position. This is not a theorem ruling out every energy functional of a larger state or history.

## Remaining connection and reproduction

For the general original equations, what remains is an independently defined configuration/history energy with a derived rate **−P_AS**, including its domain, boundary and reference conventions. The continuing carrying relationship is already part of the intended meaning; the unresolved step is its quantitative energy law and force correspondence. A definition R = R₀ − accumulated work closes an account but does not alone establish that law. No self-gravity field equation, finite reservoir, or full continuum conservation theorem is established here.

`check_saved_frames.py` repeats the read-only measurements using the original local inputs identified and hashed in `saved-frame-check.json`. It needs NumPy and SciPy; this check used NumPy 2.3.5 and a compatible local SciPy 1.16.3. The source archive's historical continuation report used a different SciPy version. No simulation data were regenerated.

`build-native.ps1` rebuilds the Lean modules given the recorded Lean 4.34.0-rc2 toolchain and matching Mathlib cache. New modules were freshly compiled; unchanged imported modules use prior successful receipts with source/object hashes rechecked. No independent external kernel or fresh dependency download was run. `logs/`, `source-manifest.json` and `SHA256SUMS.json` retain the verification evidence.
