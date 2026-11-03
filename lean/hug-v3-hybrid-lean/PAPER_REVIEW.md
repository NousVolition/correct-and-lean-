# Review of the supplied v3 hybrid proof and follow-up table

**PARTIAL.** The hybrid uniqueness route is appropriate, but the supplied manuscript is not a complete proof as written. The later table fixes the claim about constant inferred rest strain. It still needs a stronger valid-domain definition and a corrected unfiltered spectral-gradient bound. These corrections concern the argument and its domain of definition; none changes the source equations.

The original pasted LaTeX is preserved as `pasted-proof.tex`. Newly executed checks are in `paper-checks.json`. This review concerns the exact-real interpretation of the selected fixed-grid v3 source, with its 193,122 real numerical coordinates plus captured start-deformation arrays. The returning student and the idea “Giving someone space to speak can change what I understand” remain interpretation metadata; no new actor index, empirical measurement or two-state reduction was introduced.

## 1. The proposed domain is insufficient

Strict fiber positivity and the strict well margin are necessary for the proposed local argument. A constant bit pattern also keeps the result of a deterministic decoder constant. But a constant decoder result can be a rejected payload, or a record whose contents are unacceptable downstream.

Even adding successful `unpack` is insufficient. In `sources/structural_hug.py:113`, `unpack` checks the checksum, magic/version and actor/event identifiers. It does not validate the decoded time ordering or outcome ranges. `retrieve` later calls `outcome_score`, which does validate the outcomes. The proof silently uses nonnegative decoded durations when it asserts that exposure is nonnegative.

Two new checks used the unchanged source probe/decoder, the declared main dimensions and strict well margins:

| Constructed payload | What the source did | Consequence for the proof |
| --- | --- | --- |
| Correct CRC/header, observed outcome 2.0 | Probe and unpack accepted it; `outcome_score` rejected it | The RHS is not defined everywhere on the paper's proposed domain |
| Correct CRC/header, start 0.12, end 0 | Probe and unpack accepted it | At a matching cue, this record has weight −0.12, which can cancel the 0.12 history prior |

These are counterexamples to the stated domain claim. They are **not** asserted to be reachable from the declared initial state or produced by the declared writer. No fluid trajectory was simulated for these checks.

A sufficient corrected mathematical domain is

\[
\Omega_* = \{s: \|F_pa_k\|>0,\ |b_l|>0.005,\ \beta(b)\in\mathcal B_{\rm sem}\},
\]

where \(\mathcal B_{\rm sem}\) consists of bit patterns with successful decoding, every present outcome in \([-1,1]\), and every decoded duration nonnegative. Strictly positive durations can be required for the declared main records, but nonnegative durations suffice for the denominator bound. Other event-specific requirements, such as free capacity, no duplicate event ID and sufficient work budget, belong to event admissibility.

This domain remains open: on a sufficiently small neighborhood the bit pattern is fixed, so these discrete semantic conditions are fixed. This is a domain correction for an unchanged partial program, not an alteration of its dynamics. The source-to-Lean correspondence and preservation of this domain along the declared trajectory remain unproved.

## 2. The spectral-gradient constant needs a domain qualifier

`sources/continuum.py:100` computes `grad` without applying the mask. The bound

\[
\|\nabla_{\rm spec}\|\le 2\pi n/\sqrt3
\]

holds on the dealiased modes \(|f_j|<n/3\), not on arbitrary raw grid arrays. For the raw operator a safe bound is \(\sqrt3\pi n\).

At \(n=16\), the real cosine mode \((7,7,7)\) gives the exact ratio \(14\pi\sqrt3\), approximately 76.1796. The proposed raw upper bound is approximately 58.0416. A new Fourier computation confirmed these values. Bounded linearity and local ODE theory survive this correction.

The finite-volume map is indeed linear plus bilinear. However, the displayed transport estimate also uses a face-interpolation sup-norm estimate that its proof does not establish. A Fourier multiplier of modulus at most one gives an \(\ell^2\) bound, not automatically a sup-norm contraction. A safe estimate keeps the actual face operators \(H_j\):

\[
\|\Delta\mathcal T\|_2 \le 12n^2D_{\rm diff}\|\Delta C\|_2
 +2n\sum_{j=1}^3\left(\|H_ju_j\|_\infty\|\Delta C\|_2
 +\|\widetilde C\|_\infty\|H_j\Delta u_j\|_2\right).
\]

Finite-dimensional boundedness then supplies a local constant without modifying the transport formula.

## 3. Corrections specific to the pasted manuscript

