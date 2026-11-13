# Rules checked before the material-journal extension

The original corrected DOCX, sealed local source, and connected GitHub files were checked. The current fetched structural code and `rule_changes.json` at commit `feda10a4f73d314f25691c127c83662c8b9b8b03` match the sealed local copies after newline normalization. Source copies are saved under `sources/`. The bounded searches did not establish an existing chronological material-journal layout or a rule transferring every earlier software sample into the original event payload.

| Existing rule | Source and treatment |
|---|---|
| Accumulated input belongs to the model | The original corrected DOCX paragraphs 517–519 specify transport, accumulated `A(t)` and `J = kappa*A`. These do not specify a chronological material codec. No new codec is attributed to those equations. |
| Material imprint and coupling | The structural fabric's residual strains enter energy and stress; gradient flow dissipates heat. Those laws are used for every added cell. |
| Probe-based observation | The source requires addressable, nondestructive, frozen-state two-load microprobes. Readout uses loads and tractions, not a metadata archive. The extension retains this synthetic observational assumption. |
| Finite material code | Original slots use int16 quantization and CRC32. The new row code uses these mechanisms with a separately declared capacity and schema. The original event format is unchanged. |
| No overwrite or repair | Source writes reject duplicate event IDs, exhausted capacity, invalid schema/ranges and inadequate work. Reads reject ambiguous wells and checksum failures without archive repair. Equivalent checks apply to journal append operations. |
| Accounted mechanical write | Use the same fixed-F linear stroke, stored-energy change, drag heat, quartic peak and conservative budget bound. Restricting sums to changed cells is algebraically identical because all other cell increments are zero. |
| Outcome is distinct from action | Retain independent observed/reported outcomes; do not derive success/failure from action labels or from the fact that a material write occurred. |
| Recipient-directed recall | Retain origin/recipient indices and original evidence. The previously declared prefix relevance now receives material-decoded features. |

Primary GitHub sources:

- [Structural cell, codec, probe and writer equations](https://github.com/NousVolition/hug-sims-lean-proofs/blob/feda10a4f73d314f25691c127c83662c8b9b8b03/lean/hug-v3-hybrid-lean/sources/structural_hug.py).
- [Explicit source rule changes](https://github.com/NousVolition/hug-sims-lean-proofs/blob/feda10a4f73d314f25691c127c83662c8b9b8b03/lean/hug-v3-source-lean/sources/rule_changes.json), especially “Virtual mechanical observation,” “Finite material code,” “No overwrite or silent repair,” “Mechanical write stroke” and “Recipient-directed retrieval.”
- [Clay-boundary findings and qualifications](https://github.com/NousVolition/hug-sims-lean-proofs/blob/feda10a4f73d314f25691c127c83662c8b9b8b03/lean/hug-v3-clay-boundary-lean/CLAY_BOUNDARY_REPORT.md). Its preservation results require an existing trajectory and stated deformation conditions; they do not prove successful writes or full continuation. They have not been transferred into a universal claim for the enlarged journal model.
- [Earlier coupling/source review](../speck-trust-v2/COUPLING-RULES.md), preserving the original label identities and the qualifications on neighbor, parent–child, caregiver and luck rules.

The DOCX is `$USER_HOME/Documents/Codex/2026-10-05/ca/outputs/sims-framework-correction-20261022/sources/corrected-corpus.docx`. It was reopened read-only, including its 638 paragraph nodes. The earlier complete paragraph comparison remains historical evidence; this task rechecks the relevant original passages and hash. The detailed material codec is an implemented synthetic candidate, not a formula recovered from the transport passage alone.

## New rules declared here

The new decisions are: a separate finite bank inside the material state `b`; a fixed 66-byte sample schema; 801 preallocated slots at the existing 0.002 time step; append writes including time zero; use of the original feature quantum for positions as well as context/strain/trust; retained original per-cell weights for added cells; and connecting each event to the material prefix through its encoded end time. These decisions appear in [DECLARATION.json](DECLARATION.json). They alter material capacity and constitutive contribution explicitly. No compression, truncation, free storage, automatic well reset, hidden archive, or post-result selection of a smaller allowed history class is used.

Finite quantized sampled retention is the implemented claim. It is not exact continuous-history recovery, a proof that the original four slots suffice, or a formal theorem for every allowed full-model trajectory.
