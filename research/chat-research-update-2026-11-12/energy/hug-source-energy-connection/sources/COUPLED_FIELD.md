# Coupled Hug field: source, movement, structural memory and surroundings

This is the current implementation specification. It replaces the component-only status of `STRUCTURAL_MEMORY.md`. The older files and results remain available as historical tests; they are not counted as evidence of this coupled run.

**Scope selected by the user:** changes within existing material first. The body does not gain or shed matter. The simulation is three-dimensional and evolves the supplied accumulated source, context field and momentum equation together with the added structural-memory and thermal laws. No deformation trajectory, oscillation or recovery time is imposed.

**What “complete” means here:** every state equation, coupling, initial condition, computational boundary, coefficient and numerical method for this particular synthetic model is specified and implemented. This does not make the added material laws uniquely implied by the corpus, establish physical clay parameters or identify a universal model of memory. The model is a regularized immersed-material continuum, not a sharp-interface limit certified at zero regularization width.

## 1. Source and addition ledger

| Component | Origin and treatment |
|---|---|
| A′=γ(U−U_b), J=κA | **SOURCE**, DOCX paragraphs 517–539; Miro 06, 13 and 16. Accumulation is not replaced with instantaneous production or reset. |
| C_t+u·∇C=D_diff ΔC+K_hJ | **SOURCE**, with the corpus scalar S written C to distinguish its units from energy transfer. A separate mimetic term is added. |
| ρD_tu=−∇P+μΔu−σa(q)e_k; div u=0 | **SOURCE**, DOCX 230–266 and 546–551, Miro 05 and 20. Elastic stress is an explicit addition. |
| Smooth exact-off response and cutoff-preserving regularized gradient | A declared **SOURCE BRANCH**; sharp and signed-tanh branches are separately tested. Their below-threshold behavior is not interchangeable. |
| Memory changes structure, S transfers through it and surroundings | **USER INTENT**. The rock/tree/onion analogy is not claimed to supply a constitutive formula. |
| Elastic energy, directional records, bounded expression, thermal conductivity | **ADDED constitutive hypotheses**. They were absent from the supplied equations. |
| Chronological retained records plus a separately fading expression state | **ADDED**. The board discusses persistence alternatives; the user's no-erasure requirement selects retention of the encoded traces. Fading applies to expression, not A or the retained record. |
| Graded upper-half paired influence | **ADDED**, separate from source K_hJ and from recording. Both partner eligibility and the receiving spatial kernel are gated. |
| Moving immersed body, periodic surroundings, equal density and base viscosity | **ADDED computational realization**. No claim that these synthetic parameters describe clay, air or water. |
| Nonlocal interaction flux in S | **ADDED closure convention**, derived to account for spatially regularized interaction power. It is explicitly shown rather than hidden in a heat source. |

The original DOCX is unchanged. The fresh board survey searched all 58 areas matching the field, memory, force, energy, boundary and transport terms, then read 31 matching frames plus the two image items. Readable text and shape content were inspected, including the source branches, persistence labs, coupling obligations and recommendations. Some returned foreign items are not exposed as readable equations by the connector; their counts are retained in the private evidence. The two images are small lexical/coding illustrations, not readable constitutive specifications. No claim of exhaustive pixel transcription is made.

The board recommends some memory-decay comparisons. These are treated as proposals to evaluate, not commands overriding the user's requirement that encoded traces remain. Social coding tables and identity categories do not become physical material parameters or the definition of “upper.”

## 2. Domain, units, geometry and initial data — ADDED

The domain is the periodic cube Ω=[−1/2,1/2)³. Opposite faces are identified. This is a finite surrounding world with no absorbing edge: material and energy crossing an outer face re-enter at its opposite face. It is not an infinite ambient domain or a vacuum boundary.

The initial material body is the filled ellipsoid with semiaxes (0.22,0.17,0.19), centered at the origin. Its quadrature parcels have reference positions X_p and fixed positive reference volumes V_p. Radial and polar Gauss quadrature and uniformly spaced azimuths define the material sampling. The reference body is a declared geometry, not a shape inferred from the metaphor or fitted to old animations.

