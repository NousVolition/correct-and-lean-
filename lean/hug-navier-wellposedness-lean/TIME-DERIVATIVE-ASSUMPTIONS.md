# Passing the time derivative through the fixed cell integral

This step concerns the unchanged six-field continuum equations in `FullModel.lean`. It connects their pointwise time derivatives to the derivative of the full difference-energy integral. It does not rearrange stress, diffusion or reaction terms into an energy inequality.

## 1. Start at one position

For two histories, let \(\delta z=z-w\) denote the six field differences and define

\[
e_\Delta(t,x)=\tfrac12\sum_{k=1}^{6}(\delta z_k(t,x))^2,
\qquad E(t)=\int_{\rm cell}e_\Delta(t,x)\,dx.
\]

Let \(F_i(t,z,p)\) be the existing `fieldRates` function, including all transport, pressure, variable stress, diffusion and reaction terms. Define the explicit scalar rate density

\[
q(t,x)=\sum_{k=1}^{6}\delta z_k(t,x)
\bigl(F_i(t,z(t),p_z(t))_k(x)-F_i(t,w(t),p_w(t))_k(x)\bigr).
\]

`differenceRateDensity` is exactly this expression. It is not defined as the derivative of an integral and contains no assumed dissipation identity. `difference_density_hasDerivAt` uses the two existing `FieldDifferentialAt` assumptions and the ordinary chain rule to prove

\[
\partial_t e_\Delta(t,x)=q(t,x).
\]

## 2. State the additional assumption and its source

The new sufficient analytic assumption is `JointDifferenceRateRegularity`: **the explicitly defined scalar function \(q(t,x)\) is jointly continuous on \([a,b]\times[0,2\pi]^2\)**. This is a condition on the existing histories and rates, not a modification of their equations.

| Condition used | Where it comes from | Why it is used |
| --- | --- | --- |
| Both histories satisfy the same `FieldProblem` | Existing theorem hypotheses | Supplies their actual PDE time derivatives at interior times. |
| Spatial continuity of the six fields at each time | Derived from the spatial `C²` regularity already in `FieldProblem` | Makes the energy density measurable and integrable on the compact cell. |
| Joint continuity of \(q\) on the closed time-cell | Explicit **additional analytic hypothesis** in `TimeIntegralDefs.lean` | Supplies a uniform integrable bound on the pointwise time derivative and measurability of its value at the chosen time. |
| The chosen time satisfies \(a<t<b\) | Explicit theorem hypothesis | Supplies a two-sided time neighborhood where the PDE derivative identities hold. |
| The spatial cell is fixed and has finite area | Existing `cellMeasure`, proved usable through the closed-cell compactness argument | Makes a constant derivative bound integrable; no moving-boundary term arises. |

The original `FieldProblem` predicate and the previous `JointGuardGradientRegularity` assumption have **not** been shown to imply this new condition. The stronger joint classical regularity in the written uniqueness argument is an analytical route to it; a Lean derivation from component-by-component classical regularity is not included here. The assumptions are sufficient, not claimed minimal: Mathlib's underlying theorem permits an integrable dominating function instead of this compactness-based continuity route.

Periodicity and incompressibility are included in `FieldProblem`, but their cancellation identities are not used in this interchange step. A guard invariant range, positive viscosity and the uniform guard-gradient bound are also not needed for this particular result.

## 3. Derive the domination condition

Joint continuity and compactness give a finite bound \(B\) such that

\[
|q(s,x)|\le B
\]

on the time-cell. This is a bound on the **energy rate density**, distinct from the earlier guard-gradient constant \(M\). The proof derives the bound; it does not insert a numerical value. A constant is integrable over this finite cell.

The cell measure counts one fundamental square using half-open edges. Lean proves that almost every point of this measure belongs to the closed square used for compactness. Thus the bound applies on the actual integration measure.

## 4. Apply the dominated derivative theorem

`fieldproblem_energy_derivative_under_integral` applies the pinned Mathlib theorem `hasDerivAt_integral_of_dominated_loc_of_deriv_le`. It concludes both that \(q(t,\cdot)\) is integrable and that

\[
\boxed{\operatorname{HasDerivAt}\left(E,\int_{\rm cell}q(t,x)\,dx,t\right).}
\]

In ordinary notation, this proves

\[
E'(t)=\int_{\rm cell}\partial_t e_\Delta(t,x)\,dx
=\int_{\rm cell}q(t,x)\,dx
\]

at every interior time satisfying the stated hypotheses. It supplies the time-derivative/interchange part of the two-history energy argument. The equality uses the full original rates without dropping any term.

## 5. Carry forward the requested source context

The requested chat, **Find origins of 0.2 and 0.8**, records those low/high guard settings as assistant-chosen diagnostics, not derived thresholds. Neither diagnostic setting is used as a premise here. The new continuity predicate is labeled as an added analytic assumption, not attributed to the user's original conceptual description. All model coefficients, equations and initial fields remain unchanged.

That chat also distinguishes a state remaining continuous at a material-record write from its subsequent rate changing. Its material-record implementation is a separate tested realization; the present theorem is about the saved six-field continuum `FieldProblem`. The ordinary two-sided derivative theorem does not automatically apply at a discrete write or a rate discontinuity. Such a point needs its own regularity check; one-sided or piecewise statements and any genuine energy jump would require separate treatment. No smoothing rule or connection trigger is added to make this proof apply.

## 6. The next remaining gap

The new result gives the integral of the exact rate pairing. To reach the dissipative difference-energy balance, Lean must still split and integrate those PDE terms: cancel pressure and common transport, integrate the complete variable stress and scalar diffusion by parts, and identify all remaining coupling and reaction contributions. The guard invariant range and estimates controlling those contributions remain open. The full inequality \(E'\le CE\), uniqueness, existence and a regularity upgrade from the original solution predicate are not established by this step.
