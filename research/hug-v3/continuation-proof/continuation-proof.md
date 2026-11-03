# Continuation proof work for the unchanged Hug structural-memory v3 system

**Status: partial proof, not a completed global-validity theorem.** This document establishes new written bounds for the existing full fixed-grid system and identifies the remaining trajectory-specific obligations. It does not introduce another model, change an equation, replace a writer, change a coefficient, or add a simulation. No new Lean certificate is claimed.

## 1. Fixed target and source

The target is the same sealed `main` system: grid 16³, 384 material points, 24 material directions, six social roles, four memory slots, and the full 193,122-coordinate continuous state. The declared events are:

| Event | Start | Write time | Origin → recipient |
|---|---:|---:|---|
| 0 | 0 | 0.4 | 0 → 1 |
| 1 | 0.2 | 0.8 | 2 → 1 |
| 2 | 0.8 | 1.2 | 1 → 0 |

The intended theorem is existence of the complete admissible trajectory through time 1.6, with all three writes accepted. The existing local uniqueness theorem would then supply uniqueness. “Every write” here means every write in this unchanged schedule. The finite four-slot system does not promise an unlimited sequence of new records.

Sources:

- [Frozen source directory](C:/Users/ziman/Documents/Codex/2026-10-28/new-chat-4/hug-v3-transfer-lean/sources).
- [Existing corrected local proof](C:/Users/ziman/Documents/Codex/2026-10-31/ca/outputs/hug-v3-proof-corrected/revision-2/proof.md), especially its exact-real interpretation, admissible domain Ω*, and successful-write preservation lemma.
- [New static check evidence](C:/Users/ziman/Documents/Codex/2026-10-09/referenced-chatgpt-conversation-this-is-an/outputs/hug-v3-continuation-proof/checks.json).

All 21 source files were checked against their existing seal before and after the static checks; all matched. The existing proof and model files were only read. Decimal coefficients below have their mathematical values in the existing exact-real interpretation; the additional source-arithmetic checks are explicitly separate from that interpretation.

Ω* requires nonzero normalized material fibers, strict memory-read clearance |b_l| > 0.005, and a sign pattern decoding to records with valid durations and outcomes. It does not itself imply that a new record can be written. All statements below concern the exact finite-dimensional equations, not floating-point error, continuum PDE well-posedness, or empirical validity of the social interpretation.

## 2. Social bounds and record fields that are already controlled

Consider a solution on its maximal admissible interval, starting from the prescribed initial state and following a prefix of successful scheduled writes. The following bounds hold on that interval; they do not assume a global solution already exists.

### 2.1 Relations, responses, and contexts

Every off-diagonal relation coordinate stays in [0,1], and diagonal coordinates remain zero. Indeed, its derivative is 2(target − value), with target a sigmoid off the diagonal and zero on it.

Every response coordinate stays in [0,1], with zero diagonal. On this product box the source attention factor

\[
(.15+.85\,\mathrm{contextSimilarity})(.3+.7\,\mathrm{recognition})(1-.6\,\mathrm{withdrawal})
\]

lies in [0,1]. Each response target is that factor times a sigmoid, and the derivative is 4(target − response). Thus the vector field points inward at both faces. This and the relation argument are a joint product-box invariance proof, not an assumption that the responses were already bounded for all future time.

Each two-component context remains in the probability simplex. The home and room vectors are in that simplex. Context attraction is nonnegative mixing. The withdrawal term is a replicator term: its component is zero when that context component is zero, and its component sum is zero on the simplex. The full derivative therefore preserves the component sum and points inward at a zero component. Local uniqueness and the first-exit argument give invariance jointly with the relation/response box.

Writes leave all these social coordinates unchanged. Consequently the bounds persist across every accepted write.

### 2.2 Retrieval and other social variables

A record created from such a state has its two context components, recognition, authority, and seven action coordinates in [0,1]. Quantization at 0.0001 preserves these bounds. The unchanged outcomes lie in [-1,1]. Each retrieved evidence channel is therefore in [0,1]: it is a nonnegative weighted sum divided by 0.12 plus the sum of the weights. In particular, help − harm lies in [-1,1]. This argument starts with the empty memory and proceeds inductively across accepted writes; it makes no assertion about arbitrary externally fabricated records.

The log-radius derivative is 1.8(log(target radius) − log-radius), with target radius between 0.55 and 1. Starting from log(0.72), log-radius stays in [log(0.55),0]. Each association coordinate stays in [-2,2] because its target is 2(help − harm) times a tanh and its evolution relaxes toward that target.

