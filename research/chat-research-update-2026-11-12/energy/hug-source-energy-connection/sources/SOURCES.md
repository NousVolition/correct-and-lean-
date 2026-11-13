# Source review for the Hug field specification

**Current coupled continuation:** [COUPLED_FIELD.md](COUPLED_FIELD.md) supersedes the component-only stage. The corrected DOCX SHA-256 was rechecked again for the coupled implementation and is unchanged. A fresh board survey paginated all 58 areas matching memory, structure, energy, stress, source, transport, threshold, force, kernel and boundary, then read 31 matching frames, the persistence labs, energy-sign note, recommendation kanban and both image items. Readable shape text was inspected from its content attributes as well as ordinary text. The connector still reports unsupported/foreign items; this is not an exhaustive pixel transcription of the board. The two images did not supply a readable physical constitutive law. Private read evidence is saved in `work/hug-field-specification-source/miro-coupled-read-0.json` through `-4.json` and `miro-coupled-extra.json`.

The complete synthetic field specification labels immersed coupling, the material law, record-expression split, power allocation, conductivity, upper-half exchange and the nonlocal flux convention as additions. [Chen and Peskin](https://arxiv.org/abs/2302.08694) and [Peskin](https://www.cambridge.org/core/services/aop-cambridge-core/content/view/95ECDAC5D1824285563270D6DD70DA9A/S0962492902000077a.pdf/div-class-title-the-immersed-boundary-method-div.pdf) inform the adjoint immersed-coupling convention; their solver validation is not evidence for this implementation. Its checks and numerical refinement are performed independently. The remainder of this file records earlier source-review stages chronologically.

The corrected DOCX hash was rechecked on 22 and 23 October 2026 and is unchanged. Relevant Miro content was read again through the connector. Specification drafting and mathematical checks continued on 23 October. Neither source was edited.

## Corrected corpus

Local source: `$USER_HOME/OneDrive/Desktop/Plain_Language_Corpus_Math_and_Logic_Corrected.docx`.

SHA-256: `01f9ab0942f9c88982863e2ffc1e3c495786b5e6b67a26ae77d18235e7058acf`.

The prior extraction contains 624 nonempty paragraphs, including tables. It has no embedded math objects or images; the equations are text. The unchanged file hash makes that extraction applicable to this review. Paragraph numbers below identify XML paragraphs, not rendered pages.

| Location | Supports |
|---|---|
| 19–24 | Scope of the highlighted initial-field result; separate evolution obligation; Sens and Sin distinction |
| 67–96 | Static coordinate alignment is not an evolution law |
| 228–267 | Momentum, fixed-direction response, three scalar branches and gradient regularizations |
| 517–520 | Signed field transport, accumulated input, normalization and possible continuing growth |
| 524–543 | Field, input, conversion and kernel definitions |
| 545–580 | Newtonian stress, threshold calibration, units and limits of the analogy |

## Current Miro review

Board: [Plain Language Corpus corrected math and logic](https://miro.com/app/board/uXjVEXBJz3k=/).

The 22 October overview reported 766 items and 35 frames; an earlier audit reported 777 items. The 23 October board search reports 808 items. These snapshots differ; no claim is made to have inspected every board item or the layout of every image/embed. The following sections were reviewed for this specification.

| Section | Use in this specification |
|---|---|
| [05 Three response laws](https://miro.com/app/board/uXjVEXBJz3k=/?moveToWidget=3458764687912872499) | Keep activation and regularization branches distinct |
| [06 Static invariance and dynamic memory](https://miro.com/app/board/uXjVEXBJz3k=/?moveToWidget=3458764687912872500) | Accumulated source and Newtonian stress convention |
| [13 Memory can feed a threshold response](https://miro.com/app/board/uXjVEXBJz3k=/?moveToWidget=3458764687916065203) | Shared S–u coupling is proposed; domain, units, data and response still required |
| [16 The past survives a zero input](https://miro.com/app/board/uXjVEXBJz3k=/?moveToWidget=3458764687918055185) | Unit pulse, order effects and distinction between input cancellation and resetting the field |
| [18 Identical readings can hide different states](https://miro.com/app/board/uXjVEXBJz3k=/?moveToWidget=3458764687918055187) | Separate latent state from a projection or reported verdict |
| [20 Smooth switch effects](https://miro.com/app/board/uXjVEXBJz3k=/?moveToWidget=3458764687918055189) | Signed tail, underflow, direction loss and separate observability questions |
| [Grounding the core loop](https://miro.com/app/board/uXjVEXBJz3k=/?moveToWidget=3458764688169288636) | Additional comparison proposals: no decay, decay to a floor, full decay, and held-out evaluation |

The board-wide text search used Hug, mimetic, doubling and clay. It returned no matches for these terms. That does not rule out content inside images or unsupported objects. Canvas reads reported skipped foreign objects; the relevant managed text and equations listed above were read. Raw connector evidence is retained privately in `work/hug-field-specification-source/miro-review.json`.

The newer grounding section discusses R(t)=c+(1−c)exp(−λt) and R(t)=exp(−t/S) as retention comparisons. The latter S is a time-scale symbol, not automatically the corpus's spatial S(x,t). These functions do not silently replace A or C2. Their cited literature was not independently audited for this specification, and no claim about human memory is based on them here. The board's suggested held-out comparisons are treated as proposals, not a theorem that information criteria must always agree.

## Existing Hug geometry

Read local `work/My-Sources-Project-ALL/math/hug_envelope.py` and `math/notes/hug-boundary.md`. The code describes its own timed outline as a prescribed geometry prototype. Its midpoint closed pose has horizontal scale 1.08 and reciprocal vertical scale. Thickening that curve into a 3D material body is explicitly new; so are its support and stress law.

Geometry file SHA-256: `e0ef7fbb71e561d8875e1efc02e2ebf79558a8d0eae5e2e03ef9ee3045d9bdb6`.

## External technical references

These support continuum conventions and distinctions, not the user's S interpretation or physical clay parameters.

- [Bower, Applied Mechanics of Solids, hyperelastic materials](https://solidmechanics.org/Text/Chapter3_5/Chapter3_5.htm): strain energy, deformation tensors and pressure in incompressible elasticity.
- [COMSOL linear viscoelasticity](https://doc.comsol.com/6.4/doc/com.comsol.help.sme/sme_ug_theory.06.029.html): history-dependent stresses and the separate rheological branches.
- [COMSOL large-strain viscoelasticity](https://doc.comsol.com/6.3/doc/com.comsol.help.sme/sme_ug_theory.06.030.html): finite-deformation internal-state formulation is a separate specification.
- [Jie Liu, fluid–structure interaction](https://arxiv.org/abs/1401.0082): distinct fluid and solid descriptions with velocity and traction continuity. Only the author abstract was used; its numerical stability result is not transferred to the Hug candidate.

## Provenance of additions

The Q-unit convention, thickened domain, lower fixture, material law M1, moving normalized Gaussian, source pulse, pair mapping, height weight, exchange law D2, detector O1 and synthetic tidal forcing are proposals written for this task. They are not attributed to the document, Miro, Girard, laboratory measurements or the previous surrogate's numerical results.

On 23 October the user clarified that S transfers internally and externally and described it as movement, with electricity in molecules as an analogy. This is newer design intent, not a new assertion found in the DOCX or Miro. The draft now treats the sealed within-body model as a comparison and states separate transfer balances T1–T4. The scalar activity/flux representation, linear interface law and interior-only source allocation remain labeled proposals. The analogy does not by itself identify electrical charge, potential or energy as S.

A subsequent correction on 23 October assigns the gravity-like holding role to the Hug and the movement/energy-transfer role to S. This supersedes treating the Hug simply as a material container. The draft now distinguishes the corpus's earlier scalar S_c from that intended flow role. All earlier scalar exchange, constitutive and observation examples remain unselected comparisons; their numerical checks are not validation of a new gravitational or energy-flow model. No new equation is attributed to the user or board on the strength of this analogy alone.

## Holding and energy continuation, 23 October

The new [HOLDING_AND_ENERGY.md](HOLDING_AND_ENERGY.md) uses C for the original scalar, and proposes S_E as energy flux. The external potential, thermal law, material comparison, matched energy interface and contextual pair exchange are explicitly labeled additions. Energy identities are derived under their assumptions; they are not attributed to the corpus as previously supplied equations.

Additional targeted board searches covered gravity, gravitational, holding law, energy transfer, potential, confinement and force. No readable text match supplied a Hug gravitational or energy-transfer law. This is a limited text-search result, not a claim about unparsed images. The [new theory map](https://miro.com/app/board/uXjVEXBJz3k=/?moveToWidget=3458764688184818696) and sticky note `3458764687917934072` were read: the latter asks to check the energy sign. The map proposes memory-decay comparisons. Those are treated as source material to evaluate, not instructions overriding the user's no-reset intent or sufficient definitions for a physical model.

A consolidated read of response section 05, coupling section 13, switch section 20, the theory map and the energy-sign note returned 92 managed items and reported 78 skipped foreign items. The targeted evidence is saved privately in `work/hug-field-specification-source/miro-holding-review-2026-10-23.json`.

External conventions checked for this continuation:

- [OpenStax: conservative force and potential](https://openstax.org/books/university-physics-volume-1/pages/8-2-conservative-and-non-conservative-forces): the negative-gradient convention; choosing it for the Hug remains an addition.
- [COMSOL: heat-transfer conservation of energy](https://www.comsol.com/multiphysics/heat-transfer-conservation-of-energy?parent=fluid-flow-heat-transfer-and-mass-transport-0402-442) and [continuum heat balance](https://doc.comsol.com/6.3/doc/com.comsol.help.heat/heat_ug_theory.07.005.html): mechanical work, internal energy and heat exchange. The proposed equations derive their own balance explicitly.

The user subsequently supplied `fauxmoi_v4_complete.png` and requested a checked social illustration. [FAUXMOI_CASE_STUDY.md](FAUXMOI_CASE_STUDY.md) links each admitted observation to its source and labels other major claim families as unresolved. The original image was inspected using temporary crops; it was not edited, copied into the public output folder or used as calibration data. Current/date-sensitive claims are distinguished from cached responses and historical self-reports. No GitHub publication or Miro modification was made for this continuation.


## Structural-memory continuation, 23 October

The latest user direction supersedes the earlier gravity-based role definition: the Hug gathers and restructures, traces become part of its changing structure, and S transfers through it and its surroundings. The user explicitly selected changes within existing material first. Literal growth and loss of material are excluded from this stage.

The DOCX SHA-256 was rechecked and is unchanged. A fresh Miro area search for memory, structure, growth, retained, transport and boundary returned 41 areas on an 808-item board. A targeted read of sections 06, 13, 16, 18 and the theory map returned 107 managed items and reported 72 foreign/skipped items. The read supports source accumulation, separate static/dynamic models, coupling obligations and hidden-state distinctions. It does not supply a material recording, hardening or thermal-conductivity law. Evidence is retained privately in work/hug-field-specification-source/miro-structural-review-2026-10-23.json.

[STRUCTURAL_MEMORY.md](STRUCTURAL_MEMORY.md) labels the new directional record, bounded expression, energy-limited writing, elastic energy and conductivity as additions. The original source, threshold force and separate pair interaction are not silently merged. The current module and component experiments have explicit synthetic parameter values; none are recorded as physical calibration.

External checks used [Bower: constitutive requirements](https://solidmechanics.org/Text/Chapter3_1/Chapter3_1.php), [Bower: hyperelasticity](https://solidmechanics.org/Text/Chapter3_5/Chapter3_5.htm), and [Berezovski: Constitutive Modeling with Single and Dual Internal Variables](https://pmc.ncbi.nlm.nih.gov/articles/PMC10217598/). These support the general requirements to connect stored energy, stress, internal state and dissipation. They do not validate the added Hug material candidate. No equations from their particular example materials were represented as the user’s equations.

The executed experiments are an imposed material-point deformation history and a separate stationary one-dimensional thermal field across a body/exterior interface. Neither is a complete moving-body or orbit simulation. The previous gravity and scalar files remain marked historical comparisons.
