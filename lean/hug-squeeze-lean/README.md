# Hug and squeeze: Lean proof package

This package checks both Hug versions requested on 30 October 2026. It contains 51 fixed claims: 27 about the original pressure-responsive enclosure and reciprocal squeeze, 18 about the later active Hug with directional guards, and six about the separate memory-continuity extension. The original equations and the previously completed A/S proof packages are preserved.

The final verification outcome is in `verification-report.json`; raw results are in `native-final.log` and `evidence-linux/`. This README describes the exact scope of the claims, rather than certifying every statement in the corpus.

## Source versions

- Original Hug: `NousVolition/My-Sources-Project-ALL`, commit `7fbc7f28f685c86f824d7587aff91feedf20d3da`, `math/pressure_envelope.py`, `math/hug_envelope.py` and the accompanying notes.
- Later active Hug: `NousVolition/Nous-Volition`, commit `b4ae2c54cd85bfef282c501ecfca83de274e2070`, `studies/hug-active-guard/METHODS.md`, `model.py` and `protocol.json`.
- Separate memory extension and scope clarification: `studies/hug-memory-continuity/METHODS.md` and `studies/hug-movement-sweep/SPECIFICATION_STATUS.md` at the same later commit.
- The provisional interaction equation is included for provenance. Its general functions are not a fully specified evolution law by themselves.

Retrieved source snapshots are in `sources/`. The current source files explicitly describe prescribed geometry and reduced synthetic models. The later source also identifies added modeling assumptions. This package retains those distinctions.

## What is checked

| Component | Formal result | Conditions and limits |
| --- | --- | --- |
| Original pressure | Nonnegative pressure ratio; the opening threshold is exactly pressure difference at least the positive limit; ratio 2 is allowed | The limit is positive. One means the chosen opening threshold, not a maximum amount of pressure or knowledge |
| Imprint | The exponential update stays between the old imprint and applied pressure; nonnegativity survives any finite sequence of valid steps | Nonnegative step duration; positive response time. Pressure is held constant within each step |
| Imprint ODE | The displayed exponential update differentiates to `(p-m)/tau` | The time constant is fixed within the step; this does not verify floating-point execution |
| Values above one | Starting from zero, pressure 2 produces imprint 3/2 after `(4/5) log 4` | There is no imposed unit ceiling on pressure or imprint |
| Retention | A positive imprint remains positive after any finite nonnegative interval at zero pressure, while not increasing | Fading retention in this prototype; this is distinct from the later non-decaying accumulator |
| Squeeze | Positive reciprocal scales multiply to 1, the stretch is reversible, the arms mirror, and the timed horizontal scale lies between 1 and 1.08 | This proves geometry identities. It does not prove material incompressibility or contact strength |
| Closure | With positive horizontal scale, exact tip closure occurs exactly at bend 1 | A separate counterexample proves that the numerical `connected` flag can hold with a nonzero gap |
| Opening | Opening begins at ratio at least 1, remains latched, and bend is zero once opening age reaches 0.8 | Lowering pressure alone does not reclose it |
| Active guards | Sigmoid targets lie strictly between 0 and 1; drift points inward at both boundaries; every specified continuous integral solution with an initial guard in [0,1] stays there | Positive guard response time. Existence of the entire coupled trajectory is not assumed to have been proved by this result |
| Mechanical energy | Nonnegative stored energy, the exact chain-rule energy identity, and a derivative theorem along differentiable trajectories satisfying the mechanical rates | Positive mass, length, Maxwell modulus and viscosities; nonnegative volume, spring stiffness and Kelvin modulus. The formal `Physical` condition also includes positive scale and guard time and nonnegative damping |
| Loss and active drive | Material loss and guard loss are nonnegative; passive unforced energy rate is nonpositive | The guard loss result requires nonnegative guards and damping. The passive result sets both active coefficients and external force to zero |
| Active counterexample | At the unchanged primary protocol, a stated admissible state has positive energy rate `1/5000000000` | This is an instantaneous counterexample to universal energy decay, not a proof that a published initial trajectory visits that state |
| Directional versus shared guards | At unit participant weights, the participant-difference rate depends on the guard sum; the shared and directional sums have the same instantaneous rate | These algebraic identities do not alone prove uniqueness or equality of complete trajectories |
| Old limit and display | Zero guard damping recovers the old acceleration law; the affine display shear is reversible and preserves height | The display is magnified 150 times in the source; a drawing identity does not establish physical joins |
| Separate memory extension | The capped source is bounded by its nonnegative cap and changes sign with the accumulator; exchange is zero below the centreline and cancels between equally weighted mirrored partners; the exact-off response is zero below threshold; reversing the gradient sign leaves its force unchanged | These are selected properties of a separate extension. Its memory force has not been added to the guard damper model |

