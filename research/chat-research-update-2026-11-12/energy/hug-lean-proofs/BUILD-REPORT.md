# Lean build result

PASS: all six revised proof files and their two unchanged local model dependencies compile.
The combined audit reports all 92 theorems, using only standard Lean/Mathlib
axioms (`propext`, `Classical.choice`, `Quot.sound`) where needed. No final theorem
depends on `sorryAx`; no proof placeholders or `native_decide` calls occur in the final sources.

| Proof file | Theorems | Result |
| --- | ---: | --- |
| GuardTwoEffects | 18 | PASS |
| BreathingDriver | 14 | PASS |
| PressureBlindToBreathing | 13 | PASS |
| ClayFabric | 23 | PASS |
| ClayMemoryInstance | 9 | PASS |
| FabricMemory | 15 | PASS |

Lean: `Lean (version 4.34.0-rc2, x86_64-w64-windows-gnu, commit 6a10ac8c22beadecabdbb0919c2b50214762f91d, Release)`. Mathlib: `85e3a25e006c35636f0e53b0e9296caca2685bc0`.
Verification completed at `2026-11-12T07:01:14.569702+00:00` (UTC).

Five originals compiled unchanged. `FabricMemory` initially failed at a redundant
second `split` in `full_fabric_refuses`; `simp [write, full]` now proves the same statement.
All 70 original theorem statements are preserved, and
22 explicit supporting theorems were added. The added
energy-derivative proof needed tactic corrections before passing; failed intermediate
logs are retained separately from `logs/verified/`.

The workbook hash matches the supplied hash, and all 252 groups match its parsed-number
export. The draft's claim of exact raw-decimal preservation was corrected: 74 groups
contain at least one decimal changed by binary64 parsing/formatting. The 4,319/3,330
counts and 252 ambiguous-group count hold under both checked interpretations.

Read-only snapshot checks reproduce the cell counts, exact cell-0 binary64 fractions,
event IDs, and identical packed record bytes at frames 400 and 599. These are newly
computed checks of saved historical data, not a new solver simulation. The source
workbook, snapshots, original attachments, and imported model files are unchanged.

This is a direct native Lean build, with compiled modules in `compiled/`. The separate
clean-download Lake workflow was not tested. See `README.md` for rebuild instructions,
`verification.json` for hashes and exact compiler commands, and the source-check JSON
files for the checks outside Lean. The full intended unforced system and trajectories
remain outside these theorem statements.
