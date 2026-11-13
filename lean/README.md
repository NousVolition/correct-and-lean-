# Lean package index

These packages retain their own model definitions, assumptions and verification histories. **Fresh GitHub recheck: 12 November 2026.** All 19 core packages passed Comparator, Lean-kernel, nanoda, Lake and configured axiom checks. [Fresh results, logs and source fingerprints](../provenance/core-package-recheck-2026-11-12/README.md).

The fresh reports below preserve the original theorem scopes and unfinished-proof lists. Earlier reports remain linked separately. The 306 configured declarations overlap across packages and must not be added as independent discoveries.

Newer standalone results are described below: [observation and field-equation checks](#separate-observation-and-field-equation-checks), [Pair-25 origins](#separate-finite-origin-checks), [540/872 histories](#following-540-and-872), and [heat from writing](#heat-from-writing).

[Read the walkthrough](#plain-language-walkthrough) · [Open the detailed package records](#detailed-package-records)

## Plain-language walkthrough

In [the Pair 25 example](../research/hug-v3/pair-origin-study/README.md), the window begins and ends with 364 labels, although 540 leaves and 872 arrives. **The same count does not mean the same membership.** This leads to a precise question: what can an observation determine?

A [separate Lean proof](../research/ambiguous-observation-lean/Pair25Instance.lean) shows that the count alone cannot always recover either label’s membership in the supplied summaries. That proof does not verify the simulator, positions or transcription.

The **19 core packages below explore the wider project’s model questions**: what follows from the rules, whether evolution exists and is unique, and how memory writes and delays behave. Pair 25’s summary and recorded-data checks are separate from this core list. Each entry distinguishes **Proved** from **Unfinished**.

Read **PASS** as: “the precise statements submitted for this package passed the checks, under their stated assumptions.” A package can have passing component proofs while its larger goal remains unfinished. The fresh run covered all 19 packages; its 306 checked declarations overlap across packages.

The **first three packages concern the seven-variable A/S model**. In its interpretation, Smoke and Clay are one agent’s inward speaking and listening positions.

We start here because this smaller model separates three questions that recur later: **what follows from the rules, does a unique evolution exist, and which bounds persist?** Packages 1–3 address them in that order. Pair 25 introduces what observations can reveal; A/S introduces what can be proved about evolution under stated assumptions. The A/S results concern their own equations and do not verify the Pair 25 simulation.

1. **[as-lean](as-lean/) — The basic rules.**

   **Proved:** 30 consequences of the equations, including bounds on opening and reception, how an encounter updates understanding, and how adverse history affects exchange.

   **Unfinished:** Comparing suppression across complete evolving histories, and constructing the full repeated-encounter process. Some earlier gaps are addressed by the next two packages.

2. **[as-existence-lean](as-existence-lean/) — The model has a definite evolution.**

   **Proved:** Under the original assumptions, a solution exists and is unique over any chosen finite period. “Unique” means the same specified starting data and inputs determine the same evolution.

   **Unfinished:** The suppression comparison and repeated-encounter process. This also does not certify numerical solver errors or the social interpretation.

3. **[as-invariance-lean](as-invariance-lean/) — Certain quantities stay within their allowed ranges.**

   **Proved:** Both meaning variables remain between 0 and 1, and both adverse-history loads remain nonnegative, under the original assumptions.

   **Unfinished:** The broader comparisons and encounter process above. Staying within bounds does not establish that understanding improves.

The **next two concern particular reduced Hug models**.

After A/S, we ask the same questions in models involving pressure, shape, guards and energy: **which component rules hold, and can a specified model evolve uniquely while keeping its guards within bounds?** Package 4 checks particular properties and limitations; package 5 answers the evolution question for the specified eight-variable model. These packages have their own equations and assumptions. The full unforced continuum and separate memory-field evolution remain unfinished; the spatial questions follow in packages 6–9.

4. **[hug-squeeze-lean](hug-squeeze-lean/) — Pressure, shape, guards and energy.**

   **Proved:** 51 specified properties, including pressure-response formulas, retention, reversible geometric transformations, guard bounds and energy accounting. It also proves limitations: a numerical “connected” flag can allow a small gap, and the active model can gain energy.

   **Energy-chart connection:** The supplied chart, “Where the extra driving work goes”, illustrates **extra work = extra dissipated energy + stored-energy difference**. At `t = 2`, its labels show about 15 extra units of work, split into 13.5 dissipated and 1.5 stored. More work need not remain as stored energy.

   The [checked energy results](hug-squeeze-lean/ActiveHugSolution.lean#L51) establish an exact energy balance and nonnegative losses for this package’s reduced active Hug model, under their stated assumptions; active power can exceed those losses. **The chart’s curves and numbers have not been verified against these equations or by Lean.**

   **Unfinished:** The full separate memory-field evolution, long-term synchronization and recovery claims. The next package supplies an existence result for a particular reduced model.

5. **[hug-existence-lean](hug-existence-lean/) — The reduced eight-variable Hug model can evolve consistently.**

   **Proved:** Existence, uniqueness and preservation of the allowed guard ranges over any finite forward period, with the specified fixed parameters, continuous prescribed force and admissible initial guards.

   **Unfinished:** The separate memory-field extension and broader long-term claims. This result belongs to that reduced implementation; NousVolition’s intended unforced continuum system retains its own proof obligations.

Packages **6–9 approach the spatial Hug–Navier problem**. The intended formulation is one continuing system. The earlier bridge and interface constructions retain their checked mathematics, but their interpretation was subsequently corrected. Read the [single-system scope correction](../research/comparisons/hug-navier-single-system-scope-correction.md#meaning-to-preserve-across-implementations).

After the reduced-model results, the next step is to control **fields that vary across space, whose spatial variation affects their evolution**. The eight-variable theorem does not supply the estimates needed to prove that a full spatial solution exists, is unique and stays within bounds over time. Packages 6–7 audit the earlier proposed construction, package 8 checks the single-system equations, and package 9 contributes diagnostics and guard-transport estimates. These are partial steps; the full spatial evolution theorem remains unfinished.

6. **[hug-navier-bridge-lean](hug-navier-bridge-lean/) — An earlier compatibility comparison.**

   **Proved:** 14 conditional statements about when the earlier proposed coupling fits together or encounters an obstruction.

   **Unfinished:** A full evolution theorem. Those results do not establish that the intended single system lacks the connections assumed by that earlier construction.

7. **[hug-navier-full-audit-lean](hug-navier-full-audit-lean/) — An audit of that earlier construction.**

   **Proved:** Seven statements about the supplied field and interface information.

   **Unfinished:** Full evolution and uniqueness. Its interface requirements must be read with the later single-system correction.

8. **[hug-navier-single-system-lean](hug-navier-single-system-lean/) — Checks within the six-field formulation.**

   **Proved:** Ten identities and local checks concerning the equations.

   **Unfinished:** Showing that a complete spatial solution exists, is unique, and keeps its guards within bounds throughout its evolution. Local boundary signs alone do not prove that final claim.

9. **[hug-navier-wellposedness-lean](hug-navier-wellposedness-lean/) — Diagnosing the difficult analytic step.**

   **Proved:** Four diagnostic statements about smooth perturbations and the equations’ rates of change. The current package also includes six guard-transport theorems, documented in a [separate ten-result verification record](hug-navier-wellposedness-lean/evidence-linux/source.json). The 19-package recheck above covered the four diagnostics.

   **Unfinished:** The requested full existence, continuation and uniqueness theorem. The full written classical uniqueness argument has not been certified by Lean.

Packages **10–17 concern Hug v3’s evolution, memory writes, transfer and delays**. Here, “hybrid” means continuous evolution interrupted by discrete events such as writing a memory.

10. **[hug-v3-proof-attempt](hug-v3-proof-attempt/) — What happens between events and at writes.**

    **Proved:** Six specific results under explicit assumptions about the events.

    **Unfinished:** Showing that a complete trajectory actually supplies those assumed events, and proving full correspondence with program execution.

11. **[hug-v3-hybrid-lean](hug-v3-hybrid-lean/) — Joining continuous stretches and discrete events.**

    **Proved:** Nine conditional assembly results: given suitable solution stretches and valid updates, specified conclusions follow about the combined history.

    **Unfinished:** Producing every required stretch, proving every update succeeds, and deriving uniqueness from the full equations.

12. **[hug-v3-source-lean](hug-v3-source-lean/) — An exact-number version of the fixed-grid system.**

    **Proved:** Nine results about the manually transcribed equations and event definitions.

    **Unfinished:** Proving equivalence with Python’s floating-point execution, and proving every write is reached, accepted and correctly stored and recovered.

13. **[hug-v3-transfer-lean](hug-v3-transfer-lean/) — Local teacher-to-teacher transfer.**

    **Proved:** 14 transfer statements under the stated encounter and comparison assumptions.

    **Unfinished:** An end-to-end theorem showing the complete causal transfer happens within finite time, through all required events and writes.

14. **[hug-v3-delay-lean](hug-v3-delay-lean/) — Which time an input comes from.**

    **Proved:** Nine identities distinguishing current physical inputs, buffered social inputs and the zero-delay case.

    **Unfinished:** Existence and uniqueness for the delayed evolution, preservation of bounds, stability and handling delayed discontinuities.

15. **[hug-v3-full-delay-proof](hug-v3-full-delay-proof/) — Conditional assembly with delays.**

    **Proved:** 14 statements about fixed delays and joining continuous evolution with events.

    **Unfinished:** Establishing the needed regularity, memory readability, successful writes and continuation through every required event. The word “full” in the filename does not mean the full target is proved.

16. **[hug-v3-memory-rules-lean](hug-v3-memory-rules-lean/) — Retrieval and memory identity.**

    **Proved:** 17 results about retrieval from the present state, weighted memories, partner identity and the fixed-delay convention.

    **Unfinished:** Several rules still need specification: variable timing, partial or mixed reconstruction with provenance, new solo episodes, and anticipation-effort accounting.

17. **[hug-v3-clay-boundary-lean](hug-v3-clay-boundary-lean/) — Keeping memories readable through change.**

    **Proved:** 12 component and conditional schedule results. A preservation theorem applies when a full solution already exists and an explicit deformation bound holds.

    **Unfinished:** Proving that solution and bound, together with successful encoding, capacity, write budgets and continuation.

The **last two are comparison and review packages**.

18. **[hug-v3-yang-mills-audit-lean](hug-v3-yang-mills-audit-lean/) — Comparing mathematical structures.**

    **Proved:** 20 statements about strain, changes of frame and evolution.

    **Unfinished:** Full Yang–Mills structure, equivalence of the dynamics and a mass-gap theorem. This audit is also separate from both the real-valued `readJet` example and the abelian field-equation comparison described [below](#separate-observation-and-field-equation-checks).

19. **[hug-v3-gemini-review](hug-v3-gemini-review/) — Repaired supplied arguments.**

    **Proved:** 77 statements under their stated assumptions. One delayed uniqueness result concerns **already-existing seven-variable A/S solutions on one delay interval**, with shared inputs and history.

    **Unfinished:** Full Hug v3 delayed evolution through all events, successful memory writes and the other required bounds. That limited uniqueness result does not supply the missing full existence theorem.

For a first reading, follow **1–3, then 4–5, then 6–9**: basic rules, complete evolution results for smaller models, and the remaining difficulty in the spatial system. Continue with **10–17** for memory writes and delays, then **18–19** for the comparisons and reviewed arguments. The [fresh evidence collection](../provenance/core-package-recheck-2026-11-12/README.md) retains each package’s exact scope and unfinished-work list alongside its passing checks.

**Credits:** AI-generated; dictated and directed by NousVolition. Each package retains its original proof and review credits. The [observation-package credits](../research/ambiguous-observation-lean/CREDITS.md) distinguish Claude’s review and drafting from later compilation and preserve the earlier assistant’s field-equation proof authorship.

## Detailed package records

<details>
<summary>Show all 19 packages, precise limits and fresh/historical evidence links</summary>

| Package | Checked result and current limits | Evidence |
| --- | --- | --- |
| [as-lean](as-lean/) | 30 scoped A/S claims. Later [existence](as-existence-lean/) and [invariance](as-invariance-lean/) results cover the seven-coordinate model; suppression comparison and repeated-encounter coupling remain open. | [fresh report](../provenance/core-package-recheck-2026-11-12/as-lean/verification-report.json) · [earlier](as-lean/verification-report.json) |
| [as-existence-lean](as-existence-lean/) | Existence and uniqueness of the seven-coordinate continuous integral evolution on every finite interval, under the original assumptions. | [fresh report](../provenance/core-package-recheck-2026-11-12/as-existence-lean/verification-report.json) · [earlier](as-existence-lean/verification-report.json) |
| [as-invariance-lean](as-invariance-lean/) | Both meaning states remain in [0,1] and both adverse-history loads remain nonnegative on every finite interval, under the original assumptions. | [fresh report](../provenance/core-package-recheck-2026-11-12/as-invariance-lean/verification-report.json) · [earlier](as-invariance-lean/verification-report.json) |
| [hug-squeeze-lean](hug-squeeze-lean/) | 51 specified claims. [Later existence work](hug-existence-lean/) covers the primary eight-state model; the separate memory-field extension remains open. | [fresh report](../provenance/core-package-recheck-2026-11-12/hug-squeeze-lean/verification-report.json) · [earlier](hug-squeeze-lean/verification-report.json) |
| [hug-existence-lean](hug-existence-lean/) | Existence, uniqueness and guard preservation on every finite forward horizon for the reduced eight-state model, with frozen parameters, continuous prescribed force and admissible initial guards. | [fresh report](../provenance/core-package-recheck-2026-11-12/hug-existence-lean/verification-report.json) · [earlier](hug-existence-lean/verification-report.json) |
| [hug-navier-bridge-lean](hug-navier-bridge-lean/) | 14 conditional compatibility statements for the earlier proposed coupling. Read the [single-system scope correction](../research/comparisons/hug-navier-single-system-scope-correction.md#meaning-to-preserve-across-implementations); full PDE evolution remains unproved. | [fresh report](../provenance/core-package-recheck-2026-11-12/hug-navier-bridge-lean/verification-report.json) · [earlier](hug-navier-bridge-lean/verification-report.json) |
| [hug-navier-full-audit-lean](hug-navier-full-audit-lean/) | 7 field/interface audit statements. The [later single-system correction](../research/comparisons/hug-navier-single-system-scope-correction.md#meaning-to-preserve-across-implementations) revises that interpretation; full PDE evolution remains unproved. | [fresh report](../provenance/core-package-recheck-2026-11-12/hug-navier-full-audit-lean/verification-report.json) · [earlier](hug-navier-full-audit-lean/verification-report.json) |
| [hug-navier-single-system-lean](hug-navier-single-system-lean/) | 10 identities and local checks for the six-field formulation. Full PDE existence, uniqueness and global guard invariance remain open. | [fresh report](../provenance/core-package-recheck-2026-11-12/hug-navier-single-system-lean/verification-report.json) · [earlier](hug-navier-single-system-lean/verification-report.json) |
| [hug-navier-wellposedness-lean](hug-navier-wellposedness-lean/) | 4 auxiliary well-posedness statements. Full PDE existence, continuation and uniqueness remain open. | [fresh report](../provenance/core-package-recheck-2026-11-12/hug-navier-wellposedness-lean/verification-report.json) · [earlier](hug-navier-wellposedness-lean/verification-report.json) |
| [hug-v3-proof-attempt](hug-v3-proof-attempt/) | 6 inter-event and write results under explicit event hypotheses. Full hybrid existence/uniqueness and execution correspondence remain open. | [fresh report](../provenance/core-package-recheck-2026-11-12/hug-v3-proof-attempt/verification-report.json) · [earlier](hug-v3-proof-attempt/verification-report.json) |
| [hug-v3-hybrid-lean](hug-v3-hybrid-lean/) | 9 conditional assembly and event results. Actual segment solvability, successful admissible writes and full-rate uniqueness remain obligations. | [fresh report](../provenance/core-package-recheck-2026-11-12/hug-v3-hybrid-lean/verification-report.json) · [earlier](hug-v3-hybrid-lean/verification-report.json) |
| [hug-v3-source-lean](hug-v3-source-lean/) | 9 results for the exact-real fixed-grid transcription. Source-execution equivalence and successful continuation through every write remain open. | [fresh report](../provenance/core-package-recheck-2026-11-12/hug-v3-source-lean/verification-report.json) · [earlier](hug-v3-source-lean/verification-report.json) |
| [hug-v3-transfer-lean](hug-v3-transfer-lean/) | 14 local transfer results under encounter and comparison hypotheses. End-to-end finite-time transfer and full existence/uniqueness remain open. | [fresh report](../provenance/core-package-recheck-2026-11-12/hug-v3-transfer-lean/verification-report.json) · [earlier](hug-v3-transfer-lean/verification-report.json) |
| [hug-v3-delay-lean](hug-v3-delay-lean/) | 9 timing identities. Delay-equation existence, uniqueness, invariance and stability remain open. | [fresh report](../provenance/core-package-recheck-2026-11-12/hug-v3-delay-lean/verification-report.json) · [earlier](hug-v3-delay-lean/verification-report.json) |
| [hug-v3-full-delay-proof](hug-v3-full-delay-proof/) | 14 conditional fixed-delay and hybrid results. Full-rate regularity, readability, successful writes and all-event continuation remain open. | [fresh report](../provenance/core-package-recheck-2026-11-12/hug-v3-full-delay-proof/verification-report.json) · [earlier](hug-v3-full-delay-proof/verification-report.json) |
| [hug-v3-memory-rules-lean](hug-v3-memory-rules-lean/) | 17 retrieval, weighting, partner-identity and fixed-delay results. Variable timing, reconstructed episodes and anticipation accounting remain unspecified. | [fresh report](../provenance/core-package-recheck-2026-11-12/hug-v3-memory-rules-lean/verification-report.json) · [earlier](hug-v3-memory-rules-lean/verification-report.json) |
| [hug-v3-clay-boundary-lean](hug-v3-clay-boundary-lean/) | 12 fabric, local-flow and conditional schedule results. Full-rate existence, continuation, readability and write-success bounds remain open. | [fresh report](../provenance/core-package-recheck-2026-11-12/hug-v3-clay-boundary-lean/verification-report.json) · [earlier](hug-v3-clay-boundary-lean/verification-report.json) |
| [hug-v3-yang-mills-audit-lean](hug-v3-yang-mills-audit-lean/) | 20 strain, frame and evolution comparison statements, including `green_objective`. Full Yang–Mills structure, dynamical equivalence and a mass-gap theorem are not proved. | [fresh report](../provenance/core-package-recheck-2026-11-12/hug-v3-yang-mills-audit-lean/verification-report.json) · [earlier](hug-v3-yang-mills-audit-lean/verification-report.json) · [recheck](../provenance/green-objective-2026-11-08/README.md) |
| [hug-v3-gemini-review](hug-v3-gemini-review/) | 77 repaired supplied statements. Delayed uniqueness covers existing seven-coordinate A/S solutions on one delay interval; full Hug v3 delayed hybrid evolution remains open. | [fresh report](../provenance/core-package-recheck-2026-11-12/hug-v3-gemini-review/verification-report.json) · [earlier](hug-v3-gemini-review/verification-report.json) |

</details>

Challenge files can contain intentional placeholders defining a target. An unfinished target is not a proof; use the package’s checked solution modules, permitted-axiom policy and verification report.

## Separate observation and field-equation checks

The [ambiguous-observation package](../research/ambiguous-observation-lean/README.md) has a passing pinned Lean build and axiom audit covering **51 public named theorems and lemmas**, including supporting results and repeated forms of the observation rule. [Successful GitHub run and axiom logs](https://github.com/NousVolition/hug-sims-lean-proofs/actions/runs/43172199579).

Its Tick 41 and Pair 25 instances concern supplied summaries and exact numbers. **YangMillsInstance** uses a real-valued projection with equal order-zero `readJet` readings and different first derivatives. **YangMillsCueTest** separately compares two explicit abelian potentials agreeing on `x₁ = 0`, with field-equation residuals 0 and 2; the modified potential fails the equation. Neither establishes an admissible Yang–Mills family. These are also separate from the 20-statement Hug v3 strain/frame audit above.

Simulator and transcription verification are outside this package; Comparator and nanoda were not run. [Preserved authorship and credits](../research/ambiguous-observation-lean/CREDITS.md).

### Separate combined transverse-derivative theorem

The [combined package](../research/combined-yang-mills-lean/README.md) imports both examples without replacing either. At every point on `x₁ = 0`, all potential components and all first coordinate partial derivatives agree; the second transverse `readJet` readings equal the respective residuals 0 and 2. **Twelve new named results passed local Lean compilation and axiom audit** with only `propext`, `Quot.sound`, and `Classical.choice`; they are not axiom-free. [Local logs](../research/combined-yang-mills-lean/logs/CombinedAxioms.log) · [Corrected attribution](../research/combined-yang-mills-lean/CREDITS.md). No GitHub Lean build, Comparator, nanoda, admissible family, or mass-gap result is claimed for this package.

## Separate finite origin checks

[Pair-25 origin tracking](../research/hug-v3/pair-origin-lean/README.md) has 77 finite statements about recorded identity histories, memory contents, material-field changes and context-origin accounts. Its [dedicated GitHub receipt](../research/hug-v3/pair-origin-study/github-lean-receipt.json) retains the exact inputs, targets and run. This package uses Lean-kernel compilation and a source-data certificate; Comparator and nanoda are not claimed. Fluid evolution and complete physical retention remain unproved.

## Following 540 and 872

[The observer-follow package](../research/hug-v3/observer-follow-lean/README.md) has 134 finite checks of the recorded neighborhood histories, crossings, context-origin accounts and shared bytes. Its [GitHub receipt](../research/hug-v3/observer-follow-study/github-lean-receipt.json) binds the exact proof inputs, targets and run. Fluid evolution and whether everything stays with either label remain unproved. Earlier 77- and 40-statement studies remain separate.

## Finer-grid recorded heat

[The finer-grid package](../research/hug-v3/heat-grid-lean/README.md) has **414 passing checks**: five finite rules and 409 recorded claims, including 4,820 global-account rows and complete saved-word comparisons. [Fresh GitHub build and dependency receipt](../research/hug-v3/heat-grid-lean/github-lean-receipt.json). The separate [numerical study](../research/hug-v3/heat-grid-study/README.md) passes its finest-grid time-step heat control, but the declared grid-settling test still fails. A proved recorded exceedance is not a convergence result. Lean does not verify fluid evolution or derive array measurements. This package does not change the earlier 56-check study, 12-check draft or 540/872 study.

## Following the recorded heat

[The heat follow-up package](../research/hug-v3/heat-follow-lean/README.md) has **56 checks**: four general finite rules and 52 declarations covering 2,408 recorded rows and scalar diagnostics. Its [GitHub receipt](../research/hug-v3/heat-follow-lean/github-lean-receipt.json) records a fresh full Lake build, all dependency lists and exact input/target matching. The separate [numerical study](../research/hug-v3/heat-follow-study/README.md) passes time-step criteria on 16³; finer grids were outside that historical study; see the separate finer-grid package above. Lean does not verify fluid evolution or spatial convergence. The earlier 12-check draft and 134-check observer study retain their separate scopes.

## Heat from writing

[The supplied heat draft](../research/hug-v3/heat-writing-lean/README.md) has 12 passing statements about scalar stroke heat, ambiguous recovery, work accounting, exact threshold-1 replay numbers and viscosity under stated hypotheses. Its [GitHub receipt](../research/hug-v3/heat-writing-lean/github-lean-receipt.json) binds the input fingerprint, targets and run. It is separate from the 134 observer-follow checks; thermal evolution and complete retention remain open.

## Further Lean packages

Each directory below is a separate Lake project. From that directory, use its pinned toolchain and run `lake build`. The Comparator configuration names the challenge, solution, allowed axioms and target declarations. The saved reports and Linux logs record the original checks. The historical scripts accept a configurable verification directory. The current CI instructions follow below.

| Package | Comparator targets | Saved verification |
| --- | ---: | --- |
| [clay-problems-lean-audit](clay-problems-lean-audit/) | 3 | [Verification report](clay-problems-lean-audit/verification-report.json) |
| [fabric-frame-transition-audit](fabric-frame-transition-audit/) | 7 | [Verification report](fabric-frame-transition-audit/verification-report.json) |
| [hearth-wizard-lean](hearth-wizard-lean/) | 22 | [Verification report](hearth-wizard-lean/verification-report.json) |
| [hug-v3-apple-band-lean](hug-v3-apple-band-lean/) | 15 | [Verification report](hug-v3-apple-band-lean/verification-report.json) |
| [hug-v3-apple-existence-lean](hug-v3-apple-existence-lean/) | 13 | [Verification report](hug-v3-apple-existence-lean/verification-report.json) |
| [hug-v3-bridge-return-lean](hug-v3-bridge-return-lean/) | 18 | [Verification report](hug-v3-bridge-return-lean/verification-report.json) |
| [hug-v3-child-access-lean](hug-v3-child-access-lean/) | 13 | [Verification report](hug-v3-child-access-lean/verification-report.json) |
| [hug-v3-child-account-lean](hug-v3-child-account-lean/) | 14 | [Verification report](hug-v3-child-account-lean/verification-report.json) |
| [hug-v3-child-witness-lean](hug-v3-child-witness-lean/) | 20 | [Verification report](hug-v3-child-witness-lean/verification-report.json) |
| [hug-v3-coexistence-lean](hug-v3-coexistence-lean/) | 12 | [Verification report](hug-v3-coexistence-lean/verification-report.json) |
| [hug-v3-courier-weaver-lean](hug-v3-courier-weaver-lean/) | 13 | [Verification report](hug-v3-courier-weaver-lean/verification-report.json) |
| [hug-v3-full-covariance-lean](hug-v3-full-covariance-lean/) | 26 | [Verification report](hug-v3-full-covariance-lean/verification-report.json) |
| [hug-v3-hearth-readout-lean](hug-v3-hearth-readout-lean/) | 12 | [Verification report](hug-v3-hearth-readout-lean/verification-report.json) |
| [hug-v3-joint-frame-lean](hug-v3-joint-frame-lean/) | 31 | [Verification report](hug-v3-joint-frame-lean/verification-report.json) |
| [hug-v3-o-rumination-lean](hug-v3-o-rumination-lean/) | 12 | [Verification report](hug-v3-o-rumination-lean/verification-report.json) |
| [hug-v3-occupied-space-lean](hug-v3-occupied-space-lean/) | 15 | [Verification report](hug-v3-occupied-space-lean/verification-report.json) |
| [hug-v3-paint-value-lean](hug-v3-paint-value-lean/) | 19 | [Verification report](hug-v3-paint-value-lean/verification-report.json) |
| [hug-v3-street-whole-lean](hug-v3-street-whole-lean/) | 22 | [Verification report](hug-v3-street-whole-lean/verification-report.json) |
| [mira-local-paths-lean](mira-local-paths-lean/) | 18 | [Verification report](mira-local-paths-lean/verification-report.json) |
| [person-environment-pnp-lean](person-environment-pnp-lean/) | 21 | [Verification report](person-environment-pnp-lean/verification-report.json) |
| [SIMS two memories and the restaurant meeting](sims-meeting-thread-lean/) | 90 | [Verification report](sims-meeting-thread-lean/verification-report.json) |
| [Traveller B’s first thoughts, fresh listeners and one continuing encounter](sims-mentor-first-thought-lean/) | 20 | [Verification report](sims-mentor-first-thought-lean/verification-report.json) |
| [Fourth write on the Hug prime meter](hug-prime-meter-lean/) | 9 | [Verification report](hug-prime-meter-lean/verification-report.json) |
| [Original two-memory transport and supporting lemmas](original-two-memory-transport-lean/) | 16 | [Verification report](original-two-memory-transport-lean/verification-report.json) |

The apple existence package records a conditional schedule theorem. Unconditional existence and uniqueness through all three memory writes remains open. Files kept in original, portable, references and reference-history directories retain their separate roles.

[Source hashes and publication scope](../provenance/lean-additions-2026-11-07.json).

## Reproduce the checks

From the repository root, run the inexpensive checks with Python 3.11 or later.

~~~sh
python3 -m unittest discover -s scripts/tests
python3 scripts/lean_package_report.py check
python3 scripts/check_public_paths.py
~~~

The source check follows the local imports of each configured solution and rejects standalone occurrences of `sorry`, `axiom`, `native_decide`, `sorryAx` anywhere in those files, including comments. The challenge statement is outside that closure. The independent kernel checks also cover imported dependencies. The policy permits only `propext`, `Classical.choice` and `Quot.sound`.

To replay a package, start with a clean package checkout on Linux with the pinned Lean toolchain, Go, Rust, Landlock and systemd available. Use a non-root user. Run the following commands from the repository root. Choose a package by setting `pkg`.

~~~bash
set -euo pipefail
repo=$PWD
pkg=hug-v3-apple-existence-lean
scratch=$(mktemp -d)
bash scripts/build-comparator-tools.sh "$scratch/tools"
cd "lean/$pkg"
lake exe cache get
bash "$repo/scripts/compare-package.sh" "$scratch/tools" "$scratch/evidence"
lake build 2>&1 | tee "$scratch/evidence/lake-build.log"
echo 0 > "$scratch/evidence/lake-build.exit"
python3 "$repo/scripts/lean_package_report.py" axioms . --output "$scratch/evidence/axioms.json"
python3 "$repo/scripts/lean_package_report.py" ci-report . "$scratch/evidence"
~~~

Comparator runs before the local solution build. It compares the challenge and solution declarations and exports the solution for nanoda and the default Lean kernel. The default Apple build now builds the solution; its reference remains available as an explicit Comparator target. The axiom file lists the dependencies Lean reported for each named theorem. [Pinned Comparator documentation](https://github.com/leanprover/comparator/blob/19e111e2141cf333c7daff0f64c5f24acc91dd2e/README.md)

Each `verification-report.json` contains exactly six fields. `comparator`, `lean_kernel`, `nanoda`, `lean_build` record the outcomes of the four checks. PASS requires explicit successful evidence, FAIL records a reported failure, NOT_RUN means there is no record that the check ran, and UNKNOWN means the available evidence cannot settle its outcome. `scope` describes the result, and `open_items` lists claims outside that result. Each package’s checked-in report reflects its saved Linux run. The 39 packages standardized together archive their prior reports in `evidence-linux/historical-report.json`. The SIMS meeting package keeps its earlier [49-target](sims-meeting-thread-lean/evidence-history/pr-4/), [58-target](sims-meeting-thread-lean/evidence-history/pr-5/), [65-target](sims-meeting-thread-lean/evidence-history/pr-6/) and [76-target](sims-meeting-thread-lean/evidence-history/pr-8/) receipts in its evidence history. Fresh CI reports and their logs are attached to the corresponding workflow run.


## Viscous time reversal

[viscous-time-reversal-lean](viscous-time-reversal-lean/) adds 14 scoped statements for the time-reversal chain rule, scalar Fourier-mode damping and amplification, and the effect of changing both step and viscosity signs. It uses the standard Comparator and two-kernel workflow above. The package README distinguishes these statements from the full coupled solver and points to the live CI evidence.

## Standalone Lean-kernel checks

The [finite-window gap package](../research/hug-v3/finite-window-lean/README.md) is a dependency-free Lake project under `research/`. Its 15 statements check nested-window reasoning and the exact recorded decimals for 25 pairs at 51 times. Its [saved local receipt](../research/hug-v3/finite-window-lean/receipt.json) reports no axiom dependencies. Its [dedicated workflow](../.github/workflows/finite-window-lean.yml) reruns Lean and checks the receipt against the current proof inputs. It does not use Comparator or nanoda and does not verify the underlying fluid simulation.