All simulation values use **dimensionless synthetic units**. Choose independent reference length L₀, time T₀, density ρ₀ and context scale C₀ before converting to physical data. Velocity scales as L₀/T₀, stress and energy density as ρ₀L₀²/T₀² and energy flux as ρ₀L₀³/T₀³. The chosen nondimensional density and volumetric heat capacity are one. A temperature scale would also have to be specified consistently for a physical conversion. No model time is reported as a measured second.

Initial data are u=0, C=0, A=0, χ(X,0)=X, F=I, retained records m=0 and expression state z=0. The absolute nondimensional temperature is 1 plus a smooth localized excess of amplitude 0.03 and axis widths (0.19,0.14,0.16). That declared initial heat allows outward transfer to be observed; it does not prescribe the motion. Pressure is determined by incompressibility, with zero-mean pressure gauge.

The main source has positive excess input sin²(2πt) on 0<t<0.5, followed by −sin²(2π(t−0.5)) on 0.5≤t<1, and zero afterward. γ=0.08 and κ=1. Thus A returns to zero by cancellation, not by a reset. The context total should remain 0.01 after t=1. A separate positive-pulse case stops input at 0.5 without the negative pulse; it retains A=0.02 and continues producing context. This directly tests the board's distinction between stopping input and stopping its accumulated influence.

The complete coefficient and case matrix is `coupled_case_matrix.json`. Changing a number changes a declared synthetic model; none is an entered measurement.

## 3. Supplied context and momentum equations

\[
\dot A=\gamma(U-U_b),\quad J=\kappa A,
\]
\[
\partial_tC+\nabla\cdot(Cu)=D_{diff}\Delta C+K_h(\chi)J+D_{pair},
\quad\int_\Omega K_h\,dx=1,
\]
\[
\partial_tu+(u\cdot\nabla)u=-\nabla P+\nu\Delta u
+\nabla\cdot\tau_h+b_C,\quad\nabla\cdot u=0.
\]

The added elastic stress τ_h is defined below. The source is written once. Its material weights are a normalized Gaussian centered at reference position (−0.065,0.045,0.025) with width 0.08, carried by the moving material and spread through a positive normalized spatial kernel. This is an explicit moving smooth K_h, including its regularization tails; it is not two independent body and exterior sources.

For the main branch,

\[
b_C=-\sigma a(q)e_x,\quad
q=\sqrt{|\nabla C|^2+\delta^2}-\sqrt{\Gamma^2+\delta^2},
\quad a(q)=\begin{cases}0&q\le0,\\q e^{-(\epsilon/q)^2}&q>0.\end{cases}
\]

The x direction is a declared fixed laboratory direction. The norm discards the sign of ∇C, as the board points out. This is not secretly converted to an inward, restoring or dissipative force. The actual signed power ∫u·b_C is independently integrated in the energy ledger.

No additional gravity, orbital clock or forcing oscillator is present in these runs. The original potential-holding proposal remains a historical optional load, not the current definition of the Hug.

## 4. Moving structure and retained chronology — ADDED

Let I_h interpolate the band-limited velocity to a material parcel, using a Gaussian spectral smoothing width ℓ_v. Its derivative is evaluated consistently:

\[
\dot\chi_p=I_hu(\chi_p),\quad
L_p=\nabla(I_hu)(\chi_p),\quad \dot F_p=L_pF_p.
\]

I_hu is analytically divergence-free in the retained Fourier space, hence det F is constant in the continuous-time semi-discrete equations. Time-integration drift is measured; F is **not** renormalized to hide it. This is a regularized no-slip coupling to the interpolated velocity, not an assertion that the unfiltered grid value equals parcel velocity at finite ℓ_v.

Choose six reference directions: the three axes and the positive xy, xz and yz diagonals. For each direction k there are separate extending/shortening channels s=+,−. Set d_k=F a_k, strain e_k=(|d_k|²−1)/2 and rate r_k=d_k·sym(L)d_k.

