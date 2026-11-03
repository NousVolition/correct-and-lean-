# Hug v3: conditional hybrid assembly and proof review

**PARTIAL — full source-bound existence and uniqueness remain unproved.**

Nine precisely scoped results passed native Lean, a fresh Linux build, Comparator, the Lean kernel and nanoda. The reference statements and specifications were frozen before the solution was written. The Linux check used real Landrun isolation as the nonroot verification user. Only `propext`, `Quot.sound` and `Classical.choice` were permitted axioms.

The main theorem is conditional: unique solvable segments and successful deterministic events assemble into a unique finite hybrid trace. The full v3 differential RHS and concrete writer have not yet been connected to the theorem's `law` and `op` parameters. In particular, `StepSolvability` and `SegmentUniqueness` are **hypotheses**, not achievements of the source model.

| Verified declaration in `Hybrid.Verified` | Exact scope |
| --- | --- |
| `read_margin_stable` | A uniform strict perturbation bound preserves the well margin and signs |
| `decoded_value_stable` | An arbitrary deterministic function of those bits returns the same value; success is not inferred |
| `trace_uniqueness` | Segment uniqueness plus deterministic boundaries implies agreement of already existing traces |
| `trace_exists` | Explicit solvability of each whole segment plus its successful boundary transition gives a trace |
| `assemble_exists_unique` | Combines the preceding conditional results |
| `event_failure_excluded` | A valid successful trace cannot contain a rejected boundary operation |
| `v3_main_time_order` | The five specified main intervals are strictly ordered |
| `v3_simultaneous_event_order` | At 0.8, event 1 is written before event 2 is captured |
| `v3_main_conditional` | Assembly specialization to all full-state blocks and the selected main schedule, retaining the unresolved hypotheses |

The selected source has 193,122 real numerical coordinates, plus start-deformation snapshots. All fluid, material, thermal, accumulator, memory, social and accounting blocks are retained. The same student and idea are preserved as interpretation metadata. No empirical actor assignment or scoring was added.

The supplied paper's proposed domain is insufficient. Fresh source-method checks found CRC-valid readable records with an invalid outcome and with a reversed time interval. The raw spectral-gradient bound also fails outside the dealiased subspace. These are faults in the paper's argument as stated; they do not demonstrate a failure of the declared v3 trajectory. See `PAPER_REVIEW.md` for the corrections and `paper-checks.json` for the new evidence.

Read `HYBRID_THEOREM.md` for the mathematical statement, schedule and outstanding obligations. `pasted-proof.tex` preserves the user's original manuscript unchanged. `HybridChallenge.lean` contains reference-only placeholders used by Comparator; `HybridProofs.lean` imports the specifications directly and contains no proof placeholders or custom axioms. The only remaining solution warning is a deprecated tactic lemma name; it did not affect verification.

Reproduction uses the pinned `lean-toolchain`, `lake-manifest.json` and `lakefile.toml`. `comparator.json` specifies the exact nine claims. The supplied `run-linux-check.sh` records hashes, checks the configured dependency commits and clean source trees, uses a fresh solution directory and preserves its results in `evidence-linux`. Its absolute helper paths describe this workstation's already installed verification environment. `audit-paper.py` independently reruns the narrow paper counterexamples with NumPy/SciPy and the copied sealed source; it does not simulate a changed fluid model.

Original equations, source files and earlier packages remain unchanged. No complete trajectory was newly simulated. Earlier six event lemmas are historical results in the separate event package; this run checks the nine declarations listed above. A continuum-limit theorem, floating-point equivalence and empirical validation are outside these verified results.
