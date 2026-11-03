# Hug–Navier single-system Lean package

Read [RESULTS.md](RESULTS.md) first. Verification is partial: ten specific theorems pass; full PDE existence and uniqueness have not been proved.

Files:

- `FullModel.lean`: all six shared-flow PDE rates, incompressibility, source initial fields, periodicity and unproved full-evolution targets.
- `OriginalAS.lean`: original accumulated-memory A/S–Navier equations, separately preserved.
- `FullChecks.lean`: actual completed proofs. No import of the challenge or reduced mechanical Hug ODE.
- `FullChallenge.lean`: Comparator's reference statements; intentional unfinished reference proofs only.
- `sources/`: unchanged source snapshots and original-corpus provenance.
- `reference-freeze.json`, `verification-inputs.json`: source and statement hashes with the recorded freeze-timing exception.
- `evidence-linux/`: clean-build, Comparator and independent-kernel evidence.

The Lake configuration pins Lean, mathlib, Comparator and their dependencies. With these dependencies installed, `lake build` builds `FullChecks`. The full independent check uses Comparator with `comparator.json`, real Linux Landrun isolation and nanoda enabled. `run-linux-check.sh` records the exact environment-specific route used on this computer; it deliberately requires a fresh destination and clean dependency checkouts. Toolchains and dependency build caches are not bundled in the archive.

No numerical trajectory, empirical calibration or proof of full existence/uniqueness should be inferred from this package's successful build.
