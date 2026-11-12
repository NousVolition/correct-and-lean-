# Credits

## Corrected Yang–Mills attribution (12 November 2026)

The supplied attribution correction distinguishes three sources: `curve` and `readJet` were copied from the upstream source identified in `YangMillsInstance.lean`; the instance file was **NousVolition’s draft, compiled by Codex**; and `YangMillsCueTest.lean` labels its added transverse coefficient as **“an explicit test choice.”** The earlier assistant's field-equation proof credit remains intact. The original Lean files and their verification logs are unchanged.

The [combined transverse-derivative theorem](../combined-yang-mills-lean/README.md) is a separate result by Codex (OpenAI), directed by NousVolition, with its own local compilation and axiom evidence.

## Retained earlier contributions

Ideas, authorship of the underlying approach, and direction: **NousVolition**.

**Independent review and reruns by Claude (Anthropic), an AI model, directed by NousVolition. Claude did not compile or run any Lean.**

The following account is supplied by the user from Claude's attribution statement; this session has not independently repeated those numerical audits:

- Reran and audited the Tick 41 Yang–Mills check, and reproduced the threshold-1 run from time 0 to frame 600 against the saved frames.
- Checked the Ambiguity theorem checks package: hashes, before/after evidence, exported Lean strings, decoded events, and 24 return records.
- Recounted the saved-data claims in `SIMSLatentReadout.lean` outside Lean.
- Drafted its rational restatement. Two proof steps failed to compile and were corrected in another session; credit for the compiled version is shared with that session.
- Drafted `Tick41Instance.lean` and `Pair25Instance.lean`; those drafting credits are retained. The attribution of `YangMillsInstance.lean` is corrected above to NousVolition’s draft, compiled by Codex.

This Codex (OpenAI) session, directed by NousVolition, performed the compilation and axiom checks recorded in the accompanying verification logs. Those checks are separate from Claude's drafting and review credit. The checked files and their precise changes are described in `README.md`.

The compiled proofs in the earlier Ambiguity theorem checks package were written and run by another assistant; they are not attributed to Claude. This session does not claim authorship of those proofs or of NousVolition's ideas.

The project's attribution convention remains: **“AI-generated; dictated and directed by NousVolition.”**

For the added field-equation comparison, this Codex session copied `YangMillsCueTest.lean`, `TwoMemoryTransport.lean`, `TwoMemory.lean`, and `Volterra.lean` unchanged from the earlier Ambiguity theorem checks package. Their proof authorship remains with the earlier assistant, directed by NousVolition. This session's contribution is fresh compilation, package integration, and the added `YangMillsCueAxioms.lean` audit; it does not transfer that authorship to Claude or to this session.
