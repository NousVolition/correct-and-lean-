# Scope correction: HugandNavier is the user's single intended system

The user's current correction is: “its in there and i told you yesterday, its the same thing as the navier stokes.” An earlier message in the same chat states “it has to be in tandem with the navier stokes” (turn `01a19499-5e7f-7523-94bd-d012e93ce393`, chat `01a185c4-9743-7872-829c-7168b91c2532`). Those messages were freshly retrieved with the chat reader. The exact calendar meaning of “yesterday” was not needed to identify the instruction.

The interpretation to preserve is **one intended HugandNavier system**. Hug must first be traced within the user's continuum formulation. Do not assume an additional mechanical object alongside a fluid, and do not require an independently invented fluid/body interface merely because a reduced eight-state implementation was selected in an earlier audit.

The inspected `reports/interaction-equation.md` explicitly states that all fields use one carrier velocity and gives the loop: flow and participant states → directed guards → interaction and stress → later flow and states. The guards belong to relationships inside the evolution. This is direct source support for examining the existing single-field feedback structure. The particular reduced eight-state Hug implementation has its own scope and additional modeling choices; preserving its code does not by itself establish that it is the user's intended full source model.

## Meaning to preserve across implementations

These words were already supplied in the working conversation and must remain available when interpreting a new analogy or implementation:

| User's words | Meaning to carry forward |
| --- | --- |
| “its the loop, the carrying is fixed” | Follow the continuing carrying relationship while configurations change. “Fixed” does not mean every position, shape or internal value stays constant. |
| “this is navier stokes” | Examine Hug within the intended shared evolution. Do not silently substitute a separate mechanical object attached to another fluid system. |
| “mine is unforced” | Preserve the unforced underlying formulation as the target. Identify added drives in individual experiments by their own equations and settings. |
| “the hug is only a way gravity can exist here” | The hug gives gravity a role within the user's setup. Preserve that conceptual role without replacing it with an imposed actuator or claiming that a particular generated force law is its definition. |

The connected-strand description supplies the same continuity: one path can take different shapes while remaining connected. A finite viewing window may stop before that continuation is visible. A selected nearest point, displayed gap or changing configuration does not by itself define the whole relationship.

The seed and hold discussion introduces a further distinction: a thing can remain carried while a selected state is held. The hold or release rule has to be identified in the model that implements it. A later visible effect does not by itself identify when its underlying record began. These connections should be developed from the user's existing distinctions rather than treated as requests to invent a new mechanism each time.

This section records the intended meaning; verified results retain their own scope. Further work should retrieve this explanation, trace a particular equation or result back to it, and identify a concrete unresolved mapping. Do not ask the user to repeat an established definition when the record already supplies it.

## Correction to the previous conclusions

The prior 14-claim bridge and 7-claim audit imposed a comparison between that reduced Hug implementation and a separately represented field problem. Their requirements for a reciprocal load/interface and a state-to-field conversion belong to that chosen construction. They do **not** establish that the user's intended single continuum system lacks those connections.

The mathematical propositions already checked remain propositions about their stated definitions and hypotheses. Their compiler and Comparator records are preserved. Their success does not establish source fidelity or a full evolution theorem for the user's intended system. No claim is made here that the eight-state ODE and the spatial PDE are mathematically identical, or that an unproved full-system theorem has become proved through this interpretation correction.

## Continuing the verification

### Unforced system and added interventions

On 11 November 2026, the user corrected the classification directly: **“mine is unforced.”** Preserve the unforced underlying system as the target. The prescribed breathing force added in some numerical experiments is an intervention in those branches, not grounds to classify the entire formulation as externally forced.

The distinction is visible in the [single-continuum field equations](../../lean/hug-navier-single-system-lean/FullModel.lean): the two momentum components of `fieldRates` contain advection, pressure and internal stress divergence, with no separately prescribed body-force term. Optional `sourceA` and `sourceB` pulses enter the participant-state equations; the no-pulse branch sets both to zero. The separately preserved [A/S branch](../../lean/hug-navier-single-system-lean/OriginalAS.lean) has its own scalar-dependent momentum term and source options, which must be classified from that branch's equations rather than transferred to every version.

Internal stress and coupling are not, merely by being written as force terms, an externally imposed drive. This corrects the classification; it does not establish that a provisional coupled, variable-viscosity field realization is identical to the classical three-dimensional constant-viscosity Navier–Stokes problem. The external forced-flow construction does not answer the user's unforced question.

Use the exact original corpus and the user's clarification to identify Hug's representation within one velocity/pressure/state evolution. Trace any guard/stress extension to its actual source and retain its provisional status. Keep the original A/S field branch, the later optional guard-field branch and reduced implementations distinguishable; do not substitute a convenient implementation for the source without establishing the correspondence.

The full single-system evolution proof remains open. Reassess its actual mathematical assumptions and proof obligations from that equation set, rather than carrying over the two-system interface requirements. No equations, numerical settings, old proof files or prior evidence archives were changed in this correction. No new Lean result is claimed.
