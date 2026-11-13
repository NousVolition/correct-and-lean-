# Fresh checks of the added research proofs

Recorded on 13 November 2026 UTC (12 November Pacific). All nine current check batches passed Lean compilation, Comparator, Lean's default kernel and nanoda. The two archived failed drafts still fail and are preserved separately. **All 161 Lean source files in the collected publication remain byte-for-byte unchanged.**

These checks concern the [12 November research collection](../../research/chat-research-update-2026-11-12/README.md), published at commit `2fb9e611e2f56a15db22f88e6e41ca5e0054fda6`. Identical modules shared by several energy/geometry packages were compiled together; the per-batch origins lists map every included copy to its exact hash. Target counts include shared and helper declarations and are not counts of independent scientific results.

| Batch | Configured declarations | Fresh result | Reference |
| --- | ---: | --- | --- |
| [vortex/as-signed-vortex-lean](vortex/as-signed-vortex-lean/record.json) | 25 | PASS | Original frozen challenge |
| [vortex/as-vortex-hline-lean](vortex/as-vortex-hline-lean/record.json) | 5 | PASS | Original frozen challenge |
| [vortex/as-vortex-rescaling-lean](vortex/as-vortex-rescaling-lean/record.json) | 12 | PASS | Original frozen challenge |
| [vortex/as-vortex-edge-control-lean](vortex/as-vortex-edge-control-lean/record.json) | 6 | PASS | Original frozen challenge |
| [vortex/as-vortex-edge-control-lean/time-check](vortex/as-vortex-edge-control-lean--time-check/record.json) | 2 | PASS | Original frozen challenge |
| [energy-as](generic/energy-as/record.json) | 245 | PASS | Frozen published-source recheck |
| [energy-hug](generic/energy-hug/record.json) | 181 | PASS | Frozen published-source recheck |
| [geometry-real](generic/geometry-real/record.json) | 653 | PASS | Frozen published-source recheck |
| [geometry-rational](generic/geometry-rational/record.json) | 65 | PASS | Frozen published-source recheck |

## What these checks establish

The vortex and time-control checks replay the original, separately frozen Challenge modules. For energy and geometry packages that previously had compiler logs only, the new references import the frozen published modules themselves. Comparator then compares the configured declarations and rechecks their proof dependencies with Lean's kernel and nanoda, allowing only `propext`, `Quot.sound` and `Classical.choice`. This is a **published-source proof recheck**, not an independently written model specification. The reference and solution project files were frozen before an empty final local build; the earlier enumeration build was not reused as a local compiled dependency.

Every result retains its original hypotheses and package scope. A passing conditional statement does not become an unconditional theorem about the full system.

The installed external Lean/Mathlib/upstream dependency caches were reused at their recorded pins. The local proof modules were freshly compiled. These are Linux/WSL runs under an unprivileged account with Landrun and systemd's `RestrictAddressFamilies=~AF_UNIX` isolation. They are not fresh GitHub kernel runs or a rebuild of the entire external library from source.

The first metadata-only theorem scan was stopped after inspection found it was repeatedly constructing the full imported-module list. A bounded replacement traversed only the selected modules' constant tables and completed successfully. [The original harness and recovery record](harness-history/metadata-recovery.json) are retained. No frozen final proof run or source equation was replaced by this correction.

## Failures and open claims retained

- The archived original `FabricMemory.lean` fails at its `full_fabric_refuses` proof step. The accepted package contains the already corrected proof; this session made no repair.
- The archived original rational `SIMSLatentReadout.lean` fails at two `decide` proof steps. Its already corrected version is checked separately. The failed original logs contain `sorryAx` from error recovery and are not accepted proofs.
- The supplementary Lean-only check of the published `SpecificProbe` worked example passes. The preserved `DerivativeProbe` diagnostic attempt still has unsolved proof goals and an unknown `HasDerivAt.congr` constant and fails; it is not an accepted proof. Both records are under `supplemental/`, and neither is an additional configured Comparator target.
- `HistoryCompletionTarget.FullPairExists` remains an unproved proposition. The theorem using it remains conditional on that proposition. Compiling the definitions and checking the conditional theorem does not construct the requested full pair.
- Full Hug evolution through every memory write, general physical A/S energy closure, and continuum convergence remain outside these passes. The unforced underlying formulation keeps its recorded meaning and equations; results for particular driven experiments are not transferred to it.
- No simulation was run. These proof checks do not certify the attached overlapping-write plot, its transcription, numerical accuracy, or hardware energy costs.

## Evidence and replay

[Machine-readable results](results.json), [all unchanged Lean input hashes](inputs.json), [tool identities and dependency pins](tools.json), and [archived original-draft results](archived/results.json) provide the entry points. Each table row has a corresponding folder under `vortex/` or `generic/` containing the full logs, commands, source bindings and frozen targets.

[Source coverage](source-coverage.json) maps every one of the 161 files, including trusted Challenge files, byte-identical retained copies, archived drafts and the diagnostic attempt. This map does not label every historical file as a successful proof.

`python verify_records.py /path/to/repository` checks the published receipt files and unchanged source inputs. It does not rerun a proof or simulation. Personal home-directory prefixes in public logs are replaced with `$USER_HOME`; [the receipt manifest](receipt-manifest.json) records both raw private and published hashes. The private originals remain unchanged. Compiled objects are represented by hashes where recorded, not uploaded.

To reconstruct an energy/geometry batch in an already prepared pinned Linux environment, use `python replay.py energy-as --repository /path/to/repository --cache /path/to/verification`. `--prepare-only` validates and reconstructs its frozen inputs without running the kernels. For vortex batches, copy the original sibling packages to an isolated directory and run the unchanged package's `bash run-check.sh verify`; never run a source-directory script where its output would overwrite retained evidence. Session runners are retained as provenance; use `replay.py` for the portable generic reconstruction.

**AI-generated; dictated and directed by NousVolition.** Existing source/model credits and repository reuse terms remain in force.
