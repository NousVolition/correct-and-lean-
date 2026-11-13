# A common gradient bound for the guard transport estimate

The new Lean declarations connect the classical argument's joint continuity assumptions to the existing whole-cell transport estimate. They establish one finite constant for both guards and for every time in the chosen closed finite interval. The guard fields and equations are unchanged.

## 1. State the assumptions precisely

Consider two existing candidate histories `z` and `w` satisfying the same `FieldProblem`, with the same prescribed inputs and initial fields, on `[a,b]`. That predicate already supplies spatial smoothness, periodicity, and incompressibility at each time.

Add `JointGuardGradientRegularity w a b`. It states that the two spatial derivatives of each comparison guard are jointly continuous in time and position on `[a,b] × [0,2π]²`. These four continuity assumptions follow from the stronger classical regularity stated in the written uniqueness argument. The original `FieldProblem` predicate alone does not include them, and this work does not derive them from that predicate.

The transport inequality needs only this part of the stronger classical assumptions. It does not construct either candidate solution.

## 2. Obtain one finite bound

For either comparison guard, the function

\[
(t,x)\longmapsto |\nabla\widetilde g(t,x)|^2
\]

is continuous on a compact time-space region. Lean applies boundedness of a continuous image of a compact set. Periodicity of the guard gives periodicity of its partial derivatives, so the bound extends from the closed cell to all spatial representatives.

The theorem `uniform_gradient_bound` concludes

\[
\exists M\ge 0,\quad \forall t\in[a,b],\ \forall x,\quad
|\nabla\widetilde g(t,x)|^2\le M^2.
\]

The order of the quantifiers matters. One constant is chosen before the time and position. The proof establishes existence of a finite constant, without computing a numerical value. The constant can depend on the comparison history and the chosen finite interval. No bound uniform over all solutions or arbitrarily long intervals is claimed.

## 3. Feed that bound into the existing estimate

Let `δu = u − ũ` and `h = g − g̃`. At a fixed time, the residual transport contribution tested against the guard difference is

\[
R_g(t)=\int_{\text{cell}} h(t,x)\,\delta u(t,x)\cdot\nabla\widetilde g(t,x)\,dx.
\]

The previously checked theorem `integrated_residual_bound` gives

\[
|R_g(t)|\le\frac12\left(\|\delta u(t)\|_2^2+M^2\|h(t)\|_2^2\right).
\]

The new `integrated_residual_bound_uniform` supplies the gradient hypothesis using step 2. The resulting spatial integral estimate holds at every time in `[a,b]`, with the same constant. This theorem does not integrate over time or differentiate an energy.

## 4. Apply it to both existing directional guards

`fieldproblem_guard_transport_bounds` specializes the result to `gAB` and `gBA` of the actual `Fields` structure. It extracts spatial regularity and periodicity from the two `FieldProblem` assumptions, derives each comparison guard's gradient bound, and uses the sum of the two nonnegative constants as one common `M`.

Thus both residual contributions are controlled by the squared velocity difference and their respective squared guard difference, throughout the interval. The previously proved common-transport cancellation remains available under its stated periodicity, smoothness, and incompressibility assumptions.

## 5. What this completes

This supplies the previously missing formal connection between joint guard-gradient continuity and the uniform constant needed in the guard transport part of the classical energy argument. The constant is a conclusion of the new theorem, not an extra assumed gradient bound.

The full energy differential inequality, the remaining momentum, diffusion and reaction estimates, and the existence and continuation results retain their earlier open status. This does not prove full Hug–Navier uniqueness or derive the extra joint continuity from the weaker saved solution predicate. The numerical prime-17 experiments motivate the question but are not premises of these theorems.

## Verification

`GuardTransportTimeDefs.lean` contains only the new sets and continuity predicate. `GuardTransportTime.lean` contains the three new proofs. The configured `WellposednessProofs` target imports the proof module, and `lakefile.toml` declares both new modules. Comparator lists all 13 statements, including the three additions, while its reference imports definitions only.

The reference was assembled after local proof development. `reference-freeze.json` records that fact. The previous ten-target Linux receipt is preserved under `evidence-linux/historical-ten/`. The current verification report records only the evidence available for the extended target list. Native development checks are recorded separately under `evidence-native-gradient/`.
