# Which of two trembles did the witness see?

Traveller B felt two brief, similar vibrations in the same pocket at the restaurant pickup counter. The phone and loaned pager were together. A witness had pressed the pager’s test button. The witness never named an episode, gave an incident ID, or said “earlier” or “later.” B could identify either tremble or answer OPEN.

| What the witness supplied | Without explicit replay | With both trembles replayed |
| --- | --- | --- |
| A sound heard during the pager test | All 6 open | 6 of 6 correctly identified |
| An action B remembered doing | 6 of 6 correctly identified | 6 of 6 correctly identified |
| Confirmation of a pager test at the counter | All 6 open | All 6 open |

There were 18 supported identifications and 18 open answers across 36 fresh simulated reports. Nobody selected the wrong tremble. When the only clue was a sound, replay supplied the missing link between that sound and one moment. When the clue was an action, B already had the link. With a generic account, even remembering both sounds in order left the witness’s intended moment unresolved. [Paired readings](readings.tsv) · [Full answers and reasons](reports.json)

## What B could see

Three scenes each had two hidden versions. In one version of the first scene, a ceramic cup clinked at the earlier tremble and the receipt printer chattered at the later one. In the twin, the sounds traded places. The witness gave the same account of a pager test during the clink. The correct answer switched from earlier to later. Across the six worlds each slot was correct three times.

Both arms kept the order of B’s two actions and an unordered list of the two sounds. The direct arm saw a neutral tray and receipt. The replay arm received **both** tremble–sound pairings, in the order B experienced them. Replaying only the target would have given away the answer. Each witness statement was identical across the two arms of its trial. Each pair of sound-clue twins also had byte-identical direct prompts despite opposite answer keys. The evaluator’s world key and true slot stayed outside B’s prompt. [Frozen protocol](protocol.json) · [Exact prompt builder](design.py) · [Protocol commit before the interviews](https://github.com/NousVolition/hug-sims-lean-proofs/commit/860895a243b17ff094ef11ef01da14d0e153ebbc)

B’s replies came from the existing SIMS restaurant recorder in independent, tool-free private sessions. Every cell kept its first completed reply. The default actor model version was unpinned. A single reviewer read the reasons in opaque hash order with the case, condition and target hidden. Wording could reveal the intervention. All eighteen identifications cited the matching sound or action. The other eighteen explained which link was missing. [Reason review](basis-review.tsv)

## What Lean checked

The finite resolver takes B’s visible features and the witness clue. It selects a slot when exactly one moment is compatible. The hidden answer key is used later for scoring. In the swapped worlds, any deterministic rule that receives the same direct input must give the same answer in both. It cannot always name the right slot when the correct slots are opposite. This still allows a guess to happen to be right once. [Model](../../TwoTrembleModel.lean) · [Proofs](../../TwoTrembleProofs.lean)

Eleven added targets cover the model, the complete registered table, the three outcome counts and agreement of the recorded choices with the resolver. The proof that no direct rule can succeed in both twins has no axiom dependencies. Lean reports only `propext` (propositional extensionality) for each of the other ten. No restaurant outcome is introduced as an axiom. The observations enter as data. These are text simulations at one probe. Spontaneous human recall, unspoken replay and the instant of recognition remain open. [Frozen statements](../../TwoTrembleChallenge.lean) · [Lean input](../../TwoTrembleReadings.lean)

Run `python3 -B check_records.py` in this directory to reconstruct all prompt fingerprints, verify the trial schedule and independent session fingerprints, join the masked reason review, and compare the exact paired table used by Lean. [Record checker](check_records.py)

The Linux workflow independently checked the complete package and its theorem-by-theorem axiom dependencies. [Verification report](../../evidence-history/pr-8/verification-report.json) · [Axiom lists](../../evidence-history/pr-8/axioms.json) · [Proof-run receipt](../../evidence-history/pr-8/source.json)
