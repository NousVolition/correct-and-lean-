# Review of the supplied Hug v3 proof and follow-up table

**Verdict: the submitted proof is not valid as written.** The local-Lipschitz / Grönwall / deterministic-event strategy remains a useful route, but the stated valid domain admits undefined right-hand sides and the full-space spectral-gradient bound is false. The later table fixes one wording error about the decoder; it does not fix these two issues.

This review concerns **hug-structural-memory-v3**, its exact-real interpretation on the fixed finite grid, and its declared 0–1.6 interval. It is separate from the stacked Triangle Hug trial and that trial's 0–8 illustrative cycle. Neither model, any source equation, nor the submitted document was edited.

## Evidence and preservation

- [Submitted LaTeX](submitted-proof.tex) is a byte-for-byte copy of the supplied attachment.
- [Input manifest](input-manifest.json) records original paths, SHA-256 hashes and the frozen review inputs.
- [Checks](checks.json) records newly executed checks and their scope. The original 21 files, the prior proof package's 21 snapshots and this review's 21 copies all match the existing source seal before and after the checks.
- The unchanged `main` declaration passed its existing declaration gate. Constructing its state reproduced **193,122 coordinates**, excluding event-start snapshots and other runner metadata. Its checkpoints are **0, 0.2, 0.4, 0.8, 1.2, 1.6**.
- The review ran static counterexamples and selected operators. It did not integrate a new trajectory, execute Lean or nanoda, prove source-to-Lean correspondence, render the LaTeX, or test the pressure/triangle interpretation.
- [Prior verification receipt](prior-evidence/verification-report.json) is historical evidence, not a fresh verification. It reports six checked event/algebra lemmas and explicitly reports full-v3 existence, uniqueness and continuation as unproved. That receipt cannot certify this later pasted proof.

## Review of the seven rows

| Supplied row | Finding |
| --- | --- |
| Valid open domain, Item 6 | **Needs a stronger definition.** Strict fiber and bit margins do not establish successful decoding or valid decoded record semantics. Even adding the original draft's CRC/header parsing requirement is insufficient; see the counterexamples below. |
| Fixed-grid operators, Item 1 | Bounded linearity and the linear/bilinear transport structure are correct. The stated gradient norm is false on the full space. The explicit transport bound also needs a justification beyond the cited L2 contraction. |
| Wrapped Gaussian, Item 4 | The symmetry, positive normalization and global Lipschitz route are sound. Two displayed equalities in the long draft are wrong and need the corrections below. The derivative bound is piecewise / almost everywhere, since a derivative at the seam is not claimed to exist. |
| Regularized gradient and exact-off activation, Item 3 | The analytical argument is correct for positive delta and epsilon. The activation derivative has maximum 2/sqrt(e) at q = sqrt(2) epsilon, and its join is smooth and flat. |
| Viscosity, rate split and power floor, Items 2 and 5 | The stated sign and regularity arguments follow from the source expressions and positive fixed coefficients. These are exact-real statements, not protection against floating-point overflow. Positivity of this writing-power denominator does not establish positivity of the separate retrieval denominator. |
| Norms and retrieval, Items 2 and 6 | The reverse-triangle inequalities give the required local Lipschitz norm compositions. Retrieval needs additional decoded-record conditions before its claimed denominator bound follows. |
| Grönwall and hybrid composition, Item 7 | This is a conditional uniqueness argument after the domain and local-bound issues are repaired. It does not prove that all segments reach the next event, that all writes succeed, or that a complete trajectory exists through 1.6. The numerical-step domain and event ordering must also be stated precisely. |

## 1. The valid-domain claim fails for the actual decoder

The draft requires nonzero sampled fibers, strict well margins and successful `unpack` of nonempty slots. The later table mentions only the margins and local decoding conclusion. Include parsing validity explicitly in either formulation.

More fundamentally, [`unpack`](sources/structural_hug.py) checks CRC, magic/version and actor/event IDs, but does **not** check all record conditions enforced by `payload`. A checksum checks the bytes against their checksum; it does not establish the validity of their meaning.

