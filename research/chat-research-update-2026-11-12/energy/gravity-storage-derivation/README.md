# What the original carrying and activation laws require of energy storage

**The original equations determine a necessary energy-exchange term, but the checked notes do not yet determine an independent gravitational storage law.** Six new Lean results establish the relevant calculus and a restricted obstruction for a two-variable storage function. No source equation, force, activation branch or solver setting was changed, and no new numerical run was needed.

## Source findings

The corrected corpus was freshly read from its original DOCX. Its 638 XML paragraphs retained the previously verified SHA-256 hash. The governing passages state:

- Paragraphs 230–231: incompressible momentum and the fixed-direction acceleration f = −(σ/ρ) a(q)eₖ, q = |∇S| − Γ.
- Paragraphs 260 and 266: the direction is fixed; opposition to motion and energy removal do not follow automatically.
- Paragraphs 517–520: S is carried by u, diffuses and receives a localized source; A accumulates excess input, with J = κA. The corpus identifies S as a signed status/context field and says coefficient units and domain data must be supplied.

Five archived Miro selections were also freshly parsed, including the response laws, accumulated-input coupling and energy-sign note. They retain A′ = γ(U−Ubaseline), the common transport/force loop, and the instruction to check the energy sign. These archived readable selections do not specify the energy conjugate to changing activation. They include skipped/foreign items and do not cover unread images or the current live board.

The retained meaning correction preserves the user's continuing carrying relationship, one intended continuum, unforced target, and gravity's conceptual role. “Fixed carrying” is not interpreted as frozen coordinates or fixed deformation. The later `HOLDING_AND_ENERGY.md` explicitly marks its potential and additional holding force as **ADDED**; the structural-memory note likewise marks its elastic energy and stress as additions. Those proposals cannot be used as if they were already consequences of the original source equations.

The source extraction and hashes are in [source-check.json](source-check.json). The absence of a derived law in this scoped review is not an exhaustive claim about every note, chat or image.

## 1. Derive what changes the activation

Use the original, unregularized source branch. Define

\[
D_t=\partial_t+u\cdot\nabla,\qquad
g=\nabla S,\qquad q=|g|-\Gamma,\qquad \alpha=a(q),
\]
\[
Q=D_{\rm diff}\Delta S+\kappa A(t)K_h(x-x_0),\qquad D_tS=Q.
\]

Here α denotes the activation value; A remains the original input accumulator. For sufficiently smooth fields,

\[
D_tg=\nabla Q-(\nabla u)^Tg.
\]

This follows by differentiating the original scalar equation: transporting a gradient also deforms it. Wherever |g| > 0 and the chosen response is differentiable at q,

