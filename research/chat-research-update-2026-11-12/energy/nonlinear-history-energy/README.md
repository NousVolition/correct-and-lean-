# Nonlinear energy of the full carrying configuration and history

**The checked original notes do not identify a nonlinear energy law that fills the 43.6%. The nonlinear material energies that are actually specified in the later implementation are already included in the account.** This check separates those terms explicitly, rather than extending the earlier quadratic S-gradient test to arbitrary nonlinear states.

Original equations, constitutive laws and saved states are unchanged. There were zero new simulation steps. The numerical check reads the 62 saved states from the threshold-1 experiment, time 0–1.2; the original corpus and later implementations remain distinct.

## Which nonlinear candidates are actually present?

| Source candidate | What it specifies | Energy finding |
|---|---|---|
| Original sharp/tanh/exact-off activation a(q) | Nonlinear force response to the S gradient | A force response is supplied; a full-configuration stored-energy functional and its opposing transfer are not. |
| Original accumulated input A and S transport | Retained input, transport, diffusion and continuing source production | Specifies evolution/history, without a physical energy density or fuel conversion law for that history. |
| Original reciprocal SR relation | A static invariant under its declared reciprocal rescaling | It is not the spatial S field's evolution law. No source mapping makes this an energy store paying the activation remainder. |
| Later exponential directional memory | f(m)=1−exp(−m/m*) inside W(F,m) | A real nonlinear storage law, explicitly marked as an added material candidate; already counted in W and its stress/write/heat balance. |
| Older retained/recent expression split | Retained m with a separate fading expression z | A declared earlier comparison; its release is assigned to heat. It is not an uncounted reservoir in the v3 run, which does not use that fading z law. |
| Implemented bistable fabric | Strain/history coupling plus a quartic two-well energy | A nonlinear energy that can release heat and retain different records; already counted. Explicitly checked below. |
| Persistence/decay alternatives on the board | Comparisons of memory update laws | These are proposals for changing/testing memory dynamics, not an original physical energy law. They are not activated in this unchanged-equation check. |
| Holding-potential and signed-supply proposals | Added potential examples and a negative-work ledger | Historical additions, not a derivation of the needed full-history storage. The ledger is not treated as a physical supplier. |

The targeted search read the nonlinear/history passages in the same 12 corpus documents, nine archived board exports and six later note files. All hashes still match the previous source review. [Source evidence](source-check.json) retains paragraph/line numbers, board item IDs and distinctions between original content and additions. Skipped board images/foreign objects and live-board changes remain untested.

The user's meaning remains one intended unforced continuum, with carrying continuing as its configuration changes. Older specification wording about an externally powered comparison is not adopted as a definition of that intended system.

## Explicit nonlinear stored-energy check

The known implementation uses four components:

W_base = (G₀/2)(tr(FFᵀ)−3),

W_record = ½ Σ G_k [1−exp(−m_k/m*)] e_k(F)²,

w_micro = (k/2)(e(F)−b)²,

w_well = (H/4)[(b/a)²−1]².

The first two are integrated over the material quadrature; the fabric terms use their existing microcell weights. These laws depend on changing configuration and retained state. The quartic term is not convex over its whole domain; this check does not assume the full initial state minimizes all stored energy.

Direct evaluation at every saved frame reproduces the native material energy with maximum absolute difference **5.59e-21**. Their net changes are:

| Component | Final minus initial energy |
|---|---:|
| Base deformation | +1.0926125218e-6 |
| Exponential directional memory | +7.8246916401e-7 |
| Fabric strain/history coupling | +4.3120438097e-8 |
| Quartic memory wells | +8.4806239570e-11 |
| **Complete implemented material store** | **+1.9182869301e-6** |
| **Additional store change needed by the endpoint activation account** | **−1.0654747938e-5** |

These are model-energy amounts. All four known components have positive net changes over this interval. That endpoint comparison alone would not exclude energy passing through them; the rate/heat identity below checks where the actual releases go. Event-writing jumps are already represented in the saved states and the original write-work account.

For the nonlinear fabric, define

Y = ∂w/∂b = k(b−e) + (H b/a²)[(b/a)²−1].

Its unchanged evolution and heat laws are

ḃ = −M Y, Q_fabric = M Y²,

ẇ = k(e−b)ė − Q_fabric.

The stored-energy loss from changing b is exactly the heat gain, even when Y contains nonlinear terms and strain/history cross-coupling. Squaring Y retains the cross term; independently squaring the two gradient contributions would give the wrong heat. Individual microstrain and well energy rates can have either sign.

The saved-state check finds maximum relaxation/heat defect **2.94e-23**, identical fabric b rates, and maximum virtual-strain stress-contraction defect **2.44e-21**. The previously verified 1,200-stage replay integrated **7.9241619708e-10** of fabric relaxation heat. That historical stage result is reused with its hash, not newly rerun; its heat is already in the thermal balance.

See [nonlinear-storage-check.json](nonlinear-storage-check.json) and the [62-frame component history](nonlinear-storage-history.csv).

## What the existing proofs already cover

There is no need to pretend these were all quadratic tests or compile the same claim again. The previously checked `ClayFabric.energy_has_derivative_gradient` and `ClayFabric.settling_turns_energy_into_heat` apply to the strain-coupled quartic fabric at fixed strain. `HugSourceEnergy` supplies the exponential-memory chain rule. The new numerical virtual-strain check verifies the implemented F-dependent stress transfer separately.

`FullCarrying.complete_existing_transfers` permits arbitrary functions K, W, H and V. Its cancellation does not require W to be linear or quadratic and does not assume the component rates vary independently. Once the actual nonlinear W obeys its stress/write/release law, those internal exchanges cancel in K+W+H, leaving the original A/S power. Adding the earlier candidate V leaves the activation remainder.

Likewise, `GradientStorage.initial_minimum_cannot_pay` is already a general endpoint statement, not specifically quadratic. It excludes any candidate whose actual initial state is a minimum and which is asked to supply a positive net demand. It does not exclude a nonlinear store that starts away from its minimum. The fabric was checked directly rather than incorrectly assuming that condition.

The proof receipts and relevant source hashes are referenced in [verification.json](verification.json). No new Lean compilation or new theorem is claimed in this task.

## The precise unresolved condition

Let z contain the full existing configuration, source variables and retained states, and let H_t denote any history a candidate genuinely uses. A proposed extra energy Ψ(z,H_t), derived independently from the intended physics, must satisfy

d/dt Ψ(z(t),H_t) = −R(t)

for the activation remainder R, together with the appropriate existing event/jump balance. This must follow along solutions of the unchanged equations, with stated initial energy and units. Ψ also has to avoid counting W or heat a second time. This equation is an acceptance condition, not a new constitutive law inserted into the model.

An arbitrary function fitted to a trajectory, or Ψ₀−∫R dt, can reproduce the required numbers. That does not establish a physical gravitational store, a unique law, or its validity on other allowed histories. The checked sources do not select an independent nonlinear Ψ that meets these conditions.

The 43.6% therefore remains open. The outstanding issue is the actual stored-energy formula and its exchange law, rather than whether the existing material law is nonlinear. This is not a proof that no such functional can ever be derived from the intended model.

## Preservation and reproduction

Fresh work: one targeted source review, 62-state decomposition, nonlinear relaxation and stress-contraction checks. Reused evidence: the successful full-state replay and existing Lean receipts, with hashes verified. No notes, equations or saved frames were edited. The scripts retain the original `work/nonlinear-history-energy/` layout and known local input paths; they depend on prior workspace scripts/data and are not a standalone distribution of the full simulation archives.
