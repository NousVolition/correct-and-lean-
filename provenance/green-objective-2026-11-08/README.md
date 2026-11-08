# Verification receipt for `green_objective`

**Result.** Comparator checked the same 20 declarations on 3 November and 8 November 2026 UTC. In both runs the exported solution included `HugV3.Source.YMAuditVerified.green_objective`, nanoda and Lean’s default kernel accepted it, and both Comparator and the subsequent Lake build returned `0`. [Fresh transcript, lines 51–56](comparator.log#L51-L56) · [3 November transcript, lines 51–56](https://github.com/NousVolition/correct-and-lean-/blob/1f6fdc546eaedda451b5e38b6dff957260581023/lean/hug-v3-yang-mills-audit-lean/evidence-linux/comparator.log#L51-L56) · [3 November report](https://github.com/NousVolition/correct-and-lean-/blob/1f6fdc546eaedda451b5e38b6dff957260581023/lean/hug-v3-yang-mills-audit-lean/verification-report.json)

## The statement

For any real 3 × 3 matrices `F` and `Q` with `QᵀQ = I`, the Green strain of `QF` equals the Green strain of `F`. The proof first shows that `(QF)ᵀ(QF) = Fᵀ(QᵀQ)F = FᵀF`, then substitutes this identity into `(FᵀF − I)/2`. This theorem has no hypothesis about how `F` evolves over time. Global existence, Yang–Mills equivalence and a mass gap lie outside its scope. [Orthogonality](https://github.com/NousVolition/correct-and-lean-/blob/1f6fdc546eaedda451b5e38b6dff957260581023/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditDefinitions.lean#L11-L12) · [Green strain](https://github.com/NousVolition/correct-and-lean-/blob/1f6fdc546eaedda451b5e38b6dff957260581023/lean/hug-v3-yang-mills-audit-lean/V3SourceCore.lean#L15-L30) · [Lean proof](https://github.com/NousVolition/correct-and-lean-/blob/1f6fdc546eaedda451b5e38b6dff957260581023/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditProofs.lean#L14-L33) · [Package scope](https://github.com/NousVolition/correct-and-lean-/blob/1f6fdc546eaedda451b5e38b6dff957260581023/lean/hug-v3-yang-mills-audit-lean/AUDIT.md)

## What the fresh run checked

Checked source revision `1f6fdc546eaedda451b5e38b6dff957260581023`. The replay ran as UID 1000 on Ubuntu 26.04.1 LTS under WSL2. It started with a new Linux build directory and no compiled solution. It reused the installed Lean 4.34.0-rc2 toolchain and pinned dependency cache. [Fresh preflight](preflight.json) · [Runner](https://github.com/NousVolition/correct-and-lean-/blob/1f6fdc546eaedda451b5e38b6dff957260581023/lean/hug-v3-yang-mills-audit-lean/run-linux-check.sh)

| Evidence | Saved run (3 Nov UTC) | Fresh run (8 Nov UTC) |
| --- | --- | --- |
| Comparator interval | 05:03:47–05:04:39 | [07:07:49](comparator.started)–[07:08:47](comparator.finished) |
| Targets and axioms | 20 frozen targets, three permitted axioms | Same list and allow-list (`propext`, `Quot.sound`, `Classical.choice`) |
| Solution export and kernel results | Target on line 51, nanoda acceptance on 53, Lean acceptance on 55 | Same target and results on [lines 51–56](comparator.log#L51-L56) |
| Exit codes | Comparator `0`, Lake `0` | [Comparator `0`](comparator.exit), [Lake `0`](lake-build.exit) |
| Service invocation | `Running as unit: hug-v3-yang-mills-audit-comparator-20261102.service; invocation ID: 4039c48170e24ae982a4e24745bbd1cf` | `Running as unit: hug-v3-yang-mills-audit-comparator-20261102.service; invocation ID: 5200c94749124899b000334090d539a9` |

The two preflight records agree on 16 input hashes, 11 dependency revisions and clean states, the Lean version, and six executable hashes. The fresh postflight confirms the source hashes and dependency revisions still matched, and the dependency working trees were clean. [Saved preflight](https://github.com/NousVolition/correct-and-lean-/blob/1f6fdc546eaedda451b5e38b6dff957260581023/lean/hug-v3-yang-mills-audit-lean/evidence-linux/preflight.json) · [Fresh preflight](preflight.json) · [Fresh postflight](postflight.json)

The `sorry` warnings identify placeholders in the frozen challenge. The solution imports the definitions, supplies its own proof, and is the module exported for checking. The later Lake build reported two unused simplification arguments in the solution file. [Challenge statement](https://github.com/NousVolition/correct-and-lean-/blob/1f6fdc546eaedda451b5e38b6dff957260581023/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditChallenge.lean#L3-L10) · [Solution imports and proof](https://github.com/NousVolition/correct-and-lean-/blob/1f6fdc546eaedda451b5e38b6dff957260581023/lean/hug-v3-yang-mills-audit-lean/V3YangMillsAuditProofs.lean#L1-L33) · [Build transcript](lake-build.log)

## Rerun the check

Use Bash as a non-root user on Linux with a working systemd user session, Git, tar and Python 3. The frozen runner expects these installed locations. [Runner and preflight checks](https://github.com/NousVolition/correct-and-lean-/blob/1f6fdc546eaedda451b5e38b6dff957260581023/lean/hug-v3-yang-mills-audit-lean/run-linux-check.sh) · [Tool and dependency fingerprints](preflight.json)

| Required component | Location used by the runner |
| --- | --- |
| Lean 4.34.0-rc2 | `/opt/lean-audit/lean-4.34.0-rc2-linux/bin/lean` |
| Lake and Landrun | `/home/nsverify/verification/bin/lake` and `/home/nsverify/verification/bin/landrun` |
| Clean pinned packages | `/home/nsverify/verification/project/.lake/packages` |
| Comparator and lean4export | Within that cache, `Comparator/.lake/build/bin/comparator` and `lean4export/.lake/build/bin/lean4export` |
| nanoda | `/home/nsverify/verification/nanoda_lib/target/release/nanoda_bin` |

On another Linux machine, provision these prerequisites first. The repository supplies the package sources and lockfile. The external checker binaries and dependency cache must be available separately. [Package setup notes](https://github.com/NousVolition/correct-and-lean-/blob/1f6fdc546eaedda451b5e38b6dff957260581023/lean/hug-v3-yang-mills-audit-lean/README.md) · [Dependency lockfile](https://github.com/NousVolition/correct-and-lean-/blob/1f6fdc546eaedda451b5e38b6dff957260581023/lean/hug-v3-yang-mills-audit-lean/lake-manifest.json) · [Comparator setup at the pinned revision](https://github.com/leanprover/comparator/blob/19e111e2141cf333c7daff0f64c5f24acc91dd2e/README.md)

To obtain the sources, run `git clone https://github.com/NousVolition/correct-and-lean-.git` and `cd correct-and-lean-`, or use an existing clone containing the checked commit. Run the following Bash block from the repository root. It extracts only the pinned package into a temporary input folder. The runner writes its evidence into that temporary copy and into the new `check` folder, preserving the clone’s saved receipts.

```bash
set -euo pipefail
rev=1f6fdc546eaedda451b5e38b6dff957260581023
pkg=lean/hug-v3-yang-mills-audit-lean
scratch=$(mktemp -d "$HOME/green-objective.XXXXXXXX")
mkdir "$scratch/input"
git archive "$rev:$pkg" | tar -x -C "$scratch/input"
printf 'Run directory: %s\n' "$scratch"
bash "$scratch/input/run-linux-check.sh" "$scratch/check"

evidence="$scratch/check/evidence"
cat "$evidence/comparator.exit" "$evidence/lake-build.exit"
grep -F "from V3YangMillsAuditProofs" "$evidence/comparator.log" | grep -F "HugV3.Source.YMAuditVerified.green_objective"
grep -F "nanoda kernel accepts the solution" "$evidence/comparator.log"
grep -F "Lean default kernel accepts the solution" "$evidence/comparator.log"
```

Expect `0` on both exit-code lines, the target in the solution export, and both kernel acceptance messages. Compare your `preflight.json` with this receipt to identify any differences in inputs or tools. Each new run has its own service identifier and timing, so its transcript hash can differ. For a compilation-only check, the package documents `lake build V3YangMillsAuditProofs`. [Package build instructions](https://github.com/NousVolition/correct-and-lean-/blob/1f6fdc546eaedda451b5e38b6dff957260581023/lean/hug-v3-yang-mills-audit-lean/README.md)

## Fresh evidence files

These SHA-256 values identify the raw files from the 8 November run. The saved 3 November Comparator transcript has SHA-256 `8d20c20a5c7d945dbd53cf8ffadc50355c317326e482307257f6f0813acea6cd`. [Saved transcript](https://github.com/NousVolition/correct-and-lean-/blob/1f6fdc546eaedda451b5e38b6dff957260581023/lean/hug-v3-yang-mills-audit-lean/evidence-linux/comparator.log)

| File | SHA-256 |
| --- | --- |
| [comparator.exit](comparator.exit) | `9a271f2a916b0b6ee6cecb2426f0b3206ef074578be55d9bc94f6f3fe3ab86aa` |
| [comparator.finished](comparator.finished) | `7970b9d5b5cd9b7b234ba8da5936b02bd3ad3c84c10b5d628d5b94fbce99e888` |
| [comparator.log](comparator.log) | `2384585e5d0f87892e4a955a010842c6f7ea9b3cae537d5e7f9ab69f1309d4ad` |
| [comparator.started](comparator.started) | `8865aa1b74666d5ca71796bbaab8b40c26d582311853aa6b43017487d332fa53` |
| [lake-build.exit](lake-build.exit) | `9a271f2a916b0b6ee6cecb2426f0b3206ef074578be55d9bc94f6f3fe3ab86aa` |
| [lake-build.log](lake-build.log) | `7a7c1a5a992b046744998a6e4aa4fd980adb7f8572ca275cc52d08e495815b01` |
| [postflight.json](postflight.json) | `54cb2cd8c7a6c27a8c311d108da7a96c8c5537fbb49b0ca945515f6ef979b550` |
| [preflight.json](preflight.json) | `13dab3983665309627b630eedca19a13d431c15ec05a2fc41759db23dcd918c5` |
