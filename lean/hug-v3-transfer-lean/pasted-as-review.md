**Your pasted Lean module — checked 1 November 2026**

**Original: FAIL. Separate repaired copy: PASS for all 44 supplied theorem statements in Lean and Comparator.** The original attachment is preserved byte for byte. I changed six proof bodies and clarified two introductory claims; all theorem statements, hypotheses and equations are unchanged. Both Lean's kernel and the independent nanoda kernel accepted the repaired proofs against the frozen original statements.

| Supplied proof | Original problem | Proof-only repair |
|---|---|---|
| `saturation_lipschitz` | A tactic ran after the preceding step had already closed the goal | Sequence the final algebra tactic only on remaining goals |
| `exchange_lipschitz_in_gap` | Automation did not establish the product and sign bounds in three branches | Prove the unscaled piecewise bound, then multiply by the nonnegative weight |
| `loadDrift_nonneg_at_zero` | Automation did not establish the triple-product sign | Supply the product-of-nonnegative-factors proof |
| `opening_unit` | The nested fraction/product bounds were not available in the required form | Bound the fraction, then the inner expression, then the outer product |
| `registration_unit` | The product inside the complement needed explicit bounds | Bound the product in `[0,1]`, its complement, then the outer product |
| `update_preserves_simplex` | Automation did not establish positivity of the weighted update | Rewrite it as a convex combination and prove both weights nonnegative |

These failures were defects in the supplied proof scripts. They did not refute the theorem statements. The original failed compilation also reported `sorryAx` dependencies for some failed declarations: Lean had inserted error-recovery placeholders. There is no literal `sorry` in the original pasted proofs, but its failed build must not be counted as verified. The repaired solution passes Comparator with only `propext`, `Quot.sound` and `Classical.choice` permitted.

The checked results include positive-part and saturation bounds, role-indexed drift equivalence, the exchange Lipschitz bound, inward boundary signs, encounter probability bounds, simplex preservation and three integral-solution facts. A harmless unused-tactic warning remains in the repaired saturation proof; neither checker rejected it.

The uniqueness wording needs care. `integralSolution_unique_A` establishes equality of the accumulated coordinate for two assumed solutions with the same initial state and **the same external input function**. `integralSolution_sub_eq` gives their integral-difference identity. `integralSolution_coord_unique_of_drift_eq` assumes that the relevant drifts agree and concludes equality of that coordinate. It does not prove equality of those drifts or complete a seven-coordinate cascade proof. None of these statements constructs a solution.

Similarly, inward boundary signs are useful ingredients for an invariance theorem; they are not, on their own, a proof that every full trajectory stays inside the admissible region. The simplex theorem concerns the specified update map under its stated interval and simplex assumptions.

This module imports the older seven-coordinate `ASModel.lean`. Its shared-input argument cannot be transferred directly to the current full Hug v3 system, where utility depends on evolving fields, relationships and decoded memory. The separate Hug v3 check retains all 193,122 coordinates and proves 14 local transfer statements. Full coupled existence and uniqueness remains open.

Files: [repaired module](pasted-as-review/RepairedASProofs.lean), [preserved original](pasted-as-review/PastedASProofs.lean), [proof-only diff](pasted-as-review/proof-only-repair.diff), [original failure log](pasted-as-review/linux-dev-original.log), [successful Comparator log](pasted-as-review/evidence-linux/comparator.log).
