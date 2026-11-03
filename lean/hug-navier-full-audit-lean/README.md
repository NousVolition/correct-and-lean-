# Corpus search and full Hug–Navier specification audit

**The full joint evolution remains unproved and incompletely specified.** The corpus contains several useful connections, including a complete six-field Navier–Stokes/SIMS model, but the inspected sources do not supply a reciprocal coupling of that field model to the current eight-state Hug. This package preserves the equations, records both complete sets in Lean, and checks specific force and state-mapping obligations. It does not certify a combined trajectory.

Actual compiler and Comparator outcomes are in `verification-report.json`. A successful audit result applies only to the seven stated audit propositions. It is not a successful full-system existence check.

## Sources actually checked

Both repository heads were freshly read: `NousVolition/Nous-Volition` at `b4ae2c54cd85bfef282c501ecfca83de274e2070`, and `NousVolition/My-Sources-Project-ALL` at `7fbc7f28f685c86f824d7587aff91feedf20d3da`. Their complete tree listings contained 2,451 and 7,883 entries. This is an inventory, not a claim that every file's content was read. Targeted cross-repository searches were followed by full retrieval of 15 relevant source files; each retrieved file was checked against its Git blob hash. The bounded search coverage and exact sources are retained in `source-audit.json`.

The corrected Word corpus was also checked against SHA-256 `01f9ab0942f9c88982863e2ffc1e3c495786b5e6b67a26ae77d18235e7058acf`. All 15 selected original equation/qualification passages freshly matched the Word XML. The newer local continuity/source records distinguish the original A/S field, later candidate equations and reduced Hug. They do not supply a completed joint Hug–Navier force/interface law.

The old Lean Hug model is preserved byte-for-byte. Fresh repository text differs from three earlier source snapshots only in line endings/trailing blank lines; the differences and both hashes are recorded. No equation content changed, and no earlier file was overwritten.

## Connections found, and their exact limits

