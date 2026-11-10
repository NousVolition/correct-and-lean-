# Fourth write on the Hug prime meter

This standalone Lean project checks the measured fourth write in the 401-marker figure experiment. Both arm receipts and the full set of Hug meter readings are in `evidence/`.

## Build

Use the Lean version in `lean-toolchain`. Lake pins Mathlib and its dependencies in `lake-manifest.json`. In a new checkout with Mathlib’s cache available, run these commands in this directory.

```sh
python check_inputs.py
lake exe cache get
lake build
```

The Python command uses only the standard library. It checks the three input hashes and verifies that regenerating the Lean numeric literals gives exactly the shipped file. On a machine with the listed dependencies already built, `lake build` can use those dependencies directly.

## Results

Prime 59 is model time 1.6, mentor tick 400 and traveler tick 512. The work, heat and change in stored fabric energy below are in millionths of a Hug energy unit.

| Breathing history | Work | Heat | Stored energy change |
|---|---:|---:|---:|
| Always off | 12.972938 | 13.565637 | −0.592699 |
| On until prime 41 | 13.040157 | 13.605009 | −0.564852 |

`fourth_write_account` proves that work equals heat plus the change in stored energy for the exact numbers held in the receipts. It also checks the jump in the write-work accumulator and in computed energy, and equality of the signed residual immediately before and after the write.

Prime 157 is the continuation label for the saved model-time 3.6 endpoint, mentor tick 900 and traveler tick 1152. The saved meter labels extend through prime 59. The continuation uses successive primes at the same 0.1 intervals.

| Breathing history | Three-write residual | Four-write residual | Exact change in Hug units |
|---|---:|---:|---:|
| Always off | −2.290515626 × 10⁻⁸ | −2.290452765 × 10⁻⁸ | 2831 / 4503599627370496 |
| On until prime 41 | −1.466485869 × 10⁻⁸ | −1.466428275 × 10⁻⁸ | 41501 / 72057594037927936 |

`prime157_toward_zero` proves the ordering of the signed residuals in both arms. `all_meter_rows_valid` checks the two energy ledgers, clock alignment, write count after branching, phase order and receipt matches. Across 37 ticks per arm, the readings on both sides of the four writes bring each arm to 41 rows.

## What the arithmetic checks

The trajectories and receipts were produced by the Hug simulation. The Lean proof takes its measurements as inputs. The CSV distinguishes native endpoints from within-step readings. It omits fields outside the Hug energy comparison.

Each reported binary64 energy is represented exactly by a signed integer in units of 2⁻⁷⁷. For these particular readings, rounding the exact sum of source, squeeze, breathing and write work to 53 binary digits reproduces the recorded work sum. Lean then checks the expected energy and signed residual using nearest-even rounding in the same arithmetic order as the reported balance. The decimal display theorems check the stated rounding directly.

The theorem statements are in `PrimeMeter.lean`, the meter and arithmetic definitions in `PrimeMeter/Types.lean`, and the measured inputs in `PrimeMeter/Recorded.lean`. The build log includes Lean’s reported axiom dependencies.