Let R(t) bound the largest Euclidean norm of an expression vector or a norm vector. The source intent vectors have norms below one. At an expression vector attaining the common maximum R ≥ 1, incoming coercion toward another norm vector has nonpositive radial contribution. Refusal/withdrawal toward intent is also inward. The remaining terms have radial derivative at most

\[
0.8(1-R)+2.45=3.25-0.8R.
\]

For a norm vector attaining that maximum, the base term contributes at most 0.42 − 0.42R. The coefficient multiplying another expression minus this norm is cooperation + repair − coercion, in [-1,2]. Its nonnegative part is inward; its negative part contributes at most 2R after the source averaging. Thus the radial derivative is at most 0.42 + 1.58R. A common comparison function is

\[
R(t)=\left(1+\frac{3.25}{1.58}\right)e^{1.58t}-\frac{3.25}{1.58},\qquad R(0)=1.
\]

The upper Dini derivative of the finite maximum obeys this comparison, including ties. Hence expression and norm vectors cannot diverge in finite time on an admissible prefix.

### 2.3 Encoding consequences

The 11 social feature values produce signed-16-bit integers between 0 and 10,000. The outcome integers lie between −10,000 and 10,000. The declared clocks through 1.2 produce integers at most 1,200. Actor IDs are distinct and within the codebook. Event IDs 0, 1, 2 are distinct; their predecessor masks are 0, 0, 3. Three records fit in four slots. Constant signs between writes preserve prior records and checksums.

These facts discharge those schema/range/capacity obligations for an admissible prefix. The material-change tensor `delta_E` and the work acceptance tests still require separate treatment.

## 3. Nonnegative directional memory and exact preservation of volume

The source directional rate before limiting lies in [0,1]. Its limiter is

\[
\frac{0.7\,\mathrm{available}}{10^{-5}+0.7\,\mathrm{available}+\mathrm{rawpower}}\in[0,1].
\]

Available viscous power and raw power are nonnegative. Thus every exposure coordinate, initialized to zero, satisfies

\[
0\le m_{pk\pm}(t)\le t.
\]

No scheduled write changes m. Consequently 1 − exp(−m/0.2) lies in [0,1]. The directional stiffness weights are nonnegative and bounded, and the anisotropic conductivity is positive semidefinite above the fixed isotropic contribution 0.006 I.

The velocity starts at zero and its derivative is in the source's masked divergence-free Fourier subspace. Hence it remains in that subspace. With L_p = M(X)∇u, linear interpolation of zero grid divergence gives tr L_p = 0. Since

\[
\dot F_p=L_pF_p,
\]

the polynomial determinant identity gives

\[
\frac{d}{dt}\det F_p=(\operatorname{tr}L_p)\det F_p=0.
\]

This identity does not first assume that F is invertible. From F_p(0)=I it follows that det F_p=1. Writes leave F unchanged, so this holds across every accepted write. It is an exact-flow result, not a claim that the unchanged Heun method preserves determinants exactly.

## 4. A priori bounds for the whole continuous state

The purpose of this section is to rule out finite-time escape of the continuous coordinates on an admissible prefix. Its estimates are deliberately conservative and do not yet establish memory clearance.

Use the grid norm \(\|v\|_h^2=\Delta v\sum_x|v_x|^2\), with Δv = 16⁻³.

### 4.1 Accumulator and transported context

The structural utility obeys

\[
|U|\le0.63+0.2(R+1)^2.
\]

Here 0.63 bounds the outcome, reception, and observation terms; the remaining term bounds the expression mismatch. At initialization the structural outcome and mismatch are zero, observations are zero, and |U_baseline| ≤ 0.2. Since |input(t)| ≤ 1,

\[
|\dot A|\le0.08\{1+0.8[0.83+0.2(R+1)^2]\}
=0.13312+0.0128(R+1)^2.
\]

This bounds A uniformly on every finite interval, independently of F or temperature while the reader remains defined.

The face-averaged velocities in `context_transport` have zero finite-volume divergence. For a retained Fourier mode, the face-difference multiplier in direction j, including the transverse sinc factors, is

\[
i\kappa_j\prod_{k=1}^3\operatorname{sinc}(\kappa_k h/2).
\] 

Summing its product with the velocity coefficients gives zero by spectral divergence freedom. The centered face-context advection therefore contributes zero to the discrete context L² energy; diffusion contributes a nonpositive term.

The source kernel K = Rᵀα/Δv is nonnegative, with Δv Σ K = 1, because the attachment/softmax source weights α are nonnegative and sum to one. Therefore \(\|K\|_h\le\Delta v^{-1/2}=64\). Starting with C=0 gives

\[
\|C(t)\|_h\le64\int_0^t|A(s)|\,ds.
\]