A newly executed counterexample uses F = I, every b coordinate equal to +0.02 or -0.02, and a correctly checksummed slot with decoded start = 0 and end = -0.12. All sampled fiber lengths equal 1 in exact arithmetic, and every absolute b value exceeds 0.005. The slot passes `read_material`. Choosing current and recorded context (0.5, 0.5), zero association and zero stored strain change makes the retrieval cue difference zero. Hence:

\[
 w=(-0.12-0)e^0=-0.12,
 \qquad p_{\mathrm{hist}}+\mathrm{exposure}=0.12-0.12=0.
\]

The unchanged source then produces nonfinite retrieval values. The cancellation also holds in exact rational arithmetic: 3/25 - 120/1000 = 0. This is a counterexample to the claimed domain-wide denominator bound, not merely a small numerical residual.

A second checksummed slot decodes an observed score of 2. The reader accepts it, but `outcome_score` subsequently raises an error. Thus successful parsing alone does not make the complete RHS defined.

**These are static states admitted by the stated mathematical domain. They were not generated by the validated event writer, and they do not establish failure or reachability from the declared main initial state.**

A proposed repair is to restrict to a union of decoder regions with successful parsing and semantically admissible records: in particular, nonnegative decoded durations and every present outcome in [-1, 1]. Retain any additional schema/order conditions needed for the intended reachable component. Positive durations, if desired, are a stronger condition; this distinction matters when times are quantized. Since each record is fixed within its strict sign region, these discrete semantic conditions still select a union of open regions. No source-code changes are necessary to state a suitably restricted theorem.

## 2. The full-space gradient bound is too small

The source `grad` at [`continuum.py:97`](sources/continuum.py) applies Fourier differentiation without the dealiasing mask. For n = 16, choose the real grid mode

\[
 C_{ijk}=\cos\!\left(\frac{2\pi\,7(i+j+k)}{16}\right).
\]

Its gradient-to-field norm ratio is exactly

\[
 14\pi\sqrt{3}\approx76.1795733,
\]

which exceeds the supplied upper bound

\[
 2\pi n/\sqrt{3}\approx58.0415797.
\]

The source operator reproduced this ratio numerically. A safe full-space bound is **pi sqrt(3) n**, about 87.0623695 at n = 16. The smaller submitted bound can be used for the gradient restricted to the stated dealiased mode range, but that restriction must be explicit. In particular, the transported context field is not automatically restricted to that range.

For the explicit transport inequality, the draft's bound on the face multiplier establishes an L2 operator bound, not an L-infinity contraction. This review has not established that the submitted transport constant is false; its given justification is insufficient. One conservative replacement, using Euclidean norms for the full arrays and the unchanged source operators, is

\[
\begin{aligned}
\|\mathcal T(C,u)-\mathcal T(\widetilde C,\widetilde u)\|_2
&\le 12n^2D_{\mathrm{diff}}\|C-\widetilde C\|_2\\
&\quad+6n\bigl(\|u\|_2\|C-\widetilde C\|_2
+\|\widetilde C\|_2\|u-\widetilde u\|_2\bigr).
\end{aligned}
\]

This follows from the norm-at-most-one face averaging and face-velocity maps in L2, the bound 2n for each flux-difference operator, and the pointwise product bound using L-infinity <= L2. It is a proposed analytical bound, not a replacement transport equation.

## 3. Decoder values and a bounded neighborhood

The original long draft says the inferred rest strain, bit vector, checksum status and records are all strictly constant. Only the last three conclusions follow. The exact probe identity is **estimated b = b**, so the analog estimate changes with b. Changing one initially empty coordinate from -0.020 to -0.019 remains within the prescribed half-margin and leaves all bits and decoded records unchanged, while the analog estimate changes. This was reproduced with the source probe.

**The user's follow-up table corrects that wording:** it lists the sign pattern, packed bits, CRC status and records as constant, without asserting that b itself is constant. Retain that correction.

