# Does it leave with what it came with?

**We already tested this through three connected studies.** We followed identities, complete shared records, nearby material labels and the origins of model context. The results include both preservation and change. The remaining question about *everything* does not erase what these tests established.

![Map of the three completed retention studies: shared records remain unchanged, identities cross a viewing boundary, and the local context changes origin.](retention-map.svg)

[Open the scalable diagram](retention-map.svg) · [Figure source](draw_retention_map.py)

## Four things that can stay the same

| What is compared? | What the completed tests found |
| --- | --- |
| **Identity** | 540 and 872 remain identifiable across the original pair's viewing boundary. Their labels are not complete cargo lists. |
| **Decoded record** | The three original shared event records remain byte-for-byte unchanged at the recorded samples. The material storing them evolves. These are shared system records, not private inventories assigned to A, B, 540 or 872. |
| **Origin** | In the finest run, 44.65% of pair 25's starting local context remains inside its moving observation window at time 1.3; 55.35% is elsewhere in the modeled domain. |
| **Amount** | That window's local context total reaches 100.46% of its starting amount. A nearly unchanged total can contain a changed mix. |

The three studies use the historical **threshold-0.015**, breathing-on configuration, from the saved **after-write tick-41 state at time 1.2 through time 1.3**. They compare 40³/step 0.0005, 48³/step 0.0005 and 48³/step 0.00025. This interval does not reconstruct the missing incoming inventory at time 1.1. The added-drive experiment preserves its actual settings; it does not redefine the author's [intended unforced system](../../comparisons/hug-navier-single-system-scope-correction.md#meaning-to-preserve-across-implementations).

## The studies we already ran

| Study | Numerical finding | Separate historical Lean checks |
| --- | --- | --- |
| [Pair 25: retention](../pair-retention-study/README.md) | Three shared records survive in 459 complete payload comparisons while local readings change. Splitting a readout integral at cell crossings resolves the original accounting failure without changing the trajectory or sampled values; the failed receipt is preserved. | [40 targets](../pair-retention-lean/README.md): finite record rules, full recorded bytes and exact decimal accounts, including the original failure and corrected result. |
| [Pair 25: origins](../pair-origin-study/README.md) | The primary window keeps the same 133 material and 276 other observer labels at every recorded step, while context changes origin. In the wider view, 540 leaves and 872 arrives: 364 labels initially, briefly 365, then 364 with different membership. | [77 targets](../pair-origin-lean/README.md): finite classifications, recorded memberships, field-change numbers, shared bytes and context accounts. |
| [Following 540 and 872](../observer-follow-study/README.md) | At time 1.3, 43.94% of the context initially near 540 remains nearby; for 872, 42.95%. Each retains its eight starting nearby material labels at recorded steps; other observer labels arrive. | [134 targets](../observer-follow-lean/README.md): finite identity/overlap rules, recorded crossing brackets, neighbor histories, context accounts and shared bytes. |

The primary pair window is the union of two radius-0.075 spheres. The 364-to-364 example uses the wider radius-0.10 union. The follow-up uses a separate radius-0.075 window around each of 540 and 872. Their local views overlap: their accounts cannot be added as disjoint holdings, and no transfer from 540 to 872 was established.

## Follow the origin as well as the total

For pair 25's primary window in the 48³/step-0.00025 run at time 1.3:

| Contribution | Percentage of the amount initially inside at time 1.2 |
| --- | ---: |
| Starting origin still inside | 44.653936% |
| Starting origin elsewhere in the domain | 55.346064% |
| Outside origin now inside | 47.155486% |
| Later source now inside | 8.649760% |
| Current local total | 100.459181% |

Only the three **now-inside** contributions make up the current local total: 44.65% + 47.16% + 8.65%, subject to rounding. The 55.35% elsewhere belongs to the starting-origin account, not another current-inside term. [Source table and sensitivity comparisons](../pair-origin-study/README.md#the-context-total-hides-changing-origins).

**Context C is a model scalar, not water mass or a molecular inventory.** These origin fractions depend on the window and grid. Differences are larger earlier in the interval than at its endpoint; no continuum-convergence tolerance was established for these origin shares.

## Leaving a view is not leaving the system

> “If we can’t see where it comes from or continues, we can mistake the edge of our view for an edge in the connection. The first visible space then gets treated as the important gap before we’ve followed the whole path.”
>
> — NousVolition, framing the observation-window question

The windows are observation boundaries, not walls, owned parcels or physical loss mechanisms. “Elsewhere” still means in the modeled domain. Crossing a viewing boundary does not by itself establish destruction or escape, and confinement does not force a path to close into a loop.

## What the evidence establishes

**Simulation and numerical recounts:** saved trajectories, memberships, shared records and passive context-origin fields support the reported finite observations. The published studies describe which large trajectories and grids remain local. Sparse labels and sampled steps do not supply every physical content or continuous-time behavior.

**Lean:** the three packages check their stated finite rules and supplied recorded numbers, memberships and bytes. They do not prove the fluid evolution, numerical interpolation, complete physical retention or continuum convergence. The [threshold-1 heat and record-bit studies](../heat-grid-study/README.md) are a separate branch of evidence.

This map introduces no new simulation or theorem. Its source review at [revision ed5858a2](https://github.com/NousVolition/hug-sims-lean-proofs/commit/ed5858a2ec131dde467e97c50559e3a14733a762) confirmed that all 86 listed proof-input files match the historical successful run revisions; fingerprints and target lists match the preserved local receipts. The historical GitHub evidence is linked below. This documentation review did not rerun the fluid solver or recompile those Lean packages.

| Package | Published receipt | Historical successful GitHub run |
| --- | --- | --- |
| Retention, 40 targets | [Receipt](../pair-retention-study/github-lean-receipt.json) | [43160534955](https://github.com/NousVolition/hug-sims-lean-proofs/actions/runs/43160534955) |
| Origins, 77 targets | [Receipt](../pair-origin-study/github-lean-receipt.json) | [43166728112](https://github.com/NousVolition/hug-sims-lean-proofs/actions/runs/43166728112) |
| Following 540/872, 134 targets | [Receipt](../observer-follow-study/github-lean-receipt.json) | [43173911878](https://github.com/NousVolition/hug-sims-lean-proofs/actions/runs/43173911878) |

**AI-generated; dictated and directed by NousVolition.** The diagram summarizes recorded numerical results; it is not an image-generated simulation.
