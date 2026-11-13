# Configuration and history in the saved Hug notes

**A concrete storage candidate was found and its directional configuration-to-energy connection was proved: the material deformation F and retained structural records m determine a stored-energy function W. The saved notes explicitly identify that constitutive law as an added material model. It accounts for elastic work and the cost of changing records, while leaving the original A/S coupling power in the total-energy balance. A physical identification of the missing A/S reservoir remains unproved.**

No original notes, source equations, earlier proof files, or historical simulations were edited. This package contains source copies, new derivations, and verification receipts. The source search and the proof have different scopes, described below.

## What the source search found

The latest retained meaning remains authoritative: Hug belongs to one intended unforced continuum, the carrying relationship continues while configuration changes, and the author's gravity description is retained. Historical notes that proposed different interpretations are evidence about those stages, not instructions to redefine the author's meaning.

| Candidate in the saved material | What is actually specified | Connection to the missing energy |
|---|---|---|
| Original A/S accumulator | A integrates excess input; J=κA drives scalar transport. | A has no supplied physical stored-energy conversion or reciprocal work law. |
| Earlier Hug geometry | Mirrored arms, reciprocal axis scales and a prescribed holding/release schedule. | Geometric information is explicit; force and stored energy are absent from that prototype. |
| Earlier pressure imprint | A relaxing imprint controls shape and an opening latch under imposed pressure. | Historical prescribed-response experiment; it does not supply the selected unforced A/S energy law. |
| Structural material notes | F carries deformation; material-attached m records extending/shortening history; W(F,m) is explicit. | A real mathematical stored-energy candidate, connected to elastic stress and writing power. It is labelled ADDED relative to the original source. |
| Later expression history | Retained m plus recent-expression z determine b=c_f m+(1-c_f)z and W(F,b). | Different timing can change response; expression release is accounted as heat. The original coupling power still remains. |
| Holding potential Φ_H | A historical proposal adds a conservative holding force and potential energy. | Explicitly labelled ADDED and historically superseded; it cannot be treated as a hidden consequence of the unchanged A/S equations. |
| Continuing carrying relationship | The author's relationship persists while shape/configuration changes. | Preserved as meaning; the inspected notes do not turn that continuity alone into the required work identity. |

The most useful discovery is in [STRUCTURAL_MEMORY.md](sources/STRUCTURAL_MEMORY.md), sections 3–5. The energy is

\[
W(F,m)=\frac{G_0}{2}(\operatorname{tr}(FF^T)-3)
+\frac12\sum_{k,s}G_{k,s}\bigl(1-e^{-m_{k,s}/m_*}\bigr)e_k^2.
\]

The records are carried with the material. They change its later response. At the undeformed configuration, W and the elastic stress can vanish even while m remains nonzero. The notes explicitly distinguish retained structure from energy that must stay trapped indefinitely. This is why finding a persistent memory variable alone does not identify a source of continuing mechanical work.

The later [COUPLED_FIELD.md](sources/COUPLED_FIELD.md), sections 4–6, separately introduces recent expression z and a combination b. That distinction is preserved; the single-channel derivative theorem applies to whichever scalar enters the stated energy, while the release term is accounted for separately. No chronology or variable is silently merged into the original A/S model.

## The connection now checked in Lean

For one existing directional term, define exactly as in the material notes

\[
f(m)=1-e^{-m/m_*},\qquad
W_r=\frac G2 f(m)e^2,\qquad
Y=\frac{G}{2m_*}e^{-m/m_*}e^2.
\]

With a fixed reference direction a, the notes use

\[
d=Fa,\quad \dot F=LF,\quad L=\nabla u,\quad
e=(|d|^2-1)/2.
\]

`MaterialConfiguration.configuration_record_energy_balance` proves, from these derivative hypotheses,

\[
\boxed{\dot W_r=\tau_r:L+Y\dot m},\qquad
\tau_r=Gf(m)e\,d\otimes d.
\]

The proof derives the material-direction derivative and strain derivative; it also verifies that the symmetric velocity gradient gives the same directional strain rate. Thus the stress-work term is linked to the actual configuration definition, rather than being asserted by the name of an energy variable. This checks each directional history-energy term. It is not a proof of the complete immersed PDE, the base neo-Hookean term, a physical clay calibration, or a correspondence theorem for floating-point Python.

`RecordEnergyConnection.lean` also checks:

