# Hug structural memory v3 — corrected-proof testing packet

**Revision 2 is complete as a written proof of local existence and conditional hybrid uniqueness.** Its 19 targeted checks passed. The nine-page PDF was inspected page by page; all 34 displayed formulas rendered without math errors, and their LaTeX strings match the Markdown master. No full-v3 Lean/nanoda certificate or unconditional continuation result is claimed.

This packet belongs to **hug-structural-memory-v3**, with the unchanged main interval **0–1.6**. It is separate from the Triangle Hug model and its **0–8** illustration. No results are transferred between them.

## Read the corrected work

- [Corrected proof, PDF](../corrected-proof.pdf)
- [Editable LaTeX](../proof.tex) and [Markdown master](../proof.md)
- [Self-contained HTML with rendered mathematics](../proof.html)
- [Correction register](../CORRECTIONS.md): R01–R12 identify every substantive repair and its scope.
- [Verification protocol](protocol.json): cases and tolerances stated before the successful run.
- [Successful check receipt](runs/20261101T053322.089427Z/checks.json) and [frozen input manifest](runs/20261101T053322.089427Z/input-manifest.json)
- [Source manifest](source-manifest.json): all 21 sealed files and the original attachment.
- [Original submitted proof](runs/20261101T053322.089427Z/inputs/original-submitted-proof.tex), unchanged.
- [Original equation-preservation check](runs/20261101T053322.089427Z/equation-preservation.json)
- [PDF and formula rendering checks](render-checks.json), [page-bound checks](pdf-layout-checks.json), and [visual inspection](visual-review.json)
- [Final artifact hashes](final-artifacts.json)

## Outcomes retained without overwriting

| Run / stage | Outcome | Meaning |
| --- | --- | --- |
| Prior source review, 20261101T051806.050149Z | Incomplete calculation attempt | SciPy was missing from the first environment; original preservation checks succeeded. Retained in historical evidence. |
| Prior source review, 20261101T051856.361354Z | Review completed; original proof invalid as written | Its counterexamples and the original document remain evidence. The corrected proof does not relabel that result as a pass. |
| Corrected-proof check, 20261101T053111.490037Z | [Incomplete](runs/20261101T053111.490037Z/checks.json) | The symbolic-math dependency was absent; one preservation check completed. No mathematical pass was claimed. |
| Corrected-proof check, 20261101T053322.089427Z | [19 checks passed](runs/20261101T053322.089427Z/checks.json) | Existing scientific packages plus a task-local symbolic checker completed the frozen protocol's analytical and static checks. |
| Rendering, attempt 01 | Browser formulas rendered; visual inspection pending at that stage | Preserved in `render-attempts/01/`. |
| Final rendering | Passed math, page-bound and visual checks | The final export was checked at A4 content width and all nine pages were inspected. |

`runs.jsonl` is the append-only stage record. Each numerical/static run has its own frozen proof input, protocol, source snapshots, checker and outcome. The first corrected-proof attempt remains incomplete; the later attempt is a new run.

## What was actually checked

The source gate accepted the unchanged main configuration. Fresh hashes matched all 21 original source files, the previous review's snapshots and the successful run's copies. The attachment and the triangle model/source snapshots were unchanged. The actual complete state has 193,122 coordinates and the unchanged six checkpoint times.

New static checks reject both earlier invalid-record counterexamples under the corrected theorem domain, accept valid and zero-duration records, distinguish analog rest strain from decoded bits, and check the stated ball margins. The spectral bound covers all 4,096 mode symbols and the former counterexample. Twelve deterministic sample pairs support the conservative transport and centered-difference inequalities. Kernel checks cover the corrected seam, quotient identity, row sums and positive normalization. Symbolic differentiation checks the activation and writing-rate formulas. Three static F = I writes using the declared event metadata preserve the repaired domain; a duplicate write is rejected without changing its input. Signed encoding accepts both exact endpoints and rejects the immediately adjacent outside values.

These finite checks support the written arguments. They do not establish a trajectory, global bounds or reachability of arbitrary test states. The static writes are not simulated physical event-time states.

## Preservation and remaining obligations

The correction changes the theorem's domain, derived bounds and proof reasoning. It does not change the decoder, field equations, social equations, material equations, coefficients, initial conditions or schedule. The original erroneous proof equalities remain in the unchanged source draft; the correction register explains their replacements in the new proof.

The proof leaves substantive continuation requirements explicit: an inter-event solution must reach each checkpoint with a finite admissible limit, and every write must succeed. The successful-write lemma then preserves the repaired domain. No a priori proof of those requirements through 1.6, continuum limit, floating-point correspondence or full source-to-Lean formalization was added.

The PDF was generated locally from the Markdown master with MathJax 3.2.2 and Chrome, rather than from a TeX compilation. The editable LaTeX retains the same 34 display formulas but was not compiled by a TeX engine in this environment. The PDF itself was rendered and inspected. Local rendering setup could not use WSL, and the restricted network could not resolve the formatter host; an approved download supplied the public formatter. These setup failures did not alter the proof or sources.

Future work should add a new revision and fresh frozen checks. Do not overwrite original sources, historical failures or prior theorem scopes, and do not merge this packet into the triangle model's numerical results.
