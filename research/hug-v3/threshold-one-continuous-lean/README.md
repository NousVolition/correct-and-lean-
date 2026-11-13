# Threshold-1 continuous frozen-field proof development

**PARTIAL. The requested continuous traces and 36 window minima are not certified.**
This package contains global bounds on the six archived Fourier fields, general
enclosure lemmas, and candidate-segment trigonometric and Fourier evaluation
certificates. The expanded revision requires its own passing build and axiom
receipt; the retained 29-theorem receipt below covers the earlier revision only.
A successful build of
this package must not be described as successful certification of the traces.
`verify.py --require-trajectories` deliberately refuses that claim with exit 2.

The scope remains the left and right frozen snapshots around each of the three
late threshold-1 exchanges documented in [PR #14](https://github.com/NousVolition/hug-sims-lean-proofs/pull/14).
There are six signed traces, equivalently twelve directional traces, and six
windows per snapshot: `[0, .75]`, `[0, 1.5]`, `[0, 3]`, `[-.75, .75]`,
`[-1.5, 1.5]`, `[-3, 3]`. None of these full traces or minima has a closed
certificate in this package.

## What Lean establishes

The [147 submitted named declarations](targets.json) have distinct roles:

| File | Established result | What it does not establish |
| --- | --- | --- |
| [FrozenArchive.lean](FrozenArchive.lean) and [FrozenField.lean](FrozenField.lean) | For all real spatial points, each of the 18 scalar components of the six archived **unnormalized** Fourier fields has absolute value at most 1. Each component changes by at most `32 * ‖x-y‖∞`. Integer coefficient sums discharge these particular global bounds in Lean. | A positive lower bound on the vorticity norm, a bound on the normalized field's derivative along a trace, or a trajectory enclosure. |
| [FrozenPolynomial.lean](FrozenPolynomial.lean) | Real-valued error bounds for rational polynomial models under addition, negation, multiplication, coefficient replacement and truncation on `|u| ≤ 1`. | Trigonometric composition or an instantiated archived-field residual. |
| [FrozenTrig.lean](FrozenTrig.lean), [FrozenTrigModel.lean](FrozenTrigModel.lean), and [PhasePilot.lean](PhasePilot.lean) | A complex-rotation argument bounds sine/cosine errors by polynomial residuals. The starting error is checked from the exact values at zero. The pilot concerns a polynomial candidate on the first `[0, .001]` segment of the first left snapshot, using true real π. | That the candidate is an exact ODE solution, or that a tube contains an exact solution. |
| [FrozenIntPolynomial.lean](FrozenIntPolynomial.lean), [FrozenIntModel.lean](FrozenIntModel.lean), [FrozenIntTrig.lean](FrozenIntTrig.lean), and [FrozenIntTrigModel.lean](FrozenIntTrigModel.lean) | Shared-denominator integer arithmetic with real-valued soundness proofs, including computed errors from coefficient rounding and truncation. | Permission to accept the generator's floating-point or Arb error estimates. |
| [FrozenComplexModel.lean](FrozenComplexModel.lean), [FrozenFourierModel.lean](FrozenFourierModel.lean), [FieldPilotCore.lean](FieldPilotCore.lean), and [FieldPilotArchiveLink.lean](FieldPilotArchiveLink.lean) | The submitted pilot bounds one archived scalar Fourier component along that candidate polynomial to `10^-18` on every `|u| ≤ 1`. All 1,331 modes remain present. A separate equality check links the grouped coefficient tree to the archive. This claim requires the expanded revision's build and axiom audit to pass. | A normalized-field ODE residual, a complete trace, or a window minimum. |
| [FrozenNormalization.lean](FrozenNormalization.lean) | A normalized-component error bound from proved positive denominator bounds and proved square/component residuals. | Those required bounds for any of the six traces. |
| [FrozenODE.lean](FrozenODE.lean) | An exact solution exists and remains in a candidate tube when the stated continuity, Lipschitz, residual, initial-error and step-size inequalities hold. A separate theorem encloses an attained continuous-window minimum from a universal lower bound and an upper witness. | A solution obtained merely by assuming that a saved numerical path satisfies the ODE. No archived case currently discharges all these hypotheses. |
| [FrozenClippedODE.lean](FrozenClippedODE.lean) and [FrozenPrecondition.lean](FrozenPrecondition.lean) | Existence for an auxiliary field with a positive normalization cutoff, and a tube theorem using approximate inverse matrices and a boundary derivative inequality. Right derivatives allow continuous piecewise polynomial candidates. | Agreement of the auxiliary solution with the requested normalized field; this still needs nonvanishing vorticity throughout the tube. Every concrete matrix and boundary bound remains to be supplied. |

The ODE existence theorem retains the closed-ball conclusion from Mathlib's
Picard–Lindelöf construction. It does **not** assume the existence of a solution
which stays inside the desired tube. Its hypotheses are visible in the theorem
statement. The minimum theorem requires a lower bound at **every** point of the
window, not just at saved optimizer candidates.

The source is pinned to Lean `4.34.0-rc2` and Mathlib
`85e3a25e006c35636f0e53b0e9296caca2685bc0`. Axiom reports allow only the standard
`propext`, `Classical.choice`, and `Quot.sound` dependencies; no `sorryAx`, custom
axiom, or `Lean.ofReduceBool` is accepted. The three finite archive checks use
ordinary kernel-checked `decide`. Comparator and nanoda are not part of this check.

The independent [Linux run 43364713158](https://github.com/NousVolition/hug-sims-lean-proofs/actions/runs/43364713158)
passed the earlier Lake build, all 29 earlier axiom reports, input regeneration, five verifier
tests and the expected refusal of full trajectory certification. Its original
[receipt](evidence-linux/receipt.json), [compiler and axiom logs](evidence-linux/evidence),
and [artifact provenance](evidence-linux/source.json) are retained byte for byte,
including the original ZIP. That receipt belongs to proof head
`3d35b2b844ef6ea82c3a99a1b3fde37caa376cd4` and tested merge
`a70a0d320df2d0ce23d3543526e6ffe8a7a6dad6`. It explicitly records
`requested_trajectory_certificate: NOT_CERTIFIED`.

That historical receipt does not verify the added declarations in this revision.
The current proof sources, target inventory, and compiler logs must be checked
together; a new receipt is accepted only after every submitted module and all
147 axiom reports pass. The local development builds checked the trigonometric
pilot and generic lemmas, but the full Fourier-component calculation reached a
four-minute local limit. An import-only diagnostic took 193.656 seconds. The
expanded Linux build is therefore the pending check for the component pilot.

## Archived-field assumptions

[archive-inputs.json](archive-inputs.json) records the two source-file SHA-256
hashes, the exact six labels and indices, A/B coordinates in binary hexadecimal,
and the generated Lean-file hash. [generate_archive.py](generate_archive.py)
transcribes each complex coefficient into two integers over the common
denominator `2^80`; this preserves every binary coefficient exactly. All 1,331
modes per scalar component are retained, including zero and tiny coefficients.
No exact Hermitian symmetry is assumed.

For a coefficient `cₖ = aₖ + i bₖ`, the scalar field is defined as

```text
ωⱼ(x) = Σₖ [aₖⱼ cos(2π k·(x + (1/2,1/2,1/2)))
            - bₖⱼ sin(2π k·(x + (1/2,1/2,1/2)))]
k ∈ {-5, …, 5}³.
```

Here π is the mathematical real constant. The intended trace equation is
`x′(s) = ω(x(s)) / ‖ω(x(s))‖₂`, with `x(0) = A`; negative arclength follows
the same frozen field backwards. B is the fixed archived comparison target.
The global bounds currently proved use the infinity norm on coordinates. The
Euclidean normalization and the periodic Euclidean distance to B still require
their own application proofs.

The archive is supplied mathematical input. Python/NumPy loading, SHA-256 hashing,
and transcription regeneration are external provenance checks, not Lean proofs
that the archive came from the simulator. Nothing here proves its time evolution,
its relation to a continuum Navier–Stokes solution, grid or full-history
convergence, or an exchange between the two times of a saved bracket. The
historical run's breathing setting remains an intervention in that implementation;
it does not redefine the user's intended single unforced HugandNavier system.

## Numerical diagnostics, explicitly outside the proofs

[conditioning.py](diagnostics/conditioning.py) evolves a floating-point trace and
its variational matrix on all twelve directions. Its [saved output](diagnostics/conditioning.json)
is a numerical conditioning diagnostic, not an interval certificate. For the
first left snapshot at arclength 3 it estimates the integral of the Jacobian
operator norm as about 79.94, while the largest singular value of the variational
matrix is about 234.96. These observations motivate using better coordinates or
higher precision instead of treating solver-tolerance agreement as a proof.

An additional external Arb prototype was explored during development. It was not
accepted as a certificate, and no Arb output supplies a Lean hypothesis here.
The user's requirement is that **every bound used in the trajectory and minimum
certificates must be verified inside Lean**. Only the mathematical results in
the table above currently meet that requirement.

The existing [window study](../threshold-one-window-study/README.md) remains
measured evidence. The separate [23 saved-number checks](../threshold-one-window-lean/README.md)
remain proofs about finite recorded inputs. The threshold-0.015 energy proofs
are a third, distinct result; they cover none of these threshold-1 trajectories.

## Remaining certificate obligations

1. Prove correlation-preserving sine/cosine enclosures, their remainders, and
   the necessary normalized-field bounds inside Lean for every required slab.
   The new generic trigonometric proofs and single-segment pilot do not provide
   the required full coverage.
2. Prove a strictly positive vorticity lower bound over each entire tube.
3. Discharge the ODE existence/error inequalities, exact seed condition, joins,
   and uniqueness along the complete `[-3,3]` trace for all six archives. A
   sampled slab or a field-wide upper bound cannot replace this coverage.
4. Bound the periodic distance on every point of all 36 windows; provide
   upper witnesses and prove the resulting numerical minimum intervals and
   window comparisons. Any exact location or uniqueness claim needs additional
   isolation. A minimum may instead be enclosed with several possible locations.

No theorem proving these obligations is hidden behind an assumed error radius.
Their absence is recorded in [certificate-status.json](certificate-status.json)
and in every verification receipt. The current result is not a proof that this
certification is impossible; a complete numerical certificate and its checked
application remain to be constructed.

## Reproduce

From this directory, with the pinned Lean available:

```sh
python -m pip install numpy==2.5.4
lake exe cache get
python -B -m unittest test_verification.py
python -B verify.py --output /tmp/frozen-evidence
```

Use a fresh checkout for that Lake build and a new output directory. The verifier
regenerates the archived coefficient inputs byte for byte, builds all project
modules, checks all 147 axiom reports, and writes source and log hashes. Offline
verification is also supported with `--lean PATH_TO_LEAN --packages PATH_TO_PACKAGES`;
it compiles the project afresh using compiled dependencies at the pinned Mathlib
revision. That mode reports a direct Lean build, not a Lake build.

This acceptance command is expected to exit **2**, even after a successful build:

```sh
python -B verify.py --output /tmp/unused --require-trajectories
```

Reproduce the separate floating-point diagnostic with:

```sh
python -m pip install -r diagnostics/requirements.txt
python -B diagnostics/conditioning.py --output /tmp/conditioning.json
```

To propose the candidate-segment polynomial inputs again:

```sh
python -m pip install -r candidate-requirements.txt
python -B generate_phase_pilot.py --output /tmp/frozen-candidates
python -B generate_field_pilot.py --output /tmp/frozen-candidates
python -B split_field_pilot.py --directory /tmp/frozen-candidates
```

SciPy and Arb propose coefficients; neither supplies an accepted error bound.
The saved `PhasePilot.json` and `FieldPilot.json` are generator records, not Lean
receipts. Floating-point proposal regeneration can vary across platforms. The
reproducible mathematical check is the kernel build of the saved coefficient
lists: the sine/cosine residuals, true-π input errors, arithmetic rounding,
Fourier coefficient identity, and final inequality are checked inside Lean.
The [local regeneration record](generator-evidence.json) records byte-for-byte
agreement for the five saved candidate files, the dependency versions, and the
source-archive hash. This is an external provenance check, separate from the
Lean build and axiom receipt.

Floating-point diagnostics may vary across platforms; their values are not used
to establish the Lean results. The input and proof checks above require exact
bytes. Local and GitHub receipts retain their own execution context and must not
be substituted for one another.
