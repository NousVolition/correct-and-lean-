# Hug and Navier–Stokes checked together

This package checks a conditional connection between the unchanged eight-state Hug model and the optional guard-dependent Navier–Stokes formulation in the saved corpus. It does not define or prove existence of a complete joint fluid–Hug system. Final verification results are recorded separately in `verification-report.json` and `evidence-linux/`.

The two formulations share a feedback pattern: motion and internal response affect the directional guards, and the guards affect subsequent interaction and resistance. The new proofs check when selected terms can represent that same loop, and demonstrate specific mismatches when the matching conditions do not hold.

## What is preserved

`HugModel.lean` and `ActiveHugModel.lean` are byte-identical copies from the existing Hug existence package. The current eight-state model comes from `NousVolition/Nous-Volition` commit `b4ae2c54cd85bfef282c501ecfca83de274e2070`. The four source snapshots are also preserved byte-for-byte. No Hug coefficient, force law, guard rule, source experiment or existing proof was edited.

The field side is the user's optional guard-stress formulation in `sources/interaction-equation.md`. This is not a recheck of the separate forced Navier–Stokes breakdown construction.

The 14 reference propositions were frozen before successful proof implementation. One import-only repair replaced a nonexistent pinned mathlib module with `Mathlib.Data.Matrix.Basic`; the original file and freeze are retained. No mathematical definition or theorem statement changed in that repair. Development compiler failures are retained and are not counted as successful verification.

## The exact connection being tested

The comparison makes additional assumptions: a physical affine shear profile with horizontal velocity `(v/L)y`; identification of the local response and guard values with the Hug state; matching local reaction coefficients; and, for the dissipation comparison, uniform strain and guards over the volume `V`. These are hypotheses of the comparison, not established features of a joint solution.

The local reaction comparison uses the Hug reactions with no additional state inputs (`s_A=s_B=0`). The broader corpus allows such inputs and more general reaction laws. With those present, the residual would also contain their differences. Transport is interpreted along a fluid path, rather than discarded from an equation at a fixed spatial position. Each diffusion contribution is retained as a separate `diffusivity × Laplacian` value; these values are not constructed from solved spatial fields.

**Strain scale.** Under this assumed shear profile, physical `D:D = (1/2)(v/L)^2`, while Hug uses `S = (1/2)(v/Q × t_ref)^2`. Their guard arguments agree when

```
chi_NS = chi_Hug (L t_ref / Q)^2.
```

For the unchanged Hug settings this condition gives `chi_NS = 500000 s²`. Reusing Hug's numerical `0.5` as the dimensional field coefficient gives different arguments at a concrete test state. The new package proves both statements. It does not install `500000` into any fluid experiment or claim that a saved fluid run already satisfies this condition.

**Spatial variation.** Once the local reaction arguments match, the difference between the material field update and the Hug update is exactly its diffusion contribution. The two response rates and two guard rates agree together if and only if their four diffusion contributions vanish at the point considered. Zero diffusivity or a zero Laplacian can satisfy that local condition; no global removal of diffusion is inferred. A unit nonzero diffusion contribution supplies a proved mismatch.

**Guard resistance.** With the assumed uniform-volume projection, the additional guard-viscosity dissipation is

```
V (a_AB g_AB + a_BA g_BA) (v/L)^2.
```

Hug's guard loss is `c(g_AB+g_BA)v²`. Equality for all states requires and is implied by

```
V a_AB = c L²,    V a_BA = c L².
```

The unchanged Hug settings therefore require `a_AB=a_BA=1000 Pa·s` under this projection. This is a matching obligation, not a measured viscosity or a new fitted setting. Equal dissipated power alone does not establish the full force law, pressure balance, base-viscosity contribution or reciprocal exchange of energy.

**Boundary obstruction.** Nonzero affine shear does not give equal horizontal velocities at `y=0` and a nonzero transverse period `H`. Consequently this assumed profile cannot simply be inserted globally into the corpus's existing two-dimensional periodic example. This rules out that particular identification, not every possible Hug–field connection.