- Unstrained energy, stress and the record-energy conjugate vanish for every record value.
- The change in later stress is exactly proportional to the difference in expressed records at the same strain.
- The conjugate Y is nonnegative under the source parameter signs.
- The stated writing limiter allocates at most η times the available viscous power; zero viscous power gives zero allocated writing.
- Fixed strain and fixed records give zero directional stored-energy rate.

These are statements about the already written material candidate. The original `OriginalAS.rates` file is unchanged and has no added F or m variables or elastic stress.

## Why the missing A/S transfer remains

The later notes already contain the combined budget. In rate notation, let Q be viscous power, T be elastic stress work, B be allocated writing power, R be expression-release power, and P_AS be the original coupling power. Their stated transfers have the form

\[
\dot E_K=-Q-T+P_{AS},\qquad
\dot W=T+B-R,\qquad
\dot H=Q-B+R.
\]

Lean proves the cancellation of these transfers:

\[
\boxed{\frac{d}{dt}(E_K+W+H)=P_{AS}.}
\]

This is `material_total_residual`; its derivative balances are explicit assumptions taken from the saved notes, not a newly proved spatial-solver theorem. `material_conservation_iff_zero_source_power` states the corresponding zero-rate condition. The added material energy accounts for elastic stress work and restructuring. It does not provide the opposite of the original A/S coupling work.

The same residual is written explicitly in `COUPLED_FIELD.md` section 6. That historical implementation places it in a signed supply ledger and says its physical source is unknown. Its ledger label does not classify the author's intended continuum as externally driven; it records that this implementation left the energy source unidentified. Calling that ledger internal instead would still require the physical energy representation and transfer law.

The earlier exact A/S counterexample remains applicable within its stated scope. It has uniform translating velocity, hence zero velocity gradient, while A and S stay fixed. The structural strain-rate and writing laws inspected here also have zero driving rate in that situation. Rigid translation history or another configuration variable could matter for a different justified energy representation, but the inspected deformation/record law does not automatically supply one. No new potential or force was introduced to repair this.

## Evidence and boundaries of the search

- The preserved corrected Word source was freshly read as OOXML. All **638 paragraphs** exactly match the previously retained extraction; its SHA-256 remains `01f9ab0942f9c88982863e2ffc1e3c495786b5e6b67a26ae77d18235e7058acf`. It contains no embedded equation objects or media. Relevant original passages are saved in [corpus-passages.json](sources/corpus-passages.json).
- The three-page preserved original framework PDF was read as text. It supplies the social/boundary schema, rather than a material-energy law. No rendered-layout or image interpretation is claimed.
- Saved field-specification notes, their decision register, source register, and `structural_memory.py` were read directly and copied with hashes. In particular, the SOURCE, INTENT and ADDED distinctions in those files were retained.
- The early Hug geometry and pressure-memory code were read through the GitHub connector at the pinned historical commit `b20d1dcf25fb7e97bcceb9a09d0883d30bf08e8c`. See [the historical source directory](https://github.com/NousVolition/My-Sources-Project-ALL/tree/b20d1dcf25fb7e97bcceb9a09d0883d30bf08e8c/reports/hug-dynamics/source) and the local copies with [provenance](sources/github-source-provenance.json). This is not a latest-branch check.
- The retained meaning correction was read; a targeted prior-chat read supplied source pointers. No exhaustive review of all chats was performed.
- Historical Miro surveys are described by the source notes, including unsupported items. The live board and all embedded images were not freshly inspected in this task. No claim is made that the author's broader notes cannot contain another relevant law.

The fresh result is a verified connection for the already specified material storage candidate and an explicit remaining A/S power term. Establishing the requested physical total-energy connection still requires a source-supported configuration/history energy whose rate is **−P_AS**. That requirement has not been found or proved for the unchanged original A/S equations in this scoped review.

## Rebuild and proof receipt

`verification.json` records successful checks and their limits. The five unchanged original energy-source modules reuse hash-matched compiled objects and earlier receipts. The two new proof modules and their axiom audit are compiled in this task with native Lean 4.34.0-rc2 and the pinned Mathlib cache. The new proofs contain no unfinished holes; the axiom audit checks for `sorryAx`.

```powershell
./build-native.ps1 -ToolchainBin '<Lean bin directory>' -DependencyRoot '<directory containing Mathlib and its dependencies>'
```

A fresh dependency download, independent external kernel, full solver rerun and physical calibration were not performed. Earlier equation files and packages remain intact.
