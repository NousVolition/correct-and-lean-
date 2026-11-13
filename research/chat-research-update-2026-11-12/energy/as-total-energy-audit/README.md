# Can the unchanged A/S equations conserve total energy?

**Result: a conserved cumulative energy account can be proved; a universal conserved energy consisting of kinetic energy, viscous heat and a function of the current A/S state is ruled out by an exact solution admitted by the supplied equations.** The original equation files and previous energy proofs are unchanged. All formal claims and verification scope are listed in `verification.json`.

This addresses the original A/S–Navier branch selected by the author. Hug remains part of the intended single unforced continuum. The example below tests the written representation; it does not replace Hug with an actuator, an external breathing drive, or a different force law.

## The exact condition for conservation

Write the previously proved closed-boundary kinetic balance as

\[
E_K'=-\mathcal D+\mathcal P_{AS},\qquad
\mathcal D=\mu\int_\Omega|\nabla u|^2\,dx,\qquad
\mathcal P_{AS}=-\sigma\int_\Omega a(|\nabla S|-\Gamma_{crit})u_k\,dx.
\]

If H accounts for the viscous loss as heat, \(H'=\mathcal D\), then

\[
(E_K+H)'=\mathcal P_{AS}.
\]

Consequently, an internal energy I closes the total budget precisely when

\[
\boxed{I'=-\mathcal P_{AS}.}
\]

`EnergyAccounting.conservation_iff_exchange` proves this equivalence, assuming the displayed derivative balances. It does not assume or prove that the original A/S evolution supplies this I. Boundary heat loss or other energy inputs would need to appear in the corresponding budget; the equality here concerns a closed total account.

## Viscous heat, including the source's coefficient distinction

The source explicitly writes the symmetric stress

\[
T=\mu_0(\nabla u+\nabla u^T).
\]

`ViscousHeat.lean` proves directly from that definition

\[
T:\nabla u=2\mu_0 D_u:D_u\ge0,
\qquad D_u=(\nabla u+\nabla u^T)/2,
\]

for \(\mu_0\ge0\). It also proves

\[
T:\nabla u=\mu_0\left(|\nabla u|^2+
\sum_{i,j}\partial_j u_i\,\partial_i u_j\right).
\]

Thus the integral of the source stress heating agrees with the kinetic loss \(\mu\int|\nabla u|^2\) when **\(\mu_0=\mu\)** and the cross-term integral vanishes. Both conditions are explicit hypotheses of `bulk_heat_matches_kinetic_loss`. Deriving the cross-term boundary identity for a selected domain remains a separate analytic obligation. The two coefficients were not silently equated in the source; their agreement is part of a compatible physical interpretation. In particular, the earlier local gradient-norm dissipation term is not automatically the pointwise symmetric-stress heating density.

The unchanged A/S equations contain no temperature or heat evolution field. Integrating their kinetic loss gives a passive heat account, with nonnegative cumulative heating when the loss rate is nonnegative. This does not establish a temperature law, conductivity, entropy law, or thermal feedback.

## Exact obstruction for energy stored only in the current A/S state

Choose the admissible source parameters

\[
\rho=\mu=\mu_0=\sigma=\gamma=\kappa=1,
\qquad D_{diff}=0,\quad \Gamma_{crit}=0,\quad U=U_{baseline}=0,
\]

and the original sharp response. In two spatial dimensions take

\[
A(t)=0,\qquad S(t,x,y)=y,\qquad
u(t,x,y)=(-(t+1),0),\qquad p=0.
\]

Lean proves that these fields satisfy **the original `FullDifferentialAt` equations at every time and point**, for any source kernel K and any domain. The localized source is zero because A is zero. The source's admissibility predicate permits zero scalar diffusion; viscosity remains strictly positive. This example is a permitted parameter specialization, not a change to the equations or a claim about the author's chosen parameter values.

The example has these exact properties:

- S and the stored A are unchanged for all time.
- The velocity is incompressible and spatially uniform.
- The original coupling accelerates the flow: \(\partial_tu=(-1,0)\).
- Both velocity-gradient dissipation and the source stress power are zero.
- The kinetic-energy flux divergence is zero.
- The kinetic-energy density is \((t+1)^2/2\).

`channelKinetic` integrates this density exactly over the unit square; the result is the same \((t+1)^2/2\). This can be read as a channel periodic in x with impermeable slip walls in y: u and S match across the x faces, the wall-normal velocity vanishes, stress vanishes, and scalar diffusion is zero. The formal development checks the PDE, zero kinetic flux divergence, wall-normal velocity, stress, scalar diffusive flux, and iterated spatial energy integral. It does not construct a manifold quotient or prove a general boundary/divergence theorem. These are test boundary conditions, not a selection of the author's intended domain.

Let \(F(A,S)\) be **any** real-valued functional of A and the entire instantaneous S field. This includes arbitrary nonlocal or gradient-dependent constructions determined by that field. Because both arguments stay fixed, F stays fixed, without even requiring differentiability of F. If H changes only by viscous heating, it also stays fixed here. Lean then proves

\[
\boxed{
[E_K+F(A,S)+H]_{t=1}-[E_K+F(A,S)+H]_{t=0}=\frac32.
}
\]

This is the theorem `Witness.channel_energy_growth`; `Witness.no_conserved_state_energy` states the resulting impossibility of conservation for all times in this example. It rules out a universal conservation claim of this specified form over the parameter/domain choices admitted by the supplied equations. It does **not** rule out conservation in special cases, another physically justified energy depending on additional configuration/history variables, or a more constrained model with independently established conditions. The Lean witness is two-dimensional, within the source's arbitrary-finite-dimension formulation.

## What can be conserved without changing the flow

For continuous dissipation and coupling power, define passive accounts

\[
H(t)=\int_0^t\mathcal D(s)\,ds,
\qquad
R(t)=R(0)-\int_0^t\mathcal P_{AS}(s)\,ds.
\]

Then Lean proves

\[
\boxed{E_K(t)+H(t)+R(t)=E_K(0)+R(0).}
\]

`EnergyAccounting.history_account_constant` proves this from the kinetic balance. Neither account feeds back into or modifies the original u, S or A equations. R is a signed work history; identifying it with physical A/S internal energy requires further justification. It is not determined by the instantaneous A/S state in the exact example above, and no lower bound, finite available storage, or constitutive interpretation is proved.

For that example, \(\mathcal P_{AS}=t+1\), so elementary integration gives \(R(t)=R(0)-t-t^2/2\). This illustrates why the conserved account by itself cannot certify a finite physical store supplying the flow indefinitely. Conservation was built into the definition of R; the substantive missing connection is to the intended internal mechanism and its available energy.

## Source checks and next mathematical requirement

The preserved 638-paragraph corrected-corpus extraction was searched read-only for energy, heat, dissipation and potential-energy language, and its A/S passages were compared with the preserved model files. It contains the directional-force energy caveats but no supplied A/S internal-energy or thermal evolution equation was found in this scoped search. This is a finding about the inspected local source, not an exhaustive claim about every prior conversation, remote file, or the author's broader idea. The extraction's historical DOCX provenance is recorded separately; the original DOCX was not freshly extracted here.

The next requirement is a source-grounded energy representation for the same continuum that satisfies \(I'=-\mathcal P_{AS}\), plus the intended thermal and boundary accounting. Possible additional configuration or history dependence must be identified from the intended model, not invented and then reported as already proved. The original A/S state-only class has the explicit obstruction above. An arbitrary chosen work ledger does not resolve that identification.

## Reproduction and verification scope

New modules:

- `EnergyAccounting.lean`: exact conservation condition and conditional cumulative-account conservation.
- `ViscousHeat.lean`: source stress heating, positivity and conditional bulk match.
- `ASCounterexample.lean`: an exact source solution and failure of universal current-A/S-state energy conservation.
- `TotalEnergyAudit.lean`: axiom inspection of every new theorem.

The previous five source/proof modules are included unchanged, with their earlier successful build receipts and hash checks. The three new modules and axiom audit were compiled in this task with native Lean 4.34.0-rc2 and the existing pinned Mathlib cache. `verification.json` distinguishes inherited checks from new ones. No unfinished proofs or extra axioms are accepted. A fresh dependency download, independent external kernel, and numerical-solver validation are not claimed.

```powershell
./build-native.ps1 -ToolchainBin '<Lean bin directory>' -DependencyRoot '<directory containing Mathlib and its dependencies>'
```

This package establishes the accounting result and its obstruction. It does not establish a closed physical total-energy theorem for the intended Hug system, PDE well-posedness, or global regularity of general solutions.
