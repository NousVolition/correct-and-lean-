Hug v3 DDE extension v1

Read Hug-v3-DDE-extension.md and extension-register.json first.
This preserves the full baseline definitions and adds the requested timing split.
Nine definition-level identities pass Lean and independent Comparator checks.
This package does not contain a DDE trajectory solver or existence/uniqueness proof.
No calibrated delay or fabricated initial history has been selected.

V3DelayDefinitions.lean is the extension; V3DelayProofs.lean is the checked solution.
V3DelayChallenge.lean contains intentional reference-only placeholders for Comparator.
The solution does not import the challenge and contains no admitted proofs.

reference-freeze.json and V3DelayDefinitions.initial.txt preserve the initial formatting.
reference-freeze-current.json records the syntax-only amendment transparently.
evidence-linux contains the fresh independent build and both kernel-check logs.

run-linux-check.sh records the existing WSL verification setup. It needs the pinned
dependencies and external Landrun/lean4export/nanoda binaries identified in preflight.json.
Use a fresh check directory; prior evidence should be preserved.
