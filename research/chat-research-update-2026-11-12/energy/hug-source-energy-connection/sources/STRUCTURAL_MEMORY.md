# The Hug changes through what it has experienced

**Historical component stage.** The current complete synthetic field implementation is specified in [COUPLED_FIELD.md](COUPLED_FIELD.md), with results in [report.html](report.html). Statements below about a remaining full solver describe the earlier component stage.

Current continuation, 23 October 2026. The user selected **changes within existing material first**, rather than literal growth or loss of material. This supersedes the gravity-based role definition in `HOLDING_AND_ENERGY.md`; that file remains a historical comparison.

The Hug is now the coupled process of movement, retained structural change and subsequent response. Memory is part of the material's state. S describes transfer through that changing material and its surroundings. The rock, tree and onion examples motivate persistent, structured traces; they do not supply geological or biological constitutive laws.

This update supplies an executable **added material candidate**, a complete local energy account, a body/exterior coupling specification and reproducible component experiments. It does not claim that a complete moving three-dimensional Hug field has been solved. The component experiments are clearly separated from that remaining numerical task.

## Provenance: supplied equations, current intent and additions

**SOURCE** means an equation in the corrected DOCX or readable board. **INTENT** means the user's clarification. **ADDED** means a new hypothesis needed to implement it. **DERIVED** means a consequence of the stated equations, not an independent empirical fact.

| Part | Status | Role |
|---|---|---|
| Accumulator A, source J, context transport and gradient force | SOURCE | Retained exactly, with the original scalar S renamed C for clarity |
| Memory becomes part of changing structure | INTENT | Records must affect subsequent response, including after motion stops |
| Changes within existing material first | INTENT | Constant material mass; no deposition, erosion, growth or shedding in this stage |
| Material-attached directional records m | ADDED, implemented | Record extending and shortening separately; no automatic decay or reset |
| Bounded expression of retained records | ADDED, implemented | Limit their influence without deleting the record |
| History-dependent elastic stress and thermal conductivity | ADDED, implemented | Connect retained structure to mechanical response and energy transfer |
| Energy-limited writing of structural traces | ADDED, implemented | Explicitly pay for changes in stored mechanical energy |
| S_E as energy flux; movement as u | ADDED physical realization of INTENT | A declared interpretation, not a claim that the corpus's scalar was already energy |
| Upper-half paired context influence D_C | Separate ADDED law | Graded by current physical height; not part of K_h J or the material recording law |
| Gravity/confinement | Optional historical comparison | No longer the defining law of the Hug |

The DOCX hash is unchanged: `01f9ab0942f9c88982863e2ffc1e3c495786b5e6b67a26ae77d18235e7058acf`. Relevant paragraphs are 517–539 for accumulated input/transport and 546–551, with the earlier threshold section, for stress and force.