Writes do not change C or A.

### 4.2 Mechanical energy, with the directional-writing sign retained

Define E as kinetic energy plus the base/directional elastic energy plus fabric energy, excluding temperature and accounting ledgers. Every term is nonnegative along this trajectory. For the neo-Hookean term, det F=1 implies tr(FFᵀ)≥3; the directional terms use m≥0; fabric energy is a sum of squares.

The source's mechanical interpolation/spreading are adjoints, the spectral derivative has the periodic summation-by-parts identity, and u is in the projection range. The rotational advection has zero pointwise power. Differentiating E gives the exact identity

\[
\dot E=-\int_hQ_v+P_m-D_b+\langle u,f_C\rangle_h,
\]

where \(P_m=\sum_pV_p\sum_{k,\pm}Y_{pk\pm}\dot m_{pk\pm}\ge0\) and \(D_b=\sum_lw_l\mu(\partial_bW_l)^2\ge0\). In particular, directional memory writing **adds** stored mechanical energy here; it must not be assigned the wrong sign.

The unchanged limiter gives

\[
P_m\le0.7\sum_pV_p\,\mathrm{available}_p
=0.7\int_h Q_v\frac{\mathrm{occupancy}}{1+\mathrm{occupancy}}
\le0.7\int_h Q_v.
\]

Hence

\[
\dot E\le-0.3\int_hQ_v-D_b+\|u\|_h\|f_C\|_h.
\]

For the declared smooth threshold, its activation is between zero and |∇_cd C|. The centered-gradient operator norm is at most √3 n, so

\[
\|f_C\|_h\le0.16\sqrt3\,n\|C\|_h.
\]

For z=√(2E), regularizing by E+ε if necessary gives \(\dot z\le\|f_C\|_h\). An accepted write changes mechanical energy by its stored-energy increment, which is work minus nonnegative heat. The source work equals the value at one of its work polynomial and is at most the sum of that polynomial's positive coefficients. Acceptance bounds that sum by 0.02. Thus each accepted write can increase z by at most √(2·0.02)=0.2. If j writes have been accepted,

\[
z(t)\le z(0)+0.16\sqrt3\,n\int_0^t\|C(s)\|_h\,ds+0.2j,
\qquad j\le3.
\]

No acceptance of a future write is assumed by this estimate.

### 4.3 Deformation, fibers, fabric, temperature, positions, and ledgers

Let E_T be the resulting finite mechanical-energy bound through a finite time T. Every positive quadrature volume V_p yields

\[
\|F_p\|_F^2\le3+\frac{2E_T}{0.08V_p}.
\]

Every positive fabric weight w_l yields

\[
b_l^2\le a^2\left(1+\sqrt{\frac{4E_T}{w_lH}}\right),
\qquad a=0.02,\ H=0.002.
\]

Together with det F=1, a finite upper bound B_F on \(\|F_p\|_F\) gives a positive lower bound on its smallest singular value: σ_min(F_p)≥B_F⁻². Thus all the source unit fibers satisfy |F_p a_k|≥B_F⁻². A fiber cannot collapse at a finite admissible endpoint.

The interpolation matrix is globally bounded, so X′=M(X)u is bounded on the finite interval. The viscosity remains between 0.015 exp(−0.35) and 0.015 exp(0.35), regardless of temperature. K is bounded because m≥0, the normalized directions are unit vectors, R is row-stochastic, and the grid is fixed. With u,F,b,m bounded, viscous heating, extraction, and structural release are bounded. Consequently the temperature equation has a bound

\[
\|\dot\theta\|\le a_T\|\theta\|+b_T
\]

with finite constants. Grönwall bounds temperature, and each of the finitely many accepted write injections is finite. This is a finite norm bound; positivity of 1+θ is not asserted, nor is it required for the RHS domain Ω*.

All ledger derivatives are bounded by the same estimates. The accumulated write-work coordinate is between zero and 3·0.02 on an accepted prefix. Captured start arrays are finite copies of F. Sections 2–4 therefore cover every continuous coordinate and the finite snapshot dictionary.

### 4.4 Continuation consequence

**Written continuation result.** On the prescribed exact-flow trajectory with any finite accepted-write prefix, the continuous coordinates cannot become unbounded at a finite endpoint, and normalized fibers cannot collapse. If the decoder clearance also stays uniformly strict up to that endpoint, the entire state lies in a compact subset of its fixed admissible decoder component. Its RHS is bounded and locally Lipschitz there, so the state has a finite endpoint limit in Ω*. The existing local theorem extends it.

