# Hug v3: timing, partial memories, mixed influence and anticipation

The unchanged full Hug v3 source contains context-dependent retrieval, separately stored observations and reports, mixtures of records, and a proposed constant-delay wrapper. It does not yet specify the complete variable-timing, solo reconstruction and anticipation-cost process described in the latest messages. The overall connection is **PARTIAL**. **All 17 submitted claims passed a fresh Lean build and Comparator, including both Lean's kernel and the independent nanoda kernel.** The final theorem about existence and uniqueness through every event, write and delay is not claimed here.

The [verification record](C:/Users/ziman/Documents/Codex/2026-10-28/new-chat-4/hug-v3-memory-rules-lean/verification-report.json) and [Comparator log](C:/Users/ziman/Documents/Codex/2026-10-28/new-chat-4/hug-v3-memory-rules-lean/evidence-linux/comparator.log) contain the fresh results. The check used the same pinned Lean 4.34.0-rc2 and Comparator commit `19e111e2141cf333c7daff0f64c5f24acc91dd2e`, with real Landrun isolation, a fresh solution build and the allowed axioms `propext`, `Quot.sound`, `Classical.choice`. No `sorryAx` or `native_decide` was admitted in the submitted proof closures. The intentional reference placeholders are not solution proofs.

The same returning student remains actor 1, the first teacher actor 0 and the second teacher actor 2. The idea remains **“Giving someone space to speak can change what I understand.”** These are interpretive aliases for the existing six-actor fixture, not changes to its equations or measured teacher/student data. No model state or physical transfer term was removed. This audit examines consequences of the complete source definitions; it does not turn those consequences into a proof that a full trajectory exists.

## What the latest explanation adds

“Three spatial directions” is taken literally. The full source has three-dimensional material positions `X`, three-dimensional flow, and the deformation matrix `F`. Your phone-to-body placement example refers to a real configuration that could affect an encounter. Separately, the current retrieval function has three features: two context coordinates and one strain feature. Those three features are **not** a definition of spatial x/y/z or a complete encoding of personal experience.

Your “download of identity” and “draft for the experience” describe the person arriving with a situated state: physical placement, the person they face, previous experience, expected consequences and available effort. For the returning student, that could mean remembering the first teacher before meeting the second and rehearsing whether giving space will help. The dishes example adds a decision between current effort and expected later consequences. These are user-supplied requirements, not equations silently added by this audit. In particular, a present act of imagining a future encounter is different from accessing a future solution value.

The source has current state, memory, context, utility, and physical energy/write-work accounting. A rule mapping phone/body placement to these particular social inputs, a forecast or rehearsal state, and a personal cost of anticipation have not been located in the inspected Hug v3 sources. Physical write work is not automatically a measure of mental effort. The claim that most people avoid anticipation because it is draining remains an untested claim; it is not used as a proof premise.

## Rules actually present

The formulas below abbreviate the existing definitions; they do not replace them.

For a stored record r, the source computes

`w_r(s) = (end_r − start_r) exp(−‖feature_r − currentCue(s) − 0.15 tanh(association_ij)‖² / (2 × 0.32²))`.

For the matching directed pair, each memory channel is

`M_k(s) = Σ_r w_r(s) evidence_k(r) / (0.12 + Σ_r w_r(s))`,

where only records with an available outcome score enter these sums, and

`evidence(r) = [max(y_r,0), max(−y_r,0), recognition_r, authority_r]`.

The exact expressions are in [V3SourceSocial.lean](C:/Users/ziman/Documents/Codex/2026-10-28/new-chat-4/hug-v3-memory-rules-lean/V3SourceSocial.lean:21) and the original `structural_hug.py:184–202`. The structural subclass overrides the older external archive. The old archive is not treated as an additional active memory mechanism.

