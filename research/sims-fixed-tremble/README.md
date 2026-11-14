# Same tremble, later mentor evidence, and replay

AI-generated; dictated and directed by NousVolition.

**In this 18-listener pilot, the timing link changed reported certainty; showing
the original description again did not change the direct outcome.** All six
timing-linked listeners identified the pager, including three who received no
supplied replay. Vague testimony left six listeners at POSSIBLE; withdrawing
the timing link left six at OPEN.

| Later mentor evidence | No second presentation | Description shown again |
| --- | --- | --- |
| Original vague testimony repeated | 0/3 settled; 3/3 POSSIBLE | 0/3 settled; 3/3 POSSIBLE |
| Test tied to the original moment | 3/3 IDENTIFIED | 3/3 IDENTIFIED |
| Earlier timing link withdrawn | 0/3 settled; 3/3 OPEN | 0/3 settled; 3/3 OPEN |

These are the first direct judgments after the later mentor reply. Every
judgment retained its condition's classification at primes 23 and 41.
“Identified” is the listener's declared state, not an independent check of the
mentor or the actual device.

## Did B return to the feeling?

Five of the six timing-linked listeners mentioned their own feeling in their
first open thought after the mentor spoke. One no-replay listener instead said:

> That clears it up for me—it was the pager’s test vibration. I’m back to waiting for my food.

That listener, `r3-linked-direct`, made no personal-feeling reference in any
of its seven baseline/outcome answers. It then reported IDENTIFIED when asked
about the cause. Its final retrospective answer was NO:

> I relied on their clarification about pressing TEST and seeing the pager vibrate. I didn’t mentally return to how the tremble felt.

None of the 126 baseline/outcome answers explicitly reported re-experiencing
the sensation. All 18 later answered NO to the recollection question, including
listeners shown the description again. Those answers do not expose hidden
cognition. A supplied cue, a mention of a feeling, an inward return, and a claim
of certainty remain separate.

Strict grading found three explicit pager-certainty statements in the first
open thoughts, one bare explanation, one tentative “fairly sure,” and one
settled-sounding answer that left the device implicit. The two borderline
readings and exact sentences are retained in [review.json](review.json).
They do not alter the six literal IDENTIFIED judgments.

## What was controlled

Each fresh B received the identical original K27 scene, profile, headline,
phone display, and sensory description once. Each remained in one conversation
for all eight turns. After 15 scripted quiet seconds, three frozen mentor
evidence conditions were crossed with a second presentation or no second
presentation of the saved description, with three listeners per cell.

The replay arm was shown the original words again before the later mentor
sentence. Neither arm was instructed to relive or suppress the feeling.
An open question preceded each source question. Only after all outcomes was
B asked about inward recollection.

Primes 2, 23, and 41 label 0, 0.8, and 1.2 simulated seconds after the latest
mentor reply ended. Speech and replay-reading durations were unmeasured.
Wall generation time is separate in each receipt. The experiment does not
identify an exact recognition instant or measure a natural 15-second delay.

The protocol and generator were committed publicly
[before sampling](https://github.com/NousVolition/hug-sims-lean-proofs/commit/672c2738ae1bdb575f370a5bc6ea46dfabaa0063).
The signed-in actor reported model `gpt-6-astra`; its underlying revision and
sampling seed were not pinned. Three repeats per cell support the stated
descriptive finding, not a population estimate or a general psychological law.

## What Lean checks

[Evidence.lean](Evidence.lean) checks eleven general or explicitly modeled
statements. A deterministic replay preserves an ambiguity already present in
the record; accurate event-linking evidence can identify the cause without a
replay in the stated two-cause model. Identical visible reports can accompany
different hidden-return flags, so the transcript alone does not decide inward
recollection. The fixed reference can persist across distinct ordered times.

[Recorded.lean](Recorded.lean) checks sixteen finite statements about the
generated records: 144 turns, eighteen equal initial-input hashes, three
listeners per cell, exact selected clocks, all direct outcomes and their
persistence, the no-replay counterexamples, the first-thought example, the
feeling-mention count, and the eighteen retrospective denials.

The recorded result refutes **“every settled report in these trials requires
a supplied replay.”** It does not prove **“B performed no internal recall”** or
**“humans never need to return to a feeling.”** Text interpretation, model
generation, accurate testimony, and the psychological meaning of “know” are
outside the Lean kernel's checks.

Run from this directory with the pinned Lean toolchain:

```text
python3 -B check_records.py
python3 -B verify.py --work-dir /tmp/fixed-tremble-check
```

Use a fresh verification directory. The checker reconstructs all inputs,
requires eighteen distinct sessions and 144 distinct ordered turns, checks
the review excerpts and clocks, and rejects eight corrupted-record fixtures.
Native elaboration, Lake build, and every theorem's axiom dependencies are
checked. No `sorry`, custom axiom, or `native_decide` is used.

[Protocol](protocol.json) · [All actual replies](reports.json) ·
[Grades](grades.json) · [Results](results.json) · [Sources and translation](SOURCES.md)