The endpoint-limit step follows by integrating the bounded RHS; it is not an assumption that the desired limit already exists. The local theorem can be expressed using the standard [Picard–Lindelöf construction](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Analysis/ODE/PicardLindelof.html). This document does not claim that construction has been instantiated in Lean for this full system.

Therefore the remaining inter-event obstruction is reaching the memory-read boundary. Discrete write rejection is an additional, separate obstruction. Bounds in this section do not remove either obstruction.

## 5. Memory-clearance lemmas from the unchanged fabric equation

The pointwise ±0.006 barrier and its conditional first-crossing argument are already covered by the [earlier Clay-boundary Lean package](C:/Users/ziman/Documents/Codex/2026-10-28/new-chat-4/hug-v3-clay-boundary-lean/CLAY_BOUNDARY_REPORT.md), with its stated solution and deformation assumptions. They are rederived below to connect the new estimates to that existing result; that historical Lean verification was not rerun. The accumulated-strain criterion later in this section is an additional written argument, not a newly certified Lean theorem.

Writing e_l=(|F_{p,·,α}|²−1)/2, the fabric equation with the declared coefficients simplifies exactly to

\[
\dot b_l=\frac{e_l}{500}+\frac{31}{125}b_l-625b_l^3.
\]

Always e_l≥−1/2. At b_l=0.006 the derivative is at least 0.000353. Thus a cell initialized or written positive at +0.02 cannot cross below +0.006 while the exact solution exists. Positive bits have a uniform margin above the actual reader threshold 0.005.

For a negative bit, at b_l=−0.006 the derivative is at most −0.000353 **if** e_l≤1/2, equivalently |F_{p,·,α}|²≤2. Thus that geometric upper bound would also protect negative bits. The upper bound is an obligation to prove for this trajectory, not a new model constraint.

There is a weaker sufficient alternative based on accumulated positive strain. Put y=−b for a negative bit. On [0.006,0.02],

\[
g(y)=0.248y-625y^3\ge-0.00004,
\qquad \dot y=-e/500+g(y)\ge-e_+/500-0.00004.
\]

The minimum of g on this interval is at an endpoint: its only positive stationary point is a maximum. For a putative first crossing of y=0.006, integrate from its reset at 0.02, or its last downward crossing of 0.02 if it previously went higher. Through time 1.6, the sufficient strict condition is

\[
\int e_{l,+}(t)\,dt < (0.02-0.006-0.00004\cdot1.6)500
=6.968.
\]

It suffices to use the full-time integral for each material point/axis, since any subinterval integral is smaller. Positive writes are already protected, and negative resets restart from −0.02. This is a derived criterion for the existing dynamics. It has **not** been discharged for the exact main trajectory.

## 6. What one geometric bound would settle

Suppose the main exact trajectory can be proved to satisfy

\[
|F_{p,·,\alpha}(t)|^2\le2\quad\text{for all material points, axes, and }0\le t\le1.6.
\tag{G}
\]

In addition to both bit-clearance bounds above, (G) has two useful consequences:

1. **Material encoding fits.** Diagonal Green strains lie in [−1/2,1/2]. Off-diagonal Green strains have absolute value at most one by Cauchy–Schwarz. Differences between captured starts and ends therefore have absolute value at most two, safely within the signed-16-bit range at quantum 0.0001. This treats every resolved material component.
2. **The declared budget is sufficient.** Under |e|≤1/2, the fabric interval [−0.025,0.025] is invariant: the derivative at its upper endpoint is at most −821/320000 and at its lower endpoint at least +821/320000. Initial values and reset targets lie within it. Let B=0.025 and D=B+a=0.045. If c₁,…,c₄ are the source work-polynomial coefficients, their positive parts are bounded by total fabric mass times the following densities:

\[
\begin{aligned}
d_1&=\left[k(1/2+B)+\frac{HB}{a^2}\left((B/a)^2+1\right)\right]D+2.5D^2,\\
d_2&=\left[\frac{k}{2}+\frac{H(3B^2+a^2)}{2a^4}\right]D^2,\\
d_3&=HB D^3/a^4,\qquad d_4=HD^4/(4a^4).
\end{aligned}
\]

The sum of all fabric weights equals the body quadrature volume, bounded above by

\[
\frac43\frac{22}{7}(0.22)(0.17)(0.19).
\]

Using the entire fabric mass rather than just the written slot is conservative. Multiplication gives

\[
\mathrm{requiredBudget}\le0.00269623706668<0.02.
\]

The rational coefficient bounds and this inequality were checked exactly. The fixed numerical quadrature weights also satisfy the stated mass upper bound.