\[
\boxed{D_t\alpha=
\frac{a'(q)}{|g|}\left[g\cdot\nabla Q-g^T(\nabla u)g\right].}
\]

Thus activation changes through **diffusion/source gradients** and **flow deformation**. Retaining the input A, or retaining the identity of a carried parcel, does not set D_tα to zero. The formula is conditional at a zero gradient or a sharp-switch corner; we have not silently changed the response to remove those cases.

Lean proves the finite-dimensional gradient-norm chain rule, the contraction split, and the resulting candidate-energy rate given the component gradient derivatives. The spatial commutation identity above is an analytic derivation under smoothness assumptions, not a newly formalized full PDE theorem.

## 2. Determine the natural storage candidate

Let ξ be unwrapped displacement along eₖ from the parcel's initial position, so D_tξ = uₖ. The original body force per volume is b = ρf = −σαeₖ and its power is p_AS = −σαuₖ.

For a differentiable, instantaneous candidate V(ξ,α) whose displacement-conjugate force matches this term at fixed activation, one must have

\[
\partial_\xi V=\sigma\alpha.
\]

Integrating with respect to ξ determines the entire displacement dependence:

\[
\boxed{V(\xi,\alpha)=\sigma\alpha\xi+C(\alpha).}
\]

This is a derived requirement for that class of candidates, not a selected new force. Its material rate is

\[
\boxed{D_tV=-p_{AS}
+\underbrace{[\sigma\xi+C'(\alpha)]D_t\alpha}_{\text{activation-energy exchange}}.}
\]

For the simplest C = 0 choice, substituting the original activation evolution gives the precise residual

\[
\boxed{\mathcal R=
\frac{\sigma\xi a'(q)}{|\nabla S|}
\left[\nabla S\cdot\nabla\!\left(D_{\rm diff}\Delta S+\kappa A K_h\right)
-\nabla S^T(\nabla u)\nabla S\right].}
\]

An actual energy partner must contribute −ℛ for the combined balance to close. An arbitrary function C(α) cannot universally cancel it: that would require C′(α) = −σξ at every independently accessible ξ with the same α. Lean proves this incompatibility for σ ≠ 0 under explicitly independent displacement/activation variations. **It does not exclude a constrained trajectory, a nonlocal energy functional, or a larger state/history.** The original PDE's entire accessible-state set has not been characterized.

The terminology “energy conjugate” means the coefficient multiplying the rate of an internal variable. The general requirement to account for internal-state changes is consistent with [Bower's constitutive-energy framework](https://solidmechanics.org/Text/Chapter3_1/Chapter3_1.php); the formulas here are derived from the user's force and transport equations, not imported material laws.

## 3. What the retained history supplies—and what it does not yet identify

Our preceding work already constructs

\[
R(t)=\sigma\alpha(t)\xi(t)
-\sigma\int_0^t\xi(s)\dot\alpha(s)\,ds,
\qquad \dot R=-p_{AS},
\]

with a fixed reference and corresponding volume average. It closes a history account without feeding anything back into the original equations. The previous Lean proof also establishes that R is exactly the opposite accumulated work receipt, up to its initial constant.

The newly derived ℛ explains the activation-history correction in that construction. It does not convert the receipt into an independently specified gravitational reservoir. The original source equations specify how the activation evolves; they do not supply an additional energy observable or energy-exchange law for the −ℛ term. Naming A, S or their recorded history as that reservoir requires a demonstrated mapping, units and a matching rate identity.

The existing material-energy budget is already paired with its own stress, recording and heat transfers. Reusing that same storage to cancel ℛ requires a new derived identity; adding it a second time would double-count it. No such cancellation is assumed here.

The earlier saved-run result remains valid within its scope: a passive volume path integral matched A/S work within 0.1094 ppm, while a position-only potential failed a closed-loop test in unwrapped space. Those results concern the later driven numerical branch, with its regularized activation and added material laws. They were not rerun or substituted for the original unregularized source equations in this derivation.

## Result and remaining mathematical connection

The required law is now specific: identify a configuration/history energy already intended by the notes whose independently derived rate contributes **−ℛ**, or establish a source-backed constraint that makes the residual vanish. Combined with V above and the already tracked viscous heat, that would supply the missing cancellation. The continuing carrying relationship alone does not select such a law or a unique energy normalization.

This leaves the user's gravitational interpretation available for further definition. It does not establish classical self-gravity, a finite energy capacity, or general total-energy conservation from the original equations alone. No gravitational force, new stress, feedback rule, reset or exhaustion rule has been inserted.

## Verification and reproduction

[StorageRequirements.lean](StorageRequirements.lean) contains six new checked statements:

1. Derivative of the gradient magnitude along a path, away from zero gradient.
2. Source/deformation contraction split.
3. Candidate-height energy residual under the stated derivatives.
4. The form of every differentiable two-variable candidate matching the fixed-activation force.
5. Its required activation-energy conjugate.
6. Incompatibility of a nonzero coupling with independently varying, energetically unpaid activation in that two-variable class.

[verification.json](verification.json) and `logs/` record native Lean compilation and the axiom audit. Imported original sources retain their bytes and prior checked object hashes. `source_check.py` reproduces the read-only local source extraction; `build-native.ps1` rebuilds with the recorded Lean 4.34.0-rc2 toolchain and pinned Mathlib cache. No independent external kernel, exhaustive source search, new simulation or complete PDE energy theorem is claimed.