| User meaning | Present rule and checked consequence | Limit or missing connection |
|---|---|---|
| Timing changes influence | Event duration multiplies relevance. Current context and association change the Gaussian cue. The source also prescribes overlapping observation windows and their write order. | No current-age decay appears in this structural retrieval weight. Moving both recorded endpoints by the same amount leaves its weight unchanged at a fixed state. This is not a time-translation theorem for the entire encounter or writer. |
| Immediate or delayed registration | The saved extension reads present physical state and material records with social state at `t−τ`; `τ=0` recovers the original RHS exactly. | `τ` is a parameter for a run. There is no saved rule selecting a different lag during the encounter, choosing which experience to buffer, or blending several past times. |
| A partial account | An observation or report may be absent. A report without an observation is still scored. If both are absent, the record contributes no retrieved evidence in any of the four channels. | This is missing fields, not a defined selection of half an experience, fragment reconstruction, or half a person. CRC/read failures are rejected; they are not interpreted as useful partial memories. |
| Untruthful or conflicting accounts | Observation and report are separately stored; when both exist, scoring averages them. Equal and opposite values give score zero, and different input pairs can give exactly the same score. | There is no truth detector or reliability adjudication. Stored distinctions are retained, but downstream scalar scoring can lose the disagreement. A positive observation and equally negative report are not proved to mean a neutral experience. |
| Mixed influence | Records for the same directed pair are combined with relevance weights and one prior of 0.12. Positive and negative records can both have strictly positive benefit/adversity channels. | Distinct records are not the same operation as averaging two accounts within one record. These strengths are not mixture probabilities for every aspect of identity, and mixed records are not a mixture of lagged state vectors. |
| Reimagining later | Changing context or association can change relevance while leaving stored bytes intact. The association rate is already part of the coupled dynamics. | This establishes a route for reinterpretation. It does not generate a new remembered episode, specify reconstructed content, or prove how much of an experience is retained. |
| A later solo experience | Internal context, associations and other state variables can evolve between encounters. | The record schema rejects `origin = recipient`; it does not currently encode a new self-addressed record through that route. This does not prove that every form of solo inner experience is excluded. |
| Experience with teacher 1 affects teacher 2 | Records keep their original directed pair. Previously audited shared norm/guard dynamics provide an indirect transfer route. | A first-teacher record is not automatically relabelled as a second-teacher record. The previous transfer lemmas are historical evidence, not a newly verified full student trajectory. |
| Anticipation can consume effort before the encounter | The full source contains physical dissipation, writing work, current utility and a source accumulator. | No implemented forecast rule or conversion from anticipated consequences to personal effort was found. The phone/dishes explanation supplies the intended connection, not yet its quantitative law. |

## Exact scope of the 17 submitted Lean claims

The reference statements were frozen before the proof module was written. Both reference and solution import the same unchanged full source. Two new definitions only name the existing cue difference and its squared norm; neither changes evolution.

| Claim | Meaning and assumptions |
|---|---|
| `report_without_observation` | The existing score accepts a report without an observation. This does not establish truth or writer admissibility. |
| `both_missing_ignored` | A record with both outcome fields missing changes neither numerator nor exposure when inserted into retrieval. |
| `opposing_reports_zero` | Opposite observation/report numbers have zero average score. |
| `different_reports_same_score` | Adding δ to one account and subtracting δ from the other preserves the score. The two stored accounts remain different. |
| `time_translation_weight` | Shifting both record endpoints preserves retrieval weight at the same state. No claim about event rescheduling or payload admissibility. |
| `closer_cue_increases_weight` | With positive duration, smaller squared cue distance strictly increases this record's weight. A smaller cue distance along an actual student trajectory is not assumed proved. |
| `association_changes_cue` | Changing association changes the cue by the exact existing `−0.15 tanh` difference. This compares states; it does not construct an evolution between them. |
| `changed_context_and_association_keep_record_bytes` | Altering only context/association leaves material decoding identical. Actual evolution can also change physical fabric, so this is not blanket permanence of memory. |
| `exposure_adds_across_records` | Exposure from two record lists adds. These lists need not be jointly writable within four-slot capacity. |
| `weighted_memory_merge` | The exact normalized merge formula holds when each component denominator is nonzero. It retains one prior in the combined denominator; it is not an unweighted average or a capacity theorem. |
| `opposite_events_both_influence` | Two records with the same directed pair, positive durations, one positive score and one negative score give strictly positive benefit and adversity channels. Assumes these records/scores; does not prove they occur in the fixture. |
| `source_partner_remains_identified` | A record whose origin differs from the queried partner contributes nothing to that pair's retrieval. |
| `self_record_rejected` | The actual payload function rejects matching origin/recipient. |
| `buffered_cue_mixes_current_body_past_context` | The saved wrapper's first two cue features use buffered context; its strain feature uses present physical state. |
| `buffered_records_current` | The wrapper decodes present material records. It does not read a delayed copy of the material archive. |
| `zero_delay_unchanged` | Setting the parameter to zero recovers the original RHS at the present state. |
| `only_selected_history_samples` | If two histories agree now and at the chosen `t−τ`, the delayed RHS agrees. This is a dependence statement, not uniqueness of either history or a variable-delay law. |

