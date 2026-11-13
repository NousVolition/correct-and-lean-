# Hug: six checked Lean proof files

The first five supplied drafts compiled unchanged with Lean 4.34.0-rc2. The sixth,
`FabricMemory.lean`, required a small proof-script correction: its second `split`
was trying to split a goal already reduced to `none = none`. The revised proof
uses `simp [write, full]`. All six original files are preserved byte-for-byte in
`originals/`, with the initial compiler logs in `logs/original/`.

The first four modules use Mathlib commit
`85e3a25e006c35636f0e53b0e9296caca2685bc0`; the final two need only Lean's core library.

The top-level files preserve all original theorem statements and add explicit
results where the prose went further than the original statement. See
`verification.json` for the final build status, source hashes, and complete axiom
audit. `ProofAudit.lean` asks Lean to report the axioms of every theorem in the
six proof files. Successful final logs are collected in `logs/verified/`;
other logs preserve earlier attempts, including the failed original sixth file
and intermediate work on the added energy-derivative theorem.

| File | What it establishes | Important limit |
| --- | --- | --- |
| `GuardTwoEffects.lean` | Guard-opening monotonicity, reversal symmetry, and inability to recover velocity or its positive/negative distinction from guard response alone | Results about the imported reduced eight-state equations at a single state |
| `BreathingDriver.lean` | A prescribed cosine drive ignores state, repeats, has bounded amplitude, reaches its peak at exact time 1.2, and reverses its work sign when flow reverses | An added drive in the breathing-on experiments; the push bound includes its spatial pattern |
| `PressureBlindToBreathing.lean` | A divergence-free push leaves one Fourier mode's pressure unchanged and passes through projection | Exact algebra under the stated assumptions; no exact certification of the numerical breathing pattern or the whole pressure history |
| `ClayFabric.lean` | Rest-point identities, response to strain mismatch, well-energy difference, fixed-strain dissipation, exact ideal probing, and information lost by sign/bit readings | A synthetic one-cell material formula; no stability, trajectory, real-clay, or full decoding theorem |
| `ClayMemoryInstance.lean` | 252 distinct listed present-stress values, each with different recorded preconsolidation-stress values; no exact reader from one column to the other on those rows | A statement about the transcribed table; equality of recorded values need not mean equality of unrounded physical measurements |
| `FabricMemory.lean` | Abstract write/refusal rules, an integer-scaled read margin, and indistinguishable event-ID lists with different transcribed cell-0 marks | The write model omits payload and budget checks; the observation is an event-ID list, not the complete decoded record |

## Changes from the supplied drafts

- **Guard:** added nonnegative-loss assumptions and proof, the matching influence
  magnitude statement for B, and an explicit Boolean positive-velocity obstruction.
- **Breathing:** separated the amplitude bound from the spatial-pattern bound;
  proved push periodicity and the pattern-dependent bound; added the
  three-component mean-work formula and its sign-reversal theorems.
- **Pressure:** made the nonzero-denominator condition explicit, handled the zero
  wave vector separately, and added an explicit Boolean on/off obstruction.
- **Clay:** distinguished the well-energy barrier from total transition energy;
  added the lower-mark counterpart, the energy derivative, and nonpositive
  fixed-strain relaxation power; proved ambiguity for the actual Boolean reading,
  including the two example marks restricted to the declared read margin.
- **Field measurements:** preserved every supplied number, corrected the description
  of its decimal conversion, and added kernel-checked distinctness of the 252
  present-stress values and of the row IDs within each pair.
- **Fabric memory:** corrected the failed proof tactic, updated deprecated tactic
  names, and made the event-ID abstraction and source-verification boundary explicit.
- Replaced broad `import Mathlib` in the revised files with narrower imports.
  `HugModel.lean` and `ActiveHugModel.lean` are unchanged byte-for-byte copies.

The statements use exact real arithmetic. Python floating-point execution,
source transcription, spectral masking and transforms, the full material reader,
and earlier clay source correspondence are not certified by Lean here. The
two historical clay formulas remain quoted-formula results. The full intended
unforced HugandNavier evolution is outside this package's claims.

## Source checks outside Lean

The workbook's SHA-256 matches the supplied identifier. Read-only ZIP/XML inspection
reproduced 4,319 paired numeric rows, 3,330 with preconsolidation stress greater than
present stress, and 252 ambiguous present-stress groups. All supplied groups and
extremes match numeric cells parsed as binary64 and then rendered as shortest decimal
strings. That is not exact preservation of the raw XML decimals: 74 listed groups
have at least one difference. The counts remain the same under either interpretation,
and the 4 kPa witness is exact under both. See `workbook-source-check.json`.

Read-only checks of the preserved snapshots independently reproduced the two cell-0
fractions, 149,056 changed marks with zero sign changes between frames 400 and 599,
37,264 marks changed by the third write, and 18,726 upper marks in that write's slot.
The inspected noiseless-probe equations and header/CRC rules gave event IDs `[0, 1]`
at both earlier instants, with identical packed payload bytes. This was an independent
read of saved data; the original solver and full schema decoder were not rerun.
See `snapshot-source-check.json` and `source-provenance.json`.

## Rebuilding

The tested local build uses `build-native.ps1` with the existing matching Windows
Lean toolchain and dependency cache. It compiles both model files, all six proof
files, and the complete axiom audit, stopping on compiler errors. It does not
download or modify dependencies.

```powershell
./build-native.ps1 `
  -ToolchainBin 'PATH/TO/lean-4.34.0-rc2-windows/bin' `
  -DependencyRoot 'PATH/TO/project/.lake/packages'
```

`DependencyRoot` must contain the matching built Mathlib package and its
dependencies. By default the script writes compiled modules under
`.lake/build/lib/lean` and logs under `logs/rebuild`.

A conventional Lake project with pinned dependencies is also supplied. On a
machine with Elan/Lake and network access, the normal setup is:

```text
lake exe cache get
lake build
```

The receipt records the direct native compiler build actually run in this
session. The clean-download Lake workflow above was not run in this session.

`Classical.choice`, `propext`, and `Quot.sound` are standard Lean/Mathlib logical
foundations. An axiom audit should show only these (or fewer), and never
`sorryAx`. This does not turn source comments or physical interpretations into
proved statements.
