# What the completed controls change

**The saved runs support a persistent numerical history effect, a change in closest-point history when breathing is removed, and exact repetition of the dining outputs under fixed inputs. Speck crossings remain strongly dependent on the grid.** These are separate experiments, with different thresholds, observation rules and limits.

This review recomputes the arithmetic, event-table agreement, speck counts and paired dining differences from the saved files included here. It makes no new fluid run, model call or Lean proof check. [Recomputed results](recheck.json) · [Source hashes and settings](sources.json) · [Recount script](verify.py)

## A different history survives time-step refinement

The threshold-0.015, squeezed, 401-marker experiment turns breathing off after model time 1.2. Each refinement starts from time zero on the same spatial grid.

| On-minus-off quantity | Step 0.005 | Step 0.0025 | Step 0.00125 |
| --- | ---: | ---: | ---: |
| Energy at 0.7 | 5.275334624e-5 | 5.275676815e-5 | 5.275915654e-5 |
| Additional threshold work, 1.2–3.6 | 1.276931679e-5 | 1.278596932e-5 | 1.278460305e-5 |
| Energy at 3.6 | 2.467257888e-5 | 2.467812234e-5 | 2.468118136e-5 |
| Accounting residual at 3.6 | 8.240297569e-9 | 9.879815160e-10 | 1.152425516e-10 |

From **half to quarter step**, the first two quantities change by **+0.004527%** and **−0.010687%**. These percentages use the absolute quarter-step value as denominator, matching the original report. From native to quarter step their changes are +0.011013% and +0.119568%; the smaller percentages do not describe the entire refinement sequence. The final residual separation shrinks by **71.503949 times** from native to quarter step.

The post-drive energy difference at 3.6 is still about 2.4681e-5. Thus the model retains measurable differences after breathing ends, while the accounting discrepancy decreases. These scalar observations support a history effect on this grid. They do not prove convergence of every state component, spatial convergence or indefinite persistence. The energy includes the coupled system's storage; it should not be relabelled as velocity alone. [Metrics](history-metrics.csv)

## Breathing changes the observed switches

The threshold-1 comparison keeps the same initial arrays, particle labels A and B, 16³ grid, step 0.002 and write schedule. It changes the breathing coefficient from 0.5 to zero. Each branch records its own evolving state.

| Branch | Resolved examples, model times | Exchanges in the matched late windows |
| --- | --- | ---: |
| Breathing on | 1.180910, 1.182077, 1.199281 | 3 |
| Breathing off | 0.400002, 0.456368, 1.004318, 1.086997, 1.123015 | 0 |

The late windows are 1.178–1.184 and 1.198–1.200. The five off examples establish that breathing is **not necessary for every closest-point exchange**. Removing breathing changes the measured history. These are resolved examples, not total event counts or one-to-one matches between particular on and off events; **24 rapid route changes remain unresolved**. Local time refinement shifts a resolved event by at most 9.54e-9. Spatial and full-history convergence remain open.

The selected point lies on a finite vorticity-line trace, 0.75 cube lengths forward from A. Some exchanges involve its endpoints. They do not by themselves establish vortex reconnection or a break in the material path. [Exchange table](threshold-1-exchanges.csv) · [Full saved result](threshold-1-result.json) · [Original study](../../hug-v3/threshold-one-follow-up/README.md)

## The dining outputs repeat under the tested conditions

The saved audit contains **2,000 fresh model calls**: two repetitions of five 200-member batches, giving **1,000 matched A/B comparisons**. The recount finds **zero changed sentences, zero changed action tuples and zero changed prompt hashes**. The saved audit also reports zero differences from the original outputs, including raw text and tokens; this compact recount checks the parsed A/B outputs directly and retains the original-comparison flags.

