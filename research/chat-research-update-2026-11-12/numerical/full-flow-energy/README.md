# Full-flow energy balance with and without the material journal

This audit compares the existing A-trusting/B-untrusting case through time 1.3. Both arms retain the same moving A/B identities, six actors, original outcome schedule and evidence, material/flow laws and quantized prefix-recall rule. The journal arm has the additional finite material bank and sampled write jumps. The control supplies the same quantized features in software, with no journal cells or journal-write heat/work. This is a matched test of the physical journal addition; it is not a physical claim that software storage is free, and it is not the original endpoint-only retrieval model.

Read [RESULTS.md](RESULTS.md) for measured results and [verification.json](verification.json) for the numerical checks. The [extra-work plot](extra-work.png) separates supplied work, net heat retained and the change in mechanical storage. The [verification plot](energy-verification.png) shows each complete energy balance, its residual and the thermal allocation. PNG, SVG and PDF versions are provided.

## Original equations checked

The original local corrected DOCX was reopened read-only. Its SHA-256 remains `01f9ab0942f9c88982863e2ffc1e3c495786b5e6b67a26ae77d18235e7058acf`; it has 638 paragraph nodes. Paragraphs 229–230 state the incompressible momentum equation and fixed-direction forcing. Paragraphs 265 and 550 explicitly warn that a fixed-direction force is not necessarily dissipative. Consequently the audit integrates the **signed** force power `mean(u · f)`, rather than labeling all force work as heat. Paragraphs 545–549 identify the viscous stress and threshold formulation. Retrieved passages are in `sources/document-energy-passages.json`.

The detailed material/fabric/thermal budget belongs to the implemented synthetic candidate. It is not attributed to the corpus momentum equation alone. Freshly fetched primary GitHub files match the executed local files after newline normalization:

- [Continuum energy, material coupling, thermal equation and independent ledgers](https://github.com/NousVolition/hug-sims-lean-proofs/blob/feda10a4f73d314f25691c127c83662c8b9b8b03/lean/hug-v3-hybrid-lean/sources/continuum.py), especially `material`, `rhs`, the `ledger` definition, and the diagnostic energy functional.
- [Breathing force and its separate work ledger](https://github.com/NousVolition/hug-sims-lean-proofs/blob/38312565dd567db1306b4f8c72b863641453de98/research/hug-v3/fluid-grid-study/source/model/breathing.py). Its `ComparisonSolver.rhs` adds the prescribed solenoidal force and `mean(u · breath_at(t))` to an independent ledger.
- [Structural fabric and accounted writer](https://github.com/NousVolition/hug-sims-lean-proofs/blob/feda10a4f73d314f25691c127c83662c8b9b8b03/lean/hug-v3-hybrid-lean/sources/structural_hug.py), freshly matched in the preceding material-writer task and read locally here. Each successful write supplies stored-energy change plus drag heat.
- [Existing full-flow energy diagnostic](https://github.com/NousVolition/hug-sims-lean-proofs/blob/38312565dd567db1306b4f8c72b863641453de98/research/hug-v3/fluid-grid-study/source/run_study.py), which subtracts threshold, breathing and write work from energy change.

The audit uses the original absolute energy-residual criterion `1e-6` from the sealed `protocol.json`. The added journal law remains as declared in [material-trust-v3](../material-trust-v3/DECLARATION.json). No original source, historical trajectory, equation or journal code was edited for this audit.

## Correct whole-system balance

Let `M = K + U_continuum + U_fabric` be mechanical energy, including kinetic energy and every original/journal fabric cell. Let `T = mean(theta)` be excess thermal energy. The constant thermal baseline cancels from changes. Total energy is `E = M + T`. The signed context field `C`, accumulator `A` and trust variables have no additional assigned energy functional in the checked code; their physical effects are accounted through the actual force and writer work.

For each arm, measured before any time-zero write:

    E(t) - E(0-) = W_threshold(t) + W_breathing(t) + W_event(t) + W_journal(t) - R_total(t)

Here `R_total = W_in - [E(t)-E(0-)]` is retained as a numerical residual. It is never subtracted from the equations, inserted as heat or forced to zero. The initial sample write is included in work and heat at time zero; the additional bank's preexisting rest-strain energy remains in that arm's measured initial energy.

In the original periodic thermal equation:

    T_dot = mean(Q_viscous) - P_to_directional_memory + P_fabric_relaxation

The spatial advection and conduction fluxes have zero integrated boundary contribution. Writer jumps additionally deposit their stroke heat. Thus the independently integrated net heat is

    Q_net = integral(Q_viscous + P_fabric_relaxation - P_to_directional_memory) dt
            + sum(write_stroke_heat).

`Q_net` is not heat lost from the closed domain. It remains in thermal energy. Gross viscous/fabric/stroke dissipation and its diversion into directional material storage are also reported separately. Adding gross dissipation to total energy would double count energy already retained as heat.

Taking journal minus control (denoted delta), the plotted allocation is

    delta W_in = delta Q_net + delta[M(t)-M(0-)] + R_allocation.

The separate absolute final total-energy difference is

    E_journal(t) - E_control(t)
      = [E_journal(0-) - E_control(0-)]
        + [(E_journal(t)-E_journal(0-)) - (E_control(t)-E_control(0-))].

This retains the actual initial difference under the source energy convention and prevents initially stored journal energy from being counted as newly supplied work. Preparation work before the chosen initial state is not simulated. A negative extra mechanical-energy gain is allowed: the journal arm can release more of its initial stored energy.

## Independent measurements and numerical checks

`energy_audit.py` observes both native Heun stages without modifying any state derivative. It integrates threshold power, breathing power, viscous heat, fabric relaxation and diversion into directional memory from those actual stages. Energy is separately evaluated from current arrays using the original material and fabric energy functions. It checks the instantaneous chain-rule power balance, the independent thermal equation, and all write jumps.

The standard integration step is 0.002. A second pair uses two 0.001 Heun substeps for each accepted 0.002 sample interval. The **journal capacity, physical writing cadence, event boundaries and sample precision remain identical** across resolutions. This refines the integration rather than changing the physical memory model. No state-space restriction is introduced to force the balance. This is one prespecified initial-trust case; it does not sample every allowed state.

Snapshots are measured at each flow endpoint and after its writes, including both sides of time zero. The journal arm at step 0.002 is checked array-for-array against the previously published final state. Its work accounts and initial energy are measured directly, not transcribed from the earlier summary.

The checks declared before the full runs are in [DECLARATION.json](DECLARATION.json). In addition to the inherited `1e-6` per-arm energy criterion, the extra-work allocation must have differential residual below 1% of peak extra work. Results include the actual residual and time-refinement ratio, rather than only a pass label. These finite numerical checks do not establish a universal continuous-time theorem or empirical calibration.

## Reproduce

Use the project Python environment with NumPy/SciPy for the solver and Matplotlib for the figures:

```text
python -m unittest -v test_energy_audit
python energy_audit.py --arm journal --substeps 1 --out runs/journal-1
python energy_audit.py --arm control --substeps 1 --out runs/control-1
python energy_audit.py --arm journal --substeps 2 --out runs/journal-2
python energy_audit.py --arm control --substeps 2 --out runs/control-2
python plot_results.py
```

The runner refuses nonempty output folders. Each run saves raw energy samples, independently accumulated channel budgets, per-write accounts, a complete final numerical state, the numerical residuals and source/declaration hashes. `comparison-dt-*.csv` contains the plotted differences. This audit does not replace or modify the existing material trust viewer.
