# Zero excess utility from tick 41

Both complete saved states at tick 41 (time 1.2, after the third stored write) were resumed with the total excess utility feeding A set to zero at every Runge–Kutta stage. The switch time, energies and write counts were checked against the saved prime-meter table. A was retained exactly. The source law J = kappa A, moving source kernel, remaining social dynamics, force law and material/thermal equations were retained. Breathing and squeeze were off, and no further writes were performed.

| History | A retained | Energy at switch | Energy at 12 | Added energy | Added pull work |
|---|---:|---:|---:|---:|---:|
| off | 0.00640042228207 | 0.0719362100021 | 0.164453288647 | 0.0925170786448 | 0.092517078619 |
| on | 0.00640002826501 | 0.0719481134667 | 0.164475338445 | 0.0925272249782 | 0.0925272249503 |

Time-step comparison used RK4 steps 0.01 and 0.005, with the finer run exported. The predeclared tolerance is 0.1% for energy, peak slope, pull power and A, and 0.2 percentage points for the fraction above cutoff.

- off: comparison passed = True; energy: 7.05141e-07%; peak_slope: 5.49624e-05%; pull_power: 8.34827e-05%; A: 0%; active-fraction difference 0 percentage points.
- on: comparison passed = True; energy: 1.69576e-06%; peak_slope: 0.000135568%; pull_power: 0.000115457%; A: 0%; active-fraction difference 0 percentage points.

All original energy, scalar-balance, divergence and deformation checks passed. A, its zero derivative, and applied zero excess utility were checked at every RK stage; A stayed bit-for-bit constant. The three stored record payloads remained identical at every 0.1-time observation. The mean scalar field followed its independent analytic balance, mean C(t) = mean C(1.2) + kappa A(1.2) (t - 1.2). At both the switch and endpoint, direct comparison against the original solver on the identical state confirmed that only the A derivative changed.

CSV `utility` is the applied excess utility (zero); `unclamped_utility` is the score the original implementation would have supplied on the current state, recorded for diagnosis but not applied. `source_work` is the integrated pull work; it is distinct from the scalar source rate `context_source_rate`.

The earlier run with utility feedback left active reached energies off: 5.45872797715, on: 5.45990132953 at time 12. That reference uses the prior completed runs; it was not integrated again.

These are finite-time results on the existing grid. They do not establish infinite-time growth or spatial convergence. Original source files and saved states were read only.