Retained traces m never decay:

\[
\dot m_{k,s}=\lambda N_{k,s}\ge0,\qquad
N_{k,\pm}=k_w\frac{[\pm r_k]_+^2}{[\pm r_k]_+^2+r_*^2}.
\]

The separate expression state obeys

\[
\dot z_{k,s}=\dot m_{k,s}-z_{k,s}/\tau_z,
\quad b_{k,s}=c_fm_{k,s}+(1-c_f)z_{k,s},\quad
f(b)=1-e^{-b/m_*}.
\]

Here c_f=0.35 in the main case. An old increment remains in m and retains a floor contribution to b; its recent contribution decays in z. The exact continuous relation is z(t)=e^{-t/τ_z}z(0)+∫₀ᵗe^{-(t−s)/τ_z}dm(s). Equal final m with different timing can therefore yield different current expression and response.

At every integration step the files retain the complete arrays m, z, χ and F. Differences between consecutive m arrays reconstruct every encoded increment and its timestamp. No diagnostic threshold, input stop, force cutoff or drawing operation deletes those records. The reduced response depends on stated functions of the record; it does not imply all histories produce distinct present responses. The model still encodes six directional channels, not unlimited event semantics or human/biological memory. This representational choice is explicit and testable.

## 5. Material energy, stress and transport — ADDED

With B=FFᵀ,

\[
W(F,b)=\frac{G_0}{2}(\operatorname{tr}B-3)
+\frac12\sum_{k,s}G_m f(b_{k,s})e_k^2,
\]
\[
\tau_p=G_0(B-I)+\sum_{k,s}G_m f(b_{k,s})e_k\,d_k\otimes d_k,
\quad Y_{k,s}=\frac{G_m}{2m_*}e^{-b_{k,s}/m_*}e_k^2.
\]

Stress is spread with the exact adjoint of I_h: τ_h=I_h*{V_pτ_p}. This gives the power identity ∫u·div τ_h dx=−ΣV_p τ_p:L_p. The same interface operator that moves the material therefore transfers its force back to the surrounding velocity field.

Define current unit directions n_k=d_k/|d_k| and positive normalized thermal interpolation R_h with width ℓ_T. The conductivity field is

\[
K_T(x)=k_0I+R_h^*\left\{V_p\sum_{k,s}k_mf(b_{p,k,s})n_{p,k}\otimes n_{p,k}\right\},
\quad j_T=-K_T\nabla\theta.
\]

The base fluid fills the domain; elastic response and added conductivity are immersed through material quadrature. Base density, viscosity and heat capacity are equal inside and outside. This deliberately avoids claiming a measured clay/air interface. It is one consistent regularized material-surroundings model, not the earlier sharp-interface membrane law. Its finite interaction widths are tested as model choices rather than hidden numerical constants.

Increasing expression hardens this candidate and increases conduction. Fading expression can soften the added response while m remains. Plastic strain, hydration, chemical storage and material growth are not covertly inferred from these formulas. A physical alternative must change the energy and evolution laws together.

## 6. Recording, fading and the combined energy balance

Let Q_v=2νD:D be grid viscous power and α=R_h*{V_p} the nonnegative material occupancy density. To prevent spatial spreading from overdrawing a local heat budget, define each parcel's available share

\[
B_p=R_h\{Q_v/(1+\alpha)\},\quad
P_{raw,p}=\sum Y_{p,k,s}N_{p,k,s},
\quad\lambda_p=\frac{\eta B_p}{P_*+\eta B_p+P_{raw,p}}.
\]

This **added nonlocal allocation rule** replaces the isolated-parcel budget used in the earlier component experiment. Set χ_p^w=P_raw,p/(P_*+ηB_p+P_raw,p). The grid extraction for writing is

\[
Q_{write}(x)=\frac{\eta Q_v(x)}{1+\alpha(x)}R_h^*\{V_p\chi_p^w\}.
\]

It satisfies 0≤Q_write≤ηQ_v pointwise and ∫Q_write dx=ΣV_pΣY ṁ. No energy is counted twice. The release when expression fades is

