# Original two-memory Yang–Mills example

This is a specified flat abelian example; it is not a solution of the Clay Yang–Mills mass-gap problem.

**Verification: PASS** for Comparator, Lean’s kernel, nanoda and the default build. The 16 configured statements passed in [GitHub run 42852357760](https://github.com/NousVolition/hug-sims-lean-proofs/actions/runs/42852357760). The actual [report](verification-report.json), [logs and axiom lists](evidence-linux/), and [checked revision and input hashes](evidence-linux/source.json) are saved in this package. These are the successful historical checks of the unchanged proof inputs.

This standalone project builds the original `TwoMemoryTransport.lean` together with its two source dependencies, `TwoMemory.lean` and `Volterra.lean`. Their file hashes are listed in `source-sha256.txt`.

## Build

Use the Lean version in `lean-toolchain`. The dependencies are pinned in `lake-manifest.json`. In a fresh checkout, run the following commands from this directory.

```sh
lake exe cache get
lake build
```

With the pinned dependencies already built, `lake build` is sufficient. The default target is `TwoMemoryTransport`.

## The original result

The model acts by positive real rescalings on the odds of two memory weights. Its cue coefficient is −2. In the four Euclidean coordinates, the abelian potential is constant, with components (−2, 0, 0, 0).

`TwoMemoryTransport.flat_curvature` proves that every curvature component is zero at every point for this potential. `TwoMemoryTransport.source_free` proves that the source-free field-equation residual is zero in every component there. The source also proves composition of transport and exact return around a closed cue route.

These statements specialize to the potential defined in the original file. The source’s axiom reports are printed during the build.

## Assumptions in the dependency

`Volterra.extend_continuous` and `Volterra.extend_val` hold for any topological codomain. Extension clamps a real argument to the closed interval. It agrees with the curve inside the interval, and composition with the continuous clamp preserves continuity.

`Volterra.step_apply` unfolds the integral operator and needs no completeness assumption. `Volterra.path_integrable` restricts an already-integrable path to a smaller interval and needs neither a real vector-space structure nor completeness. The two iteration bounds also hold without completeness. Completeness enters at the fixed-point existence theorem. These six lemmas now state the more general facts their proofs establish.

The byte-for-byte original field and transport source has SHA-256 `b8681a3435b2367081d285fb83e7964a9ce5d2f7d0c9de07b87c798638a5d36e`. The repository CI checks the ten original statements and the six generalized lemmas against the separate reference.

The independent reference keeps interval, memory, and transport declarations in separate modules. This preserves the original module boundaries for Lean’s generated numeral helpers.
