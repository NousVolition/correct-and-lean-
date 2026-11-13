# Energy balance for the original A/S–Navier Hug

This package connects the energy calculation to the original A/S source equations selected by the author. It adds no external breathing drive, mechanical oscillator, guard law, fabric law, or replacement coupling. The source equation files are preserved byte for byte. Compiler and axiom results are recorded in `verification.json` and `logs/verified/`.

## The equations being used

The preserved source passages 229–230, 517–519 and 545–550 give

\[
\rho(\partial_t u+(u\cdot\nabla)u)
=-\nabla P+\mu\Delta u-\sigma a(q)e_k,
\qquad \nabla\cdot u=0,
\qquad q=|\nabla S|-\Gamma_{\rm crit},
\]
\[
\partial_t S+u\cdot\nabla S
=D\Delta S+K_h(x-x_0)\kappa A(t),
\qquad
A(t)=\int_0^t\gamma[U(s)-U_{\rm baseline}]\,ds.
\]

Here density and viscosity are spatially constant; the physical assumptions are \(\rho>0,\mu>0,\sigma\ge0,D\ge0\). The Lean source uses kinematic pressure \(p=P/\rho\), so the pressure flux in that notation is \(\rho p u\). The threshold response remains a parameter: sharp, signed tanh and exact-off laws are distinct alternatives. No gradient smoothing is inserted.

“Unforced” means that no additional external momentum drive is appended here. The original A/S coupling remains part of the one intended continuum. The source representation supplies \(U(t)\) as an input function; proving that the entire system is autonomous also requires its intended endogenous definition. It is not silently set to zero or to baseline.

## The energy result

Set \(e_K=\rho|u|^2/2\). For a sufficiently differentiable solution of those equations, the pointwise identity is

\[
\boxed{
\partial_t e_K+\nabla\cdot
\left[(e_K+P)u-\mu\sum_i u_i\nabla u_i\right]
=-\mu|\nabla u|^2-\sigma a(q)u_k.
}
\]

`OriginalASBalance.lean`, theorem `kinetic_local_balance`, proves this in arbitrary finite dimension. In Lean the flux is written as the sum of its three divergence contributions. The proof derives it from `OriginalAS.FullDifferentialAt`; it does not assume the energy identity itself. Its hypotheses explicitly require the coordinate derivatives of velocity, its first derivatives, and pressure to exist. Incompressibility comes from the source equation predicate.

With zero net boundary energy flux, integrable terms, and a justified interchange of time derivative and spatial integral, the result becomes

\[
\boxed{
\frac{d}{dt}\int_\Omega\frac{\rho}{2}|u|^2\,dx
=-\mu\int_\Omega|\nabla u|^2\,dx
-\sigma\int_\Omega a(q)u_k\,dx.
}
\]

`OriginalASIntegrated.lean`, theorem `kinetic_global_balance`, proves this conditional integrated statement from the source-derived local balance. It explicitly assumes the integral of the net flux vanishes and that differentiation under the integral is valid. It does **not** establish either assumption for an unspecified domain or boundary condition. Periodic cells with suitable regularity, or suitable closed boundaries, are possible settings to establish those assumptions in subsequent work.

This is a kinetic-energy budget. Viscosity removes kinetic energy when \(\mu\ge0\). Incompressibility makes pressure a transport term; pressure can still contribute boundary work unless the relevant flux vanishes. The coupling power is exactly

\[
\mathcal P_{AS}=-\sigma a(q)u_k.
\]

For nonnegative activation, flow with \(u_k\ge0\) gives nonpositive coupling work. With \(\sigma>0\), active positive response and \(u_k<0\), coupling work is strictly positive. These sign statements are Lean-checked. A positive local coupling contribution alone does not establish growth of the total kinetic energy: viscosity, other locations and boundary work also matter. For the sharp law, inactive response gives zero coupling power. The signed tanh alternative need not be nonnegative below threshold.

The original source also lists \(T=\mu_0(\nabla u+\nabla u^T)\). Its momentum equation uses \(\mu\Delta u\). This package follows that momentum coefficient \(\mu\); it does not assume an unstated identification \(\mu_0=\mu\), nor replace the dissipation term by a different stress law.

## What A and S account for

The source equations also imply the Lean-checked local square balance

\[
\partial_t(S^2/2)+\nabla\cdot[(S^2/2)u-D S\nabla S]
=-D|\nabla S|^2+\kappa A K_h(x-x_0)S.
\]

For continuous \(U\), Lean checks

\[
A'=\gamma(U-U_{\rm baseline}),\qquad
\frac{d}{dt}(A^2/2)=\gamma A(U-U_{\rm baseline}).
\]

These squares provide mathematical budgets, not an established physical energy for A or S. Their production terms do not automatically equal \(+\sigma a(q)u_k\), the term needed to cancel the kinetic coupling work. The current result neither proves total-energy conservation nor proves that no suitable internal-energy formulation exists. It identifies the transfer that such a formulation must account for. Viscous loss would also need its thermal accounting for a conserved total energy.

If \(U\) equals baseline over the **entire original history from time zero**, the declared integral gives \(A=0\) and hence \(J=\kappa A=0\); these special cases are checked. Merely returning to baseline at a later observation time does not erase accumulated A. Even with \(J=0\), a nonuniform existing S field can still activate the original momentum coupling.

## Connection to the previous six proof files

| Previous proof | Connection to this equation set |
|---|---|
| Guard effects | A different reduced/provisional closure. Its guard-dependent damping is not imported into the original A/S equation. |
| Breathing driver | An externally prescribed experiment. Its power term is absent here. |
| Pressure blindness | Its projection/observability result remains separate. The new proof directly establishes the original equation's pressure-work identity. |
| Clay fabric energy | Demonstrates energy/gradient/relaxation accounting for that specific fabric law. The original A/S source has no such law, so its energy cannot be substituted for A/S energy. |
| Field clay observations | An observation ambiguity result; it supplies no missing mechanical energy law. |
| Fabric memory/readout | A storage/readout result; it supplies no A/S energy exchange identity. |

The transferable lesson is to keep the actual stored quantity, its evolution and its work term together. The new energy theorem is proved directly for the selected source equations, with no claim that the six earlier modules were already a proof of this PDE balance.

## Verification and remaining work

The package contains 29 energy-related theorems and supporting lemmas, including a reproof of the previously checked original memory derivative. `ProofAudit.lean` prints the axiom dependencies for every one. See `verification.json` for the actual compiler result; a written theorem statement alone is not a verification receipt.

`FullModel.lean` remains only because the unchanged `OriginalAS.lean` imports it. The energy definitions and conclusions use the `OriginalAS` namespace, not the six-field model's equations. The two source modules and the copied source passages are hash-compared to the preserved local source. The DOCX and remote repository were not freshly re-audited; their provenance in the source manifest is historical evidence.

Rebuild with a matching Lean 4.34.0-rc2 installation and the pinned Mathlib dependency cache:

```powershell
./build-native.ps1 -ToolchainBin '<Lean bin directory>' -DependencyRoot '<directory containing Mathlib and its dependencies>'
```

The recorded verification uses the native compiler and existing pinned dependency cache. `lakefile.toml` and `lake-manifest.json` record the dependency configuration; a fresh network download and clean `lake build` are not claimed as tested.

Next mathematical obligations are to specify the intended domain/boundaries and solution regularity, identify the intended endogenous U law, and locate or formulate the A/S internal-energy accounting consistent with the source. No force law was changed to obtain a convenient energy sign. Existence, uniqueness, global smoothness, and numerical-solver correctness are not established by this package.
