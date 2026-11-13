# Pull after shutoff: squeezed pair, force 0.7

Both archived states were resumed at model time 3.6. Breathing and squeeze were off throughout this continuation; their accumulated work and the write-work total remained exactly constant. All three stored records decoded to their original payloads at every 0.1-time observation.

| Run | Energy at 3.6 | Energy at end | Energy increase | Pull work added | End time |
|---|---:|---:|---:|---:|---:|
| Breathing always off | 0.08772858547 | 5.458727977 | 5.370999392 | 5.370996968 | 12 |
| Breathing on until 1.2 | 0.08775325805 | 5.45990133 | 5.372148071 | 5.372145636 | 12 |

The exact accounting used is ΔE = ΔW_pull + Δr, where E is kinetic + elastic + thermal energy, W_pull is the independently integrated `source_work` ledger, and r is the signed energy-balance residual. Instantaneous pull power is the grid mean of u · f_pull. The source accumulator A is a different quantity: it supplies the scalar field through κ A kernel and has no energy-depletion equation in this implementation.

Shutoff applies to squeeze and breathing. The added social utility input remains active: A_dot = 0.08 [pulse(t) + 0.8 (V(state) - V(initial))]. The pulse is zero from time 1, but V remains above its fixed initial baseline. Audit rule B04 marks this utility mapping as an implemented addition; the accumulator law itself comes from the registered Hug source. Therefore this continuation did not test zero total excess utility. See `A-growth-provenance.md` and `A-growth-audit.json` for the source distinction and measured contributions.

The original Heun runs stopped when they exceeded the existing 0.00002 absolute energy-residual limit: at time 8.4 with step 0.005, and at 9.6 with step 0.0025. Classical RK4 was then applied to the unchanged equations at steps 0.005 and 0.004.

Time-step comparison (maximum relative difference across the shared 0.1-time readings):

| Run | Compared through | Energy | Peak slope | Pull power | A | Within declared tolerances |
|---|---:|---:|---:|---:|---:|---|
| off | 12 | 0.00015793% | 0.021141% | 0.00018588% | 3.0604e-10% | True |
| on | 12 | 7.9279e-05% | 0.0095376% | 0.00043889% | 3.18e-10% | True |

The preset tolerances were 0.1% for these four quantities and 0.2 percentage points for the fraction of grid points above the cutoff. Detailed run statuses, inherited checks and any failures are retained in `Hug pull verification.json`.

The earlier Heun step-0.0025/RK4 step-0.005 comparison, through 9.5, agreed to within 0.0047% in energy and 0.040% in pull power. Peak-slope differences reached 0.375%, exceeding the preset 0.1% tolerance. That comparison is retained as a failed precision check; the RK4 step comparison above assesses the replacement integration.

The separate feedback readings use G = mean(|D C|²)/2, where D is the same centered gradient used by the pull. They split dG/dt into source, diffusion and advection contributions. This measures total slope variation, not the derivative of the single largest slope. They also separate kinetic energy and pull power into average-flow and fluctuating-flow parts. The net momentum-rate check verifies that the domain-average acceleration equals the domain-average pull force at each inspected checkpoint.

With breathing always off, 75.51% of the energy added after 3.6 is kinetic energy of the average flow. The average-flow energy is |mean(u)|²/2; the remaining kinetic energy is mean(|u - mean(u)|²)/2. The energy-components figure shows both parts separately from elastic energy and heat.

The results establish behavior over the measured interval on the existing grid. They do not establish infinite-time growth or spatial convergence. The original archived states and source files were read only.
