# Pair 25 retention test: simulation and Lean

User asks whether the pair leaves with everything it came with. "Pair 25" means the 25th A/B pair (stored ID 24), not all 25 pairs. Preserve carrying while values/configuration change.

This is a new finite continuation from the exact saved after-write state at model time 1.2 (tick 41) to 1.3. The original prime schedule ends at 41; later samples use model time without inventing prime labels. It does not reconstruct the missing inventory at 1.1.

Use n40/dt0.0005, n48/dt0.0005, and n48/dt0.00025 from their respective full-history checkpoints. Retain the threshold-0.015, breathing-on, 801-native-observer, 384-material-point model and all solver equations. This historical driven implementation is separate from the user's intended unforced formulation. No added object, carrier, passive cargo, imposed closure, reverse integration, or new write is introduced.

Inventory:
- Same A/B observer identities (global slots 825/850) and their five local fluid values: three velocity components, context concentration C and excess heat theta.
- For C and theta, independent time-integrated local rate budgets, separating diffusion/conduction, source/heat exchange, and the discrete advection/interpolation contribution. They are point values, not masses in a parcel or proof that all incoming physical contents can be recovered.
- All 384 material points: F, directional memory m and bistable material state b retain their existing identities. Test m nondecrease and every stored record's complete quantized payload, not just CRC.
- Classify every native state array in an entry/exit manifest. Shared material/actor arrays are not relabelled as the private property of A/B.

Observe 51 common times every .002. Preserve complete entry/exit state, compact samples, full byte payloads and identities; no fallback archive repair. At each actual Heun stage inspect material-memory increments, b read margins/signs and finite state.

Predetermined criteria:
- Record payload bytes and IDs match entry at all 51 samples; b signs unchanged and read margin >= .005 at all inspected stages/states.
- Material m has no decrease beyond 1e-14 across stages/states.
- C ledger residual <=1e-10 and energy ledger residual <=1e-6.
- Each local C/theta integrated budget closes within1e-6. This is a readout accuracy target, not an invariant that C/theta remain unchanged.
- Report spatial and time-step differences of these new readouts; no borrowed gap tolerance or unproved convergence claim.
- Failures remain results. Do not loosen criteria after seeing data.

Validation: instrumented and original one-step states must be byte-identical; trilinear readout gradient checked against an analytic multi-affine field and finite differences away from cell boundaries. Recount byte payloads, coverage, budgets and input hashes independently.

Lean: prove finite inventory/record preservation rules, show accounting can allow a value to change, reject missing/changed records and incomplete coverage, and check exact decimal encodings of the recorded numerical assertions. Do not assert or axiomatize the PDE simulation, physical cargo completeness or a new theorem of the fluid. Print theorem axiom dependencies; no sorry, native_decide or added axioms.

Deliver a local reproducible study, a plain diagram/report, and a passing Lean package with receipts. Publication is not part of this new request unless separately directed.
