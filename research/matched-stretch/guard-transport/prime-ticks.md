# The mentor and marker clocks at prime ticks

The marker advances every 1/320 model unit. The original comparison clock records every 1/250 unit. A marker step $k$ and a mentor step $j$ share a physical time exactly when $25k=32j$. Since 25 and 32 are coprime, the pairs are $(32m,25m)$ at times $m/10$. The export assigns the first 13 primes in order from 0 through 1.2. All 401 specks present at a shared time receive that time tag. Each keeps its own marker ID.

| Model time | Prime | Marker step | Mentor step | 3D output frame |
| ---: | ---: | ---: | ---: | ---: |
| 0.6 | 17 | 192 | 150 | 300 |
| 0.603125 | — | 193 | between 150 and 151 | between 301 and 302 |
| 0.65 | — | 208 | between 162 and 163 | 325 |
| 0.7 | 19 | 224 | 175 | 350 |

At 0.65 the two bracketing mentor ticks are 0.648 and 0.652. Calling either one a coincidence would shift the comparison. At 0.7 both clocks can be compared directly.

## A second trajectory on the mentor clock

The historical comparison clock supplies timing. For this experiment we also advanced a second copy of each speck on that clock, using the same 96×96 velocity frames, bilinear samples and midpoint integrator as the marker. In each 0.1 interval the marker took 32 steps and the mentor took 25. Both continued from their own positions across shared ticks without resetting. The baseline marker replay also matched all 10,426 originally exported prime-tagged rows in time, ID order and position to CSV precision.

| Basin | Prime | RMS distance between the two paths | RMS velocity difference at their own positions | RMS held-out velocity error at identical positions |
| --- | ---: | ---: | ---: | ---: |
| 7.52 | 17 | 0.000000961 | 0.00000270 | 0.01243 |
| 7.67 | 17 | 0.000001037 | 0.00000303 | 0.01309 |
| 7.52 | 19 | 0.000001353 | 0.00000415 | 0.01625 |
| 7.67 | 19 | 0.000001473 | 0.00000475 | 0.01713 |

For the last column we hid the velocity readout at the shared tick, estimated it from the two adjacent prime ticks, and evaluated both the estimate and the withheld field at the *same* baseline marker positions. The positions themselves came from the ordinary saved-field trajectory. This column measures reconstruction of a field reading. The preceding column measures the velocity difference caused by the two integrated paths arriving at slightly different places. Only a comparison at a common position gives the velocity residual used in the [guard transport proof](../../../lean/hug-navier-wellposedness-lean/GuardTransport.lean). [All 13 catch-ups and 11 interior field checks per case](prime-results.json)

## The same times in the 3D cylinder records

The cylinder saves every 1/500 unit. At a prime tick it has an exact frame $50m$. We verified all four historical CSV hashes against the solver provenance, joined baseline and breathing runs on the 801 original marker IDs, and counted later insertions separately. At prime 17 in the 7.67 case the two archives contain 808 and 809 markers. Among the same 801 original specks, the RMS depth difference is 0.001117. At prime 19 it is 0.001535. These are depth differences between two forcing conditions. A velocity interpolation error in 3D would need an independent velocity field at the same points. [All matched depth readings](cylinder-results.json)

Run the checks beside these scripts with NumPy and SciPy. The 2D check regenerates the frames by default. Pass `--archive` for the original frame directory and `--readings` for the original dense-trail ZIP to compare against the exported rows. The 3D check accepts the original CSV directory and verifies its inputs before reading the trajectories.

```sh
python check_prime_ticks.py
python check_cylinder_ticks.py /path/to/3d-csv-folder
```
