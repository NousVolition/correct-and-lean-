# From guard transport to the full difference-energy inequality

The new theorem controls the two guard transport residuals by the full difference energy. It does not yet assert the time derivative inequality for that energy. This note identifies the exact connection and the remaining proof obligations for the unchanged field equations.

## 1. Use the full difference energy

For two existing histories with the same initial fields and inputs, write

\[
v=u-\widetilde u,\quad \alpha=x_A-\widetilde x_A,\quad
\beta=x_B-\widetilde x_B,\quad h=g_{AB}-\widetilde g_{AB},\quad
j=g_{BA}-\widetilde g_{BA}.
\]

Define the mathematical comparison functional

\[
E(t)=\tfrac12\int_{\rm cell}(|v|^2+\alpha^2+\beta^2+h^2+j^2).
\]

`differenceFields` in `EnergyDefs.lean` constructs the six actual field differences. `differenceEnergy` integrates the existing model's quadratic `energy` applied to those differences. No finite grid or replacement field is used. Each square is nonnegative, and equal initial fields give zero initial difference energy. This functional does not assign measured personal or physical energy to the participant-state squares.

## 2. Put both checked guard estimates into this energy

Let \(U=\|v\|_2^2\), \(H=\|h\|_2^2\), and \(J=\|j\|_2^2\). The previous uniform-gradient theorem supplies one finite \(M\) for both comparison guards throughout the chosen interval, under `FieldProblem` for both histories and the extra `JointGuardGradientRegularity` assumption for the comparison history. Its two transport estimates imply

\[
|R_{AB}|+|R_{BA}|\le U+\tfrac{M^2}{2}(H+J).
\]

Because \(U\le2E\) and \(H+J\le2E\),

\[
\boxed{|R_{AB}|+|R_{BA}|\le (2+M^2)E.}
\]

The new Lean theorem `fieldproblem_guard_transport_energy_bound` proves this connection as \(\exists C_g\ge0,\ \forall t\in[a,b],\ |R_{AB}|+|R_{BA}|\le C_g E(t)\), with witness \(C_g=2+M^2\). This is a convenient, nonoptimal constant. Its proof establishes integrability from spatial regularity and compactness, splits the actual energy integral into its components, and invokes the previous uniform guard estimate. It does not assume the desired energy inequality.

## 3. The time interchange is now conditional and checked; the full balance remains

`TimeIntegral.lean` now proves the pointwise difference-density chain rule and passes its derivative through the fixed cell integral at interior times. Its extra hypothesis is joint continuity of the explicitly defined scalar rate density on the closed time-cell. This condition is not derived from the previous guard-gradient assumption or the original `FieldProblem`. [The exact assumptions and proof steps](TIME-DERIVATIVE-ASSUMPTIONS.md) are recorded separately.

Under the stronger joint classical regularity in `CLASSICAL-UNIQUENESS-ARGUMENT.md`, the required two-history integrated balance has the form

\[
E'+D_\nu+D_s+D_r=\mathcal R_g+\mathcal R_{\rm other},
\qquad \mathcal R_g=-R_{AB}-R_{BA}.
\]

Here, with \(Dv=(\nabla v+\nabla v^T)/2\) and \(Q=\|Dv\|_2^2\),

\[
D_\nu=2\int\nu(z)|Dv|^2,\quad
D_s=\tfrac1{50}(\|\nabla\alpha\|_2^2+\|\nabla\beta\|_2^2)
+\tfrac3{200}(\|\nabla h\|_2^2+\|\nabla j\|_2^2),
\]
\[
D_r=\|\alpha\|_2^2+\|\beta\|_2^2+\tfrac53(H+J).
\]

This identity must be derived from the actual difference equations: justify differentiating the cell integral in time, cancel pressure and common transport, and integrate the complete variable-viscosity stress and scalar diffusion terms by parts. The single-history pointwise `full_material_energy_balance` in `FullChecks.lean` and the checked common-transport cancellation are useful ingredients; neither alone supplies this integrated difference balance.

**The remaining bridge is the stress, pressure and diffusion part of this integrated two-history balance.** The time-interchange part has a conditional Lean proof. The guard-gradient condition alone does not supply its new rate-density hypothesis or the stronger component regularity needed for all later steps.

## 4. Bound every remaining term and retain positive viscosity

The other terms require uniform bounds on the comparison velocity gradient, participant-state gradients and values, and the strains of both histories. Under the stronger classical assumptions, these are obtained on a compact finite time-space region. Those additional formal bounds have not been supplied here.

| Remaining contribution | Required estimate or identity |
| --- | --- |
| Momentum residual transport \(-\int v\cdot((v\cdot\nabla)\widetilde u)\) | A constant times \(E\), using a uniform comparison velocity-gradient bound. |
| Participant-state residual transport and coupling reactions | A constant times \(E\), using bounded state gradients, values and guards; identical prescribed inputs cancel. |
| Viscosity mismatch \(-2\int\delta\nu D\widetilde u:Dv\), where \(\delta\nu=(h+j)/25\) | \(C_\nu E+\varepsilon_\nu Q\). Retain the full variable stress. |
| Guard target differences, including their dependence on squared strain | \(C_\sigma E+\varepsilon_\sigma Q\), using the sigmoid Lipschitz bound and uniform strain bounds. The negative guard relaxation is already in \(D_r\). |

For source initial data, both guards start at \(1/2\). The written maximum-principle argument must still be formalized to show they remain in \([0,1]\). The existing local inward-boundary signs do not by themselves prove this invariant range. The range would give \(\nu(z)\ge\nu_0=1/50\), hence \(D_\nu\ge2\nu_0Q\). The existing pointwise viscosity lemma is conditional on that range.

## 5. The precise conditional assembly

Once the balance, invariant range, and the remaining bound
\(\mathcal R_{\rm other}\le C_{\rm other}E+\varepsilon Q\), with \(\varepsilon<2\nu_0\), have been proved, the checked guard contribution fits as follows:

\[
E'+(2\nu_0-\varepsilon)Q+D_s+D_r
\le (C_g+C_{\rm other})E.
\]

The terms retained on the left are nonnegative, so this yields

\[
E'\le CE,\qquad C=C_g+C_{\rm other}.
\]

Together with the required time regularity and \(E(a)=0\), Gronwall then gives \(E=0\). Spatial continuity converts equality almost everywhere to equality of the six fields. These final applications, the full balance and other estimates above are still to be formalized for the actual solutions. Existence, continuation, and deriving the stronger regularity from the original `FieldProblem` predicate remain separate open obligations.

The new theorem has one explicit endpoint: guard transport is controlled by the full difference energy. The prime-17 numerical experiments are not premises of the theorem or substitutes for the remaining space-time arguments.

## Verification

The energy statement and definitions were recorded before the new proof file was written, as recorded in `energy-reference-freeze.json`. The definition and proof modules are included in the default build, and the new theorem is Comparator target 14. [The saved fourteen-target Linux receipt](evidence-linux/historical-fourteen/source.json) pins proof commit `fdc6b5277d67f4b9ee8d16b50641bac20a67e6df`: Comparator, Lean's kernel, nanoda, the full package build and all 14 axiom lists passed. The previous thirteen-target receipt is retained under `evidence-linux/historical-thirteen/`. These checks establish the displayed guard-to-energy bound under its hypotheses; they do not establish the still-open time-dependent energy inequality.