\[
P_{release,p}=\sum Y_{p,k,s}(1-c_f)z_{p,k,s}/\tau_z\ge0.
\]

The mechanical identity is Ẇ_p=τ_p:L_p+ΣY ṁ−P_release,p. Released energy is included as heat, not deleted:

\[
\partial_t\theta+\nabla\cdot(u\theta+j_T)
=Q_v-Q_{write}+R_h^*\{V_pP_{release,p}\}.
\]

Temperature represents an explicit mechanical/thermal transfer channel; it is not assigned a hydration or electrical meaning. These constitutive coefficients are temperature-independent, so thermal expansion is absent rather than silently included. Mechanical work changes the thermal field and structure changes conduction; temperature is not claimed to feed back on elasticity in this chosen branch.

The independently checked total is

\[
\mathcal E=\int_\Omega(\tfrac12|u|^2+\theta)dx+\sum_pV_pW_p,
\qquad \dot{\mathcal E}=\int_\Omega u\cdot b_C\,dx.
\]

The thermal diagnostic uses excess over the constant initial baseline for numerical accuracy. The unknown physical source of b_C work remains a signed external supply entry. A and C have context units and are not falsely labeled fuel.

### S in a spatially regularized model

The local continuum expression is S_loc=Eu−Tu+j_T, with material energy spread consistently into E. At finite interaction width, work is transferred between grid locations and material parcels nonlocally. S_loc alone is therefore **not** asserted to close a sharp local energy balance.

The implementation explicitly calculates the resolved residual R=∂_tE+div S_loc−u·b_C from the equations, including the derivative of the moving material energy distribution. It adds the declared periodic, zero-mean, minimum-L² interaction flux

\[
J_{int}=-\nabla\Delta^{-1}(R-\langle R\rangle),\qquad S_E=S_{loc}+J_{int}.
\]

This fixes a flux convention, not a unique microscopic transfer route. A divergence-free flux can be added without changing a local conservation equation. The unresolved spatial gauge and finite regularization are stated explicitly. The mean defect ⟨R⟩ is reported; it is never absorbed into heat or removed from the global energy ledger. The local residual check verifies this defined flux construction; the **independent global work/state-energy test** is what checks the energy accounting.

Products in this diagnostic are resolved in the same Fourier space as velocity and heat. No claim is made about local structure below the retained spatial resolution.

## 7. The upper-half pair interaction remains its own law

Pair reference material parcels by reflection in reference x, with equal V_p and an involutive partner map. Transport both partners by the solved flow. Their current heights H_p are measured above the moving body's volume-weighted centroid in the fixed laboratory z direction.

Use w(H)=0 for H≤0 and H²/(H²+ℓ_m²) for H>0. The receiving kernel is R_h multiplied by the **current grid-height gate** and renormalized. Call this positive operator R_U; its values are exactly zero below the physical mid-plane. Let c_p=R_U C and

\[
d_p=k_{pair}w(H_p)w(H_{\pi p})B_m\tanh[(c_{\pi p}-c_p)/B_m].
\]

The reverse term is −d_p. Both are explicitly set to zero if either partner is lower or on the plane. The direct grid term is D_pair=R_U*{V_pd_p}. This ensures exact lower-grid exclusion and zero integrated paired production. It also gives ∫C D_pair dx=ΣV_pc_pd_p≤0.

Only this direct interaction is off below the mid-plane. Advection, diffusion, stress and heat can still carry consequences there. A global Fourier filter is deliberately **not** applied to D_pair, because that would spread a sharply excluded source back into lower grid locations.

This is a proposed bounded alignment exchange, not a Girard-derived rivalry or amplification law. Its mechanical influence remains through C and the original b_C. It does not overwrite the material's retained records or stand in for K_hJ.

## 8. Numerical method and what the tests must distinguish