The model was `NVIDIA-Nemotron-3.5-Bolt-E4B-UD-Q4_K_XL.gguf`, using greedy argmax decoding with thinking disabled. Prior dialogue was frozen for each phase, contexts were cleared and the model was reloaded between repetitions. Consequently, the original scene differences are reproducible against this observed zero-variation baseline. This is conditional repeatability, not a general absence of model noise or a significance test.

At 1.50 under steady light, phase, time and supplied history change and a new action batch is applied. Light remains unchanged. Repetition does not remove that confounding, and the AI answers were generated before the fluid runs, without feedback from their evolving state. [Saved replay outputs](dining-replay-answers.csv) · [Reported comparisons](dining-repeat-counts.csv)

## Both signs can belong to a record

The memory decoder uses positive and negative marks as code symbols. A negative sign does not, by itself, identify unused capacity. An uncontrolled sign change in an occupied record can corrupt its content; it is not evidence of consuming spare storage. The completed hold experiment preserved the records while its saved states stayed below the static loss-of-well-stability threshold. Recovery after forcing a recorded mark to switch remains a different, unperformed test. The source audit's identity is recorded in [sources.json](sources.json).

## Speck crossings have not stabilized across grids

The adaptive-from-release runs use 201 paired starts per case and grid, all continuing to time 9.

| Case label | Grid 320: ever above 1 | Grid 384 | Grid 448 |
| --- | ---: | ---: | ---: |
| 7.52 | 201/201 | 201/201 | 30/201 |
| 7.67 | 148/201 | 130/201 | 27/201 |

This prevents treating crossing classification as a grid-independent flow property. It also prevents promoting the earlier figure's 320-before-448 ordering into an established continuum ordering. The recount does **not** prove that the earlier ordering is purely a numerical artifact, or reverse its recorded brackets. These adaptive runs and the earlier stepping protocol must remain identified separately.

A fraction of sampled trajectories is not the area or volume of the region above threshold. These paired starts share a simulated flow and are not independent experimental replicates. [All 1,206 trajectory summaries](speck-trajectories.csv)

## Current Navier–Stokes context

**Correction: the user's underlying system is unforced.** The breathing-on numerical branches add a prescribed intervention for those tests. They do not justify classifying the underlying HugandNavier formulation as externally forced. Internal coupling and state-dependent stress must be distinguished from an imposed body force. [Source and scope correction](../../comparisons/hug-navier-single-system-scope-correction.md#unforced-system-and-added-interventions)

OpenAI [published a forced-flow blow-up construction on 8 September 2026](https://openai.com/index/navier-stokes-solution/) with [Lean files](https://github.com/openai/NavierStokesAndEuler). Its statement is existential: specially constructed admissible initial data and forcing produce breakdown. That forced construction does not settle the user's unforced question.

The [Formal Conjectures catalogue](https://github.com/google-deepmind/formal-conjectures/blob/main/FormalConjectures/Millennium/NavierStokes.lean) currently labels the forced alternatives C/D solved and the unforced alternatives A/B open. Thomas Hou's [2 November commentary](https://www.siam.org/publications/siam-news/articles/openai-s-navier-stokes-construction-what-c-infty-forcing-changes/) discusses the proposed construction and explicitly does not independently verify it. This review confirms the publication and scope; it does not certify completion or absence of an independent review of the whole construction.

The earlier description of Hug as sharing the external construction's “forced” classification is withdrawn. Applying any theorem to the user's unforced formulation still requires matching its equations, domain, regularity and initial-data assumptions. The separate printed-estimate and formal-correspondence audits retain their own scope. The breathing intervention results remain valid descriptions of those experiments.

## Reproduce this recount

From this directory, run `python -B verify.py` with Python 3.11 or later. It checks the included source hashes, reconstructs the energy and work differences from all six saved tick accounts, matches the eight exchange rows, recounts the 1,206 trajectories and compares all 1,000 dining A/B pairs. The source files retain their bytes; this recount does not rebuild their simulation histories or regenerate their original prompts and model outputs.
