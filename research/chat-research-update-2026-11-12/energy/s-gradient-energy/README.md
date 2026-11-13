# Can S smoothing and rebuilding supply the missing energy?

**The checked original notes supply a transport/source law, but no independently specified energy law that fills the 43.6%.** There is a useful new constraint: the saved run starts with S=0 and A=0, so ordinary nonnegative quadratic scalar, gradient and accumulated-input stores begin at their minimum. Each ends above its initial value. They therefore require net funding over the full run and cannot provide the missing net release.

The original equations and saved data remain unchanged. This check makes no new solver steps. It does not rule out every nonlinear, nonlocal, cross-coupled or history-dependent energy law.

## What the original notes actually give

I read both Desktop corpus versions, all ten documents in the original revision pack, nine archived board exports, and six later specification/source-audit documents. The board scan extracted 598 distinct readable text items across the overlapping exports. It did not read skipped foreign/image content or refresh the live board. Hashes, exact excerpts and coverage are recorded in [source-scan.json](source-scan.json).

| Source | Actual content relevant to this question |
|---|---|
| Combined corpus, paragraphs 455–457 | Diffusion is described as spreading or smoothing; S evolves by advection, diffusion and an accumulated-input point source. |
| Corrected corpus, paragraphs 517–520 | The regularized source is κ A K_h; A stores accumulated input. The text explains that sustained input can keep increasing the total scalar field. |
| Corrected corpus, paragraphs 524–529 | S is a signed status/context field; D_diff is a diffusion coefficient with length²/time units. |
| Board item 3458764687916065207 | Transport, diffusion and a localized source for S. |
| Board items 3458764687917934072 and 3458764687916065214 | An energy-sign check and further coupling/units obligations, rather than a supplied free-energy formula. |
| Later SPECIFICATION.md, E2, lines 323–331 | A derived balance for ½∫S², explicitly described as a mathematical field-norm balance, not an established physical memory energy. |

The user's intended S energy-transfer role is retained. The inspected equations do not yet fix the stored-energy density, conversion coefficient, or matched energy debit/credit for that role. The older specification's actuator language is not adopted as a definition of the intended unforced system. The chosen original A/S branch remains the target; later gravity, fabric and thermal proposals do not silently replace it.

## What can be derived without changing S

For smooth fields on the periodic domain, constant D_diff and incompressible u, let J=κ A K_h. The original equation is

S_t+u·∇S=D_diff ΔS+J.

It gives the scalar-norm identity already represented in the earlier proof work:

d/dt [½∫S²] = −D_diff∫|∇S|² + ∫S J.

This explains smoothing and rebuilding of the scalar norm. Assigning it a physical energy coefficient is a separate constitutive choice, not a result of multiplication by S.

For the gradient candidate E_g=(c/2)∫|∇S|² with a constant coefficient c, the same unchanged equation gives

dE_g/dt = −c∫(∇S⊗∇S):∇u − c D_diff∫(ΔS)² + c∫∇S·∇J.

This derivation includes both the energy released by smoothing and the cost or release associated with the source. It also includes deformation. Dropping the source term and counting only diffusion would not be a total energy account.

The activation-history demand has a different weight:

R = ∫ [σ ξ a'(|∇S|−Γ)/|∇S|] ∇S·[∇(D_diff ΔS+J)−(∇u)ᵀ∇S].

Here ξ is the unwrapped displacement in the original coupling direction. This is the prior candidate's remainder, not a new force. Its weight varies with position, history and activation. The notes do not identify it with a constant physical coefficient c. The previous positive-gradient/differentiability qualifications apply to this continuum activation formula; the numerical run uses its declared regularized norm.

The local finite-dimensional gradient-square rate and its transport split are now checked in Lean. The full spatial commutator, periodic integration by parts and differentiation under the spatial integral are analytical assumptions in this derivation, not a newly formalized continuum PDE theorem.

## The saved-run sign test

Read-only checks of all 62 saved threshold-1 states give these values. The unit-periodic-domain average equals its volume integral. These quantities retain their scalar/model units; no joule conversion is assumed.

| Candidate quantity before an energy coefficient is chosen | Initial | Final |
|---|---:|---:|
| ½∫S² | 0 | 7.6917417086e-4 |
| ½∫|centered ∇S|², matching activation's gradient stencil | 0 | 5.8946547881e-2 |
| ½∫|forward ∇S|², matching the diffusion stencil's discrete identity | 0 | 6.4157834583e-2 |
| ½A² | 0 | 2.0666414745e-5 |

The existing endpoint-history account needs another store to change by **−1.0654747938e-5**. A nonnegative coefficient times any quantity in this table changes by zero or a positive amount. Nonnegative combinations do too. Adding a constant preload changes neither difference. Intermediate decreases cannot reverse this full-interval sign result.

For example, the centered-gradient quantity falls from 0.0774007448 at time 0.8 to 0.0589465479 at time 1.2. That late release is real in the norm account. But the run began at zero: building the gradient before time 0.8 must also be included.

As a diagnostic only, fitting an unrestricted coefficient to force the final gradient amount to pay the hole requires **c=−0.0001807527043**. It then misses the required account by **1.2896501212e-5** at time 0.8. Thus a single constant coefficient of either sign does not match this saved history. That fitted value is not adopted as a physical law. Similar endpoint fits for S², the diffusion-compatible gradient norm and A² also fail earlier in the run; details are in [saved-norm-check.json](saved-norm-check.json).

The discrete diffusion identity was independently checked at every saved state, using the forward-difference norm appropriate to the native Laplacian. Maximum defect was **5.55e-17**. Centered and forward gradients are deliberately distinguished; they give the same sign conclusion here.

## What this settles and what remains open

Smoothing and rebuilding have a derived *quantity balance*. The original readable notes checked here do not supply a physical storage law with the required conversion and exchange. The ordinary positive quadratic candidates cannot supply this run's missing net release; even a single fitted coefficient of either sign fails the recorded time history.

This is not a general impossibility result for the user's Hug model. A different free energy could have a nonzero initial reservoir, a non-quadratic landscape, configuration cross terms, or genuine history dependence. Such a law must be independently grounded in the original setup and its rate must match the demand along the unchanged equations. Defining it as minus the integrated demand would only reproduce a work account.

The 43.6% remains unresolved. The new result is that ordinary scalar/gradient smoothing energy is not a hidden payment that can simply be inserted into the already-checked balance.

## Verification and files

- [New Lean identities](GradientStorage.lean) and [axiom audit](logs/GradientStorageAudit.log).
- [Saved quantities at every checkpoint](saved-norm-history.csv) and [numerical check](saved-norm-check.json).
- [Source excerpts and hashes](source-scan.json), [verification receipt](verification.json).

Seven new Lean statements cover the quadratic derivative, transport split, nonnegativity, zero initial state, initial-minimum obstruction, its quadratic instance, and the integrated smoothing/rebuilding accounting identity. Scope is their stated hypotheses; numerical trajectories are not certified by these theorems. The compiler/axiom receipt determines check status. No external kernel run is claimed.

The Lean package includes unchanged dependency modules and a pinned Lake configuration. `build-native.ps1` also rebuilds with the existing matching native toolchain/cache. Numerical/source scripts are preserved in `scripts/`; they retain the workspace-relative `work/s-gradient-energy/` layout and original read-only source paths, and depend on the preceding full-carrying output. This is an evidence package, not a standalone copy of the full saved run. Earlier proofs, reports, notes and saved frames are preserved.
