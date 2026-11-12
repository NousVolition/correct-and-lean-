# Pair 25: recorded origins, exits and replacement

User request: follow what pair 25 came in with, distinguish staying/leaving/replacement, and check the recorded results in Lean. Pair 25 is stored pair ID24, native observer slots 825/850. Use the same saved after-write tick-41 state (time 1.2) through time 1.3. No new prime label is assigned. Earlier receipts remain unchanged.

## Declared observation convention

The model has no complete private inventory assigned to A/B. Use two moving spherical observation windows centered on the existing A/B positions, with periodic distances in the unit cube. Primary radius is 0.075; radius 0.05 and 0.10 are sensitivity views. Record A, B and their union. These are observation boundaries, not objects, walls, ownership or a closed material loop. Entry-only inspection found material counts 132/1 and nonreference observer counts 234/42 in the primary A/B windows; the sparse material coverage near B must be disclosed.

Follow existing identities, without creating new physical cargo:

- All 384 carried material points and their existing F and m fields.
- All 926 passive observer labels, excluding A/B themselves (825/850) from replacement counts. Counts are unweighted labels, not mass or representative samples of all fluid.
- The three shared memory records by complete decoded bytes; do not assign this shared memory to the local pair.

At every completed native Heun step, record positions and window membership. Classify each identity: present throughout recorded steps; entered at start and absent at end; left and returned; initially outside and present at end; visited and left; never observed inside. Record first crossing brackets and the minimum distance to a boundary. A count of arrivals is not one-to-one replacement of a particular departing point. The finite sampling does not rule out crossings between samples.

## Context origin accounting

For each radius, partition the existing context field C at entry into the part initially inside the union and the part initially outside; initialize a separate later-source component at zero. Evolve these diagnostic components with the native conservative, centered finite-volume transport/diffusion operator and native Heun stages, using the unchanged realized velocity and source. All labels are passive: no component feeds the fluid or its coupled states. The components must reconstruct the native C field. Context is the model's signed scalar, not water mass or a molecule identity. Negative component values would prevent interpreting these components as nonnegative shares; retain such a failure without clipping or changing the solver.

At 51 common times, record original-inside context still inside the moving union, original-inside context elsewhere, incoming context of outside origin, and context added after entry. Record the same origin contributions at A and B. Moving-window changes include observation-boundary motion. An original tag found elsewhere is not destroyed. Thermal origin and a complete microscopic inventory are not established by this C-only origin calculation.

## Runs and acceptance

Run 40^3/dt0.0005, 48^3/dt0.0005 and 48^3/dt0.00025 from their own exact previous checkpoints. Retain threshold 0.015, breathing on, 384 material points and all original equations. This historical intervention does not redefine the intended unforced system.

Before production: verify native versus instrumented one-step equality of every state array; compare the batched origin transport with the native scalar operator; check linear reconstruction and conservative transport on synthetic fields.

For every run: all 17 exit arrays and all 51 saved pair positions must match the prior continuation byte-for-byte. Require maximum C reconstruction defect <=1e-12, global original-component drift <=1e-12, source-account defect <=1e-10, and component nonnegativity within 1e-12. Do not loosen these targets after seeing the results. Record every-step identity coverage, full memory payloads and all failures. Compare the same identities across grids and time steps; report all disagreements without borrowing the earlier gap tolerance or declaring continuum convergence. The boundary ambiguity band is 1e-8 model lengths.

## Delivery

Independently recompute membership, origin accounts, record retention, source fingerprints and state equality from saved arrays. Add meaningful refusal tests. Lean checks finite inventory/partition rules, recorded membership histories and exact decimal origin-account values. It does not prove the fluid solver, geometric interpolation, between-sample behavior, microscopic ownership or complete retention. Audit axioms; use no added axioms, sorry or native_decide. Save a report, diagram and separate Lean receipt locally. This request does not ask for a new GitHub publication.
