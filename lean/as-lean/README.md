# A/S Lean proof package — current Monoxide buildup equations

**Result: 30 local claims verified; the complete coupled model is not yet proved.**

The Windows build, Linux Lake build, Comparator statement/definition comparison,
permitted-axiom check, Lean kernel replay, and independent nanoda check passed on
29 October 2026. These are fresh checks of this A/S package. The Navier–Stokes
proof was not rerun or used as evidence for the A/S claims.

The subject remains one agent and one moving idea: **“Giving someone space to
speak can change what I understand.”** Smoke and Clay are the agent's inward
speaking and listening positions. Monoxide is the corpus's adverse interaction
mechanism. This is a model of social fluidity.

## What was preserved

`source-equations.json` is a byte-for-byte copy of the current E1–E16 register;
`source-protocol.json` preserves its interpretation, assumptions, and numerical
scenarios. All 79 files in the preceding equation audit remain unchanged.

`ASModel.lean` transcribes the right-hand sides without changing them to pass a
proof. Its seven continuous coordinates are A, S_Smoke, S_Clay, forward and
reverse L, and z_Smoke and z_Clay. A and S remain signed. The two-component H and
M belong to the same idea's encounter update; they are not additional agents.

The reference definitions and 30 theorem statements were frozen before proof
implementation. A recorded declaration-syntax repair occurred before that
implementation; both the initial freeze and the amendment record are retained.
The final proof statements match the frozen challenge statements exactly.

Comparator checks the Lean transcription against the protected Lean reference.
It does not independently translate prose or LaTeX into Lean. Formula-to-code
correspondence was reviewed against E1–E16; the two-position expansion of E3
into E4/E5 is additionally proved. Independent review of the transcription
and social interpretation remains useful.

## What is proved

Each named target is in namespace `SocialAS.Verified`. The exact assumptions
and conclusions are visible in `ASChallenge.lean`; complete proofs are in
`ASProofs.lean`.

| Equation / mechanism | Verified consequence | Limit of that result |
| --- | --- | --- |
| E1–E2: accumulated experience and its source | The linear A formula solves E1 under constant input; E2 is represented exactly. | No general coupled existence theorem. |
| E3–E5: Smoke–Clay influence | The two-position and expanded equations agree. The exact total-influence balance is proved. Suppression cannot increase an exchange term at the same state, and leaves a nonpositive gap unchanged. Exchange is monotone in the gap when its gain is in [0,1]. | A pointwise exchange comparison is not yet a comparison between whole trajectories. |
| E6–E8: activation, opening, reception | Activation is nonnegative. Opening lies between 0 and g. Registration lies between 0 and eta under the stated domain bounds. No opening gives zero registration; z=v=1 gives zero; v=0 leaves eta unchanged. | Bounds on z at every future time still need proof. These are conditional model consequences, not observations about a person. |
| E7–E8: one encounter's branches | The three feasible branch weights are nonnegative and sum to one when p,q are in [0,1]. | A complete repeated-encounter probability process is not constructed. |
| E9–E10: changed understanding | No contribution leaves H unchanged. Identical content leaves H unchanged. A received contribution gives the specified convex update and preserves the two-component probability simplex for beta in [0,1]. | No claim that every encounter improves understanding. |
| E11, E13: buildup effects | L/(L+L*) is in [0,1) for L≥0 and L*>0; gains in [0,1] keep suppression/distortion in [0,1]. | This is conditional on admissible L; full-time preservation of L≥0 remains open. |
| E12: adverse history | At L=0 the drift cannot point negative under nonnegative exposure/gain. Constant exposure with zero clearing has the stated linear solution; pure clearing has the stated exponential solution. Both formulas preserve nonnegativity under their hypotheses. | Arbitrary switched exposure/clearing and their coupling are not covered by these segment formulas alone. |
| E14–E16: changed meaning | Reception is a convex blend in [0,1]; interaction rate lies in [0,w]. The meaning drift points inward at 0 and 1 under the supplied bounds. | Boundary signs alone do not prove an invariant interval for all solutions. |
| E14–E15: after clearing | With distortion zero, matching source/recipient meanings, and no clarification, the meaning drift is zero. | Clearing L does not itself guarantee restoration of the original meaning. |

An exact implication worth retaining: exchange is not automatically conservative.
The proved total-influence identity includes the asymmetry of the two weights
and subtracts the two adverse positive-gap terms. Calling this pure
redistribution would overstate what the current equation says.

## What still needs proof

`ASOpenClaims.lean` states three precise outstanding propositions. They are
definitions of proof obligations, **not established theorems, assumptions
imported by the proofs, or Comparator successes**:

