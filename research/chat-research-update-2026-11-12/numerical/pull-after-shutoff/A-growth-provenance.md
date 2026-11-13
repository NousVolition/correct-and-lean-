# Why A grows after shutoff

The accumulator law comes from the Hug source recorded for this run. The particular positive utility input that keeps A growing here was added in the implementation.

The frozen corrected Hug extraction, paragraph 505, gives

    A(t) = integral from 0 to t of gamma [U(s) - Ubaseline] ds
    J(t) = kappa A(t)

The implementation chooses

    A_dot = 0.08 * [pulse(t) + 0.8 * (V(state) - V(initial))]

Here `social_source = 1`, `gamma = 0.08`, and `kappa = 1`. The prescribed pulse is zero from time 1 onward. Switching off squeeze and breathing at 1.2 does not switch off V or reset its baseline.

The implementation audit identifies rule B04, “Excess-input mapping and baseline,” as **implemented addition**. Its wording is:

> Excess U=pulse(t)+social_source*0.8*(U_social-U_social_initial). Baseline computed from initial social state with zero physical observations; gamma=0.08 and kappa=1 are chosen defaults. The accumulator form itself is registered; this U definition is not.

In the structural model used by this run, V is

    0.35 * remembered_outcome_score
    - 0.2 * mean squared expression-to-intent difference
    + 0.2 * mean reception score
    + 0.08 * mean tanh(field observation)

The reception score uses `tanh(margin / 0.4)`, with `margin` equal to the receiver's modeled acceptance radius minus the distance between the sender's expression and the receiver's norm. The field observation is itself `tanh(local C / 0.08)`, multiplied by `field_feedback = 1`. The baseline is fixed at the initial social state with zero physical observations; it is not reset at shutoff.

For breathing always off, the contributions to A_dot at time 12 are:

| Added utility component, relative to its initial value | Contribution to A_dot |
|---|---:|
| Reception margin | +0.009807107354 |
| Field observation | +0.003899362078 |
| Expression penalty | -0.001171286408 |
| Remembered outcomes | +0.000030275704 |
| **Total** | **+0.012565458729** |

At that time V = 0.162502722570, V(initial) = -0.033832570070, and their difference is 0.196335292640. The prescribed pulse contributes exactly zero. The other breathing arm gives almost identical contributions; both are recorded in `A-growth-audit.json`.

Thus the earlier continuation retained an added feedback input to A. It was not a test with all excess utility set to zero. If excess utility is set to zero, the Hug accumulator law gives A_dot = 0, leaving A at its existing value. Since J = kappa A, holding A constant still leaves a nonzero field source when A is nonzero.

A subsequent experiment applied that intervention from tick 41 (time 1.2), preserving the complete saved states and their accumulated A. Both histories reached time 12 with A exactly constant and energy still rising: from 0.0719362100021 to 0.164453288647 with breathing always off, and from 0.0719481134667 to 0.164475338445 with breathing previously on. RK4 steps 0.01 and 0.005 passed the declared comparison checks. This confirms that further accumulation of A after shutoff is not required for continued energy growth over this interval in the implementation. See `Zero utility run notes.md`, `Zero utility verification.json` and `Zero utility from tick 41.csv` for that separate experiment.

Verified sources in the sealed run:

- `engine/corpus_paragraphs.json`, paragraphs 505–506: accumulator and source law.
- `engine/inherited/inherited_inventory.json`, B04: provenance of the excess-input mapping.
- `engine/inherited/social_base.py`, lines 155 and 206: physical observations and continuing utility input.
- `engine/inherited/structural_hug.py`, lines 175–178 and 203–208: fixed initial baseline and actual utility definition.
- `engine/inherited/continuum.py`, lines 180–184, 212 and 233: prescribed pulse, field source and A derivative.

These files are under `$USER_HOME/Documents/Codex/2026-11-07/mathlib4-the-main-library-good-first/work/hug-v3-breathing/figure401-source/`. All five source hashes matched the run seal. Six saved states were inspected read-only, with file hashes and the utility/A-rate decomposition checked; no new trajectory was integrated. The original DOCX was not reopened: the source wording checked here is the frozen corrected Hug extraction used by the run.