The follow-up table already fixes the first item below; the remaining manuscript errors should not be carried into a final proof.

* **Strain versus decoded value.** The probe returns \(\widehat b=b\). The vector \(b\) varies continuously in the neighborhood. Its signs, packed bits and decoded records can remain constant. The claim that \(\widehat b\) itself is strictly constant is false.
* **Gaussian seam value.** For shifts \(-1,0,1\),
  \(\psi(1/2)=\psi(-1/2)=2e^{-1/(8w^2)}+e^{-9/(8w^2)}\).
  The manuscript's term with exponent \(-25/(8w^2)\) is incorrect. The evenness argument and continuity conclusion remain valid.
* **Normalization identity.** The manuscript's numerator \(n(X)-R(X)Z(X)\) is identically zero. The correct identity is
  \(R(X)-R(Y)=[n(X)Z(Y)-n(Y)Z(X)]/[Z(X)Z(Y)]\).
  Using positivity, the lower bound on \(Z\), and \(0\le R\le1\) recovers the stated kind of Lipschitz estimate.
* **Compact neighborhood.** The displayed neighborhood only restricts \(F\) and \(b\); all other coordinates are free. It is not a bounded ball, and its closure is not compact. Choose an actual sufficiently small Euclidean ball in the full numerical state space and use its compact closure inside \(\Omega_*\).
* **Pulse regularity.** The source's signed \(\sin^2\) pulse has matching values and first derivatives at 0, 0.5 and 1. It is \(C^1\), with possible second-derivative jumps. It does not force a jump in the ODE solution's first derivative. The memory writes do cause state jumps.
* **Simultaneous actions.** `run.py` completes endpoint writes, then captures starts at the next interval's left endpoint. At 0.8 the source order is `write 1`, then `capture 2`. Although this particular writer leaves \(F\) unchanged, the theorem should state the actual order and consume each completed start snapshot.
* **Heun's domain.** A successful RHS evaluation at the initial state does not guarantee the predictor lies in the valid domain. Heun is a deterministic partial update, unique when both stage evaluations and all intervening event checks succeed; it is not established as a total map on \(\Omega_*\).
* **Exact encoding limits.** The source's quantized integer range is \([-32768,32767]\). A symmetric absolute bound of 32767 is sufficient but omits a source-allowed endpoint.

## 4. Parts of the route that survive these corrections

The wrapped three-image Gaussian is continuous across the seam, with bounded derivatives on each smooth piece and a strictly positive normalization denominator. Its normalized periodic kernel is globally Lipschitz for the fixed positive width. It need not be smooth at the seam.

The regularized gradient excess is 1-Lipschitz. For the selected exact-off activation, the derivative on the positive branch is \((1+2\epsilon^2/q^2)e^{-\epsilon^2/q^2}\); its maximum is \(2/\sqrt e\), attained at \(q=\sqrt2\epsilon\), and the join is flat. Squared positive-part rates are \(C^1\). The temperature-dependent viscosity is positive, and the power-floor denominator is bounded below by \(10^{-5}\). Norm-based strain and permission sensors are locally Lipschitz even at zero. These are mathematical checks of the formulas, not newly completed Lean proofs of those components.

On a true compact neighborhood in \(\Omega_*\), all finite products, sums, bounded linear spatial maps and locally Lipschitz components can therefore be combined. This supplies a valid route to local Picard–Lindelöf theory and uniqueness by Grönwall. The relevant library tools are documented in [mathlib's Picard–Lindelöf module](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Analysis/ODE/PicardLindelof.html) and [Grönwall module](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Analysis/ODE/Gronwall.html). Their hypotheses still have to be established for a source-bound Lean RHS.

## 5. What the hybrid conclusion actually says

If two admissible solutions already exist on a segment, start from the same complete state, and satisfy the same locally Lipschitz source-bound RHS, they coincide there. If they reach an event with valid left limits and execute the same successful deterministic transition, the next complete state is the same. Induction gives **at most one** admissible hybrid trajectory over the declared schedule.

Existence up to 1.6 is a separate obligation. Local existence does not prove that every segment reaches its endpoint, that the read/fiber margins persist, or that every write is within capacity, encoding range and work budget. Replacing these obligations with hypotheses gives a conditional theorem; it does not discharge them.

The earlier six event lemmas remain historical verified evidence for their stated algebraic/discontinuity conditions. They were not a formal proof that the complete Python writer, codec and trajectory satisfy all those conditions. The new package separately records the precise scope of its own Lean and Comparator checks.
