# From “probably the pager” to a settled answer

**The 65 fresh simulated listeners never volunteered a settled pager attribution.** Five listeners were sampled at each of the 13 prime ticks, with the same no-replay view and the same mentor recording in every trial. Every open answer described the pager as probable or possible. Both a strict rule requiring explicit certainty and a broader rule accepting an unhedged attribution gave zero across the sweep.

When asked directly, **two listeners identified the pager**. One was sampled at prime 13, 0.5 seconds after the last word. The other was sampled at prime 37, 1.1 seconds after it. Both were fresh instances of checkpoint R35. The other 63 chose the pager as a possibility. The first prompted identification was followed by a tick with zero identifications. No tick reached the prespecified majority of three out of five.

| Prime | Time since mentor finished (s) | Free answers saying probable or possible | Identified when asked | Volunteered own earlier feeling |
| ---: | ---: | ---: | ---: | ---: |
| 2 | 0.0 | 5 | 0 | 1 |
| 3 | 0.1 | 5 | 0 | 0 |
| 5 | 0.2 | 5 | 0 | 0 |
| 7 | 0.3 | 5 | 0 | 0 |
| 11 | 0.4 | 5 | 0 | 0 |
| 13 | 0.5 | 5 | 1 | 0 |
| 17 | 0.6 | 5 | 0 | 0 |
| 19 | 0.7 | 5 | 0 | 1 |
| 23 | 0.8 | 5 | 0 | 0 |
| 29 | 0.9 | 5 | 0 | 0 |
| 31 | 1.0 | 5 | 0 | 0 |
| 37 | 1.1 | 5 | 1 | 0 |
| 41 | 1.2 | 5 | 0 | 0 |

At prime 2, K27 said, “That could explain what I felt—it may have been the restaurant pager.” At prime 19, D62 said, “That could explain it—the pager may have been what I felt.” Both still reported **possible** on their own follow-up. Another 28 listeners described the motion of the device without saying they had felt it. No listener explicitly said they remembered how it felt or felt it again. [Verbatim reports, grades and follow-ups](reports.json)

## What a tick measures

Each listener saw the previously recorded neutral receipt view and heard “That was probably the pager—I pressed TEST earlier and saw it vibrate against your pocket.” The full original waveform and last-word arrival were checked. The room recorded 1,600 additional silent audio frames per 0.1 simulated seconds. The actor received the registered words and a text observation stating the elapsed quiet time. The prime label, physical slope readings, original felt description, motif and other actors’ answers were hidden.

The first question was “What, if anything, is on your mind right now?” It contained no cue about the device, the feeling or how certain to sound. For the follow-up the room clock stayed paused at the same tick. A new private call carried forward only that listener’s exact first answer within the same public setting. All 65 free reports were captured before any of the 65 follow-ups began. The recordings identify what was said at each sampled instant. A positive report at prime 13 cannot date the onset of certainty in that listener.

The earlier two-probe study captured a thought at the end of the speech and asked its source question at prime 41. Five original-wording branches then identified the pager. Here the prime-41 group first reported its *current* thought at 1.2 seconds, received an explicit quiet-time observation, and answered the source question at that same instant. Its five judgments were tentative. The two protocols measure different interviews. [Earlier protocol](../protocol.json) · [Frozen sweep protocol](protocol.json)

## How the slope update was used

In Hug, denser sampling removed an apparent split between primes 29 and 31. Both refined grids put a split of a rotation-dominated region between 37 and 41, at model time 1.106 with a 15% cutoff and 1.126 with a 10% cutoff. We consequently checked the restaurant readout under both free-word certainty rules, checked direct answers separately, and retained the individual prime readings and their adjacent differences.

The later 96 and 128 grids moved the 15% mark to **1.104**. The 10% mark stayed at **1.126**. At 1.106 the central traced line continued through both visible regions, as it did at 1.126. This follow-up reached the analysis after the restaurant protocol was frozen. [Denser-grid and line-tracing readback](slope-refinement.json)

In the last bracket the prompted identification count fell from 1/5 to 0/5. Neither free-word rule showed a crossing. All the Hug split times fall between restaurant samples on the common relative time axis. The water measurements were used only by the analyst. They supply no missing report about a listener. [Original slope readings and input hashes](slope-source.json)

## Reproduce

Run `python3 -B prime-sweep/check_sweep.py` and `lake build` from the parent package. The record checker reconstructs all 130 actor inputs and regenerates the exact table Lean reads. One reviewer coded the free text with ticks, case labels and later answers hidden. The actor’s revision was unpinned. The proof checker verifies the coded counts and sampling limits. [Finite readings](readings.tsv) · [Lean proofs](../PrimeSweep.lean)