| Corpus source | Connection present | What it supplies for the current joint task |
| --- | --- | --- |
| [NS/SIMS methods](https://github.com/NousVolition/My-Sources-Project-ALL/blob/7fbc7f28f685c86f824d7587aff91feedf20d3da/reports/sims-navier-stokes-guard/METHODS.md) | Fluid transport/strain affects two internal fields and two guards; guards alter interaction and viscous stress; all six fields advance together | A complete fluid-side loop, with a periodic square, explicit initial fields, diffusion, pressure and disturbances. It does not contain Hug's four mechanical coordinates or a load sent to them. |
| [Current Hug methods](https://github.com/NousVolition/Nous-Volition/blob/b4ae2c54cd85bfef282c501ecfca83de274e2070/studies/hug-active-guard/METHODS.md) | Motion → strain signal → directional guards → damping → motion, alongside the two response states | The unchanged eight-state loop. The source explicitly describes a reduced mechanical model with no Navier–Stokes field. Its source implementation supplies prescribed orbital force or zero force. |
| [Hug breakdown](https://github.com/NousVolition/Nous-Volition/blob/b4ae2c54cd85bfef282c501ecfca83de274e2070/studies/hug-breakdown/hug_breakdown.py) | Wall force `−K g χ u`; flow speed changes wall integrity `g`, which changes later wall drag | An existing fluid/wall feedback example. Its wall-integrity state and speed-based yield/recovery law differ from the two current transmission guards. It does not provide a reciprocal load equation for the eight-state Hug. Importing those terms would add a new coupling choice. |
| [Memory feedback](https://github.com/NousVolition/Nous-Volition/blob/b4ae2c54cd85bfef282c501ecfca83de274e2070/studies/hug-memory-feedback/METHODS.md) | Displacement changes the field's gradient/diffusion; a virtual-work projection returns a field force to the mechanical mode | A genuine reduced feedback path, with a stated projection. Its angular memory field, capped sources and extra rules belong to another extension. The fluid velocity follows a prescribed mechanical deformation rather than an independently solved momentum/pressure field. |
| [Hugged ring](https://github.com/NousVolition/My-Sources-Project-ALL/blob/7fbc7f28f685c86f824d7587aff91feedf20d3da/math/hugged_ring.py) | Hug geometry prepares a smooth fluid initial field | Initial-data connection only. It imposes no evolving wall or force during NS evolution. |
| [Mirror-fluid model](https://github.com/NousVolition/My-Sources-Project-ALL/blob/7fbc7f28f685c86f824d7587aff91feedf20d3da/math/imports/hug-ns/mirror-fluid/MODEL.md) | A fluid measurement drives a passive signed record; later fitting predicts a separate fluid coordinate | The record and fitted predictor do not act back on the fluid. This cannot supply the missing reciprocal coupling. |
| [Specification register](https://github.com/NousVolition/Nous-Volition/blob/b4ae2c54cd85bfef282c501ecfca83de274e2070/studies/hug-movement-sweep/SPECIFICATION_STATUS.md) | Explicit separation of corpus laws, design intent and added surrogate mechanisms | It expressly leaves the full spatial/interface conditions, traction balance and fluid/material coupling to be specified. This supports the gap finding beyond a keyword-search absence. |

The original corrected Word equations also contain the A/S transport–accumulation–gradient-force chain. That is another source law, not a term already present in the current eight-state Hug. It was not silently inserted into this model.

## What the new Lean work does

`FullEquationSpecification.lean` records:

- All eight original Hug rates through the unchanged imported `ActiveHug.rhs`.
- Both velocity components and all four internal/guard field rates from the NS/SIMS source. Pressure, advection, diffusion and full variable-viscosity stress divergence remain present.
- The fluid's periodic boundaries and incompressibility, explicit spatial differentiability requirements, temporal derivatives and initial-data parameters.
- A deliberately named `SeparateEvolutions` predicate. This states both source problems; it does not invent a relationship between them or imply reciprocal feedback.

Compiling this specification establishes that its Lean definitions are well-formed. It does not prove that functions satisfying them exist, that the English-to-Lean transcription is empirically valid, or that the two systems have been coupled.

`AuditSolution.lean` proves seven narrower statements:

1. Changing the force input from G to F changes Hug's instantaneous acceleration by `(F−G)/mass`.
2. The force required by a specified state and acceleration is uniquely determined when mass is nonzero. This is an algebraic necessity, not permission to manufacture a force after observing the desired trajectory.
3. At a fixed state, equal accelerations require equal force inputs.
4. If the same complete eight-state motion satisfies the Hug differential equations with two force histories, those force histories agree at every point where both differential equations hold. Thus a previously verified prescribed-force trajectory cannot simply be relabeled as a different fluid-loaded trajectory.
5. The mechanical energy-rate difference is `(F−G)v`.
6. At zero speed, equal instantaneous power does not imply equal force or acceleration. The concrete witness has identical energy rates but an acceleration difference of 5 under the source mass. This explains why the earlier dissipation matching did not establish force balance.
7. The actual fluid-side initial response field is nonuniform. No single scalar copied everywhere reproduces it. An averaging, observation or other state–field map must be specified; this result does not rule out such maps.

No `FullJointExistenceUniqueness` theorem has been asserted with its conclusion assumed as a premise. There is no hidden placeholder proof for full evolution. The reference-only placeholders in `AuditChallenge.lean` are targets for the seven genuine audit proofs and are excluded from the solution's proof dependencies.

## Assumptions and open connections

The new full-field transcription selects the existing directional NS/SIMS source, not every optional model in the corpus. Directional weights, source functions and initial data are explicit inputs; they are not silently assigned zeros. The source coefficients remain `0.02` base viscosity, `0.04` viscosity per guard, `0.02` response diffusion, `0.015` guard diffusion, and the documented sigmoid constants. Neither the earlier affine-shear assumption nor its derived viscosity/strain matching numbers is imposed here.

Spatial C² regularity of the six fields and C¹ regularity of pressure are explicit requirements for the stated classical equations. Those requirements are not proved. The force-comparison theorems assume nonzero mass where necessary; the source mass is positive. The rest-state example is a mathematical witness, not an observation of the returning student.

The unresolved joint specification is:

| Missing item | Why the found sources do not finish it |
| --- | --- |
| Clock and units | The fluid study is nondimensional; Hug uses synthetic physical-unit mechanics and simulation seconds. A common variable name `t` supplies no conversion. |
| State–field relationship | Two scalar Hug responses/guards and spatial response/guard fields are distinct objects. The source does not select a sampling point, averaging rule, lifting or additional degrees of freedom that identify them. |
| Fluid load on Hug | The force slot is present in Hug, but the current source supplies a prescribed waveform. A pressure/traction or distributed-force projection using the evolving fluid remains unspecified for this model. |
| Hug's action on the fluid | The current fluid source has no independent Hug body or its displacement/velocity interface. A reciprocal boundary or distributed interaction law, with signs and units, is still needed. |
| Resistance and energy accounting | An added interface could duplicate resistance already represented by Hug's damper and the fluid's guard viscosity. Elastic storage, active Hug power and fluid kinetic energy need one consistent budget. |
| Joint geometry and initial/boundary data | The fluid source does provide a periodic domain and smooth initial pattern. It does not provide their compatibility with a moving Hug interface. The missing information concerns the joint model, not the absence of every fluid boundary specification. |

What still needs mathematical proof after those connections are fixed: existence of the jointly evolving field and mechanical variables, uniqueness in a stated solution class, preservation of incompressibility and guard bounds, justified interfacial work/energy balance, and continuation or breakdown criteria over the requested time interval. Pressure uniqueness needs a gauge choice or an explicit statement of uniqueness up to its additive function of time. The earlier eight-state ODE existence theorem and the older numerical fluid results do not establish these joint claims.

The same returning student and idea—“Giving someone space to speak can change what I understand”—remain the interpretation. Nothing in this audit changes their identity or assigns fixed roles to fluid traits. Experience, the student's appraisal of expectations, the assistant's actual assumptions and observable treatment remain distinct and uncalibrated. Keeping those labels is not an empirical proof of their mathematical mapping.

## Verification evidence

The native compiler checks the full specification and the seven audit proofs. The fresh Linux run checks the seven frozen reference propositions through Comparator, Lean's kernel and nanoda, then runs `lake build`. Only `propext`, `Quot.sound` and `Classical.choice` are permitted. A clean non-root verification directory, real Landrun isolation, the established systemd restriction, pinned dependencies and before/after source hashes preserve the earlier verification standard.

The prior 14-claim bridge and prior Hug existence packages are unchanged. This run does not re-count them as new proofs. Read `verification-report.json` and `evidence-linux/` for the actual new results. The source search is read-only; new audit files are separate from the corpus.