The final theorem joins agreement of all four local rates with agreement of guard dissipation for the primary coefficients and zero diffusion contributions. It does not assert the existence of any trajectory, spatial field or momentum-equation solution.

## The 14 frozen checks

| Lean theorem (in `HugNavierBridge.Verified`) | Scope |
| --- | --- |
| `shear_derivative` | Derivative of the assumed affine velocity component |
| `shear_contraction` | Squared contraction of its declared shear matrix |
| `nonzero_shear_not_periodic` | Obstruction across a nonzero transverse period |
| `strain_matching` | Physical versus normalized strain coefficient conversion |
| `argument_matching` | Both directional guard arguments agree under that conversion |
| `guard_diffusion_residual` | Both guard-rate differences equal their diffusion terms |
| `four_rates_agree_iff` | Necessary and sufficient local diffusion condition for all four rates |
| `power_matching` | Sufficient coefficient conditions for guard-power agreement |
| `power_matching_necessary` | Those conditions are necessary for agreement at every state |
| `primary_required_coefficients` | Exact primary numerical matching conditions |
| `primary_power_matches` | Primary projected guard power equals Hug guard loss |
| `same_number_chi_is_not_same_argument` | Concrete failure of an unconverted strain coefficient |
| `nonzero_diffusion_blocks_local_match` | Concrete nonzero-diffusion obstruction |
| `simultaneous_conditional_bridge` | Joint agreement of the four rates and guard power under the declared specialization |

## What still prevents a full combined theorem

1. Specify how a spatial velocity and pressure field determine Hug's load, and how Hug's motion and stress act back on that field. The same resistance must not be counted twice.
2. Give a compatible domain, boundary conditions, initial fields and a rule relating the spatial fields to Hug's eight coordinates. The tested affine profile conflicts with the existing periodic example unless its shear is zero.
3. Account for the full stress and energy budget. The optional field guard stress is dissipative; Hug also contains elastic storage and an active source. Matching only guard dissipation does not transfer those components automatically.
4. Prove existence, uniqueness, regularity and the required guard bounds for that fully specified joint system. The previous Hug theorem handles a prescribed continuous force. It does not by itself prove a reciprocal coupling to an unknown fluid trajectory.

The same returning student and the same idea—“Giving someone space to speak can change what I understand”—remain the interpretation. No new person, idea, fixed Smoke/Clay role or measurement map is introduced. The student's experience, their appraisal of the teaching assistant's expectations, the assistant's actual beliefs and observed behavior remain distinct. These Lean results do not establish an empirical map from any of those quantities to the mathematical states.

## Verification and reproducibility

The configured checks are native Windows Lean, a fresh Linux Comparator run, nanoda and Lean kernel replay, followed by Linux `lake build`. Comparator checks all 14 exact reference propositions and permits only `propext`, `Quot.sound` and `Classical.choice`. The solution contains no `sorry`, `admit`, new axiom or unsafe declaration. The deliberate `sorry` bodies in `BridgeChallenge.lean` specify reference targets and are not imported by the proof solution.

Pinned versions: Lean `4.34.0-rc2`; mathlib `85e3a25e006c35636f0e53b0e9296caca2685bc0`; Comparator `19e111e2141cf333c7daff0f64c5f24acc91dd2e`. The Linux check runs as a non-root user with real Landrun isolation and the established systemd address-family restriction. It starts without precompiled project solutions, reuses trusted dependency builds, and records source hashes, clean pinned dependency revisions and tool binary hashes before and after checking.

For a fresh checkout with the pinned dependencies, `lake build` checks the solution. `run-linux-check.sh` uses this workstation's installed verification paths and a fresh target directory. `build-native.ps1` is an unsuccessful early launcher retained for development history; it is not the source of a pass result. The successful native run used the saved Python launcher, with its compiler output retained in `native-development-5.log`.

Read `verification-report.json` for actual completion status. Passing these compatibility propositions is not a proof of a full unified Hug–Navier–Stokes evolution.