Thus (G), if established, would simultaneously resolve negative-bit clearance, material encoding range, and budget sufficiency. It would **not** resolve the writer's independent requirement that the net supplied work be nonnegative. The next section shows why that distinction cannot be omitted.

## 7. A verified counterexample to a shortcut, not to the main trajectory

Consider the following static state using the unchanged configuration: F=I, every fabric coordinate b=−0.01, and all other coordinates equal to their initial values. All slots read as empty, |b| exceeds both 0.005 and 0.006, det F=1, and (G) holds. The source `make_event` creates the ordinary event-0 payload with zero material-change tensor. Its schema, feature ranges, and checksum are valid.

For a cell with e=0, the initial potential is 0.00028325 and either reset target ±0.02 has potential 0.000008. The prescribed heat density is 2.5(target−b)². Therefore the net work densities are exactly

\[
w_{\text{zero bit}}=-0.00002525=-101/4000000,
\qquad
w_{\text{one bit}}=0.00197475=7899/4000000.
\]

If ρ is the fraction of the selected slot's material weight assigned one bits, total work is

\[
M_{\mathrm{slot}}[-0.00002525+0.002\rho].
\]

It is negative when ρ<101/8000=0.012625. The actual source payload and material weights give ρ≈0.00170893656, and source arithmetic gives work≈−1.6246087661×10⁻⁷. Exact rational arithmetic applied to the fixed binary quadrature weights gives the same negative sign. The required budget is only approximately 1.1499968273×10⁻⁶, already far below 0.02, so this is not an insufficient-budget example.

The existing `write_event` rejects it with `insufficient writing work budget or undeclared recovery path`, specifically because work<0. No equations or budget were changed to obtain this result. No time integration was performed.

**Meaning:** readable records, invertible deformation, the geometric buffer (G), and ample budget do not imply automatic write acceptance. A universal proof based only on those conditions is false. **Reachability of this static state from the main initial state is not established. This is not evidence that any scheduled main write fails.**

## 8. What remains to finish the requested theorem

The target is not yet proved. A sufficient remaining route is:

- Establish (G) for the exact prescribed trajectory through all three writes and the final interval. Alternatively, obtain the weaker accumulated-strain bound and a separate material-range/budget bound.
- Prove nonnegative supplied work for the actual three pre-write states and their actual quantized payloads. This cannot be removed using mere readability or the energy-balance identity.
- Establish defined execution of the original discrete diagnostics, including the source polynomial-root calculation, for those writes. An exact-real quartic is finite, but that fact alone does not certify a floating-point library call.

With these obligations discharged, the bounds and existing successful-write preservation lemma support a finite induction: continue to a checkpoint, form the source record, prove the write is accepted, preserve Ω*, and continue. The captured-start ordering and same-time end/start order remain the original ones. No additional model branch or alternative writer is needed for that proof strategy.

### Why the present broad energy bound does not close (G)

Applying the explicit conservative bounds above even before the first write at 0.4 gives a positive-strain-integral upper bound about 4.50×10⁸, far above the sufficient 6.968 threshold. This is a failure of that estimate to establish the required smallness; it is not a prediction of actual deformation or a failure of the simulation. The small material quadrature weights and worst-case source/operator bounds make the estimate very loose.

Repeating that same estimate does not supply the missing proof. The next substantive method would need a sharper bound that uses the actual spatial forcing and its evolution, or a rigorous enclosure of the exact trajectory and its write inputs. Ordinary saved floating-point values do not provide such an enclosure. No such enclosure has been constructed in this work.

## 9. Verification and preservation boundary

New evidence consists of source inspection, written analytical derivations, exact rational coefficient/sign/budget checks, one static call of the unchanged reader/writer demonstrating the counterexample, and a separate nontrivial static RHS evaluation checking the mechanical-energy and context-transport identities. The last check includes positive directional storage power, its viscous-power upper bound, and the zero trace of the interpolated velocity gradient. No trajectory or timestep was executed. The checks completed successfully and retained all 21 sealed source hashes. They are not an automated verification of every analytical argument in this document.

The previously saved main numerical run completed its three writes. Its sampled minimum normalized well margin is approximately 0.99335, and its recorded write work values are positive. Those are historical numerical observations, not newly rerun experiments and not bounds on the exact trajectory between samples. They cannot be promoted to a proof of (G), exact work acceptance, or approximation accuracy.

Existing Lean packages retain their existing scope. This work adds no machine-checked global theorem and does not broaden any previous certificate. A formal proof of the full Lean proposition would additionally need the full source correspondence and codec obligations identified in that package, plus formalizations of the new analytic arguments. The full-system existence-through-all-writes theorem remains open, while the bounds and counterexample above narrow and clarify the work needed to complete it.