The targeted Miro read covered [06: static/dynamic distinction](https://miro.com/app/board/uXjVEXBJz3k=/?moveToWidget=3458764687912872500), [13: coupled field and threshold response](https://miro.com/app/board/uXjVEXBJz3k=/?moveToWidget=3458764687916065203), [16: the past survives zero input](https://miro.com/app/board/uXjVEXBJz3k=/?moveToWidget=3458764687918055185), [18: identical readings can hide different states](https://miro.com/app/board/uXjVEXBJz3k=/?moveToWidget=3458764687918055187), and the theory map. It returned 107 managed items and reported 72 foreign/skipped items. Readable text supports the distinctions above; it does not supply the material laws introduced below. This is not a claim to have parsed every image on the board.

## 1. What changes, and what remains distinct

At each material parcel the state includes deformation F, velocity u, temperature θ, context C and directional structural records m. A is the original accumulated source input. A record is carried with its parcel, rather than stored at a fixed location that another parcel may later occupy.

The feedback path is:

**input → A → context C → original gradient force → movement → structural records → stress and transfer pathways → later movement and transfer.**

There are three different flows:

| Flow | Expression | Units |
|---|---|---|
| Material movement | u; mass flux ρu | m/s; kg/(m² s) |
| Original context transport | C u − D_diff ∇C | Q·m/s |
| Proposed S energy transfer | S_E = E u − T u + j_T | W/m² |

Q is an explicitly uncalibrated context unit. Neither C nor A is automatically fuel, heat, water content or electrical charge. Heat can cross a material boundary while no mass crosses it. A zero net reading can also hide opposing flows. Those distinctions are essential to the user's internal/external-transfer intent.

## 2. The supplied equations remain identifiable

In the body, retaining the corpus's incompressible setting:

\[
\dot A=\gamma_U(U-U_b),\quad A(0)=0,\qquad J=\kappa A,
\]
\[
\partial_t C+u\cdot\nabla C=D_{diff}\Delta C+K_hJ+D_C,
\qquad \int_{\Omega_b(t)}K_h\,dx=1.
\]

Everything except **D_C** in that context equation is the supplied law. The added pair term is separately defined in section 8. There is no new term called “memory” hidden inside J or K_h. The kernel is normalized over the current body and the source is not duplicated in the exterior.

The original force is retained:

\[
b_C=-\sigma_r a(q)e_k,\quad |e_k|=1.
\]

For this component implementation the declared branch is the supplied smooth exact-off option with cutoff-preserving regularization:

\[
q=\sqrt{|\nabla C|^2+\delta^2}-\sqrt{\Gamma^2+\delta^2},\quad
a(q)=\begin{cases}0&q\leq0,\\q\exp[-(\epsilon/q)^2]&q>0.\end{cases}
\]

The sharp and signed-tanh alternatives remain different choices. In particular, the signed-tanh branch is not exact-off below threshold. No threshold in b_C erases A, C or m. The chosen force may add or remove mechanical energy: its power is b_C·u, not automatically negative.

When U returns to its baseline, A remains at its accumulated value and J can continue. Under closed conditions, the context total obeys d∫C/dt=κA. Constant positive excess input can still cause quadratic growth. Bounded structural expression below does **not** cap A or C. A signed input can lower A; that original behavior is not changed into an everlasting positive archive.

## 3. Material coordinates and persistent structural records — ADDED

Let x=χ(X,t) map each reference body parcel into its current position. Set

\[
F=\nabla_X\chi,\quad D_tF=(\nabla u)F,\quad \det F=1,
\quad D=\tfrac12(\nabla u+\nabla u^T).
\]

The map must remain invertible. The density is constant in each phase, and div u=0. This is the selected constant-mass incompressible stage, not a growth model.

Choose unit **material** directions a_k. For each direction keep two nonnegative records m_{k,+} and m_{k,−}, for extending and shortening. They do not subtract from one another. Their axes move with F; a picture rotating does not create a new material memory.

\[
d_k=Fa_k,\quad e_k^{str}=\tfrac12(|d_k|^2-1),\quad
r_k=d_k\cdot Dd_k=D_te_k^{str}.
\]

The strain symbol e_k^{str} is distinct from the fixed unit force direction e_k above. The implementation uses `strain` and `direction` to avoid confusing them.

Each retained record has bounded expression

\[
f(m)=1-e^{-m/m_*},\qquad m_* >0.
\]

Here m is dimensionless, m≥0, and 0≤f(m)<1 for finite m in exact arithmetic. Machine arithmetic can round f to one at large m; the record itself is still stored. Saturating expression is not truncating or resetting m. At rest the recording rate below is zero, so the already encoded state remains.

This is a finite directional summary of experience. It is **not** a complete recoverable record of every event or human memory. Different histories can lead to the same m. The saved chronological CSV records preserve the tested trajectory separately; the constitutive law does not secretly read that file. Literal concentric layers, permanent plastic shape change, chemical history and biological inheritance are not asserted by these variables.

## 4. How memory becomes part of material response — ADDED

Use B=FFᵀ and the mechanical stored-energy density

\[
W(F,m)=\frac{G_0}{2}(\operatorname{tr}B-3)
+\frac12\sum_{k,s\in\{+,-\}}G_{k,s}f(m_{k,s})(e_k^{str})^2,
\]

with G_0>0 and G_{k,s}≥0 in pascals. This is one explicit **hardening** candidate. Increasing trace expression strengthens the directional response; it is not a universal claim that experience must stiffen real clay.

Its elastic stress, up to the incompressible pressure convention, is

\[
\tau_{el}=G_0(B-I)+\sum_{k,s}G_{k,s}f(m_{k,s})e_k^{str}\,d_k\otimes d_k.
\]

The full body stress and momentum balance become

\[
T_b=-PI+2\mu D+\tau_{el},\qquad
\rho_bD_tu=\nabla\cdot T_b+b_C+b_{ext}.
\]

The original Newtonian viscous stress is preserved with μ₀=μ. **Elastic stress is the declared addition.** This is not the earlier Burgers law, not calibrated clay and not a deduction from the corpus's fluid analogy.

At F=I, the added elastic stress and W vanish even when m is nonzero. When the material is loaded again, that same m changes the stress. Thus equal visible shape and zero instantaneous stored mechanical energy do not imply equal structure. Memory is not identified with an amount of energy that must remain trapped forever.

Expression bounds the coefficients, not deformation: sufficiently large strain can still give large stress. Positive energy and the tests below do not prove global existence, strong ellipticity for every compression, or physical stability at arbitrary strains.

## 5. Writing memory has an explicit energy account — ADDED and DERIVED

The energy conjugate of a record is

\[
Y_{k,s}=\partial W/\partial m_{k,s}
=\tfrac12G_{k,s}f'(m_{k,s})(e_k^{str})^2\ge0.
\]

For positive write rate k_w and rate scale r_*>0, define candidate recording rates

\[
N_{k,+}=k_w\frac{[r_k]_+^2}{[r_k]_+^2+r_*^2},\quad
N_{k,-}=k_w\frac{[-r_k]_+^2}{[-r_k]_+^2+r_*^2}.
\]

They lie between zero and k_w. Extending and shortening enter their own channels. New evidence can change the relative pattern of channel expression while older records remain present.

Define viscous stress power Q_v=2μD:D≥0, proposed writing power P_raw=ΣY N, an allocation fraction 0≤η≤1 and a strictly positive power scale P_*. Then

\[
\lambda=\frac{\eta Q_v}{P_*+\eta Q_v+P_{raw}},\qquad
D_tm_{k,s}=\lambda N_{k,s}.
\]

This is the complete implemented recording law. It follows the parcel and has no decay, reset or subtraction. It gives

\[
0\le P_{write}=\sum Y_{k,s}D_tm_{k,s}\le\eta Q_v,
\qquad Q_{heat}=Q_v-P_{write}\ge0.
\]

The derivation of the mechanical power identity is

\[
D_tW=\tau_{el}:D+P_{write}.
\]

Accordingly, the heat equation uses Q_heat, **not Q_v a second time**. A numerical implementation that changes stiffness while leaving both W and heat unchanged would violate this accounting.

This assigns some mechanical dissipation budget to restructuring. It does not establish a molecular writing cost. In particular, Y can be zero at an unstrained instant: this candidate charges only the change in its declared W, not an invented universal cost per memory. Temperature-only exposure does not write m in this candidate. Hydration, permanent rearrangement, softening or chemical storage require distinct added laws and evidence.

Units: F, e^{str}, m, f and λ are dimensionless; D, r, r_* and k_w are s⁻¹; G and Y are Pa=J/m³; Q_v, P_raw, P_write and P_* are W/m³. These units prohibit treating the input accumulator A as an energy budget without a separate conversion law.

## 6. How S passes through the changed structure — ADDED

With current unit directions n_k=d_k/|d_k|, choose the conductivity tensor

\[
K_T(F,m)=k_0I+\sum_{k,s}\Delta k_{k,s}f(m_{k,s})n_k\otimes n_k,
\quad j_T=-K_T\nabla\theta,
\]

where k_0>0 and Δk≥0 in W/(m K). Every conductivity eigenvalue lies between k_0 and k_0+ΣΔk. This explicit branch makes exposed directions better conductors. Whether real material conducts more or less after movement is an experimental question, not decided by the metaphor.

With constant volumetric heat capacity ρc_v,

\[
\rho c_vD_t\theta=Q_{heat}-\nabla\cdot j_T+r_T,
\quad E=\tfrac12\rho|u|^2+W+\rho c_v\theta,
\]
\[
\boxed{S_E=Eu-Tu+j_T},\qquad
\partial_tE+\nabla\cdot S_E=(b_C+b_{ext})\cdot u+r_T.
\]

S_E is measured relative to a declared laboratory frame. It carries advected energy, stress work and heat; it is not simply a moving dot or speed. At u=0 it can remain nonzero because j_T can remain nonzero. Conversely a record m can remain when every current flux is zero.

For θ>0 the material's entropy production is

\[
Q_{heat}/\theta+(\nabla\theta)\cdot K_T\nabla\theta/\theta^2\ge0.
\]

This result assumes the stated temperature-independent mechanical W, constant heat capacity and no extra thermomechanical constitutive terms. These assumptions must be revised together if temperature or hydration is allowed to change elasticity.

The source-force power remains an **external signed power entry**. A supply ledger can use E_supply′=−∫b_C·u dx; this is bookkeeping, not a specified physical generator with unlimited free fuel. Any physical implementation must name that generator and its limits. A passive, undriven version of these additions does not establish a self-sustained rhythm.

For the mathematics of stored energy, stress and internal variables, the conventions were checked against [Bower's constitutive requirements](https://solidmechanics.org/Text/Chapter3_1/Chapter3_1.php), [hyperelasticity](https://solidmechanics.org/Text/Chapter3_5/Chapter3_5.htm), and [Berezovski's internal-variable formulation](https://pmc.ncbi.nlm.nih.gov/articles/PMC10217598/). The specific writing limiter, directional records and conductivity rule here are task-specific additions, not formulas attributed to those sources.

## 7. Body, surroundings, boundaries and initial state

The field formulation has a moving material body Ω_b(t), a surrounding region Ω_e(t), and their interface Γ(t). Use a Newtonian exterior with its own ρ_e, μ_e, c_{v,e}, positive conductivity and context diffusivity; set W_e=0 and omit m in that reference exterior. Body memory stays with body parcels. The surroundings can carry momentum, heat and context; they are not a sink where exported quantities disappear.

**Added reference interface closure**, with the normal n from body to exterior and velocity v_Γ:

\[
u_b=u_e=v_\Gamma,\quad T_bn=T_en,\quad
\theta_b=\theta_e,\quad j_{T,b}\cdot n=j_{T,e}\cdot n.
\]

This assumes no slip, no interfacial mass transfer, no surface energy and no contact thermal resistance. The relative energy flux is

\[
(S_E-Ev_\Gamma)\cdot n.
\]

It matches across Γ under these conditions. Subtracting Ev_Γ is necessary: motion of the boundary itself is not energy leaking through it. The internal transfer cancels when the two regions' energy budgets are added.

Context uses a **different** proposed interface law

\[
(-D_b\nabla C_b)\cdot n=(-D_e\nabla C_e)\cdot n
=\Lambda(C_b-C_e),\quad \Lambda\ge0.
\]

Λ has units m/s; this is not the heat conductivity. There is no exterior copy of K_h J. Over body plus exterior, the context budget counts that source once and subtracts any outer export. The membrane-style context jump law and perfectly contacted temperature law concern different quantities.

For a closed reference field experiment the outer boundary is stationary, no-slip, thermally insulated and has zero normal context flux. This keeps energy within the modeled body-plus-surroundings except for explicitly counted source/body work. An open-world experiment must replace those conditions and accumulate outgoing energy/context in external ledgers; it may not interpret leaving the chosen domain as annihilation.

A source-off fresh initial state is χ(X,0)=X, F=I, u=0, m=0, A=0, C_b=C_e=0, equal positive θ_0 and matched constant pressure. With b_ext=0 it is a consistent rest state. A prior-history start must load its actual m and other fields, not silently initialize them to zero. The earlier gravity-equilibrated starts belong to the optional gravity comparison.

These statements close the types of coupling conditions. A full numerical run still needs an actual body/exterior geometry, parameter values, U(t), spatial input/kernel details, mesh, integration and convergence protocol. `decisions.json` keeps **physical run parameters uncalibrated**. The concrete component experiments in section 9 specify their own geometry, data and synthetic parameters separately.

The model does not yet prove inward gathering or attraction. The original fixed-direction b_C is not automatically a gathering force; uniform C can produce no b_C, and pressure can balance some forces. The user's new name for the coupled process is not used to invent an extra attractive force without an equation.

## 8. Upper-half doubling stays separate

Use height H(x,t)=vertical·(x−current body volume centroid), measured in the physical laboratory orientation. Let π pair reference parcels by an involutive volume-preserving reflection, transported by χ. The selected det F=1 stage preserves that equal-volume pairing. If growth is added later, this conservation argument must be revised.

\[
w(H)=\begin{cases}0&H\le0,\\H^2/(H^2+\ell^2)&H>0,\end{cases}\quad
D_C(x)=k_m w(H_x)w(H_{\pi x})B_m
\tanh\!\left(\frac{C(\pi x)-C(x)}{B_m}\right).
\]

The reverse term is its negative. Both directed terms are **exactly zero** if either endpoint is at or below the mid-plane, for arbitrary finite local states. This is a spatial eligibility rule, not a rule that C or memory must be binary. Above it, strength varies continuously. The height gate is C¹, not C², at zero.

This term preserves the total paired context and reduces pair disagreement. It is a proposed alignment interaction, not a derived Girardian rivalry law. It influences mechanics only through the original C-gradient force. It neither writes nor resets m directly, and does not replace K_h J. Ordinary motion, stress, heat and context diffusion can affect lower regions even though this **specific direct interaction** is off there.

## 9. Executed component experiments and controls

`structural_memory.py` implements the added constitutive law and reference fluxes. `run_structural_memory.py` executes the experiments and saves numerical results and plots. All parameters are explicitly synthetic.

**Material probe:** six reference directions (three axes and three positive diagonal directions), two records each; G_0=1000 Pa, each G_history=250 Pa, μ=100 Pa·s, m_*=1, k_w=0.8 s⁻¹, r_*=0.2 s⁻¹, η=0.35, P_*=0.1 W/m³. Impose three 4-second simple-shear pulses of amplitude 0.6, then four seconds at F=I. Use RK4 with 0.01 s steps. Compare a fresh state and the recorded state under the same instantaneous readout deformation; keep memory frozen during that readout. No autonomous oscillator is being integrated. Stress power from the imposed driver is recorded.

**Transfer probe:** a stationary 40 mm planar slice, body 0–20 mm and surroundings 20–40 mm, unit cross-sectional area, 80 uniform finite-volume cells and insulated endpoints. Both have ρc_v=2×10⁶ J/(m³ K). Start the body at 303 K, exterior at 293 K. Compare fresh and previously recorded body structure, each initially at F=I. The body uses k_0=0.2 and each Δk=0.08 W/(m K); the exterior uses k=0.2. Resolve 2000 s with a monotone explicit step restricted by the maximum conductivity. Shared harmonic face fluxes count interface energy with opposite signs.

The thermal comparison starts from **separately specified identical temperatures** to isolate the structural effect. It is not presented as a continuous replay of the mechanically heated material. Matching those temperatures in a physical experiment would require equilibration with a reservoir and an associated heat account.

Controls and independent checks include: fresh/no-write behavior; record retention through rest; separate extension/shortening records; objectivity under rotation; finite-difference derivatives of W against stress and memory conjugates; positive and bounded conductivity; writing power and entropy signs; time-step refinement; removal of the mechanical or conductivity coupling; a standard diffusion eigenmode; interface-energy conservation and grid refinement; exact lower-region pair exclusion; and unchanged source behavior after an input pulse.

The overview plot answers a limited question: **can this explicit added model retain a structural trace, change the next response and alter transfer while accounting for energy?** It cannot tell us whether these coefficients or this hardening branch describe real clay. The tests do not establish a rhythm, synchronization, a new orbit ordering, molecular memory or a complete three-dimensional solution.

## 10. Read and reproduce

- `report.html`: plain-language overview, pictures and measured scope of the numerical checks.
- `structural_memory_overview.png`: movement, retained traces, changed response and transfer.
- `structural_energy_accounting.png`: mechanical work and body/exterior heat balance.
- `structural_record_history.csv`: timestamped retained state from the material probe.
- `structural_memory_results.json`: all synthetic constants, protocol and numerical outputs.
- `structural_memory_checks.json`: independent test results, tolerances and refinement metrics.

Run `python run_structural_memory.py`, then `python check_structural_memory.py` from this folder with NumPy and Matplotlib available. The earlier `check_specification.py` and `check_holding_energy.py` remain reproducible historical checks; their results must not be represented as additional full-field evidence.

No source document, board contents or existing orbit result is rewritten by these additions. A future change to a softening, plastic, hydration or growing-material branch must update the stored energy, evolution law, transfer law and verification together.
