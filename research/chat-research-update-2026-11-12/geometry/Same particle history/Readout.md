> **Correction recorded 12 November 2026:** The complete same-history fluid pair is unproved. The later [checked progress and open obligations](../History%20proof%20completion/Readout.md) supersede the opening existence claim in this historical note. Its original argument and limited checks are retained below.

# Same particle history, different vortex-line closure

**Yes, as a mathematical existence construction.** Two flows can give A the same moving path and exactly the same paddle-wheel vector at every time from tagging at 1.178 to tick 41 at 1.2, while one vortex line closes and the other winds forever without an exact return or a zero-swirl endpoint.

The shared path in this new example is A(t) = (0,(t−1.2)/10,0). Its wheel points in the same direction in both flows and has the same time-dependent strength. At tick 41, it also matches the preceding example's vector (0,W,0). Both retain closest point A, distance 1/4 and winning arclength 0, with B at (0,0,1/4).

The alteration has zero value and zero first spatial derivatives at A throughout the evolution. That keeps the particle motion, actual swirl and local stretch history equal there. Away from A it changes how the vortex line winds: one closes, while the other gains an exactly chosen irrational displacement after each turn. Its swirl stays above W/4 along the whole line at tick 41. Both use the same unforced periodic Navier–Stokes equations, viscosity 0.015 and ordinary pressure; the two pressure fields are identical.

Consequently the ambiguity theorem still applies when the observation includes A's **whole history**, not just one saved reading. This establishes an information limit for that observation. It does not explain the saved Hug switch or reproduce the saved particle's actual trajectory.

**Verification boundary:** the full argument is written as an analytical existence proof, with an implicit parameter selection. Lean checks the local algebra, distance bound, conditional irrational nonreturn and history-observation corollary. The new parabolic existence and parameter-selection steps are not yet formalized, so this is not an end-to-end Lean-verified fluid pair. A separate numerical illustration agrees at two resolutions; finite numerical traces do not prove nonreturn.

![Numerical comparison of the matching histories and different lines](<$USER_HOME/Documents/Codex/2026-11-10/lo/outputs/Same particle history/Same history, different lines.png>)

[Full construction and proof](<$USER_HOME/Documents/Codex/2026-11-10/lo/outputs/Same particle history/Proof.md>) · [Exact scope of formal checks](<$USER_HOME/Documents/Codex/2026-11-10/lo/outputs/Same particle history/Formal core verification.json>) · [Numerical checks](<$USER_HOME/Documents/Codex/2026-11-10/lo/outputs/Same particle history/Numerical checks.json>)
