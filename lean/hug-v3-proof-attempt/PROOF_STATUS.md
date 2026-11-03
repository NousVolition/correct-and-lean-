# Full Hug v3 existence and uniqueness remains unproved

The user selected the later `hug-structural-memory-v3` model. This attempt preserves that selection, its complete source package, the returning student, and the idea “Giving someone space to speak can change what I understand.” It does **not** prove existence and uniqueness for the full model. The Lean and Comparator results below concern six necessary facts about its memory-writing events, not the coupled evolution theorem requested.

## Exact selected source

Source directory: `C:/Users/ziman/Documents/Codex/2026-10-08/referenced-chatgpt-conversation-this-is-an-2/outputs/hug-structural-memory-v3`.

All 21 entries in the original source seal were checked and matched. Their files are copied unchanged into `sources/`. The source's original `main` declaration gate also accepted the copied inputs. Its declaration SHA256 is `f9726113dc6ef6d8f6598dafe3bdb145dabb226a0197c63f72dc4f3624b93514`. The gate says `claims_corpus_validation: false`; accepting a declaration is not a mathematical or empirical validation.

The six synthetic actors and two context coordinates are choices already present in this version's source. They do not restrict the author's broader concept to two meaning states. No actor has been newly assigned to the returning student or given invented measurements. The person and idea remain interpretation metadata, rather than an established numerical mapping.

The main source fixture contains 193,122 continuous numerical coordinates in its state dictionary: the three-dimensional velocity/context/temperature grid; material positions and deformation gradients; directional records and structural rest-strain cells; A and accounting quantities; and expression, context, norms, permission radii, relationships, response strengths and retrieval associations. This count excludes the event scheduler's temporary captured deformation arrays, immutable input data and output history. A complete hybrid formalization must include the scheduler's relevant state as well.

## What the full transfer includes

`continuum.py:186` computes all field and material rates together. The important connected paths are retained in the source snapshot:

- The current state and decoded history determine social responses, utility and source allocation. The source is `A' = gamma * utility`, followed by `J = kappa * A` and normalized allocation into transported context C.
- Context gradients activate the selected smooth response with its calibrated gradient excess. The force, variable viscous stress and material stress enter the projected three-dimensional momentum rate.
- Velocity transports context and temperature, moves the material and changes its deformation. Material records and structural memory change stress and conductivity.
- Writing and structural relaxation have explicit work and heat accounting. Temperature changes viscosity and returns through the observation terms to social responses.
- Current fabric is decoded for recipient-directed history. The v3 override disables the older external episodic archive. It must not be replaced by the v2 Volterra history law.

The actual source uses finite Fourier and finite-volume operators, material quadrature, Heun time steps, and scheduled writes. The numerical method and the continuous-time equations it approximates are different proof targets. Neither one automatically proves an unrestricted spatial continuum limit.

## The event requirement that Lean checked

The original change ledger calls the mechanical write an **idealized event jump**. `structural_hug.py:223` replaces the selected unused slot's rest-strain coordinates, adds the corresponding heat, and updates writing work. `run.py:37` applies this update at the scheduled event endpoint. The nonzero stroke duration is used in the work calculation; the implementation does not evolve a resolved continuous writing stroke through that duration.

In exact real arithmetic, the source's probe formula recovers a rest strain b from load l and traction k(l-b), for k nonzero. The header magic is 1729, whose least significant bit is one. An empty, valid coordinate is negative; writing a one sets it to positive rest amplitude. If this event has the specified pre-event limit, that coordinate cannot be continuous at the write time. Any full state with that continuous coordinate projection likewise cannot be continuous there.

The six checked theorems are:

1. `probe_recovers_rest_strain` — the exact probe algebra.
2. `header_first_bit_is_one` — the stated natural-number header bit.
3. `valid_empty_coordinate_changes` — a valid empty coordinate differs from a written one.
4. `event_prevents_continuity` — distinct pre-write limit and post-write value rule out continuity.
5. `event_prevents_derivative` — the same witness rules out a derivative at that event.
6. `full_state_prevents_continuity` — the obstruction applies to an arbitrary full state space through a continuous observation coordinate.

These theorems are conditional on the displayed algebra and event witness. They do **not** prove that the full main trajectory exists, reaches every scheduled write, keeps every decoder valid, or has the assumed left limit. The Python bit packing, rounding and CRC implementation have not been formally proved equivalent to these mathematical statements. The arbitrary full state space in theorem 6 is not a completed Lean definition of V3's full state evolution.

This result is not a refutation of hybrid existence or uniqueness. Continuous evolution between events and specified updates at events are compatible with a well-posed hybrid system. A smooth trajectory theorem across every event would be the wrong target for this unchanged source.

## Full theorem still required

For the source's main case, the desired finite-horizon claim would construct a unique trajectory through time 1.6, starting from the declared initial state, satisfying every full joint rate between events and the exact updates and captures at event times. It must also establish that required decoding and writing operations succeed throughout the interval. The three declared observation windows and their overlaps must be preserved; the memory cannot be frozen or replaced.

This claim has **not** been proved or submitted to Comparator. A complete source-to-Lean translation of the full RHS and event program does not yet exist in this package.

Required work includes:

- Formalize the full source operators, nonlinear rates, initialization, event captures, writes and decoding. Establish the correspondence to the chosen exact-real or floating-point semantics explicitly. A generic function named `fullRHS` would not establish that correspondence.
- Prove local existence and uniqueness for the complete rates on a precisely defined valid domain. Smooth pieces alone are insufficient: norms, threshold branches, periodic wrapping, normalized kernels and decoding regions need their actual regularity arguments.
- Prove continuation to every scheduled event and through time 1.6. In particular, keep material direction denominators nonzero and decoding unambiguous; establish input encoding bounds, capacity and writing-budget conditions. Local existence alone does not establish those claims.
- Prove deterministic event composition and preservation of the conditions needed for the following interval. Do not replace successful-operation obligations with an assumption that the desired full solution already exists.
- If the intended conclusion concerns the spatial continuum, define and prove the appropriate continuum result separately. A proof for a selected finite grid, or for the deterministic time-step recurrence, would not establish it.

The source's stored numerical tests remain historical evidence. They were not rerun or promoted into a formal proof in this attempt. No absence of a proof is treated as a counterexample to the user's model.

## Checks actually run

The reference specification and challenges were frozen before creating the proof file. Native Lean compiled the specification, challenge and six proofs. The challenge alone contains the standard Comparator reference `sorry` placeholders; the solution does not import that challenge or use `sorry`, `admit` or new axioms.

A fresh non-root Linux directory ran Comparator with real Landrun isolation and the prescribed systemd address-family restriction. Both Lean's kernel and nanoda accepted the six listed proofs. The subsequent Lake build passed. Preflight and postflight checked frozen input hashes and clean pinned dependency commits. Linter warnings in the proof file are retained; they are not proof errors.

The pins are Lean `4.34.0-rc2`, mathlib `85e3a25e006c35636f0e53b0e9296caca2685bc0`, and Comparator `19e111e2141cf333c7daff0f64c5f24acc91dd2e`. Allowed axioms were only `propext`, `Quot.sound`, and `Classical.choice`.

See `evidence-linux/comparator.log`, `evidence-linux/preflight.json`, `evidence-linux/postflight.json`, `native-first.json`, and `verification-report.json` for the actual evidence. The full existence-and-uniqueness status remains **UNPROVED**, independently of these narrower passes.