The draft's set U constrains b and sampled changes in F, while leaving other coordinates unrestricted. It is an open neighborhood, but not a bounded Euclidean ball in the full state space. Its closure cannot be called compact on that basis. For local Picard–Lindelöf and the compact-bound step, choose an actual finite-radius ball B_r(s0) whose closure lies inside the corrected valid domain. Restrict delta in the local existence statement so it does not cross the next scheduled jump.

## 4. Two algebraic corrections in the long Gaussian proof

For the three shifts {-1, 0, 1}, the correct seam value is

\[
\psi(1/2)=\psi(-1/2)
=2e^{-1/(8w_{\mathrm{th}}^2)}+e^{-9/(8w_{\mathrm{th}}^2)}.
\]

The draft instead adds terms with coefficients 1, 9 and 25 in the exponent. That value is incorrect. The even-symmetry argument still establishes continuity.

The normalized-kernel equality in the draft has numerator `psi(X) - R(X) Z(X)`, which is identically zero. A correct identity, with f the relevant Gaussian factor and R = f/Z, is

\[
 R(X)-R(Y)
=\frac{f(X)-f(Y)-R(Y)[Z(X)-Z(Y)]}{Z(X)}.
\]

Together with 0 <= R <= 1 and Z >= z_min, this gives the intended bound (1+n)L_psi/z_min for each one-dimensional factor. A source-equivalent numerical example gave a nonzero difference about 0.1435457 where the draft's right-hand side was zero. The global Lipschitz conclusion is repairable; the written equalities are not correct as supplied.

## 5. Hybrid and numerical uniqueness require exact qualifications

Use the source order in [`run.py`](sources/run.py): finish an interval; process ending events sequentially in the declared list order, consuming the current updated state and popping the corresponding start snapshot; then capture starts for the next interval. At time zero, capture the initial starts. If several writes end at one time, compose their updates; do not repeatedly reset each write to the same pre-event state. The general corollary's notation should express this even when a particular fixture has no simultaneous endings.

The source's Heun step evaluates the RHS first at s and then at s + h F(t,s). Membership of s in the valid domain alone does not guarantee that the second evaluation is defined. It is a single-valued **partial** map on the states where the required stages exist; continued iteration also needs valid outputs. Determinism does not establish existence, numerical convergence or agreement with an exact-real ODE solution.

The draft's final quantization condition `abs(rint(x/q)) <= 32767` is a sufficient but unnecessarily stronger condition than the actual signed-16-bit source range **-32768 <= rint(x/q) <= 32767**. Use the exact source range if claiming an exact correspondence. Successful writes also require capacity, unique IDs, schema/range validity and the source's work/budget checks; a deterministic rejection is not a successful trajectory.

The appropriate conditional target is:

> For the fixed configuration and inputs, use a corrected open domain on which the full exact-real RHS is defined and locally Lipschitz, uniformly in time on each relevant local interval. Given the same initial state and captured-start data, any two admissible hybrid trajectories agree for their common duration, provided each segment exists within that domain and each scheduled event executes successfully in the same fixed order and supplies an admissible next state.

This states **at most one admissible trajectory**, not existence of one through t = 1.6. A priori continuation, domain invariance, successful writes and full formal source correspondence remain additional obligations. The proposed repaired statement is not presented as a new Lean certificate.

## Connection to the pressure discussion

Uniqueness means that identical complete conditions do not produce two different solutions of the specified equations. It does not establish resistance to crushing, stability under perturbations, or psychological meaning. Nonzero sampled fiber lengths and readable bit margins are conditions of this proof domain; assuming them does not prove they persist. Loss of a decoding margin is also not, by itself, a law of material fracture.

The v3 source has material deformation and stress quantities that could support a separate investigation, but this proof does not identify a dangerous middle and does not transfer to the triangle geometry without an explicitly defined coupling. The original equations and the separate triangle trial remain preserved.