Velocity and temperature use Fourier collocation, a strict two-thirds retained-mode cutoff, periodic Gaussian-smoothed material interpolation and its adjoint stress spreading. The velocity equation uses the rotational form u×curl u and a Leray projection; the reported physical pressure subtracts the kinetic-energy pressure offset. Material velocity gradients are the derivatives of the same interpolant that moves the parcels.

Context uses conservative finite volumes with centered face states, centered diffusion and face-averaged normal velocities derived from the divergence-free Fourier velocity. Their discrete divergence is zero. This keeps the compactly gated pair source exact at lower grid locations and preserves ∫C without pretending a Fourier truncation preserves pointwise support. The context gradient in b_C uses centered differences, making its finite-grid approximation explicit.

All states advance together by classical RK4. No operator step prescribes the body trajectory; no post-step reset fixes volume, energy or memory. Synthetic baseline: 24³ grid points, 192 material quadrature parcels, Δt=0.005 and final model time 2. The validation suite independently varies time step, grid, material quadrature, response branch and interaction widths.

Required tests include:

1. Independent Fourier fluid and finite-volume diffusion benchmarks, pressure projection and a known advected scalar.
2. Interpolation-gradient consistency and adjoint mechanical work, not merely matching a displayed formula.
3. Complete-run context and total energy ledgers, positive temperature, retained trace monotonicity, div u and det F drift.
4. Immediate coupling probes: C changes acceleration; u changes transport and recording; m/z change stress and heat transport.
5. Zero-input and zero-force runs; removal of structural feedback, conductivity feedback and doubling; persistent-source and expression-fading controls.
6. Finer time steps, grids and material sampling. Tolerances and failures are reported separately from model sensitivities.
7. Exact direct mimetic exclusion at lower **grid** locations and lower material partners for arbitrary finite states.
8. Chronological reconstruction of encoded increments and a same-total/different-timing response comparison.

`check_coupled_analytic.py` additionally evolves an independent exact-solution control through the same full solver: a decaying transverse shear, a passive context mode, its viscous heating and thermal diffusion, and the corresponding smoothed material trajectory and deformation gradient. Three time steps are compared to analytic formulas. Elastic feedback, history writing and pairing are set to zero for this analytic control; they remain active in the main experiment. Rigid-rotation tests independently check the material energy, stress, conductivity and recording drivers.

`check_coupled_transfer_budget.py` repeats the main trajectory with extra diagnostic counters only. It integrates net advective/conductive heat transport into the fixed region |x| > 0.32 separately from heat generated there by viscosity and expression release. That region is an observation control volume, not an asserted sharp material boundary. The final grid is compared with the uninstrumented main run; a locally generated temperature increase is not counted as transported heat.

No finite-horizon computation proves a limit cycle, all-history uniqueness, all-parameter robustness, global PDE regularity or physical clay behavior. Those are different claims from completing and checking this coupled candidate.

## 9. Scientific-method references for the added numerics

[Chen and Peskin's Fourier spectral immersed-boundary method](https://arxiv.org/abs/2302.08694) motivates divergence-free interpolation and adjoint interaction work. This implementation uses direct tensor-product interpolation matrices, not their NUFFT implementation or their validated solver. Their convergence results are not imported as evidence for this code.

[Peskin's immersed-boundary formulation](https://www.cambridge.org/core/services/aop-cambridge-core/content/view/95ECDAC5D1824285563270D6DD70DA9A/S0962492902000077a.pdf/div-class-title-the-immersed-boundary-method-div.pdf), [Bower's constitutive requirements](https://solidmechanics.org/Text/Chapter3_1/Chapter3_1.php) and [Berezovski on internal variables](https://pmc.ncbi.nlm.nih.gov/articles/PMC10217598/) provide general numerical and thermodynamic context. The specific Hug memory, thermal allocation and upper-half laws remain the additions declared here.

The runnable source is `coupled_hug.py`; the case matrix and batch runner are `run_coupled_suite.py`; the independent checks are `check_coupled_hug.py`. The report must be built from saved outputs and their source hashes. The visualizations show solved material parcels and field slices; no drawing map enforces closure or supplies an uncomputed trajectory.