## Findings that restrict broader claims

1. A reported connection is not necessarily exact closure. The original `gap <= 10^-12` condition admits a strictly positive gap. The counterexample uses a valid bend between zero and one and horizontal scale one.
2. The active model need not lose energy overall. Its added damper dissipates energy, but its active source can supply more than the losses.
3. Reversing the sign of the memory gradient does not reverse the force generated through its absolute value. That law alone cannot encode a distinction between beneficial and adverse interpretation.
4. Pair cancellation requires the same coupling coefficient, height weight, amplitude and sign for both directed terms. Arbitrary asymmetric weights do not follow from that theorem.

These are proven properties or counterexamples of the unchanged formulas. They are not reasons to alter the equations merely to obtain a favorable result.

## What remains unproved or untested

- Global existence and uniqueness of the full later coupled Hug system; its long-time bounds, limit cycles, synchronization, attraction and recovery claims.
- The full memory field evolution, its continuum regularity, the claimed field-amplitude bound, spatial convergence and coupling to motion. The six memory checks above do not cover that entire system.
- The complete timed animation schedule, discrete sampling, Python floating-point behavior, solver tolerances, published trajectories, and parameter calibration. Source inspection is not execution verification.
- A resolved material model of squeezing, contact, pressure transmission, rupture or a moving interface. The source does not specify a complete Hug field problem with all domains and boundary/interface conditions.
- An operational connection from the abstract state variables to the user's social interpretation, lived experience or observed behavior. Mathematical consistency does not supply that measurement map.

The later source's cap, relaxation, exchange, synthetic Burgers mechanics, time mapping and guard-to-damper coupling remain declared modeling choices. No proof here upgrades them into empirical evidence or derives them uniquely from the earlier corpus.

## Proof and checking structure

`HugModel.lean` and `ActiveHugModel.lean` are exact-real transcriptions. Decimal coefficients are represented as exact rational numbers. `HugChallenge.lean` and `ActiveHugChallenge.lean` hold the fixed target statements; their intentional `sorry` placeholders are only Comparator reference declarations. The solution imports contain no proof placeholders or extra axioms.

`HugSolution.lean` proves the original 27 targets. `HugBarrier.lean` supplies a general scalar integral barrier argument, adapted from the existing generic A/S proof utility without modifying that package. `ActiveHugSolution.lean` proves the other 24 targets. `HugAllSolution.lean` prints the axiom dependencies for all 51.

Both model/target pairs were recorded in reference freezes before their proof implementation. One later syntax-only repair renamed the reserved Lean argument name `local` to `own`; the original hashes and reason are retained in `active-reference-freeze.json`. No formula, premise or conclusion changed. `verification-inputs.json` fixes the final inputs supplied to the isolated check.

The verification uses Lean 4.34.0-rc2, mathlib `85e3a25e006c35636f0e53b0e9296caca2685bc0`, and Comparator `19e111e2141cf333c7daff0f64c5f24acc91dd2e`. Comparator is configured to compare all 51 target statements, enforce the axiom allowlist `propext`, `Quot.sound`, `Classical.choice`, and invoke nanoda as well as Lean's kernel.

The Linux check starts in a new directory without compiled solution files, runs as the non-root verification user, and uses real Landrun with the pinned README's systemd restriction. It reuses the trusted dependency builds installed for the earlier audit, records their commits and tool hashes, and checks source preservation afterward. This records the actual checking boundary; it is not an independent audit of the operating system, dependency caches, or the source-to-Lean interpretation.

For a standalone checkout, install the pinned Lean toolchain and dependencies, then run `lake build`. The included `build-native.ps1` and `run-linux-check.sh` use this workstation's already installed tools and dependency locations; the latter requires an unused destination and the listed Linux isolation tools. Large dependency builds are excluded from the archive.
