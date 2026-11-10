# Can a remembered action catch a reversed sound replay?

Reversing the supplied sound order led Traveller B to identify the wrong pocket tremble in **four of six** simulated worlds. B left the other two open. In one fork of each of those four mistakes, B remembered what they were doing *at the instant of the witnessed sound*. Three answers changed to the correct tremble. The fourth changed to OPEN and explicitly described the contradiction. In the other fork, simply remembering the same action and sound during the wait left all four wrong answers in place. [Paired transitions](readings.tsv) · [All 36 reports and reasons](reports.json)

| Sound replay | First report | After recalling the action at the sound | After recalling both without a timing link |
| --- | --- | --- | --- |
| Faithful | 5 correct, 1 open | 6 correct | 4 correct, 2 open |
| Reversed | 4 wrong, 2 open | 5 correct, 1 open | 4 wrong, 2 open |

Two of the five correct answers after a reversed replay came from initially open cases. The number of **corrected errors is 3 of 4**. In the sleeve case (F8), B first placed the steamer hiss at the later tremble. Recalling the hiss while rolling up a sleeve placed it at the earlier tremble. B answered OPEN and wrote, “I cannot resolve my conflicting recollections.” The three correct revisions cited the action timing without expressly identifying the clash. This measures what appeared in B’s report. [Case records](reports.json) · [Conflict coding](conflict-review.tsv)

## What changed between probes

The original six worlds contain an earlier and a later tremble, with the pager test equally often at either slot. We gave B a fresh faithful-order or reversed-order replay in each world. The actual events, ordered actions, sound inventory and truthful witness statement were fixed within the pair. Only the two sounds in the recollection traded places. B received no indication of reversal, incident ID or answer key. Across swapped worlds a reversed initial packet is byte-identical to its twin’s faithful packet, while the correct slot is opposite. [Earlier six-world design](../two-trembles/README.md) · [Preregistered protocol](protocol.json) · [Commit before the interviews](https://github.com/NousVolition/correct-and-lean-/commit/e399d747f9afbdd9b64a447965716089b6fdb147)

Each of the twelve first reports had two continuations. Both received the complete earlier prompt and that particular B’s verbatim first choice and reason. Both then named the same action and the same sound. Only the linked recollection placed the sound during the action. The control deliberately named the action from the correct slot too, so its mere mention was equally available. Someone given the evaluator’s selection rule could use that fact. B received no such rule. B was asked again which tremble the witness meant, with no instruction to change the first answer or to prefer one memory. These were fresh private SIMS text sessions with an explicit transcript handoff. The default actor model version was unpinned. [Exact packet builder](study.py)

The faithful-order arm was rerun here. Its first reports included five correct choices and one open answer. The earlier study recorded six correct choices with replay and explicitly described that replay as being in its original order. Here neither arm received an assurance about the order. The difference between the two runs has no established cause.

One reviewer coded each of the 24 follow-up explanations in opaque hash order with the arm, evaluator’s target and parent answer hidden. The words themselves could reveal the condition. Explicit noticing required the reason to recognize incompatible episode timings. A change of choice alone did not earn that code. One explanation met the criterion. Unspoken recognition, spontaneous recall and how people would respond remain unmeasured. [Review rule](protocol.json) · [Review codes](conflict-review.tsv)

## What Lean established

The finite resolver receives the replayed sounds and the witness’s sound clue. With two distinct sounds in reversed order, it points to the opposite slot. An accurate action–sound link then points to the true slot. The two candidates disagree. A rule that withholds judgment on conflict returns OPEN. A rule that gives priority to the accurate action returns the correct slot. Co-mentioning the features supplies no new timing relation. [Model](../../ReplayAuditModel.lean) · [Proofs](../../ReplayAuditProofs.lean)

The same visible conflict can also occur in a world with a faithful sound replay and a mistaken action link. The proof that no fixed rule can always choose the reliable source from these identical visible inputs uses no axioms. Thirteen other new statements use only `propext`. Lean checked the case schedule, original targets, observed first choices, both follow-ups, transitions from initially wrong answers, and the supplied coding of explicit notices. Five reversed, linked reports agreed with action priority and one with withholding on conflict. This comparison leaves B’s internal decision process open. [Frozen statements](../../ReplayAuditChallenge.lean) · [Lean data and policy comparison](../../ReplayAuditReadings.lean)

Run `python3 -B check_records.py` here to reconstruct the initial and continuation prompts, check the transcript and parent fingerprints, verify the conflict-code join, and check the exact table consumed by Lean. [Record checker](check_records.py)

The Linux workflow independently checked the package and the axiom list for each configured theorem. [Verification report](../../verification-report.json) · [Axiom lists](../../evidence-linux/axioms.json) · [Proof-run receipt](../../evidence-linux/source.json)