1. **FullExistenceUniqueness:** on each finite interval, admissible initial
   states and inputs produce a unique solution of the complete seven-coordinate
   system. The next proof needs regularity and growth estimates, continuation,
   and treatment of the switching inputs and rational denominators.
2. **FullStateInvariance:** along every such solution, both adverse-history
   loads remain nonnegative and both meaning coordinates stay in [0,1]. The
   boundary lemmas are ingredients; they still need an invariant-region or
   comparison argument for integral solutions.
3. **FullSuppressionComparison:** under matched initial states and inputs,
   the suppressed S coordinates never exceed those of the system with
   chi_max=0. This target concerns the S subsystem. A comparison covering
   distortion, reception, or understanding requires further statements and
   proofs; monotonic improvement of understanding is not presumed.

Additional connections remain outside those three targets:

- Construct the repeated-encounter process, specify the event sequence and how
  H_after becomes the next H_before, and connect its random events to the
  continuous state. The current package proves one encounter's algebra.
- Prove any numerical error guarantee for the earlier simulations. Their
  recorded 143 passing checks are historical numerical evidence, not Lean
  proof terms, and were not rerun in this proof-building step.
- Establish how observations determine U, adverse attribution h, exposure E,
  L, z, challenge v, and received content M. Unknown attribution is not encoded
  as h=false. Disagreement or refusal alone does not establish adversity.
- Test whether those measurements and relationships explain actual social
  understanding. Kernel verification does not establish empirical validity.

## Explicit mathematical conventions

The constants' domains are recorded in `ParametersOK`; input domains in
`InputsOK`; initial/load/meaning domains in `StateOK`. In particular, scales
are positive, exposure and clearing/clarification rates are nonnegative, and
probability/convex-blend quantities have unit-interval bounds. Local theorems
state the hypotheses they actually need. These are declared assumptions, not
facts deduced about the corpus or any individual.

The ODE uses an integral solution definition. This permits the existing abrupt
input switches while retaining the same right-hand sides. Requiring an ordinary
derivative at every switching instant would exclude the existing numerical
fixture. No existence or differentiability theorem is smuggled into this
definition. `RegularInputs` explicitly requires bounded inputs continuous away
from a finite set; it is an assumption of the open evolution targets.

Parameters such as imposed/reference meaning are fixed over an evolution
interval, as in the current candidate. Encounter functions accept their own
g, eta and beta values; a repeated-event law is not supplied. `Meaning` has two
coordinates, following the present one-idea examples. Claims about arbitrary
meaning spaces are not included.

## Verification evidence and reproduction

| Check | Result / evidence |
| --- | --- |
| Pinned Lean | 4.34.0-rc2, compiler commit 6a10ac8c22beadecabdbb0919c2b50214762f91d |
| Pinned mathlib | 85e3a25e006c35636f0e53b0e9296caca2685bc0 |
| Pinned Comparator | 19e111e2141cf333c7daff0f64c5f24acc91dd2e |
| Native build and 30 axiom reports | PASS; `native-build.log`, `native-build.exit`, `native-audit.json` |
| Fresh Linux environment and 11 dependency revisions | PASS; `evidence-linux/preflight.json` |
| Comparator / Lean replay / nanoda | PASS, exit 0; `evidence-linux/comparator.log` |
| Linux Lake build | PASS, exit 0; `evidence-linux/lake-build.log` |
| Source and dependency preservation | PASS; `reference-freeze.json`, `evidence-linux/postflight.json`, `verification-report.json` |

Only `propext`, `Quot.sound`, and `Classical.choice` are permitted. There are no
`sorry` proofs or new axioms in the solution. Intentional `sorry` placeholders
occur only in the separate challenge, as required by the checking arrangement;
the solution does not import that challenge. The open targets contain no proof
placeholders and are not counted as verified claims.

Comparator ran as the nonprivileged `nsverify` user, with real Landrun isolation
and systemd's AF_UNIX restriction, with nanoda enabled. The verification copy
had no previously compiled A/S solution. Existing pinned dependency caches and
checking tools were reused. The Linux build ran after Comparator so it did not
precompile the solution before the protected comparison.

For an ordinary build in an environment with the pinned dependencies, run
`lake build`. `build-native.ps1` uses this workspace's existing Windows tools.
`run-linux-check.sh` documents and reproduces this machine's full check using
the already installed Linux tools; give it a new, nonexistent destination path.
It intentionally refuses to overwrite a previous verification run. The
`verification-inputs.json` hashes identify the checked source exactly.

The independent checker accepts the selected statements under their explicit
assumptions. It does not establish that the entire A/S theory is finalized.
