# Hug v3 Yang–Mills audit package

The 20 frozen theorem targets passed Lean, Comparator and the independent nanoda checker. Read `AUDIT.md` for the mathematical result, interpretation and remaining proof obligations. The package uses the unchanged full Hug v3 source definitions; it does not assert Yang–Mills equivalence or full hybrid/delayed existence and uniqueness.

| File | Purpose |
|---|---|
| `V3Source*.lean`, `V3DelayDefinitions.lean` | Preserved model and saved delay definitions |
| `V3YangMillsAuditDefinitions.lean` | Comparison maps and derivative predicates; no replacement Hug equations |
| `V3YangMillsAuditChallenge.lean` | Frozen reference statements, with deliberate reference-only placeholders |
| `V3YangMillsAuditProofs.lean` | Completed solution, importing no challenge file |
| `verification-report.json` | Final results and scope |
| `evidence-linux/` | Fresh isolated verification, kernel acceptance, build and source-integrity logs |
| `reference-freeze*.json`, `verification-inputs.json` | Hashed reference and checked inputs |
| `source-preservation-check.json` | Read-only checks of original and copied source, pins and corpus |
| `corpus/` | Retrieved passages and search evidence |
| `DEVELOPMENT-NOTES.md`, `dev-*.log` | Development history, including failed attempts and the notation-only reference correction |

Lean is pinned to `leanprover/lean4:v4.34.0-rc2`. The manifest pins mathlib to `85e3a25e006c35636f0e53b0e9296caca2685bc0` and Comparator to `19e111e2141cf333c7daff0f64c5f24acc91dd2e`. With the toolchain and dependencies available, the ordinary build is:

```text
lake build V3YangMillsAuditProofs
```

The recorded Comparator run additionally used Landrun and nanoda in the existing Linux audit environment. `run-linux-check.sh` is tailored to those installed paths; it verifies the pinned clean dependencies, uses a fresh directory, and rejects a directory that already exists. For another run in that environment, supply an unused absolute Linux check-directory path as its first argument. Do not overwrite the retained successful evidence. The script's nanoda and permitted-axiom settings are in `comparator.json`.

`check-preservation.ps1` checks the original workspace sources read-only and updates the preservation report; those original paths must still be present. This archive contains the Lean proof inputs and evidence, not a second complete Python simulation environment or downloaded dependency binaries.