## What remains to connect and prove

1. **Timing selection:** a corpus-defined selection rule for immediate versus delayed registration, and any dependence on state, person or encounter. Substituting an arbitrary new `τ(t,s)` would change the saved extension; this audit does not do that.
2. **Partial/mixed reconstruction:** which fields or fragments are selected, how contradictory sources are weighted, whether a reconstruction is written as a new event, and what retains its provenance. No arbitrary “half” coefficient is introduced.
3. **Anticipatory preparation:** what is forecast, where a forecast is stored, how it affects action or the guard, and what accounts for the effort of rehearsing it before the encounter. These requirements should be connected to existing variables only where the source warrants that identification.
4. **Spatial embodiment:** the observable connection from actual relative placement and contact to the social cue/utility inputs. Three physical axes are already present; a calibrated person/phone/body mapping is not.
5. **Full existence and uniqueness:** actual full-rate regularity and domain bounds, nonvanishing fibers, continued readable fabric, successful event encoding/capacity/work budget, specified prehistory and event-side conventions, and composition through all events and delays. The earlier conditional local theorem did not discharge these conditions. Changing to variable or state-dependent timing would require the corresponding new regularity and causality analysis; the fixed-positive-delay argument does not establish it automatically.
6. **Correspondence and evidence:** the Lean source transcription is preserved and inspected, but a machine proof that Python execution implements the real-valued definitions is still missing. Mathematical consequences of chosen rules do not establish the rules as empirical laws of human experience.

## Corpus and preservation record

Read-only corpus work in this check included a fresh extraction of all 638 paragraphs, including equation text, from the corrected DOCX; the sealed source/registers and saved board extracts; fresh term searches on the 1,123-item SIMS Miro board and reads of 20 matching items plus the separate “download” match; and connected GitHub searches in the two known corpus repositories. The last two Miro matches concerned identity in other documents and were not read in this audit. Search coverage is bounded: failure to locate a rule here is not proof that no other private file contains one.

The Miro search found that the only `download` match was a downloaded manuscript, not the latest identity metaphor. Its current [full rule register](https://miro.com/app/board/uXjVEXBJz3k=/?moveToWidget=3458764688385112809) explicitly says association changes the cue rather than the stored record and describes the finite event, independent-report and recipient-directed retrieval rules. Its historical forgetting alternatives were not adopted. The GitHub `anticipation` matches concerned causal “no-anticipation” tests, not the effort of mentally rehearsing an encounter.

The corrected DOCX SHA-256 is `01f9ab0942f9c88982863e2ffc1e3c495786b5e6b67a26ae77d18235e7058acf`. Full extracts/search results are retained under `corpus/`. Fresh hashes checked all 21 original sealed source files and their 21 saved copies, plus the ten copied model/delay/build inputs; all were unchanged at that check. The 17 statements concern imported source definitions, not a replacement two-state equation. No new numerical simulation or human-subject test was run.

The full source distinguishes registered A/S relations from numerous assistant-added constitutive, social, numerical and event rules. Those additions are retained as declared model choices, not retroactively attributed to the user's original corpus or treated as measurements.
